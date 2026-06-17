-- ================================================================
-- SORTIA — Migration 005: Fonctions RPC Dashboard
-- ================================================================

-- Fonction 1 : Stockage total utilisé
CREATE OR REPLACE FUNCTION get_user_storage_used(p_user_id UUID)
RETURNS BIGINT LANGUAGE SQL SECURITY DEFINER STABLE AS $$
  SELECT COALESCE(SUM(size_bytes), 0)::BIGINT
  FROM public.files
  WHERE user_id = p_user_id AND is_latest_version = TRUE AND is_archived = FALSE;
$$;
REVOKE ALL ON FUNCTION get_user_storage_used FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_user_storage_used TO authenticated;

-- Fonction 2 : Top N catégories IA
CREATE OR REPLACE FUNCTION get_top_categories(p_user_id UUID, p_limit INT DEFAULT 5)
RETURNS TABLE (ai_classification TEXT, count BIGINT)
LANGUAGE SQL SECURITY DEFINER STABLE AS $$
  SELECT COALESCE(ai_classification, 'other') AS ai_classification, COUNT(*) AS count
  FROM public.files
  WHERE user_id = p_user_id AND is_latest_version = TRUE AND is_archived = FALSE
  GROUP BY ai_classification ORDER BY count DESC LIMIT p_limit;
$$;
REVOKE ALL ON FUNCTION get_top_categories FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_top_categories TO authenticated;

-- Fonction 3 : Activité mensuelle sur N mois glissants
CREATE OR REPLACE FUNCTION get_monthly_activity(p_user_id UUID, p_months INT DEFAULT 6)
RETURNS TABLE (year INT, month INT, files_added BIGINT)
LANGUAGE SQL SECURITY DEFINER STABLE AS $$
  SELECT EXTRACT(YEAR FROM created_at)::INT AS year,
         EXTRACT(MONTH FROM created_at)::INT AS month,
         COUNT(*) AS files_added
  FROM public.files
  WHERE user_id = p_user_id AND is_latest_version = TRUE
    AND created_at >= NOW() - (p_months || ' months')::INTERVAL
  GROUP BY year, month ORDER BY year ASC, month ASC;
$$;
REVOKE ALL ON FUNCTION get_monthly_activity FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_monthly_activity TO authenticated;

-- Index performance dashboard
CREATE INDEX IF NOT EXISTS idx_files_storage_calc
  ON public.files(user_id, is_latest_version, is_archived) INCLUDE (size_bytes);
CREATE INDEX IF NOT EXISTS idx_files_ai_classification
  ON public.files(user_id, ai_classification)
  WHERE is_latest_version = TRUE AND is_archived = FALSE;
CREATE INDEX IF NOT EXISTS idx_files_created_month
  ON public.files(user_id, created_at) WHERE is_latest_version = TRUE;
