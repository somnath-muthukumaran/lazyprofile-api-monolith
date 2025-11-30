CREATE TYPE content_status AS ENUM (
  'draft',
  'published',
  'archived'
);

CREATE TYPE social_platform AS ENUM (
  'linkedin',
  'twitter',
  'facebook',
  'instagram',
  'youtube',
  'pinterest',
  'tiktok',
  'behance',
  'dribbble',
  'github',
  'medium',
  'devto',
  'stackoverflow',
  'twitch',
  'discord'
);

-- ==========================================
-- TABLES
-- ==========================================

-- --- 1. USERS & PROFILE (MERGED) ---
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  
  -- Firebase Auth fields
  firebase_uid VARCHAR(128) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  display_name VARCHAR(255),
  photo_url TEXT,
  
  -- Profile/About fields (all nullable - filled during onboarding)
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  profile_picture TEXT,
  short_bio VARCHAR(255),
  full_bio TEXT,
  resume_url TEXT,
  
  -- Metadata
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

-- Indexes for users
CREATE UNIQUE INDEX idx_users_firebase_uid_not_deleted ON users (firebase_uid) WHERE is_deleted = false;
CREATE INDEX idx_users_email_not_deleted ON users (email) WHERE is_deleted = false;
CREATE INDEX idx_users_created_at ON users (created_at);

-- Comments for users
COMMENT ON COLUMN users.firebase_uid IS 'Firebase Auth UID - primary identifier';
COMMENT ON COLUMN users.display_name IS 'From Firebase Auth, can be overridden';
COMMENT ON COLUMN users.photo_url IS 'From Firebase Auth profile picture';
COMMENT ON COLUMN users.profile_picture IS 'Custom profile pic URL, overrides photo_url';

-- --- 2. API CONFIGS ---
CREATE TABLE api_configs (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  api_key VARCHAR(255) UNIQUE NOT NULL,
  allowed_origins TEXT, -- JSON array or comma-separated
  is_active BOOLEAN NOT NULL DEFAULT true,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_api_configs_user_id ON api_configs (user_id) WHERE is_deleted = false;
CREATE INDEX idx_api_configs_api_key ON api_configs (api_key) WHERE is_deleted = false;

COMMENT ON COLUMN api_configs.allowed_origins IS 'JSON array or comma-separated list of allowed origins';

-- --- 3. CONTACT INFO ---
CREATE TABLE contact_info (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  email VARCHAR(255),
  phone VARCHAR(50),
  address TEXT,
  city VARCHAR(100),
  state VARCHAR(100),
  zip VARCHAR(20),
  country VARCHAR(100),
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_contact_info_user_id ON contact_info (user_id) WHERE is_deleted = false;

-- --- 4. SOCIAL LINKS ---
CREATE TABLE social_links (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform social_platform NOT NULL,
  url TEXT NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_social_links_user_platform ON social_links (user_id, platform) WHERE is_deleted = false;
CREATE INDEX idx_social_links_user_order ON social_links (user_id, display_order) WHERE is_deleted = false;

-- --- 5. PROJECT CATEGORIES ---
CREATE TABLE project_categories (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL,
  description TEXT,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_project_categories_slug_user ON project_categories (slug, user_id) WHERE is_deleted = false;
CREATE INDEX idx_project_categories_user_id ON project_categories (user_id) WHERE is_deleted = false;

-- --- 6. SKILL CATEGORIES ---
CREATE TABLE skill_categories (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_skill_categories_user_order ON skill_categories (user_id, display_order) WHERE is_deleted = false;

-- --- 7. PROJECTS ---
CREATE TABLE projects (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id BIGINT REFERENCES project_categories(id) ON DELETE SET NULL,
  
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  short_description VARCHAR(255),
  full_description TEXT,
  cover_image TEXT,
  status content_status NOT NULL DEFAULT 'draft',
  live_url TEXT,
  github_url TEXT,
  display_order INT NOT NULL DEFAULT 0,
  is_featured BOOLEAN NOT NULL DEFAULT false,
  
  -- Denormalized counts for performance
  image_count INT NOT NULL DEFAULT 0,
  tag_count INT NOT NULL DEFAULT 0,
  
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_projects_slug_user ON projects (slug, user_id) WHERE is_deleted = false;
CREATE INDEX idx_projects_user_featured ON projects (user_id, is_featured) WHERE is_deleted = false;
CREATE INDEX idx_projects_user_status ON projects (user_id, status) WHERE is_deleted = false;
CREATE INDEX idx_projects_created_at ON projects (created_at) WHERE is_deleted = false;

COMMENT ON COLUMN projects.image_count IS 'Denormalized count - updated via triggers or app logic';
COMMENT ON COLUMN projects.tag_count IS 'Denormalized count - updated via triggers or app logic';

-- --- 8. PROJECT IMAGES ---
CREATE TABLE project_images (
  id BIGSERIAL PRIMARY KEY,
  project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  caption VARCHAR(255),
  display_order INT NOT NULL DEFAULT 0,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_project_images_project_order ON project_images (project_id, display_order) WHERE is_deleted = false;

-- --- 9. TAGS ---
CREATE TABLE tags (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_tags_slug ON tags (slug) WHERE is_deleted = false;

-- --- 10. PROJECT TAGS (Junction Table) ---
CREATE TABLE project_tags (
  project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  tag_id BIGINT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  
  PRIMARY KEY (project_id, tag_id)
);

CREATE INDEX idx_project_tags_project ON project_tags (project_id) WHERE is_deleted = false;
CREATE INDEX idx_project_tags_tag ON project_tags (tag_id) WHERE is_deleted = false;

-- --- 11. SKILLS ---
CREATE TABLE skills (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id BIGINT REFERENCES skill_categories(id) ON DELETE SET NULL,
  
  name VARCHAR(100) NOT NULL,
  proficiency INT CHECK (proficiency >= 0 AND proficiency <= 100),
  icon VARCHAR(255),
  status content_status NOT NULL DEFAULT 'draft',
  display_order INT NOT NULL DEFAULT 0,
  
  -- Denormalized usage count
  usage_count INT NOT NULL DEFAULT 0,
  
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_skills_user_category ON skills (user_id, category_id) WHERE is_deleted = false;
CREATE INDEX idx_skills_user_usage ON skills (user_id, usage_count DESC) WHERE is_deleted = false;

COMMENT ON COLUMN skills.proficiency IS 'Scale of 0-100';
COMMENT ON COLUMN skills.usage_count IS 'How many projects/experiences use this skill';

-- --- 12. EXPERIENCE ---
CREATE TABLE experience (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  company_name VARCHAR(255) NOT NULL,
  company_logo TEXT,
  position VARCHAR(255) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  is_currently_working BOOLEAN NOT NULL DEFAULT false,
  description TEXT,
  location VARCHAR(255),
  status content_status NOT NULL DEFAULT 'draft',
  display_order INT NOT NULL DEFAULT 0,
  
  -- Denormalized duration in months
  duration_months INT,
  
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  
  CONSTRAINT chk_experience_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE INDEX idx_experience_user_start_date ON experience (user_id, start_date DESC) WHERE is_deleted = false;
CREATE INDEX idx_experience_user_current ON experience (user_id, is_currently_working) WHERE is_deleted = false;

COMMENT ON COLUMN experience.duration_months IS 'Denormalized for sorting/filtering - calculated on save';

-- --- 13. EXPERIENCE SKILLS (Junction Table) ---
CREATE TABLE experience_skills (
  experience_id BIGINT NOT NULL REFERENCES experience(id) ON DELETE CASCADE,
  skill_id BIGINT NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  
  PRIMARY KEY (experience_id, skill_id)
);

CREATE INDEX idx_experience_skills_experience ON experience_skills (experience_id) WHERE is_deleted = false;
CREATE INDEX idx_experience_skills_skill ON experience_skills (skill_id) WHERE is_deleted = false;

-- --- 14. EDUCATION ---
CREATE TABLE education (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  institution_name VARCHAR(255) NOT NULL,
  institution_logo TEXT,
  degree VARCHAR(255) NOT NULL,
  field_of_study VARCHAR(255),
  start_date DATE NOT NULL,
  end_date DATE,
  is_currently_studying BOOLEAN NOT NULL DEFAULT false,
  description TEXT,
  status content_status NOT NULL DEFAULT 'draft',
  display_order INT NOT NULL DEFAULT 0,
  
  -- Denormalized duration in years
  duration_years INT,
  
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  
  CONSTRAINT chk_education_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE INDEX idx_education_user_start_date ON education (user_id, start_date DESC) WHERE is_deleted = false;
CREATE INDEX idx_education_user_current ON education (user_id, is_currently_studying) WHERE is_deleted = false;

COMMENT ON COLUMN education.duration_years IS 'Denormalized for display - calculated on save';

-- --- 15. TESTIMONIALS ---
CREATE TABLE testimonials (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  client_name VARCHAR(255) NOT NULL,
  client_position VARCHAR(255),
  client_company VARCHAR(255),
  client_photo TEXT,
  content TEXT NOT NULL,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  project_id BIGINT REFERENCES projects(id) ON DELETE SET NULL,
  status content_status NOT NULL DEFAULT 'draft',
  display_order INT NOT NULL DEFAULT 0,
  
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_testimonials_user_status ON testimonials (user_id, status) WHERE is_deleted = false;
CREATE INDEX idx_testimonials_project ON testimonials (project_id) WHERE is_deleted = false;
CREATE INDEX idx_testimonials_rating ON testimonials (rating DESC) WHERE is_deleted = false;

COMMENT ON COLUMN testimonials.rating IS '1-5 stars rating';
COMMENT ON COLUMN testimonials.project_id IS 'Optional link to specific project';

-- ==========================================
-- TRIGGERS FOR AUTO-UPDATING updated_at
-- ==========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_api_configs_updated_at BEFORE UPDATE ON api_configs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contact_info_updated_at BEFORE UPDATE ON contact_info
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_social_links_updated_at BEFORE UPDATE ON social_links
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_project_categories_updated_at BEFORE UPDATE ON project_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skill_categories_updated_at BEFORE UPDATE ON skill_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skills_updated_at BEFORE UPDATE ON skills
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_experience_updated_at BEFORE UPDATE ON experience
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_education_updated_at BEFORE UPDATE ON education
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_testimonials_updated_at BEFORE UPDATE ON testimonials
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- TRIGGER FOR AUTO-SETTING deleted_at
-- ==========================================

CREATE OR REPLACE FUNCTION set_deleted_at_column()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_deleted = true AND OLD.is_deleted = false THEN
    NEW.deleted_at = NOW();
  ELSIF NEW.is_deleted = false AND OLD.is_deleted = true THEN
    NEW.deleted_at = NULL;
  END IF;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all tables with soft delete
CREATE TRIGGER set_users_deleted_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_api_configs_deleted_at BEFORE UPDATE ON api_configs
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_contact_info_deleted_at BEFORE UPDATE ON contact_info
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_social_links_deleted_at BEFORE UPDATE ON social_links
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_project_categories_deleted_at BEFORE UPDATE ON project_categories
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_skill_categories_deleted_at BEFORE UPDATE ON skill_categories
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_projects_deleted_at BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_project_images_deleted_at BEFORE UPDATE ON project_images
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_tags_deleted_at BEFORE UPDATE ON tags
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_project_tags_deleted_at BEFORE UPDATE ON project_tags
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_skills_deleted_at BEFORE UPDATE ON skills
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_experience_deleted_at BEFORE UPDATE ON experience
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_experience_skills_deleted_at BEFORE UPDATE ON experience_skills
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_education_deleted_at BEFORE UPDATE ON education
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();

CREATE TRIGGER set_testimonials_deleted_at BEFORE UPDATE ON testimonials
  FOR EACH ROW EXECUTE FUNCTION set_deleted_at_column();