-- name: GetUserSocialLinks :many
SELECT * FROM social_links
WHERE user_id = $1 AND is_deleted = false
ORDER BY display_order ASC;

-- name: GetSocialLinkByPlatform :one
SELECT * FROM social_links
WHERE user_id = $1 AND platform = $2 AND is_deleted = false
LIMIT 1;

-- name: CreateSocialLink :one
INSERT INTO social_links (
  user_id,
  platform,
  url,
  display_order
) VALUES (
  $1, $2, $3, $4
)
RETURNING *;

-- name: UpdateSocialLink :one
UPDATE social_links
SET 
  url = COALESCE(sqlc.narg('url'), url),
  display_order = COALESCE(sqlc.narg('display_order'), display_order)
WHERE id = sqlc.arg('id') AND is_deleted = false
RETURNING *;

-- name: SoftDeleteSocialLink :exec
UPDATE social_links
SET is_deleted = true
WHERE id = $1;
