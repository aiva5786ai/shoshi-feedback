-- עדכון 2 (6.8.2026) — בקשות שושי מ-15.7:
-- מינימום תשובות, רקע כרטיס מותאם, טקסט תחתית הכרטיס.
-- להריץ פעם אחת ב-Supabase → SQL Editor → Run

alter table shoshi_lessons add column if not exists min_answers int default 3;
alter table shoshi_lessons add column if not exists card_bg text default '';
alter table shoshi_lessons add column if not exists card_text text default '';
