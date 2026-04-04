using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("hashtags")]
    public class Hashtag
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Column("slug")]
        public string Slug { get; set; } = string.Empty;

        [Column("cover_url")]
        public string? CoverUrl { get; set; }

        [Column("is_active")]
        public bool IsActive { get; set; } = true;
    }
}
