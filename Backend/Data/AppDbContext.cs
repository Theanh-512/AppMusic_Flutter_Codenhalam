using Microsoft.EntityFrameworkCore;
using MusicBackend.Models;

namespace MusicBackend.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Song> Songs { get; set; }
        public DbSet<Profile> Profiles { get; set; }
        public DbSet<Favorite> Favorites { get; set; }
        public DbSet<Playlist> Playlists { get; set; }
        public DbSet<Artist> Artists { get; set; }
        public DbSet<Album> Albums { get; set; }
        public DbSet<Podcast> Podcasts { get; set; }
        public DbSet<PodcastChannel> PodcastChannels { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Map to Supabase tables
            modelBuilder.Entity<Song>().ToTable("songs");
            modelBuilder.Entity<Profile>().ToTable("profiles");
            modelBuilder.Entity<Favorite>().ToTable("favorites");
            modelBuilder.Entity<Playlist>().ToTable("playlists");
            modelBuilder.Entity<Artist>().ToTable("artists");
            modelBuilder.Entity<Album>().ToTable("albums");
            modelBuilder.Entity<Podcast>().ToTable("podcasts");
            modelBuilder.Entity<PodcastChannel>().ToTable("podcast_channels");
        }
    }
}
