# VaraNama public launch checklist

- [ ] Create Supabase project and run `supabase/schema.sql`.
- [ ] Set your first admin profile using the SQL comment at the end of the schema.
- [ ] Put Supabase Project URL and anon/publishable key in `config.js`.
- [ ] Configure authentication redirect URLs and email sign-in. Test email verification.
- [ ] Review and approve the initial place list. Add seed places in Supabase if desired; only approved shared rows appear to visitors.
- [ ] Deploy to Cloudflare Pages. Test from an incognito window and a second device.
- [ ] Test contributor flow, place review (+5 XP), fare review (+3 XP), leaderboard, and Pro redemption.
- [ ] Add a privacy notice and terms before inviting the public.
- [ ] Set up a process for moderation, abuse reports, backups/export, and provider-limit monitoring.

**Do not call the site fully launched until the checklist is complete.** The repository contains a frontend scaffold and schema, not a pre-created cloud project.
