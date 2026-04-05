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
            try 
            {
                if (!Guid.TryParse(request.UserId, out var guidUserId)) 
                {
                    Console.WriteLine($"DEBUG: Invalid UserId format: {request.UserId}");
                    return BadRequest(new { message = "Invalid User ID format" });
                }

                // Check if already exists
                var existing = await _context.Favorites
                    .FirstOrDefaultAsync(f => f.UserId == guidUserId && f.SongId == request.SongId);

                // Optional but good: Check if song exists
                var songExists = await _context.Songs.AnyAsync(s => s.Id == request.SongId);
                if (!songExists) return NotFound(new { message = "Song not found" });

                if (existing != null)
                {
                    _context.Favorites.Remove(existing);
                    await _context.SaveChangesAsync();
                    return Ok(new { isLiked = false });
                }
                else
                {
                    // Check change tracker to prevent race conditions within the same context
                    var isTracked = _context.Favorites.Local
                        .Any(f => f.UserId == guidUserId && f.SongId == request.SongId);

                    if (!isTracked)
                    {
                        var newFavorite = new Favorite
                        {
                            UserId = guidUserId,
                            SongId = request.SongId,
                            CreatedAt = DateTime.UtcNow
                        };
                        _context.Favorites.Add(newFavorite);
                        await _context.SaveChangesAsync();
                    }
                    return Ok(new { isLiked = true });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR in ToggleLike: {ex.Message}");
                if (ex.InnerException != null) Console.WriteLine($"INNER: {ex.InnerException.Message}");
                return StatusCode(500, new { message = ex.Message, inner = ex.InnerException?.Message });
            }
        }
    }

    public class FavoriteToggleRequest
    {
        [System.Text.Json.Serialization.JsonPropertyName("userId")]
        public string UserId { get; set; } = string.Empty;

        [System.Text.Json.Serialization.JsonPropertyName("songId")]
        public int SongId { get; set; }
    }
}
