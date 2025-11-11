-- ============================================================================
-- ALL-IN-ONE SUPABASE SETUP for Todo App
-- ============================================================================
-- Run this ENTIRE file in the Supabase SQL Editor to set up everything!
-- This includes: schema, RLS policies, triggers, seed data, and utilities
-- ============================================================================

-- Step 1: Create the todos table
-- ============================================================================
CREATE TABLE IF NOT EXISTS todos (
  id BIGSERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  completed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 2: Add indexes for better performance
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_todos_completed ON todos(completed);
CREATE INDEX IF NOT EXISTS idx_todos_created_at ON todos(created_at DESC);

-- Step 3: Enable Row Level Security (RLS)
-- ============================================================================
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- Step 4: Create RLS policy for single-user access (no auth required)
-- ============================================================================
-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Allow all operations" ON todos;

-- Create permissive policy (allows all CRUD operations for everyone)
CREATE POLICY "Allow all operations" ON todos
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Step 5: Create auto-update trigger for updated_at
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if it exists
DROP TRIGGER IF EXISTS update_todos_updated_at ON todos;

-- Create trigger
CREATE TRIGGER update_todos_updated_at
  BEFORE UPDATE ON todos
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Step 6: Insert sample/seed data for testing
-- ============================================================================
-- Only insert if table is empty
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM todos LIMIT 1) THEN
    INSERT INTO todos (text, completed) VALUES
      ('Welcome to your Supabase-powered todo app!', false),
      ('Try adding a new todo above', false),
      ('Click the checkbox to mark this as complete', false),
      ('Click Edit to change the text', false),
      ('This is a completed todo', true),
      ('You can delete todos you no longer need', false),
      ('All your data is safely stored in PostgreSQL', false),
      ('Check out the stats at the bottom', false);

    RAISE NOTICE 'Inserted % sample todos', 8;
  ELSE
    RAISE NOTICE 'Table already has data, skipping seed data';
  END IF;
END $$;

-- Step 7: Create helpful utility views (optional, for debugging)
-- ============================================================================

-- View to see todo statistics
CREATE OR REPLACE VIEW todo_stats AS
SELECT
  COUNT(*) as total_todos,
  COUNT(*) FILTER (WHERE completed = true) as completed_todos,
  COUNT(*) FILTER (WHERE completed = false) as active_todos,
  MIN(created_at) as first_todo_created,
  MAX(created_at) as last_todo_created,
  MAX(updated_at) as last_updated
FROM todos;

-- View to see recent todos
CREATE OR REPLACE VIEW recent_todos AS
SELECT
  id,
  text,
  completed,
  created_at,
  updated_at,
  AGE(NOW(), created_at) as age
FROM todos
ORDER BY created_at DESC
LIMIT 10;

-- ============================================================================
-- VERIFICATION QUERIES (run these to check everything worked)
-- ============================================================================

-- Check table structure
-- SELECT * FROM information_schema.columns WHERE table_name = 'todos';

-- Check RLS policies
-- SELECT * FROM pg_policies WHERE tablename = 'todos';

-- View your todos
-- SELECT * FROM todos ORDER BY created_at;

-- View statistics
-- SELECT * FROM todo_stats;

-- View recent todos
-- SELECT * FROM recent_todos;

-- ============================================================================
-- SUCCESS!
-- ============================================================================
-- Your database is now ready!
-- Next steps:
--   1. Go back to your terminal
--   2. Run: ./setup.sh (or bash setup.sh)
--   3. Start your app: npm start
--   4. Visit: http://localhost:3000
-- ============================================================================
