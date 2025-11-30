-- name: GetExperienceSkills :many
SELECT s.* FROM skills s
INNER JOIN experience_skills es ON s.id = es.skill_id
WHERE es.experience_id = $1 AND es.is_deleted = false AND s.is_deleted = false
ORDER BY s.name;

-- name: AddExperienceSkill :exec
INSERT INTO experience_skills (experience_id, skill_id)
VALUES ($1, $2)
ON CONFLICT (experience_id, skill_id) DO NOTHING;

-- name: RemoveExperienceSkill :exec
UPDATE experience_skills
SET is_deleted = true
WHERE experience_id = $1 AND skill_id = $2;