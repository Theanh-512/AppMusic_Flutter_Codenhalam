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
        public async Task<IActionResult> GetSubscriptions(string userId)
        {
            if (!Guid.TryParse(userId, out var guidUser)) return Ok(new List<PodcastChannel>());
            
            var channels = await _context.ChannelSubscriptions
                .Where(s => s.UserId == guidUser)
                .Join(_context.PodcastChannels, s => s.ChannelId, c => c.Id, (s, c) => c)
                .ToListAsync();

            return Ok(channels);
        }

        [HttpGet("channel/{channelId}")]
        public async Task<IActionResult> GetPodcastsByChannel(string channelId)
        {
            if (!Guid.TryParse(channelId, out var guid)) return Ok(new List<Podcast>());
            var podcasts = await _context.Podcasts
                .Where(p => p.ChannelId == guid && p.IsActive)
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
        public async Task<IActionResult> CheckSubscription([FromQuery] string userId, [FromQuery] string channelId)
        {
            if (!Guid.TryParse(userId, out var guidUser) || !Guid.TryParse(channelId, out var guidChannel))
                return Ok(new { isSubscribed = false });

            var exists = await _context.ChannelSubscriptions
                .AnyAsync(s => s.UserId == guidUser && s.ChannelId == guidChannel);
            
            return Ok(new { isSubscribed = exists });
        }

        [HttpPost("toggle-subscription")]
        public async Task<IActionResult> ToggleSubscription([FromBody] SubscriptionRequest request)
        {
            if (!Guid.TryParse(request.UserId, out var guidUser) || !Guid.TryParse(request.ChannelId, out var guidChannel))
                return BadRequest("Invalid ID format");

            var sub = await _context.ChannelSubscriptions
                .FirstOrDefaultAsync(s => s.UserId == guidUser && s.ChannelId == guidChannel);

            if (sub != null)
            {
                _context.ChannelSubscriptions.Remove(sub);
            }
            else
            {
                _context.ChannelSubscriptions.Add(new ChannelSubscription
                {
                    UserId = guidUser,
                    ChannelId = guidChannel
                });
            }

            await _context.SaveChangesAsync();
            return Ok(new { success = true });
        }
    }

    public class SubscriptionRequest
    {
        public string? UserId { get; set; }
        public string? ChannelId { get; set; }
    }
}
