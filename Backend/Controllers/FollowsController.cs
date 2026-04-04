using Microsoft.AspNetCore.Mvc;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FollowsController : ControllerBase
    {
        [HttpGet("check")]
        public IActionResult CheckFollow([FromQuery] string userId, [FromQuery] string artistId)
        {
            return Ok(new { isFollowed = false });
        }

        [HttpPost("toggle")]
        public IActionResult ToggleFollow([FromBody] object request)
        {
            return Ok(new { success = true });
        }

        [HttpGet("user/{userId}/artists")]
        public IActionResult GetFollowedArtists(string userId)
        {
            return Ok(new List<Artist>());
        }
    }
}
