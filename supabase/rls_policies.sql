-- ============================================================
-- TAPLOOP — Row Level Security Policies
-- ============================================================
-- Pega esto completo en el SQL Editor de Supabase.
-- Ejecuta primero los ALTER TABLE, luego las policies.
-- ============================================================


-- ─── 0. Función helper SECURITY DEFINER ─────────────────────────────────────
-- Lee role y org_id del usuario actual SIN activar RLS en la tabla users,
-- evitando la recursión infinita en todas las políticas que necesitan esos datos.

CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.get_my_org_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT org_id FROM public.users WHERE id = auth.uid();
$$;

-- Verifica si un user_id dado pertenece a la misma org que el usuario actual
DROP FUNCTION IF EXISTS public.same_org(UUID);
DROP FUNCTION IF EXISTS public.same_org(TEXT);

CREATE OR REPLACE FUNCTION public.same_org(target_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = target_user_id
      AND org_id = (SELECT org_id FROM public.users WHERE id = auth.uid())
  );
$$;

-- Overload para evitar errores de tipo cuando el caller envía TEXT.
CREATE OR REPLACE FUNCTION public.same_org(target_user_id TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT public.same_org(target_user_id::UUID);
$$;


-- ─── 1. Habilitar RLS en todas las tablas ────────────────────────────────────

ALTER TABLE public.users               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.digital_cards        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contact_items        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_links         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_actions         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visit_events         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.link_stats           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaigns            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaign_members     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.smart_forms          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.smart_form_fields    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.form_submissions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_integrations  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nfc_cards            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contacto_webpage     ENABLE ROW LEVEL SECURITY;


-- ─── 2. Permisos al rol anónimo (visitantes del perfil público) ──────────────
-- Sin esto, las políticas de SELECT públicas no funcionan para no-autenticados.

GRANT SELECT ON public.digital_cards    TO anon;
GRANT SELECT ON public.contact_items    TO anon;
GRANT SELECT ON public.social_links     TO anon;
GRANT SELECT ON public.smart_forms      TO anon;
GRANT SELECT ON public.smart_form_fields TO anon;
GRANT INSERT ON public.visit_events     TO anon;
GRANT INSERT ON public.leads            TO anon;
GRANT INSERT ON public.form_submissions TO anon;
GRANT INSERT ON public.contacto_webpage TO anon;


-- ============================================================
-- USERS
-- ============================================================

-- El propio usuario puede leer y actualizar su fila
CREATE POLICY "users_select_own"
  ON public.users FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "users_update_own"
  ON public.users FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Al registrarse (signUp), el id del nuevo row debe coincidir con auth.uid()
CREATE POLICY "users_insert_own"
  ON public.users FOR INSERT
  WITH CHECK (id = auth.uid());

-- Admins pueden leer todos los usuarios de su organización
CREATE POLICY "users_select_org_admin"
  ON public.users FOR SELECT
  USING (
    org_id IS NOT NULL
    AND org_id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );

-- Miembros de la org pueden leer usuarios activos de su propia org
CREATE POLICY "users_select_org_member"
  ON public.users FOR SELECT
  USING (
    org_id IS NOT NULL
    AND org_id = public.get_my_org_id()
    AND is_active = true
  );

-- Admins pueden insertar / actualizar usuarios dentro de su org
CREATE POLICY "users_insert_org_admin"
  ON public.users FOR INSERT
  WITH CHECK (
    org_id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );

CREATE POLICY "users_update_org_admin"
  ON public.users FOR UPDATE
  USING (
    org_id IS NOT NULL
    AND org_id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );


-- ============================================================
-- ORGANIZATIONS
-- ============================================================

-- Cualquier miembro puede leer su propia organización
CREATE POLICY "organizations_select_member"
  ON public.organizations FOR SELECT
  USING (id = public.get_my_org_id());

-- Solo admins pueden actualizar su organización
CREATE POLICY "organizations_update_admin"
  ON public.organizations FOR UPDATE
  USING (
    id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );


-- ============================================================
-- DIGITAL CARDS
-- ============================================================

-- PÚBLICO: cualquiera (anon + auth) puede leer tarjetas activas — taploop.mx/:slug
CREATE POLICY "digital_cards_select_public"
  ON public.digital_cards FOR SELECT
  USING (is_active = true);

-- El dueño puede leer SUS tarjetas (activas o inactivas)
CREATE POLICY "digital_cards_select_owner"
  ON public.digital_cards FOR SELECT
  USING (user_id = auth.uid());

-- El dueño puede insertar su tarjeta
CREATE POLICY "digital_cards_insert_owner"
  ON public.digital_cards FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- El dueño puede actualizar su tarjeta
CREATE POLICY "digital_cards_update_owner"
  ON public.digital_cards FOR UPDATE
  USING (user_id = auth.uid());

-- Admins pueden leer / actualizar cualquier tarjeta de su org
CREATE POLICY "digital_cards_select_org_admin"
  ON public.digital_cards FOR SELECT
  USING (
    org_id IS NOT NULL
    AND org_id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );

-- Miembros de la org pueden leer tarjetas de su organización
CREATE POLICY "digital_cards_select_org_member"
  ON public.digital_cards FOR SELECT
  USING (
    (
      org_id IS NOT NULL
      AND org_id = public.get_my_org_id()
    )
    OR public.same_org(user_id)
  );

CREATE POLICY "digital_cards_update_org_admin"
  ON public.digital_cards FOR UPDATE
  USING (
    org_id IS NOT NULL
    AND org_id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );


-- ============================================================
-- CONTACT ITEMS
-- ============================================================

-- PÚBLICO: items visibles de tarjetas activas (perfil público)
CREATE POLICY "contact_items_select_public"
  ON public.contact_items FOR SELECT
  USING (
    is_visible = true
    AND EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = contact_items.card_id AND is_active = true
    )
  );

-- Dueño de la tarjeta: acceso total (incluyendo items ocultos)
CREATE POLICY "contact_items_select_owner"
  ON public.contact_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = contact_items.card_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "contact_items_insert_owner"
  ON public.contact_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = contact_items.card_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "contact_items_update_owner"
  ON public.contact_items FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = contact_items.card_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "contact_items_delete_owner"
  ON public.contact_items FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = contact_items.card_id AND user_id = auth.uid()
    )
  );


-- ============================================================
-- SOCIAL LINKS
-- ============================================================

-- PÚBLICO: links visibles de tarjetas activas
CREATE POLICY "social_links_select_public"
  ON public.social_links FOR SELECT
  USING (
    is_visible = true
    AND EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = social_links.card_id AND is_active = true
    )
  );

-- Dueño: acceso total (incluyendo links ocultos)
CREATE POLICY "social_links_select_owner"
  ON public.social_links FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = social_links.card_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "social_links_insert_owner"
  ON public.social_links FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = social_links.card_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "social_links_update_owner"
  ON public.social_links FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = social_links.card_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "social_links_delete_owner"
  ON public.social_links FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = social_links.card_id AND user_id = auth.uid()
    )
  );


-- ============================================================
-- VISIT EVENTS
-- ============================================================

-- PÚBLICO INSERT: visitantes anónimos registran su visita
CREATE POLICY "visit_events_insert_anon"
  ON public.visit_events FOR INSERT
  WITH CHECK (true);

-- Dueño de la tarjeta puede leer sus visitas
CREATE POLICY "visit_events_select_owner"
  ON public.visit_events FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = visit_events.card_id AND user_id = auth.uid()
    )
  );

-- Admin de la org puede leer visitas de todas las tarjetas de su org
CREATE POLICY "visit_events_select_org_admin"
  ON public.visit_events FOR SELECT
  USING (
    public.get_my_role() = 'admin'
    AND EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = visit_events.card_id
        AND org_id = public.get_my_org_id()
    )
  );

-- Miembros de la org pueden leer eventos de tarjetas de su organización
CREATE POLICY "visit_events_select_org_member"
  ON public.visit_events FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = visit_events.card_id
        AND (
          (
            org_id IS NOT NULL
            AND org_id = public.get_my_org_id()
          )
          OR public.same_org(user_id)
        )
    )
  );


-- ============================================================
-- LEADS
-- ============================================================

-- PÚBLICO INSERT: se genera lead al interactuar con una tarjeta pública
CREATE POLICY "leads_insert_anon"
  ON public.leads FOR INSERT
  WITH CHECK (true);

-- Dueño de la tarjeta puede leer sus leads
CREATE POLICY "leads_select_owner"
  ON public.leads FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = leads.card_id AND user_id = auth.uid()
    )
  );

-- Dueño puede actualizar (pipeline stage, conversión, etc.)
CREATE POLICY "leads_update_owner"
  ON public.leads FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = leads.card_id AND user_id = auth.uid()
    )
  );

-- Admin de la org puede leer / actualizar todos los leads de su org
CREATE POLICY "leads_select_org_admin"
  ON public.leads FOR SELECT
  USING (
    org_id IS NOT NULL
    AND org_id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );

-- Miembros de la org pueden leer leads de su organización
CREATE POLICY "leads_select_org_member"
  ON public.leads FOR SELECT
  USING (
    (
      org_id IS NOT NULL
      AND org_id = public.get_my_org_id()
    )
    OR EXISTS (
      SELECT 1
      FROM public.digital_cards dc
      WHERE dc.id = leads.card_id
        AND public.same_org(dc.user_id)
    )
  );

CREATE POLICY "leads_update_org_admin"
  ON public.leads FOR UPDATE
  USING (
    org_id IS NOT NULL
    AND org_id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );


-- ============================================================
-- LEAD ACTIONS
-- ============================================================

-- Dueño de la tarjeta (vía lead) puede insertar y leer acciones
CREATE POLICY "lead_actions_insert_owner"
  ON public.lead_actions FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.leads l
      JOIN  public.digital_cards dc ON dc.id = l.card_id
      WHERE l.id = lead_actions.lead_id AND dc.user_id = auth.uid()
    )
  );

CREATE POLICY "lead_actions_select_owner"
  ON public.lead_actions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.leads l
      JOIN  public.digital_cards dc ON dc.id = l.card_id
      WHERE l.id = lead_actions.lead_id AND dc.user_id = auth.uid()
    )
  );


-- ============================================================
-- LINK STATS
-- ============================================================

-- PÚBLICO INSERT: cualquiera registra un clic
CREATE POLICY "link_stats_insert_anon"
  ON public.link_stats FOR INSERT
  WITH CHECK (true);

-- Dueño puede leer y actualizar los contadores
CREATE POLICY "link_stats_select_owner"
  ON public.link_stats FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = link_stats.card_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "link_stats_update_owner"
  ON public.link_stats FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = link_stats.card_id AND user_id = auth.uid()
    )
  );


-- ============================================================
-- CAMPAIGNS
-- ============================================================

-- Cualquier miembro de la org puede leer campañas
CREATE POLICY "campaigns_select_org_member"
  ON public.campaigns FOR SELECT
  USING (
    org_id IS NOT NULL
    AND org_id = public.get_my_org_id()
  );

-- Solo admins pueden crear / editar / eliminar campañas
CREATE POLICY "campaigns_insert_org_admin"
  ON public.campaigns FOR INSERT
  WITH CHECK (
    org_id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );

CREATE POLICY "campaigns_update_org_admin"
  ON public.campaigns FOR UPDATE
  USING (
    org_id IS NOT NULL
    AND org_id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );

CREATE POLICY "campaigns_delete_org_admin"
  ON public.campaigns FOR DELETE
  USING (
    org_id IS NOT NULL
    AND org_id = public.get_my_org_id()
    AND public.get_my_role() = 'admin'
  );


-- ============================================================
-- CAMPAIGN MEMBERS
-- ============================================================

-- Cada usuario ve / gestiona sus propias membresías
CREATE POLICY "campaign_members_select_own"
  ON public.campaign_members FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "campaign_members_insert_own"
  ON public.campaign_members FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "campaign_members_delete_own"
  ON public.campaign_members FOR DELETE
  USING (user_id = auth.uid());

-- Admins pueden gestionar membresías de usuarios de su org
CREATE POLICY "campaign_members_all_org_admin"
  ON public.campaign_members FOR ALL
  USING (
    public.get_my_role() = 'admin'
    AND public.same_org(campaign_members.user_id)
  )
  WITH CHECK (
    public.get_my_role() = 'admin'
    AND public.same_org(campaign_members.user_id)
  );


-- ============================================================
-- SMART FORMS
-- ============================================================

-- PÚBLICO: formularios activos de tarjetas activas son visibles para renderizarlos
CREATE POLICY "smart_forms_select_public"
  ON public.smart_forms FOR SELECT
  USING (
    is_active = true
    AND EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = smart_forms.card_id AND is_active = true
    )
  );

-- Dueño: acceso total
CREATE POLICY "smart_forms_select_owner"
  ON public.smart_forms FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = smart_forms.card_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "smart_forms_insert_owner"
  ON public.smart_forms FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = smart_forms.card_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "smart_forms_update_owner"
  ON public.smart_forms FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = smart_forms.card_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "smart_forms_delete_owner"
  ON public.smart_forms FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.digital_cards
      WHERE id = smart_forms.card_id AND user_id = auth.uid()
    )
  );


-- ============================================================
-- SMART FORM FIELDS
-- ============================================================

-- PÚBLICO: campos de formularios públicos
CREATE POLICY "smart_form_fields_select_public"
  ON public.smart_form_fields FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.smart_forms sf
      JOIN  public.digital_cards dc ON dc.id = sf.card_id
      WHERE sf.id = smart_form_fields.form_id
        AND sf.is_active = true
        AND dc.is_active = true
    )
  );

-- Dueño: acceso total
CREATE POLICY "smart_form_fields_select_owner"
  ON public.smart_form_fields FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.smart_forms sf
      JOIN  public.digital_cards dc ON dc.id = sf.card_id
      WHERE sf.id = smart_form_fields.form_id AND dc.user_id = auth.uid()
    )
  );

CREATE POLICY "smart_form_fields_insert_owner"
  ON public.smart_form_fields FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.smart_forms sf
      JOIN  public.digital_cards dc ON dc.id = sf.card_id
      WHERE sf.id = smart_form_fields.form_id AND dc.user_id = auth.uid()
    )
  );

CREATE POLICY "smart_form_fields_update_owner"
  ON public.smart_form_fields FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.smart_forms sf
      JOIN  public.digital_cards dc ON dc.id = sf.card_id
      WHERE sf.id = smart_form_fields.form_id AND dc.user_id = auth.uid()
    )
  );

CREATE POLICY "smart_form_fields_delete_owner"
  ON public.smart_form_fields FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.smart_forms sf
      JOIN  public.digital_cards dc ON dc.id = sf.card_id
      WHERE sf.id = smart_form_fields.form_id AND dc.user_id = auth.uid()
    )
  );


-- ============================================================
-- FORM SUBMISSIONS
-- ============================================================

-- PÚBLICO INSERT: cualquiera puede enviar un formulario
CREATE POLICY "form_submissions_insert_anon"
  ON public.form_submissions FOR INSERT
  WITH CHECK (true);

-- Dueño de la tarjeta puede leer las respuestas
CREATE POLICY "form_submissions_select_owner"
  ON public.form_submissions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.smart_forms sf
      JOIN  public.digital_cards dc ON dc.id = sf.card_id
      WHERE sf.id = form_submissions.form_id AND dc.user_id = auth.uid()
    )
  );


-- ============================================================
-- MEMBER INTEGRATIONS
-- ============================================================

-- Solo el propio usuario puede ver / gestionar sus integraciones
CREATE POLICY "member_integrations_select_own"
  ON public.member_integrations FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "member_integrations_insert_own"
  ON public.member_integrations FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "member_integrations_update_own"
  ON public.member_integrations FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "member_integrations_delete_own"
  ON public.member_integrations FOR DELETE
  USING (user_id = auth.uid());


-- ============================================================
-- NFC CARDS
-- ============================================================

-- El usuario ve / actualiza su propio NFC card
CREATE POLICY "nfc_cards_select_own"
  ON public.nfc_cards FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "nfc_cards_update_own"
  ON public.nfc_cards FOR UPDATE
  USING (user_id = auth.uid());

-- Admins pueden ver todos los NFC cards de su org
CREATE POLICY "nfc_cards_select_org_admin"
  ON public.nfc_cards FOR SELECT
  USING (
    public.get_my_role() = 'admin'
    AND public.same_org(nfc_cards.user_id)
  );


-- ============================================================
-- CONTACTO WEBPAGE
-- ============================================================

-- Cualquiera puede enviar el formulario de contacto del sitio web
CREATE POLICY "contacto_webpage_insert_anon"
  ON public.contacto_webpage FOR INSERT
  WITH CHECK (true);

-- Solo admins pueden leer los formularios recibidos
CREATE POLICY "contacto_webpage_select_admin"
  ON public.contacto_webpage FOR SELECT
  USING (
    public.get_my_role() = 'admin'
  );
