-- Team-wide consistency toggles used by the Administration / Integrations view.
ALTER TABLE public.organizations
ADD COLUMN IF NOT EXISTS shared_design_enabled boolean NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS shared_forms_enabled boolean NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS shared_integrations_enabled boolean NOT NULL DEFAULT false;
