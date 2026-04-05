using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("profiles")]
    public class Profile
    {
        [Key]
        [Column("id")]
        [System.Text.Json.Serialization.JsonPropertyName("id")]
        public Guid Id { get; set; }

        [Column("email")]
        [System.Text.Json.Serialization.JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;

        [Column("display_name")]
        [System.Text.Json.Serialization.JsonPropertyName("display_name")]
        public string? DisplayName { get; set; }

        [Column("avatar_url")]
        [System.Text.Json.Serialization.JsonPropertyName("avatar_url")]
        public string? AvatarUrl { get; set; }

        [Column("created_at")]
        [System.Text.Json.Serialization.JsonPropertyName("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("is_artist")]
        [System.Text.Json.Serialization.JsonPropertyName("is_artist")]
        public bool IsArtist { get; set; } = false;

        [Column("updated_at")]
        [System.Text.Json.Serialization.JsonPropertyName("updated_at")]
        public DateTime? UpdatedAt { get; set; }
    }
}
