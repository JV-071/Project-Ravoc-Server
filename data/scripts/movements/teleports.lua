-- Map portals for the Rotten Blood boss antechambers.
-- Place a portal in Remere and give it one of the Action IDs below.

local portals = {
	[9107] = { boss = "sala de entrada", destination = Position(32881, 31599, 11) },
	[9108] = { boss = "THAIS", destination = Position(32369, 32241, 7) },
	[9109] = { boss = "THAIS", destination = Position(33078, 32400, 15) },
}

for actionId, config in pairs(portals) do
	local portal = MoveEvent()

	function portal.onStepIn(creature, item, position, fromPosition)
		local player = creature:getPlayer()
		if not player then
			return true
		end

		player:teleportTo(config.destination, true)
		config.destination:sendMagicEffect(CONST_ME_TELEPORT)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You enter " .. config.boss .. "'s antechamber.")
		return true
	end

	portal:aid(actionId)
	portal:type("stepin")
	portal:register()
end