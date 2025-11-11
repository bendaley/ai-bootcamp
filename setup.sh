#!/bin/bash

# ============================================================================
# AUTOMATED SETUP SCRIPT for Todo App with Supabase
# ============================================================================
# This script automates the local setup process:
#   - Checks prerequisites (Node.js, npm)
#   - Installs npm dependencies
#   - Creates .env file with your Supabase credentials
#   - Optionally migrates existing todos.json data
# ============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# ============================================================================
# Step 1: Check Prerequisites
# ============================================================================
print_header "Step 1: Checking Prerequisites"

# Check for Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js is installed: $NODE_VERSION"
else
    print_error "Node.js is not installed!"
    print_info "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check for npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_success "npm is installed: v$NPM_VERSION"
else
    print_error "npm is not installed!"
    exit 1
fi

# ============================================================================
# Step 2: Install Dependencies
# ============================================================================
print_header "Step 2: Installing Dependencies"

if [ -f "package.json" ]; then
    print_info "Running npm install..."
    npm install
    print_success "Dependencies installed successfully!"
else
    print_error "package.json not found! Are you in the todo-app directory?"
    exit 1
fi

# ============================================================================
# Step 3: Configure Environment Variables
# ============================================================================
print_header "Step 3: Configure Supabase Credentials"

# Check if .env already exists
if [ -f ".env" ]; then
    print_warning ".env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing .env file"
        SKIP_ENV=true
    fi
fi

if [ "$SKIP_ENV" != "true" ]; then
    echo -e "\n${YELLOW}Please provide your Supabase credentials:${NC}"
    echo -e "${BLUE}Get these from: https://app.supabase.com/project/_/settings/api${NC}\n"

    # Prompt for Supabase URL
    read -p "Enter your SUPABASE_URL (e.g., https://xxxxx.supabase.co): " SUPABASE_URL

    # Prompt for Supabase Service Key
    read -p "Enter your SUPABASE_SERVICE_KEY: " SUPABASE_SERVICE_KEY

    # Prompt for port (optional)
    read -p "Enter PORT (press Enter for default 3000): " PORT
    PORT=${PORT:-3000}

    # Validate inputs
    if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_KEY" ]; then
        print_error "SUPABASE_URL and SUPABASE_SERVICE_KEY are required!"
        exit 1
    fi

    # Create .env file
    cat > .env << EOF
# Supabase Configuration
SUPABASE_URL=$SUPABASE_URL
SUPABASE_SERVICE_KEY=$SUPABASE_SERVICE_KEY

# Server Configuration
PORT=$PORT
EOF

    print_success ".env file created successfully!"
else
    # Load existing .env to get PORT
    if [ -f ".env" ]; then
        source .env
        PORT=${PORT:-3000}
    fi
fi

# ============================================================================
# Step 4: Database Setup Reminder
# ============================================================================
print_header "Step 4: Database Setup Check"

echo -e "${YELLOW}Have you run the database setup SQL in Supabase?${NC}"
echo -e "You need to run ${BLUE}all-in-one.sql${NC} in the Supabase SQL Editor"
echo -e "\nSteps:"
echo -e "  1. Go to https://app.supabase.com/project/_/sql"
echo -e "  2. Click 'New Query'"
echo -e "  3. Copy/paste contents of ${BLUE}all-in-one.sql${NC}"
echo -e "  4. Click 'Run' (or press Cmd/Ctrl + Enter)"
echo ""

read -p "Have you completed the database setup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Please complete the database setup first!"
    print_info "Run this script again after setting up the database."
    exit 0
fi

print_success "Database setup confirmed!"

# ============================================================================
# Step 5: Migrate Existing Data (Optional)
# ============================================================================
print_header "Step 5: Data Migration (Optional)"

if [ -f "todos.json" ]; then
    TODO_COUNT=$(grep -o '"id"' todos.json | wc -l | tr -d ' ')
    print_info "Found todos.json with approximately $TODO_COUNT todos"

    read -p "Do you want to migrate this data to Supabase? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Running migration script..."
        node migrate-todos.js
        print_success "Migration completed!"

        # Offer to backup the file
        read -p "Create a backup of todos.json? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp todos.json "todos.json.backup.$(date +%Y%m%d_%H%M%S)"
            print_success "Backup created: todos.json.backup.$(date +%Y%m%d_%H%M%S)"
        fi
    else
        print_info "Skipping data migration"
    fi
else
    print_info "No todos.json file found - starting with fresh database"
fi

# ============================================================================
# Setup Complete!
# ============================================================================
print_header "Setup Complete! 🎉"

echo -e "${GREEN}Your todo app is ready to run!${NC}\n"
echo -e "Next steps:"
echo -e "  1. Start the server:  ${BLUE}npm start${NC}"
echo -e "  2. Open your browser:  ${BLUE}http://localhost:$PORT${NC}"
echo -e "  3. Start managing todos!"
echo ""
echo -e "Additional commands:"
echo -e "  • View database: ${BLUE}https://app.supabase.com/project/_/editor${NC}"
echo -e "  • Check logs: ${BLUE}Check your terminal after starting the server${NC}"
echo ""
print_success "Happy todo-ing! 📝"
