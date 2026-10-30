-- Ejecutar en Supabase SQL Editor.
--
-- Agrega el idioma preferido del usuario, usado SOLO para decidir en qué
-- idioma se muestran las etiquetas fijas de su perfil digital público
-- (no afecta el dashboard, que siempre se muestra en español).
--
-- DEFAULT 'es' asegura que absolutamente ningún usuario existente cambia de
-- comportamiento al correr esta migración: todos quedan en español hasta
-- que ellos mismos eligen inglés desde Configuración.

ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS language text NOT NULL DEFAULT 'es'
  CHECK (language = ANY (ARRAY['es'::text, 'en'::text]));

NOTIFY pgrst, 'reload schema';
