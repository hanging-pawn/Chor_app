// Supabase configuration
// Credentials: anon key is safe for client-side use (row-level security enforced server-side)
// Tables and schema are populated in later versions.

const SUPABASE_URL = 'https://guxvlbrxzmgylojbxjew.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd1eHZsYnJ4em1neWxvamJ4amV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNzQyNzYsImV4cCI6MjA5Njg1MDI3Nn0.GUxrOP9GOZz2cvDaGUiJ8aq9Dnw-L1XVO7HUL0Og-OQ';

// Lazy-initialised client — imported via CDN when needed
// Usage: import { getSupabase } from './supabase.js'
let _client = null;

export function getSupabase() {
  if (_client) return _client;
  if (typeof window.supabase === 'undefined') {
    throw new Error('Supabase CDN not loaded. Add the script tag before importing this module.');
  }
  _client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  return _client;
}

export { SUPABASE_URL, SUPABASE_ANON_KEY };
