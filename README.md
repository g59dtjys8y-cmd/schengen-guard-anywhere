<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="wordmark-dark.png">
    <img src="wordmark-light.png" alt="Schengen Guard+" height="40">
  </picture>
</h1>

A web app for tracking Schengen Area visits and staying compliant with the 90/180-day short-stay rule. Live, installable as an app, and synced to your account — sign in once and your trips follow you to every device.

This is the cloud-synced sibling of [Schengen Guard](https://github.com/g59dtjys8y-cmd/schengen-guard), which shares the same UI and calculation engine but stores trips only on-device (IndexedDB, no account, no server). Pick whichever storage model fits — this repo trades full local privacy for cross-device sync.

**Live app:** https://g59dtjys8y-cmd.github.io/schengen-guard-anywhere/ (needs your own Supabase project configured — see below)

## Features

- **Home dashboard** — an arc progress ring shows days left of your rolling 90, with a gold EU-star marker that travels around it and shifts color as the limit approaches. Below it, a "Quick check" card lets you check compliance as of any reference date, and — once you have a trip logged — a "Trip in progress" or "Next trip" panel surfaces the most relevant one.
- **Tabbed navigation** — Home, Trips, and Settings, with a fixed bottom tab bar for quick switching between views.
- **Safe Trip Checker** — on the Trips tab, tap a country and candidate entry/exit dates on an embedded calendar to see live whether that stay would keep you compliant and how many days of margin you'd have, *before* you save it, with concrete alternatives if it wouldn't.
- **Trip list with status** — logged stays show a "DONE" stamp once they're in the past, and an Active or Planned tag otherwise; edit or remove any trip inline.
- **Side trips** — mark days within a stay as spent outside Schengen (e.g. a UK leg); they're excluded from your 90-day count, shown with a diagonal-hatch pattern on the calendar, a "Side trip: N days" badge on the trip card, and distinctly in the calculation breakdown — add, edit, or remove them from the Trip Checker.
- **"How is this calculated?"** — a day-by-day breakdown of the rolling 180-day window behind any number, with consecutive same-status days collapsed into readable date ranges.
- **One calendar for everything** — the same tap-an-entry-date-then-an-exit-date interaction logs or edits a stay, drives the Safe Trip Checker, and marks a side trip. Every date also shows your remaining day allowance as of that day, with past/active, planned, overstay, and excluded days visually distinguished.
- **Overstay warnings & overlap detection** — flagged directly against the trip responsible, with the exact date and running total.
- **CSV / print export** — for handing trip history to a border official or visa office, separate from the JSON backup.
- **Notification thresholds** — opt in (from Settings) to a browser notification when your days remaining hits 14, 7, or 3.
- **Light, dark & auto themes**, and **English / Chinese / Japanese** language support (UI fully translated in English; zh/ja ship as a framework with English fallback pending real translations) — both are per-device preferences, not synced.
- **Account sync via Supabase** — sign in with email/password; your trips are stored in a Supabase Postgres database tied to your account, scoped by Row Level Security, and available on every device you sign into. You're automatically signed out if the app hasn't been opened in 1 day.
- **JSON export/import** — a supplementary local backup and account-to-account data-migration tool, not required for normal use since your account already syncs everything.
- **Installable app (PWA)** — add it to your phone's home screen; the app shell caches for fast loads, though trip data itself needs a connection to load or save.
- **Legal-risk disclaimers** — first-run modal, a persistent Home footer line, and a dedicated Privacy & Terms screen, all linking to the EU's official short-stay calculator.
- **All 29 Schengen countries** — pick from a dropdown, defaulting to Spain.

## Tech stack

- Plain HTML, CSS, and JavaScript — no build step, no framework.
- Self-hosted [Source Serif 4](https://github.com/adobe-fonts/source-serif) (SIL OFL, see `fonts/source-serif-4/OFL.txt`) in a light-first "Broadsheet" design system driven by CSS custom properties.
- [Supabase](https://supabase.com) for authentication and the Postgres database (a `trips` table, scoped per-user with Row Level Security).
- A web app manifest and service worker for PWA installability (app shell only — trip data is never cached offline).

## Project files

| File | Purpose |
|---|---|
| `index.html` | Page structure and layout |
| `style.css` | All styling, including self-hosted `@font-face` rules |
| `script.js` | App logic — date math, calendar rendering, Supabase auth + storage, export/import |
| `manifest.json` | PWA metadata (name, icons, theme colors) |
| `sw.js` | Service worker for app-shell offline fallback and installability |
| `icon-192.png` / `icon-512.png` | App icons |
| `i18n/*.json` | Per-locale UI strings (`en` complete; `zh`/`ja` are placeholders with English fallback) |
| `fonts/source-serif-4/` | Self-hosted font files + OFL license |

## Running it yourself / setting up your own database

1. Create a free project at [supabase.com](https://supabase.com).
2. In the SQL editor, run:
   ```sql
   create table trips (
     id uuid primary key default gen_random_uuid(),
     user_id uuid references auth.users(id) default auth.uid(),
     start_date date not null,
     end_date date not null,
     country text,
     excluded_ranges jsonb not null default '[]'::jsonb
   );

   alter table trips enable row level security;

   create policy "Users manage own trips" on trips for all
     using (auth.uid() = user_id) with check (auth.uid() = user_id);
   ```
3. In **Authentication → Providers**, confirm Email is enabled. Optionally turn off "Confirm email" for simpler local testing.
4. In `script.js`, replace `SUPABASE_URL` and `SUPABASE_KEY` with your own project's values (found under **Settings → API**).
5. Serve the files with any static host — GitHub Pages, Netlify, Vercel, or just open `index.html` directly.

## Rule reference

The Schengen short-stay rule allows non-EU visitors to stay up to 90 days in any rolling 180-day period across the Schengen Area. This app is a personal tracking tool, not immigration advice — see the in-app Privacy & Terms screen for the full disclaimer.

## License

Personal project — no license specified. Source Serif 4 is licensed separately under the SIL Open Font License (see `fonts/source-serif-4/OFL.txt`).
