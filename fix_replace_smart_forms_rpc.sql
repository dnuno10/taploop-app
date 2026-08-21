DROP FUNCTION IF EXISTS public.replace_smart_forms(uuid, jsonb);

CREATE OR REPLACE FUNCTION public.replace_smart_forms(
  p_card_id uuid,
  p_forms jsonb DEFAULT '[]'::jsonb
)
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
  IF p_forms IS NULL THEN
    p_forms := '[]'::jsonb;
  END IF;

  IF jsonb_typeof(p_forms) <> 'array' THEN
    RAISE EXCEPTION 'Los formularios deben enviarse como arreglo JSON.'
      USING ERRCODE = '22023';
  END IF;

  SELECT user_id, org_id
  INTO v_owner_id, v_card_org_id
  FROM public.digital_cards
  WHERE id = p_card_id;

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
    RAISE EXCEPTION 'No autorizado para reemplazar formularios de esta tarjeta.'
      USING ERRCODE = '42501';
  END IF;

  DELETE FROM public.visit_events ve
  WHERE ve.smart_form_id IN (
    SELECT sf.id
    FROM public.smart_forms sf
    WHERE sf.card_id = p_card_id
  );

  DELETE FROM public.form_submissions fs
  WHERE fs.form_id IN (
    SELECT sf.id
    FROM public.smart_forms sf
    WHERE sf.card_id = p_card_id
  );

  IF to_regclass('public.smart_form_fields') IS NOT NULL THEN
    EXECUTE
      'DELETE FROM public.smart_form_fields
       WHERE form_id IN (
         SELECT id FROM public.smart_forms WHERE card_id = $1
       )'
    USING p_card_id;
  END IF;

  DELETE FROM public.smart_forms
  WHERE card_id = p_card_id;

  INSERT INTO public.smart_forms (
    card_id,
    name,
    description,
    success_message,
    included_fields,
    is_active
  )
  SELECT
    p_card_id,
    trim(form_item->>'name'),
    NULLIF(form_item->>'description', ''),
    COALESCE(
      NULLIF(form_item->>'success_message', ''),
      'Gracias, recibimos tu información.'
    ),
    CASE
      WHEN jsonb_typeof(form_item->'included_fields') = 'array'
        THEN form_item->'included_fields'
      ELSE '[]'::jsonb
    END,
    COALESCE((form_item->>'is_active')::boolean, true)
  FROM jsonb_array_elements(p_forms) AS form_item
  WHERE NULLIF(trim(form_item->>'name'), '') IS NOT NULL;
END;
$$;

GRANT EXECUTE ON FUNCTION public.replace_smart_forms(uuid, jsonb) TO authenticated;

NOTIFY pgrst, 'reload schema';
