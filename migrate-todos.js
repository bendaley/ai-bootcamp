/**
 * Migration script to import todos from todos.json to Supabase
 *
 * Usage:
 *   1. Make sure you have a todos.json file with your existing todos
 *   2. Set up your .env file with Supabase credentials
 *   3. Run: node migrate-todos.js
 *
 * WARNING: This will insert all todos from todos.json into Supabase.
 * It will not delete existing todos in the database.
 */

require('dotenv').config();
const fs = require('fs').promises;
const path = require('path');
const { createClient } = require('@supabase/supabase-js');

const TODOS_FILE = path.join(__dirname, 'todos.json');

// Initialize Supabase client
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ ERROR: Missing Supabase credentials in .env file');
  console.error('   Please set SUPABASE_URL and SUPABASE_SERVICE_KEY');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function migrate() {
  console.log('🔄 Starting migration from todos.json to Supabase...\n');

  // Step 1: Read todos.json
  let todos = [];
  try {
    const data = await fs.readFile(TODOS_FILE, 'utf8');
    todos = JSON.parse(data);
    console.log(`✓ Found ${todos.length} todos in todos.json`);
  } catch (error) {
    if (error.code === 'ENOENT') {
      console.log('ℹ No todos.json file found. Nothing to migrate.');
      return;
    }
    console.error('❌ Error reading todos.json:', error.message);
    process.exit(1);
  }

  if (todos.length === 0) {
    console.log('ℹ todos.json is empty. Nothing to migrate.');
    return;
  }

  // Step 2: Transform todos for Supabase
  // Remove the old timestamp-based IDs (database will generate new ones)
  const todosToInsert = todos.map(todo => ({
    text: todo.text,
    completed: todo.completed
  }));

  // Step 3: Insert into Supabase
  console.log('🔄 Inserting todos into Supabase...');

  try {
    const { data, error } = await supabase
      .from('todos')
      .insert(todosToInsert)
      .select();

    if (error) {
      console.error('❌ Error inserting todos:', error.message);
      process.exit(1);
    }

    console.log(`✓ Successfully migrated ${data.length} todos to Supabase!\n`);

    // Step 4: Show summary
    const completed = data.filter(t => t.completed).length;
    const active = data.length - completed;

    console.log('📊 Migration Summary:');
    console.log(`   Total todos: ${data.length}`);
    console.log(`   Active: ${active}`);
    console.log(`   Completed: ${completed}\n`);

    // Step 5: Suggest backup
    console.log('💡 Tip: You may want to back up or rename your todos.json file:');
    console.log('   mv todos.json todos.json.backup');
    console.log('\n✅ Migration complete!');

  } catch (error) {
    console.error('❌ Unexpected error during migration:', error.message);
    process.exit(1);
  }
}

// Run migration
migrate();
