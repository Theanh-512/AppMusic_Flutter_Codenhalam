using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using MusicBackend.Models;

namespace MusicBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SearchController : ControllerBase
    {
        private readonly AppDbContext _context;

        public SearchController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("songs")]
        public async Task<IActionResult> SearchSongs([FromQuery] string query)
        {
            var pattern = $"%{query}%";
            var songs = await _context.Songs
                .FromSqlInterpolated($@"
                    SELECT s.* 
                    FROM songs s
                    LEFT JOIN v_song_details v ON s.id = v.id
                    WHERE s.title ILIKE {pattern} 
                       OR s.artist ILIKE {pattern}
                       OR v.genres::text ILIKE {pattern}
                       OR v.moods::text ILIKE {pattern}
                ")
                .OrderBy(s => s.Id)
                .Take(20)
                .ToListAsync();

            return Ok(songs);
        }

        // GET: api/search/artists
        [HttpGet("artists")]
        public async Task<IActionResult> SearchArtists([FromQuery] string query)
        {
            var artists = await _context.Artists
                .Where(a => a.Name.ToLower().Contains(query.ToLower()))
                .OrderBy(a => a.Id)
                .Take(20)
                .ToListAsync();

            return Ok(artists);
        }

        // GET: api/search/playlists
        [HttpGet("playlists")]
        public async Task<IActionResult> SearchPlaylists([FromQuery] string query)
        {
            var playlists = await _context.Playlists
                .Where(p => p.Name.ToLower().Contains(query.ToLower()))
                .OrderBy(p => p.Id)
                .Take(20)
                .ToListAsync();

            return Ok(playlists);
        }

        // GET: api/search/albums
        [HttpGet("albums")]
        public async Task<IActionResult> SearchAlbums([FromQuery] string query)
        {
            var albums = await _context.Albums
                .Where(a => a.Title.ToLower().Contains(query.ToLower()))
                .OrderBy(a => a.Id)
                .Take(20)
                .ToListAsync();

            return Ok(albums);
        }

        // GET: api/search/podcasts
        [HttpGet("podcasts")]
        public async Task<IActionResult> SearchPodcasts([FromQuery] string query)
        {
            var podcasts = await _context.Podcasts
                .Where(p => p.Title != null && p.Title.ToLower().Contains(query.ToLower()))
                .OrderBy(p => p.Id)
                .Take(20)
                .ToListAsync();

            return Ok(podcasts);
        }

        // Discovery Endpoints (Basic implementation)

        [HttpGet("trending-keywords")]
        public IActionResult GetTrendingKeywords()
        {
            return Ok(new List<string> { "Sơn Tùng M-TP", "Chill Lofi", "Rap Việt", "Pop Ballad" });
        }

        [HttpGet("discovery/hashtags")]
        public IActionResult GetHashtags()
        {
            return Ok(new List<object> { 
                new { name = "#chill", count = 120 }, 
                new { name = "#party", count = 85 },
                new { name = "#study", count = 200 }
            });
        }

        [HttpGet("discovery/genres")]
        public IActionResult GetGenres()
        {
            return Ok(new List<object> { 
                new { title = "Pop", image_url = "" }, 
                new { title = "Rock", image_url = "" },
                new { title = "K-Pop", image_url = "" }
            });
        }

        [HttpGet("discovery/moods")]
        public IActionResult GetMoods()
        {
            return Ok(new List<object> { 
                new { title = "Vui vẻ", image_url = "" }, 
                new { title = "Buồn", image_url = "" },
                new { title = "Thư giãn", image_url = "" }
            });
        }
    }
}
