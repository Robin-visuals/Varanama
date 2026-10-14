# VaraNama v11 — Page-based layout

This version changes the interface from a long, crowded single-page layout to a page-style experience. Only one main workspace is shown at a time, with shared navigation and browser back/forward support. The existing Supabase integration and element IDs are preserved.

## Included
- `index.html` — page-based UI and existing app logic
- `config.js` — browser-safe Supabase project URL and publishable key
- `supabase/schema.sql` — schema reference (do not rerun for this UI-only update)
- `DEPLOY_CHECKLIST.md` — quick test checklist

## Publish to GitHub Pages
1. Back up your current repository files.
2. Extract this ZIP on your computer.
3. Upload/replace `index.html`, `config.js`, `_headers`, and `START_LOCAL_VARANAMA.bat` in the repository root. Keep `supabase/schema.sql` in the `supabase` folder if you already keep it in the repo.
4. Do **not** replace your existing `config.js` if it contains the correct URL and publishable key for your Supabase project; compare first.
5. Commit the changes and wait for GitHub Pages to publish.
6. Test navigation and account/contribution flows before announcing the site.

## Security and setup notes
- The publishable/anon key is intended for browser use; never add a Supabase secret/service-role key or database password to frontend files.
- No SQL migration is required just to change the page layout.
- Supabase Authentication → URL Configuration must include your exact GitHub Pages URL.
- Public fare data is community-reported guidance, not an official fare schedule. Free-tier and map-provider usage limits apply.


## v12 place-name search

Place fields show instant matches from saved places. To search OpenStreetMap after finishing typing, press Enter or click **Find place names**. This is a user-initiated search (not per-keystroke autocomplete), includes Bangladesh results, and does not display a map. The browser tab uses a small inline VaraNama favicon.
