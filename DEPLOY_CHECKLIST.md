# VaraNama v11 deploy and smoke-test checklist

## Before upload
- [ ] Back up the current GitHub repository files.
- [ ] Confirm `config.js` points to the correct Supabase project and contains only the browser-safe publishable/anon key.
- [ ] Do not rerun `supabase/schema.sql` for this UI-only update.

## After upload
- [ ] Home opens with a welcome panel and clear shortcuts.
- [ ] Navigation displays one workspace at a time.
- [ ] Browser back/forward changes pages correctly.
- [ ] Find Fares route selection and fare results work.
- [ ] Create Account and Log In email-link flows work.
- [ ] Place and fare submissions still require a verified account.
- [ ] Leaderboard displays public usernames and XP only.
- [ ] Profile, rewards, and moderator queue behave as expected for the signed-in account.
- [ ] Test on a phone-sized screen and desktop.

Do not announce the site as fully launched until account, contribution, and moderator flows have been tested against the live Supabase project.

- [ ] Type a place name and press Enter; OpenStreetMap name results should appear in the dropdown without opening a map.
- [ ] Check the browser tab for the VaraNama ৳ icon.
