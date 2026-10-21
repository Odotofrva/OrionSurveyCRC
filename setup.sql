-- Run in Supabase SQL Editor. Reviews are private until explicitly approved.
create table if not exists public.customer_surveys (
 id uuid primary key default gen_random_uuid(),
 customer_name text check (customer_name is null or char_length(customer_name) <= 60),
 rating integer not null check (rating between 1 and 5),
 feedback text not null check (char_length(btrim(feedback)) between 1 and 1000),
 language text not null default 'en' check (language in ('en','es')),
 status text not null default 'pending' check (status in ('pending','approved','rejected')),
 created_at timestamptz not null default now()
);
create table if not exists public.survey_admins (
 user_id uuid primary key references auth.users(id) on delete cascade
);
-- Prevent clients from writing the admin allowlist; add admins only via SQL Editor.
revoke all on public.survey_admins from anon, authenticated;
alter table public.customer_surveys enable row level security;
alter table public.survey_admins enable row level security;
-- Function executes as its owner to check the allowlist without exposing it.
create or replace function public.is_survey_admin()
returns boolean language sql stable security definer set search_path = '' as $$
 select exists (select 1 from public.survey_admins where user_id = (select auth.uid()));
$$;
revoke all on function public.is_survey_admin() from public;
grant execute on function public.is_survey_admin() to authenticated;
-- No client-supplied status/created_at/id are accepted: public inserts must be pending.
drop policy if exists "Customer can submit pending survey" on public.customer_surveys;
create policy "Customer can submit pending survey" on public.customer_surveys
for insert to anon, authenticated with check (status = 'pending');
drop policy if exists "Admin can read surveys" on public.customer_surveys;
create policy "Admin can read surveys" on public.customer_surveys
for select to authenticated using ((select public.is_survey_admin()));
drop policy if exists "Admin can moderate surveys" on public.customer_surveys;
create policy "Admin can moderate surveys" on public.customer_surveys
for update to authenticated using ((select public.is_survey_admin()))
with check ((select public.is_survey_admin()));
-- Public view deliberately omits customer names, and exposes approved records only.
-- This view uses its owner's rights; base table remains unreadable to anonymous users.
create or replace view public.approved_surveys as
select id, rating, feedback, language, created_at
from public.customer_surveys where status = 'approved';
revoke all on public.customer_surveys from anon;
grant insert on public.customer_surveys to anon;
grant select, insert, update on public.customer_surveys to authenticated;
revoke all on public.approved_surveys from public;
grant select on public.approved_surveys to anon, authenticated;
-- IMPORTANT: Add an admin only after creating a user in Authentication > Users:
-- insert into public.survey_admins(user_id) values ('PASTE-AUTH-USER-UUID-HERE');
