-- Run this in Supabase SQL Editor to enable avatar and company logo persistence.
-- After running this migration, re-enable profile_photo_url and company_logo_url
-- in digital_card_model.dart toJson() by removing the comment block.

ALTER TABLE public.digital_cards
  ADD COLUMN IF NOT EXISTS profile_photo_url TEXT,
  ADD COLUMN IF NOT EXISTS company_logo_url  TEXT;
