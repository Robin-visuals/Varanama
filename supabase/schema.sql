-- VaraNama schema for Supabase PostgreSQL. Run in the Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (char_length(username) between 3 and 24),
  xp integer not null default 0 check (xp >= 0),
  pro_until timestamptz,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);


create or replace function public.set_username(p_username text)
returns void language plpgsql security definer set search_path=public as $$
declare uid uuid:=auth.uid(); clean text:=trim(p_username);
begin
 if uid is null then raise exception 'Sign in required'; end if;
 if clean is null or char_length(clean)<3 or char_length(clean)>24 or clean !~ '^[[:alnum:]_. -]+$' then raise exception 'Username must be 3–24 allowed characters'; end if;
 if exists(select 1 from public.profiles where lower(username)=lower(clean) and id<>uid) then raise exception 'That username is already taken'; end if;
 update public.profiles set username=clean where id=uid;
 if not found then raise exception 'Profile not found'; end if;
end; $$;
grant execute on function public.set_username(text) to authenticated;

create table if not exists public.places (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_bn text,
  aliases text[] not null default '{}',
  area text not null default 'Dhaka Division',
  lat double precision,
  lon double precision,
  map_label text,
  status text not null default 'pending' check (status in ('pending','approved','rejected','duplicate')),
  submitted_by uuid references public.profiles(id) on delete set null,
  canonical_place_id uuid references public.places(id),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles(id)
);

-- Starter locations shared by all visitors. The UUIDs match the frontend's starter IDs.
insert into public.places(id,name,name_bn,aliases,area,status) values
('4a157817-0562-5d37-824c-b5e8e12e26f3'::uuid,'Farmgate','ফার্মগেট',ARRAY['Farm Gate']::text[],'Tejgaon, Dhaka','approved'),
('60653d87-6aa8-57fa-9f3a-efad5c608a7a'::uuid,'Gulistan','গুলিস্তান',ARRAY['Gulistan More']::text[],'Dhaka','approved'),
('4371e1e4-2ea8-55bc-9e39-7df0e3b3472f'::uuid,'Iskaton','ইস্কাটন',ARRAY['Eskaton', 'Ishkaton']::text[],'Ramna, Dhaka','approved'),
('58bd5043-c92e-56ee-a1e1-0feb0f0dfc34'::uuid,'Mohakhali','মহাখালী',ARRAY['Mohakhali Bus Terminal']::text[],'Dhaka','approved'),
('0f8849f0-8a63-5c8a-9411-c1ceb8ad03b3'::uuid,'Shahbagh','শাহবাগ',ARRAY['Shahbag']::text[],'Dhaka','approved'),
('c899f4e3-6628-57be-b9fc-c2d498a6f524'::uuid,'Motijheel','মতিঝিল','{}'::text[],'Dhaka','approved'),
('b64403d2-01f9-5003-b822-93b34ad367b9'::uuid,'Dhanmondi','ধানমন্ডি',ARRAY['Dhanmondi 27']::text[],'Dhaka','approved'),
('0821536e-4fb4-5fe6-b9c6-7e441f45bb3d'::uuid,'Mirpur 10','মিরপুর ১০',ARRAY['Mirpur-10', 'Mirpur Ten']::text[],'Mirpur, Dhaka','approved'),
('1e0df229-c2aa-57ad-a474-b07d3e5f0c40'::uuid,'Uttara','উত্তরা',ARRAY['Uttara Sector']::text[],'Dhaka','approved'),
('d1ce4b09-2dcc-5379-aaba-5caea880b7ef'::uuid,'Sayedabad','সায়েদাবাদ',ARRAY['Saidabad']::text[],'Dhaka','approved'),
('16c7e1eb-e138-5df7-bcf5-b03f8ae46aba'::uuid,'Gabtoli','গাবতলী',ARRAY['Gabtoli Bus Terminal']::text[],'Dhaka','approved'),
('51da09f0-8e74-5f4e-b7b2-f2900a4a2d0b'::uuid,'Jatrabari','যাত্রাবাড়ী','{}'::text[],'Dhaka','approved'),
('f0e052ef-ae9d-588d-aee5-0b7d09278261'::uuid,'Badda','বাড্ডা',ARRAY['Badda Link Road']::text[],'Dhaka','approved'),
('7d7f7fec-6dee-501e-8289-9592f5223a77'::uuid,'Rampura','রামপুরা','{}'::text[],'Dhaka','approved'),
('b0ae6b78-0f6f-5a17-8fea-1e6759352504'::uuid,'Banani','বনানী','{}'::text[],'Dhaka','approved'),
('813dee4e-5e8d-5424-8d2d-564ff81bddcd'::uuid,'Khilgaon','খিলগাঁও','{}'::text[],'Dhaka','approved'),
('478b7aa6-fc2e-5666-b740-f0443cd49216'::uuid,'New Market','নিউ মার্কেট',ARRAY['Dhaka New Market']::text[],'Dhaka','approved'),
('971205dd-8cc4-5965-9870-fdfb04746ca9'::uuid,'Savar','সাভার','{}'::text[],'Dhaka District','approved'),
('b623b047-4588-5406-bbb0-26bf844510a4'::uuid,'Narayanganj','নারায়ণগঞ্জ','{}'::text[],'Narayanganj District','approved'),
('f4b70087-c724-52fe-81c8-8833a3962e62'::uuid,'Gazipur Chowrasta','গাজীপুর চৌরাস্তা',ARRAY['Gazipur Chourasta']::text[],'Gazipur','approved')
on conflict (id) do nothing;

create index if not exists places_status_idx on public.places(status);
create index if not exists places_name_lower_idx on public.places(lower(name));

create table if not exists public.fare_reports (
  id uuid primary key default gen_random_uuid(),
  from_place_id uuid not null references public.places(id),
  to_place_id uuid not null references public.places(id),
  vehicle text not null,
  ride_type text not null check (ride_type in ('reserved','shared')),
  fare numeric(10,2) not null check (fare > 0),
  travel_date date not null default current_date,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  submitted_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles(id),
  check (from_place_id <> to_place_id)
);
create index if not exists fare_reports_route_idx on public.fare_reports(from_place_id,to_place_id,vehicle,ride_type,status);

create table if not exists public.xp_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  points integer not null,
  reason text not null,
  contribution_id uuid,
  created_at timestamptz not null default now(),
  unique(user_id,reason,contribution_id)
);
create table if not exists public.pro_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  days integer not null check (days in (1,7,30)),
  xp_cost integer not null,
  starts_at timestamptz not null default now(),
  ends_at timestamptz not null,
  created_at timestamptz not null default now()
);

-- Auto-create a private profile shell after signup. Username is supplied in user metadata or updated after login.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.profiles(id,username) values(new.id, 'traveller_'||substr(new.id::text,1,8)) on conflict(id) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

-- Explicit grants: row-level security remains the real access control boundary.
revoke all on public.profiles, public.places, public.fare_reports, public.xp_ledger, public.pro_subscriptions from anon, authenticated;
grant select on public.places, public.fare_reports to anon, authenticated;
grant select on public.profiles to authenticated;
grant select on public.xp_ledger, public.pro_subscriptions to authenticated;

alter table public.profiles enable row level security;
alter table public.places enable row level security;
alter table public.fare_reports enable row level security;
alter table public.xp_ledger enable row level security;
alter table public.pro_subscriptions enable row level security;

drop policy if exists "public can view approved places" on public.places;
create policy "public can view approved places" on public.places for select using (status='approved');
drop policy if exists "public can view approved fares" on public.fare_reports;
create policy "public can view approved fares" on public.fare_reports for select using (status='approved');
drop policy if exists "users can view own profile" on public.profiles;
create policy "users can view own profile" on public.profiles for select to authenticated using (auth.uid()=id);
drop policy if exists "public leaderboard usernames and xp" on public.profiles;
-- A view exposes only usernames and XP, never email addresses.
create or replace view public.public_leaderboard with (security_invoker=true) as
select username, xp,
 case when xp>=1500 then 'Local Legend' when xp>=500 then 'Local Expert' when xp>=200 then 'Navigator' when xp>=50 then 'Explorer' else 'Newcomer' end as level_name
from public.profiles;
-- View access should be public; source table RLS is intentionally not public, so use a tightly-scoped security-definer function/view pattern instead.
revoke all on public.public_leaderboard from anon, authenticated;
-- A security-definer RPC exposes only public leaderboard fields.
create or replace function public.get_leaderboard(p_limit integer default 10)
returns table(username text, xp integer, level_name text)
language sql stable security definer set search_path=public as $$
  select p.username,p.xp,case when p.xp>=1500 then 'Local Legend' when p.xp>=500 then 'Local Expert' when p.xp>=200 then 'Navigator' when p.xp>=50 then 'Explorer' else 'Newcomer' end
  from public.profiles p order by p.xp desc,p.created_at asc limit least(greatest(p_limit,1),50);
$$;
grant execute on function public.get_leaderboard(integer) to anon, authenticated;

create or replace function public.submit_place(p_name text,p_name_bn text default null,p_area text default 'Dhaka Division',p_aliases text[] default '{}',p_lat double precision default null,p_lon double precision default null,p_map_label text default null)
returns uuid language plpgsql security definer set search_path=public as $$
declare uid uuid:=auth.uid(); new_id uuid; clean_name text:=trim(p_name);
begin
 if uid is null then raise exception 'Sign in required'; end if;
 if not exists(select 1 from auth.users u where u.id=uid and u.email_confirmed_at is not null) then raise exception 'Verify your email before contributing'; end if;
 if clean_name is null or char_length(clean_name)<2 or char_length(clean_name)>100 then raise exception 'Place name must be 2–100 characters'; end if;
 if exists(select 1 from public.places p where p.status in ('approved','pending') and (lower(p.name)=lower(clean_name) or lower(coalesce(p.name_bn,''))=lower(clean_name) or exists(select 1 from unnest(p.aliases) a where lower(a)=lower(clean_name)))) then raise exception 'A matching place already exists or is awaiting review'; end if;
 insert into public.places(name,name_bn,area,aliases,lat,lon,map_label,status,submitted_by)
 values(clean_name,nullif(trim(p_name_bn),''),left(coalesce(nullif(trim(p_area),''),'Dhaka Division'),120),coalesce(p_aliases,'{}'),p_lat,p_lon,left(p_map_label,500),'pending',uid) returning id into new_id;
 return new_id;
end; $$;
grant execute on function public.submit_place(text,text,text,text[],double precision,double precision,text) to authenticated;

create or replace function public.submit_fare_report(p_from_place_id uuid,p_to_place_id uuid,p_vehicle text,p_ride_type text,p_fare numeric,p_travel_date date default current_date)
returns uuid language plpgsql security definer set search_path=public as $$
declare uid uuid:=auth.uid(); new_id uuid;
begin
 if uid is null then raise exception 'Sign in required'; end if;
 if not exists(select 1 from auth.users u where u.id=uid and u.email_confirmed_at is not null) then raise exception 'Verify your email before contributing'; end if;
 if p_from_place_id=p_to_place_id then raise exception 'Origin and destination must be different'; end if;
 if not exists(select 1 from public.places where id=p_from_place_id and status='approved') or not exists(select 1 from public.places where id=p_to_place_id and status='approved') then raise exception 'Choose recognized, approved places'; end if;
 if p_fare<=0 or p_fare>1000000 then raise exception 'Enter a valid fare'; end if;
 insert into public.fare_reports(from_place_id,to_place_id,vehicle,ride_type,fare,travel_date,status,submitted_by)
 values(p_from_place_id,p_to_place_id,left(trim(p_vehicle),80),p_ride_type,p_fare,coalesce(p_travel_date,current_date),'pending',uid) returning id into new_id;
 return new_id;
end; $$;
grant execute on function public.submit_fare_report(uuid,uuid,text,text,numeric,date) to authenticated;

-- Moderation is restricted to profiles marked is_admin=true by a trusted owner in the SQL editor.
create or replace function public.review_contribution(p_kind text,p_id uuid,p_decision text,p_canonical_place_id uuid default null)
returns void language plpgsql security definer set search_path=public as $$
declare uid uuid:=auth.uid(); owner_id uuid; points integer; target_user uuid;
begin
 if uid is null or not exists(select 1 from public.profiles where id=uid and is_admin=true) then raise exception 'Moderator access required'; end if;
 if p_decision not in ('approved','rejected','duplicate') then raise exception 'Invalid decision'; end if;
 if p_kind='place' then
   select submitted_by into target_user from public.places where id=p_id and status='pending' for update;
   if not found then raise exception 'Pending place not found'; end if;
   update public.places set status=p_decision,canonical_place_id=p_canonical_place_id,reviewed_at=now(),reviewed_by=uid where id=p_id;
   points:=case when p_decision='approved' then 5 else 0 end;
 elsif p_kind='fare' then
   select submitted_by into target_user from public.fare_reports where id=p_id and status='pending' for update;
   if not found then raise exception 'Pending fare report not found'; end if;
   update public.fare_reports set status=case when p_decision='duplicate' then 'rejected' else p_decision end,reviewed_at=now(),reviewed_by=uid where id=p_id;
   points:=case when p_decision='approved' then 3 else 0 end;
 else raise exception 'Unknown contribution type'; end if;
 if points>0 and target_user is not null then
   insert into public.xp_ledger(user_id,points,reason,contribution_id) values(target_user,points,p_kind||'_approved',p_id) on conflict do nothing;
   if found then update public.profiles set xp=xp+points where id=target_user; end if;
 end if;
end; $$;
grant execute on function public.review_contribution(text,uuid,text,uuid) to authenticated;

create or replace function public.redeem_pro(p_days integer)
returns timestamptz language plpgsql security definer set search_path=public as $$
declare uid uuid:=auth.uid(); cost integer; balance integer; starts timestamptz; finish timestamptz;
begin
 if uid is null then raise exception 'Sign in required'; end if;
 cost:=case p_days when 1 then 100 when 7 then 500 when 30 then 1500 else null end;
 if cost is null then raise exception 'Invalid Pro duration'; end if;
 select xp,case when pro_until>now() then pro_until else now() end into balance,starts from public.profiles where id=uid for update;
 if balance is null then raise exception 'Profile not found'; end if;
 if balance<cost then raise exception 'Not enough XP'; end if;
 finish:=starts+make_interval(days=>p_days);
 update public.profiles set xp=xp-cost,pro_until=finish where id=uid;
 insert into public.xp_ledger(user_id,points,reason,contribution_id) values(uid,-cost,'pro_redeem_'||p_days||'d',gen_random_uuid());
 insert into public.pro_subscriptions(user_id,days,xp_cost,starts_at,ends_at) values(uid,p_days,cost,starts,finish);
 return finish;
end; $$;
grant execute on function public.redeem_pro(integer) to authenticated;

-- Enable pending queue access only for moderators. Admins review through the SQL function above.
create policy "admins can view all places" on public.places for select to authenticated using (exists(select 1 from public.profiles where id=auth.uid() and is_admin));
create policy "admins can view all fare reports" on public.fare_reports for select to authenticated using (exists(select 1 from public.profiles where id=auth.uid() and is_admin));
create policy "users can view own XP history" on public.xp_ledger for select to authenticated using (user_id=auth.uid());
create policy "users can view own Pro history" on public.pro_subscriptions for select to authenticated using (user_id=auth.uid());

-- After creating your account, make yourself an administrator by running this as project owner in SQL Editor:
-- update public.profiles set is_admin=true where id=(select id from auth.users where email='YOUR_EMAIL_HERE');
-- Use the in-app Moderator queue to approve/reject pending submissions after signing in as this admin.
