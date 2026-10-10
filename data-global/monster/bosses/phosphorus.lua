-- Local test implementation of the final boss from the Make Believe Quest.
-- The official encounter has multiple arena phases; this version focuses on a
-- single spawnable boss so it can be tested on an offline server.
local mType = Game.createMonsterType("Phosphorus")
local monster = {}

monster.description = "Phosphorus"
monster.experience = 16000000
monster.outfit = {
	-- Official Phosphorus appearance from Tibia 15.30.
	lookType = 1955,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 16000000
monster.maxHealth = 16000000
monster.race = "blood"
monster.corpse = 37704
monster.speed = 420
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 10,
}

monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	rewardBoss = false,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = true,
	staticAttackChance = 80,
	targetDistance = 1,
	runHealth = 0,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = {
	level = 8,
	color = 215,
}

monster.voices = {
	interval = 5000,
	chance = 12,
	{ text = "The moon's splinters belong to me!", yell = true },
	{ text = "Your dreams will burn.", yell = false },
	{ text = "There is no escape from the broken moon!", yell = true },
}

monster.loot = {
	{ id = 3043, chance = 100000, maxCount = 100 }, -- crystal coin
	{ id = 3035, chance = 100000, maxCount = 100 }, -- platinum coin
	{ id = 23373, chance = 50000, maxCount = 100 }, -- ultimate mana potion
	{ id = 7643, chance = 50000, maxCount = 100 }, -- ultimate health potion
	{ id = 23374, chance = 50000, maxCount = 100 }, -- ultimate spirit potion
	{ id = 30059, chance = 20000 }, -- giant ruby
	{ id = 8090, chance = 10000 }, -- spellbook of dark mysteries
	{ id = 8092, chance = 10000 }, -- wand of starstorm
	{ id = 53207, chance = 5000 }, -- moonsilver epee
	{ id = 53209, chance = 5000 }, -- moonsilver claymore
	{ id = 53211, chance = 5000 }, -- moonsilver axe
	{ id = 53215, chance = 5000 }, -- moonsilver crusher
	{ id = 53225, chance = 5000 }, -- moonsilver bow
	{ id = 53227, chance = 5000 }, -- moonsilver crossbow
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, skill = 260, attack = 300 },
	{ name = "combat", interval = 1500, chance = 20, type = COMBAT_ENERGYDAMAGE, minDamage = -1400, maxDamage = -3500, range = 7, shootEffect = CONST_ANI_ENERGY, effect = CONST_ME_ENERGYAREA, target = true },
	{ name = "combat", interval = 2000, chance = 16, type = COMBAT_FIREDAMAGE, minDamage = -1800, maxDamage = -4000, radius = 4, effect = CONST_ME_FIREAREA, target = false },
	{ name = "combat", interval = 2000, chance = 14, type = COMBAT_ICEDAMAGE, minDamage = -1500, maxDamage = -3200, radius = 5, effect = CONST_ME_ICEATTACK, target = false },
	{ name = "combat", interval = 2000, chance = 12, type = COMBAT_HOLYDAMAGE, minDamage = -2200, maxDamage = -4800, length = 8, spread = 0, effect = CONST_ME_HOLYDAMAGE, target = false },
	{ name = "speed", interval = 2000, chance = 10, speedChange = -900, radius = 5, effect = CONST_ME_MAGIC_RED, target = false, duration = 5000 },
}

monster.defenses = {
	defense = 190,
	armor = 170,
	{ name = "combat", interval = 2000, chance = 12, type = COMBAT_HEALING, minDamage = 25000, maxDamage = 50000, effect = CONST_ME_MAGIC_BLUE, target = false },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 5 },
	{ type = COMBAT_EARTHDAMAGE, percent = 20 },
	{ type = COMBAT_FIREDAMAGE, percent = 10 },
	{ type = COMBAT_ICEDAMAGE, percent = 0 },
	{ type = COMBAT_HOLYDAMAGE, percent = 0 },
	{ type = COMBAT_DEATHDAMAGE, percent = 0 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "invisible", condition = true },
	{ type = "drunk", condition = true },
	{ type = "bleed", condition = false },
}

mType:register(monster)
