class TodoList {
    constructor() {
        this.todos = [];
        this.todoInput = document.getElementById('todoInput');
        this.addBtn = document.getElementById('addBtn');
        this.todoList = document.getElementById('todoList');
        this.init();
    }

    init() {
        // Event listeners
        this.addBtn.addEventListener('click', () => this.addTodo());
        this.todoInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.addTodo();
        });

        // Load initial data
        this.loadTodos();
    }

    /**
     * Helper function for API requests
     */
    async apiRequest(endpoint, options = {}) {
        try {
            const response = await fetch(endpoint, {
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                },
                ...options
            });

            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.error || 'Request failed');
            }

            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }

    /**
     * Load todos from API
     */
    async loadTodos() {
        try {
            const data = await this.apiRequest('/api/todos');
            this.todos = data.todos;
            this.render();
        } catch (error) {
            console.error('Failed to load todos:', error);
        }
    }

    /**
     * Add new todo
     */
    async addTodo() {
        const text = this.todoInput.value.trim();
        if (!text) return;

        try {
            await this.apiRequest('/api/todos', {
                method: 'POST',
                body: JSON.stringify({ text })
            });

            this.todoInput.value = '';
            await this.loadTodos();
        } catch (error) {
            console.error('Failed to add todo:', error);
        }
    }

    /**
     * Delete todo
     */
    async deleteTodo(id) {
        try {
            await this.apiRequest(`/api/todos/${id}`, {
                method: 'DELETE'
            });

            await this.loadTodos();
        } catch (error) {
            console.error('Failed to delete todo:', error);
        }
    }

    /**
     * Toggle todo completion
     */
    async toggleComplete(id) {
        try {
            const todo = this.todos.find(t => t.id === id);
            if (!todo) return;

            await this.apiRequest(`/api/todos/${id}`, {
                method: 'PUT',
                body: JSON.stringify({ completed: !todo.completed })
            });

            await this.loadTodos();
        } catch (error) {
            console.error('Failed to toggle todo:', error);
        }
    }

    /**
     * Edit todo text
     */
    async editTodo(id, newText) {
        const trimmedText = newText.trim();
        if (!trimmedText) return;

        try {
            await this.apiRequest(`/api/todos/${id}`, {
                method: 'PUT',
                body: JSON.stringify({ text: trimmedText })
            });

            await this.loadTodos();
        } catch (error) {
            console.error('Failed to edit todo:', error);
        }
    }

    /**
     * Render all todos
     */
    render() {
        this.todoList.innerHTML = '';

        if (this.todos.length === 0) {
            this.todoList.innerHTML = '<div class="empty-state">No todos yet. Add one above!</div>';
        } else {
            this.todos.forEach(todo => {
                const li = this.createTodoElement(todo);
                this.todoList.appendChild(li);
            });
        }

        this.updateStats();
    }

    /**
     * Create DOM element for a single todo
     */
    createTodoElement(todo) {
        const li = document.createElement('li');
        li.className = `todo-item ${todo.completed ? 'completed' : ''}`;

        li.innerHTML = `
            <input type="checkbox" class="todo-checkbox" ${todo.completed ? 'checked' : ''} />
            <span class="todo-text">${this.escapeHtml(todo.text)}</span>
            <input type="text" class="edit-input" value="${this.escapeHtml(todo.text)}" />
            <button class="btn edit-btn">Edit</button>
            <button class="btn save-btn">Save</button>
            <button class="btn delete-btn">Delete</button>
        `;

        // Get elements
        const checkbox = li.querySelector('.todo-checkbox');
        const editBtn = li.querySelector('.edit-btn');
        const saveBtn = li.querySelector('.save-btn');
        const deleteBtn = li.querySelector('.delete-btn');
        const todoText = li.querySelector('.todo-text');
        const editInput = li.querySelector('.edit-input');

        // Event listeners
        checkbox.addEventListener('change', () => this.toggleComplete(todo.id));
        deleteBtn.addEventListener('click', () => this.deleteTodo(todo.id));

        editBtn.addEventListener('click', () => {
            todoText.classList.add('editing');
            editInput.classList.add('active');
            saveBtn.classList.add('active');
            editBtn.style.display = 'none';
            editInput.focus();
        });

        saveBtn.addEventListener('click', () => {
            this.editTodo(todo.id, editInput.value);
        });

        editInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.editTodo(todo.id, editInput.value);
            }
        });

        return li;
    }

    /**
     * Escape HTML to prevent XSS
     */
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    /**
     * Update statistics
     */
    updateStats() {
        const total = this.todos.length;
        const completed = this.todos.filter(t => t.completed).length;
        const active = total - completed;

        document.getElementById('totalCount').textContent = total;
        document.getElementById('activeCount').textContent = active;
        document.getElementById('completedCount').textContent = completed;
    }
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new TodoList();
});
