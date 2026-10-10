-- Exit forcefields for the Rotten Blood boss rooms.
-- The map objects need no Action ID; they are bound by exact positions.

local exits = {
	{ from = Position(33043, 32344, 15), destination = Position(34116, 31879, 14), boss = "Vemiath" },
	{ from = Position(33070, 32337, 15), destination = Position(34116, 31879, 14), boss = "Vemiath" },
	{ from = Position(33004, 32343, 15), destination = Position(34101, 31681, 13), boss = "Ichgahal" },
	{ from = Position(33009, 32374, 15), destination = Position(33843, 31653, 13), boss = "Murcion" },
	{ from = Position(33044, 32375, 15), destination = Position(33809, 31816, 13), boss = "Chagorz" },
}

for _, config in ipairs(exits) do
	local exitPortal = MoveEvent()

	function exitPortal.onStepIn(creature, item, portalPosition, fromPosition)
		local player = creature:getPlayer()
		if not player then
			return true
		end

		player:teleportTo(config.destination, true)
		config.destination:sendMagicEffect(CONST_ME_TELEPORT)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You leave " .. config.boss .. "'s boss room.")
		return true
	end

	exitPortal:position(config.from)
	exitPortal:type("stepin")
	exitPortal:register()
end
