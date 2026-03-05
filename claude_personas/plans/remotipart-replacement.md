# Product Spec: Remotipart Replacement

## Problem

`remotipart` 1.4.4 is the last jQuery-specific dependency preventing a clean JS stack.
It handles multipart AJAX file uploads for exactly one form: the profile picture upload on the
account settings page. It's untested on Rails 8 + Turbo and could break silently.

## Current State

**What remotipart does:** Intercepts `form_with(multipart: true)` submissions, wraps the file
in a multipart AJAX request via jQuery, and returns the response for Turbo Stream processing.

**The single file upload form:**
- Location: `app/views/users/partials/_account_form.html.haml` (Profile Photo section)
- Two input methods: file field (local upload) + remote URL (CarrierWave fetches from URL)
- Response: Turbo Stream replaces `#profile-pic` and `#header-pic` with new image

**CarrierWave stack:**
- `carrierwave` ~> 3.1 with `fog-aws` (S3 storage)
- `rmagick` for image processing (5 size versions: 27px to 120px)
- `PreviewUploader` for crossword previews (generated programmatically, not user-uploaded)

---

## Solution: Turbo Native File Upload

Rails 7+/Turbo handles `multipart/form-data` submissions natively. The `form_with` helper
with `multipart: true` submits via Turbo's fetch API, which supports `FormData` (including
files) without any gem.

**This means:** Simply removing `remotipart` may be all that's needed. Turbo already handles
multipart forms.

---

## Migration Plan

### Phase 1: Verify Turbo Handles It (30 min)

1. Remove `gem 'remotipart'` from Gemfile
2. `bundle install`
3. Remove any remotipart JS requires from the asset pipeline (check `application.js`)
4. Test the profile picture upload form:
   - Upload a local file → verify Turbo Stream response replaces images
   - Paste a remote URL → verify same behavior
   - Submit with no image → verify form still works normally
5. If it works: done. Turbo has handled multipart since Turbo 7.2+.

### Phase 2: If Turbo Doesn't Handle It (fallback)

If removing remotipart breaks file uploads, use **Active Storage direct upload** as replacement:

1. Install Active Storage: `rails active_storage:install`
2. Replace CarrierWave with Active Storage on the User model
3. Use `direct_upload: true` on the file field — uploads go directly to S3 via JS
4. Turbo Stream response works normally (no multipart in the form submission itself)

**This is the nuclear option** — it replaces CarrierWave entirely. Only pursue if Phase 1 fails.

### Phase 3: Alternative Lightweight Fix

If Turbo multipart works for file upload but breaks for remote URL:
- Split the form: file upload via Turbo, remote URL via standard POST
- Or: fetch the remote URL server-side after a normal form submission (no multipart needed
  for URL-only submissions)

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Removing remotipart breaks file upload | Low | High | Phase 1 is a test, not a commit. Revert if broken. |
| CarrierWave incompatible with Active Storage | N/A unless Phase 2 | High | Keep CarrierWave. Only replace remotipart, not the upload stack. |
| Remote URL upload breaks | Low | Low | Remote URL upload uses CarrierWave's `remote_image_url=`, which doesn't need multipart — it's a regular text field. |
| Image processing breaks | None | N/A | RMagick is independent of how the file arrives. |

**Key insight:** The remote URL upload (`remote_image_url`) is just a text field. It doesn't
need multipart at all. Only the file field needs multipart. And Turbo handles `FormData`
with files natively since ~2022.

---

## Why Not Active Storage?

Active Storage would be the "modern Rails" answer, but:
1. CarrierWave works fine — 5 image versions, S3 storage, all tested
2. Migration would touch every `image_tag` that references CarrierWave URLs
3. Preview generation (RMagick → CarrierWave) would need rewriting
4. Risk/reward ratio is poor for replacing a working upload stack

**Recommendation:** Just remove remotipart. Keep CarrierWave. Turbo handles the rest.

---

## Files Touched (Phase 1 — optimistic path)

| File | Change |
|------|--------|
| `Gemfile` | Remove `gem 'remotipart', '~> 1.4'` |
| `app/assets/javascripts/application.js` | Remove remotipart require (if present) |
| Possibly: `app/views/users/partials/_account_form.html.haml` | May need no changes (Turbo handles multipart) |

## jQuery Dependency Impact

After removing remotipart, jQuery is still required by:
- `solve_funcs.js` — extensive jQuery use
- `edit_funcs.js` — extensive jQuery use
- Various animation/DOM manipulation code

Removing jQuery entirely is a much larger project (not in scope). But removing remotipart
eliminates the last jQuery *gem dependency*, which reduces upgrade risk.

## Acceptance Criteria

1. `remotipart` gem removed from Gemfile
2. Profile picture upload (file) works via Turbo without remotipart
3. Profile picture upload (remote URL) works
4. Turbo Stream response correctly replaces both `#profile-pic` and `#header-pic`
5. Image processing (5 CarrierWave versions) still works
6. No other forms or features broken
7. `bundle exec rspec` passes
