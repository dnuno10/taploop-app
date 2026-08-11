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

DROP TABLE IF EXISTS public.link_stats;

NOTIFY pgrst, 'reload schema';
