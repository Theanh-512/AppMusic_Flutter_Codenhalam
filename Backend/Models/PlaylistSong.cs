using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("playlist_songs")]
    public class PlaylistSong
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Column("playlist_id")]
        public int PlaylistId { get; set; }

        [Column("song_id")]
        public int SongId { get; set; }

        [Column("position")]
        public int Position { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("SongId")]
        public virtual Song? Song { get; set; }
    }
}
