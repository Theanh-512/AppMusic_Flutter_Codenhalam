using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FavoritesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FavoritesController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("{userId}")]
        public async Task<IActionResult> GetLikedSongs(string userId)
        {
            if (!Guid.TryParse(userId, out var guidUserId)) return Ok(new List<Song>());

            var favorites = await _context.Favorites
                .Where(f => f.UserId == guidUserId)
                .Include(f => f.Song)
                .OrderByDescending(f => f.CreatedAt)
                .Select(f => f.Song)
                .ToListAsync();

            return Ok(favorites);
        }

        [HttpGet("check")]
        public async Task<IActionResult> IsLiked([FromQuery] string userId, [FromQuery] int songId)
        {
            if (!Guid.TryParse(userId, out var guidUserId)) return Ok(new { isLiked = false });

            var isLiked = await _context.Favorites
                .AnyAsync(f => f.UserId == guidUserId && f.SongId == songId);
            return Ok(new { isLiked });
        }

        [HttpPost("toggle")]
        public async Task<IActionResult> ToggleLike([FromBody] FavoriteToggleRequest request)
        {
            if (!Guid.TryParse(request.UserId, out var guidUserId)) return BadRequest();

            var existing = await _context.Favorites
                .FirstOrDefaultAsync(f => f.UserId == guidUserId && f.SongId == request.SongId);

            var song = await _context.Songs.FindAsync(request.SongId);
            if (song == null) return NotFound(new { message = "Song not found" });

            if (existing != null)
            {
                _context.Favorites.Remove(existing);
            }
            else
            {
                var newFavorite = new Favorite
                {
                    UserId = guidUserId,
                    SongId = request.SongId,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Favorites.Add(newFavorite);
            }

            await _context.SaveChangesAsync();
            return Ok(new { isLiked = existing == null });
        }
    }

    public class FavoriteToggleRequest
    {
        public string UserId { get; set; } = string.Empty;
        public int SongId { get; set; }
    }
}
