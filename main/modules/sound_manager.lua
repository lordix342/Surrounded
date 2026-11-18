local M = {}

local cooldowns = {}
local MIN_SLASH_INTERVAL = 0.05
local MIN_DEATH_INTERVAL = 0.05
local MIN_HURT_INTERVAL = 0.15

function M.play_music()
	pcall(sound.play, "/sound_manager#music", { gain = 0.55 })
end

function M.stop_music()
	pcall(sound.stop, "/sound_manager#music")
end

function M.play_slash()
	local now = os.clock()
	if not cooldowns.slash or (now - cooldowns.slash) > MIN_SLASH_INTERVAL then
		cooldowns.slash = now
		local pitch = 0.95 + math.random() * 0.1
		local vol = 0.7 + math.random() * 0.1
		pcall(sound.play, "/sound_manager#sound_slash", { gain = vol, speed = pitch })
	end
end

function M.play_hero_hurt()
	local now = os.clock()
	if not cooldowns.hero_hurt or (now - cooldowns.hero_hurt) > MIN_HURT_INTERVAL then
		cooldowns.hero_hurt = now
		pcall(sound.play, "/sound_manager#sound_hero_hurt", { gain = 0.9 })
	end
end

function M.play_enemy_death()
	local now = os.clock()
	if not cooldowns.enemy_death or (now - cooldowns.enemy_death) > MIN_DEATH_INTERVAL then
		cooldowns.enemy_death = now
		local pitch = 0.9 + math.random() * 0.2
		pcall(sound.play, "/sound_manager#sound_enemy_death", { gain = 0.8, speed = pitch })
	end
end

function M.play_chest_open()
	pcall(sound.play, "/sound_manager#sound_chest_open", { gain = 0.95 })
end

return M
