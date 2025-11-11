const express = require('express');
const path = require('path');
const { readTodos, writeTodos } = require('./storage');

const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// GET /api/todos - Get all todos
app.get('/api/todos', async (req, res) => {
  try {
    const todos = await readTodos();
    res.json({ success: true, todos });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Failed to load todos' });
  }
});

// POST /api/todos - Create new todo
app.post('/api/todos', async (req, res) => {
  try {
    const { text } = req.body;

    // Validate
    if (!text || text.trim() === '') {
      return res.status(400).json({ success: false, error: 'Text is required' });
    }

    // Create new todo
    const newTodo = {
      id: Date.now(),
      text: text.trim(),
      completed: false
    };

    // Load, add, save
    const todos = await readTodos();
    todos.push(newTodo);
    await writeTodos(todos);

    res.status(201).json({ success: true, todo: newTodo });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Failed to create todo' });
  }
});

// PUT /api/todos/:id - Update todo
app.put('/api/todos/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { text, completed } = req.body;

    // Load todos
    const todos = await readTodos();
    const todoIndex = todos.findIndex(t => t.id === id);

    if (todoIndex === -1) {
      return res.status(404).json({ success: false, error: 'Todo not found' });
    }

    // Update fields
    if (text !== undefined) {
      todos[todoIndex].text = text.trim();
    }
    if (completed !== undefined) {
      todos[todoIndex].completed = completed;
    }

    // Save
    await writeTodos(todos);

    res.json({ success: true, todo: todos[todoIndex] });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Failed to update todo' });
  }
});

// DELETE /api/todos/:id - Delete todo
app.delete('/api/todos/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);

    // Load todos
    const todos = await readTodos();

    // Filter out the todo
    const filteredTodos = todos.filter(t => t.id !== id);

    // Save
    await writeTodos(filteredTodos);

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, error: 'Failed to delete todo' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Todo app running at http://localhost:${PORT}`);
  console.log('Press Ctrl+C to stop');
});
