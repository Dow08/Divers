-- ================================================================
-- SORTIA — Migration 001: Schéma initial
-- Base de données PostgreSQL via Supabase
-- ================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ────────────────────────────────────────────────────────
-- TABLE: user_profiles
-- ────────────────────────────────────────────────────────
CREATE TABLE public.user_profiles (
  id              UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email           TEXT NOT NULL,
  full_name       TEXT,
  avatar_url      TEXT,
  plan            TEXT NOT NULL DEFAULT 'free'
                  CHECK (plan IN ('free', 'starter', 'pro', 'expert', 'business')),
  plan_expires_at TIMESTAMPTZ,
  stripe_customer_id TEXT,
  onboarding_done BOOLEAN DEFAULT FALSE,
  template_chosen TEXT,
  locale          TEXT DEFAULT 'fr',
  timezone        TEXT DEFAULT 'Europe/Paris',
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- TABLE: folders
-- ────────────────────────────────────────────────────────
CREATE TABLE public.folders (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  parent_id       UUID REFERENCES public.folders(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  description     TEXT,
  ai_context      JSONB DEFAULT '{}',
  color           TEXT DEFAULT '#1B4F72',
  icon            TEXT,
  is_locked       BOOLEAN DEFAULT FALSE,
  lock_hint       TEXT,
  lock_hash       TEXT,
  rgpd_retention_days INTEGER,
  rgpd_policy_type TEXT,
  sort_order      INTEGER DEFAULT 0,
  is_archived     BOOLEAN DEFAULT FALSE,
  archived_at     TIMESTAMPTZ,
  path            TEXT,
  depth           INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_folders_user_parent ON public.folders(user_id, parent_id);
CREATE INDEX idx_folders_path ON public.folders USING gin(path gin_trgm_ops);

-- ────────────────────────────────────────────────────────
-- TABLE: files
-- ────────────────────────────────────────────────────────
CREATE TABLE public.files (
  id                UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id           UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  folder_id         UUID REFERENCES public.folders(id) ON DELETE CASCADE NOT NULL,
  name              TEXT NOT NULL,
  original_name     TEXT NOT NULL,
  mime_type         TEXT NOT NULL,
  size_bytes        BIGINT NOT NULL,
  storage_path      TEXT NOT NULL,
  storage_bucket    TEXT DEFAULT 'documents',
  checksum_sha256   TEXT,
  ai_classification TEXT,
  ai_confidence     FLOAT,
  ai_extracted_data JSONB DEFAULT '{}',
  ai_processed_at   TIMESTAMPTZ,
  document_date     DATE,
  document_amount   DECIMAL(15,2),
  document_currency TEXT DEFAULT 'EUR',
  vendor_name       TEXT,
  document_number   TEXT,
  content_text      TEXT,
  search_vector     tsvector,
  version           INTEGER DEFAULT 1,
  parent_version_id UUID REFERENCES public.files(id),
  is_latest_version BOOLEAN DEFAULT TRUE,
  rgpd_expires_at   TIMESTAMPTZ,
  is_archived       BOOLEAN DEFAULT FALSE,
  archived_at       TIMESTAMPTZ,
  is_electronic_invoice BOOLEAN DEFAULT FALSE,
  facturx_data      JSONB,
  is_in_vault       BOOLEAN DEFAULT FALSE,
  vault_certified_at TIMESTAMPTZ,
  vault_certificate_hash TEXT,
  is_shared         BOOLEAN DEFAULT FALSE,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_files_search ON public.files USING gin(search_vector);
CREATE INDEX idx_files_user_folder ON public.files(user_id, folder_id);
CREATE INDEX idx_files_vendor ON public.files(user_id, vendor_name);
CREATE INDEX idx_files_date ON public.files(user_id, document_date);

-- Trigger: mise à jour search_vector
CREATE OR REPLACE FUNCTION update_file_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('french', COALESCE(NEW.name, '')), 'A') ||
    setweight(to_tsvector('french', COALESCE(NEW.vendor_name, '')), 'B') ||
    setweight(to_tsvector('french', COALESCE(NEW.document_number, '')), 'B') ||
    setweight(to_tsvector('french', COALESCE(NEW.content_text, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_file_search_vector
  BEFORE INSERT OR UPDATE ON public.files
  FOR EACH ROW EXECUTE FUNCTION update_file_search_vector();

-- ────────────────────────────────────────────────────────
-- TABLE: notes
-- ────────────────────────────────────────────────────────
CREATE TABLE public.notes (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  folder_id   UUID REFERENCES public.folders(id) ON DELETE CASCADE,
  type        TEXT NOT NULL CHECK (type IN ('text', 'checklist', 'photo', 'voice', 'table')),
  title       TEXT,
  content     JSONB NOT NULL DEFAULT '{}',
  audio_url   TEXT,
  transcript  TEXT,
  is_pinned   BOOLEAN DEFAULT FALSE,
  tags        TEXT[] DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- TABLE: mail_accounts
-- ────────────────────────────────────────────────────────
CREATE TABLE public.mail_accounts (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  provider        TEXT NOT NULL CHECK (provider IN ('gmail', 'outlook', 'imap')),
  email_address   TEXT NOT NULL,
  display_name    TEXT,
  is_personal     BOOLEAN DEFAULT FALSE,
  is_professional BOOLEAN DEFAULT TRUE,
  oauth_token     TEXT,
  oauth_refresh   TEXT,
  imap_host       TEXT,
  imap_port       INTEGER,
  imap_use_ssl    BOOLEAN DEFAULT TRUE,
  last_sync_at    TIMESTAMPTZ,
  sync_enabled    BOOLEAN DEFAULT TRUE,
  folders_watched TEXT[] DEFAULT '{"INBOX"}',
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- TABLE: classification_rules
-- ────────────────────────────────────────────────────────
CREATE TABLE public.classification_rules (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  rule_type       TEXT NOT NULL,
  condition       JSONB NOT NULL,
  target_folder_id UUID REFERENCES public.folders(id),
  ai_classification TEXT,
  confidence_boost FLOAT DEFAULT 0.1,
  use_count       INTEGER DEFAULT 0,
  last_used_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- TABLE: share_links
-- ────────────────────────────────────────────────────────
CREATE TABLE public.share_links (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  file_id         UUID REFERENCES public.files(id) ON DELETE CASCADE,
  folder_id       UUID REFERENCES public.folders(id) ON DELETE CASCADE,
  token           TEXT UNIQUE NOT NULL,
  pin_hash        TEXT,
  expires_at      TIMESTAMPTZ,
  max_downloads   INTEGER,
  download_count  INTEGER DEFAULT 0,
  is_active       BOOLEAN DEFAULT TRUE,
  access_log      JSONB DEFAULT '[]',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- TABLE: file_versions
-- ────────────────────────────────────────────────────────
CREATE TABLE public.file_versions (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  file_id         UUID REFERENCES public.files(id) ON DELETE CASCADE NOT NULL,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  version_number  INTEGER NOT NULL,
  storage_path    TEXT NOT NULL,
  size_bytes      BIGINT NOT NULL,
  checksum_sha256 TEXT,
  change_summary  TEXT,
  changed_by      UUID REFERENCES auth.users(id),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- TABLE: workflows
-- ────────────────────────────────────────────────────────
CREATE TABLE public.workflows (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  file_id         UUID REFERENCES public.files(id) ON DELETE CASCADE NOT NULL,
  title           TEXT NOT NULL,
  status          TEXT DEFAULT 'pending'
                  CHECK (status IN ('pending', 'in_review', 'approved', 'rejected')),
  assigned_to     UUID REFERENCES auth.users(id),
  due_date        TIMESTAMPTZ,
  comments        JSONB DEFAULT '[]',
  history         JSONB DEFAULT '[]',
  reminder_sent_at TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- TABLE: alerts
-- ────────────────────────────────────────────────────────
CREATE TABLE public.alerts (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  type            TEXT NOT NULL,
  title           TEXT NOT NULL,
  message         TEXT,
  related_file_id UUID REFERENCES public.files(id),
  related_folder_id UUID REFERENCES public.folders(id),
  trigger_at      TIMESTAMPTZ NOT NULL,
  is_read         BOOLEAN DEFAULT FALSE,
  is_dismissed    BOOLEAN DEFAULT FALSE,
  priority        TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- TABLE: vault_items
-- ────────────────────────────────────────────────────────
CREATE TABLE public.vault_items (
  id                UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id           UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  file_id           UUID REFERENCES public.files(id) ON DELETE CASCADE NOT NULL,
  certified_at      TIMESTAMPTZ DEFAULT NOW(),
  checksum_sha256   TEXT NOT NULL,
  certificate_data  JSONB NOT NULL,
  integrity_verified_at TIMESTAMPTZ,
  is_valid          BOOLEAN DEFAULT TRUE
);

-- ────────────────────────────────────────────────────────
-- TABLE: subscriptions
-- ────────────────────────────────────────────────────────
CREATE TABLE public.subscriptions (
  id                  UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id             UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  stripe_subscription_id TEXT UNIQUE,
  stripe_price_id     TEXT,
  plan                TEXT NOT NULL,
  status              TEXT NOT NULL,
  current_period_start TIMESTAMPTZ,
  current_period_end  TIMESTAMPTZ,
  cancel_at_period_end BOOLEAN DEFAULT FALSE,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- TABLE: import_jobs
-- ────────────────────────────────────────────────────────
CREATE TABLE public.import_jobs (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  source          TEXT NOT NULL,
  status          TEXT DEFAULT 'pending'
                  CHECK (status IN ('pending', 'running', 'completed', 'failed')),
  total_files     INTEGER DEFAULT 0,
  processed_files INTEGER DEFAULT 0,
  classified_files INTEGER DEFAULT 0,
  failed_files    INTEGER DEFAULT 0,
  error_log       JSONB DEFAULT '[]',
  started_at      TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- TABLE: pa_connections
-- ────────────────────────────────────────────────────────
CREATE TABLE public.pa_connections (
  id              UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  pa_name         TEXT NOT NULL,
  pa_api_key      TEXT,
  pa_company_id   TEXT,
  is_active       BOOLEAN DEFAULT TRUE,
  last_sync_at    TIMESTAMPTZ,
  sync_enabled    BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ────────────────────────────────────────────────────────
-- Trigger: updated_at automatique
-- ────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_profiles_updated BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_folders_updated BEFORE UPDATE ON public.folders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_files_updated BEFORE UPDATE ON public.files FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_workflows_updated BEFORE UPDATE ON public.workflows FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_subscriptions_updated BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at();
