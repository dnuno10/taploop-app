-- ============================================================
-- TAPLOOP — NFC Card Activation System
-- ============================================================
-- Ejecuta esto en el SQL Editor de Supabase.
-- ============================================================

-- ─── 1. Agregar columna serial a nfc_cards (si no existe) ────────────────────
-- El serial es el identificador único que se programa en el chip de fábrica.
-- Formato sugerido: TL-XXXXXX  (ej: TL-A3F9K2)

ALTER TABLE public.nfc_cards
  ADD COLUMN IF NOT EXISTS serial         TEXT UNIQUE,
  ADD COLUMN IF NOT EXISTS is_assigned    BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS assigned_at    TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Índice para lookup rápido por serial
CREATE INDEX IF NOT EXISTS nfc_cards_serial_idx ON public.nfc_cards (serial);

-- ─── 2. Función pública: lookup de tarjeta por serial (sin auth) ─────────────
-- Usada cuando alguien toca la tarjeta NFC — devuelve el user_id asignado.

CREATE OR REPLACE FUNCTION public.get_user_id_by_nfc_serial(p_serial TEXT)
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT user_id
  FROM public.nfc_cards
  WHERE serial = p_serial
    AND is_assigned = TRUE
    AND user_id IS NOT NULL
  LIMIT 1;
$$;

-- Permitir que anon llame esta función
GRANT EXECUTE ON FUNCTION public.get_user_id_by_nfc_serial(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.get_user_id_by_nfc_serial(TEXT) TO authenticated;

-- ─── 3. Política pública SELECT por serial (para el lookup de tap) ───────────
-- Necesitamos que anon pueda leer la fila del NFC card para hacer el lookup.
-- En lugar de exponer toda la tabla, usamos la función SECURITY DEFINER arriba.
-- Si prefieres una política directa:

CREATE POLICY "nfc_cards_select_by_serial_anon"
  ON public.nfc_cards FOR SELECT
  USING (serial IS NOT NULL);   -- solo filas con serial (tarjetas físicas)

GRANT SELECT ON public.nfc_cards TO anon;

-- ─── 4. Política para que el admin registre (INSERT) tarjetas nuevas ─────────
CREATE POLICY "nfc_cards_insert_admin"
  ON public.nfc_cards FOR INSERT
  WITH CHECK (public.get_my_role() = 'admin');

GRANT INSERT ON public.nfc_cards TO authenticated;

-- ─── 5. Política UPDATE para que el usuario autenticado active su tarjeta ─────
-- Solo permite actualizar filas no asignadas, y solo puede asignarse a sí mismo.
CREATE POLICY "nfc_cards_update_activation"
  ON public.nfc_cards FOR UPDATE
  TO authenticated
  USING (is_assigned = false)
  WITH CHECK (user_id = auth.uid() AND is_assigned = true);

GRANT UPDATE ON public.nfc_cards TO authenticated;

-- ─── 5. Cómo registrar una tarjeta nueva desde el panel admin ─────────────────
-- Cuando produces o recibes un lote de chips, los registras así:
--
--   INSERT INTO public.nfc_cards (serial, is_assigned)
--   VALUES ('TL-A3F9K2', FALSE);
--
-- El serial puede ser cualquier string único:
--   - El UID que viene grabado en el chip (formato hex: A1:B2:C3:D4)
--   - Un código que tú generes (TL-XXXXXX)
--   - Un UUID

-- ─── 6. Cómo activar (vincular usuario → tarjeta) ────────────────────────────
-- Cuando el usuario quiere activar su tarjeta, ejecuta desde la app:
--
--   UPDATE public.nfc_cards
--   SET user_id = auth.uid(),
--       is_assigned = TRUE,
--       assigned_at = NOW()
--   WHERE serial = 'TL-A3F9K2'
--     AND is_assigned = FALSE;   -- evita robar una tarjeta ya asignada
