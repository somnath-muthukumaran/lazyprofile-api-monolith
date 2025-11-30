-- name: GetProjectTags :many
SELECT t.* FROM tags t
INNER JOIN project_tags pt ON t.id = pt.tag_id
WHERE pt.project_id = $1 AND pt.is_deleted = false AND t.is_deleted = false
ORDER BY t.name;

-- name: AddProjectTag :exec
INSERT INTO project_tags (project_id, tag_id)
VALUES ($1, $2)
ON CONFLICT (project_id, tag_id) DO NOTHING;

-- name: RemoveProjectTag :exec
UPDATE project_tags
SET is_deleted = true
WHERE project_id = $1 AND tag_id = $2;

-- name: GetProjectsByTag :many
SELECT p.* FROM projects p
INNER JOIN project_tags pt ON p.id = pt.project_id
WHERE pt.tag_id = $1 AND pt.is_deleted = false AND p.is_deleted = false
ORDER BY p.created_at DESC;
