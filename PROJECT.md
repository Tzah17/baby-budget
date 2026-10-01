# Baby Hub — Project Guide

## Product
Shared Hebrew RTL, mobile-first app for a couple preparing for a baby. V2 expands the original Baby Budget into a hub with six areas: Home, Budget, Preparations, Hospital Bag, Pregnancy Checks and Safety.

## Stack
- Repository: Tzah17/baby-budget
- GitHub Pages from main; main app is index.html.
- Plain HTML/CSS/JavaScript; keep it lightweight.
- Supabase project xewoeopijjgaaqqcyqnp: email/password Auth, Postgres and Realtime.
- Never use or commit database passwords/service-role secrets. The browser publishable key is intentionally public.

## Tables
### baby_budget_items
Existing source for budget, preparation tasks and packing. Important fields: id, item, category, min_price, max_price, slider, actual_price, enabled, purchased, gift, type (product/task/packing), completed, needs_purchase, archived.

### pregnancy_checks
V2 pregnancy-check tracker imported from the workbook's בדיקות tab: trimester, test_name, week_text, date_window, test_date_text, completed, notes.

### safety_notes
Read-only safety cards imported from the workbook's הערות בטיחות tab: topic, important, impact, source_url.

### prep_items
V2 staging/extension table created for richer workbook metadata. Do not depend on it for current UI until its richer MASTER import is completed; current preparation/packing UI intentionally uses baby_budget_items to preserve all existing user state.

## Current V2 navigation
- ראשי: combined progress and next unchecked pregnancy item.
- תקציב: existing budget behavior.
- הכנות: task/checklist view.
- תיק לידה: packing view.
- בדיקות: trimester-based checklist imported from workbook.
- בטיחות: safety notes with their source links.

## Budget rules
- actual_price overrides slider when non-null.
- Slider 0%=min, 100%=max; slider changes only on change/release and clears actual_price.
- Gifts contribute zero.
- Planned totals include enabled, non-archived, non-task rows with needs_purchase=true.
- Spent is purchased price history.
- Task/packing completion is independent of purchase state.

## Critical iPhone rule
Never render or write to Supabase continuously during range input dragging. Slider commits only on change/release. Avoid expensive full-list work on touchmove/input. This previously caused Safari instability.

## Realtime
baby_budget_items and pregnancy_checks are in supabase_realtime. V2 listens for UPDATE on both. Safety notes are read-only.

## Source workbook
The V2 concept and pregnancy/safety content came from the uploaded birth checklist workbook. Preserve source wording rather than silently changing medical/safety guidance. The workbook also contains richer MASTER metadata (priority, quantity, when needed, notes, shopping links) that can be imported in a later iteration.

## Collaboration
Before editing, fetch latest main and read this file + index.html. Both partners may edit via separate ChatGPT sessions. Never overwrite a newer main revision; re-fetch/reconcile. Keep changes focused, preserve RTL/Auth/Realtime/mobile performance, and update this guide when architecture changes.

## V2 status — 2026-10-01
- Supabase migration baby_hub_v2_core applied.
- pregnancy_checks and safety_notes seeded from the workbook.
- prep_items created and initialized as a safe extension path.
- Existing baby_budget_items preserved; no destructive migration.
- GitHub V2 frontend committed to main.
