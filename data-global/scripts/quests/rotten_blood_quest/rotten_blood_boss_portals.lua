-- Map portals for the Rotten Blood boss antechambers.
-- Place a portal in Remere and give it one of the Action IDs below.

local portals = {
	[9101] = { boss = "Murcion", destination = Position(32974, 32365, 15) },
	[9102] = { boss = "Ichgahal", destination = Position(32974, 32333, 15) },
	[9103] = { boss = "Chagorz", destination = Position(33074, 32367, 15) },
	[9104] = { boss = "Vemiath", destination = Position(33074, 32333, 15) },
	[9105] = { boss = "Bakragore", destination = Position(33078, 32400, 15) },
}

for actionId, config in pairs(portals) do
	local portal = MoveEvent()

	function portal.onStepIn(creature, item, position, fromPosition)
		local player = creature:getPlayer()
		if not player then
			return true
		end

		if config.boss == "Bakragore" and RottenBloodInstances and RottenBloodInstances.detachPlayer then
			RottenBloodInstances.detachPlayer(player)
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
