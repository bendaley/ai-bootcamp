# Todo List Application

A simple todo list application with local JSON file storage.

## Features

- Add new tasks
- Mark tasks as complete/incomplete
- Edit existing tasks
- Delete tasks
- Persistent storage in local JSON file
- Clean, modern UI
- Real-time statistics (total, active, completed)

## Requirements

- Node.js v14 or higher
- npm

## Installation

1. Navigate to the project directory:
```bash
cd todo-app
```

2. Install dependencies:
```bash
npm install
```

## Usage

1. Start the server:
```bash
npm start
```

2. Open your browser and navigate to:
```
http://localhost:3000
```

3. Start managing your todos!

## File Structure

```
todo-app/
├── server.js           # Express server and API routes
├── storage.js          # JSON file storage operations
├── package.json        # Node.js dependencies
├── todos.json          # Data storage (auto-generated)
└── public/             # Frontend files
    ├── index.html      # Main HTML page
    ├── styles.css      # CSS styles
    └── app.js          # Frontend JavaScript
```

## API Endpoints

- `GET /api/todos` - Get all todos
- `POST /api/todos` - Create new todo
- `PUT /api/todos/:id` - Update todo
- `DELETE /api/todos/:id` - Delete todo

## Data Storage

All todos are stored in `todos.json` in the project root directory. The file is created automatically when you add your first todo.
