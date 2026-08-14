DROP FUNCTION IF EXISTS public.delete_contact_item(uuid);
DROP FUNCTION IF EXISTS public.delete_social_link(uuid);

ALTER TABLE public.visit_events
DROP CONSTRAINT IF EXISTS visit_events_source_ref_check;

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

ALTER TABLE public.visit_events
ADD CONSTRAINT visit_events_source_ref_check
CHECK (
  num_nonnulls(contact_item_id, social_link_id, smart_form_id) <= 1
  AND (
    source <> 'contact'
    OR (social_link_id IS NULL AND smart_form_id IS NULL)
  )
  AND (
    source <> 'social'
    OR (contact_item_id IS NULL AND smart_form_id IS NULL)
  )
  AND (
    source <> 'form'
    OR (contact_item_id IS NULL AND social_link_id IS NULL)
  )
  AND (
    source IN ('contact', 'social', 'form')
    OR (
      contact_item_id IS NULL
      AND social_link_id IS NULL
      AND smart_form_id IS NULL
    )
  )
);

CREATE OR REPLACE FUNCTION public.delete_contact_item(p_contact_item_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owner_id uuid;
BEGIN
  SELECT dc.user_id
  INTO v_owner_id
  FROM public.contact_items ci
  JOIN public.digital_cards dc ON dc.id = ci.card_id
  WHERE ci.id = p_contact_item_id;

  IF v_owner_id IS NULL THEN
    RETURN;
  END IF;

  IF auth.uid() IS NULL OR auth.uid() <> v_owner_id THEN
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
BEGIN
  SELECT dc.user_id
  INTO v_owner_id
  FROM public.social_links sl
  JOIN public.digital_cards dc ON dc.id = sl.card_id
  WHERE sl.id = p_social_link_id;

  IF v_owner_id IS NULL THEN
    RETURN;
  END IF;

  IF auth.uid() IS NULL OR auth.uid() <> v_owner_id THEN
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
