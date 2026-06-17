-- ================================================================
-- SORTIA — Migration 003: Functions & Triggers
-- ================================================================

-- Fonction: créer automatiquement le profil utilisateur après inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Fonction: calculer le chemin complet d'un dossier
CREATE OR REPLACE FUNCTION public.calculate_folder_path()
RETURNS TRIGGER AS $$
DECLARE
  parent_path TEXT;
BEGIN
  IF NEW.parent_id IS NULL THEN
    NEW.path := '/' || NEW.name;
    NEW.depth := 0;
  ELSE
    SELECT path INTO parent_path FROM public.folders WHERE id = NEW.parent_id;
    NEW.path := parent_path || '/' || NEW.name;
    NEW.depth := array_length(string_to_array(NEW.path, '/'), 1) - 1;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calculate_folder_path
  BEFORE INSERT OR UPDATE OF name, parent_id ON public.folders
  FOR EACH ROW EXECUTE FUNCTION public.calculate_folder_path();

-- Fonction: vérifier les quotas de stockage par plan
CREATE OR REPLACE FUNCTION public.check_storage_quota()
RETURNS TRIGGER AS $$
DECLARE
  total_size BIGINT;
  max_size BIGINT;
  user_plan TEXT;
BEGIN
  SELECT plan INTO user_plan FROM public.user_profiles WHERE id = NEW.user_id;

  SELECT COALESCE(SUM(size_bytes), 0) INTO total_size
  FROM public.files WHERE user_id = NEW.user_id;

  -- Limites par plan (en bytes)
  max_size := CASE user_plan
    WHEN 'free' THEN 524288000        -- 500 Mo
    WHEN 'starter' THEN 5368709120    -- 5 Go
    WHEN 'pro' THEN 21474836480       -- 20 Go
    WHEN 'expert' THEN 53687091200    -- 50 Go
    WHEN 'business' THEN 107374182400 -- 100 Go
    ELSE 524288000
  END;

  IF (total_size + NEW.size_bytes) > max_size THEN
    RAISE EXCEPTION 'Quota de stockage dépassé. Plan actuel: %, limite: % Mo',
      user_plan, max_size / 1048576;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_storage_quota
  BEFORE INSERT ON public.files
  FOR EACH ROW EXECUTE FUNCTION public.check_storage_quota();
