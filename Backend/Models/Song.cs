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
    }
}
