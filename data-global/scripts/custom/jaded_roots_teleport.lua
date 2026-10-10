-- Blood Vestibule entrance to Darklight Core.

-- The visible exit portal is at 34119,31875.  Landing on it would trigger
-- the map teleport again, so players arrive on the free tile beside it.
local destination = Position(34119, 31877, 14)
local entrance = Position(34117, 32010, 15)
local exitPortal = Position(34119, 31875, 14)
local cooldowns = {}

local function canTeleport(player)
	local playerId = player:getId()
	if (cooldowns[playerId] or 0) > os.time() then
		return false
	end
	cooldowns[playerId] = os.time() + 2
	return true
end

local jadedRootsTeleport = MoveEvent()

function jadedRootsTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	if not canTeleport(player) then
		return true
	end

	player:teleportTo(destination, true)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You enter the Darklight Core.")
	destination:sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

-- The visible entrance occupies more than one square, so cover its 3x3 area.
jadedRootsTeleport:position({
	Position(34116, 32009, 15), Position(34117, 32009, 15), Position(34118, 32009, 15),
	Position(34116, 32010, 15), Position(34117, 32010, 15), Position(34118, 32010, 15),
	Position(34116, 32011, 15), Position(34117, 32011, 15), Position(34118, 32011, 15),
})
jadedRootsTeleport:register()

-- This entrance is activated by using/clicking the object, not only by
-- stepping on its tile.
local jadedRootsUse = Action()

function jadedRootsUse.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not canTeleport(player) then
		return true
	end
	player:teleportTo(destination, true)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You enter the Darklight Core.")
	destination:sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

jadedRootsUse:position(entrance)
jadedRootsUse:register()

local darklightExit = MoveEvent()

function darklightExit.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player or not canTeleport(player) then
		return true
	end

	player:teleportTo(entrance, true)
	entrance:sendMagicEffect(CONST_ME_TELEPORT)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You leave the Darklight Core.")
	return true
end

darklightExit:position(exitPortal)
darklightExit:register()

local darklightExitUse = Action()

function darklightExitUse.onUse(player)
	if not canTeleport(player) then
		return true
	end

	player:teleportTo(entrance, true)
	entrance:sendMagicEffect(CONST_ME_TELEPORT)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You leave the Darklight Core.")
	return true
end

darklightExitUse:position(exitPortal)
darklightExitUse:register()
