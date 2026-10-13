# VaraNama (ভাড়ানামা) — community fare guide

This is the deployable V9 scaffold based on the approved Local Fare BD V8 design. It adds the VaraNama name, contributor sign-in UI, email magic-link authentication, XP/profile/leaderboard panels, place/fare submission RPC calls, and XP-to-Pro redemption.

## Important status

**This ZIP is not live yet and shared contributions will not work until Supabase is configured.** Browsing and the seeded prototype remain available before configuration. Public browsing requires no account; contributing requires a verified email and a public username. The main typeahead searches the shared registry; map/geocoder lookup is user-triggered rather than sent on every keystroke. The moderator panel appears for the profile marked as admin.

## Deploy

1. Create a Supabase project on its free tier.
2. In Supabase SQL Editor, run `supabase/schema.sql`.
3. In Authentication → URL Configuration, set your deployed site URL and add the local preview URL if needed. Enable email OTP/magic-link sign-in. Configure email delivery/rate limits according to Supabase's current plan.
4. Copy the Project URL and anon/publishable key into `config.js`. **Never use the service_role key in the browser.**
5. Deploy this folder to Cloudflare Pages (direct upload or connect a Git repository). Set the root to this folder; no build command is required.
6. Visit the public URL and test browse, sign-in, approved data loading, and contribution submission.

## Preview locally

Run `python -m http.server 8000` in this folder and visit `http://localhost:8000`. `config.js` remains unconfigured until you add your project details.

## Data and moderation

Place and fare contributions enter a pending-review queue. XP is granted only when a moderator approves a genuinely new place (5 XP) or a useful fare report (3 XP). The SQL creates a moderator helper function and uses a `profiles.is_admin` flag; the first administrator must be designated by a trusted project owner in the SQL editor. XP and Pro balances are not client-editable. Never expose service-role credentials in frontend files.

## Free-tier note

The design avoids paid API keys, but free tiers have quotas, inactivity policies, email limits, and terms that can change. A public global launch is not guaranteed to remain free at every scale. OpenStreetMap/Nominatim services also have their own usage policies; the autocomplete in the inherited prototype is best-effort and must not be treated as unlimited production geocoding.
