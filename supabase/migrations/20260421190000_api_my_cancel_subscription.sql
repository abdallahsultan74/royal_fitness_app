-- User-initiated cancellation: no staff approval required.
-- Creates an audit row in subscription_requests for reporting and revokes access immediately.

create or replace function public.api_my_cancel_subscription()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid;
begin
  uid := auth.uid();
  if uid is null then
    raise exception 'not_authenticated';
  end if;

  -- Audit row for admin reports (not pending).
  insert into public.subscription_requests(
    user_id, requested_plan, request_kind, duration_days, status, note, approved_at
  )
  values (
    uid,
    'cancel',
    'cancel',
    0,
    'approved',
    'Cancelled from mobile (instant)',
    timezone('utc', now())
  );

  -- Apply immediately.
  perform public.apply_subscription_request_effects(uid, 'cancel', null::uuid);

  -- Notify admins (optional report signal).
  insert into public.admin_notifications(type, title, body, read)
  values (
    'subscription_cancelled',
    'Subscription cancelled',
    'User ' || uid::text || ' cancelled subscription.',
    false
  );
end;
$$;

revoke all on function public.api_my_cancel_subscription() from public;
grant execute on function public.api_my_cancel_subscription() to authenticated;

