using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProfileController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ProfileController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetProfile(string id)
        {
            if (!Guid.TryParse(id, out var guidId)) return BadRequest();

            var profile = await _context.Profiles.FindAsync(guidId);
            if (profile == null) return NotFound();

            return Ok(profile);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateProfile(string id, [FromBody] Profile request)
        {
            if (!Guid.TryParse(id, out var guidId)) return BadRequest();
            if (guidId != request.Id) return BadRequest();

            var existing = await _context.Profiles.FindAsync(guidId);
            if (existing == null) return NotFound();

            existing.DisplayName = request.DisplayName;
            existing.AvatarUrl = request.AvatarUrl;
            existing.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(existing);
        }
    }
}
