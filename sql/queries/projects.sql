-- ===========================================
-- sql/queries/projects.sql
-- ===========================================

-- name: GetProjectByID :one
SELECT * FROM projects
WHERE id = $1 AND is_deleted = false
LIMIT 1;

-- name: GetProjectBySlug :one
SELECT * FROM projects
WHERE slug = $1 AND user_id = $2 AND is_deleted = false
LIMIT 1;

-- name: ListUserProjects :many
SELECT * FROM projects
WHERE user_id = $1 AND is_deleted = false
ORDER BY display_order ASC, created_at DESC;

-- name: ListFeaturedProjects :many
SELECT * FROM projects
WHERE user_id = $1 AND is_featured = true AND is_deleted = false
ORDER BY display_order ASC
LIMIT $2;

-- name: ListProjectsByStatus :many
SELECT * FROM projects
WHERE user_id = $1 AND status = $2 AND is_deleted = false
ORDER BY created_at DESC;

-- name: CreateProject :one
INSERT INTO projects (
  user_id,
  category_id,
  title,
  slug,
  short_description,
  full_description,
  cover_image,
  status,
  live_url,
  github_url,
  display_order,
  is_featured
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
)
RETURNING *;

-- name: UpdateProject :one
UPDATE projects
SET 
  category_id = COALESCE(sqlc.narg('category_id'), category_id),
  title = COALESCE(sqlc.narg('title'), title),
  slug = COALESCE(sqlc.narg('slug'), slug),
  short_description = COALESCE(sqlc.narg('short_description'), short_description),
  full_description = COALESCE(sqlc.narg('full_description'), full_description),
  cover_image = COALESCE(sqlc.narg('cover_image'), cover_image),
  status = COALESCE(sqlc.narg('status'), status),
  live_url = COALESCE(sqlc.narg('live_url'), live_url),
  github_url = COALESCE(sqlc.narg('github_url'), github_url),
  display_order = COALESCE(sqlc.narg('display_order'), display_order),
  is_featured = COALESCE(sqlc.narg('is_featured'), is_featured)
WHERE id = sqlc.arg('id') AND is_deleted = false
RETURNING *;

-- name: IncrementProjectImageCount :exec
UPDATE projects
SET image_count = image_count + 1
WHERE id = $1;

-- name: DecrementProjectImageCount :exec
UPDATE projects
SET image_count = GREATEST(image_count - 1, 0)
WHERE id = $1;

-- name: IncrementProjectTagCount :exec
UPDATE projects
SET tag_count = tag_count + 1
WHERE id = $1;

-- name: DecrementProjectTagCount :exec
UPDATE projects
SET tag_count = GREATEST(tag_count - 1, 0)
WHERE id = $1;

-- name: SoftDeleteProject :exec
UPDATE projects
SET is_deleted = true
WHERE id = $1;