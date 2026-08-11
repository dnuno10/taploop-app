BEGIN;

-- Formularios: ahora se configuran desde campos predefinidos en smart_forms.
ALTER TABLE public.smart_forms
ADD COLUMN IF NOT EXISTS description text,
ADD COLUMN IF NOT EXISTS success_message text NOT NULL DEFAULT 'Gracias, recibimos tu información.',
ADD COLUMN IF NOT EXISTS included_fields jsonb NOT NULL DEFAULT '["name", "email", "phone", "message"]'::jsonb;

ALTER TABLE public.smart_forms
DROP CONSTRAINT IF EXISTS smart_forms_included_fields_array_check;

ALTER TABLE public.smart_forms
ADD CONSTRAINT smart_forms_included_fields_array_check
CHECK (jsonb_typeof(included_fields) = 'array');

ALTER TABLE public.form_submissions
DROP CONSTRAINT IF EXISTS form_submissions_form_id_fkey;

DELETE FROM public.form_submissions fs
WHERE fs.form_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM public.smart_forms sf
    WHERE sf.id = fs.form_id
  );

ALTER TABLE public.form_submissions
ADD CONSTRAINT form_submissions_form_id_fkey
FOREIGN KEY (form_id)
REFERENCES public.smart_forms(id)
ON DELETE CASCADE;

ALTER TABLE public.visit_events
DROP CONSTRAINT IF EXISTS visit_events_smart_form_id_fkey;

DELETE FROM public.visit_events ve
WHERE ve.smart_form_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM public.smart_forms sf
    WHERE sf.id = ve.smart_form_id
  );

ALTER TABLE public.visit_events
ADD CONSTRAINT visit_events_smart_form_id_fkey
FOREIGN KEY (smart_form_id)
REFERENCES public.smart_forms(id)
ON DELETE CASCADE;

DO $$
BEGIN
  IF to_regclass('public.smart_form_fields') IS NOT NULL THEN
    EXECUTE $legacy_fields$
      WITH mapped_fields AS (
        SELECT
          form_id,
          jsonb_agg(field_key ORDER BY fixed_order) AS included_fields
        FROM (
          SELECT DISTINCT ON (form_id, field_key)
            form_id,
            field_key,
            fixed_order
          FROM (
            SELECT
              form_id,
              CASE
                WHEN lower(coalesce(label, '')) LIKE '%nombre%' THEN 'name'
                WHEN lower(coalesce(label, '')) LIKE '%mail%'
                  OR lower(coalesce(label, '')) LIKE '%correo%'
                  OR field_type = 'email' THEN 'email'
                WHEN lower(coalesce(label, '')) LIKE '%tel%'
                  OR lower(coalesce(label, '')) LIKE '%cel%'
                  OR field_type = 'phone' THEN 'phone'
                WHEN lower(coalesce(label, '')) LIKE '%empresa%' THEN 'company'
                WHEN lower(coalesce(label, '')) LIKE '%mensaje%'
                  OR field_type = 'textarea' THEN 'message'
                WHEN lower(coalesce(label, '')) LIKE '%presupuesto%'
                  OR field_type = 'number' THEN 'budget'
                WHEN lower(coalesce(label, '')) LIKE '%fecha%' THEN 'date'
                ELSE NULL
              END AS field_key,
              CASE
                WHEN lower(coalesce(label, '')) LIKE '%nombre%' THEN 1
                WHEN lower(coalesce(label, '')) LIKE '%mail%'
                  OR lower(coalesce(label, '')) LIKE '%correo%'
                  OR field_type = 'email' THEN 2
                WHEN lower(coalesce(label, '')) LIKE '%tel%'
                  OR lower(coalesce(label, '')) LIKE '%cel%'
                  OR field_type = 'phone' THEN 3
                WHEN lower(coalesce(label, '')) LIKE '%empresa%' THEN 4
                WHEN lower(coalesce(label, '')) LIKE '%mensaje%'
                  OR field_type = 'textarea' THEN 5
                WHEN lower(coalesce(label, '')) LIKE '%presupuesto%'
                  OR field_type = 'number' THEN 6
                WHEN lower(coalesce(label, '')) LIKE '%fecha%' THEN 7
                ELSE 99
              END AS fixed_order
            FROM public.smart_form_fields
          ) detected
          WHERE field_key IS NOT NULL
          ORDER BY form_id, field_key, fixed_order
        ) deduped
        GROUP BY form_id
      )
      UPDATE public.smart_forms sf
      SET included_fields = mf.included_fields
      FROM mapped_fields mf
      WHERE sf.id = mf.form_id
        AND jsonb_array_length(mf.included_fields) > 0
    $legacy_fields$;
  END IF;
END $$;

DROP TABLE IF EXISTS public.smart_form_fields;

-- Retirar firmas antiguas que recibían campaign_id.
DROP FUNCTION IF EXISTS public.record_card_visit(
  uuid,
  text,
  text,
  text,
  text,
  text,
  uuid,
  uuid,
  uuid,
  uuid
);

DROP FUNCTION IF EXISTS public.submit_card_form(
  uuid,
  uuid,
  text,
  text,
  text,
  text,
  jsonb
);

DROP FUNCTION IF EXISTS public.submit_card_form(
  uuid,
  uuid,
  text,
  text,
  text,
  text,
  jsonb,
  uuid
);

DROP FUNCTION IF EXISTS public.submit_card_form(
  uuid,
  text,
  text,
  text,
  text,
  text,
  jsonb
);

DROP FUNCTION IF EXISTS public.submit_card_form(
  uuid,
  text,
  text,
  text,
  text,
  text,
  jsonb,
  uuid
);

-- RPC sin campaña: visitas/interacciones.
CREATE OR REPLACE FUNCTION public.record_card_visit(
  p_card_id uuid,
  p_source text,
  p_device text DEFAULT NULL,
  p_ip text DEFAULT NULL,
  p_city text DEFAULT NULL,
  p_country text DEFAULT NULL,
  p_contact_item_id uuid DEFAULT NULL,
  p_social_link_id uuid DEFAULT NULL,
  p_smart_form_id uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.visit_events (
    card_id,
    timestamp,
    ip,
    device,
    city,
    country,
    source,
    contact_item_id,
    social_link_id,
    smart_form_id
  )
  VALUES (
    p_card_id,
    now(),
    p_ip,
    p_device,
    p_city,
    p_country,
    p_source,
    p_contact_item_id,
    p_social_link_id,
    p_smart_form_id
  );
END;
$$;

-- RPC sin campaña: envío de formulario por id.
CREATE OR REPLACE FUNCTION public.submit_card_form(
  p_card_id uuid,
  p_form_id uuid,
  p_name text,
  p_email text DEFAULT NULL,
  p_phone text DEFAULT NULL,
  p_company text DEFAULT NULL,
  p_form_data jsonb DEFAULT '{}'::jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_org_id uuid;
  v_lead_id uuid;
BEGIN
  SELECT org_id INTO v_org_id
  FROM public.digital_cards
  WHERE id = p_card_id;

  INSERT INTO public.leads (
    card_id,
    org_id,
    name,
    company,
    first_seen,
    last_seen,
    score,
    form_data,
    form_type
  )
  VALUES (
    p_card_id,
    v_org_id,
    p_name,
    p_company,
    now(),
    now(),
    0,
    p_form_data || jsonb_strip_nulls(jsonb_build_object(
      'email', p_email,
      'phone', p_phone
    )),
    p_form_id::text
  )
  RETURNING id INTO v_lead_id;

  INSERT INTO public.form_submissions (
    form_id,
    lead_id,
    data,
    submitted_at
  )
  VALUES (
    p_form_id,
    v_lead_id,
    p_form_data,
    now()
  );
END;
$$;

-- RPC sin campaña: compatibilidad con clientes que mandan form_type textual.
CREATE OR REPLACE FUNCTION public.submit_card_form(
  p_card_id uuid,
  p_form_type text,
  p_name text,
  p_email text DEFAULT NULL,
  p_phone text DEFAULT NULL,
  p_company text DEFAULT NULL,
  p_form_data jsonb DEFAULT '{}'::jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_form_id uuid;
  v_org_id uuid;
  v_lead_id uuid;
BEGIN
  BEGIN
    v_form_id := p_form_type::uuid;
  EXCEPTION WHEN invalid_text_representation THEN
    v_form_id := NULL;
  END;

  SELECT org_id INTO v_org_id
  FROM public.digital_cards
  WHERE id = p_card_id;

  INSERT INTO public.leads (
    card_id,
    org_id,
    name,
    company,
    first_seen,
    last_seen,
    score,
    form_data,
    form_type
  )
  VALUES (
    p_card_id,
    v_org_id,
    p_name,
    p_company,
    now(),
    now(),
    0,
    p_form_data || jsonb_strip_nulls(jsonb_build_object(
      'email', p_email,
      'phone', p_phone
    )),
    p_form_type
  )
  RETURNING id INTO v_lead_id;

  IF v_form_id IS NOT NULL THEN
    INSERT INTO public.form_submissions (
      form_id,
      lead_id,
      data,
      submitted_at
    )
    VALUES (
      v_form_id,
      v_lead_id,
      p_form_data,
      now()
    );
  END IF;
END;
$$;

-- Borrado seguro de formularios: limpia referencias antes de eliminar.
DROP FUNCTION IF EXISTS public.delete_smart_form(uuid);

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

-- Eliminar referencias de campañas en BD.
ALTER TABLE public.leads
DROP CONSTRAINT IF EXISTS leads_campaign_id_fkey;

ALTER TABLE public.form_submissions
DROP CONSTRAINT IF EXISTS form_submissions_campaign_id_fkey;

ALTER TABLE public.visit_events
DROP CONSTRAINT IF EXISTS visit_events_campaign_id_fkey;

ALTER TABLE public.leads
DROP COLUMN IF EXISTS campaign_id;

ALTER TABLE public.form_submissions
DROP COLUMN IF EXISTS campaign_id;

ALTER TABLE public.visit_events
DROP COLUMN IF EXISTS campaign_id;

DROP TABLE IF EXISTS public.campaign_members;
DROP TABLE IF EXISTS public.campaigns;

COMMIT;
