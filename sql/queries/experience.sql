-- name: GetExperienceByID :one
SELECT * FROM experience
WHERE id = $1 AND is_deleted = false
LIMIT 1;

-- name: ListUserExperience :many
SELECT * FROM experience
WHERE user_id = $1 AND is_deleted = false
ORDER BY is_currently_working DESC, start_date DESC;

-- name: GetCurrentExperience :many
SELECT * FROM experience
WHERE user_id = $1 AND is_currently_working = true AND is_deleted = false
ORDER BY start_date DESC;

-- name: CreateExperience :one
INSERT INTO experience (
  user_id,
  company_name,
  company_logo,
  position,
  start_date,
  end_date,
  is_currently_working,
  description,
  location,
  status,
  display_order,
  duration_months
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
)
RETURNING *;

-- name: UpdateExperience :one
UPDATE experience
SET 
  company_name = COALESCE(sqlc.narg('company_name'), company_name),
  company_logo = COALESCE(sqlc.narg('company_logo'), company_logo),
  position = COALESCE(sqlc.narg('position'), position),
  start_date = COALESCE(sqlc.narg('start_date'), start_date),
  end_date = sqlc.narg('end_date'),
  is_currently_working = COALESCE(sqlc.narg('is_currently_working'), is_currently_working),
  description = COALESCE(sqlc.narg('description'), description),
  location = COALESCE(sqlc.narg('location'), location),
  status = COALESCE(sqlc.narg('status'), status),
  display_order = COALESCE(sqlc.narg('display_order'), display_order),
  duration_months = COALESCE(sqlc.narg('duration_months'), duration_months)
WHERE id = sqlc.arg('id') AND is_deleted = false
RETURNING *;

-- name: SoftDeleteExperience :exec
UPDATE experience
SET is_deleted = true
WHERE id = $1;
