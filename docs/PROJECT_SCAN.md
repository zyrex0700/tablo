# Project Scan — Tablo Rebuild

## Snapshot
- **Stack:** Flutter + GetX + flutter_map (web-first rebuild).
- **Direction:** Persian/RTL-first UI with custom `IRANYekan` font.
- **Current maturity:** Foundation and two core pages are implemented (`/` and `/billboards`) with live API reads.

## What currently exists

### 1) App shell & routing
- App bootstrap is minimal and clean via `TabloApp`.
- `GetMaterialApp` is configured with:
  - RTL enforced globally
  - Farsi locale/fallback locale
  - central route table in `AppPages`
- Current routes:
  - `/` home
  - `/billboards`
  - `/magazine` (placeholder)
  - `/contact-us` (placeholder)

### 2) Home module
- `HomeController` fetches and manages five data streams:
  - provinces
  - map billboards
  - party billboards
  - testimonials
  - brands
- Each stream has dedicated loading + error observables.
- `HomeView` already renders:
  - top nav
  - map section
  - provinces carousel
  - main banner
  - party billboard section
  - testimonials section
- Brand section code exists but is currently commented out in the view.

### 3) Billboards module
- `BillboardsController` supports:
  - list loading
  - province filter
  - city text filter
- `BillboardsView` contains:
  - KPI bar
  - filter sidebar
  - responsive-ish grid of billboard cards

### 4) Design system baseline
- Shared theme under `AppTheme` with:
  - brand color tokens
  - Material 3 enabled
  - rounded component language (`15` radius)
  - consistent button/input/chip defaults

## Strengths observed
- Good separation of concerns at this stage (routes/bindings/controllers/views/models).
- API parsing is defensive (null-safe to string conversions, tryParse for doubles).
- User-facing errors are generally surfaced rather than silently ignored.
- Project direction is aligned with README roadmap.

## Key gaps / risks
1. **No service/repository abstraction yet**
   - Networking is embedded directly in controllers, which will grow hard to test and maintain.

2. **No automated tests for business behavior**
   - `test/widget_test.dart` is still default scaffold-level.

3. **Inconsistent HTTP usage patterns**
   - Some requests use timeout, others do not.
   - Error messages and parsing branches are duplicated across controllers.

4. **Heavy HomeView**
   - A single large widget file handling many sections increases iteration cost.

5. **Small data-mapping issue candidate**
   - `BillboardItem.rentLabel` falls back to `'1'` when `monthlyRent` is empty, which is likely placeholder behavior and may create misleading UI.

## Recommended next steps (ordered)
1. Create a lightweight `ApiClient` + feature repositories (`home_repository`, `billboards_repository`).
2. Extract reusable request/error handling helpers (result type or typed failure model).
3. Split `home_view.dart` into section widgets (`home_sections/...`) to make UI iteration faster.
4. Re-enable/finalize brands section once the API contract is confirmed.
5. Add first tests:
   - model mapping unit tests
   - controller happy-path + error-path tests with mocked HTTP
6. Replace temporary fallback logic in rent label and define formatting rules for price/unit display.

## Local checks run during scan
- Repository status inspected (`git status --short --branch`).
- File inventory sampled (`rg --files`, `rg --files lib`).
- Core app files reviewed (README, pubspec, routing, controllers, views, models, theme).
- Tooling availability check: `flutter --version` failed in this environment (`flutter` not installed), so runtime checks/analyze/tests could not be executed here.

## Suggested immediate execution plan for next coding turn
- **Phase A (infra):** add repository layer + dependency wiring in bindings.
- **Phase B (quality):** add controller tests for billboards filtering and API failure handling.
- **Phase C (UI):** modularize home sections and re-activate brands row with loading/error states.
