# NSTU Medical Center - Web App

Professional Flutter Web frontend for the NSTU Medical Center system.

## Architecture

This repository now supports platform-separated frontends with a shared backend:

- `backend/backend_server` → Serverpod backend (unchanged)
- `mobile_app` → existing Flutter mobile app (current root app)
- `web_app` → new Flutter Web frontend

The web app uses the same backend client package:

- `../packages/backend_client`

## Backend API Configuration

Default URL is configured in `lib/core/config/app_config.dart`:

- `https://api.nstu-medical.com/`

Override at build/run time with:

- `--dart-define=SERVERPOD_URL=https://your-api-url/`

## Web Frontend Structure

`lib/` contains:

- `core/` config, constants, themes, responsive utilities
- `services/` API/auth/appointment services
- `models/` doctor, patient, appointment models
- `controllers/` auth and appointment controllers
- `pages/` home, login, dashboard, doctors, appointments, reports, admin
- `widgets/` navbar, sidebar, cards, common components

## Routing

Configured with `go_router` in `lib/core/config/app_router.dart`:

- `/home`
- `/login`
- `/dashboard` (auto-redirects to role dashboard)
- `/patient/dashboard`
- `/patient/appointments`
- `/patient/reports`
- `/doctor/dashboard`
- `/admin/dashboard`
- `/lab/dashboard`
- `/dispenser/dashboard`

## Role-aware and guarded access

- Patient, Doctor, Admin, Lab, and Dispenser roles are supported.
- Private routes are protected; unauthenticated users are redirected to `/login`.
- Authenticated users are automatically redirected to their role-specific dashboard.
- Sidebar and top navigation adapt based on logged-in role.

## Endpoint-backed role dashboards

- Patient: doctors, prescriptions/appointments, and medical reports.
- Doctor: home summary + patient prescription list.
- Admin: overview + analytics chart + recent audit table.
- Lab: today summary + latest result history.
- Dispenser: stock table + dispense history.

## Run & Build

### Development

`flutter run -d chrome`

### Production build

`flutter build web`

Output directory:

- `build/web`

## Deployment Targets

The `build/web` output can be deployed to:

- Netlify
- Vercel
- Firebase Hosting
- Nginx (static hosting)
