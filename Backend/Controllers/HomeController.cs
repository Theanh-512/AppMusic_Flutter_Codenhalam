using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HomeController : ControllerBase
    {
        private readonly AppDbContext _context;

        public HomeController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetHomeData()
        {
            var banners = await _context.HomeBanners
                .Where(b => b.IsActive && 
                           (b.StartsAt == null || b.StartsAt <= DateTime.UtcNow) && 
                           (b.EndsAt == null || b.EndsAt >= DateTime.UtcNow))
                .OrderBy(b => b.DisplayOrder)
                .ToListAsync();

            var sections = await _context.HomeSections
                .Where(s => s.IsActive)
                .OrderBy(s => s.DisplayOrder)
                .ToListAsync();

            var items = await _context.HomeSectionItemViews
                .Where(i => i.IsActive)
                .OrderBy(i => i.DisplayOrder)
                .ToListAsync();

            return Ok(new
            {
                Banners = banners,
                Sections = sections,
                SectionItems = items
            });
        }

        [HttpGet("recent/{userId}")]
        public async Task<IActionResult> GetRecentItems(string userId)
        {
            if (!Guid.TryParse(userId, out var guidUserId))
                return BadRequest("Invalid user ID");

            var recentItems = await _context.HomeSectionItemViews
                .FromSqlRaw(@"
                    SELECT 
                        uri.id,
                        0 as section_id,
                        'recently_played' as section_code,
                        'Nghe gần đây' as section_title,
                        uri.item_type,
                        uri.item_key,
                        0 as display_order,
                        true as is_active,
                        CASE 
                            WHEN uri.item_type = 'playlist' THEN p.name
                            WHEN uri.item_type = 'artist' THEN a.name
                            WHEN uri.item_type = 'album' THEN al.title
                            WHEN uri.item_type = 'song' THEN s.title
                        END as display_title,
                        CASE 
                            WHEN uri.item_type = 'playlist' THEN p.description
                            WHEN uri.item_type = 'artist' THEN a.bio
                            WHEN uri.item_type = 'album' THEN al.description
                            WHEN uri.item_type = 'song' THEN s.artist
                        END as display_subtitle,
                        CASE 
                            WHEN uri.item_type = 'playlist' THEN p.cover_url
                            WHEN uri.item_type = 'artist' THEN a.avatar_url
                            WHEN uri.item_type = 'album' THEN al.cover_url
                            WHEN uri.item_type = 'song' THEN s.cover_url
                        END as image_url
                    FROM user_recent_items uri
                    LEFT JOIN playlists p ON uri.item_type = 'playlist' AND p.id::text = uri.item_key
                    LEFT JOIN artists a ON uri.item_type = 'artist' AND a.id::text = uri.item_key
                    LEFT JOIN albums al ON uri.item_type = 'album' AND al.id::text = uri.item_key
                    LEFT JOIN songs s ON uri.item_type = 'song' AND s.id::text = uri.item_key
                    WHERE uri.user_id = {0}
                    ORDER BY uri.last_interacted_at DESC
                    LIMIT 20", guidUserId)
                .ToListAsync();

            return Ok(recentItems);
        }
    }
}
