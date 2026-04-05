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
        public DbSet<Follow> Follows { get; set; }
        public DbSet<PlaylistSong> PlaylistSongs { get; set; }
        public DbSet<UserPlayerState> UserPlayerStates { get; set; }
        public DbSet<Listen> Listens { get; set; }
        public DbSet<SavedPlaylist> SavedPlaylists { get; set; }
        public DbSet<SongArtist> SongArtists { get; set; }
        public DbSet<TrendingKeyword> TrendingKeywords { get; set; }
        public DbSet<Genre> Genres { get; set; }
        public DbSet<Mood> Moods { get; set; }
        public DbSet<Hashtag> Hashtags { get; set; }
        public DbSet<HomeSection> HomeSections { get; set; }
        public DbSet<HomeSectionItem> HomeSectionItems { get; set; }
        public DbSet<HomeSectionItemView> HomeSectionItemViews { get; set; }
        public DbSet<HomeBanner> HomeBanners { get; set; }
        public DbSet<ChannelSubscription> ChannelSubscriptions { get; set; }

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
            modelBuilder.Entity<Follow>().ToTable("user_followed_artists");
            modelBuilder.Entity<PlaylistSong>().ToTable("playlist_songs");
            modelBuilder.Entity<UserPlayerState>().ToTable("user_player_state");
            modelBuilder.Entity<Listen>().ToTable("song_listens");
            modelBuilder.Entity<SavedPlaylist>().ToTable("user_saved_playlists");
            modelBuilder.Entity<SongArtist>().ToTable("song_artists").HasKey(sa => new { sa.SongId, sa.ArtistId });
            modelBuilder.Entity<TrendingKeyword>().ToTable("trending_search_keywords");
            modelBuilder.Entity<Genre>().ToTable("genres");
            modelBuilder.Entity<Mood>().ToTable("moods");
            modelBuilder.Entity<Hashtag>().ToTable("hashtags");
            modelBuilder.Entity<HomeSection>().ToTable("home_sections");
            modelBuilder.Entity<HomeSectionItem>().ToTable("home_section_items");
            modelBuilder.Entity<HomeSectionItemView>().ToView("v_home_section_items_for_app").HasNoKey();
            modelBuilder.Entity<HomeBanner>().ToTable("home_banners");
            modelBuilder.Entity<ChannelSubscription>().ToTable("channel_subscriptions");
        }
    }
}
