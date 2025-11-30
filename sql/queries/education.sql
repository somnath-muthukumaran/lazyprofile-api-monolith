-- name: GetEducationByID :one
SELECT * FROM education
WHERE id = $1 AND is_deleted = false
LIMIT 1;

-- name: ListUserEducation :many
SELECT * FROM education
WHERE user_id = $1 AND is_deleted = false
ORDER BY is_currently_studying DESC, start_date DESC;

-- name: CreateEducation :one
INSERT INTO education (
  user_id,
  institution_name,
  institution_logo,
  degree,
  field_of_study,
  start_date,
  end_date,
  is_currently_studying,
  description,
  status,
  display_order,
  duration_years
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
)
RETURNING *;

-- name: UpdateEducation :one
UPDATE education
SET 
  institution_name = COALESCE(sqlc.narg('institution_name'), institution_name),
  institution_logo = COALESCE(sqlc.narg('institution_logo'), institution_logo),
  degree = COALESCE(sqlc.narg('degree'), degree),
  field_of_study = COALESCE(sqlc.narg('field_of_study'), field_of_study),
  start_date = COALESCE(sqlc.narg('start_date'), start_date),
  end_date = sqlc.narg('end_date'),
  is_currently_studying = COALESCE(sqlc.narg('is_currently_studying'), is_currently_studying),
  description = COALESCE(sqlc.narg('description'), description),
  status = COALESCE(sqlc.narg('status'), status),
  display_order = COALESCE(sqlc.narg('display_order'), display_order),
  duration_years = COALESCE(sqlc.narg('duration_years'), duration_years)
WHERE id = sqlc.arg('id') AND is_deleted = false
RETURNING *;

-- name: SoftDeleteEducation :exec
UPDATE education
SET is_deleted = true
WHERE id = $1;
