using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("artists")]
    public class Artist
    {
        [Key]
        [Column("id")]
        public Guid Id { get; set; }

        [Required]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Column("avatar_url")]
        public string? AvatarUrl { get; set; }

        [Column("bio")]
        public string? Bio { get; set; }

        [Column("verified")]
        public bool Verified { get; set; } = false;

        [Column("followers_count_cache")]
        public int? FollowersCount { get; set; }

        [Column("songs_count_cache")]
        public int? SongsCount { get; set; }

        [Column("cover_url")]
        public string? CoverUrl { get; set; }
    }
}
