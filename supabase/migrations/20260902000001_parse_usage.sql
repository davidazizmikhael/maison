-- Per-user daily parse counter: protects the Anthropic bill from abuse.
-- Written only by the parse-entry edge function (service role); clients
-- get no access at all (RLS enabled, no policies).
create table if not exists public.parse_usage (
  owner_id uuid not null references auth.users (id) on delete cascade,
  day date not null,
  count integer not null default 0,
  primary key (owner_id, day)
);
alter table public.parse_usage enable row level security;

create or replace function public.increment_parse_usage(uid uuid, on_day date)
returns integer
language sql
security definer
set search_path = public
as $$
  insert into public.parse_usage (owner_id, day, count)
  values (uid, on_day, 1)
  on conflict (owner_id, day)
  do update set count = parse_usage.count + 1
  returning count;
$$;
