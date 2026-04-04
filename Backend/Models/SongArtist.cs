using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("song_artists")]
    public class SongArtist
    {
        [Column("song_id")]
        public int SongId { get; set; }

        [Column("artist_id")]
        public Guid ArtistId { get; set; }

        [Column("role")]
        public string? Role { get; set; }

        [ForeignKey("SongId")]
        public virtual Song? Song { get; set; }

        [ForeignKey("ArtistId")]
        public virtual Artist? Artist { get; set; }
    }
}
