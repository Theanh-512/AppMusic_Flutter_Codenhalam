using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace MusicBackend.Models
{
    [Table("home_section_items")]
    public class HomeSectionItem
    {
        [Key]
        [Column("id")]
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [Column("section_id")]
        [JsonPropertyName("section_id")]
        public int SectionId { get; set; }

        [Column("item_type")]
        [JsonPropertyName("item_type")]
        public string ItemType { get; set; } = string.Empty;

        [Column("item_key")]
        [JsonPropertyName("item_key")]
        public string ItemKey { get; set; } = string.Empty;

        [Column("display_order")]
        [JsonPropertyName("display_order")]
        public int DisplayOrder { get; set; }

        [Column("is_active")]
        [JsonPropertyName("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("created_at")]
        [JsonPropertyName("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    /// <summary>
    /// Model representing the v_home_section_items_for_app view.
    /// </summary>
    [Keyless]
    public class HomeSectionItemView
    {
        [Column("id")]
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [Column("section_id")]
        [JsonPropertyName("section_id")]
        public int SectionId { get; set; }

        [Column("section_code")]
        [JsonPropertyName("section_code")]
        public string SectionCode { get; set; } = string.Empty;

        [Column("section_title")]
        [JsonPropertyName("section_title")]
        public string SectionTitle { get; set; } = string.Empty;

        [Column("item_type")]
        [JsonPropertyName("item_type")]
        public string ItemType { get; set; } = string.Empty;

        [Column("item_key")]
        [JsonPropertyName("item_key")]
        public string ItemKey { get; set; } = string.Empty;

        [Column("display_order")]
        [JsonPropertyName("display_order")]
        public int DisplayOrder { get; set; }

        [Column("is_active")]
        [JsonPropertyName("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("display_title")]
        [JsonPropertyName("display_title")]
        public string? DisplayTitle { get; set; }

        [Column("display_subtitle")]
        [JsonPropertyName("display_subtitle")]
        public string? DisplaySubtitle { get; set; }

        [Column("image_url")]
        [JsonPropertyName("image_url")]
        public string? ImageUrl { get; set; }
    }
}
