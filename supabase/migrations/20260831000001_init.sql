-- Maison v1 schema: homes, records, reminders + RLS + storage.

create table public.homes (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  address text not null,
  -- {type, bedrooms, bathrooms, garage, basement} as structured by the AI
  profile jsonb,
  created_at timestamptz not null default now()
);

create table public.records (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  owner_id uuid not null references auth.users (id) on delete cascade,
  kind text not null check (kind in ('appliance', 'receipt', 'service')),
  title text not null,
  subtitle text,
  room text,
  cost numeric(12, 2),
  vendor text,
  model_serial text,
  warranty_until date,
  return_by date,
  manual_found boolean not null default false,
  raw_input text,
  photo_path text, -- storage object path in the 'captures' bucket
  ai_confidence text check (ai_confidence in ('high', 'medium', 'low')),
  created_at timestamptz not null default now()
);

create table public.reminders (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  owner_id uuid not null references auth.users (id) on delete cascade,
  record_id uuid references public.records (id) on delete cascade,
  title text not null,
  detail text,
  due_on date not null,
  seasonal boolean not null default false,
  done_at timestamptz,
  created_at timestamptz not null default now()
);

create index records_home_idx on public.records (home_id, created_at desc);
create index reminders_home_due_idx on public.reminders (home_id, due_on) where done_at is null;

-- Row-level security: every row is visible and writable only to its owner.
alter table public.homes enable row level security;
alter table public.records enable row level security;
alter table public.reminders enable row level security;

create policy "own homes" on public.homes
  for all using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "own records" on public.records
  for all using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "own reminders" on public.reminders
  for all using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

-- Private bucket for nameplate/receipt photos, scoped per user by folder prefix.
insert into storage.buckets (id, name, public)
values ('captures', 'captures', false);

create policy "own captures read" on storage.objects
  for select using (
    bucket_id = 'captures'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "own captures write" on storage.objects
  for insert with check (
    bucket_id = 'captures'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "own captures delete" on storage.objects
  for delete using (
    bucket_id = 'captures'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
