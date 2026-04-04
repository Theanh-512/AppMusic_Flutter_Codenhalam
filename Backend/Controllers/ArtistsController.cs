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
    }
}
