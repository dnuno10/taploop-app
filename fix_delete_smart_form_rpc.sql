DROP FUNCTION IF EXISTS public.delete_smart_form(uuid);

ALTER TABLE public.visit_events
DROP CONSTRAINT IF EXISTS visit_events_smart_form_id_fkey;

DELETE FROM public.visit_events ve
WHERE ve.smart_form_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM public.smart_forms sf
    WHERE sf.id = ve.smart_form_id
  );

DELETE FROM public.form_submissions fs
WHERE fs.form_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM public.smart_forms sf
    WHERE sf.id = fs.form_id
  );

ALTER TABLE public.visit_events
ADD CONSTRAINT visit_events_smart_form_id_fkey
FOREIGN KEY (smart_form_id)
REFERENCES public.smart_forms(id)
ON DELETE CASCADE;

CREATE OR REPLACE FUNCTION public.delete_smart_form(p_form_id uuid)
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
  FROM public.smart_forms sf
  JOIN public.digital_cards dc ON dc.id = sf.card_id
  WHERE sf.id = p_form_id;

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
    RAISE EXCEPTION 'No autorizado para eliminar este formulario.'
      USING ERRCODE = '42501';
  END IF;

  DELETE FROM public.visit_events
  WHERE smart_form_id = p_form_id;

  DELETE FROM public.form_submissions
  WHERE form_id = p_form_id;

  IF to_regclass('public.smart_form_fields') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.smart_form_fields WHERE form_id = $1'
    USING p_form_id;
  END IF;

  DELETE FROM public.smart_forms
  WHERE id = p_form_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_smart_form(uuid) TO authenticated;

NOTIFY pgrst, 'reload schema';
