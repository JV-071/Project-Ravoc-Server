local mType = Game.createMonsterType("Infernal Colossus")
local monster = {}

monster.description = "an infernal colossus"
monster.experience = 25000

-- Custom outfit installed in the CrystalOTC appearances.
monster.outfit = {
	lookType = 10046,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 45000
monster.maxHealth = 45000
monster.race = "fire"
monster.corpse = 0
monster.speed = 230
monster.manaCost = 0

monster.changeTarget = {
	interval = 4000,
	chance = 15,
}

monster.strategiesTarget = {
	nearest = 70,
	health = 20,
	damage = 10,
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
	staticAttackChance = 90,
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
	chance = 10,
	{ text = "BURN IN THE INFERNO!", yell = true },
	{ text = "THE FLAMES WILL CONSUME YOU!", yell = true },
}

monster.loot = {
	{ name = "crystal coin", chance = 60000, maxCount = 10 },
	{ name = "great fireball rune", chance = 18000, maxCount = 10 },
	{ name = "red gem", chance = 3500 },
	{ name = "magma coat", chance = 700 },
	{ name = "magma legs", chance = 600 },
	{ name = "magma monocle", chance = 300 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, minDamage = -500, maxDamage = -1400 },
	{ name = "combat", interval = 2000, chance = 25, type = COMBAT_FIREDAMAGE, minDamage = -700, maxDamage = -1500, radius = 4, effect = CONST_ME_FIREAREA, target = false },
	{ name = "combat", interval = 2000, chance = 20, type = COMBAT_FIREDAMAGE, minDamage = -650, maxDamage = -1300, length = 8, spread = 3, effect = CONST_ME_FIREAREA, target = false },
	{ name = "combat", interval = 2000, chance = 15, type = COMBAT_PHYSICALDAMAGE, minDamage = -450, maxDamage = -900, range = 7, effect = CONST_ME_EXPLOSIONAREA, shootEffect = CONST_ANI_FIRE, target = true },
}

monster.defenses = {
	defense = 130,
	armor = 125,
	mitigation = 3.0,
	{ name = "combat", interval = 2000, chance = 20, type = COMBAT_HEALING, minDamage = 600, maxDamage = 1200, effect = CONST_ME_MAGIC_RED, target = false },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 10 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 10 },
	{ type = COMBAT_EARTHDAMAGE, percent = 20 },
	{ type = COMBAT_FIREDAMAGE, percent = 100 },
	{ type = COMBAT_LIFEDRAIN, percent = 0 },
	{ type = COMBAT_MANADRAIN, percent = 0 },
	{ type = COMBAT_DROWNDAMAGE, percent = -10 },
	{ type = COMBAT_ICEDAMAGE, percent = -25 },
	{ type = COMBAT_HOLYDAMAGE, percent = 0 },
	{ type = COMBAT_DEATHDAMAGE, percent = 10 },
}

monster.immunities = {
	{ type = "paralyze", condition = true },
	{ type = "outfit", condition = true },
	{ type = "invisible", condition = true },
	{ type = "bleed", condition = false },
}

mType:register(monster)
