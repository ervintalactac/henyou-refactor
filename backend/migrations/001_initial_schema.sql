-- Migration: Initial Schema
-- Created at: 2024-01-01

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE game_mode AS ENUM ('classic', 'gimme5', 'party', 'multiplayer');
CREATE TYPE game_status AS ENUM ('waiting', 'in_progress', 'completed', 'abandoned');
CREATE TYPE player_role AS ENUM ('guesser', 'clue_giver', 'spectator');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    display_name VARCHAR(100),
    avatar_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create indexes for users
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- User statistics table
CREATE TABLE user_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_games INTEGER DEFAULT 0,
    games_won INTEGER DEFAULT 0,
    games_lost INTEGER DEFAULT 0,
    total_score BIGINT DEFAULT 0,
    highest_score INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    average_guess_time DECIMAL(10,2),
    total_play_time INTEGER DEFAULT 0, -- in seconds
    favorite_category VARCHAR(50),
    achievements JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_stats_user_id UNIQUE (user_id)
);

-- Create index for user stats
CREATE INDEX idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX idx_user_stats_total_score ON user_stats(total_score DESC);

-- Words table
CREATE TABLE words (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    word VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    difficulty INTEGER DEFAULT 1 CHECK (difficulty >= 1 AND difficulty <= 5),
    language VARCHAR(10) DEFAULT 'fil',
    hints TEXT[],
    tags TEXT[],
    usage_count INTEGER DEFAULT 0,
    success_rate DECIMAL(5,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create indexes for words
CREATE INDEX idx_words_category ON words(category);
CREATE INDEX idx_words_difficulty ON words(difficulty);
CREATE INDEX idx_words_language ON words(language);
CREATE INDEX idx_words_word_lower ON words(LOWER(word));

-- Game sessions table
CREATE TABLE game_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_code VARCHAR(10) UNIQUE,
    host_id UUID NOT NULL REFERENCES users(id),
    game_mode game_mode NOT NULL,
    status game_status DEFAULT 'waiting',
    max_players INTEGER DEFAULT 2,
    current_round INTEGER DEFAULT 1,
    total_rounds INTEGER DEFAULT 5,
    time_limit INTEGER DEFAULT 120, -- in seconds
    settings JSONB DEFAULT '{}'::jsonb,
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for game sessions
CREATE INDEX idx_game_sessions_room_code ON game_sessions(room_code);
CREATE INDEX idx_game_sessions_status ON game_sessions(status);
CREATE INDEX idx_game_sessions_host_id ON game_sessions(host_id);
CREATE INDEX idx_game_sessions_created_at ON game_sessions(created_at DESC);

-- Game participants table
CREATE TABLE game_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    game_session_id UUID NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    role player_role DEFAULT 'guesser',
    score INTEGER DEFAULT 0,
    rounds_won INTEGER DEFAULT 0,
    average_time DECIMAL(10,2),
    is_ready BOOLEAN DEFAULT false,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uk_game_participant UNIQUE (game_session_id, user_id)
);

-- Create indexes for game participants
CREATE INDEX idx_game_participants_game_session_id ON game_participants(game_session_id);
CREATE INDEX idx_game_participants_user_id ON game_participants(user_id);

-- Game rounds table
CREATE TABLE game_rounds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    game_session_id UUID NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
    round_number INTEGER NOT NULL,
    word_id UUID NOT NULL REFERENCES words(id),
    guesser_id UUID NOT NULL REFERENCES users(id),
    clue_giver_id UUID REFERENCES users(id),
    status game_status DEFAULT 'waiting',
    time_taken INTEGER, -- in seconds
    guesses JSONB DEFAULT '[]'::jsonb, -- array of {guess, timestamp, correct}
    clues JSONB DEFAULT '[]'::jsonb, -- array of {clue, timestamp}
    score_earned INTEGER DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_game_round UNIQUE (game_session_id, round_number)
);

-- Create indexes for game rounds
CREATE INDEX idx_game_rounds_game_session_id ON game_rounds(game_session_id);
CREATE INDEX idx_game_rounds_word_id ON game_rounds(word_id);

-- Weekly competitions table
CREATE TABLE weekly_competitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    week_number INTEGER NOT NULL,
    year INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    prize_pool JSONB DEFAULT '{}'::jsonb,
    rules JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_weekly_competition UNIQUE (year, week_number)
);

-- Create indexes for weekly competitions
CREATE INDEX idx_weekly_competitions_dates ON weekly_competitions(start_date, end_date);
CREATE INDEX idx_weekly_competitions_active ON weekly_competitions(is_active);

-- Weekly competition entries table
CREATE TABLE weekly_competition_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    competition_id UUID NOT NULL REFERENCES weekly_competitions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    total_score INTEGER DEFAULT 0,
    games_played INTEGER DEFAULT 0,
    best_score INTEGER DEFAULT 0,
    rank INTEGER,
    prizes_won JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_competition_entry UNIQUE (competition_id, user_id)
);

-- Create indexes for competition entries
CREATE INDEX idx_competition_entries_competition_id ON weekly_competition_entries(competition_id);
CREATE INDEX idx_competition_entries_user_id ON weekly_competition_entries(user_id);
CREATE INDEX idx_competition_entries_total_score ON weekly_competition_entries(total_score DESC);

-- Achievements table
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url VARCHAR(500),
    points INTEGER DEFAULT 0,
    requirements JSONB NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User achievements table
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id),
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    progress JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT uk_user_achievement UNIQUE (user_id, achievement_id)
);

-- Create indexes for user achievements
CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_achievement_id ON user_achievements(achievement_id);

-- Audit log table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for audit logs
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);

-- Create update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply update timestamp triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_stats_updated_at BEFORE UPDATE ON user_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_words_updated_at BEFORE UPDATE ON words
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_game_sessions_updated_at BEFORE UPDATE ON game_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_weekly_competitions_updated_at BEFORE UPDATE ON weekly_competitions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_weekly_competition_entries_updated_at BEFORE UPDATE ON weekly_competition_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to generate room codes
CREATE OR REPLACE FUNCTION generate_room_code()
RETURNS VARCHAR(10) AS $$
DECLARE
    code VARCHAR(10);
    exists_check BOOLEAN;
BEGIN
    LOOP
        -- Generate a random 6-character alphanumeric code
        code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6));
        
        -- Check if code already exists
        SELECT EXISTS(SELECT 1 FROM game_sessions WHERE room_code = code) INTO exists_check;
        
        -- Exit loop if code doesn't exist
        EXIT WHEN NOT exists_check;
    END LOOP;
    
    RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Comments for documentation
COMMENT ON TABLE users IS 'Main users table storing account information';
COMMENT ON TABLE user_stats IS 'User statistics and gameplay metrics';
COMMENT ON TABLE words IS 'Word dictionary for the game';
COMMENT ON TABLE game_sessions IS 'Active and historical game sessions';
COMMENT ON TABLE game_participants IS 'Players participating in game sessions';
COMMENT ON TABLE game_rounds IS 'Individual rounds within game sessions';
COMMENT ON TABLE weekly_competitions IS 'Weekly competition definitions';
COMMENT ON TABLE weekly_competition_entries IS 'User entries in weekly competitions';
COMMENT ON TABLE achievements IS 'Achievement definitions';
COMMENT ON TABLE user_achievements IS 'User earned achievements';
COMMENT ON TABLE audit_logs IS 'System audit trail for important actions';