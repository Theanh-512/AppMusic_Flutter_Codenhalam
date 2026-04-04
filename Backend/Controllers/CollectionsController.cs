using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CollectionsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CollectionsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("system-playlists")]
        public async Task<IActionResult> GetSystemPlaylists()
        {
            var playlists = await _context.Playlists
                .OrderBy(p => p.Id)
                .Take(10)
                .ToListAsync();
            return Ok(playlists);
        }

        [HttpGet("new-albums")]
        public async Task<IActionResult> GetNewAlbums()
        {
            var albums = await _context.Albums
                .OrderByDescending(a => a.Id)
                .Take(10)
                .ToListAsync();
            return Ok(albums);
        }

        [HttpGet("playlists/{playlistId}/songs")]
        public IActionResult GetPlaylistSongs(int playlistId)
        {
            // Stub implementation
            return Ok(new List<Song>());
        }

        [HttpGet("albums/{albumId}/songs")]
        public IActionResult GetAlbumSongs(int albumId)
        {
            // Stub implementation
            return Ok(new List<Song>());
        }

        [HttpGet("check-saved")]
        public IActionResult CheckSaved([FromQuery] string userId, [FromQuery] int playlistId)
        {
            return Ok(new { isSaved = false });
        }

        [HttpPost("toggle-save")]
        public IActionResult ToggleSave([FromBody] object request)
        {
            return Ok(new { success = true });
        }

        [HttpGet("user/{userId}/saved-playlists")]
        public IActionResult GetSavedPlaylists(string userId)
        {
            return Ok(new List<Playlist>());
        }
    }
}
