const fs = require('fs').promises;
const path = require('path');

const TODOS_FILE = path.join(__dirname, 'todos.json');

/**
 * Read todos from JSON file
 * Creates file with empty array if it doesn't exist
 */
async function readTodos() {
  try {
    const data = await fs.readFile(TODOS_FILE, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    if (error.code === 'ENOENT') {
      // File doesn't exist, create it with empty array
      await writeTodos([]);
      return [];
    }
    // JSON parse error or other error
    console.error('Error reading todos:', error);
    return [];
  }
}

/**
 * Write todos to JSON file
 */
async function writeTodos(todos) {
  try {
    await fs.writeFile(TODOS_FILE, JSON.stringify(todos, null, 2), 'utf8');
    return true;
  } catch (error) {
    console.error('Error writing todos:', error);
    throw error;
  }
}

module.exports = {
  readTodos,
  writeTodos
};
