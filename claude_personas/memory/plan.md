# Plan: Vendor Chart.js (Replace CDN)

## Problem
Stats page loads Chart.js v4 from jsdelivr CDN. CDN adds latency (DNS + TLS to third-party
domain), has no fallback if jsdelivr goes down, and is unnecessary for a single-page consumer.

## Approach
Vendor the Chart.js v4 UMD build locally. Sprockets manifest already links `vendor/assets/javascripts/`.
The file loads only on the stats page (not globally), so zero impact on other pages.

## Steps

### 1. Download Chart.js v4 UMD build
```bash
curl -o vendor/assets/javascripts/chart.umd.min.js \
  https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js
```
~175KB. One file, no dependencies (v4 UMD is self-contained).

### 2. Update stats view — CDN → local asset
**File:** `app/views/pages/stats.html.haml` (line 4)

```diff
- = javascript_include_tag 'https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js'
+ = javascript_include_tag 'chart.umd.min'
```

Sprockets serves it with digest fingerprint for cache busting. Same-domain = no extra DNS/TLS.

### 3. Simplify Stimulus controller — remove CDN load fallback
**File:** `app/assets/javascripts/controllers/stats_controller.js` (lines 3–11)

The `typeof Chart === 'undefined'` check + window load listener was a CDN latency workaround.
With a local `<script>` tag in `<head>`, Chart.js is guaranteed loaded before Stimulus connects.

```diff
  connect() {
-   // Chart.js loads via CDN in the <head> — should be available by connect().
-   // Belt-and-suspenders: wait for window load if CDN is slow.
-   if (typeof Chart === 'undefined') {
-     window.addEventListener('load', () => this.renderCharts())
-   } else {
-     this.renderCharts()
-   }
+   this.renderCharts()
  }
```

### 4. Clear precompiled assets (if stale)
```bash
rm -rf public/assets
```
Sprockets caches aggressively. New vendor file won't appear until cache is cleared or
`RAILS_ENV=production bundle exec rake assets:precompile` is run.

## Files Changed
| File | Change |
|------|--------|
| `vendor/assets/javascripts/chart.umd.min.js` | New — vendored Chart.js v4 UMD |
| `app/views/pages/stats.html.haml` | Line 4: CDN URL → local asset tag |
| `app/assets/javascripts/controllers/stats_controller.js` | Remove CDN load fallback (3 lines → 1) |

## Verification
1. `rails s` → visit `/stats`
2. Both charts render (Total Users + Daily Signups)
3. Browser DevTools Network tab: `chart.umd.min-[digest].js` served from localhost, not jsdelivr
4. `bundle exec rspec` — no test changes needed (no stats page specs exist)

## Risk
Very low. Swapping script source, no behavior change. Charts use identical Chart.js v4 API.
