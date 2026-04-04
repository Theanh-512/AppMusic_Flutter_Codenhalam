using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PodcastsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PodcastsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllPodcasts()
        {
            var podcasts = await _context.Podcasts.ToListAsync();
            return Ok(podcasts);
        }

        [HttpGet("user/{userId}/subscriptions")]
        public IActionResult GetSubscriptions(string userId)
        {
            // Simple stub for now
            return Ok(new List<PodcastChannel>());
        }

        [HttpGet("channel/{channelId}")]
        public async Task<IActionResult> GetPodcastsByChannel(string channelId)
        {
            if (!Guid.TryParse(channelId, out var guid)) return Ok(new List<Podcast>());
            var podcasts = await _context.Podcasts
                .Where(p => p.ChannelId == guid)
                .ToListAsync();
            return Ok(podcasts);
        }

        [HttpGet("channel-detail/{channelId}")]
        public async Task<IActionResult> GetChannelDetail(string channelId)
        {
            if (!Guid.TryParse(channelId, out var guid)) return NotFound();
            var channel = await _context.PodcastChannels.FindAsync(guid);
            if (channel == null) return NotFound();
            return Ok(channel);
        }

        [HttpGet("check-subscription")]
        public IActionResult CheckSubscription([FromQuery] string userId, [FromQuery] string channelId)
        {
            return Ok(new { isSubscribed = false });
        }

        [HttpPost("toggle-subscription")]
        public IActionResult ToggleSubscription([FromBody] object request)
        {
            return Ok(new { success = true });
        }
    }
}
