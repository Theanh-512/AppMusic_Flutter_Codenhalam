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
            var safePat = pattern;
            var songs = await _context.Songs
                .Where(s => (s.Title != null && EF.Functions.ILike(s.Title, safePat)) ||
                            (s.ArtistName != null && EF.Functions.ILike(s.ArtistName, safePat)))
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
        public async Task<IActionResult> GetTrendingKeywords()
        {
            var keywords = await _context.TrendingKeywords
                .OrderByDescending(k => k.Score)
                .Take(10)
                .Select(k => k.Keyword)
                .ToListAsync();

            return Ok(keywords);
        }

        [HttpGet("discovery/hashtags")]
        public async Task<IActionResult> GetHashtags()
        {
            var hashtags = await _context.Hashtags
                .Where(h => h.IsActive)
                .Take(20)
                .ToListAsync();
            return Ok(hashtags);
        }

        [HttpGet("discovery/genres")]
        public async Task<IActionResult> GetGenres()
        {
            var genres = await _context.Genres
                .Where(g => g.IsActive)
                .Take(20)
                .ToListAsync();
            return Ok(genres);
        }

        [HttpGet("discovery/moods")]
        public async Task<IActionResult> GetMoods()
        {
            var moods = await _context.Moods
                .Where(m => m.IsActive)
                .Take(20)
                .ToListAsync();
            return Ok(moods);
        }

        [HttpGet("genres")]
        public async Task<IActionResult> SearchGenres([FromQuery] string query)
        {
            var genres = await _context.Genres
                .Where(g => g.Name.ToLower().Contains(query.ToLower()) && g.IsActive)
                .ToListAsync();
            return Ok(genres);
        }

        [HttpGet("moods")]
        public async Task<IActionResult> SearchMoods([FromQuery] string query)
        {
            var moods = await _context.Moods
                .Where(m => m.Name.ToLower().Contains(query.ToLower()) && m.IsActive)
                .ToListAsync();
            return Ok(moods);
        }

        [HttpGet("hashtags")]
        public async Task<IActionResult> SearchHashtags([FromQuery] string query)
        {
            var hashtags = await _context.Hashtags
                .Where(h => h.Name.ToLower().Contains(query.ToLower()) && h.IsActive)
                .ToListAsync();
            return Ok(hashtags);
        }
    }
}
