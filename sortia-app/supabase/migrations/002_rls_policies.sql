-- ================================================================
-- SORTIA — Migration 002: Row Level Security
-- Règle absolue : chaque utilisateur ne voit QUE ses données
-- ================================================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mail_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classification_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.share_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.file_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workflows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vault_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.import_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pa_connections ENABLE ROW LEVEL SECURITY;

-- Policies : chaque utilisateur accède uniquement à SES données

CREATE POLICY "users_own_profile" ON public.user_profiles
  FOR ALL USING (id = auth.uid());

CREATE POLICY "users_own_folders" ON public.folders
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_files" ON public.files
  FOR ALL USING (user_id = auth.uid());

-- Accès aux fichiers partagés via share_links (lecture seule)
CREATE POLICY "shared_file_access" ON public.files
  FOR SELECT USING (
    id IN (
      SELECT file_id FROM public.share_links
      WHERE is_active = TRUE
      AND (expires_at IS NULL OR expires_at > NOW())
      AND (max_downloads IS NULL OR download_count < max_downloads)
    )
  );

CREATE POLICY "users_own_notes" ON public.notes
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_mail" ON public.mail_accounts
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_rules" ON public.classification_rules
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_shares" ON public.share_links
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_versions" ON public.file_versions
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_workflows" ON public.workflows
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_alerts" ON public.alerts
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_vault" ON public.vault_items
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_subscriptions" ON public.subscriptions
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_imports" ON public.import_jobs
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "users_own_pa" ON public.pa_connections
  FOR ALL USING (user_id = auth.uid());
