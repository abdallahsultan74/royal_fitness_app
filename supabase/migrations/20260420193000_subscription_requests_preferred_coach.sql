-- Allow users to choose a preferred coach when requesting activation/renewal.

alter table public.subscription_requests
  add column if not exists preferred_coach_id uuid references auth.users(id) on delete set null;

create index if not exists idx_subscription_requests_preferred_coach
  on public.subscription_requests (preferred_coach_id);

