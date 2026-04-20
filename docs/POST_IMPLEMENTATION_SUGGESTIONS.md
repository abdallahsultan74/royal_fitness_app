# Post-Implementation Suggestions (Royal Fitness)

This document is a review checklist and is not part of the runtime application logic.

## Product & permissions

- **Grace period after Pro expiry**: keep access for 24–72 hours with a banner instead of immediate lockout.
- **Central feature matrix**: consider a `plan_tier_features` table to drive both app + admin behavior instead of duplicating checks across RPCs.
- **Audit log**: introduce an `admin_audit_log` to track changes to `plan`, `feature_flags`, and plan assignments.

## Performance & reliability

- **Realtime**: where it makes sense, consider merging `plan_assignments` + `profiles` subscriptions into a single channel to reduce load.
- **Integration tests**: add end-to-end scenarios for `api_my_active_plan` / `api_my_active_challenge` after changes to `profiles.plan` and `feature_flags`.

## User experience

- **Cached images on Home**: use `CachedNetworkImage` for plan images loaded from HTTPS URLs.
- **In-app notice**: notify users when Pro access is revoked or a plan assignment is removed (via `user_notifications`).

## Admin

- **Plan JSON import/export**: enable moving plan JSON between staging and production.
- **Preview**: add a “today preview” in the admin before saving (reuse the same parsing logic as the app).

## Branding

- Replace `assets/branding/*.png` with final high-resolution assets when ready.
