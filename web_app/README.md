# NSTU Medical Center — Web App

Flutter Web frontend for the NSTU Medical Center system.

## Overview

This app lives in `web_app/` and connects to the same Serverpod backend used by other clients.

Related directories:

- `backend/backend_server` → Serverpod backend
- `packages/backend_client` → shared generated API client
- `web_app` → this Flutter Web application

## Requirements

- Flutter SDK (stable)
- Dart SDK (comes with Flutter)
- Running backend API (Serverpod)

## Backend configuration

The web app supports a configurable backend URL.

- Default behavior: uses app config from `lib/core/config/app_config.dart`
- Override at runtime/build time:

`--dart-define=SERVERPOD_URL=https://your-api-url/`

For local development, a typical value is:

`--dart-define=SERVERPOD_URL=http://localhost:8080/`

## Install dependencies

From `web_app/`:

`flutter pub get`

## Run (development)

From `web_app/`:

`flutter run -d chrome --dart-define=SERVERPOD_URL=http://localhost:8080/`

## Build (production)

From `web_app/`:

`flutter build web --release --dart-define=SERVERPOD_URL=https://api.nstu-medical.com/`

Build output:

- `web_app/build/web`

## Main app structure

`lib/` includes:

- `core/` → configuration, theme, routing, constants
- `controllers/` → auth and feature controllers
- `models/` → frontend models
- `pages/` → role-based screens and modules
- `services/` → API/business access
- `widgets/` → reusable UI components

## Routing and role access

Routing is configured with `go_router`.

- Unauthenticated users are redirected to `/login`
- Authenticated users are redirected to role-specific dashboards
- Roles supported: Patient, Doctor, Admin, Lab, Dispenser

## Troubleshooting

- If login/API calls fail, verify backend is running on the same URL passed via `SERVERPOD_URL`.
- If browser build cache causes stale behavior, hard refresh the page (`Ctrl + F5`).
- If generated API models mismatch backend, regenerate backend/client code and run `flutter pub get` again.
