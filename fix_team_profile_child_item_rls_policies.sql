-- Permite que un admin de TapLoop edite los items hijos de tarjetas dentro
-- de su organizacion sin cambiar el frontend.
--
-- Ejecutar en Supabase SQL Editor.

CREATE OR REPLACE FUNCTION public.current_taploop_user()
RETURNS TABLE (
  id uuid,
  org_id uuid,
  role text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT u.id, u.org_id, u.role
  FROM public.users u
  WHERE u.id = auth.uid()
    OR (
      auth.email() IS NOT NULL
      AND lower(u.email) = lower(auth.email())
    )
  ORDER BY CASE WHEN u.id = auth.uid() THEN 0 ELSE 1 END
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.current_taploop_user() TO authenticated;

CREATE OR REPLACE FUNCTION public.can_manage_card(p_card_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.digital_cards dc
    CROSS JOIN public.current_taploop_user() cu
    WHERE dc.id = p_card_id
      AND (
        dc.user_id = cu.id
        OR (
          cu.role = 'admin'
          AND dc.org_id IS NOT NULL
          AND cu.org_id IS NOT NULL
          AND dc.org_id = cu.org_id
        )
        OR (
          cu.role IN ('super_admin', 'owner')
          AND dc.org_id IS NOT NULL
          AND cu.org_id IS NOT NULL
          AND dc.org_id = cu.org_id
        )
      )
  );
$$;

GRANT EXECUTE ON FUNCTION public.can_manage_card(uuid) TO authenticated;

ALTER TABLE public.contact_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.smart_forms ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own or org contact items" ON public.contact_items;
CREATE POLICY "Users can manage own or org contact items"
ON public.contact_items
FOR ALL
TO authenticated
USING (public.can_manage_card(card_id))
WITH CHECK (public.can_manage_card(card_id));

DROP POLICY IF EXISTS "Users can manage own or org social links" ON public.social_links;
CREATE POLICY "Users can manage own or org social links"
ON public.social_links
FOR ALL
TO authenticated
USING (public.can_manage_card(card_id))
WITH CHECK (public.can_manage_card(card_id));

DROP POLICY IF EXISTS "Users can manage own or org smart forms" ON public.smart_forms;
CREATE POLICY "Users can manage own or org smart forms"
ON public.smart_forms
FOR ALL
TO authenticated
USING (public.can_manage_card(card_id))
WITH CHECK (public.can_manage_card(card_id));

NOTIFY pgrst, 'reload schema';
