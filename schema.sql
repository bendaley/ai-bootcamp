-- Supabase Schema for Todo App
-- Run this in the Supabase SQL Editor (https://app.supabase.com/project/_/sql)

-- Create todos table
CREATE TABLE IF NOT EXISTS todos (
  id BIGSERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  completed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add index for faster queries on completed status
CREATE INDEX IF NOT EXISTS idx_todos_completed ON todos(completed);

-- Enable Row Level Security
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- Create permissive policy for single-user access (no authentication)
-- This allows all operations (SELECT, INSERT, UPDATE, DELETE) for everyone
DROP POLICY IF EXISTS "Allow all operations" ON todos;
CREATE POLICY "Allow all operations" ON todos
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Optional: Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at on row updates
DROP TRIGGER IF EXISTS update_todos_updated_at ON todos;
CREATE TRIGGER update_todos_updated_at
  BEFORE UPDATE ON todos
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
