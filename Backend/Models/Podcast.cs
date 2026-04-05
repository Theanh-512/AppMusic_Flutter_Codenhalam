using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("podcasts")]
    public class Podcast
    {
        [Key]
        [Column("id")]
        public Guid Id { get; set; }

        [Column("title")]
        public required string Title { get; set; }


        [Column("audio_url")]
        public required string AudioUrl { get; set; }

        [Column("cover_url")]
        public string? CoverUrl { get; set; }

        [Column("channel_id")]
        public Guid? ChannelId { get; set; }

        [Column("duration_seconds")]
        public int DurationSeconds { get; set; }

        [Column("listen_count")]
        public int ListenCount { get; set; } = 0;

        [Column("lyrics_url")]
        public string? LyricsUrl { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
