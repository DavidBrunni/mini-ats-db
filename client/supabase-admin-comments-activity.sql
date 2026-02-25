-- Run in Supabase SQL Editor AFTER supabase-comments-activity.sql.
-- Lets admins read and add comments/activity for any org's candidates.

-- Comments: admin can read and insert for any candidate
create policy "Admin read all comments"
  on public.candidate_comments for select
  using (
    (select role from public.profiles where id = auth.uid()) = 'admin'
  );

create policy "Admin insert any comment"
  on public.candidate_comments for insert
  with check (
    (select role from public.profiles where id = auth.uid()) = 'admin'
    and auth.uid() = user_id
  );

-- Activity: admin can read and insert for any candidate
create policy "Admin read all activities"
  on public.candidate_activities for select
  using (
    (select role from public.profiles where id = auth.uid()) = 'admin'
  );

create policy "Admin insert any activity"
  on public.candidate_activities for insert
  with check (
    (select role from public.profiles where id = auth.uid()) = 'admin'
    and auth.uid() = user_id
  );
