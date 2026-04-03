-- Migration for recent_searches
-- Remove the old table if it exists
DROP TABLE IF EXISTS public.user_recent_searches;

CREATE TABLE IF NOT EXISTS public.recent_searches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  keyword TEXT NULL,
  content_type TEXT NOT NULL, -- e.g., 'keyword', 'song', 'artist', 'album', 'playlist', 'podcast', 'genre'
  content_id TEXT NULL,
  title TEXT NOT NULL,
  subtitle TEXT NULL,
  image_url TEXT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- We want to avoid duplicate identical searches for the same user.
-- If keywords are used, uniqueness is on user_id and keyword.
-- If content is used, uniqueness is on user_id, content_type, and content_id.
-- Since keyword and content_id can be NULL, we can create a unique index using COALESCE.
CREATE UNIQUE INDEX idx_recent_searches_unique 
ON public.recent_searches (user_id, content_type, COALESCE(content_id, ''), COALESCE(keyword, ''));

-- Enable Row Level Security (RLS)
ALTER TABLE public.recent_searches ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can insert their own recent searches" 
ON public.recent_searches FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own recent searches" 
ON public.recent_searches FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own recent searches" 
ON public.recent_searches FOR DELETE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own recent searches" 
ON public.recent_searches FOR UPDATE 
USING (auth.uid() = user_id);
