-- SenseAI Database Schema
-- Compatible with Flutter app data models

-- Clinicians table
CREATE TABLE IF NOT EXISTS clinicians (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  hospital TEXT NOT NULL,
  pin_hash TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Children table (matches Flutter Child model)
CREATE TABLE IF NOT EXISTS children (
  id TEXT PRIMARY KEY,
  clinician_id INTEGER,
  name TEXT NOT NULL,
  date_of_birth INTEGER NOT NULL,
  gender TEXT NOT NULL CHECK(gender IN ('male', 'female', 'other')),
  language TEXT NOT NULL,
  age REAL NOT NULL,
  hospital_id TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (clinician_id) REFERENCES clinicians(id) ON DELETE SET NULL
);

-- Sessions table (matches Flutter AssessmentSession model)
CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  child_id TEXT NOT NULL,
  session_type TEXT NOT NULL,
  age_group TEXT,
  start_time INTEGER NOT NULL,
  end_time INTEGER,
  metrics TEXT,
  game_results TEXT,
  questionnaire_results TEXT,
  reflection_results TEXT,
  risk_score REAL,
  risk_level TEXT CHECK(risk_level IN ('low', 'moderate', 'high')),
  created_at INTEGER NOT NULL,
  FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE
);

-- Trials table (matches Flutter TrialData model)
CREATE TABLE IF NOT EXISTS trials (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  trial_number INTEGER NOT NULL,
  stimulus TEXT,
  rule TEXT,
  response TEXT,
  correct INTEGER CHECK(correct IN (0, 1)),
  reaction_time INTEGER,
  timestamp INTEGER NOT NULL,
  is_post_switch INTEGER CHECK(is_post_switch IN (0, 1)),
  is_perseverative_error INTEGER CHECK(is_perseverative_error IN (0, 1)),
  additional_data TEXT,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_children_clinician ON children(clinician_id);
CREATE INDEX IF NOT EXISTS idx_children_created ON children(created_at);
CREATE INDEX IF NOT EXISTS idx_sessions_child ON sessions(child_id);
CREATE INDEX IF NOT EXISTS idx_sessions_type ON sessions(session_type);
CREATE INDEX IF NOT EXISTS idx_sessions_created ON sessions(created_at);
CREATE INDEX IF NOT EXISTS idx_trials_session ON trials(session_id);
CREATE INDEX IF NOT EXISTS idx_trials_number ON trials(session_id, trial_number);

