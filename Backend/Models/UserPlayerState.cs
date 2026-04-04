using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MusicBackend.Models
{
    [Table("user_player_state")]
    public class UserPlayerState
    {
        [Key]
        [Column("user_id")]
        public Guid UserId { get; set; }

        [Column("current_song_id")]
        public int? CurrentSongId { get; set; }

        [Column("current_playlist_id")]
        public int? CurrentPlaylistId { get; set; }

        [Column("position_seconds")]
        public int PositionSeconds { get; set; }

        [Column("is_playing")]
        public bool IsPlaying { get; set; }

        [Column("shuffle_enabled")]
        public bool ShuffleEnabled { get; set; }

        [Column("repeat_mode")]
        public string RepeatMode { get; set; } = "none";

        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
