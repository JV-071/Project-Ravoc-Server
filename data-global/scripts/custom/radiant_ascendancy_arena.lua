-- Original, offline-friendly arena inspired by a radiant sky palace.
-- Generated at startup so it does not alter the shipped world.otbm map.
local RADIANT_CENTER = Position(34500, 34500, 7)
local RADIUS = 15
local FLOOR_ID = 409 -- white marble floor
local PILLAR_ID = 2153 -- marble pillar
local MIRROR_ID = 6447 -- marble window
local RED_MARKER_ID = 33305 -- red marble

local function at(dx, dy)
	return Position(RADIANT_CENTER.x + dx, RADIANT_CENTER.y + dy, RADIANT_CENTER.z)
end

local function makeTile(position)
	Game.createTile(position, true)
	if not Tile(position):getGround() then
		Game.createItem(FLOOR_ID, 1, position)
	end
end

local function buildRadiantArena()
	for dx = -RADIUS, RADIUS do
		for dy = -RADIUS, RADIUS do
			makeTile(at(dx, dy))
		end
	end

	-- Outer boundary: darker marble makes the combat space easy to read.
	for i = -RADIUS, RADIUS do
		Game.createItem(410, 1, at(i, -RADIUS))
		Game.createItem(410, 1, at(i, RADIUS))
		Game.createItem(410, 1, at(-RADIUS, i))
		Game.createItem(410, 1, at(RADIUS, i))
	end

	-- Four support pillars and a north mirror wall.
	for _, point in ipairs({ { -11, -11 }, { 11, -11 }, { -11, 11 }, { 11, 11 } }) do
		Game.createItem(PILLAR_ID, 1, at(point[1], point[2]))
	end
	for dx = -4, 4 do
		Game.createItem(MIRROR_ID, 1, at(dx, -12))
	end

	-- Red markers are safe decoration now; boss phases can later turn them into hazards.
	for dx = -10, 10, 5 do
		for dy = -8, 8, 4 do
			if not (dx == 0 and dy == 0) then
				Game.createItem(RED_MARKER_ID, 1, at(dx, dy))
			end
		end
	end

	RADIANT_CENTER:sendMagicEffect(CONST_ME_MAGIC_BLUE)
end

local radiantArenaStartup = GlobalEvent("RadiantAscendancyArenaStartup")
function radiantArenaStartup.onStartup()
	buildRadiantArena()
	return true
end
radiantArenaStartup:register()

local radiantArenaTeleport = TalkAction("/radiantarena")
function radiantArenaTeleport.onSay(player)
	if not player:getGroup():getAccess() then
		return true
	end
	player:teleportTo(RADIANT_CENTER)
	RADIANT_CENTER:sendMagicEffect(CONST_ME_TELEPORT)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You entered the original Radiant Ascendancy test arena.")
	return false
end
radiantArenaTeleport:separator(" ")
radiantArenaTeleport:groupType("god")
radiantArenaTeleport:register()
