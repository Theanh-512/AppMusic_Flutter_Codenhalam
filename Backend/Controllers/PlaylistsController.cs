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

        [HttpPost]
        public async Task<IActionResult> CreatePlaylist([FromBody] Playlist playlist)
        {
            Console.WriteLine($"DEBUG: CreatePlaylist - UserId: {playlist.UserId}, Type: {playlist.PlaylistType}, IsSystem: {playlist.IsSystem}");
            playlist.CreatedAt = DateTime.UtcNow;
            _context.Playlists.Add(playlist);
            
            try 
            {
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"DB ERROR: {ex.Message}");
                if (ex.InnerException != null) Console.WriteLine($"INNER ERROR: {ex.InnerException.Message}");
                throw;
            }

            // Add initial songs if any
            if (playlist.SongIds != null && playlist.SongIds.Any())
            {
                var uniqueSongIds = playlist.SongIds.Distinct().ToList();
                for (int i = 0; i < uniqueSongIds.Count; i++)
                {
                    _context.PlaylistSongs.Add(new PlaylistSong
                    {
                        PlaylistId = playlist.Id,
                        SongId = uniqueSongIds[i],
                        CreatedAt = DateTime.UtcNow,
                        Position = i
                    });
                }
                await _context.SaveChangesAsync();
            }

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
            Console.WriteLine($"DEBUG: AddSongsToPlaylist - PlaylistId: {id}, Songs: {string.Join(",", request.SongIds)}");
            
            var playlist = await _context.Playlists.FindAsync(id);
            if (playlist == null) 
            {
                Console.WriteLine($"DEBUG: Playlist {id} not found");
                return NotFound(new { message = "Playlist not found" });
            }

            if (request.SongIds == null || !request.SongIds.Any())
            {
                return Ok();
            }

            try 
            {
                // De-duplicate the incoming IDs just in case
                var songIdsToAdd = request.SongIds.Distinct().ToList();

                // Find the current max position to append after it
                var maxPosition = await _context.PlaylistSongs
                    .Where(ps => ps.PlaylistId == id)
                    .Select(ps => (int?)ps.Position)
                    .MaxAsync() ?? -1;

                foreach (var songId in songIdsToAdd)
                {
                    // Check if already in DB
                    var existsInDb = await _context.PlaylistSongs
                        .AnyAsync(ps => ps.PlaylistId == id && ps.SongId == songId);
                    
                    if (!existsInDb)
                    {
                        // Also check if already added to ChangeTracker in this loop
                        var isTracked = _context.PlaylistSongs.Local
                            .Any(ps => ps.PlaylistId == id && ps.SongId == songId);

                        if (!isTracked)
                        {
                            maxPosition++;
                            _context.PlaylistSongs.Add(new PlaylistSong
                            {
                                PlaylistId = id,
                                SongId = songId,
                                CreatedAt = DateTime.UtcNow,
                                Position = maxPosition
                            });
                        }
                    }
                }

                await _context.SaveChangesAsync();
                return Ok();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR in AddSongsToPlaylist: {ex.Message}");
                if (ex.InnerException != null) Console.WriteLine($"INNER ERROR: {ex.InnerException.Message}");
                return StatusCode(500, new { message = ex.Message, inner = ex.InnerException?.Message });
            }
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
        [System.Text.Json.Serialization.JsonPropertyName("songIds")]
        public List<int> SongIds { get; set; } = new List<int>();
    }
}
