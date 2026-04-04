using Microsoft.AspNetCore.Mvc;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PlayerController : ControllerBase
    {
        [HttpGet("state/{userId}")]
        public IActionResult GetState(string userId)
        {
            return Ok(new { });
        }

        [HttpPost("state")]
        public IActionResult UpdateState([FromBody] object request)
        {
            return Ok();
        }

        [HttpPost("listen")]
        public IActionResult LogListen([FromBody] object request)
        {
            return Ok();
        }

        [HttpGet("recent/{userId}")]
        public IActionResult GetRecentPlays(string userId)
        {
            return Ok(new List<object>());
        }
    }
}
