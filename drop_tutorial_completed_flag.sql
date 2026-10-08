-- Ejecutar en Supabase SQL Editor.
--
-- Revierte add_tutorial_completed_flag.sql: quita la columna usada por el
-- tour guiado de bienvenida (que ya se removió del código de la app).
-- Solo necesitas correr esto SI llegaste a ejecutar la migración original;
-- si nunca la corriste, la columna no existe y este script no hace nada
-- (el IF EXISTS evita error en ese caso).

ALTER TABLE public.users
DROP COLUMN IF EXISTS tutorial_completed;

NOTIFY pgrst, 'reload schema';
