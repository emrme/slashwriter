-- +------------------------------------------+
-- |                 PROFILES                 |
-- +------------------------------------------+
alter table profiles enable row level security;

drop policy if exists "Profiles are viewable by everyone" on profiles;
create policy "Profiles are viewable by everyone" on profiles
  for select using (true);

drop policy if exists "Users can insert their own profile" on profiles;
create policy "Users can insert their own profile" on profiles
  for insert with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on profiles;
create policy "Users can update their own profile" on profiles
  for update using (auth.uid() = id);


-- +------------------------------------------+
-- |                  FOLDERS                 |
-- +------------------------------------------+
alter table folders enable row level security;

drop policy if exists "Users can create folders" on folders;
create policy "Users can create folders" on folders
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users can view their own folders" on folders;
create policy "Users can view their own folders" on folders
  for select using (auth.uid() = user_id);

drop policy if exists "Users can update their own folders" on folders;
create policy "Users can update their own folders" on folders
  for update using (auth.uid() = user_id);

drop policy if exists "Users can delete their own folders" on folders;
create policy "Users can delete their own folders" on folders
  for delete using (auth.uid() = user_id);


-- +------------------------------------------+
-- |                  SHARES                  |
-- +------------------------------------------+
alter table shares enable row level security;

drop policy if exists "Users can create shares" on shares;
create policy "Users can create shares" on shares
  for insert with check (auth.uid() = user_id);

drop policy if exists "Anyone can view any share" on shares;
create policy "Anyone can view any share" on shares
  for select using (true);

drop policy if exists "Users can update their own shares" on shares;
create policy "Users can update their own shares" on shares
  for update using (auth.uid() = user_id);

drop policy if exists "Users can delete their own shares" on shares;
create policy "Users can delete their own shares" on shares
  for delete using (auth.uid() = user_id);


-- +------------------------------------------+
-- |                 DOCUMENTS                |
-- +------------------------------------------+
alter table documents enable row level security;

drop policy if exists "Users can create documents" on documents;
create policy "Users can create documents" on documents
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users can view their own documents" on documents;
create policy "Users can view their own documents" on documents
  for select using (auth.uid() = user_id);

drop policy if exists "Users can update their own documents" on documents;
create policy "Users can update their own documents" on documents
  for update using (auth.uid() = user_id);

drop policy if exists "Users can delete their own documents" on documents;
create policy "Users can delete their own documents" on documents
  for delete using (auth.uid() = user_id);


create or replace function canRead(user_id uuid, share_id uuid) returns boolean
language plpgsql
as
$$
declare
  can_read boolean;
  share_settings shares%rowtype;
begin
select * into share_settings from shares where id=share_id;
if not found then
  can_read := false;
else
  if share_settings.anyone_can_read then
    can_read := true;
  elsif user_id = any(share_settings.users_can_read) then
    can_read := true;
  else
    can_read := false;
  end if;
end if;
return can_read;
end; $$;

create or replace function canEdit(user_id uuid, share_id uuid) returns boolean
language plpgsql
as
$$
declare
  can_edit boolean;
  share_settings shares%rowtype;
begin
select * into share_settings from shares where id=share_id;
if not found then
  can_edit := false;
else
  if share_settings.anyone_can_edit then
    can_edit := true;
  elsif user_id = any(share_settings.users_can_edit) then
    can_edit := true;
  else
    can_edit := false;
  end if;
end if;
return can_edit;
end; $$;

drop policy if exists "Other users may read a shared document" on documents;
create policy "Other users may read a shared document" on documents
  for select using (
    deleted is not true and
    share_settings is not null and
    (canRead(auth.uid(), share_settings) 
      or canEdit(auth.uid(), share_settings))
  );

drop policy if exists "Other users may edit a shared document" on documents;
create policy "Other users may edit a shared document" on documents
  for update using (
    deleted is not true and
    share_settings is not null and 
    canEdit(auth.uid(), share_settings)
  ); 

