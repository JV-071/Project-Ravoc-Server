-- Summer Update 15.30 creatures.
-- Race IDs and outfits were read from the official 15.30 staticdata asset.

local creatures = {
	{ name = "Winged Jaracal", raceId = 2802, lookType = 1961, lookHead = 113, lookBody = 40, lookLegs = 95, lookFeet = 95, lookAddons = 1, health = 8200, experience = 7830, charms = 50, class = "Mammal", bestiaryRace = BESTY_RACE_MAMMAL, speed = 180 },
	{ name = "Iceplume Strider", raceId = 2803, lookType = 1950, lookBody = 51, health = 8500, experience = 8150, charms = 50, class = "Bird", bestiaryRace = BESTY_RACE_BIRD, speed = 180 },
	{ name = "Silverfrost Sentinel", raceId = 2804, lookType = 1951, lookHead = 81, lookBody = 113, health = 9500, experience = 8450, charms = 50, class = "Construct", bestiaryRace = BESTY_RACE_CONSTRUCT, speed = 170 },
	{ name = "True Feverbloom Asura", raceId = 2805, lookType = 1068, lookHead = 62, lookBody = 61, lookLegs = 114, lookFeet = 15, lookAddons = 1, health = 8600, experience = 7400, charms = 50, class = "Demon", bestiaryRace = BESTY_RACE_DEMON, speed = 180 },

	{ name = "Radiant Warden", raceId = 2839, lookType = 1964, health = 38500, experience = 31450, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 210 },
	{ name = "Devoted Radiant Warden", raceId = 2840, lookType = 1964, lookAddons = 1, health = 44275, experience = 43460, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 220 },
	{ name = "Radiant Paragon", raceId = 2841, lookType = 1966, lookAddons = 2, health = 36000, experience = 30780, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 210 },
	{ name = "Devoted Radiant Paragon", raceId = 2842, lookType = 1966, lookAddons = 1, health = 41400, experience = 42850, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 220 },
	{ name = "Radiant Acolyte", raceId = 2843, lookType = 1969, health = 34600, experience = 29170, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 205 },
	{ name = "Devoted Radiant Acolyte", raceId = 2844, lookType = 1969, lookAddons = 3, health = 39790, experience = 40530, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 215 },
	{ name = "Radiant Templar", raceId = 2845, lookType = 1965, health = 37000, experience = 30550, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 205 },
	{ name = "Devoted Radiant Templar", raceId = 2846, lookType = 1965, lookAddons = 3, health = 42550, experience = 42300, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 215 },
	{ name = "Radiant Inquisitor", raceId = 2847, lookType = 1967, health = 34800, experience = 28730, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 210 },
	{ name = "Devoted Radiant Inquisitor", raceId = 2848, lookType = 1967, lookAddons = 3, health = 40020, experience = 39860, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 220 },
	{ name = "Radiant Zealot", raceId = 2849, lookType = 1968, health = 36500, experience = 31160, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 210 },
	{ name = "Devoted Radiant Zealot", raceId = 2850, lookType = 1968, lookAddons = 3, health = 41980, experience = 42800, charms = 100, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 220 },

	{ name = "Moonspawn Blightspitter", raceId = 2851, lookType = 1970, health = 8500, experience = 6670, charms = 50, class = "Magical", bestiaryRace = BESTY_RACE_MAGICAL, speed = 170 },
	{ name = "Moonspawn Oozecrown", raceId = 2852, lookType = 1971, health = 9200, experience = 7320, charms = 50, class = "Magical", bestiaryRace = BESTY_RACE_MAGICAL, speed = 165 },
	{ name = "Jaracal", raceId = 2856, lookType = 1961, lookHead = 82, lookBody = 97, lookLegs = 76, lookFeet = 76, health = 3200, experience = 2460, charms = 50, class = "Mammal", bestiaryRace = BESTY_RACE_MAMMAL, speed = 170 },
	{ name = "Moonstone Excavator", raceId = 2857, lookType = 1952, lookAddons = 1, health = 5100, experience = 4670, charms = 50, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 160 },
	{ name = "Moonstone Overseer", raceId = 2858, lookType = 1956, health = 5450, experience = 4920, charms = 50, class = "Humanoid", bestiaryRace = BESTY_RACE_HUMANOID, speed = 165 },
}

local function registerCreature(config)
	local mType = Game.createMonsterType(config.name)
	local monster = {}

	monster.description = "a " .. config.name:lower()
	monster.experience = config.experience
	monster.outfit = {
		lookType = config.lookType,
		lookHead = config.lookHead or 0,
		lookBody = config.lookBody or 0,
		lookLegs = config.lookLegs or 0,
		lookFeet = config.lookFeet or 0,
		lookAddons = config.lookAddons or 0,
		lookMount = 0,
	}

	monster.raceId = config.raceId
	monster.Bestiary = {
		class = config.class,
		race = config.bestiaryRace,
		toKill = config.charms == 100 and 1000 or 500,
		FirstUnlock = config.charms == 100 and 100 or 25,
		SecondUnlock = config.charms == 100 and 500 or 250,
		CharmsPoints = config.charms,
		Stars = config.charms == 100 and 4 or 3,
		Occurrence = 0,
		Locations = "Summer Update 15.30.",
	}

	monster.health = config.health
	monster.maxHealth = config.health
	monster.race = "blood"
	monster.corpse = (config.raceId == 2802 or config.raceId == 2856) and 54678
		or (config.raceId == 2805 and 28617 or 0)
	monster.speed = config.speed

	monster.changeTarget = { interval = 4000, chance = 20 }
	monster.strategiesTarget = { nearest = 80, health = 10, damage = 10 }
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
		isPreyExclusive = true,
	}

	local maximum = math.max(450, math.floor(config.health * 0.085))
	monster.attacks = {
		{ name = "melee", interval = 2000, chance = 100, minDamage = 0, maxDamage = -maximum },
		{ name = "combat", interval = 2000, chance = 20, type = COMBAT_PHYSICALDAMAGE, minDamage = -math.floor(maximum * 0.35), maxDamage = -math.floor(maximum * 0.7), range = 7, shootEffect = CONST_ANI_POWERBOLT, effect = CONST_ME_HITAREA, target = true },
	}
	monster.defenses = {
		defense = config.charms == 100 and 80 or 55,
		armor = config.charms == 100 and 85 or 65,
		mitigation = config.charms == 100 and 1.65 or 1.15,
	}
	monster.elements = {
		{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
		{ type = COMBAT_ENERGYDAMAGE, percent = 0 },
		{ type = COMBAT_EARTHDAMAGE, percent = 0 },
		{ type = COMBAT_FIREDAMAGE, percent = 0 },
		{ type = COMBAT_ICEDAMAGE, percent = 0 },
		{ type = COMBAT_HOLYDAMAGE, percent = 0 },
		{ type = COMBAT_DEATHDAMAGE, percent = 0 },
	}
	monster.immunities = {
		{ type = "paralyze", condition = false },
		{ type = "outfit", condition = false },
		{ type = "invisible", condition = true },
		{ type = "bleed", condition = false },
	}
	monster.loot = {}

	mType:register(monster)
end

for _, creature in ipairs(creatures) do
	registerCreature(creature)
end
