-- ============================================================
-- منصة صيف الابتكار 2026 - قاعدة البيانات
-- نفّذ هذا الملف كاملاً في Supabase SQL Editor (مرة واحدة فقط)
-- ============================================================

create extension if not exists pgcrypto;

-- ---------- المسارات (بيانات ثابتة من البرنامج) ----------
create table if not exists tracks (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name_ar text not null,
  day1_date date not null,
  day2_date date not null,
  day3_date date not null,
  color text not null default '#0B1B3F',
  capacity int default 30
);

insert into tracks (code, name_ar, day1_date, day2_date, day3_date, color) values
  ('biz',      'ريادة الأعمال',                 '2026-07-27','2026-07-28','2026-07-29', '#E7B10A'),
  ('agents',   'وكلاء الذكاء الاصطناعي',        '2026-07-27','2026-07-28','2026-07-29', '#0B1B3F'),
  ('coding',   'البرمجة بالذكاء الاصطناعي',      '2026-08-03','2026-08-04','2026-08-05', '#E7B10A'),
  ('elearn',   'التعلم الإلكتروني',              '2026-08-03','2026-08-04','2026-08-05', '#0B1B3F'),
  ('emerging', 'التقنيات الناشئة',               '2026-08-10','2026-08-11','2026-08-12', '#E7B10A'),
  ('digital',  'التصنيع الرقمي والنمذجة',        '2026-08-10','2026-08-11','2026-08-12', '#0B1B3F')
on conflict (code) do nothing;

-- ---------- المشاركون ----------
create table if not exists participants (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  email text not null,
  phone text not null,
  organization text,
  track_id uuid references tracks(id) not null,
  qr_token text unique not null default encode(gen_random_bytes(6), 'hex'),
  registered_at timestamptz default now(),
  day1_attended boolean default false,
  day2_attended boolean default false,
  day3_attended boolean default false,
  certificate_issued boolean default false,
  certificate_code text unique
);

create index if not exists idx_participants_track on participants(track_id);
create index if not exists idx_participants_qr on participants(qr_token);

-- ============================================================
-- الصلاحيات (RLS)
-- ============================================================
alter table tracks enable row level security;
alter table participants enable row level security;

-- الجميع يمكنه قراءة المسارات (تظهر في نموذج التسجيل)
create policy "tracks_public_read" on tracks for select using (true);

-- أي زائر يمكنه التسجيل (إدخال جديد فقط)
create policy "participants_public_insert" on participants for insert with check (true);

-- القراءة/التعديل/الحذف للمشاركين محصورة على المستخدمين المسجّلين (فريق الإدارة)
create policy "participants_admin_select" on participants for select using (auth.role() = 'authenticated');
create policy "participants_admin_update" on participants for update using (auth.role() = 'authenticated');
create policy "participants_admin_delete" on participants for delete using (auth.role() = 'authenticated');

-- ============================================================
-- دالة عامة وآمنة لصفحة "التحقق من الشهادة" (لا تكشف بيانات حساسة)
-- ============================================================
create or replace function get_certificate(p_code text)
returns table (full_name text, track_name text, day1_date date, day3_date date, issued boolean)
language sql security definer as $$
  select p.full_name, t.name_ar, t.day1_date, t.day3_date, p.certificate_issued
  from participants p join tracks t on t.id = p.track_id
  where p.certificate_code = p_code and p.certificate_issued = true;
$$;

grant execute on function get_certificate(text) to anon;

-- ============================================================
-- بعد تنفيذ هذا الملف:
-- 1) من Authentication > Users في Supabase، أضف حساب/حسابات لفريق الإدارة (بريد + كلمة مرور)
--    هذا الحساب هو ما سيسجل الدخول منه في admin.html و checkin.html
-- ============================================================
