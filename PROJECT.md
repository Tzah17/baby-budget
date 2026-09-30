# Baby Budget — Project Guide

## Purpose
Shared Hebrew RTL web app for a couple to plan baby / birth / postpartum purchases and budget together. Mobile-first, especially iPhone Safari.

## Repository and deployment
- Repository: `Tzah17/baby-budget`
- Main app: `index.html`
- Production deploys from `main` with GitHub Pages.
- Keep it lightweight: plain HTML/CSS/JavaScript; no framework/build system unless explicitly requested.

## Architecture
- GitHub Pages: static frontend.
- Supabase: email/password Auth, Postgres database and Realtime.
- Browser-side Supabase JS v2.
- Supabase project URL and browser publishable key are already in `index.html`. Never replace with a database password, secret key, or service-role key.
- Both partners use the same underlying data.
- Realtime listens for UPDATE events on `public.baby_budget_items`.

## Database
Main table: `public.baby_budget_items`.

Fields used:
- `id`
- `item`
- `category`
- `min_price`
- `max_price`
- `slider` — integer 0–100
- `enabled`
- `purchased`
- `gift`
- `type`
- `created_at`

Expected logical types for `enabled`, `purchased`, and `gift` are boolean.

## Budget rules
- Slider 0% means `min_price`, NOT zero.
- Slider 100% means `max_price`.
- Current price = min + (max-min) × slider/100.
- If min=max, display a fixed price.
- `enabled=false` excludes the item from planned-budget totals.
- `purchased` is independent of `enabled`.
- `gift` is independent of `purchased`.
- Gift price contribution is ₪0.
- “הוצאנו עד כה” sums current prices for purchased items; gifts contribute zero.
- Dashboard: selected budget, spent so far, minimum, maximum.

## Critical mobile/performance rule
An earlier iPhone Safari stability problem was caused by repeated full-list rendering/work while dragging sliders.

Current deliberate behavior:
- Never write to Supabase continuously during slider dragging.
- Never full-render the ~150-item list on every slider `input` event.
- Slider commits on `change` / release: one local update, one render, one Supabase UPDATE.
- Checkbox actions: one local state change and one Supabase UPDATE.
- Realtime UPDATE messages replace the corresponding in-memory row and render.

Preserve this principle. Prefer minimal network and DOM work on touch gestures.

## Realtime
Realtime is enabled for `baby_budget_items` in the Supabase `supabase_realtime` publication.

Subscription:
- schema: `public`
- table: `baby_budget_items`
- event: `UPDATE`

Do not add Firebase or a second backend unless explicitly requested.

## Security
- Row Level Security is enabled.
- Authenticated-user policies are configured.
- Never commit a database password, service-role key, or other secret.
- The browser publishable key is intentionally client-visible.
- Inspect current Supabase configuration before changing access/security.

## UX / visual direction
- Hebrew RTL.
- Mobile-first.
- Warm pastel palette: dusty pink, warm brown, sage green, cream/sand.
- Large touch targets.
- Calm/simple UI.
- Purchased items: subtle green treatment.
- Gifts: subtle pink/warm treatment.
- Search + category filter.
- Saving is automatic; no normal Save button.
- CSV export was intentionally removed.

## Collaboration rules for ChatGPT / coding agents
Before editing:
1. Read this file and current `index.html`.
2. Fetch latest `main` immediately before writing; both partners may edit from separate ChatGPT sessions.
3. Make focused changes; avoid unnecessary rewrites/dependencies.
4. Preserve Auth, Realtime, RTL and mobile-performance rules.
5. Sanity-check handlers/functions after edits and remove dead handlers.
6. Commit to `main` only when the user asks to make the change; GitHub Pages redeploys automatically.
7. If another edit landed meanwhile, re-fetch and reconcile instead of overwriting it.

## Current status — 2026-09-30
- Cloud persistence works.
- Email/password authentication works.
- GitHub Pages works.
- Mobile layout works.
- Earlier iPhone slider crashes were resolved by removing continuous render/write behavior.
- Supabase Realtime sync between two open clients has been tested by the owner and works.

Keep this file updated when architecture or important behavioral decisions change.
