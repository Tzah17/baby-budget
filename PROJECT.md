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
- `actual_price` — nullable numeric(12,2), nonnegative exact manual price override.
- `enabled`
- `purchased`
- `gift`
- `type` — `product`, `task`, or `packing`.
- `completed` — independent preparation / packing checkbox.
- `needs_purchase` — whether the item needs buying, independent of completion.
- `archived` — hides redundant records without deleting data.
- `created_at`

Expected logical types for `enabled`, `purchased`, and `gift` are boolean.

## Budget rules
- Slider 0% means `min_price`, NOT zero.
- Slider 100% means `max_price`.
- Current price = `actual_price` when non-null, otherwise min + (max-min) × slider/100.
- Manual entry accepts zero and up to two decimal places, including outside the original range. Never overwrite `min_price` / `max_price` to store a paid price.
- Manual entry is saved on `change` (blur / Enter), never per keystroke. Emptying it restores the slider price.
- Moving the slider clears `actual_price` in the same UPDATE. Manual entry aligns the slider to the nearest in-range integer percentage, but the exact manual price remains authoritative.
- The price field is also available for fixed-range items; gifts remain zero and their field is disabled.
- Typing a price does not mark an item purchased. Existing purchased/enabled/gift rules still apply.
- If min=max, omit the slider; manual price editing is still available.
- `enabled=false` excludes the item from planned-budget totals.
- `purchased` is independent of `enabled`.
- `gift` is independent of `purchased`.
- Gift price contribution is ₪0.
- “הוצאנו עד כה” sums current prices for purchased items, independently of type, completion, inclusion or needs_purchase; gifts contribute zero. Historical purchases must not disappear when an item is reclassified.
- Planned total, minimum and maximum include only enabled, non-archived, non-task rows with needs_purchase=true. Gifts contribute zero.
- Task completion and packing completion have no budget effect.
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

## Manual price rollout — 2026-09-30
- Frontend implemented with backward compatibility: the editor appears only when SELECT * includes the `actual_price` column.
- Database activation is complete: `actual_price` was verified present on 2026-09-30.
- Existing rows default to NULL and keep their current slider prices. No existing data, RLS, Auth, or Realtime configuration is changed.
- After adding the column, verify manual entry, reload persistence and sync between both authenticated clients. Older already-open versions should be refreshed because they do not understand the override.

## Purchase / task / packing model — 2026-09-30
- Classify per item, never infer that a whole category must be shopping or tasks.
- `product`: equipment; `task`: action; `packing`: something to pack or bring.
- `completed` means "בוצע" for tasks, "ארזתי" for packing and "מוכן" for products already available.
- `purchased` and `completed` are independent. Buying a TENS does not mean it is packed.
- All non-task items have "צריך לקנות". Turning it on shows existing price, slider, purchase and gift controls. Turning it off keeps prices and purchase history while excluding future planned expense.
- Type selector allows partners to correct classifications. Changing to product enables needs_purchase; changing to task/packing disables it. It never resets purchased, completed or prices.
- Checklist progress reflects visible, non-archived tasks, packing items and products with needs_purchase=false, including enabled=false tasks. Disabled-budget status must not hide or fade tasks.
- Existing task records and documents were classified; station organization and food preparation are tasks. Packing supplies default to already available, except snacks, cord kit and the previously purchased TENS. Missing supplies can be flagged for buying.
- Baby clothes moved from room/sleep to clothing/textiles; sprays moved to postpartum; packing supplies moved out of pre-birth tasks.
- Three untouched companion duplicates are archived, not deleted. Purchased, gifted or manually priced duplicates are preserved.
- Database setup: applied schema migration `add_checklist_and_packing_state`; `database/checklists.sql` records its schema and one-time classification changes. Do not rerun classification after users make edits.
- Existing RLS policies and UPDATE Realtime publication are preserved. Realtime spreads new row fields and normalizes the corresponding local row.
- Checkbox/type actions update locally and issue one UPDATE; failed writes revert if no newer change superseded them. Slider performance rule remains unchanged.
- Validation: all rendered inline handlers compile; functional checks cover budget exclusion, history, independent completion, exact prices, slider reset, failed writes and Realtime payload handling. Database completion persistence checked in a rolled-back transaction. iPhone visual validation still requires an actual browser.
- Both clients must reload after deployment to use the new fields.

Keep this file updated when architecture or important behavioral decisions change.
