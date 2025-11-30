-- name: GetTestimonialByID :one
SELECT * FROM testimonials
WHERE id = $1 AND is_deleted = false
LIMIT 1;

-- name: ListUserTestimonials :many
SELECT * FROM testimonials
WHERE user_id = $1 AND is_deleted = false
ORDER BY rating DESC, created_at DESC;

-- name: ListProjectTestimonials :many
SELECT * FROM testimonials
WHERE project_id = $1 AND is_deleted = false
ORDER BY rating DESC, created_at DESC;

-- name: CreateTestimonial :one
INSERT INTO testimonials (
  user_id,
  client_name,
  client_position,
  client_company,
  client_photo,
  content,
  rating,
  project_id,
  status,
  display_order
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
)
RETURNING *;

-- name: UpdateTestimonial :one
UPDATE testimonials
SET 
  client_name = COALESCE(sqlc.narg('client_name'), client_name),
  client_position = COALESCE(sqlc.narg('client_position'), client_position),
  client_company = COALESCE(sqlc.narg('client_company'), client_company),
  client_photo = COALESCE(sqlc.narg('client_photo'), client_photo),
  content = COALESCE(sqlc.narg('content'), content),
  rating = COALESCE(sqlc.narg('rating'), rating),
  project_id = sqlc.narg('project_id'),
  status = COALESCE(sqlc.narg('status'), status),
  display_order = COALESCE(sqlc.narg('display_order'), display_order)
WHERE id = sqlc.arg('id') AND is_deleted = false
RETURNING *;

-- name: SoftDeleteTestimonial :exec
UPDATE testimonials
SET is_deleted = true
WHERE id = $1;