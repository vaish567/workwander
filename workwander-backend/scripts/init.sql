-- Users table
CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Meeting suggestions table
CREATE TABLE meeting_suggestions (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    attendees JSONB NOT NULL,
    time_slot TIMESTAMP NOT NULL,
    venue TEXT NOT NULL,
    purpose TEXT NOT NULL,
    confidence FLOAT CHECK (confidence >= 0 AND confidence <= 1),
    accepted BOOLEAN DEFAULT FALSE,
    feedback TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'completed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_meeting_suggestions_location ON meeting_suggestions USING GIST (ll_to_earth(venue_lat, venue_lng));

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_meeting_suggestions_timestamp
    BEFORE UPDATE ON meeting_suggestions
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();