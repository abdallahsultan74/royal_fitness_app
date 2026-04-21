-- Fix: api_staff_upsert_subscription_package_variant uses ON CONFLICT(package_id, duration_days)
-- which requires a unique/exclusion constraint. The original schema only had a partial unique index.
-- We enforce one row per (package_id, duration_days) and toggle active on that row.

drop index if exists public.idx_subscription_package_variants_active_unique;

alter table public.subscription_package_variants
  drop constraint if exists subscription_package_variants_package_duration_unique;

alter table public.subscription_package_variants
  add constraint subscription_package_variants_package_duration_unique
  unique (package_id, duration_days);

