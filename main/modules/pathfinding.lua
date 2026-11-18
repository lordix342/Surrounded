local M = {}

local TILE_SIZE = 16

-- Arena bounds in tile coordinates (covering the playable arena in layer1)
local X_MIN = -46
local X_MAX = 48
local Y_MIN = -41
local Y_MAX = 36

local WIDTH = X_MAX - X_MIN + 1
local HEIGHT = Y_MAX - Y_MIN + 1

-- 8-directional movement costs (orthogonal: 1.0, diagonal: ~1.414)
local WALK_COST = {
	1.0,   -- East
	1.0,   -- North
	1.0,   -- West
	1.0,   -- South
	1.414, -- North-East
	1.414, -- North-West
	1.414, -- South-West
	1.414  -- South-East
}

-- Tiles in main_tile_source.tilesource that have collision_group: "walls" (0-based protobuf IDs)
-- In Defold tilemap.get_tile(), empty tiles return 0, and non-empty tiles return (id + 1).
local WALL_TILE_IDS = {
	[2] = true, [3] = true, [4] = true, [5] = true, [6] = true,
	[7] = true, [8] = true, [9] = true, [10] = true, [11] = true,
	[13] = true, [14] = true, [15] = true, [16] = true, [17] = true,
	[18] = true, [20] = true, [21] = true, [22] = true, [23] = true,
	[24] = true, [25] = true, [26] = true, [27] = true, [28] = true,
	[29] = true, [33] = true, [34] = true, [35] = true, [36] = true,
	[37] = true, [39] = true, [40] = true, [45] = true, [46] = true,
	[47] = true, [57] = true, [58] = true, [59] = true, [63] = true,
}

local initialized = false
local map_data = {}
local grid_walkable = {} -- 2D lookup: [gy][gx] = true/false

local function world_to_tile(wx, wy)
	local tx = math.floor(wx / TILE_SIZE)
	local ty = math.floor(wy / TILE_SIZE)
	return tx, ty
end

local function tile_to_world(tx, ty)
	return tx * TILE_SIZE + (TILE_SIZE * 0.5), ty * TILE_SIZE + (TILE_SIZE * 0.5)
end

local function tile_to_grid(tx, ty)
	local gx = tx - X_MIN + 1
	local gy = ty - Y_MIN + 1
	return gx, gy
end

local function grid_to_tile(gx, gy)
	local tx = gx + X_MIN - 1
	local ty = gy + Y_MIN - 1
	return tx, ty
end

local function is_grid_walkable(gx, gy)
	if gx < 1 or gx > WIDTH or gy < 1 or gy > HEIGHT then
		return false
	end
	return grid_walkable[gy] and grid_walkable[gy][gx] == true
end

-- If a position is inside or touching a wall, snap to the nearest walkable tile
local function snap_to_walkable(gx, gy)
	if is_grid_walkable(gx, gy) then
		return gx, gy
	end

	for r = 1, 4 do
		local best_gx, best_gy = nil, nil
		local best_d = 999999
		for dy = -r, r do
			for dx = -r, r do
				local nx, ny = gx + dx, gy + dy
				if is_grid_walkable(nx, ny) then
					local d = dx * dx + dy * dy
					if d < best_d then
						best_d = d
						best_gx, best_gy = nx, ny
					end
				end
			end
		end
		if best_gx then
			return best_gx, best_gy
		end
	end

	return gx, gy
end

local function is_tile_wall(tile_val)
	if tile_val == nil or tile_val == 0 then
		return false
	end
	return WALL_TILE_IDS[tile_val - 1] == true
end

function M.init(tilemap_url)
	if initialized then
		return
	end

	tilemap_url = tilemap_url or msg.url("/arena#game_arena")

	map_data = {}
	grid_walkable = {}

	for gy = 1, HEIGHT do
		grid_walkable[gy] = {}
		local ty = gy + Y_MIN - 1
		for gx = 1, WIDTH do
			local tx = gx + X_MIN - 1
			local tile = 0
			pcall(function()
				tile = tilemap.get_tile(tilemap_url, hash("layer1"), tx, ty)
			end)

			if is_tile_wall(tile) then
				table.insert(map_data, 0) -- 0 = obstacle
				grid_walkable[gy][gx] = false
			else
				table.insert(map_data, 1) -- 1 = walkable
				grid_walkable[gy][gx] = true
			end
		end
	end

	if astar then
		local direction = astar.DIRECTION_EIGHT
		local allocate = WIDTH * HEIGHT
		local typical_adjacent = 8
		local use_cache = true
		local use_zero = false
		local flip_map = false

		astar.setup(WIDTH, HEIGHT, direction, allocate, typical_adjacent, use_cache, use_zero, flip_map)
		astar.set_map(map_data)

		local costs = {
			[1] = WALK_COST
		}
		astar.set_costs(costs)
		print(string.format("Pathfinding A* initialized: %dx%d grid (DIRECTION_EIGHT)", WIDTH, HEIGHT))
	else
		print("Pathfinding module ready (direct fallback until defold-astar is fetched)")
	end

	initialized = true
end

function M.is_available()
	return initialized and (astar ~= nil)
end

function M.is_walkable_world(world_pos)
	if not initialized then
		M.init()
	end
	local tx, ty = world_to_tile(world_pos.x, world_pos.y)
	local gx, gy = tile_to_grid(tx, ty)
	return is_grid_walkable(gx, gy)
end

-- Returns an array of vector3 waypoints towards the goal, or nil if no path exists
function M.get_path(from_world_pos, to_world_pos)
	if not initialized then
		M.init()
	end

	if not astar then
		return { to_world_pos }
	end

	local start_tx, start_ty = world_to_tile(from_world_pos.x, from_world_pos.y)
	local end_tx, end_ty = world_to_tile(to_world_pos.x, to_world_pos.y)

	local sgx, sgy = tile_to_grid(start_tx, start_ty)
	local egx, egy = tile_to_grid(end_tx, end_ty)

	-- Snap to valid walkable grid cells
	sgx, sgy = snap_to_walkable(sgx, sgy)
	egx, egy = snap_to_walkable(egx, egy)

	if sgx == egx and sgy == egy then
		return { to_world_pos }
	end

	local status, size, total_cost, path = astar.solve(sgx, sgy, egx, egy)

	if status == astar.SOLVED and size and size >= 2 and path then
		local waypoints = {}
		for i = 2, size do
			local node = path[i]
			local ntx, nty = grid_to_tile(node.x, node.y)
			local nwx, nwy = tile_to_world(ntx, nty)
			table.insert(waypoints, vmath.vector3(nwx, nwy, from_world_pos.z))
		end
		-- Final destination is exact hero position
		table.insert(waypoints, to_world_pos)
		return waypoints
	end

	return nil
end

-- Backward compatibility helper returning single next target
function M.get_next_target(from_world_pos, to_world_pos)
	local waypoints = M.get_path(from_world_pos, to_world_pos)
	if waypoints and waypoints[1] then
		return waypoints[1]
	end
	return to_world_pos
end

return M
