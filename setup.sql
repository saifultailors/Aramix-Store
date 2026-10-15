-- Supabase > SQL Editor এ এই পুরো লেখাটা পেস্ট করে Run দিন (একবারই)

create table if not exists public.apps (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name text not null,
  developer text not null default '',
  category text not null default 'অন্যান্য',
  description text not null default '',
  version text not null default '',
  rating numeric(2,1) not null default 4.5,
  size text not null default '',
  icon_url text not null default '',
  screenshots text[] not null default '{}',
  file_url text not null default '',
  downloads integer not null default 0,
  published boolean not null default true
);

alter table public.apps enable row level security;

-- সবাই অ্যাপের তালিকা দেখতে পারবে
drop policy if exists "public read apps" on public.apps;
create policy "public read apps" on public.apps for select using (true);

-- শুধু লগইন করা অ্যাডমিন যোগ/এডিট/মুছতে পারবে
drop policy if exists "admin write apps" on public.apps;
create policy "admin write apps" on public.apps for all to authenticated
  using (true) with check (true);

-- ডাউনলোড সংখ্যা বাড়ানোর ফাংশন (সবাই ব্যবহার করতে পারবে, শুধু +১ করে)
create or replace function public.add_download(app_id uuid)
returns void language sql security definer set search_path = public as $$
  update public.apps set downloads = downloads + 1 where id = app_id;
$$;
grant execute on function public.add_download(uuid) to anon, authenticated;

-- ছবি ও সফটওয়্যার ফাইল রাখার জায়গা
insert into storage.buckets (id, name, public)
values ('app-files', 'app-files', true)
on conflict (id) do nothing;

drop policy if exists "public read files" on storage.objects;
create policy "public read files" on storage.objects for select
  using (bucket_id = 'app-files');

drop policy if exists "admin upload files" on storage.objects;
create policy "admin upload files" on storage.objects for insert to authenticated
  with check (bucket_id = 'app-files');

drop policy if exists "admin update files" on storage.objects;
create policy "admin update files" on storage.objects for update to authenticated
  using (bucket_id = 'app-files');

drop policy if exists "admin delete files" on storage.objects;
create policy "admin delete files" on storage.objects for delete to authenticated
  using (bucket_id = 'app-files');
