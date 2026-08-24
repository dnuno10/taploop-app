-- Adds optional profile icon customization without changing existing data.

alter table public.digital_cards
  add column if not exists icon_color bigint default 4293879840;

alter table public.social_links
  add column if not exists icon_key text default 'link';

