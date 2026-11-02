-- Lista zadań: tabele, historia (wyzwalacz) i RLS
-- Wklej w Supabase: SQL Editor -> New query -> Run

-- 1. Zadania
create table if not exists public.zadania (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  tytul text not null check (char_length(tytul) between 1 and 200),
  notatka text,
  priorytet smallint not null default 2 check (priorytet in (1, 2, 3)), -- 1 niski, 2 średni, 3 wysoki
  termin date,
  zrobione boolean not null default false,
  zrobione_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists zadania_user_idx on public.zadania (user_id, created_at desc);

-- 2. Historia (bez klucza obcego do zadań, żeby wpisy przetrwały usunięcie zadania)
create table if not exists public.zadania_historia (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  zadanie_id uuid,
  tytul text not null,
  akcja text not null check (akcja in ('dodano', 'zmieniono', 'zrobione', 'przywrócono', 'usunięto')),
  created_at timestamptz not null default now()
);

create index if not exists zadania_historia_user_idx on public.zadania_historia (user_id, created_at desc);

-- 3. Wyzwalacz zapisujący historię automatycznie
create or replace function public.zadania_loguj()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    insert into public.zadania_historia (user_id, zadanie_id, tytul, akcja)
    values (new.user_id, new.id, new.tytul, 'dodano');
    return new;
  elsif tg_op = 'UPDATE' then
    if new.zrobione is distinct from old.zrobione then
      insert into public.zadania_historia (user_id, zadanie_id, tytul, akcja)
      values (new.user_id, new.id, new.tytul, case when new.zrobione then 'zrobione' else 'przywrócono' end);
    elsif (new.tytul, new.notatka, new.priorytet, new.termin)
          is distinct from (old.tytul, old.notatka, old.priorytet, old.termin) then
      insert into public.zadania_historia (user_id, zadanie_id, tytul, akcja)
      values (new.user_id, new.id, new.tytul, 'zmieniono');
    end if;
    return new;
  elsif tg_op = 'DELETE' then
    insert into public.zadania_historia (user_id, zadanie_id, tytul, akcja)
    values (old.user_id, old.id, old.tytul, 'usunięto');
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists zadania_loguj_trg on public.zadania;
create trigger zadania_loguj_trg
after insert or update or delete on public.zadania
for each row execute function public.zadania_loguj();

-- 4. RLS: każdy widzi tylko swoje dane
alter table public.zadania enable row level security;
alter table public.zadania_historia enable row level security;

drop policy if exists "zadania_wlasne" on public.zadania;
create policy "zadania_wlasne" on public.zadania
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- historia: tylko odczyt (zapisuje ją wyzwalacz)
drop policy if exists "historia_odczyt" on public.zadania_historia;
create policy "historia_odczyt" on public.zadania_historia
  for select to authenticated
  using (user_id = (select auth.uid()));
