using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace MusicBackend.Models
{
    [Table("albums")]
    public class Album
    {
        [Key]
        [Column("id")]
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [Column("external_id")]
        [JsonPropertyName("external_id")]
        public string? ExternalId { get; set; }

        [Column("title")]
        [JsonPropertyName("title")]
        public required string Title { get; set; }

        [Column("cover_file")]
        [JsonPropertyName("cover_file")]
        public string? CoverFile { get; set; }

        [Column("cover_url")]
        [JsonPropertyName("cover_url")]
        public string? CoverUrl { get; set; }

        [Column("description")]
        [JsonPropertyName("description")]
        public string? Description { get; set; }

        [Column("release_date")]
        [JsonPropertyName("release_date")]
        public DateTime? ReleaseDate { get; set; }

        [Column("album_type")]
        [JsonPropertyName("album_type")]
        public string AlbumType { get; set; } = "album";

        [Column("is_active")]
        [JsonPropertyName("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("total_tracks_cache")]
        [JsonPropertyName("total_tracks")]
        public int TotalTracks { get; set; } = 0;

        [Column("total_duration_seconds_cache")]
        [JsonPropertyName("total_duration_seconds")]
        public int TotalDurationSeconds { get; set; } = 0;

        [Column("created_at")]
        [JsonPropertyName("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
