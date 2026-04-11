// =============================================
// Cadentra — Supabase Configuration
// =============================================
// Setup steps:
// 1. Go to https://supabase.com → create a free project
// 2. Project Settings → API → copy Project URL and anon/public key
// 3. Paste them below and save this file
// 4. Run the SQL in supabase-schema.sql in the Supabase SQL editor
// =============================================

window.SUPABASE_URL     = 'YOUR_PROJECT_URL';
window.SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';

try {
  window._supabase = supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY);
} catch (e) {
  window._supabase = null;
}
