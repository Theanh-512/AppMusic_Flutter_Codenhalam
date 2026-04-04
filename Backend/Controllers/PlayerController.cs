using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PlayerController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PlayerController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("state/{userId}")]
        public async Task<IActionResult> GetPlayerState(string userId)
        {
            if (!Guid.TryParse(userId, out var guidUserId)) return NotFound();

            var state = await _context.UserPlayerStates
                .FirstOrDefaultAsync(s => s.UserId == guidUserId);

            return Ok(state);
        }

        [HttpPost("state")]
        public async Task<IActionResult> UpdatePlayerState([FromBody] UserPlayerState request)
        {
            var existing = await _context.UserPlayerStates
                .FirstOrDefaultAsync(s => s.UserId == request.UserId);

            if (existing != null)
            {
                existing.CurrentSongId = request.CurrentSongId;
                existing.CurrentPlaylistId = request.CurrentPlaylistId;
                existing.PositionSeconds = request.PositionSeconds;
                existing.IsPlaying = request.IsPlaying;
                existing.ShuffleEnabled = request.ShuffleEnabled;
                existing.RepeatMode = request.RepeatMode;
                existing.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                _context.UserPlayerStates.Add(request);
            }

            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpPost("listen")]
        public async Task<IActionResult> LogListen([FromBody] Listen request)
        {
            _context.Listens.Add(request);
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpGet("recent/{userId}")]
        public async Task<IActionResult> GetRecentPlays(string userId)
        {
            if (!Guid.TryParse(userId, out var guidUserId)) return Ok(new List<object>());

            var listens = await _context.Listens
                .Where(l => l.UserId == guidUserId)
                .Include(l => l.Song)
                .OrderByDescending(l => l.ListenedAt)
                .Take(20)
                .Select(l => new { type = "song", data = l.Song })
                .ToListAsync();

            return Ok(listens);
        }
    }
}
