using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace MusicBackend.Models
{
    [Table("trending_search_keywords")]
    public class TrendingKeyword
    {
        [Key]
        [Column("id")]
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [Column("keyword")]
        [JsonPropertyName("keyword")]
        public string Keyword { get; set; } = string.Empty;

        [Column("score")]
        [JsonPropertyName("score")]
        public int Score { get; set; } = 0;

        [Column("updated_at")]
        [JsonPropertyName("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
