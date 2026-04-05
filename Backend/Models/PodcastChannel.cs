using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace MusicBackend.Models
{
    [Table("podcast_channels")]
    public class PodcastChannel
    {
        [Key]
        [Column("id")]
        [JsonPropertyName("id")]
        public Guid Id { get; set; }

        [Column("name")]
        [JsonPropertyName("name")]
        public required string Name { get; set; }

        [Column("avatar_url")]
        [JsonPropertyName("avatar_url")]
        public string? AvatarUrl { get; set; }

        [Column("subscriber_count")]
        [JsonPropertyName("subscriber_count")]
        public int SubscriberCount { get; set; } = 0;

        [Column("created_at")]
        [JsonPropertyName("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
