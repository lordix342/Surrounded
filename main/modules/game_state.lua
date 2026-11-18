local M = {}

M.enemies = {}
M.paused = false
M.dead = false
M.health = 100
M.max_health = 100

-- XP & Skill Tree Progression
M.level = 1
M.xp = 0
M.xp_next = 65
M.skill_points = 0
M.skills = {}

-- Card Chest Upgrades tracking
M.card_upgrades = {
	extra_sword = 0,
	move_speed = 0,
	max_hp = 0,
	spin_speed = 0,
	shield_barrier = 0,
}
M.CARD_MAX_LEVELS = {
	extra_sword = 4,    -- 2 base + 4 upgrades = 6 max swords
	move_speed = 3,     -- +12 speed * 3 = +36 max speed
	max_hp = 4,         -- +25 max HP * 4 = +100 max HP
	spin_speed = 3,     -- +20% spin * 3 = +60% max spin
	shield_barrier = 4, -- +2 dmg * 4 = +8 max dmg
}
M.card_max_hp_bonus = 0

-- Skill Tree Max Levels
M.SKILL_MAX_LEVELS = {
	fire_aura = 5,
	frost_aura = 5,
	aura_radiance = 5,
	lightning = 5,
	chain_lightning = 5,
	thunderstorm = 5,
	magnet = 5,
	vitality = 5,
	haste = 5,
}

-- Active Skill Effect Stats
M.magnet_radius = 50
M.fire_aura_level = 0
M.frost_aura_level = 0
M.aura_radiance_level = 0
M.lightning_level = 0
M.chain_level = 0
M.thunder_level = 0
M.regen_rate = 0
M.swift_speed_mult = 1.0

function M.register_enemy(id)
	if id then
		M.enemies[id] = true
	end
end

function M.unregister_enemy(id)
	if id then
		M.enemies[id] = nil
	end
end

function M.for_each_enemy(callback)
	for id, _ in pairs(M.enemies) do
		callback(id)
	end
end

function M.is_running()
	return (not M.paused) and (not M.dead)
end

function M.set_paused(paused)
	M.paused = not not paused
end

function M.set_dead(dead)
	M.dead = not not dead
	if M.dead then
		M.paused = true
	end
end

function M.set_health(health, max_health)
	M.max_health = max_health or M.max_health
	M.health = math.max(0, math.min(health, M.max_health))
end

function M.get_card_upgrade_count(id)
	return (M.card_upgrades and M.card_upgrades[id]) or 0
end

function M.is_card_maxed(id)
	local max_lvl = M.CARD_MAX_LEVELS[id]
	if not max_lvl then
		return false
	end
	return M.get_card_upgrade_count(id) >= max_lvl
end

function M.record_card_upgrade(id)
	if not M.card_upgrades then
		M.card_upgrades = {}
	end
	M.card_upgrades[id] = (M.card_upgrades[id] or 0) + 1
	if id == "max_hp" then
		M.card_max_hp_bonus = (M.card_max_hp_bonus or 0) + 25
		M.apply_skill_effects()
	end
end

function M.get_remaining_skill_points_needed()
	local needed = 0
	local has_fire = (M.get_skill_level("fire_aura") > 0)
	local has_frost = (M.get_skill_level("frost_aura") > 0)

	for skill_id, max_lvl in pairs(M.SKILL_MAX_LEVELS) do
		local skip = false
		if skill_id == "fire_aura" and has_frost then
			skip = true
		elseif skill_id == "frost_aura" and has_fire then
			skip = true
		end

		if not skip then
			local cur = M.get_skill_level(skill_id)
			if cur < max_lvl then
				needed = needed + (max_lvl - cur)
			end
		end
	end

	-- Subtract 5 for mutually exclusive second aura if neither chosen yet
	if not has_fire and not has_frost then
		needed = math.max(0, needed - 5)
	end

	return needed
end

function M.is_skill_tree_maxed()
	local needed = M.get_remaining_skill_points_needed()
	return (needed <= 0) or (M.skill_points >= needed)
end

function M.add_xp(amount)
	if M.is_skill_tree_maxed() then
		M.xp = M.xp_next
		return false
	end

	M.xp = M.xp + (amount or 10)
	local leveled_up = false
	while M.xp >= M.xp_next do
		if M.is_skill_tree_maxed() then
			M.xp = M.xp_next
			break
		end
		M.xp = M.xp - M.xp_next
		M.level = M.level + 1
		M.skill_points = M.skill_points + 1
		M.xp_next = math.floor(35 + M.level * 22 + (M.level ^ 1.45) * 9)
		leveled_up = true
	end
	return leveled_up
end

function M.get_skill_level(id)
	return M.skills[id] or 0
end

function M.has_skill(id)
	return (M.skills[id] or 0) > 0
end

function M.can_unlock_skill(id)
	local cur_lvl = M.get_skill_level(id)
	if cur_lvl >= 5 then
		return false, "MAX"
	end

	-- 1. Mutual exclusivity for Auras
	if id == "fire_aura" and M.get_skill_level("frost_aura") > 0 then
		return false, "EXCLUSIVE_FROST"
	end
	if id == "frost_aura" and M.get_skill_level("fire_aura") > 0 then
		return false, "EXCLUSIVE_FIRE"
	end

	-- 2. Prerequisite check (previous skill must be unlocked, level >= 1)
	if id == "aura_radiance" then
		if M.get_skill_level("fire_aura") == 0 and M.get_skill_level("frost_aura") == 0 then
			return false, "REQUIRES_AURA"
		end
	elseif id == "chain_lightning" then
		if M.get_skill_level("lightning") == 0 then
			return false, "REQUIRES_LIGHTNING"
		end
	elseif id == "thunderstorm" then
		if M.get_skill_level("chain_lightning") == 0 then
			return false, "REQUIRES_CHAIN"
		end
	elseif id == "vitality" then
		if M.get_skill_level("magnet") == 0 then
			return false, "REQUIRES_MAGNET"
		end
	elseif id == "haste" then
		if M.get_skill_level("vitality") == 0 then
			return false, "REQUIRES_VITALITY"
		end
	end

	if M.skill_points < 1 then
		return false, "NEED_SP"
	end

	return true, "READY"
end

function M.apply_skill_effects()
	M.fire_aura_level = M.get_skill_level("fire_aura")
	M.frost_aura_level = M.get_skill_level("frost_aura")
	M.aura_radiance_level = M.get_skill_level("aura_radiance")

	M.lightning_level = M.get_skill_level("lightning")
	M.chain_level = M.get_skill_level("chain_lightning")
	M.thunder_level = M.get_skill_level("thunderstorm")

	local mag_lvl = M.get_skill_level("magnet")
	M.magnet_radius = 50 + mag_lvl * 30

	local vit_lvl = M.get_skill_level("vitality")
	M.regen_rate = vit_lvl * 0.75

	local target_max = 100 + (M.card_max_hp_bonus or 0) + (vit_lvl * 20)
	if target_max > M.max_health then
		local diff = target_max - M.max_health
		M.max_health = target_max
		M.health = math.min(M.max_health, M.health + diff)
	else
		M.max_health = target_max
		M.health = math.min(M.max_health, M.health)
	end

	local haste_lvl = M.get_skill_level("haste")
	M.swift_speed_mult = 1.0 + haste_lvl * 0.04
end

function M.unlock_skill(id)
	local can, reason = M.can_unlock_skill(id)
	if not can then
		return false, reason
	end

	M.skill_points = M.skill_points - 1
	local next_lvl = M.get_skill_level(id) + 1
	M.skills[id] = next_lvl

	M.apply_skill_effects()
	return true, next_lvl
end

function M.reset()
	M.enemies = {}
	M.paused = false
	M.dead = false
	M.health = 100
	M.max_health = 100
	M.level = 1
	M.xp = 0
	M.xp_next = 65
	M.skill_points = 0
	M.skills = {}
	M.card_upgrades = {
		extra_sword = 0,
		move_speed = 0,
		max_hp = 0,
		spin_speed = 0,
		shield_barrier = 0,
	}
	M.card_max_hp_bonus = 0
	M.magnet_radius = 50
	M.fire_aura_level = 0
	M.frost_aura_level = 0
	M.aura_radiance_level = 0
	M.lightning_level = 0
	M.chain_level = 0
	M.thunder_level = 0
	M.regen_rate = 0
	M.swift_speed_mult = 1.0
end

return M
