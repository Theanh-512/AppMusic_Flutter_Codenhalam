using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ArtistsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ArtistsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("popular")]
        public async Task<IActionResult> GetPopularArtists([FromQuery] int limit = 20)
        {
            var artists = await _context.Artists
                .OrderBy(a => a.Name) // Added OrderBy
                .Take(limit)
                .ToListAsync();
            return Ok(artists);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetArtistDetail(string id)
        {
            if (Guid.TryParse(id, out var guidId))
            {
                var artist = await _context.Artists.FindAsync(guidId);
                if (artist != null) return Ok(artist);
            }
            return NotFound();
        }

        [HttpGet("{id}/songs")]
        public async Task<IActionResult> GetArtistSongs(string id)
        {
            if (!Guid.TryParse(id, out var guidId)) return Ok(new List<Song>());

            var songs = await _context.SongArtists
                .Where(sa => sa.ArtistId == guidId)
                .Include(sa => sa.Song)
                .Select(sa => sa.Song)
                .ToListAsync();

            return Ok(songs);
        }

        [HttpGet("{id}/albums")]
        public async Task<IActionResult> GetArtistAlbums(string id)
        {
            if (!Guid.TryParse(id, out var guidId)) return Ok(new List<Album>());

            // For now, check if the song artists' songs belong to albums
            var albums = await _context.SongArtists
                .Where(sa => sa.ArtistId == guidId)
                .Include(sa => sa.Song)
                .ThenInclude(s => s != null ? s.Album : null)
                .Select(sa => sa.Song != null ? sa.Song.Album : null)
                .Where(a => a != null)
                .Distinct()
                .OrderBy(a => a!.Title) // Added OrderBy after Distinct
                .ToListAsync();

            return Ok(albums);
        }
        [HttpGet("me/{userId}")]
        public async Task<IActionResult> GetMyArtistProfile(string userId)
        {
            if (!Guid.TryParse(userId, out var guidUserId)) return BadRequest();
            var artist = await _context.Artists.FirstOrDefaultAsync(a => a.UserId == guidUserId);
            if (artist == null) return NotFound();
            return Ok(artist);
        }

        [HttpPost("release")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> ReleaseSong([FromForm] ReleaseSongRequest request)
        {
            if (!Guid.TryParse(request.UserId, out var guidUserId)) return BadRequest(new { message = "Invalid User ID" });

            var artist = await _context.Artists.FirstOrDefaultAsync(a => a.UserId == guidUserId);
            if (artist == null) return Unauthorized(new { message = "Bạn không phải là nghệ sĩ" });

            if (request.AudioFile == null) return BadRequest(new { message = "Vui lòng chọn file nhạc" });

            // Create directories if not exist
            var wwwroot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            if (!Directory.Exists(wwwroot)) Directory.CreateDirectory(wwwroot);
            var uploadsPath = Path.Combine(wwwroot, "uploads");
            if (!Directory.Exists(uploadsPath)) Directory.CreateDirectory(uploadsPath);

            // Save audio
            var audioName = $"{Guid.NewGuid()}{Path.GetExtension(request.AudioFile.FileName)}";
            var audioPath = Path.Combine(uploadsPath, audioName);
            using (var stream = new FileStream(audioPath, FileMode.Create))
            {
                await request.AudioFile.CopyToAsync(stream);
            }

            // Save cover
            string? coverUrl = null;
            if (request.CoverFile != null)
            {
                var coverName = $"{Guid.NewGuid()}{Path.GetExtension(request.CoverFile.FileName)}";
                var coverPath = Path.Combine(uploadsPath, coverName);
                using (var stream = new FileStream(coverPath, FileMode.Create))
                {
                    await request.CoverFile.CopyToAsync(stream);
                }
                coverUrl = $"/uploads/{coverName}";
            }

            // Create Song
            var song = new Song
            {
                Title = request.Title,
                ArtistName = artist.Name,
                AudioUrl = $"/uploads/{audioName}",
                CoverUrl = coverUrl,
                DurationSeconds = request.DurationSeconds > 0 ? request.DurationSeconds : 180,
                TotalListens = 0,
                LikeCount = 0,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.Songs.Add(song);
            await _context.SaveChangesAsync();

            // Link Artist to Song
            _context.SongArtists.Add(new SongArtist 
            { 
                SongId = song.Id, 
                ArtistId = artist.Id, 
                Role = "main" 
            });
            await _context.SaveChangesAsync();

            return Ok(song);
        }
    }

    public class ReleaseSongRequest
    {
        public string UserId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public int DurationSeconds { get; set; } = 180;
        public IFormFile? AudioFile { get; set; }
        public IFormFile? CoverFile { get; set; }
    }
}
