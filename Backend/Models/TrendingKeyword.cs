using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("trending_search_keywords")]
    public class TrendingKeyword
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Column("keyword")]
        public string Keyword { get; set; } = string.Empty;

        [Column("score")]
        public int Score { get; set; }

        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
