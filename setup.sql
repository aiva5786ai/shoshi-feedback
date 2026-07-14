-- מערכת פידבק לשיעורים של שושי קוט
-- להריץ פעם אחת ב-Supabase → SQL Editor → New query → Run

create table if not exists shoshi_settings (
  id int primary key default 1,
  admin_pass text default '770',
  openai_key text, -- יופעל בשלב ב' כשיגיע המפתח (דרך Edge Function, לא מהדפדפן)
  updated_at timestamptz default now()
);

create table if not exists shoshi_lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  lesson_point text default '',
  questions jsonb not null default '[]'::jsonb,
  image_style text default 'קומיקס',
  image_prompt text default '',
  is_open boolean default true,
  created_at timestamptz default now()
);

create table if not exists shoshi_students (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  photo_base64 text,
  created_at timestamptz default now()
);

create table if not exists shoshi_responses (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid references shoshi_lessons(id) on delete cascade,
  student_id uuid references shoshi_students(id) on delete set null,
  student_name text,
  answers jsonb not null default '[]'::jsonb,
  ai_reply text,
  image_url text,
  created_at timestamptz default now()
);

-- הרשאות: אפליקציה קהילתית קטנה — גישה פתוחה עם מפתח anon.
-- המפתח openai_key לעולם לא נשלף בדף התלמידים.
alter table shoshi_settings enable row level security;
alter table shoshi_lessons enable row level security;
alter table shoshi_students enable row level security;
alter table shoshi_responses enable row level security;

create policy "anon all settings" on shoshi_settings for all using (true) with check (true);
create policy "anon all lessons" on shoshi_lessons for all using (true) with check (true);
create policy "anon all students" on shoshi_students for all using (true) with check (true);
create policy "anon all responses" on shoshi_responses for all using (true) with check (true);

-- נתוני פתיחה
insert into shoshi_settings (id) values (1) on conflict (id) do nothing;

insert into shoshi_lessons (title, lesson_point, questions, image_style, image_prompt, is_open)
values (
  'שיעור ראשון',
  'חשוב להיות גאה ביהדות',
  '[
    {"type":"text","q":"משהו שהבנת או שהתחדש לך מהשיעור היום"},
    {"type":"emoji","q":"איזה אימוג''י הכי מתחבר לך לשיעור? וכמה מילים למה"},
    {"type":"openers","q":"איך זה קשור לחיים האמיתיים שלך?","options":["קשור לחלומות שלי בעתיד","קשור לבחירות שאני צריך לעשות","קשור לחיי משפחה","קשור לבית","קשור לדברים פיזיים","קשור לרגשות שלי","אחר"]},
    {"type":"text","q":"רעיון מהיום שחשוב לחלוק עם אחרים / משהו שתרצה להעמיק בו"}
  ]'::jsonb,
  'קומיקס',
  'תמונה של התלמיד בתוך ריבוע קומיקס, משוחח עם דמות של גיבור-על ומבטא בבועות דיבור את נקודות התוכן העיקריות של השיעור בשילוב נקודות מתוך הפידבק שלו. לשלב רעיונות מהתוכן גם באביזרים, ברקע ובציור, עם קצת מלל.',
  true
);
