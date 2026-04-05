using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuthController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            Console.WriteLine($"DEBUG: Login attempt for {request.Email}");
            var profile = await _context.Profiles
                .FirstOrDefaultAsync(u => u.Email == request.Email);
 
            if (profile == null)
            {
                Console.WriteLine($"DEBUG: Profile NOT FOUND for {request.Email}");
                return Unauthorized(new { message = "Email hoặc mật khẩu không đúng" });
            }
 
            Console.WriteLine($"DEBUG: Login SUCCESS for {profile.Email} (ID: {profile.Id})");
            return Ok(profile);
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            var exists = await _context.Profiles.AnyAsync(u => u.Email == request.Email);
            if (exists)
            {
                return BadRequest(new { message = "Email đã tồn tại" });
            }

            var newProfile = new Profile
            {
                Id = Guid.NewGuid(),
                Email = request.Email,
                DisplayName = request.DisplayName,
                IsArtist = request.IsArtist,
                AvatarUrl = $"https://ui-avatars.com/api/?name={request.DisplayName}&background=random"
            };

            _context.Profiles.Add(newProfile);

            if (request.IsArtist)
            {
                var newArtist = new Artist
                {
                    Id = Guid.NewGuid(),
                    UserId = newProfile.Id,
                    Name = request.DisplayName,
                    AvatarUrl = newProfile.AvatarUrl,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Artists.Add(newArtist);
            }

            await _context.SaveChangesAsync();

            return Ok(newProfile);
        }
    }

    public class LoginRequest
    {
        [System.Text.Json.Serialization.JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;

        [System.Text.Json.Serialization.JsonPropertyName("password")]
        public string Password { get; set; } = string.Empty;
    }

    public class RegisterRequest
    {
        [System.Text.Json.Serialization.JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;

        [System.Text.Json.Serialization.JsonPropertyName("password")]
        public string Password { get; set; } = string.Empty;

        [System.Text.Json.Serialization.JsonPropertyName("display_name")]
        public string DisplayName { get; set; } = string.Empty;

        [System.Text.Json.Serialization.JsonPropertyName("is_artist")]
        public bool IsArtist { get; set; } = false;
    }
}
