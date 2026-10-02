-- ============================================================================
-- Schengen Guard Anywhere — multiple people ("travellers")
-- RUN THIS IN THE SUPABASE SQL EDITOR *BEFORE* DEPLOYING THE APP UPDATE.
-- (The updated app reads the travellers table on sign-in; until this has run it
-- shows "the database needs the travellers step" on the sign-in screen instead
-- of loading trips.)
--
-- Safe to run more than once. It runs as one transaction: if any statement
-- fails, nothing is changed.
--
-- Before running, check the real name of your trips policy:
--   select policyname from pg_policies where tablename = 'trips';
-- This script assumes "Users manage own trips" (from the README). If yours is
-- named differently, change the `drop policy` line below to match.
-- ============================================================================

begin;

-- 1. People table, scoped to the signed-in user.
create table if not exists travellers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 20),
  colour text not null,
  created_at timestamptz not null default now()
);
create unique index if not exists travellers_user_name_unique on travellers (user_id, lower(btrim(name)));

alter table travellers enable row level security;
drop policy if exists "own travellers" on travellers;
create policy "own travellers" on travellers
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- 2. A default traveller ("Me") for every account that already has trips.
insert into travellers (user_id, name, colour)
select distinct t.user_id, 'Me', 'teal' from trips t
where t.user_id is not null
  and not exists (select 1 from travellers v where v.user_id = t.user_id);

-- 3. Link every trip to a traveller; group_id links stays saved for several people at once.
alter table trips add column if not exists traveller_id uuid references travellers(id) on delete cascade;
alter table trips add column if not exists group_id uuid;

update trips t set traveller_id = (
  select v.id from travellers v where v.user_id = t.user_id order by v.created_at limit 1
)
where t.traveller_id is null;

-- If this next line fails with "contains null values", some trips have no user_id
-- (they're already invisible to everyone under RLS). Find them with
--   select * from trips where traveller_id is null;
-- and delete or reassign them, then run the script again.
alter table trips alter column traveller_id set not null;
create index if not exists trips_traveller_id_idx on trips (traveller_id);

-- 4. Trips stay scoped by user_id, and can only point at one of your own travellers.
drop policy if exists "Users manage own trips" on trips;
create policy "Users manage own trips" on trips for all
  using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and exists (select 1 from travellers v where v.id = traveller_id and v.user_id = auth.uid())
  );

commit;

-- Quick check afterwards (should return one row per account, all with 0 orphan trips):
--   select v.user_id, count(distinct v.id) as travellers,
--          (select count(*) from trips t where t.user_id = v.user_id and t.traveller_id is null) as orphan_trips
--   from travellers v group by v.user_id;
