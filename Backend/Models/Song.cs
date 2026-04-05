using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace MusicBackend.Models
{
    [Table("songs")]
    public class Song
    {
        [Key]
        [Column("id")]
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [Column("external_id")]
        [JsonPropertyName("external_id")]
        public string? ExternalId { get; set; }

        [Column("album_id")]
        [JsonPropertyName("album_id")]
        public int? AlbumId { get; set; }

        [ForeignKey("AlbumId")]
        [JsonIgnore]
        public virtual Album? Album { get; set; }

        [Column("title")]
        [JsonPropertyName("title")]
        public required string Title { get; set; }

        [Column("artist")]
        [JsonPropertyName("artist")]
        public string? ArtistName { get; set; }

        [Column("cover_url")]
        [JsonPropertyName("cover_url")]
        public string? CoverUrl { get; set; }

        [Column("cover_file")]
        [JsonPropertyName("cover_file")]
        public string? CoverFile { get; set; }

        [Column("audio_url")]
        [JsonPropertyName("audio_url")]
        public required string AudioUrl { get; set; }

        [Column("audio_file")]
        [JsonPropertyName("audio_file")]
        public string? AudioFile { get; set; }

        [Column("lyrics_url")]
        [JsonPropertyName("lyrics_url")]
        public string? LyricsUrl { get; set; }

        [Column("lyrics_file")]
        [JsonPropertyName("lyrics")]
        public string? Lyrics { get; set; }

        [Column("duration_seconds")]
        [JsonPropertyName("duration_seconds")]
        public int? DurationSeconds { get; set; }

        [Column("total_listens")]
        [JsonPropertyName("total_listens")]
        public int? TotalListens { get; set; }

        [Column("like_count_cache")]
        [JsonPropertyName("like_count")]
        public int? LikeCount { get; set; }

        [Column("release_date")]
        [JsonPropertyName("release_date")]
        public DateTime? ReleaseDate { get; set; }

        [Column("is_active")]
        [JsonPropertyName("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("created_at")]
        [JsonPropertyName("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
