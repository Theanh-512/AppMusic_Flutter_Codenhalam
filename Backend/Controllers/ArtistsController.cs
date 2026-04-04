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
            string artistName = id;
            if (Guid.TryParse(id, out var guidId))
            {
                var artist = await _context.Artists.FindAsync(guidId);
                if (artist != null) artistName = artist.Name;
            }

            var songs = await _context.Songs
                .Where(s => s.ArtistName == artistName)
                .ToListAsync();
            return Ok(songs);
        }

        [HttpGet("{id}/albums")]
        public async Task<IActionResult> GetArtistAlbums(string id)
        {
            string artistName = id;
            if (Guid.TryParse(id, out var guidId))
            {
                var artist = await _context.Artists.FindAsync(guidId);
                if (artist != null) artistName = artist.Name;
            }

            var albums = new List<Album>();
            return Ok(albums);
        }
    }
}
