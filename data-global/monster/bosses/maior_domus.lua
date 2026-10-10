-- Make Believe Quest (15.30) - offline test boss.
local mType = Game.createMonsterType("Maior Domus")
local monster = {}

monster.description = "Maior Domus"
monster.experience = 0
monster.outfit = { lookType = 1954 }
monster.health = 3500000
monster.maxHealth = 3500000
monster.race = "blood"
monster.corpse = 37704
monster.speed = 410
monster.manaCost = 0

monster.changeTarget = { interval = 4000, chance = 10 }
monster.strategiesTarget = { nearest = 70, health = 10, damage = 10, random = 10 }
monster.flags = {
	summonable = false, attackable = true, hostile = true, convinceable = false,
	pushable = false, rewardBoss = false, illusionable = false, canPushItems = true,
	canPushCreatures = true, staticAttackChance = 80, targetDistance = 1,
	runHealth = 0, healthHidden = false, isBlockable = false,
	canWalkOnEnergy = true, canWalkOnFire = true, canWalkOnPoison = true,
}

monster.light = { level = 7, color = 215 }
monster.voices = {
	interval = 5000, chance = 14,
	{ text = "The palace will never fall!", yell = true },
	{ text = "Kneel before the radiant order.", yell = false },
}

monster.loot = {
	{ id = 3043, chance = 100000, maxCount = 33 },
	{ id = 3035, chance = 100000, maxCount = 76 },
	{ id = 23373, chance = 50000, maxCount = 28 },
	{ id = 23374, chance = 18000, maxCount = 5 },
	{ id = 7643, chance = 28000, maxCount = 8 },
	{ id = 3030, chance = 8000 },
	{ id = 53229, chance = 1200 }, { id = 53230, chance = 1200 },
	{ id = 53231, chance = 1200 }, { id = 53232, chance = 1200 },
	{ id = 53233, chance = 1200 },
}

monster.attacks = {
	{ name = "melee", interval = 2000, chance = 100, skill = 240, attack = 280 },
	{ name = "combat", interval = 1500, chance = 24, type = COMBAT_FIREDAMAGE, minDamage = -1200, maxDamage = -2800, range = 7, shootEffect = CONST_ANI_FIRE, effect = CONST_ME_FIREAREA, target = true },
	{ name = "combat", interval = 2000, chance = 18, type = COMBAT_ENERGYDAMAGE, minDamage = -1400, maxDamage = -3100, radius = 4, effect = CONST_ME_ENERGYAREA, target = false },
	{ name = "combat", interval = 2200, chance = 14, type = COMBAT_DEATHDAMAGE, minDamage = -1300, maxDamage = -3000, length = 8, spread = 0, effect = CONST_ME_MORTAREA, target = false },
	{ name = "speed", interval = 2000, chance = 12, speedChange = -850, radius = 5, effect = CONST_ME_MAGIC_RED, target = false, duration = 4500 },
}

monster.defenses = {
	defense = 180, armor = 165,
	{ name = "combat", interval = 2000, chance = 12, type = COMBAT_HEALING, minDamage = 18000, maxDamage = 36000, effect = CONST_ME_MAGIC_BLUE, target = false },
}
monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 }, { type = COMBAT_ENERGYDAMAGE, percent = 10 },
	{ type = COMBAT_EARTHDAMAGE, percent = 10 }, { type = COMBAT_FIREDAMAGE, percent = 20 },
	{ type = COMBAT_ICEDAMAGE, percent = 0 }, { type = COMBAT_HOLYDAMAGE, percent = 0 },
	{ type = COMBAT_DEATHDAMAGE, percent = 10 },
}
monster.immunities = {
	{ type = "paralyze", condition = true }, { type = "invisible", condition = true },
	{ type = "drunk", condition = true }, { type = "bleed", condition = false },
}

mType.onSpawn = function(self)
	local difficulty = Game.getStorageValue("MakeBelieveDifficulty")
	if difficulty < 0 then difficulty = 0 end
	local healthMultiplier = 1 + difficulty * 0.08
	self:setMaxHealth(math.floor(self:getMaxHealth() * healthMultiplier))
	self:setHealth(self:getMaxHealth())
	self:addDefense(difficulty * 4)
	self:setStorageValue("MakeBelieveDifficulty", difficulty)
end

mType:register(monster)
