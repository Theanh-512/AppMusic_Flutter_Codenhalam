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
            Console.WriteLine($"DEBUG: Login attempt for {request.Email} with pwd {request.Password}");
            var profile = await _context.Profiles
                .FirstOrDefaultAsync(u => u.Email == request.Email);
 
            if (profile == null) 
            {
               Console.WriteLine($"DEBUG: User {request.Email} NOT FOUND in DB");
               return Unauthorized(new { message = "Email không tồn tại" });
            }

            if (profile.Password != request.Password)
            {
                Console.WriteLine($"DEBUG: Wrong password for {request.Email}. Found in DB: {profile.Password}");
                return Unauthorized(new { message = "Mật khẩu không chính xác" });
            }
 
            Console.WriteLine($"DEBUG: Login SUCCESS for {profile.Email}");
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
                Password = request.Password,
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

        [HttpPut("profile/{userId}")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UpdateProfile(Guid userId, [FromForm] UpdateProfileRequest request)
        {
            var profile = await _context.Profiles.FindAsync(userId);
            if (profile == null) return NotFound();

            if (!string.IsNullOrEmpty(request.DisplayName))
            {
                profile.DisplayName = request.DisplayName;
            }

            if (request.AvatarFile != null)
            {
                var wwwroot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                if (!Directory.Exists(wwwroot)) Directory.CreateDirectory(wwwroot);
                var uploadsPath = Path.Combine(wwwroot, "uploads", "avatars");
                if (!Directory.Exists(uploadsPath)) Directory.CreateDirectory(uploadsPath);

                var fileName = $"avatar_{userId}_{DateTime.Now.Ticks}{Path.GetExtension(request.AvatarFile.FileName)}";
                var filePath = Path.Combine(uploadsPath, fileName);
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await request.AvatarFile.CopyToAsync(stream);
                }
                profile.AvatarUrl = $"/uploads/avatars/{fileName}";
            }

            profile.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return Ok(profile);
        }

        [HttpPut("change-password/{userId}")]
        public async Task<IActionResult> ChangePassword(Guid userId, [FromBody] ChangePasswordRequest request)
        {
            var profile = await _context.Profiles.FindAsync(userId);
            if (profile == null) return NotFound();

            if (profile.Password != request.OldPassword)
            {
                return BadRequest(new { message = "Mật khẩu cũ không chính xác" });
            }

            profile.Password = request.NewPassword;
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đổi mật khẩu thành công" });
        }
    }

    public class UpdateProfileRequest
    {
        public string? DisplayName { get; set; }
        public IFormFile? AvatarFile { get; set; }
    }

    public class ChangePasswordRequest
    {
        public string OldPassword { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
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
