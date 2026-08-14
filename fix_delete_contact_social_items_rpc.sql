DROP FUNCTION IF EXISTS public.delete_contact_item(uuid);
DROP FUNCTION IF EXISTS public.delete_social_link(uuid);

ALTER TABLE public.visit_events
DROP CONSTRAINT IF EXISTS visit_events_contact_item_id_fkey;

ALTER TABLE public.visit_events
DROP CONSTRAINT IF EXISTS visit_events_social_link_id_fkey;

UPDATE public.visit_events ve
SET contact_item_id = NULL
WHERE ve.contact_item_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM public.contact_items ci
    WHERE ci.id = ve.contact_item_id
  );

UPDATE public.visit_events ve
SET social_link_id = NULL
WHERE ve.social_link_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM public.social_links sl
    WHERE sl.id = ve.social_link_id
  );

ALTER TABLE public.visit_events
ADD CONSTRAINT visit_events_contact_item_id_fkey
FOREIGN KEY (contact_item_id)
REFERENCES public.contact_items(id)
ON DELETE SET NULL;

ALTER TABLE public.visit_events
ADD CONSTRAINT visit_events_social_link_id_fkey
FOREIGN KEY (social_link_id)
REFERENCES public.social_links(id)
ON DELETE SET NULL;

CREATE OR REPLACE FUNCTION public.delete_contact_item(p_contact_item_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owner_id uuid;
  v_card_org_id uuid;
  v_requester_id uuid;
  v_requester_org_id uuid;
  v_requester_role text;
BEGIN
  SELECT dc.user_id, dc.org_id
  INTO v_owner_id, v_card_org_id
  FROM public.contact_items ci
  JOIN public.digital_cards dc ON dc.id = ci.card_id
  WHERE ci.id = p_contact_item_id;

  IF v_owner_id IS NULL THEN
    RETURN;
  END IF;

  SELECT id, org_id, role
  INTO v_requester_id, v_requester_org_id, v_requester_role
  FROM public.users
  WHERE id = auth.uid()
    OR (
      auth.email() IS NOT NULL
      AND lower(email) = lower(auth.email())
    )
  ORDER BY CASE WHEN id = auth.uid() THEN 0 ELSE 1 END
  LIMIT 1;

  IF auth.uid() IS NULL
    OR NOT (
      auth.uid() = v_owner_id
      OR v_requester_id = v_owner_id
      OR v_requester_role = 'admin'
      OR (
        v_card_org_id IS NOT NULL
        AND v_requester_org_id IS NOT NULL
        AND v_card_org_id = v_requester_org_id
      )
    )
  THEN
    RAISE EXCEPTION 'No autorizado para eliminar este contacto.'
      USING ERRCODE = '42501';
  END IF;

  DELETE FROM public.contact_items
  WHERE id = p_contact_item_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.delete_social_link(p_social_link_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owner_id uuid;
  v_card_org_id uuid;
  v_requester_id uuid;
  v_requester_org_id uuid;
  v_requester_role text;
BEGIN
  SELECT dc.user_id, dc.org_id
  INTO v_owner_id, v_card_org_id
  FROM public.social_links sl
  JOIN public.digital_cards dc ON dc.id = sl.card_id
  WHERE sl.id = p_social_link_id;

  IF v_owner_id IS NULL THEN
    RETURN;
  END IF;

  SELECT id, org_id, role
  INTO v_requester_id, v_requester_org_id, v_requester_role
  FROM public.users
  WHERE id = auth.uid()
    OR (
      auth.email() IS NOT NULL
      AND lower(email) = lower(auth.email())
    )
  ORDER BY CASE WHEN id = auth.uid() THEN 0 ELSE 1 END
  LIMIT 1;

  IF auth.uid() IS NULL
    OR NOT (
      auth.uid() = v_owner_id
      OR v_requester_id = v_owner_id
      OR v_requester_role = 'admin'
      OR (
        v_card_org_id IS NOT NULL
        AND v_requester_org_id IS NOT NULL
        AND v_card_org_id = v_requester_org_id
      )
    )
  THEN
    RAISE EXCEPTION 'No autorizado para eliminar este enlace.'
      USING ERRCODE = '42501';
  END IF;

  DELETE FROM public.social_links
  WHERE id = p_social_link_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_contact_item(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_social_link(uuid) TO authenticated;

NOTIFY pgrst, 'reload schema';
