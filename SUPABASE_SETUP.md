# Supabase Setup Guide

Your todo app has been migrated to use Supabase (PostgreSQL) instead of local JSON file storage!

## What Changed

### Files Modified:
- `package.json` - Added Supabase and dotenv dependencies
- `server.js` - Updated to use new storage functions and database IDs
- `storage.js` - Completely rewritten to use Supabase client
- `CLAUDE.md` - Updated documentation to reflect Supabase setup

### Files Created:
- `schema.sql` - Database schema to run in Supabase
- `.env.example` - Template for environment variables
- `migrate-todos.js` - Script to import existing todos.json data
- `SUPABASE_SETUP.md` - This file!

### Files Unchanged:
- `public/app.js` - Frontend works as-is with database IDs
- `public/index.html` - No changes needed
- `public/styles.css` - No changes needed

## Setup Instructions

### Step 1: Install Dependencies

```bash
cd todo-app
npm install
```

This will install:
- `@supabase/supabase-js` - Supabase client library
- `dotenv` - Environment variable loader
- `express` - Web server (already had this)

### Step 2: Create Supabase Project

1. Go to https://supabase.com and sign up/log in
2. Click "New Project"
3. Fill in:
   - **Name**: Your project name (e.g., "todo-app")
   - **Database Password**: Choose a strong password (save it somewhere safe)
   - **Region**: Choose closest to you
   - **Pricing Plan**: Free tier works great
4. Click "Create new project" (takes ~2 minutes)

### Step 3: Get Your Supabase Credentials

1. Once your project is ready, go to **Settings** → **API**
2. Copy these two values:
   - **Project URL** (looks like `https://xxxxx.supabase.co`)
   - **service_role key** (under "Project API keys" - this is SECRET!)

### Step 4: Create Database Schema

1. In Supabase, go to **SQL Editor** (left sidebar)
2. Click **New Query**
3. Open the `schema.sql` file in your `todo-app` folder
4. Copy and paste the entire contents into the SQL Editor
5. Click **Run** (or press Cmd/Ctrl + Enter)
6. You should see "Success. No rows returned" - this is good!

This creates:
- `todos` table with proper columns (id, text, completed, created_at, updated_at)
- Row Level Security policies (allows all operations for single-user)
- Auto-update trigger for `updated_at` timestamp

### Step 5: Configure Environment Variables

1. In your `todo-app` folder, copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your Supabase credentials:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_SERVICE_KEY=your-service-role-key-here
   PORT=3000
   ```

   Replace:
   - `your-project-id` with your actual Supabase project URL
   - `your-service-role-key-here` with your actual service role key

3. **IMPORTANT**: Never commit the `.env` file to git! It's already in `.gitignore`.

### Step 6: Migrate Existing Data (Optional)

If you have existing todos in `todos.json` that you want to keep:

```bash
node migrate-todos.js
```

This script will:
- Read all todos from `todos.json`
- Insert them into your Supabase database
- Show a summary of what was migrated

**Note**: The old timestamp IDs will be replaced with new database-generated IDs.

### Step 7: Start Your App!

```bash
npm start
```

Visit http://localhost:3000 and your todo app should work with Supabase!

## Verification

To verify everything works:

1. Open http://localhost:3000
2. Add a new todo
3. Go to Supabase → **Table Editor** → **todos** table
4. You should see your todo in the database!

## Database Schema

Your `todos` table structure:

| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGSERIAL | Auto-increment primary key |
| `text` | TEXT | The todo text (required) |
| `completed` | BOOLEAN | Completion status (default: false) |
| `created_at` | TIMESTAMPTZ | When todo was created (auto) |
| `updated_at` | TIMESTAMPTZ | When todo was last updated (auto) |

## Troubleshooting

### Error: "Missing Supabase credentials in .env file"
- Make sure your `.env` file exists in the `todo-app` folder
- Check that `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` are set correctly
- Restart the server after changing `.env`

### Error: "relation 'todos' does not exist"
- You need to run the `schema.sql` in Supabase SQL Editor
- Make sure you ran the entire schema file, not just part of it

### Todos aren't saving
- Check the server console for errors
- Verify your Supabase service role key is correct
- Check Supabase dashboard → **Table Editor** to see if data is actually there

### Port 3000 already in use
- Change `PORT=3000` to another port in `.env` (e.g., `PORT=3001`)
- Or stop the other process using port 3000

## Benefits of Supabase

Now that you're using Supabase:

✅ **Database backups** - Automatic backups (every day on free tier)
✅ **Concurrent access** - Multiple users can use the app simultaneously
✅ **Cross-device** - Access your todos from anywhere
✅ **Scalability** - Handles thousands of todos efficiently
✅ **Real-time ready** - Can add Supabase Realtime subscriptions later
✅ **Authentication ready** - Easy to add user auth when needed
✅ **Serverless compatible** - Can deploy to Vercel with minor changes

## Next Steps (Optional)

### Add User Authentication
1. Enable Email auth in Supabase → **Authentication** → **Providers**
2. Update `schema.sql` to add `user_id` column to todos table
3. Update RLS policies to filter by `auth.uid()`
4. Add Supabase Auth to frontend

### Deploy to Vercel
1. Convert Express routes to Vercel API routes format
2. Push to GitHub
3. Deploy on Vercel
4. Add environment variables in Vercel dashboard

### Add Real-time Updates
1. Enable Realtime on `todos` table in Supabase
2. Subscribe to changes in frontend using `supabase.channel()`
3. Update UI automatically when data changes

## Questions?

Check the updated `CLAUDE.md` file for more details about the architecture and how everything works!
