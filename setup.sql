-- Digaf Loan Manager: run this once in Supabase > SQL Editor
create table customers(
  id uuid primary key default gen_random_uuid(),
  name text not null, phone text, nid text,
  created_at timestamptz default now());
create table loans(
  id uuid primary key default gen_random_uuid(),
  no text, cid uuid references customers(id) on delete restrict,
  cat text, principal numeric not null, rate numeric not null, n int not null,
  start_date date not null, pm0 numeric default 0, note text,
  closed date, reg boolean default false,
  created_at timestamptz default now());
create table payments(
  id uuid primary key default gen_random_uuid(),
  loan_id uuid references loans(id) on delete cascade,
  inst int not null, amt numeric not null, pay_date date not null,
  receipt_path text, created_by uuid default auth.uid(),
  created_at timestamptz default now());
create index on loans(cid); create index on payments(loan_id);
alter table customers enable row level security;
alter table loans enable row level security;
alter table payments enable row level security;
create policy staff_all on customers for all to authenticated using (true) with check (true);
create policy staff_all on loans for all to authenticated using (true) with check (true);
create policy staff_all on payments for all to authenticated using (true) with check (true);
insert into storage.buckets (id, name, public) values ('receipts','receipts',false) on conflict do nothing;
create policy staff_receipts on storage.objects for all to authenticated
  using (bucket_id='receipts') with check (bucket_id='receipts');
