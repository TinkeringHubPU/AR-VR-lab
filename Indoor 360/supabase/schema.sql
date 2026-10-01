-- ============================================================
--  Indoor Campus Navigation – Flat Supabase Schema
--  Matches config.json & scenes.json 1:1
-- ============================================================

DROP TABLE IF EXISTS destinations CASCADE;
DROP TABLE IF EXISTS nav_edges CASCADE;
DROP TABLE IF EXISTS hotspots CASCADE;
DROP TABLE IF EXISTS scenes CASCADE;
DROP TABLE IF EXISTS floors CASCADE;
DROP TABLE IF EXISTS buildings CASCADE;
DROP TABLE IF EXISTS config_globals CASCADE;
DROP TABLE IF EXISTS map_labels CASCADE;

-- 1. Globals (from config.json -> default)
CREATE TABLE config_globals (
  id TEXT PRIMARY KEY DEFAULT 'default',
  first_scene TEXT,
  scene_fade_duration INT DEFAULT 1200,
  auto_load BOOLEAN DEFAULT TRUE,
  compass BOOLEAN DEFAULT FALSE
);

-- 2. Scenes (from config.json -> scenes & scenes.json)
CREATE TABLE scenes (
  id TEXT PRIMARY KEY,                 -- e.g. "scene1"
  title TEXT NOT NULL,                 -- e.g. "CV RAMAN CENTER"
  description TEXT,                    -- Scene description
  panorama TEXT NOT NULL,              -- Cloudinary URL or local path
  audio_file TEXT,                     -- e.g. "audio/cv_raman.mp3"
  hfov INT DEFAULT 110,
  north_offset INT DEFAULT 0,
  map_x FLOAT,                         -- from scenes.json (x)
  map_y FLOAT,                         -- from scenes.json (y)
  hotspots JSONB DEFAULT '[]'::jsonb,  -- raw hotspots array from config.json
  is_published BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Map Labels (from scenes.json -> _labels)
CREATE TABLE map_labels (
  id TEXT PRIMARY KEY,                 -- e.g. "label_1783575710106"
  text TEXT NOT NULL,
  x FLOAT NOT NULL,
  y FLOAT NOT NULL,
  size FLOAT DEFAULT 6,
  rotation FLOAT DEFAULT 0
);

-- Enable RLS
ALTER TABLE config_globals ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenes         ENABLE ROW LEVEL SECURITY;
ALTER TABLE map_labels     ENABLE ROW LEVEL SECURITY;

-- Allow public read
CREATE POLICY "Public read config" ON config_globals FOR SELECT USING (true);
CREATE POLICY "Public read scenes" ON scenes         FOR SELECT USING (is_published = true);
CREATE POLICY "Public read labels" ON map_labels     FOR SELECT USING (true);

-- Allow public write (Admin login bypassed per request)
CREATE POLICY "Admin write config" ON config_globals FOR ALL USING (true);
CREATE POLICY "Admin write scenes" ON scenes         FOR ALL USING (true);
CREATE POLICY "Admin write labels" ON map_labels     FOR ALL USING (true);

-- Seed default global config
INSERT INTO config_globals (id, first_scene) VALUES ('default', 'scene1') ON CONFLICT DO NOTHING;
