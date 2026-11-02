-- שלב ב' (2.11.2026) — תמונות AI אישיות לתלמידים.
-- להריץ פעם אחת ב-Supabase → SQL Editor → Run

alter table shoshi_lessons add column if not exists images_on boolean default true;

alter table shoshi_responses add column if not exists image_status text; -- generating / queued / done / failed
alter table shoshi_responses add column if not exists image_error text;
alter table shoshi_responses add column if not exists image_started_at timestamptz;

-- יומן תמונות לתקרה היומית. בלי policies — רק פונקציית השרת ניגשת אליו.
create table if not exists shoshi_image_log (
  id bigserial primary key,
  response_id uuid,
  created_at timestamptz default now()
);
alter table shoshi_image_log enable row level security;

-- התמונות שנוצרו (קריאה ציבורית, כתיבה רק מפונקציית השרת)
insert into storage.buckets (id, name, public)
values ('shoshi-images', 'shoshi-images', true)
on conflict (id) do nothing;
