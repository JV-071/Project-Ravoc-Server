-- Green portal connection for the First Dragon area.
-- Entrance: 32746, 31570, 15
-- Destination: Charred Skull room.

local entrance = Position(32746, 31570, 15)
local destination = Position(32702, 31594, 7)

local greenPortal = MoveEvent()

function greenPortal.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if not player:kv():scoped("first-dragon-champions"):get("fatal-bug-defeated") then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Defeat the Fatal Bug before using this portal.")
		return true
	end

	player:teleportTo(destination, true)
	destination:sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

greenPortal:position(entrance)
greenPortal:type("stepin")
greenPortal:register()
