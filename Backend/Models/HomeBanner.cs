using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace MusicBackend.Models
{
    [Table("home_banners")]
    public class HomeBanner
    {
        [Key]
        [Column("id")]
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [Column("title")]
        [JsonPropertyName("title")]
        public string Title { get; set; } = string.Empty;

        [Column("subtitle")]
        [JsonPropertyName("subtitle")]
        public string? Subtitle { get; set; }

        [Column("image_url")]
        [JsonPropertyName("image_url")]
        public string? ImageUrl { get; set; }

        [Column("action_type")]
        [JsonPropertyName("action_type")]
        public string ActionType { get; set; } = string.Empty;

        [Column("action_value")]
        [JsonPropertyName("action_value")]
        public string ActionValue { get; set; } = string.Empty;

        [Column("display_order")]
        [JsonPropertyName("display_order")]
        public int DisplayOrder { get; set; }

        [Column("is_active")]
        [JsonPropertyName("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("starts_at")]
        [JsonPropertyName("starts_at")]
        public DateTime? StartsAt { get; set; }

        [Column("ends_at")]
        [JsonPropertyName("ends_at")]
        public DateTime? EndsAt { get; set; }

        [Column("created_at")]
        [JsonPropertyName("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
