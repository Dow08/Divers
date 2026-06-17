-- ================================================================
-- SORTIA — Migration 004: Index de performance
-- ================================================================

-- Index composites pour les requêtes fréquentes
CREATE INDEX IF NOT EXISTS idx_files_classification
  ON public.files(user_id, ai_classification);

CREATE INDEX IF NOT EXISTS idx_files_vault
  ON public.files(user_id, is_in_vault) WHERE is_in_vault = TRUE;

CREATE INDEX IF NOT EXISTS idx_files_archived
  ON public.files(user_id, is_archived) WHERE is_archived = TRUE;

CREATE INDEX IF NOT EXISTS idx_files_shared
  ON public.files(user_id, is_shared) WHERE is_shared = TRUE;

CREATE INDEX IF NOT EXISTS idx_files_electronic_invoice
  ON public.files(user_id, is_electronic_invoice) WHERE is_electronic_invoice = TRUE;

CREATE INDEX IF NOT EXISTS idx_notes_user_folder
  ON public.notes(user_id, folder_id);

CREATE INDEX IF NOT EXISTS idx_notes_pinned
  ON public.notes(user_id, is_pinned) WHERE is_pinned = TRUE;

CREATE INDEX IF NOT EXISTS idx_alerts_user_trigger
  ON public.alerts(user_id, trigger_at) WHERE is_dismissed = FALSE;

CREATE INDEX IF NOT EXISTS idx_workflows_user_status
  ON public.workflows(user_id, status);

CREATE INDEX IF NOT EXISTS idx_share_links_token
  ON public.share_links(token) WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS idx_vault_items_user
  ON public.vault_items(user_id, certified_at);

CREATE INDEX IF NOT EXISTS idx_import_jobs_user_status
  ON public.import_jobs(user_id, status);
