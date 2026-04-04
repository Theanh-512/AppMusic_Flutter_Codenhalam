using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace MusicBackend.Models
{
    [Table("songs")]
    public class Song
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Column("album_id")]
        public int? AlbumId { get; set; }

        [ForeignKey("AlbumId")]
        public virtual Album? Album { get; set; }

        [Column("title")]
        public required string Title { get; set; }

        [Column("artist")]
        [System.Text.Json.Serialization.JsonPropertyName("artist")]
        public string? ArtistName { get; set; }

        [Column("cover_url")]
        [System.Text.Json.Serialization.JsonPropertyName("cover_url")]
        public string? CoverUrl { get; set; }

        [Column("audio_url")]
        [System.Text.Json.Serialization.JsonPropertyName("audio_url")]
        public required string AudioUrl { get; set; }

        [Column("lyrics_url")]
        [System.Text.Json.Serialization.JsonPropertyName("lyrics_url")]
        public string? LyricsUrl { get; set; }

        [Column("lyrics")]
        public string? Lyrics { get; set; }

        [Column("duration_seconds")]
        [System.Text.Json.Serialization.JsonPropertyName("duration_seconds")]
        public int? DurationSeconds { get; set; }

        [Column("total_listens")]
        [System.Text.Json.Serialization.JsonPropertyName("total_listens")]
        public int? TotalListens { get; set; }

        [Column("like_count_cache")]
        [System.Text.Json.Serialization.JsonPropertyName("like_count_cache")]
        public int? LikeCountCache { get; set; }
    }
}
