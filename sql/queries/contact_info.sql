-- name: GetUserContactInfo :one
SELECT * FROM contact_info
WHERE user_id = $1 AND is_deleted = false
LIMIT 1;

-- name: CreateContactInfo :one
INSERT INTO contact_info (
  user_id,
  email,
  phone,
  address,
  city,
  state,
  zip,
  country
) VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8
)
RETURNING *;

-- name: UpdateContactInfo :one
UPDATE contact_info
SET 
  email = COALESCE(sqlc.narg('email'), email),
  phone = COALESCE(sqlc.narg('phone'), phone),
  address = COALESCE(sqlc.narg('address'), address),
  city = COALESCE(sqlc.narg('city'), city),
  state = COALESCE(sqlc.narg('state'), state),
  zip = COALESCE(sqlc.narg('zip'), zip),
  country = COALESCE(sqlc.narg('country'), country)
WHERE user_id = sqlc.arg('user_id') AND is_deleted = false
RETURNING *;
