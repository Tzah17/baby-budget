-- Applied schema and one-time classification setup, 2026-09-30.
-- Reference only: do not rerun classification after user edits.
ALTER TABLE public.baby_budget_items
 ADD COLUMN IF NOT EXISTS completed boolean NOT NULL DEFAULT false,
 ADD COLUMN IF NOT EXISTS needs_purchase boolean NOT NULL DEFAULT true,
 ADD COLUMN IF NOT EXISTS archived boolean NOT NULL DEFAULT false;
NOTIFY pgrst, 'reload schema';

BEGIN;
UPDATE public.baby_budget_items SET needs_purchase=false WHERE type='task';
UPDATE public.baby_budget_items SET type='task',needs_purchase=false
 WHERE category='בית והכנות' AND item IN ('ארגון תחנת החתלה','ארגון תחנת הנקה ליד המיטה/ספה','מלאי אוכל קפוא/קל להכנה');
UPDATE public.baby_budget_items SET type='packing',needs_purchase=purchased
 WHERE category IN ('תיק לידה ואשפוז','תיק לידה — מלווה');
UPDATE public.baby_budget_items SET type='packing',needs_purchase=purchased
 WHERE category='משימות לפני הלידה' AND item IN ('טלפון + מטען ארוך/סוללה','כפכפים למקלחת','מגבת / חלוק רחצה','גרביים חמות','גומיות/קליפס לשיער','שפתון לחות','תיק רחצה בסיסי','כרית חימום / כדור טניס לעיסוי','פלייליסט / רמקול קטן','מניפה/תרסיס מים','חבילת טישו / נייר טואלט קטנה','משקפי שמש','בושם / מוצרי ריח אישיים','בגדים כהים ונוחים לאשפוז','בגד נוח/יפה ליציאה מבית החולים','סט בגדים מלא למלווה ל-1–2 ימים');
UPDATE public.baby_budget_items SET type='packing',needs_purchase=true,category='תיק לידה ואשפוז'
 WHERE category='משימות לפני הלידה' AND item='מכשיר TENS לצירים';
UPDATE public.baby_budget_items SET needs_purchase=purchased
 WHERE item IN ('בגדים נוחים / פיג''מות נפתחות','בקבוק מים גדול עם קש','כרית ישיבה/חימום לפי צורך','מטען ארוך ליד המיטה');
UPDATE public.baby_budget_items SET category='בגדים וטקסטיל'
 WHERE (category='חדר ושינה' AND item IN ('בגדי גוף NB/0–3','אוברולים / פיג''מות 0–3','מכנסי רגליות'))
 OR (category='משימות לפני הלידה' AND item='כפפות ניו-בורן / מיטנס');
UPDATE public.baby_budget_items SET category='אמא לאחר הלידה'
 WHERE category='משימות לפני הלידה' AND item IN ('ספריי הרגעה לפרינאום / תפרים','Aloe First / ספריי אלוורה');
UPDATE public.baby_budget_items SET category='תיק לידה ואשפוז'
 WHERE category='משימות לפני הלידה' AND type='packing';
UPDATE public.baby_budget_items SET category='תיק לידה — מלווה'
 WHERE category='תיק לידה ואשפוז' AND item='סט בגדים מלא למלווה ל-1–2 ימים';
UPDATE public.baby_budget_items SET needs_purchase=true
 WHERE type='packing' AND item IN ('חטיפים/אוכל קל לגילי ולמלווה','אוכל ושתייה','ערכת דם טבורי');
-- Hide only untouched duplicates; retain rows, prices and any recorded purchases.
UPDATE public.baby_budget_items d SET archived=true
 WHERE d.category='תיק לידה — מלווה'
 AND d.item IN ('החלפת בגדים','מברשת שיניים + דאודורנט','סט בגדים מלא למלווה ל-1–2 ימים')
 AND NOT d.purchased AND NOT d.gift AND d.actual_price IS NULL
 AND EXISTS (SELECT 1 FROM public.baby_budget_items c WHERE c.category=d.category AND NOT c.archived
 AND c.item=CASE WHEN d.item='מברשת שיניים + דאודורנט' THEN 'מברשת ומשחת שיניים' ELSE '2–3 החלפות בגדים נוחים' END);
COMMIT;
