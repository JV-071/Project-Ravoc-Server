local championTypes = {
	"Ranking Level Champion",
	"Ranking Magic Champion",
	"Ranking Sword Champion",
}

for _, internalNpcName in ipairs(championTypes) do
	local npcType = Game.createNpcType(internalNpcName)
	local npcConfig = {
		name = internalNpcName,
		description = internalNpcName,
		health = 100,
		maxHealth = 100,
		walkInterval = 0,
		walkRadius = 0,
		outfit = {
			lookType = 128,
			lookHead = 0,
			lookBody = 0,
			lookLegs = 0,
			lookFeet = 0,
			lookAddons = 0,
		},
		flags = {
			floorchange = false,
		},
	}
	npcType:register(npcConfig)
end
