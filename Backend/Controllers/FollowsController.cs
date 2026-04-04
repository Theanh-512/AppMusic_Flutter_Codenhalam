using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FollowsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FollowsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("check")]
        public async Task<IActionResult> CheckFollow([FromQuery] string userId, [FromQuery] string artistId)
        {
            if (!Guid.TryParse(userId, out var guidUserId) || !Guid.TryParse(artistId, out var guidArtistId))
                return Ok(new { isFollowed = false });

            var isFollowed = await _context.Follows
                .AnyAsync(f => f.UserId == guidUserId && f.ArtistId == guidArtistId);
            return Ok(new { isFollowed });
        }

        [HttpPost("toggle")]
        public async Task<IActionResult> ToggleFollow([FromBody] FollowRequest request)
        {
            if (!Guid.TryParse(request.UserId, out var guidUserId) || !Guid.TryParse(request.ArtistId, out var guidArtistId))
                return BadRequest();

            var existing = await _context.Follows
                .FirstOrDefaultAsync(f => f.UserId == guidUserId && f.ArtistId == guidArtistId);

            if (existing != null)
            {
                _context.Follows.Remove(existing);
            }
            else
            {
                _context.Follows.Add(new Follow
                {
                    UserId = guidUserId,
                    ArtistId = guidArtistId,
                    CreatedAt = DateTime.UtcNow
                });
            }

            await _context.SaveChangesAsync();
            return Ok(new { success = true });
        }

        [HttpGet("user/{userId}/artists")]
        public async Task<IActionResult> GetFollowedArtists(string userId)
        {
            if (!Guid.TryParse(userId, out var guidUserId))
                return Ok(new List<Artist>());

            var artists = await _context.Follows
                .Where(f => f.UserId == guidUserId)
                .Include(f => f.Artist)
                .Select(f => f.Artist)
                .ToListAsync();

            return Ok(artists);
        }
    }

    public class FollowRequest
    {
        public string UserId { get; set; } = string.Empty;
        public string ArtistId { get; set; } = string.Empty;
    }
}
