
-- name: GetTagByID :one
SELECT * FROM tags
WHERE id = $1 AND is_deleted = false
LIMIT 1;

-- name: GetTagBySlug :one
SELECT * FROM tags
WHERE slug = $1 AND is_deleted = false
LIMIT 1;

-- name: ListTags :many
SELECT * FROM tags
WHERE is_deleted = false
ORDER BY name ASC;

-- name: CreateTag :one
INSERT INTO tags (name, slug)
VALUES ($1, $2)
RETURNING *;

-- name: GetOrCreateTag :one
INSERT INTO tags (name, slug)
VALUES ($1, $2)
ON CONFLICT (slug) DO UPDATE SET slug = EXCLUDED.slug
RETURNING *;
