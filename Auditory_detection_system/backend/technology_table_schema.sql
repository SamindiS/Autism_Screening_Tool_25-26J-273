-- Technology Table Schema
-- SQL schema for creating the technology table in your database

CREATE TABLE IF NOT EXISTS technologies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,  -- SQLite
    -- id SERIAL PRIMARY KEY,  -- PostgreSQL
    -- id INT AUTO_INCREMENT PRIMARY KEY,  -- MySQL
    
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    version VARCHAR(50),
    documentation_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes for better query performance
    INDEX idx_technologies_category (category),
    INDEX idx_technologies_is_active (is_active),
    INDEX idx_technologies_name (name)
);

-- Example data insertion
INSERT INTO technologies (name, description, category, version, documentation_url, is_active) VALUES
('Flutter', 'Google''s UI toolkit for building natively compiled applications', 'Framework', '3.24.0', 'https://flutter.dev/docs', TRUE),
('Dart', 'Programming language optimized for building mobile, desktop, and web applications', 'Language', '3.4.0', 'https://dart.dev', TRUE),
('Python', 'High-level programming language known for its simplicity and versatility', 'Language', '3.12.0', 'https://www.python.org/docs/', TRUE),
('Flask', 'Lightweight Python web framework', 'Framework', '3.0.0', 'https://flask.palletsprojects.com/', TRUE),
('OpenCV', 'Open Source Computer Vision Library for image and video processing', 'Library', '4.8.0', 'https://docs.opencv.org/', TRUE),
('TensorFlow', 'Open-source machine learning framework', 'ML Framework', '2.15.0', 'https://www.tensorflow.org/api_docs', TRUE);

-- Query examples:
-- SELECT * FROM technologies WHERE is_active = TRUE;
-- SELECT * FROM technologies WHERE category = 'Framework';
-- SELECT * FROM technologies ORDER BY created_at DESC;







