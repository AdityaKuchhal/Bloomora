-- ============================================================================
-- SUPERSEDED — not the live schema, not applied anywhere, not maintained.
--
-- This file predates FT-006 (Database Schema & Migration Baseline) and was
-- never a versioned migration. It defines table names (child_profiles,
-- assessment_sessions, assessment_results, development_domains, age_groups)
-- that DO NOT match either the actual live/dev Supabase project (which has
-- parents/children/assessments/assessment_responses/domain_results — see
-- docs/audit-findings.md Section D) or the new committed baseline (see
-- supabase/migrations/, which uses profiles/children/child_caregivers/...
-- per the TRD).
--
-- The authoritative, committed schema now lives in supabase/migrations/ —
-- see supabase/migrations/README.md. Kept here rather than deleted only as
-- a historical artifact; do not run this file against any database.
-- ============================================================================

-- Bloomora Database Schema
-- AmazingPath Kids - Child Development Platform
-- PostgreSQL + Supabase

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (handled by Supabase Auth)
-- We'll extend with additional fields

-- Child Profiles
CREATE TABLE child_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) NOT NULL,
    relationship VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Development Domains
CREATE TABLE development_domains (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7), -- Hex color code
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Age Groups
CREATE TABLE age_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    min_age_months INTEGER NOT NULL,
    max_age_months INTEGER NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Assessment Questions
CREATE TABLE assessment_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    age_group_id UUID REFERENCES age_groups(id) ON DELETE CASCADE,
    domain_id UUID REFERENCES development_domains(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(20) DEFAULT 'yes_no', -- yes_no, multiple_choice, scale
    options JSONB, -- For multiple choice questions
    weight DECIMAL(3,2) DEFAULT 1.0, -- Question importance weight
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Assessment Sessions
CREATE TABLE assessment_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID REFERENCES child_profiles(id) ON DELETE CASCADE,
    age_group_id UUID REFERENCES age_groups(id),
    status VARCHAR(20) DEFAULT 'in_progress', -- in_progress, completed, abandoned
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    total_questions INTEGER DEFAULT 0,
    answered_questions INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Assessment Responses
CREATE TABLE assessment_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES assessment_sessions(id) ON DELETE CASCADE,
    question_id UUID REFERENCES assessment_questions(id) ON DELETE CASCADE,
    answer VARCHAR(50) NOT NULL, -- yes, no, or other values
    response_time_ms INTEGER, -- Time taken to answer
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Assessment Results
CREATE TABLE assessment_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES assessment_sessions(id) ON DELETE CASCADE,
    child_id UUID REFERENCES child_profiles(id) ON DELETE CASCADE,
    domain_id UUID REFERENCES development_domains(id) ON DELETE CASCADE,
    score DECIMAL(5,2) NOT NULL, -- 0-100 score
    percentile INTEGER, -- Percentile ranking
    level VARCHAR(20), -- beginner, intermediate, advanced
    recommendations TEXT[], -- Array of recommendation texts
    ai_analysis JSONB, -- Detailed AI analysis
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activities
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    domain_id UUID REFERENCES development_domains(id),
    age_group_id UUID REFERENCES age_groups(id),
    difficulty_level VARCHAR(20) DEFAULT 'beginner', -- beginner, intermediate, advanced
    duration_minutes INTEGER,
    materials_needed TEXT[],
    instructions TEXT[],
    benefits TEXT[],
    image_url VARCHAR(500),
    video_url VARCHAR(500),
    points INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity Sessions (when child does an activity)
CREATE TABLE activity_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID REFERENCES child_profiles(id) ON DELETE CASCADE,
    activity_id UUID REFERENCES activities(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    points_earned INTEGER DEFAULT 0,
    feedback TEXT,
    parent_notes TEXT,
    status VARCHAR(20) DEFAULT 'in_progress', -- in_progress, completed, abandoned
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Progress Tracking
CREATE TABLE progress_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID REFERENCES child_profiles(id) ON DELETE CASCADE,
    domain_id UUID REFERENCES development_domains(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    activities_completed INTEGER DEFAULT 0,
    total_time_minutes INTEGER DEFAULT 0,
    points_earned INTEGER DEFAULT 0,
    skill_level VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(child_id, domain_id, date)
);

-- Parent Notifications
CREATE TABLE parent_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    child_id UUID REFERENCES child_profiles(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- assessment_complete, milestone_achieved, etc.
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    data JSONB, -- Additional data for the notification
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_child_profiles_user_id ON child_profiles(user_id);
CREATE INDEX idx_assessment_sessions_child_id ON assessment_sessions(child_id);
CREATE INDEX idx_assessment_responses_session_id ON assessment_responses(session_id);
CREATE INDEX idx_activity_sessions_child_id ON activity_sessions(child_id);
CREATE INDEX idx_progress_tracking_child_date ON progress_tracking(child_id, date);
CREATE INDEX idx_parent_notifications_user_id ON parent_notifications(user_id);

-- Insert initial data
INSERT INTO development_domains (name, description, icon, color) VALUES
('Fine Motor Skills', 'Hand-eye coordination, finger dexterity, and small muscle control', 'touch_app', '#FF6B6B'),
('Gross Motor Skills', 'Large muscle movements, balance, and coordination', 'directions_run', '#4ECDC4'),
('Cognitive Development', 'Thinking, problem-solving, and memory skills', 'psychology', '#45B7D1'),
('Language & Communication', 'Speaking, listening, and understanding language', 'record_voice_over', '#96CEB4'),
('Social & Emotional', 'Interacting with others and managing emotions', 'people', '#FFEAA7'),
('Self-Care Skills', 'Independence in daily activities', 'self_improvement', '#DDA0DD');

INSERT INTO age_groups (name, min_age_months, max_age_months, description) VALUES
('1-2 years', 12, 24, 'Early toddler development and exploration'),
('2-3 years', 24, 36, 'Rapid language and motor skill development'),
('3-4 years', 36, 48, 'Pre-school preparation and social skills'),
('4-5 years', 48, 60, 'School readiness and advanced cognitive skills');

-- Sample assessment questions for different age groups
INSERT INTO assessment_questions (age_group_id, domain_id, question_text, weight) 
SELECT 
    ag.id,
    dd.id,
    'Can your child pick up small objects with thumb and forefinger?',
    1.0
FROM age_groups ag, development_domains dd
WHERE ag.name = '1-2 years' AND dd.name = 'Fine Motor Skills';

-- ============================================================
-- AUTH TRIGGER: Auto-create parent profile on signup
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.parents (id, email, name, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Add more sample questions as needed...
