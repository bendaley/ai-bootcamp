-- ============================================================================
-- SEED DATA for Todo App
-- ============================================================================
-- Run this file to populate your todos table with sample data for testing
--
-- USAGE:
--   - If you want to add sample data to an existing database, run this
--   - If you used all-in-one.sql, seed data is already included
--   - To reset data: DELETE FROM todos; then run this file
-- ============================================================================

-- Option 1: Insert sample todos (will fail if duplicates exist)
-- ============================================================================
INSERT INTO todos (text, completed) VALUES
  ('Welcome to your Supabase-powered todo app!', false),
  ('Try adding a new todo above', false),
  ('Click the checkbox to mark this as complete', false),
  ('Click Edit to change the text', false),
  ('This is a completed todo', true),
  ('You can delete todos you no longer need', false),
  ('All your data is safely stored in PostgreSQL', false),
  ('Check out the stats at the bottom', false);

-- ============================================================================
-- Alternative: Clear existing data and insert fresh seed data
-- ============================================================================
-- Uncomment these lines if you want to REPLACE all existing todos:
--
-- TRUNCATE todos RESTART IDENTITY CASCADE;
--
-- INSERT INTO todos (text, completed) VALUES
--   ('Welcome to your Supabase-powered todo app!', false),
--   ('Try adding a new todo above', false),
--   ('Click the checkbox to mark this as complete', false),
--   ('Click Edit to change the text', false),
--   ('This is a completed todo', true),
--   ('You can delete todos you no longer need', false),
--   ('All your data is safely stored in PostgreSQL', false),
--   ('Check out the stats at the bottom', false);

-- ============================================================================
-- More sample data options
-- ============================================================================

-- Option 2: Larger dataset for testing performance
-- Uncomment to add 100 random todos:
--
-- INSERT INTO todos (text, completed)
-- SELECT
--   'Sample todo #' || generate_series || ' - ' ||
--   CASE (random() * 5)::int
--     WHEN 0 THEN 'Review code changes'
--     WHEN 1 THEN 'Update documentation'
--     WHEN 2 THEN 'Fix bug in production'
--     WHEN 3 THEN 'Meeting with team'
--     WHEN 4 THEN 'Deploy to staging'
--     ELSE 'General task'
--   END,
--   (random() > 0.7)::boolean as completed
-- FROM generate_series(1, 100);

-- Option 3: Categorized sample todos
-- Uncomment to add organized sample todos:
--
-- INSERT INTO todos (text, completed) VALUES
--   -- Work todos
--   ('🏢 Finish quarterly report', false),
--   ('🏢 Schedule team meeting', false),
--   ('🏢 Review pull requests', true),
--   ('🏢 Update project documentation', false),
--
--   -- Personal todos
--   ('🏠 Buy groceries', false),
--   ('🏠 Call dentist for appointment', false),
--   ('🏠 Pay utility bills', true),
--   ('🏠 Clean garage', false),
--
--   -- Learning todos
--   ('📚 Complete React tutorial', false),
--   ('📚 Read TypeScript documentation', true),
--   ('📚 Practice SQL queries', false),
--   ('📚 Watch conference talks', false),
--
--   -- Health todos
--   ('💪 Go for a run', true),
--   ('💪 Meal prep for the week', false),
--   ('💪 Book gym session', false);

-- ============================================================================
-- Verification
-- ============================================================================

-- Check how many todos were inserted
SELECT COUNT(*) as total_todos FROM todos;

-- View the todos you just inserted
SELECT id, text, completed, created_at FROM todos ORDER BY created_at DESC LIMIT 10;

-- View statistics
SELECT
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE completed = true) as completed,
  COUNT(*) FILTER (WHERE completed = false) as active
FROM todos;

-- ============================================================================
-- SUCCESS!
-- ============================================================================
-- Your sample data has been inserted!
-- Visit your app at http://localhost:3000 to see it in action.
-- ============================================================================
