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
        public string Name { get; set; } = string.Empty;

        [Column("description")]
        public string? Description { get; set; }

        [Column("cover_url")]
        public string? CoverUrl { get; set; }

        [Column("playlist_type")]
        public string PlaylistType { get; set; } = "user";

        [Column("user_id")]
        public Guid? UserId { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("is_public")]
        public bool IsPublic { get; set; } = false;
    }
}
