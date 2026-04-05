using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace MusicBackend.Models
{
    [Table("home_sections")]
    public class HomeSection
    {
        [Key]
        [Column("id")]
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [Column("code")]
        [JsonPropertyName("code")]
        public string Code { get; set; } = string.Empty;

        [Column("title")]
        [JsonPropertyName("title")]
        public string Title { get; set; } = string.Empty;

        [Column("subtitle")]
        [JsonPropertyName("subtitle")]
        public string? Subtitle { get; set; }

        [Column("section_type")]
        [JsonPropertyName("section_type")]
        public string SectionType { get; set; } = "manual";

        [Column("display_order")]
        [JsonPropertyName("display_order")]
        public int DisplayOrder { get; set; }

        [Column("item_limit")]
        [JsonPropertyName("item_limit")]
        public int ItemLimit { get; set; } = 10;

        [Column("is_active")]
        [JsonPropertyName("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("created_at")]
        [JsonPropertyName("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
