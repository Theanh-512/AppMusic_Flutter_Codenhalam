using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PlaylistsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PlaylistsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/playlists/user/{userId}
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserPlaylists(string userId)
        {
            var playlists = new List<Playlist>();
            if (Guid.TryParse(userId, out var guidUserId))
            {
                playlists = await _context.Playlists
                    .Where(p => p.UserId == guidUserId)
                    .OrderByDescending(p => p.CreatedAt)
                    .ToListAsync();
            }

            return Ok(playlists);
        }

        // POST: api/playlists
        [HttpPost]
        public async Task<IActionResult> CreatePlaylist([FromBody] Playlist playlist)
        {
            playlist.CreatedAt = DateTime.UtcNow;
            _context.Playlists.Add(playlist);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetUserPlaylists), new { userId = playlist.UserId }, playlist);
        }

        // DELETE: api/playlists/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePlaylist(int id)
        {
            var playlist = await _context.Playlists.FindAsync(id);
            if (playlist == null) return NotFound();

            _context.Playlists.Remove(playlist);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // PUT: api/playlists/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> RenamePlaylist(int id, [FromBody] Dictionary<string, string> data)
        {
            var playlist = await _context.Playlists.FindAsync(id);
            if (playlist == null) return NotFound();

            if (data.ContainsKey("name"))
            {
                playlist.Name = data["name"];
                await _context.SaveChangesAsync();
            }

            return Ok(playlist);
        }

        // POST: api/playlists/{id}/songs
        [HttpPost("{id}/songs")]
        public async Task<IActionResult> AddSongsToPlaylist(int id, [FromBody] PlaylistSongsRequest request)
        {
            var playlist = await _context.Playlists.FindAsync(id);
            if (playlist == null) return NotFound();

            foreach (var songId in request.SongIds)
            {
                var existing = await _context.PlaylistSongs
                    .AnyAsync(ps => ps.PlaylistId == id && ps.SongId == songId);
                
                if (!existing)
                {
                    _context.PlaylistSongs.Add(new PlaylistSong
                    {
                        PlaylistId = id,
                        SongId = songId,
                        CreatedAt = DateTime.UtcNow
                    });
                }
            }

            await _context.SaveChangesAsync();
            return Ok();
        }

        // DELETE: api/playlists/{id}/songs/{songId}
        [HttpDelete("{id}/songs/{songId}")]
        public async Task<IActionResult> RemoveSongFromPlaylist(int id, int songId)
        {
            var item = await _context.PlaylistSongs
                .FirstOrDefaultAsync(ps => ps.PlaylistId == id && ps.SongId == songId);

            if (item != null)
            {
                _context.PlaylistSongs.Remove(item);
                await _context.SaveChangesAsync();
            }

            return Ok();
        }
    }

    public class PlaylistSongsRequest
    {
        public List<int> SongIds { get; set; } = new List<int>();
    }
}
