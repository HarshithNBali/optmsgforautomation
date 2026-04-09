# HTML Sanitization & Email Rendering

> Documentation, rules, implementation plans, and progress tracking for email HTML sanitization in the OptMsg app.

---

## Architecture Overview

### Rendering Pipeline

```
Backend API (email.message: raw HTML string)
  |
  v
HtmlSanitizerService.buildEmailHtml(rawHtml)
  |-- sanitizeEmailHtml()      --> security & rendering sanitization
  |   |-- convertPlainUrlToHtml()  --> linkify URLs, proxy non-HTTPS images
  |   |-- regex pipeline          --> strip dangerous tags, attrs, URIs
  |-- wrap in HTML template    --> viewport meta, responsive CSS, JS normalization
  |
  v
Platform-specific rendering:
  |-- iOS/Android: InAppWebView  (native_app_html_view_native.dart)
  |-- Web: sandboxed iframe      (native_app_html_view_web.dart)
```

### Key Files

| Component | File |
|-----------|------|
| Sanitization & rendering | `lib/services/html_sanitizer_service.dart` |
| Native renderer (iOS/Android) | `lib/screens/inbox/native_app_html_view_native.dart` |
| Web renderer | `lib/screens/inbox/native_app_html_view_web.dart` |
| Platform abstraction | `lib/screens/inbox/native_app_html_view.dart` |
| Email display screen | `lib/screens/inbox/view_email.dart` |
| Biometric link guard | `lib/services/action_biometric_guard.dart` |
| App config (proxy URLs) | `lib/constant/app_config.dart` |

### Packages

- `flutter_inappwebview: ^6.1.5` -- native rendering engine (iOS/Android + draft compose)
- No dedicated HTML sanitizer package -- custom regex-based pipeline in `HtmlSanitizerService`

---

## Sanitization Rules

### Security Sanitization (H-11 Hardening)

All rules applied in `sanitizeEmailHtml()` in order:

| # | Rule | What it removes/neutralizes | Regex |
|---|------|-----------------------------|-------|
| 1 | Script tags | `<script>...</script>` and self-closing | `_scriptTagRegex` |
| 2 | Iframe tags | `<iframe>...</iframe>` and self-closing | `_iframeTagRegex` |
| 3 | Dangerous tags | `<object>`, `<embed>`, `<applet>`, `<form>`, `<base>`, `<link rel="import">` | `_dangerousTagRegex` |
| 4 | Structural tags | Nested `<html>`, `<head>`, `<body>`, `<meta>` | `_structuralTagRegex` |
| 5 | Event handlers | `onclick`, `onerror`, `onload`, etc. | `_eventHandlerRegex` |
| 6 | Dangerous URIs | `javascript:`, `vbscript:`, `data:` in href/src/action | `_dangerousUriRegex` |
| 7 | CSS expressions | `expression()`, `url("javascript:...")` in style attrs | `_cssExpressionRegex` |
| 8 | Tracking pixels | `<img>` with `height="1"` | `_trackingPixelRegex` |
| 9 | Empty tables | `<table>` with no content | `_emptyTableRegex` |

### Pre-processing

| Rule | What it does |
|------|-------------|
| URL linkification | Plain-text `http(s)://` URLs in non-HTML emails wrapped in `<a>` tags with `rel="noopener noreferrer"` |
| Image proxy | Non-HTTPS `<img src>` URLs rewritten to `{baseUrl}/image-proxy?url={encoded}` |

### Preserved (intentionally NOT stripped)

| Property | Reason |
|----------|--------|
| `display:none` | WebView/browser handles correctly; stripping exposes preheader text |
| `float:left/right` | Standard layout property for text-wrapping (restored in v1.0.6 rendering fixes) |

---

## Rendering Wrapper (buildEmailHtml)

### Viewport Meta

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=0.25, maximum-scale=4.0, shrink-to-fit=yes">
```

- `width=device-width` -- renders at the device's actual width
- `initial-scale=1.0` -- starts at 1:1 zoom
- `shrink-to-fit=yes` -- auto-scales the page when content is wider than the viewport (e.g., 600px email on 375px phone); only activates when content overflows, so no effect on tablets/desktops
- `minimum-scale=0.25` -- allows zooming out to 25% to see full-width content
- `maximum-scale=4.0` -- allows zooming in to 400% for small text

### CSS Injection

```css
/* Responsive containment */
*, *::before, *::after { box-sizing: border-box !important; }
img { max-width:100% !important; height:auto !important; }
table { max-width:100% !important; border-collapse:collapse; }
td, th { overflow-wrap:break-word; }
a { overflow-wrap: break-word; }
```

Key design decisions:
- **No `width:auto !important` on tables** -- allows tables to keep their specified widths (e.g., `width="600"`) while `max-width:100%` prevents overflow
- **No `display:block` on images** -- preserves inline image patterns (signatures, social icon rows like myQ Facebook/Twitter/Instagram)
- **No `max-width` on div/p/span/td/th** -- these elements naturally respect parent width; forcing `max-width:100%` breaks intentional constraints (e.g. myQ logo wrapper `max-width: 105px` would expand to full width)
- **`overflow-wrap: break-word`** (not `word-break: break-word`) on td/th/a -- `word-break: break-word` reduces minimum content width to ~1 character in the table layout algorithm, causing narrow cells (e.g. Ahrefs "View" buttons) to collapse and render text vertically. `overflow-wrap` only breaks when content would overflow, preserving correct minimum widths
- **`overflow-x: auto`** (not `hidden`) on body -- shows scrollbar if content overflows rather than silently clipping
- **`overflow-y: auto`** (not `hidden`) on body -- required for accurate `scrollHeight` measurement in Chromium

### JavaScript Normalization (`normalizeWidths`)

Runs on DOMContentLoaded. Strips HTML **attributes** (not inline CSS styles) to make legacy email layouts responsive:

- **Tables**: HTML `width`/`height` attributes removed; `max-width: 100%` added as inline style. Inline CSS `width` styles preserved (e.g. `style="width: 100%"`)
- **Table cells (td/th)**: HTML `width`/`height` attributes removed. Inline CSS `width` styles **preserved** (e.g. Ahrefs `width: 1%` on icon/count/view columns — destroying these collapses columns)
- **Images**: Only large images (no `width` attr OR `width` > 100px) get dimensions stripped + `max-width: 100%` + `height: auto`. Small images (`width` ≤ 100px, e.g. social icons at `width="50"`) are left untouched — stripping their dimensions makes them lose their size, and they're too small to cause overflow

### JavaScript Height Override (`forceAutoHeight`)

Runs before each height measurement. Calls `style.setProperty('height', 'auto', 'important')` on body and html elements. Needed because marketing emails (e.g. Nextdoor) inject `body { height: 100% !important }` in their `<style>` blocks, which locks the body to the WKWebView viewport height. Note: on iOS WKWebView this does NOT reliably override the body height (computed height still reports viewport), but the element-walk measurement technique bypasses this limitation.

---

## Platform-Specific Rendering

### Native (iOS/Android) -- InAppWebView

- Transparent background
- Vertical scroll disabled (parent Flutter `ScrollView` handles it)
- Horizontal scroll enabled (needed to pan zoomed content)
- **Pinch-to-zoom**: `supportZoom: true`, `enableViewportScale: true`
- Link interception via `shouldOverrideUrlLoading`:
  - `mailto:` -> callback to parent (copy/compose/opt-in)
  - `http(s)://` -> biometric auth required, then `launchUrl` externally
  - All other schemes -> blocked

#### Height Measurement (iOS WKWebView)

Height is measured by JS embedded in the HTML, pushed to Dart via `window.flutter_inappwebview.callHandler('heightUpdate', width, height)`. The Dart handler (registered in `onWebViewCreated`) computes a CSS transform scale factor and updates the `SizedBox`.

**Measurement technique: element walk** — The JS walks ALL descendant elements via `querySelectorAll('*')` and finds `Math.max(getBoundingClientRect().bottom)`. This is the **only** reliable height measurement on iOS WKWebView. All standard methods fail:

| Measurement | Failure mode on iOS |
|---|---|
| `body.scrollHeight` | Clamped to viewport height on first call (body locked by email CSS `height: 100%`) |
| `body.offsetHeight` | Always viewport height |
| `#measure div.getBoundingClientRect().height` | Clamped by parent body's fixed height |
| `#measure div.scrollHeight/offsetHeight` | Same clamping |
| `documentElement.scrollHeight` | Correct on first call, then causes infinite +50px growth (feedback loop with SizedBox padding) |
| **`max(child.getBoundingClientRect().bottom)`** | **Always correct** — individual elements report true rendered position regardless of parent overflow |

Measurements are taken at: immediate, +300ms, +1000ms, +2000ms, and via `ResizeObserver`. Only larger values are accepted (prevents late clamped measurements from shrinking the container).

**Debug logging** (`_debugHeight` flag, defaults to `kDebugMode`): When true, logs all measurement sources to the Flutter debug console as `[EMAIL_JS]` and `[EMAIL_HEIGHT]` lines. Useful when debugging rendering issues or building new sanitization rules.

### Web -- Sandboxed iframe

- Sandbox: `allow-scripts allow-same-origin` (NO `allow-popups`)
- Height via `postMessage({ type: 'emailHeightUpdate', height: h })`
- Links intercepted via DOM click listener -> `postMessage({ type: 'emailLinkClick', url })` -> Dart handler
- Scroll forwarding: iframe's `wheel` events -> `postMessage({ type: 'emailScrollForward', deltaY })` -> parent `Scrollable.jumpTo()` (zero-frame latency)
- Internal scroll disabled (`overflow: hidden` on html/body inside iframe)
- Zoom handled natively by the browser (Ctrl+/-, trackpad pinch)

### Biometric Guard

- All external HTTP(S) links require biometric authentication before opening
- 30-second recency window (no re-prompt within window)
- Web platform always allows (no biometric on web)
- Implementation: `lib/services/action_biometric_guard.dart`

---

## Known Issues & Root Causes

### Resolved (v1.0.6)

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| Emails squished into narrow column | `table { width:auto !important }` collapsed tables to content width | Removed `width:auto !important`; tables keep specified widths capped by `max-width:100%` |
| Multi-column rows broken | JS stripped `width` from `td`/`th` elements | JS preserves width attributes; no `max-width` override on cells |
| Images wrong size | JS removed ALL `width`/`height` from images | JS converts dimensions to inline styles capped by `max-width:100%` |
| Inline images stacked vertically | CSS forced `display:block` on all `<img>` | Removed `display:block` from img CSS rule |
| Float layouts broken | Sanitizer stripped all `float:left/right` | Removed float stripping (float is not a security concern) |
| Center-aligned emails off-center | Table `align="center"` had no effect after width stripping | JS detects `align="center"` and adds `margin:0 auto` |
| Horizontal buttons/text rendered vertically | `max-width:100% !important` on `div, p, span` forced inline-block elements to wrap; also applied via JS to `td`/`th` interfering with table layout | Removed `max-width` rule from div/p/span/section/article; removed `max-width` from td/th CSS and JS |
| Content not scaling on small screens | Viewport meta lacked `shrink-to-fit=yes`; fixed-width tables (600px) overflowed 375px phone screens and were clipped by `overflow-x: hidden` | Added `shrink-to-fit=yes, minimum-scale=0.25, maximum-scale=4.0` to viewport; changed `overflow-x` from `hidden` to `auto` |
| Pinch-to-zoom not working | InAppWebView had no explicit zoom settings; `disableHorizontalScroll: true` prevented panning zoomed content | Added `supportZoom: true`, `builtInZoomControls: true`, `displayZoomControls: false`; changed `disableHorizontalScroll` to `false` |
| Email body cut off below the fold on iOS (Nextdoor) | iOS WKWebView: `body.scrollHeight`, `getBoundingClientRect()`, `offsetHeight` all clamped to viewport height. Email CSS `body { height: 100% !important }` locked body to SizedBox initial estimate (~70% screen). `evaluateJavascript` return values unreliable. | Rewrote native height measurement: JS walks all descendant elements to find `max(getBoundingClientRect().bottom)`; pushes to Dart via `addJavaScriptHandler` (not `evaluateJavascript` return values); retries at 300ms/1s/2s + ResizeObserver; "only grow" guard |
| `docEl.scrollHeight` infinite growth loop | Each measurement increased SizedBox by +50px padding → viewport grew → `docEl.scrollHeight` reported new viewport height → next measurement grew again | Excluded `documentElement.scrollHeight` from height calculation; only use element-walk `maxChildBottom` |
| Ahrefs "View" buttons rendered vertically (V-i-e-w) | `word-break: break-word` on `td, th, a` reduced minimum content width to 1 character in table layout algorithm; `width: 1%` cells collapsed to near-zero | Changed to `overflow-wrap: break-word` — only breaks when content overflows, preserves minimum content width so cells auto-expand |
| Ahrefs Issues columns squeezed | `normalizeWidths()` JS set `style.width = 'auto'` on every `td`/`th`, destroying intentional `width: 1%` layout hints | `normalizeWidths()` now only strips HTML `width` attributes, preserves inline CSS `width` styles on cells |
| myQ logo rendered at full container width | CSS `div { max-width: 100% !important }` overrode the logo wrapper's `max-width: 105px` | Removed `max-width: 100% !important` from div/p/span/section/article entirely |
| myQ social icons stacked vertically | `normalizeWidths()` stripped `width="50"` from icon images and CSS added `display: block`, making each icon a block element | Only strip dimensions from images wider than 100px; removed `display: block` from img CSS rule and JS |

### Open / Future Work

| Issue | Priority | Status |
|-------|----------|--------|
| Tracker link detection & removal | Medium | Not started |
| Hidden content detection (e.g., invisible text for preheader) | Low | `display:none` preserved; no active stripping |
| Privacy beacon image detection (beyond 1px tracking pixels) | Medium | Not started |
| Sanitization stats/metrics (counts of stripped elements) | Low | Not started |
| Dark mode support for email HTML | Low | Not started |

---

## Progress Tracking

### Completed

- [x] Extract `HtmlSanitizerService` from `CommonService` (was 1,236-line kitchen-sink utility)
- [x] Fix A: Remove `width:auto !important` from table CSS
- [x] Fix B: Preserve table/cell/image dimensions in JS `normalizeWidths()`
- [x] Fix C: Remove forced `display:block` from images
- [x] Fix D: Stop stripping `float` CSS
- [x] Fix E: Center-aligned table support (`align="center"` -> `margin:0 auto`)
- [x] Fix F: Remove `max-width:100%` from div/p/span and td/th (broke inline-block horizontal layouts)
- [x] Fix G: Add `shrink-to-fit=yes` viewport meta for small screen auto-scaling
- [x] Fix H: Enable pinch-to-zoom on native InAppWebView
- [x] Fix I: Change `overflow-x` from `hidden` to `auto`
- [x] Fix J: Rewrite native height measurement — element walk + `addJavaScriptHandler` (iOS WKWebView fix)
- [x] Fix K: Change `word-break: break-word` to `overflow-wrap: break-word` on td/th/a (Ahrefs View button fix)
- [x] Fix L: Preserve inline CSS `width` styles on td/th in `normalizeWidths()` (Ahrefs columns fix)
- [x] Fix M: Remove `max-width: 100% !important` from div/p/span/section/article (myQ logo fix)
- [x] Fix N: Only strip dimensions from images > 100px; remove `display: block` from img (myQ social icons fix)
- [x] Fix O: Add `_debugHeight` flag for verbose JS measurement logging (debug builds only)
- [x] Delete dead code: `checkHtmlData()` (zero callers), `sanitizeEmailMessage()` (commented-out only)
- [x] Delete dead code: 120-line commented-out `_getHtmlContent()` in `view_email.dart`
- [x] Create this documentation

### Testing Checklist

Emails verified during v1.0.6 development:

- [x] Nextdoor newsletter (id 27284) -- full height renders on iOS, no cutoff below fold
- [x] Ahrefs Site Audit -- Issues columns correct width, "View" buttons horizontal
- [x] myQ marketing email -- logo constrained to 105px, social icons inline (not stacked)
- [ ] Marketing/newsletter emails -- tables fill specified width, not squished
- [ ] Multi-column layouts (Mailchimp-style) -- columns render side-by-side
- [ ] Emails with logos/images -- render at specified size, capped at viewport
- [ ] Email signatures with inline social icons -- render in a row, not stacked
- [ ] Float-based layouts (text wrapping around image) -- render correctly
- [ ] Horizontal button rows -- render side-by-side, not stacked
- [ ] Small phone screens (375px) -- wide emails auto-scale to fit
- [ ] Pinch-to-zoom -- zoom in/out smoothly, pan when zoomed
- [ ] Tablet/desktop -- no regression, content renders at full size
- [ ] Height measurement works correctly (native + web) -- no clipping
- [ ] Email list previews show correct stripped text
- [ ] Plain-text emails with URLs render clickable links
- [ ] Non-HTTPS images proxy through backend correctly
