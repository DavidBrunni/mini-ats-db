-- Run this in the Supabase SQL Editor.
-- Dashboard expects: profiles (id, organization_id) and jobs (id, organization_id, title, created_at).

-- Profile per user; id matches auth.users(id). Get organization_id from here.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  organization_id uuid not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Jobs belong to an organization (no user_id).
create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  title text not null,
  created_at timestamptz not null default now()
);

alter table public.jobs enable row level security;

-- Only allow access to jobs in the same organization as the user's profile.
create policy "Users can read jobs in own organization"
  on public.jobs for select
  using (
    organization_id in (
      select organization_id from public.profiles where id = auth.uid()
    )
  );

create policy "Users can insert jobs in own organization"
  on public.jobs for insert
  with check (
    organization_id in (
      select organization_id from public.profiles where id = auth.uid()
    )
  );

create policy "Users can update jobs in own organization"
  on public.jobs for update
  using (
    organization_id in (
      select organization_id from public.profiles where id = auth.uid()
    )
  );

create policy "Users can delete jobs in own organization"
  on public.jobs for delete
  using (
    organization_id in (
      select organization_id from public.profiles where id = auth.uid()
    )
  );
