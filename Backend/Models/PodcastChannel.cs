using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("podcast_channels")]
    public class PodcastChannel
    {
        [Key]
        [Column("id")]
        public Guid Id { get; set; }

        [Column("name")]
        public required string Name { get; set; }

        [Column("cover_url")]
        public string? CoverUrl { get; set; }

        [Column("owner_id")]
        public Guid? OwnerId { get; set; }
    }
}
