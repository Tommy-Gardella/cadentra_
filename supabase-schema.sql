-- =============================================
-- Cadentra — Supabase Database Schema
-- Run this in your Supabase project SQL editor
-- =============================================

-- Folders table
create table public.folders (
  id         uuid default gen_random_uuid() primary key,
  user_id    uuid references auth.users(id) on delete cascade not null,
  name       text not null,
  created_at timestamptz default now()
);

-- Plans table
create table public.plans (
  id         uuid default gen_random_uuid() primary key,
  user_id    uuid references auth.users(id) on delete cascade not null,
  folder_id  uuid references public.folders(id) on delete set null,
  name       text not null,
  plan_json  jsonb not null,
  created_at timestamptz default now()
);

-- Row Level Security (users can only see their own data)
alter table public.folders enable row level security;
alter table public.plans   enable row level security;

create policy "Users manage own folders"
  on public.folders for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users manage own plans"
  on public.plans for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
