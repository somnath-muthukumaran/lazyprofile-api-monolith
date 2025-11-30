-- name: GetProjectImages :many
SELECT * FROM project_images
WHERE project_id = $1 AND is_deleted = false
ORDER BY display_order ASC;

-- name: CreateProjectImage :one
INSERT INTO project_images (
  project_id,
  image_url,
  caption,
  display_order
) VALUES (
  $1, $2, $3, $4
)
RETURNING *;

-- name: UpdateProjectImageOrder :exec
UPDATE project_images
SET display_order = $2
WHERE id = $1;

-- name: SoftDeleteProjectImage :exec
UPDATE project_images
SET is_deleted = true
WHERE id = $1;