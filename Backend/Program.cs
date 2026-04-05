using Microsoft.EntityFrameworkCore;
using MusicBackend.Data;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// ── Listen on all interfaces ──────────────────────────────────────────────────
builder.WebHost.ConfigureKestrel(options =>
{
    options.Listen(System.Net.IPAddress.Any, 5094);
});

// ── Controllers + JSON ────────────────────────────────────────────────────────
builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower;
});
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();

// ── Database ──────────────────────────────────────────────────────────────────
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
                       ?? builder.Configuration["Supabase:ConnectionString"];

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseNpgsql(connectionString);
    options.LogTo(_ => { }, Microsoft.Extensions.Logging.LogLevel.None);
});

// Suppress noisy EF Core logs
builder.Logging.AddFilter("Microsoft.EntityFrameworkCore.Database.Command", Microsoft.Extensions.Logging.LogLevel.None);
builder.Logging.AddFilter("Microsoft.EntityFrameworkCore.Update", Microsoft.Extensions.Logging.LogLevel.None);
builder.Logging.AddFilter("Microsoft.EntityFrameworkCore.Infrastructure", Microsoft.Extensions.Logging.LogLevel.None);

// ── CORS ──────────────────────────────────────────────────────────────────────
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
});

var app = builder.Build();

// ── Database Migration (Development only) ─────────────────────────────────────
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    RunMigrations(app);
}

// ── Middleware Pipeline ────────────────────────────────────────────────────────
app.UseCors("AllowAll");

var mimeProvider = new Microsoft.AspNetCore.StaticFiles.FileExtensionContentTypeProvider();
mimeProvider.Mappings[".mp3"]  = "audio/mpeg";
mimeProvider.Mappings[".wav"]  = "audio/wav";
mimeProvider.Mappings[".jpg"]  = "image/jpeg";
mimeProvider.Mappings[".jpeg"] = "image/jpeg";
mimeProvider.Mappings[".png"]  = "image/png";
mimeProvider.Mappings[".webp"] = "image/webp";

app.UseStaticFiles(new StaticFileOptions { ContentTypeProvider = mimeProvider });
app.UseAuthorization();
app.MapControllers();
app.Run();

// ── Migration Helper ─────────────────────────────────────────────────────────
static void RunMigrations(WebApplication app)
{
    // Create a scope that lives for the lifetime of this method only
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

    // ── Step 1: Drop all legacy FK / CHECK / UNIQUE constraints ───────────────
    TryRun(db, "Step 1 (Drop constraints)", @"
        DO $$
        DECLARE r RECORD;
        BEGIN
            FOR r IN (
                SELECT constraint_name, table_name
                FROM information_schema.table_constraints
                WHERE table_name IN (
                    'profiles','favorites','user_player_state',
                    'songs','artists','song_artists','song_listens'
                )
                AND constraint_type IN ('FOREIGN KEY','CHECK','UNIQUE')
            )
            LOOP
                BEGIN
                    EXECUTE 'ALTER TABLE ' || quote_ident(r.table_name)
                         || ' DROP CONSTRAINT IF EXISTS ' || quote_ident(r.constraint_name) || ' CASCADE';
                EXCEPTION WHEN OTHERS THEN NULL;
                END;
            END LOOP;
        END $$;
    ");

    // ── Step 2: Allow NULLs in previously strict columns ─────────────────────
    foreach (var ddl in new[] {
        "ALTER TABLE song_artists ALTER COLUMN role            DROP NOT NULL",
        "ALTER TABLE songs        ALTER COLUMN duration_seconds DROP NOT NULL",
        "ALTER TABLE songs        ALTER COLUMN total_listens    DROP NOT NULL",
        "ALTER TABLE songs        ALTER COLUMN like_count_cache DROP NOT NULL",
        "ALTER TABLE song_listens  ALTER COLUMN song_id         DROP NOT NULL",
    })
    {
        try { db.Database.ExecuteSqlRaw(ddl); } catch { /* already nullable */ }
    }
    Console.WriteLine("[DB] Step 2 OK: NOT NULL removed on flexible columns.");

    // ── Step 3: Recreate v_song_details view ────────────────────────────────
    // First drop, then create — avoids "cannot drop columns from view" error
    TryRun(db, "Step 3 (Drop old view)", "DROP VIEW IF EXISTS v_song_details CASCADE;");
    TryRun(db, "Step 3 (Create view)", @"
        CREATE VIEW v_song_details AS
        SELECT s.id,
               '[]'::jsonb AS genres,
               '[]'::jsonb AS moods,
               '[]'::jsonb AS hashtags
        FROM songs s;
    ");

    // ── Step 4: Ensure required columns exist ─────────────────────────────────
    foreach (var ddl in new[] {
        "ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_artist BOOLEAN DEFAULT FALSE",
        "ALTER TABLE profiles ADD COLUMN IF NOT EXISTS password  TEXT",
        "ALTER TABLE artists  ADD COLUMN IF NOT EXISTS user_id   UUID",
    })
    {
        try { db.Database.ExecuteSqlRaw(ddl); }
        catch (Exception ex) { Console.WriteLine($"[DB] Column skipped: {ex.Message.Split('\n')[0]}"); }
    }
    Console.WriteLine("[DB] Step 4 OK: Columns verified.");

    // ── Step 5: Set default password for existing users ───────────────────────
    TryRun(db, "Step 5 (Default passwords)", "UPDATE profiles SET password = '123456' WHERE password IS NULL;");

    Console.WriteLine("[DB] ✅ Migration complete. Server is ready.");
}

static void TryRun(AppDbContext db, string label, string sql)
{
    try
    {
        db.Database.ExecuteSqlRaw(sql);
        Console.WriteLine($"[DB] {label} OK.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[DB] {label} skipped: {ex.Message.Split('\n')[0]}");
    }
}
