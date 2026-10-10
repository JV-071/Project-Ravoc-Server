-- Blood Vestibule entrances to the Rotten Blood hunting grounds.
-- Bound by map position: no Action ID is required in Remere.

local entries = {
	-- The visible exit portal is at 33842,31650.  Players land two squares
	-- away so they are not immediately sent back out.
	{ from = Position(34092, 31978, 14), destination = Position(33842, 31652, 13), exit = Position(33842, 31650, 13), area = "Jaded Roots" },
}

local cooldowns = {}

local function teleportPlayer(player, destination, message)
	local playerId = player:getId()
	if cooldowns[playerId] then
		return true
	end

	-- Only blocks the immediate re-trigger after a teleport.  A long cooldown
	-- made the portal feel unresponsive when the player used it again.
	cooldowns[playerId] = true
	addEvent(function(id)
		cooldowns[id] = nil
	end, 300, playerId)
	player:teleportTo(destination, true)
	destination:sendMagicEffect(CONST_ME_TELEPORT)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
	return true
end

local function registerPortal(from, destination, message)
	local entrance = MoveEvent()

	function entrance.onStepIn(creature, item, position, fromPosition)
		local player = creature:getPlayer()
		if not player then
			return true
		end

		return teleportPlayer(player, destination, message)
	end

	entrance:position(from)
	entrance:register()

	-- Lets the same portal work when the player clicks it as well.
	local portalUse = Action()
	function portalUse.onUse(player, item, fromPosition, target, toPosition, isHotkey)
		return teleportPlayer(player, destination, message)
	end
	portalUse:position(from)
	portalUse:register()
end

for _, config in ipairs(entries) do
	registerPortal(config.from, config.destination, "You have left Blood Vestibule.")
	registerPortal(config.exit, config.from, "You have entered Blood Vestibule.")
end
