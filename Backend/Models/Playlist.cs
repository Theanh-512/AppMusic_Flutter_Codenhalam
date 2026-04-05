using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("playlists")]
    public class Playlist
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Required]
        [Column("name")]
        [System.Text.Json.Serialization.JsonPropertyName("name")]
        public string Name { get; set; } = string.Empty;

        [Column("description")]
        [System.Text.Json.Serialization.JsonPropertyName("description")]
        public string? Description { get; set; }

        [Column("cover_url")]
        [System.Text.Json.Serialization.JsonPropertyName("cover_url")]
        public string? CoverUrl { get; set; }

        [Column("playlist_type")]
        [System.Text.Json.Serialization.JsonPropertyName("playlist_type")]
        public string PlaylistType { get; set; } = "user";

        [Column("is_system")]
        [System.Text.Json.Serialization.JsonPropertyName("is_system")]
        public bool IsSystem { get; set; } = false;

        [Column("user_id")]
        [System.Text.Json.Serialization.JsonPropertyName("user_id")]
        public Guid? UserId { get; set; }

        [Column("created_at")]
        [System.Text.Json.Serialization.JsonPropertyName("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("is_public")]
        [System.Text.Json.Serialization.JsonPropertyName("is_public")]
        public bool IsPublic { get; set; } = false;

        [Column("songs_count_cache")]
        [System.Text.Json.Serialization.JsonPropertyName("songs_count")]
        public int SongsCount { get; set; } = 0;

        [Column("saves_count_cache")]
        [System.Text.Json.Serialization.JsonPropertyName("saves_count")]
        public int SavesCount { get; set; } = 0;

        [Column("total_listens_cache")]
        [System.Text.Json.Serialization.JsonPropertyName("total_listens")]
        public int TotalListens { get; set; } = 0;

        [NotMapped]
        [System.Text.Json.Serialization.JsonPropertyName("song_ids")]
        public List<int> SongIds { get; set; } = new List<int>();
    }
}
