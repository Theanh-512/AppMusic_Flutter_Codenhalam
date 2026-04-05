using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace MusicBackend.Models
{
    [Table("podcasts")]
    public class Podcast
    {
        [Key]
        [Column("id")]
        [JsonPropertyName("id")]
        public Guid Id { get; set; }

        [Column("external_id")]
        [JsonPropertyName("external_id")]
        public string? ExternalId { get; set; }

        [Column("title")]
        [JsonPropertyName("title")]
        public required string Title { get; set; }

        [Column("channel_id")]
        [JsonPropertyName("channel_id")]
        public Guid ChannelId { get; set; }

        [ForeignKey("ChannelId")]
        [JsonIgnore]
        public virtual PodcastChannel? Channel { get; set; }

        [Column("audio_url")]
        [JsonPropertyName("audio_url")]
        public required string AudioUrl { get; set; }

        [Column("cover_url")]
        [JsonPropertyName("cover_url")]
        public string? CoverUrl { get; set; }

        [Column("lyrics_url")]
        [JsonPropertyName("lyrics_url")]
        public string? LyricsUrl { get; set; }

        [Column("duration_seconds")]
        [JsonPropertyName("duration_seconds")]
        public int DurationSeconds { get; set; } = 0;

        [Column("listen_count")]
        [JsonPropertyName("listen_count")]
        public int ListenCount { get; set; } = 0;

        [Column("is_active")]
        [JsonPropertyName("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("created_at")]
        [JsonPropertyName("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
