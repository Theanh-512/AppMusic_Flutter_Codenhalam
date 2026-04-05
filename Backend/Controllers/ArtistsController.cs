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
                .OrderBy(a => a.Id)
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
        public async Task<IActionResult> ReleaseSong([FromForm] string userId, [FromForm] string title, IFormFile audioFile, IFormFile? coverFile)
        {
            if (!Guid.TryParse(userId, out var guidUserId)) return BadRequest();

            var artist = await _context.Artists.FirstOrDefaultAsync(a => a.UserId == guidUserId);
            if (artist == null) return Unauthorized(new { message = "Bạn không phải là nghệ sĩ" });

            // Create directories if not exist
            var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
            if (!Directory.Exists(uploadsPath)) Directory.CreateDirectory(uploadsPath);

            // Save audio
            var audioName = $"{Guid.NewGuid()}{Path.GetExtension(audioFile.FileName)}";
            var audioPath = Path.Combine(uploadsPath, audioName);
            using (var stream = new FileStream(audioPath, FileMode.Create))
            {
                await audioFile.CopyToAsync(stream);
            }

            // Save cover
            string? coverUrl = null;
            if (coverFile != null)
            {
                var coverName = $"{Guid.NewGuid()}{Path.GetExtension(coverFile.FileName)}";
                var coverPath = Path.Combine(uploadsPath, coverName);
                using (var stream = new FileStream(coverPath, FileMode.Create))
                {
                    await coverFile.CopyToAsync(stream);
                }
                coverUrl = $"/uploads/{coverName}";
            }

            // Create Song
            var song = new Song
            {
                Title = title,
                ArtistName = artist.Name,
                AudioUrl = $"/uploads/{audioName}",
                CoverUrl = coverUrl,
                CreatedAt = DateTime.UtcNow
            };

            _context.Songs.Add(song);
            await _context.SaveChangesAsync();

            // Link Artist to Song
            _context.SongArtists.Add(new SongArtist { SongId = song.Id, ArtistId = artist.Id });
            await _context.SaveChangesAsync();

            return Ok(song);
        }
    }
}
