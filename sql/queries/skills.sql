-- name: GetSkillByID :one
SELECT * FROM skills
WHERE id = $1 AND is_deleted = false
LIMIT 1;

-- name: ListUserSkills :many
SELECT s.*, sc.name as category_name
FROM skills s
LEFT JOIN skill_categories sc ON s.category_id = sc.id
WHERE s.user_id = $1 AND s.is_deleted = false
ORDER BY sc.display_order, s.display_order;

-- name: ListUserSkillsByCategory :many
SELECT * FROM skills
WHERE user_id = $1 AND category_id = $2 AND is_deleted = false
ORDER BY display_order ASC;

-- name: ListTopSkills :many
SELECT * FROM skills
WHERE user_id = $1 AND is_deleted = false
ORDER BY usage_count DESC, proficiency DESC
LIMIT $2;

-- name: CreateSkill :one
INSERT INTO skills (
  user_id,
  category_id,
  name,
  proficiency,
  icon,
  status,
  display_order
) VALUES (
  $1, $2, $3, $4, $5, $6, $7
)
RETURNING *;

-- name: UpdateSkill :one
UPDATE skills
SET 
  category_id = COALESCE(sqlc.narg('category_id'), category_id),
  name = COALESCE(sqlc.narg('name'), name),
  proficiency = COALESCE(sqlc.narg('proficiency'), proficiency),
  icon = COALESCE(sqlc.narg('icon'), icon),
  status = COALESCE(sqlc.narg('status'), status),
  display_order = COALESCE(sqlc.narg('display_order'), display_order)
WHERE id = sqlc.arg('id') AND is_deleted = false
RETURNING *;

-- name: IncrementSkillUsage :exec
UPDATE skills
SET usage_count = usage_count + 1
WHERE id = $1;

-- name: DecrementSkillUsage :exec
UPDATE skills
SET usage_count = GREATEST(usage_count - 1, 0)
WHERE id = $1;

-- name: SoftDeleteSkill :exec
UPDATE skills
SET is_deleted = true
WHERE id = $1;
