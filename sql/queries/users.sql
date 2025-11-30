-- name: GetUserByFirebaseUID :one
SELECT * FROM users
WHERE firebase_uid = $1 AND is_deleted = false
LIMIT 1;

-- name: GetUserByID :one
SELECT * FROM users
WHERE id = $1 AND is_deleted = false
LIMIT 1;

-- name: GetUserByEmail :one
SELECT * FROM users
WHERE email = $1 AND is_deleted = false
LIMIT 1;

-- name: CreateUser :one
INSERT INTO users (
  firebase_uid, 
  email, 
  display_name, 
  photo_url
) VALUES (
  $1, $2, $3, $4
)
RETURNING *;

-- name: UpdateUserProfile :one
UPDATE users
SET 
  first_name = COALESCE(sqlc.narg('first_name'), first_name),
  last_name = COALESCE(sqlc.narg('last_name'), last_name),
  profile_picture = COALESCE(sqlc.narg('profile_picture'), profile_picture),
  short_bio = COALESCE(sqlc.narg('short_bio'), short_bio),
  full_bio = COALESCE(sqlc.narg('full_bio'), full_bio),
  resume_url = COALESCE(sqlc.narg('resume_url'), resume_url)
WHERE id = sqlc.arg('id') AND is_deleted = false
RETURNING *;

-- name: SoftDeleteUser :exec
UPDATE users
SET is_deleted = true
WHERE id = $1;

-- name: RestoreUser :exec
UPDATE users
SET is_deleted = false, deleted_at = NULL
WHERE id = $1;
