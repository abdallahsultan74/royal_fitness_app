-- Add date of birth to profiles + expose age to the admin summary RPC.

alter table public.profiles
  add column if not exists date_of_birth date;

-- Compute age in full years (NULL-safe).
create or replace function public.age_years(dob date)
returns integer
language sql
stable
set search_path = public
as $$
  select case
    when dob is null then null
    else date_part('year', age(current_date, dob))::integer
  end;
$$;

-- Admin/Coach user summary for the admin dashboard: include DOB + age_years.
create or replace function public.api_admin_user_progress_summary()
returns table (
  user_id uuid,
  email text,
  name text,
  plan text,
  role text,
  status text,
  date_of_birth date,
  age_years integer,
  current_weight_kg numeric,
  target_weight_kg numeric,
  height_cm numeric,
  bmi numeric,
  bmi_status text,
  last_weight_log_at timestamptz,
  active_challenge_slug text,
  active_challenge_title text,
  challenge_level text,
  challenge_status text,
  challenge_current_day integer,
  challenge_progress_percent numeric,
  streak_days integer
)
language sql
stable
security definer
set search_path = public
as $$
  with active_challenge as (
    select distinct on (uc.user_id)
      uc.user_id,
      ct.slug,
      ct.title,
      ct.level,
      uc.status,
      uc.current_day,
      uc.progress_percent
    from public.user_challenges uc
    join public.challenge_templates ct
      on ct.id = uc.challenge_id
    where uc.status in ('active', 'completed')
    order by uc.user_id, uc.started_at desc
  ),
  streaks as (
    select
      ds.user_id,
      count(*)::integer as streak_days
    from public.daily_stats ds
    where ds.session_count > 0
       or ds.completed_exercises > 0
       or ds.total_minutes > 0
    group by ds.user_id
  )
  select
    p.id,
    p.email,
    p.name,
    p.plan,
    p.role,
    p.status,
    p.date_of_birth,
    public.age_years(p.date_of_birth),
    p.current_weight_kg,
    p.target_weight_kg,
    p.height_cm,
    p.bmi,
    p.bmi_status,
    p.last_weight_log_at,
    ac.slug,
    ac.title,
    ac.level,
    ac.status,
    ac.current_day,
    ac.progress_percent,
    coalesce(s.streak_days, 0)
  from public.profiles p
  left join active_challenge ac
    on ac.user_id = p.id
  left join streaks s
    on s.user_id = p.id
  where public.is_admin() or public.is_coach();
$$;

