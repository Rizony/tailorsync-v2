-- 1. Create the profiles table if it doesn't exist
create table if not exists public.profiles (
  id uuid not null references auth.users(id) on delete cascade primary key,
  full_name text,
  shop_name text,
  subscription_tier text default 'freemium',
  referral_code text unique,
  referrer_id uuid references public.profiles(id),
  wallet_balance decimal default 0.0,
  ad_credits integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  
  -- Extra columns from SETUP_GUIDE.md just in case
  subscription_started_at timestamptz,
  subscription_expires_at timestamptz,
  last_payment_provider text,
  last_transaction_ref text
);

-- 2. Enable RLS (Row Level Security)
alter table public.profiles enable row level security;

-- 3. Create policies (allow users to read/update their own profile)
create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );

-- 4. Create the function that inserts a row into public.profiles
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, created_at)
  values (new.id, new.raw_user_meta_data ->> 'full_name', now())
  on conflict (id) do nothing;
  return new;
end;
$$;

-- 5. Create the trigger which calls the function on USER creation
-- We drop it first to avoid "trigger already exists" errors if re-running
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 6. Helper function from SETUP_GUIDE (optional but good to have)
create or replace function increment_wallet_balance(user_id uuid, amount decimal)
returns void as $$
begin
  update profiles
  set wallet_balance = wallet_balance + amount
  where id = user_id;
end;
$$ language plpgsql;
