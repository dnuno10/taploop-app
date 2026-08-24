-- Mitigacion para PGRST003 / 504 en dashboards de metricas.
-- Ejecutar en Supabase SQL Editor. CREATE INDEX CONCURRENTLY no debe ir dentro
-- de BEGIN/COMMIT.

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_users_org_active
ON public.users (org_id, is_active);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_digital_cards_user_id
ON public.digital_cards (user_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_digital_cards_org_id
ON public.digital_cards (org_id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_visit_events_card_timestamp
ON public.visit_events (card_id, "timestamp" DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_visit_events_card_source_timestamp
ON public.visit_events (card_id, source, "timestamp" DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_visit_events_contact_item_id
ON public.visit_events (contact_item_id)
WHERE contact_item_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_visit_events_social_link_id
ON public.visit_events (social_link_id)
WHERE social_link_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_visit_events_smart_form_id
ON public.visit_events (smart_form_id)
WHERE smart_form_id IS NOT NULL;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_leads_card_last_seen
ON public.leads (card_id, last_seen DESC);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_leads_card_converted
ON public.leads (card_id, is_converted);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_lead_actions_lead_timestamp
ON public.lead_actions (lead_id, "timestamp");

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_contact_items_card_id_id
ON public.contact_items (card_id, id);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_taploop_social_links_card_id_id
ON public.social_links (card_id, id);
