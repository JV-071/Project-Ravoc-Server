local config = {
	difficultySelector = true,
	boss = {
		name = "Bakragore",
		position = Position(33044, 32394, 15),
	},
	requiredLevel = 250,
	onUseExtra = function(player)
		if (player:kv():scoped("rotten-blood-quest"):get("taints") or 0) < 4 then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need all four Rotten Blood Taints to challenge Bakragore.")
			return false
		end
		return true
	end,
	timeToFightAgain = ParseDuration("20h") / ParseDuration("1s"),
	playerPositions = {
		{ pos = Position(33078, 32398, 15), teleport = Position(33044, 32407, 15), effect = CONST_ME_TELEPORT },
		{ pos = Position(33077, 32398, 15), teleport = Position(33044, 32407, 15), effect = CONST_ME_TELEPORT },
		{ pos = Position(33076, 32398, 15), teleport = Position(33044, 32407, 15), effect = CONST_ME_TELEPORT },
		{ pos = Position(33075, 32398, 15), teleport = Position(33044, 32407, 15), effect = CONST_ME_TELEPORT },
		{ pos = Position(33074, 32398, 15), teleport = Position(33044, 32407, 15), effect = CONST_ME_TELEPORT },
	},
	specPos = {
		from = Position(33034, 32389, 15),
		to = Position(33053, 32410, 15),
	},
	exit = Position(34106, 32052, 13),
}

local lever = BossLever(config)
lever:position(Position(33079, 32398, 15))
lever:register()
