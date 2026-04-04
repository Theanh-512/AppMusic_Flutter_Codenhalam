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
    }
}
