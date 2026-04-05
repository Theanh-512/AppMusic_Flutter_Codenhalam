using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SongsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public SongsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/songs/trending
        [HttpGet("trending")]
        public async Task<IActionResult> GetTrendingSongs([FromQuery] int limit = 50)
        {
            var songs = await _context.Songs
                .OrderByDescending(s => s.Id)
                .Take(limit)
                .ToListAsync();

            return Ok(songs);
        }

        // GET: api/songs
        [HttpGet]
        public async Task<IActionResult> GetAllSongs([FromQuery] string? query, [FromQuery] int limit = 100)
        {
            var q = _context.Songs.AsQueryable();

            if (!string.IsNullOrEmpty(query))
            {
                q = q.Where(s => (s.Title != null && s.Title.ToLower().Contains(query.ToLower())) || 
                                 (s.ArtistName != null && s.ArtistName.ToLower().Contains(query.ToLower())));
            }

            var songs = await q
                .OrderByDescending(s => s.Id)
                .Take(limit)
                .ToListAsync();

            return Ok(songs);
        }

        // GET: api/songs/random
        [HttpGet("random")]
        public async Task<IActionResult> GetRandomSong()
        {
            var songs = await _context.Songs
                .OrderBy(s => Guid.NewGuid()) // Random order in EF
                .Take(50)
                .ToListAsync();

            if (!songs.Any()) return NotFound(new { message = "No songs found" });

            var random = new Random();
            var randomSong = songs[random.Next(songs.Count)];
            return Ok(randomSong);
        }

        // GET: api/songs/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetSongById(int id)
        {
            var song = await _context.Songs.FirstOrDefaultAsync(s => s.Id == id);
            if (song == null) return NotFound(new { message = "Song not found" });
            return Ok(song);
        }

        [HttpGet("category")]
        public async Task<IActionResult> GetByCategory([FromQuery] string type, [FromQuery] string name, [FromQuery] int limit = 50)
        {
            var pattern = $"%{name}%";
            var query = _context.Songs.FromSqlInterpolated($@"
                SELECT s.* 
                FROM songs s
                LEFT JOIN v_song_details v ON s.id = v.id
                WHERE ({(type == "genre" ? 1 : 0)} = 1 AND v.genres::text ILIKE {pattern})
                   OR ({(type == "mood" ? 1 : 0)} = 1 AND v.moods::text ILIKE {pattern})
                   OR ({(type == "hashtag" ? 1 : 0)} = 1 AND v.hashtags::text ILIKE {pattern})
            ");

            var songs = await query
                .OrderBy(s => s.Title) // Ensure OrderBy
                .Take(limit)
                .ToListAsync();

            return Ok(songs);
        }

        // GET: api/songs/artist/{artistName}
        [HttpGet("artist/{artistName}")]
        public async Task<IActionResult> GetSongsByArtist(string artistName, [FromQuery] int limit = 20)
        {
            var songs = await _context.Songs
                .Where(s => s.ArtistName == artistName)
                .OrderBy(s => s.Id)
                .Take(limit)
                .ToListAsync();

            return Ok(songs);
        }
        // DELETE: api/songs/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSong(int id, [FromQuery] Guid userId)
        {
            var song = await _context.Songs.FindAsync(id);
            if (song == null) return NotFound();

            // Verify ownership if possible
            // Note: Currently songs don't have owner_id, we need to add it or check via artist
            var artist = await _context.Artists.FirstOrDefaultAsync(a => a.UserId == userId);
            if (artist == null || song.ArtistName != artist.Name)
            {
                return Forbid();
            }

            _context.Songs.Remove(song);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Xóa bài hát thành công" });
        }

        // PUT: api/songs/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSong(int id, [FromBody] SongUpdateRequest request)
        {
            var song = await _context.Songs.FindAsync(id);
            if (song == null) return NotFound();

            // Verify ownership
            var artist = await _context.Artists.FirstOrDefaultAsync(a => a.UserId == request.UserId);
            if (artist == null || song.ArtistName != artist.Name)
            {
                return Forbid();
            }

            song.Title = request.Title;
            await _context.SaveChangesAsync();
            return Ok(song);
        }
    }

    public class SongUpdateRequest
    {
        public Guid UserId { get; set; }
        public string Title { get; set; } = string.Empty;
    }
}
