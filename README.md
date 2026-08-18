<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="wordmark-dark.png">
    <img src="wordmark-light.png" alt="Schengen Guard+" height="40">
  </picture>
</h1>

A free web app for tracking Schengen Area visits and staying compliant with the 90/180-day short-stay rule. Live, installable as an app.

This is one of two identical-feeling sibling apps — same UI, same calculation engine, both free — that differ in exactly one place: where your data lives.

- **This repo (Schengen Guard Anywhere)** — sign in once, and your trips sync across every device via a Supabase-backed account.
- **[Schengen Guard](https://github.com/g59dtjys8y-cmd/schengen-guard)** — no account, no server; trips are stored only on your device and never leave it.

Pick whichever matches how you want your data handled. Everything else about the app — every feature below — is the same either way.

**Live app:** https://g59dtjys8y-cmd.github.io/schengen-guard-anywhere/ (needs your own Supabase project configured — see below)

## Features

- **Home dashboard** — an arc progress ring shows days left of your rolling 90, with a gold EU-star marker that travels around it and shifts color as the limit approaches. Below it, a "Quick check" card lets you check compliance as of any reference date, and — once you have a trip logged — an "Active trip" or "Next trip" card surfaces the most relevant one, with the country flag and day count front and center, matching how trips are shown on the Trips tab.
- **Tabbed navigation** — Home, Calendar, Trips, and Settings, with a fixed bottom tab bar for quick switching between views.
- **Safe Check and Log a Trip** — the Calendar tab leads with this: pick a country, then tap an entry date and an exit date on the calendar to log (or edit) a stay, with a side trip markable on the same screen. Every date also shows your remaining day allowance as of that day, with past/active, planned, overstay, and excluded days visually distinguished.
- **Live compliance preview** — as you pick entry/exit dates, immediate feedback shows whether that stay would keep you compliant and how many days of margin you'd have, *before* you save it, with concrete alternate-date suggestions if it wouldn't.
- **Full Calendar View** — a collapsed section at the bottom of the Calendar tab (so it stays out of the way of logging a trip): a year-by-year nav, a running total for the year, and a 12-month grid you can share as a passport-stamp-styled recap card.
- **Countries visited** — the Trips tab opens with a stamp-collection card: a progress bar toward all 29 Schengen countries and a peek at the most recently visited ones (flags + a "Last stamped" caption). Tap through to a full passport-stamp grid of every country, stamped or not.
- **90/180 overview** — a collapsed section below that (so it stays out of the way of your trip history) — expand it for the compliance chart (year nav, a within-limits/14-days-or-fewer trend line) and a month-by-month breakdown.
- **Trip list with status** — a "+" to add a new trip; a "DONE" stamp once a trip is in the past, or an Active or Planned tag otherwise; the 4 most-recently-completed stays stay visible, anything older collapses into one expandable "Earlier trips" group; edit or remove any trip inline; an optional note on every trip.
- **Side trips** — mark days within a stay as spent outside Schengen (e.g. a UK leg); they're excluded from your 90-day count, shown with a diagonal-hatch pattern on the calendar, a "Side trip: N days" badge on the trip card, and distinctly in the calculation breakdown.
- **"How is this calculated?"** — a day-by-day breakdown of the rolling 180-day window behind any number, with consecutive same-status days collapsed into readable date ranges.
- **Passport control** — a per-trip view of the rolling 180-day window for a chosen date, handy to show a border official alongside your passport stamps.
- **Overstay warnings & overlap detection** — flagged directly against the trip responsible, with the exact date and running total.
- **CSV / print export** — for handing trip history to a border official or visa office, separate from the JSON backup.
- **Notification thresholds** — opt in (from Settings) to a browser notification when your days remaining hits 14, 7, or 3, with a warning (amber, "!") or danger (red, "!") icon depending on how close you are.
- **Light, dark & auto themes** — a per-device preference, not synced.
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
| `fonts/source-serif-4/` | Self-hosted font files + OFL license |
| `scripts/` | Dev-only checks — see below |

## Dev tooling & checks

There's no build step for the app itself, but a small set of dev-only Node scripts (see `package.json`) catch the most likely ways a push breaks something:

| Command | What it checks |
|---|---|
| `npm run check:html` | `index.html` tags are validly nested (a real stack-based check, not just an open/close count) |
| `npm run check:js` | `script.js` parses (`node --check`) |
| `npm run check:parity -- <path-to-sibling-checkout>` | Diffs element ids against [Schengen Guard](https://github.com/g59dtjys8y-cmd/schengen-guard) so a feature added to one app and forgotten in the other gets flagged, not shipped silently. Intentional one-sided ids (e.g. the sign-in screen, which only exists here) are documented in `scripts/parity-allowlist.json`. |
| `npm run smoke` | Boots the app in headless Chromium and confirms every primary tab renders with zero console errors |
| `npm run check` | Runs the HTML, JS, and smoke checks together |

`.github/workflows/checks.yml` runs all of the above (plus the parity check against a live checkout of the sibling repo) on every push and pull request.

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
     excluded_ranges jsonb not null default '[]'::jsonb,
     note text not null default ''
   );

   alter table trips enable row level security;

   create policy "Users manage own trips" on trips for all
     using (auth.uid() = user_id) with check (auth.uid() = user_id);
   ```
   Already have a `trips` table from before the `note` column existed? Add it with:
   ```sql
   alter table trips add column if not exists note text not null default '';
   ```
3. In **Authentication → Providers**, confirm Email is enabled. Optionally turn off "Confirm email" for simpler local testing.
4. In `script.js`, replace `SUPABASE_URL` and `SUPABASE_KEY` with your own project's values (found under **Settings → API**).
5. Serve the files with any static host — GitHub Pages, Netlify, Vercel, or just open `index.html` directly.

## Rule reference

The Schengen short-stay rule allows non-EU visitors to stay up to 90 days in any rolling 180-day period across the Schengen Area. This app is a personal tracking tool, not immigration advice — see the in-app Privacy & Terms screen for the full disclaimer.

## License

Personal project — no license specified. Source Serif 4 is licensed separately under the SIL Open Font License (see `fonts/source-serif-4/OFL.txt`).
