-- Run once in the existing Baby Budget Supabase project's SQL Editor.
-- Adds exact manual prices without rewriting existing rows or changing RLS.
ALTER TABLE public.baby_budget_items
  ADD COLUMN IF NOT EXISTS actual_price numeric(12,2)
  CHECK (actual_price >= 0);
NOTIFY pgrst, 'reload schema';
