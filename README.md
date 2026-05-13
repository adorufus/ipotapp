# ipotapp

ipotapp is a Flutter client for in-restaurant ordering: scan a table QR code, browse the menu, build a cart, and place orders against a JSON HTTP API. The UI uses a tabbed shell (menu, cart, orders), Riverpod for state, and Dio for networking. English and Chinese strings are maintained through Flutter gen-l10n.

The API base URL is **not** hard-coded in Dart. It is compiled in only via **`API_BASE_URL`** using `--dart-define-from-file=config.json` (see below). Order status **live updates** use **Supabase Realtime broadcast** on a per-table channel; the app needs **`SUPABASE_URL`** and **`SUPABASE_ANON_KEY`** in the same file. The local **`mock-api`** pushes those broadcasts using **`SUPABASE_SERVICE_ROLE_KEY`** in `mock-api/.env` (server-only; never ship that key in the Flutter app).

**Technical test note.** The assignment description did not specify which API base URL to use. This submission therefore targets a **self-hosted HTTP API** (deployed for reviewers) instead of an unspecified third-party endpoint. To run the app against that server, put the URL below in `config.json` as `API_BASE_URL`. The repo also includes a **`mock-api`** project if you prefer to run the same contract locally against MongoDB.

## Requirements

- Flutter SDK compatible with Dart `^3.11.5` (stable channel; CI uses `subosito/flutter-action` on stable).
- Node.js if you run the local `mock-api` server.

## Repository layout

- `lib/` — application code (screens, state, repositories, services, models).
- `mock-api/` — Express API on port 4000 (`/api/v1`) backed by MongoDB (Mongoose). Static menu data seeds automatically when collections are empty.
- `config.example.json` — template for local `config.json` (dart-define injection).
- `integration_test/` — widget integration tests (run headlessly with `flutter-tester` in CI).

## Architecture

The app follows a small layered structure inside `lib/`, with Riverpod as the single wiring layer between UI and IO.

**Composition.** `main.dart` requires non-empty compile-time **`API_BASE_URL`**, **`SUPABASE_URL`**, and **`SUPABASE_ANON_KEY`**, then calls **`Supabase.initialize`**, then builds `AppScope`, which creates the root `ProviderScope` and overrides `appConfigProvider` so every consumer sees one resolved API base URL. `MainApp` configures `MaterialApp` (theme, locale, gen-l10n delegates) and hosts `AppShellScreen` as the home route.

**UI.** Screens and widgets live under `lib/screens/` and `lib/components/`. The shell (`app_shell.screen.dart`) keeps three tabs in an `IndexedStack` so switching tabs does not reset subtree state. Menu flow splits QR capture, menu listing, and cart actions across dedicated widgets and local providers under `lib/screens/menu/`.

**State.** Global and cross-feature providers are grouped under `lib/state/` (`providers.dart` re-exports the main slices). `lib/state/core/` holds configuration, the shared `Dio` instance, HTTP facade, and connectivity helpers. Cart, checkout, navigation index, and locale each have their own files or subfolders. Screen-scoped controllers (for example QR scan) sit next to the screen under `providers/` or `controllers/` where the UI needs tight coupling.

**Data.** `lib/repositories/` call the backend through `DioHttpService` and map JSON into `lib/models/`. `lib/services/` adds behavior that is not a single REST resource: caching, building offline payloads, persisting pending orders, and coordinating flush when the device is back online (`order_outbound_sync.dart` and related store types).

**Localization.** User-visible strings come from ARB files code-generated into `lib/l10n/`; the active locale is driven by a Riverpod provider so the language control in the app bar stays in sync with `MaterialApp`.

## How to run the project

### 1. API base URL and Supabase (`config.json`)

1. Copy `config.example.json` to **`config.json`** in the **repository root** (same folder as `pubspec.yaml`). `config.json` is gitignored so your URLs and keys stay local.
2. Set **`API_BASE_URL`** to your backend root including `/api/v1`.
3. Set **`SUPABASE_URL`** to your project URL (for example `https://<project-ref>.supabase.co`) and **`SUPABASE_ANON_KEY`** to the **anon** public JWT from the Supabase dashboard. These are safe to embed in the client; they gate Realtime access together with your Supabase **Realtime authorization** settings.

**For reviewers / against the submitted API:** use this value for the HTTP API (Vercel):

`https://ipotserver.vercel.app/api/v1`

**For local development** (optional, if you run `mock-api` yourself):

- **This machine:** `http://localhost:4000/api/v1` (iOS Simulator, desktop, or `flutter-tester`).
- **Android emulator to host:** `http://10.0.2.2:4000/api/v1`.
- **Physical device on the same LAN:** `http://<your-computer-LAN-IP>:4000/api/v1`.

The JSON shape is a flat map of dart-define keys, for example:

```json
{
  "API_BASE_URL": "http://127.0.0.1:4000/api/v1",
  "SUPABASE_URL": "https://YOUR_PROJECT_REF.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_SUPABASE_ANON_JWT"
}
```

4. Run or build the Flutter app with:

```bash
flutter pub get
flutter run --dart-define-from-file=config.json
```

VS Code / Cursor: use the **ipotapp** launch configuration in `.vscode/launch.json`, which passes the same flag.

`main.dart` throws a clear error if `API_BASE_URL`, `SUPABASE_URL`, or `SUPABASE_ANON_KEY` is missing at compile time (for example if you run `flutter run` without `--dart-define-from-file=config.json`).

**Tests.** Unit tests under `test/` do not start `main()`. Integration tests initialize Supabase with a dummy project URL before pumping `AppScope` (see `integration_test/app_smoke_test.dart`).

### 2. Mock API (optional, for local backend)

Configure MongoDB and Supabase (never commit secrets):

1. Copy `mock-api/.env.example` to `mock-api/.env`.
2. Set `MONGODB_URI` (include a database name in the path before `?`, for example `.../ipotapp?retryWrites=...`).
3. Set **`SUPABASE_URL`** and **`SUPABASE_SERVICE_ROLE_KEY`** (service role from the Supabase dashboard). The server uses them only to call Realtime **broadcast** over HTTPS for `orders:<table_id>` channels; it does not replace MongoDB for menus or orders.
4. In the Supabase dashboard, ensure **Realtime** is enabled and clients are allowed to subscribe to **broadcast** on the channels this app uses (see Supabase Realtime authorization docs if subscriptions are denied).

From the repo root:

```bash
cd mock-api
npm install
npm run dev
```

The server listens on port 4000 by default (`PORT` in `.env` overrides). Optional: `npm run seed` runs only the seed step.

Match `API_BASE_URL` in `config.json` to where this server is reachable from your target device or emulator (see host notes above). Use the **same** Supabase project in `config.json` (`SUPABASE_URL` / `SUPABASE_ANON_KEY`) as in `mock-api/.env` so the app receives the broadcasts the API sends.

### 3. Localization code generation

ARB files live under `lib/l10n/`. After editing them:

```bash
flutter pub get
```

(or `flutter gen-l10n` per `l10n.yaml`).

## Tests and CI

```bash
flutter test
flutter analyze --fatal-infos
flutter test integration_test/ -d flutter-tester
```

Pull requests run analyze, unit tests, and integration tests on Ubuntu with the stable Flutter channel.

## Main dependencies

State and networking: `flutter_riverpod`, `dio`, `supabase_flutter`. UI helpers: `flutter_screenutil`. Device features: `qr_code_scanner`, `connectivity_plus`, `shared_preferences`. Localization: `flutter_localizations` and `intl`.
