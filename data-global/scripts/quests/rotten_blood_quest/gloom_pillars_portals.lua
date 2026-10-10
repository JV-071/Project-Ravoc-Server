-- Gloom Pillars hunting-ground portals.
-- The landing tile is deliberately beside the exit portal.

local entrancePosition = Position(34093, 32009, 14)
local landingPosition = Position(33809, 31816, 13)
local exitPosition = Position(33809, 31814, 13)
local cooldowns = {}

local function movePlayer(player, destination, message)
	local playerId = player:getId()
	if (cooldowns[playerId] or 0) > os.time() then
		return true
	end

	cooldowns[playerId] = os.time() + 2
	player:teleportTo(destination, true)
	destination:sendMagicEffect(CONST_ME_TELEPORT)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
	return true
end

local function registerPortal(position, destination, message)
	local stepIn = MoveEvent()
	function stepIn.onStepIn(creature)
		local player = creature:getPlayer()
		return player and movePlayer(player, destination, message) or true
	end
	stepIn:position(position)
	stepIn:register()

	local use = Action()
	function use.onUse(player)
		return movePlayer(player, destination, message)
	end
	use:position(position)
	use:register()
end

registerPortal(entrancePosition, landingPosition, "You enter Gloom Pillars.")
registerPortal(exitPosition, entrancePosition, "You leave Gloom Pillars.")
