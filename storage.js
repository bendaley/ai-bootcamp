require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

// Initialize Supabase client with service role key
// Service role key bypasses Row Level Security (RLS) policies
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('ERROR: Missing Supabase credentials in .env file');
  console.error('Please set SUPABASE_URL and SUPABASE_SERVICE_KEY');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

/**
 * Get all todos from the database
 * @returns {Promise<Array>} Array of todo objects
 */
async function getAllTodos() {
  try {
    const { data, error } = await supabase
      .from('todos')
      .select('*')
      .order('created_at', { ascending: true });

    if (error) {
      console.error('Error fetching todos:', error);
      throw error;
    }

    return data || [];
  } catch (error) {
    console.error('Error in getAllTodos:', error);
    return [];
  }
}

/**
 * Create a new todo
 * @param {string} text - The todo text
 * @returns {Promise<Object>} The created todo object
 */
async function createTodo(text) {
  try {
    const { data, error } = await supabase
      .from('todos')
      .insert([{ text, completed: false }])
      .select()
      .single();

    if (error) {
      console.error('Error creating todo:', error);
      throw error;
    }

    return data;
  } catch (error) {
    console.error('Error in createTodo:', error);
    throw error;
  }
}

/**
 * Update a todo by ID
 * @param {number} id - The todo ID
 * @param {Object} updates - Object with fields to update (text and/or completed)
 * @returns {Promise<Object>} The updated todo object
 */
async function updateTodo(id, updates) {
  try {
    const { data, error } = await supabase
      .from('todos')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      console.error('Error updating todo:', error);
      throw error;
    }

    return data;
  } catch (error) {
    console.error('Error in updateTodo:', error);
    throw error;
  }
}

/**
 * Delete a todo by ID
 * @param {number} id - The todo ID
 * @returns {Promise<boolean>} True if deleted successfully
 */
async function deleteTodo(id) {
  try {
    const { error } = await supabase
      .from('todos')
      .delete()
      .eq('id', id);

    if (error) {
      console.error('Error deleting todo:', error);
      throw error;
    }

    return true;
  } catch (error) {
    console.error('Error in deleteTodo:', error);
    throw error;
  }
}

/**
 * Get a single todo by ID
 * @param {number} id - The todo ID
 * @returns {Promise<Object|null>} The todo object or null if not found
 */
async function getTodoById(id) {
  try {
    const { data, error } = await supabase
      .from('todos')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        // Not found
        return null;
      }
      console.error('Error fetching todo:', error);
      throw error;
    }

    return data;
  } catch (error) {
    console.error('Error in getTodoById:', error);
    return null;
  }
}

module.exports = {
  getAllTodos,
  createTodo,
  updateTodo,
  deleteTodo,
  getTodoById
};
