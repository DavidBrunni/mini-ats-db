-- Run in Supabase SQL Editor.
-- Candidate comments and activity log for Mini-ATS.

-- Comments on candidates (admin and customer can add/view).
create table if not exists public.candidate_comments (
  id uuid primary key default gen_random_uuid(),
  candidate_id uuid not null references public.candidates(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_candidate_comments_candidate_id
  on public.candidate_comments(candidate_id);

alter table public.candidate_comments enable row level security;

-- Users can read comments for candidates they can read (same org as job).
create policy "Read comments for org candidates"
  on public.candidate_comments for select
  using (
    candidate_id in (
      select c.id from public.candidates c
      join public.jobs j on j.id = c.job_id
      where j.organization_id in (
        select organization_id from public.profiles where id = auth.uid()
      )
    )
  );

-- Users can insert comments for candidates in their org.
create policy "Insert comments for org candidates"
  on public.candidate_comments for insert
  with check (
    auth.uid() = user_id
    and candidate_id in (
      select c.id from public.candidates c
      join public.jobs j on j.id = c.job_id
      where j.organization_id in (
        select organization_id from public.profiles where id = auth.uid()
      )
    )
  );

-- Activity log: who moved a candidate when.
create table if not exists public.candidate_activities (
  id uuid primary key default gen_random_uuid(),
  candidate_id uuid not null references public.candidates(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  from_stage text,
  to_stage text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_candidate_activities_candidate_id
  on public.candidate_activities(candidate_id);

alter table public.candidate_activities enable row level security;

-- Users can read activities for candidates in their org.
create policy "Read activities for org candidates"
  on public.candidate_activities for select
  using (
    candidate_id in (
      select c.id from public.candidates c
      join public.jobs j on j.id = c.job_id
      where j.organization_id in (
        select organization_id from public.profiles where id = auth.uid()
      )
    )
  );

-- Only backend/service or authenticated user can insert (when they move a candidate).
create policy "Insert activities for org candidates"
  on public.candidate_activities for insert
  with check (
    auth.uid() = user_id
    and candidate_id in (
      select c.id from public.candidates c
      join public.jobs j on j.id = c.job_id
      where j.organization_id in (
        select organization_id from public.profiles where id = auth.uid()
      )
    )
  );
