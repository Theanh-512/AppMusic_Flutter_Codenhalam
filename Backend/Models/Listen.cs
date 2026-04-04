using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("song_listens")]
    public class Listen
    {
        [Key]
        [Column("id")]
        public int Id { get; set; }

        [Column("user_id")]
        public Guid UserId { get; set; }

        [Column("song_id")]
        public int? SongId { get; set; }

        [Column("source_playlist_id")]
        public int? SourcePlaylistId { get; set; }

        [Column("source_screen")]
        public string? SourceScreen { get; set; }

        [Column("listened_at")]
        public DateTime ListenedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("SongId")]
        public virtual Song? Song { get; set; }
    }
}
