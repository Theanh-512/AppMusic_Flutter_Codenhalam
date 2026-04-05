using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace MusicBackend.Models
{
    [Table("artists")]
    public class Artist
    {
        [Key]
        [Column("id")]
        [JsonPropertyName("id")]
        public Guid Id { get; set; }

        [Column("user_id")]
        [JsonPropertyName("user_id")]
        public Guid? UserId { get; set; }

        [Column("name")]
        [JsonPropertyName("name")]
        public string Name { get; set; } = string.Empty;

        [Column("avatar_file")]
        [JsonPropertyName("avatar_file")]
        public string? AvatarFile { get; set; }

        [Column("avatar_url")]
        [JsonPropertyName("avatar_url")]
        public string? AvatarUrl { get; set; }

        [Column("cover_url")]
        [JsonPropertyName("cover_url")]
        public string? CoverUrl { get; set; }

        [Column("bio")]
        [JsonPropertyName("bio")]
        public string? Bio { get; set; }

        [Column("verified")]
        [JsonPropertyName("verified")]
        public bool Verified { get; set; } = false;

        [Column("country")]
        [JsonPropertyName("country")]
        public string? Country { get; set; }

        [Column("debut_year")]
        [JsonPropertyName("debut_year")]
        public int? DebutYear { get; set; }

        [Column("followers_count_cache")]
        [JsonPropertyName("followers_count")]
        public int FollowersCount { get; set; } = 0;

        [Column("songs_count_cache")]
        [JsonPropertyName("songs_count")]
        public int SongsCount { get; set; } = 0;

        [Column("albums_count_cache")]
        [JsonPropertyName("albums_count")]
        public int AlbumsCount { get; set; } = 0;

        [Column("monthly_listeners_previous")]
        [JsonPropertyName("monthly_listeners")]
        public int MonthlyListeners { get; set; } = 0;

        [Column("monthly_listeners_current")]
        [JsonPropertyName("monthly_listeners_current")]
        public int MonthlyListenersCurrent { get; set; } = 0;

        [Column("monthly_previous_month")]
        [JsonPropertyName("monthly_listeners_month")]
        public DateTime? MonthlyPreviousMonth { get; set; }

        [Column("created_at")]
        [JsonPropertyName("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("updated_at")]
        [JsonPropertyName("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
