-- Ejecutar en Supabase SQL Editor.
--
-- Soporte para "configuración compartida de equipo" como plantilla viva:
-- en vez de copiar diseño/formularios/integraciones/enlaces a cada miembro
-- (lo cual sobrescribía/borraba su configuración original para siempre),
-- cada toggle ahora solo decide si el equipo lee los datos de la tarjeta
-- "plantilla" (shared_template_card_id) en vez de los suyos propios.
--
-- Nada de esto borra datos existentes; shared_links_enabled nace en false
-- y shared_template_card_id nace en null, así que el comportamiento actual
-- de cada organización no cambia hasta que un admin elija una plantilla.

ALTER TABLE public.organizations
ADD COLUMN IF NOT EXISTS shared_links_enabled boolean NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS shared_template_card_id uuid REFERENCES public.digital_cards(id) ON DELETE SET NULL;

NOTIFY pgrst, 'reload schema';
