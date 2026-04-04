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
        public async Task<IActionResult> GetPlaylistSongs(int playlistId)
        {
            var songs = await _context.PlaylistSongs
                .Where(ps => ps.PlaylistId == playlistId)
                .Include(ps => ps.Song)
                .OrderBy(ps => ps.Position)
                .Select(ps => ps.Song)
                .ToListAsync();

            return Ok(songs);
        }

        [HttpGet("albums/{albumId}/songs")]
        public async Task<IActionResult> GetAlbumSongs(int albumId)
        {
            var songs = await _context.Songs
                .Where(s => s.AlbumId == albumId)
                .ToListAsync();

            return Ok(songs);
        }

        [HttpGet("check-saved")]
        public async Task<IActionResult> CheckSaved([FromQuery] string userId, [FromQuery] int playlistId)
        {
            if (!Guid.TryParse(userId, out var guidUserId)) return Ok(new { isSaved = false });

            var isSaved = await _context.SavedPlaylists
                .AnyAsync(s => s.UserId == guidUserId && s.PlaylistId == playlistId);
            return Ok(new { isSaved });
        }

        [HttpPost("toggle-save")]
        public async Task<IActionResult> ToggleSave([FromBody] SavePlaylistRequest request)
        {
            if (!Guid.TryParse(request.UserId, out var guidUserId)) return BadRequest();

            var existing = await _context.SavedPlaylists
                .FirstOrDefaultAsync(s => s.UserId == guidUserId && s.PlaylistId == request.PlaylistId);

            if (existing != null)
            {
                _context.SavedPlaylists.Remove(existing);
            }
            else
            {
                _context.SavedPlaylists.Add(new SavedPlaylist
                {
                    UserId = guidUserId,
                    PlaylistId = request.PlaylistId,
                    CreatedAt = DateTime.UtcNow
                });
            }

            await _context.SaveChangesAsync();
            return Ok(new { success = true });
        }

        [HttpGet("user/{userId}/saved-playlists")]
        public async Task<IActionResult> GetSavedPlaylists(string userId)
        {
            if (!Guid.TryParse(userId, out var guidUserId)) return Ok(new List<Playlist>());

            var playlists = await _context.SavedPlaylists
                .Where(s => s.UserId == guidUserId)
                .Include(s => s.Playlist)
                .Select(s => s.Playlist)
                .ToListAsync();

            return Ok(playlists);
        }
    }

    public class SavePlaylistRequest
    {
        public string UserId { get; set; } = string.Empty;
        public int PlaylistId { get; set; }
    }
}
