-- Linked Tasks / Task Hub integration for CrystalOTC.
-- The client layout is based on the DeusOT Task window while all state is
-- stored in Crystal's persistent player storages.

local OPCODE = 143

-- Player storages are used instead of the global KV cache so progress is
-- committed by player:save() immediately, even when the server is restarted
-- before the next global KV flush.
local STORAGE = {
	active = 987400,
	points = 987401,
	progress = 987410,
	claimed = 987430,
	runFinished = 987450,
	claimedRun = 987470,
	extendedProgress = 987500,
	extendedClaimed = 987600,
	extendedRunFinished = 987700,
	extendedClaimedRun = 987800,
	hallReward = 987900,
}

local TASKS = {
	{ id = 1, category = 1, name = "Rotworm Infestation", monster = "Rotworm", raceId = 26, kills = 25, stars = 1, exp = 1, loot = 1, background = 0, points = 15, experience = 5000 },
	{ id = 2, category = 1, name = "Minotaur Camp", monster = "Minotaur", raceId = 25, kills = 50, stars = 1, exp = 1, loot = 2, background = 1, points = 20, experience = 10000 },
	{ id = 3, category = 1, name = "Cyclops Hills", monster = "Cyclops", raceId = 22, kills = 75, stars = 1, exp = 1, loot = 2, background = 2, points = 25, experience = 15000 },
	{ id = 4, category = 1, name = "Orc Berserkers", monster = "Orc Berserker", raceId = 8, kills = 100, stars = 1, exp = 2, loot = 2, background = 3, points = 30, experience = 20000 },
	{ id = 5, category = 1, name = "Dwarven Guards", monster = "Dwarf Guard", raceId = 70, kills = 150, stars = 1, exp = 2, loot = 2, background = 4, points = 35, experience = 30000 },
	{ id = 6, category = 1, name = "Elven Arcanists", monster = "Elf Arcanist", raceId = 63, kills = 200, stars = 1, exp = 2, loot = 3, background = 5, points = 40, experience = 40000 },

	{ id = 7, category = 2, name = "Dragon Hunt", monster = "Dragon", raceId = 34, kills = 150, stars = 2, exp = 2, loot = 2, background = 6, points = 45, experience = 60000 },
	{ id = 8, category = 2, name = "Dragon Lords", monster = "Dragon Lord", raceId = 39, kills = 200, stars = 2, exp = 3, loot = 3, background = 7, points = 55, experience = 90000 },
	{ id = 9, category = 2, name = "Giant Spider Nest", monster = "Giant Spider", raceId = 38, kills = 250, stars = 2, exp = 3, loot = 3, background = 8, points = 65, experience = 125000 },
	{ id = 10, category = 2, name = "Behemoth Caverns", monster = "Behemoth", raceId = 55, kills = 300, stars = 2, exp = 3, loot = 4, background = 9, points = 75, experience = 175000 },
	{ id = 11, category = 2, name = "Fallen Heroes", monster = "Hero", raceId = 73, kills = 350, stars = 2, exp = 3, loot = 4, background = 0, points = 85, experience = 225000 },
	{ id = 12, category = 2, name = "Warlock Conspiracy", monster = "Warlock", raceId = 130, kills = 400, stars = 2, exp = 4, loot = 4, background = 1, points = 95, experience = 300000 },

	{ id = 13, category = 3, name = "Hydra Swamp", monster = "Hydra", raceId = 121, kills = 400, stars = 3, exp = 3, loot = 3, background = 2, points = 105, experience = 400000 },
	{ id = 14, category = 3, name = "Frozen Dragons", monster = "Frost Dragon", raceId = 248, kills = 450, stars = 3, exp = 3, loot = 4, background = 3, points = 120, experience = 500000 },
	{ id = 15, category = 3, name = "Serpents of the Deep", monster = "Sea Serpent", raceId = 275, kills = 500, stars = 3, exp = 4, loot = 4, background = 4, points = 135, experience = 650000 },
	{ id = 16, category = 3, name = "Nightmare Legion", monster = "Nightmare", raceId = 245, kills = 600, stars = 3, exp = 4, loot = 4, background = 5, points = 150, experience = 800000 },
	{ id = 17, category = 3, name = "Hellspawn Invasion", monster = "Hellspawn", raceId = 322, kills = 700, stars = 3, exp = 4, loot = 5, background = 6, points = 165, experience = 1000000 },
	{ id = 18, category = 3, name = "Werehyaena Pack", monster = "Werehyaena", raceId = 1300, kills = 800, stars = 3, exp = 4, loot = 5, background = 7, points = 180, experience = 1250000 },

	{ id = 19, category = 4, name = "Grim Harvest", monster = "Grim Reaper", raceId = 300, kills = 800, stars = 4, exp = 4, loot = 4, background = 8, points = 200, experience = 1500000 },
	{ id = 20, category = 4, name = "Medusa's Gaze", monster = "Medusa", raceId = 330, kills = 900, stars = 4, exp = 4, loot = 4, background = 9, points = 220, experience = 1800000 },
	{ id = 21, category = 4, name = "Serpent Spawn Brood", monster = "Serpent Spawn", raceId = 220, kills = 1000, stars = 4, exp = 4, loot = 5, background = 0, points = 240, experience = 2100000 },
	{ id = 22, category = 4, name = "Guzzlemaw Depths", monster = "Guzzlemaw", raceId = 584, kills = 1100, stars = 4, exp = 5, loot = 5, background = 1, points = 260, experience = 2500000 },
	{ id = 23, category = 4, name = "Silenced Grounds", monster = "Silencer", raceId = 585, kills = 1200, stars = 4, exp = 5, loot = 5, background = 2, points = 280, experience = 3000000 },
	{ id = 24, category = 4, name = "Retching Horrors", monster = "Retching Horror", raceId = 588, kills = 1300, stars = 4, exp = 5, loot = 5, background = 3, points = 300, experience = 3500000 },

	{ id = 25, category = 5, name = "Midnight Asuras", monster = "Midnight Asura", raceId = 150, kills = 1500, stars = 5, exp = 5, loot = 5, background = 4, points = 330, experience = 4000000 },
	{ id = 26, category = 5, name = "Demon Annihilation", monster = "Demon", raceId = 35, kills = 1750, stars = 5, exp = 5, loot = 5, background = 5, points = 360, experience = 5000000 },
	{ id = 27, category = 5, name = "Falcon Knights", monster = "Falcon Knight", raceId = 1071, kills = 2000, stars = 5, exp = 5, loot = 5, background = 6, points = 400, experience = 6000000 },
	{ id = 28, category = 5, name = "Cobra Assassins", monster = "Cobra Assassin", raceId = 1217, kills = 2250, stars = 5, exp = 5, loot = 5, background = 7, points = 440, experience = 7500000 },
	{ id = 29, category = 5, name = "Burning Gladiators", monster = "Burning Gladiator", raceId = 541, kills = 2500, stars = 5, exp = 5, loot = 5, background = 8, points = 480, experience = 9000000 },
	{ id = 30, category = 5, name = "Flimsy Lost Souls", monster = "Flimsy Lost Soul", raceId = 1268, kills = 3000, stars = 5, exp = 5, loot = 5, background = 9, points = 550, experience = 12000000 },

	{ id = 79, category = 5, name = "Earth Library", monster = "Cursed Book", raceId = 1655, lookType = 1061, kills = 10000, stars = 5, exp = 5, loot = 0, background = 0, points = 0, experience = 25000000, repeatExperience = 20000000, noItemReward = true, monsters = {
		{ name = "Cursed Book", raceId = 1655, lookType = 1061 }, { name = "Ink Blob", raceId = 1658, lookType = 1064 },
	} },
	{ id = 80, category = 5, name = "Ice Library", monster = "Icecold Book", raceId = 1664, lookType = 1061, kills = 25000, stars = 5, exp = 5, loot = 0, background = 1, points = 0, experience = 25000000, repeatExperience = 20000000, noItemReward = true, monsters = {
		{ name = "Icecold Book", raceId = 1664, lookType = 1061 }, { name = "Squid Warden", raceId = 1669, lookType = 1059 }, { name = "Animated Feather", raceId = 1671, lookType = 1058 },
	} },
	{ id = 81, category = 5, name = "Fire Library", monster = "Burning Book", raceId = 1663, lookType = 1061, kills = 25000, stars = 5, exp = 5, loot = 0, background = 2, points = 0, experience = 25000000, repeatExperience = 20000000, noItemReward = true, monsters = {
		{ name = "Burning Book", raceId = 1663, lookType = 1061 }, { name = "Rage Squid", raceId = 1668, lookType = 1059 }, { name = "Guardian Of Tales", raceId = 1659, lookType = 1063 },
	} },
	{ id = 82, category = 5, name = "Energy Library", monster = "Energetic Book", raceId = 1665, lookType = 1061, kills = 25000, stars = 5, exp = 5, loot = 0, background = 3, points = 0, experience = 20000000, repeatExperience = 20000000, noItemReward = true, monsters = {
		{ name = "Energetic Book", raceId = 1665, lookType = 1061 }, { name = "Brain Squid", raceId = 1653, lookType = 1059 }, { name = "Energuardian Of Tales", raceId = 1666, lookType = 1063 },
	} },
	{ id = 83, category = 5, name = "Furious Crater", monster = "Vibrant Phantom", raceId = 1929, lookType = 1298, kills = 35000, stars = 5, exp = 5, loot = 5, background = 4, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Vibrant Phantom", raceId = 1929, lookType = 1298 }, { name = "Courage Leech", raceId = 1941, lookType = 1315 }, { name = "Cloak Of Terror", raceId = 1928, lookType = 1295 },
	} },
	{ id = 84, category = 5, name = "Mirrored Nightmare", monster = "Many Faces", raceId = 1927, lookType = 1296, kills = 35000, stars = 5, exp = 5, loot = 5, background = 5, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Many Faces", raceId = 1927, lookType = 1296 }, { name = "Druid's Apparition", raceId = 1946, lookType = 148 }, { name = "Knight's Apparition", raceId = 1947, lookType = 131 }, { name = "Paladin's Apparition", raceId = 1948, lookType = 129 }, { name = "Sorcerer's Apparition", raceId = 1949, lookType = 138 }, { name = "Monk's Apparition", raceId = 2636, lookType = 1824 }, { name = "Distorted Phantom", raceId = 1962, lookType = 1298 },
	} },
	{ id = 85, category = 5, name = "Rotten Wasteland", monster = "Branchy Crawler", raceId = 1931, lookType = 1297, kills = 35000, stars = 5, exp = 5, loot = 5, background = 6, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Branchy Crawler", raceId = 1931, lookType = 1297 }, { name = "Rotten Golem", raceId = 1939, lookType = 1312 }, { name = "Mould Phantom", raceId = 1945, lookType = 1298 },
	} },
	{ id = 86, category = 5, name = "Claustrophobic Inferno", monster = "Brachiodemon", raceId = 1930, lookType = 1299, kills = 35000, stars = 5, exp = 5, loot = 5, background = 7, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Brachiodemon", raceId = 1930, lookType = 1299 }, { name = "Infernal Demon", raceId = 1938, lookType = 1313 }, { name = "Infernal Phantom", raceId = 1933, lookType = 1298 },
	} },
	{ id = 87, category = 5, name = "Ebb and Flow", monster = "Bony Sea Devil", raceId = 1926, lookType = 1294, kills = 35000, stars = 5, exp = 5, loot = 5, background = 8, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Bony Sea Devil", raceId = 1926, lookType = 1294 }, { name = "Turbulent Elemental", raceId = 1940, lookType = 1314 }, { name = "Capricious Phantom", raceId = 1932, lookType = 1298 },
	} },
	{ id = 88, category = 5, name = "Sparkling Pools", monster = "Emerald Tortoise", raceId = 2268, lookType = 1550, kills = 50000, stars = 5, exp = 5, loot = 5, background = 9, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Emerald Tortoise", raceId = 2268, lookType = 1550 }, { name = "Gore Horn", raceId = 2266, lookType = 1548 }, { name = "Gorerilla", raceId = 2277, lookType = 1559 }, { name = "Hulking Prehemoth", raceId = 2271, lookType = 1553 }, { name = "Sabretooth", raceId = 2267, lookType = 1549 },
	} },
	{ id = 89, category = 5, name = "Crystal Enigma", monster = "Headpecker", raceId = 2275, lookType = 1557, kills = 50000, stars = 5, exp = 5, loot = 5, background = 0, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Headpecker", raceId = 2275, lookType = 1557 }, { name = "Mantosaurus", raceId = 2274, lookType = 1556 }, { name = "Mercurial Menace", raceId = 2279, lookType = 1561 }, { name = "Noxious Ripptor", raceId = 2276, lookType = 1558 }, { name = "Shrieking Cry-stal", raceId = 2278, lookType = 1560 },
	} },
	{ id = 90, category = 5, name = "Monster Graveyard", monster = "Sulphider", raceId = 2264, lookType = 1546, kills = 50000, stars = 5, exp = 5, loot = 5, background = 1, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Sulphider", raceId = 2264, lookType = 1546 }, { name = "Sulphur Spouter", raceId = 2265, lookType = 1547 }, { name = "Nighthunter", raceId = 2270, lookType = 1552 }, { name = "Stalking Stalk", raceId = 2272, lookType = 1554 }, { name = "Undertaker", raceId = 2269, lookType = 1551 },
	} },
	{ id = 91, category = 5, name = "Putrefactory", monster = "Meandering Mushroom", raceId = 2376, lookType = 1621, kills = 60000, stars = 5, exp = 5, loot = 5, background = 2, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Meandering Mushroom", raceId = 2376, lookType = 1621 }, { name = "Oozing Carcass", raceId = 2377, lookType = 1626 }, { name = "Rotten Man-maggot", raceId = 2393, lookType = 1655 }, { name = "Sopping Carcass", raceId = 2396, lookType = 1658 }, { name = "Elder Bloodjaw", displayName = "Bloodjaw", raceId = 0, lookType = 1628 },
	} },
	{ id = 92, category = 5, name = "Gloom Pillars", monster = "Converter", raceId = 2379, lookType = 1623, kills = 60000, stars = 5, exp = 5, loot = 5, background = 3, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Converter", raceId = 2379, lookType = 1623 }, { name = "Darklight Construct", raceId = 2378, lookType = 1622 }, { name = "Darklight Emitter", raceId = 2382, lookType = 1627 }, { name = "Wandering Pillar", raceId = 2395, lookType = 1657 }, { name = "Elder Bloodjaw", displayName = "Bloodjaw", raceId = 0, lookType = 1628 },
	} },
	{ id = 93, category = 5, name = "Jaded Roots", monster = "Bloated Man-maggot", raceId = 2392, lookType = 1654, kills = 60000, stars = 5, exp = 5, loot = 5, background = 4, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Bloated Man-maggot", raceId = 2392, lookType = 1654 }, { name = "Mycobiontic Beetle", raceId = 2375, lookType = 1620 }, { name = "Oozing Corpus", raceId = 2381, lookType = 1625 }, { name = "Sopping Corpus", raceId = 2397, lookType = 1659 }, { name = "Elder Bloodjaw", displayName = "Bloodjaw", raceId = 0, lookType = 1628 },
	} },
	{ id = 94, category = 5, name = "Darklight Core", monster = "Darklight Matter", raceId = 2380, lookType = 1624, kills = 60000, stars = 5, exp = 5, loot = 5, background = 5, points = 0, experience = 40000000, repeatExperience = 40000000, noItemReward = true, itemRewards = { { item = 61718, count = 1, name = "Mystic Bag" } }, repeatItemRewards = true, monsters = {
		{ name = "Darklight Matter", raceId = 2380, lookType = 1624 }, { name = "Darklight Source", raceId = 2398, lookType = 1660 }, { name = "Darklight Striker", raceId = 2399, lookType = 1661 }, { name = "Walking Pillar", raceId = 2394, lookType = 1656 }, { name = "Elder Bloodjaw", displayName = "Bloodjaw", raceId = 0, lookType = 1628 },
	} },
}

local BY_ID = {}
local BY_MONSTER = {}
for _, task in ipairs(TASKS) do
	BY_ID[task.id] = task
	for _, monster in ipairs(task.monsters or { { name = task.monster, raceId = task.raceId, lookType = task.lookType or task.raceId } }) do
		BY_MONSTER[monster.name:lower()] = task
	end
end

local TASK_STORE_PRODUCTS = {
	[1] = { item = 61718, count = 1, price = 25, name = "Mystic Bag" },
	[2] = { item = 61608, count = 1, price = 15, name = "Tigrinho Roulette Coin" },
	[3] = { item = 61722, count = 1, price = 50, name = "Paladin's Chest" },
	[4] = { item = 61720, count = 1, price = 50, name = "Druid's Chest" },
	[5] = { item = 61721, count = 1, price = 50, name = "Knight's Chest" },
	[6] = { item = 61719, count = 1, price = 50, name = "Sorcerer's Chest" },
}

local TASK_STORE_OUTFIT_PRICE = 1000
local TASK_STORE_OUTFITS = {
	{ name = "Citizen", female = 136, male = 128 },
	{ name = "Hunter", female = 137, male = 129 },
	{ name = "Mage", female = 138, male = 130 },
	{ name = "Knight", female = 139, male = 131 },
	{ name = "Noble", female = 140, male = 132 },
	{ name = "Summoner", female = 141, male = 133 },
	{ name = "Warrior", female = 142, male = 134 },
	{ name = "Barbarian", female = 147, male = 143 },
	{ name = "Druid", female = 148, male = 144 },
	{ name = "Wizard", female = 149, male = 145 },
	{ name = "Oriental", female = 150, male = 146 },
	{ name = "Pirate", female = 155, male = 151 },
	{ name = "Assassin", female = 156, male = 152 },
	{ name = "Beggar", female = 157, male = 153 },
	{ name = "Shaman", female = 158, male = 154 },
	{ name = "Norse", female = 252, male = 251 },
	{ name = "Nightmare", female = 269, male = 268 },
	{ name = "Jester", female = 270, male = 273 },
	{ name = "Brotherhood", female = 279, male = 278 },
	{ name = "Demon Hunter", female = 288, male = 289 },
	{ name = "Yalaharian", female = 324, male = 325 },
	{ name = "Newly Wed", female = 329, male = 328 },
	{ name = "Warmaster", female = 336, male = 335 },
	{ name = "Wayfarer", female = 366, male = 367 },
	{ name = "Afflicted", female = 431, male = 430 },
	{ name = "Elementalist", female = 433, male = 432 },
	{ name = "Deepling", female = 464, male = 463 },
	{ name = "Insectoid", female = 466, male = 465 },
	{ name = "Entrepreneur", female = 471, male = 472 },
	{ name = "Crystal Warlord", female = 513, male = 512 },
	{ name = "Soil Guardian", female = 514, male = 516 },
	{ name = "Demon", female = 542, male = 541 },
	{ name = "Cave Explorer", female = 575, male = 574 },
	{ name = "Dream Warden", female = 578, male = 577 },
	{ name = "Glooth Engineer", female = 618, male = 610 },
	{ name = "Jersey", female = 620, male = 619 },
	{ name = "Champion", female = 632, male = 633 },
	{ name = "Conjurer", female = 635, male = 634 },
	{ name = "Beastmaster", female = 636, male = 637 },
	{ name = "Chaos Acolyte", female = 664, male = 665 },
	{ name = "Death Herald", female = 666, male = 667 },
	{ name = "Ranger", female = 683, male = 684 },
	{ name = "Ceremonial Garb", female = 694, male = 695 },
	{ name = "Puppeteer", female = 696, male = 697 },
	{ name = "Spirit Caller", female = 698, male = 699 },
	{ name = "Evoker", female = 724, male = 725 },
	{ name = "Seaweaver", female = 732, male = 733 },
	{ name = "Recruiter", female = 745, male = 746 },
	{ name = "Sea Dog", female = 749, male = 750 },
	{ name = "Royal Pumpkin", female = 759, male = 760 },
	{ name = "Rift Warrior", female = 845, male = 846 },
	{ name = "Winter Warden", female = 852, male = 853 },
	{ name = "Philosopher", female = 874, male = 873 },
	{ name = "Arena Champion", female = 885, male = 884 },
	{ name = "Lupine Warden", female = 900, male = 899 },
	{ name = "Grove Keeper", female = 909, male = 908 },
	{ name = "Festive", female = 929, male = 931 },
	{ name = "Pharaoh", female = 956, male = 955 },
	{ name = "Trophy Hunter", female = 958, male = 957 },
	{ name = "Retro Warrior", female = 963, male = 962 },
	{ name = "Retro Summoner", female = 965, male = 964 },
	{ name = "Retro Noble", female = 967, male = 966 },
	{ name = "Retro Mage", female = 969, male = 968 },
	{ name = "Retro Knight", female = 971, male = 970 },
	{ name = "Retro Hunter", female = 973, male = 972 },
	{ name = "Retro Citizen", female = 975, male = 974 },
	{ name = "Herbalist", female = 1020, male = 1021 },
	{ name = "Sun Priest", female = 1024, male = 1023 },
	{ name = "Makeshift Warrior", female = 1043, male = 1042 },
	{ name = "Siege Master", female = 1050, male = 1051 },
	{ name = "Mercenary", female = 1057, male = 1056 },
	{ name = "Battle Mage", female = 1070, male = 1069 },
	{ name = "Discoverer", female = 1095, male = 1094 },
	{ name = "Sinister Archer", female = 1103, male = 1102 },
	{ name = "Pumpkin Mummy", female = 1128, male = 1127 },
	{ name = "Dream Warrior", female = 1147, male = 1146 },
	{ name = "Percht Raider", female = 1162, male = 1161 },
	{ name = "Owl Keeper", female = 1174, male = 1173 },
	{ name = "Guidon Bearer", female = 1187, male = 1186 },
	{ name = "Void Master", female = 1203, male = 1202 },
	{ name = "Veteran Paladin", female = 1205, male = 1204 },
	{ name = "Lion of War", female = 1207, male = 1206 },
	{ name = "Golden", female = 1211, male = 1210 },
	{ name = "Hand of the Inquisition", female = 1244, male = 1243 },
	{ name = "Breezy Garb", female = 1246, male = 1245 },
	{ name = "Orcsoberfest Garb", female = 1252, male = 1251 },
	{ name = "Poltergeist", female = 1271, male = 1270 },
	{ name = "Herder", female = 1280, male = 1279 },
	{ name = "Falconer", female = 1283, male = 1282 },
	{ name = "Dragon Slayer", female = 1289, male = 1288 },
	{ name = "Trailblazer", female = 1293, male = 1292 },
	{ name = "Revenant", female = 1323, male = 1322 },
	{ name = "Jouster", female = 1332, male = 1331 },
	{ name = "Moth Cape", female = 1339, male = 1338 },
	{ name = "Rascoohan", female = 1372, male = 1371 },
	{ name = "Merry Garb", female = 1383, male = 1382 },
	{ name = "Rune Master", female = 1385, male = 1384 },
	{ name = "Citizen of Issavi", female = 1387, male = 1386 },
	{ name = "Forest Warden", female = 1416, male = 1415 },
	{ name = "Royal Bounacean Advisor", female = 1437, male = 1436 },
	{ name = "Dragon Knight", female = 1445, male = 1444 },
	{ name = "Arbalester", female = 1450, male = 1449 },
	{ name = "Royal Costume", female = 1456, male = 1457 },
	{ name = "Formal Dress", female = 1461, male = 1460 },
	{ name = "Ghost Blade", female = 1490, male = 1489 },
	{ name = "Nordic Chieftain", female = 1501, male = 1500 },
	{ name = "Fire-Fighter", female = 1569, male = 1568 },
	{ name = "Fencer", female = 1576, male = 1575 },
	{ name = "Shadowlotus Disciple", female = 1582, male = 1581 },
	{ name = "Ancient Aucar", female = 1598, male = 1597 },
	{ name = "Frost Tracer", female = 1613, male = 1612 },
	{ name = "Armoured Archer", female = 1619, male = 1618 },
	{ name = "Decaying Defender", female = 1663, male = 1662 },
	{ name = "Darklight Evoker", female = 1676, male = 1675 },
	{ name = "Flamefury Mage", female = 1681, male = 1680 },
	{ name = "Doom Knight", female = 1714, male = 1713 },
	{ name = "Draccoon Herald", female = 1723, male = 1722 },
	{ name = "Celestial Avenger", female = 1726, male = 1725 },
	{ name = "Blade Dancer", female = 1746, male = 1745 },
	{ name = "Rootwalker", female = 1775, male = 1774 },
	{ name = "Beekeeper", female = 1777, male = 1776 },
	{ name = "Fiend Slayer", female = 1808, male = 1809 },
	{ name = "Field Surgeon", female = 1815, male = 1814 },
	{ name = "Monk", female = 1825, male = 1824 },
	{ name = "Winged Druid", female = 1832, male = 1831 },
	{ name = "Martial Artist", female = 1838, male = 1837 },
	{ name = "Necromancer", female = 1846, male = 1845 },
	{ name = "Illuminator", female = 1861, male = 1860 },
	{ name = "Bat Knight", female = 1875, male = 1874 },
	{ name = "Feral Trapper", female = 1906, male = 4050 },
}

local function taskCoinReward(task)
	if task.id >= 91 and task.id <= 94 then return 10 end
	if task.id >= 88 and task.id <= 90 then return 8 end
	if task.id >= 83 and task.id <= 87 then return 5 end
	return task.points or 0
end

local function storageId(key)
	if key == "active" then return STORAGE.active, false end
	if key == "points" then return STORAGE.points, false end
	local id = tonumber(key:match("^progress%-(%d+)$"))
	if id then return (id <= 10 and STORAGE.progress or STORAGE.extendedProgress) + id, false end
	id = tonumber(key:match("^claimed%-(%d+)$"))
	if id then return (id <= 10 and STORAGE.claimed or STORAGE.extendedClaimed) + id, true end
	id = tonumber(key:match("^run%-finished%-(%d+)$"))
	if id then return (id <= 10 and STORAGE.runFinished or STORAGE.extendedRunFinished) + id, true end
	id = tonumber(key:match("^claimed%-run%-(%d+)$"))
	if id then return (id <= 10 and STORAGE.claimedRun or STORAGE.extendedClaimedRun) + id, true end
	id = tonumber(key:match("^hall%-reward%-(%d+)$"))
	if id then return STORAGE.hallReward + id, false end
	return nil, false
end

local function storage(player)
	return {
		get = function(_, key)
			local id, booleanValue = storageId(key)
			if not id then return nil end
			local value = player:getStorageValue(id)
			if value < 0 then return nil end
			if booleanValue then return value == 1 end
			return value
		end,
		set = function(_, key, value)
			local id, booleanValue = storageId(key)
			if not id then return false end
			if booleanValue then value = value and 1 or 0 end
			player:setStorageValue(id, tonumber(value) or 0)
			return true
		end,
	}
end

local function escape(value)
	return tostring(value):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")
end

local function send(player, payload)
	player:sendExtendedOpcode(OPCODE, payload)
end

local function taskMonsters(task)
	return task.monsters or { { name = task.monster, raceId = task.raceId, lookType = task.lookType or task.raceId } }
end

local function previousTask(task)
	local previous
	for _, candidate in ipairs(TASKS) do
		if candidate == task then return previous end
		if candidate.category == task.category then previous = candidate end
	end
	return previous
end

local function getState(player, task)
	local kv = storage(player)
	local isGod = player:getGroup():getAccess()
	local active = kv:get("active") or 0
	local claimed = kv:get("claimed-" .. task.id) and true or false
	local runFinished = kv:get("run-finished-" .. task.id) and true or false
	local previous = previousTask(task)
	local unlocked = isGod or not previous or kv:get("claimed-" .. previous.id)
	if active == task.id then
		if runFinished then return claimed and 6 or 3 end
		return claimed and 5 or 2
	end
	if claimed then return 4 end
	return unlocked and 1 or 0
end

local function sendList(player)
	local kv = storage(player)
	local categories = { {}, {}, {}, {}, {} }
	for _, task in ipairs(TASKS) do
		local progress = kv:get("progress-" .. task.id) or 0
		local state = getState(player, task)
		categories[task.category][#categories[task.category] + 1] = string.format(
			'{"id":%d,"name":"%s","kills":%d,"stars":%d,"exp":%d,"loot":%d,"background":%d,"status":%d,"progress":%d,"monster1":%d,"monster2":0,"monster3":0}',
			task.id, escape(task.name), task.kills, task.stars, task.exp, task.loot, task.background,
			state, math.min(100, math.floor(progress * 100 / task.kills)), task.raceId
		)
	end
	local encoded = {}
	for index = 1, 5 do encoded[index] = "[" .. table.concat(categories[index], ",") .. "]" end
	send(player, string.format('{"action":"list","points":%d,"categories":[%s]}', kv:get("points") or 0, table.concat(encoded, ",")))
end

local function sendCategory(player, category)
	category = math.max(1, math.min(5, tonumber(category) or 1))
	local kv = storage(player)
	local rows = {}
	for _, task in ipairs(TASKS) do
		if task.category == category then
			local progress = kv:get("progress-" .. task.id) or 0
			local monsters = taskMonsters(task)
			rows[#rows + 1] = string.format(
				'{"id":%d,"name":"%s","kills":%d,"stars":%d,"exp":%d,"loot":%d,"background":%d,"status":%d,"progress":%d,"monster1":%d,"monster2":0,"monster3":0}',
				task.id, escape(task.name), task.kills, task.stars, task.exp, task.loot, task.background,
				getState(player, task), math.min(100, math.floor(progress * 100 / task.kills)), monsters[1] and monsters[1].lookType or 0
			)
			rows[#rows] = rows[#rows]:gsub('"monster2":0', '"monster2":' .. tostring(monsters[2] and monsters[2].lookType or 0)):gsub('"monster3":0', '"monster3":' .. tostring(monsters[3] and monsters[3].lookType or 0))
		end
	end
	send(player, string.format('{"type":"category","category":%d,"taskPoints":%d,"tasks":[%s]}', category, kv:get("points") or 0, table.concat(rows, ",")))
end

local function sendTracker(player)
	local kv = storage(player)
	local task = BY_ID[kv:get("active") or 0]
	if not task then
		return send(player, '{"type":"tracker","list":[]}')
	end
	local progress = kv:get("progress-" .. task.id) or 0
	local creatures = {}
	for _, monster in ipairs(taskMonsters(task)) do
		creatures[#creatures + 1] = string.format('{"name":"%s","kills":%d,"lookType":%d}', escape(monster.displayName or monster.name), progress, monster.lookType or 0)
	end
	local first = taskMonsters(task)[1]
	send(player, string.format('{"type":"tracker","list":[{"name":"%s","kills":%d,"total":%d,"lookType":%d,"creatures":[%s]}]}', escape(task.name), progress, task.kills, first.lookType or 0, table.concat(creatures, ",")))
end

local function sendDetail(player, task)
	local kv = storage(player)
	local progress = kv:get("progress-" .. task.id) or 0
	local repeatExperience = task.repeatExperience or math.max(0, math.floor(task.experience / 2))
	local repeatPoints = math.max(1, math.floor(task.points / 2))
	local rewards = task.noItemReward and string.format('[{"item":0,"count":%d,"countMax":0,"special":false}]', task.experience) or string.format('[{"item":0,"count":%d,"countMax":0,"special":false},{"taskPoints":true,"count":%d},{"item":30316,"count":1,"countMax":0,"special":%s}]', task.experience, task.points, task.id % 2 == 0 and "true" or "false")
	local secondRewards = task.noItemReward and string.format('[{"item":0,"count":%d,"countMax":0,"special":false}]', repeatExperience) or string.format('[{"item":0,"count":%d,"countMax":0,"special":false},{"taskPoints":true,"count":%d}]', repeatExperience, repeatPoints)
	if task.itemRewards then
		local rewardRows = {
			string.format('{"item":0,"count":%d,"countMax":0,"special":false}', task.experience),
		}
		local repeatRewardRows = {
			string.format('{"item":0,"count":%d,"countMax":0,"special":false}', repeatExperience),
		}
		local coinReward = taskCoinReward(task)
		if coinReward > 0 then
			rewardRows[#rewardRows + 1] = string.format('{"taskPoints":true,"count":%d}', coinReward)
			repeatRewardRows[#repeatRewardRows + 1] = string.format('{"taskPoints":true,"count":%d}', coinReward)
		end
		for _, reward in ipairs(task.itemRewards) do
			local rewardRow = string.format('{"item":%d,"count":%d,"countMax":0,"name":"%s","special":false}', reward.item, reward.count, escape(reward.name))
			rewardRows[#rewardRows + 1] = rewardRow
			if task.repeatItemRewards then
				repeatRewardRows[#repeatRewardRows + 1] = rewardRow
			end
		end
		rewards = "[" .. table.concat(rewardRows, ",") .. "]"
		secondRewards = "[" .. table.concat(repeatRewardRows, ",") .. "]"
	end
	local monsterRows, monsterIds = {}, {}
	for _, monster in ipairs(taskMonsters(task)) do
		monsterRows[#monsterRows + 1] = string.format('{"raceId":%d,"name":"%s","lookType":%d,"stars":%d}', monster.raceId or 0, escape(monster.displayName or monster.name), monster.lookType or 0, task.stars)
		monsterIds[#monsterIds + 1] = tostring(monster.raceId or 0)
	end
	local hunts = string.format('[{"name":"Recommended hunting place","position":{"x":32369,"y":32241,"z":7},"solo":%d,"party":%d,"experience":%d,"stars":%d,"creatures":[%d]}]', math.max(8, task.id * 20), math.max(8, task.id * 15), task.exp, task.stars, task.raceId)
	hunts = hunts:gsub('"creatures":%[[^%]]*%]', '"creatures":[' .. table.concat(monsterIds, ",") .. ']')
	local first = taskMonsters(task)[1]
	send(player, string.format('{"type":"selected","taskPoints":%d,"id":%d,"name":"%s","raceId":%d,"kills":%d,"total":%d,"state":%d,"rewards":%s,"secondRewards":%s,"hunts":%s,"creatures":[%s],"outfit":{"lookType":%d}}', kv:get("points") or 0, task.id, escape(task.name), first.raceId or 0, progress, task.kills, getState(player, task), rewards, secondRewards, hunts, table.concat(monsterRows, ","), first.lookType or 0))
end

local function message(player, text)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, text)
end

local function getStoredOutfitAddons(player)
	local outfits = {}
	local query = db.storeQuery(string.format("SELECT `outfit_id`, `addons` FROM `player_outfits` WHERE `player_id` = %d", player:getGuid()))
	if not query then return outfits end
	repeat
		outfits[result.getNumber(query, "outfit_id")] = result.getNumber(query, "addons")
	until not result.next(query)
	result.free(query)
	return outfits
end

local function ownsFullOutfit(player, lookType, storedOutfits)
	-- Access groups can wear everything, so hasOutfit() alone cannot tell what a GOD
	-- actually owns. Use persisted outfit data for them so the store remains testable.
	if player:getGroup():getAccess() then
		local addons = (storedOutfits or getStoredOutfitAddons(player))[lookType] or 0
		return addons == 3
	end
	return player:hasOutfit(lookType, 3)
end

local function sendTaskStore(player)
	local rows = {}
	for id, product in ipairs(TASK_STORE_PRODUCTS) do
		rows[#rows + 1] = string.format('{"id":%d,"item":%d,"count":%d,"price":%d,"name":"%s"}', id, product.item, product.count, product.price, escape(product.name))
	end
	local outfitRows = {}
	local female = player:getSex() == PLAYERSEX_FEMALE
	local storedOutfits = player:getGroup():getAccess() and getStoredOutfitAddons(player) or nil
	for id, outfit in ipairs(TASK_STORE_OUTFITS) do
		local lookType = female and outfit.female or outfit.male
		outfitRows[#outfitRows + 1] = string.format(
			'{"id":%d,"lookType":%d,"price":%d,"name":"%s","owned":%s}',
			id, lookType, TASK_STORE_OUTFIT_PRICE, escape(outfit.name), ownsFullOutfit(player, lookType, storedOutfits) and "true" or "false"
		)
	end
	local balance = storage(player):get("points") or 0
	send(player, string.format('{"type":"task_store","taskPoints":%d,"products":[%s],"outfits":[%s]}', balance, table.concat(rows, ","), table.concat(outfitRows, ",")))
end

local function buyTaskStoreProduct(player, id)
	local product = TASK_STORE_PRODUCTS[id]
	if not product then return message(player, "Invalid Task Store product.") end
	local kv = storage(player)
	local balance = kv:get("points") or 0
	if balance < product.price then
		message(player, string.format("You need %d Task Coins to buy %s.", product.price, product.name))
		return sendTaskStore(player)
	end
	kv:set("points", balance - product.price)
	player:addItemStoreInbox(product.item, product.count, true, false)
	player:save()
	message(player, string.format("You bought %s for %d Task Coins. It was sent to your Store Inbox.", product.name, product.price))
	sendTaskStore(player)
end

local function buyTaskStoreOutfit(player, id)
	local outfit = TASK_STORE_OUTFITS[id]
	if not outfit then return message(player, "Invalid Task Store outfit.") end

	local lookType = player:getSex() == PLAYERSEX_FEMALE and outfit.female or outfit.male
	if ownsFullOutfit(player, lookType) then
		message(player, string.format("You already own %s with Addon 1 and Addon 2.", outfit.name))
		return sendTaskStore(player)
	end

	local kv = storage(player)
	local balance = kv:get("points") or 0
	if balance < TASK_STORE_OUTFIT_PRICE then
		message(player, string.format("You need %d Task Coins to buy %s.", TASK_STORE_OUTFIT_PRICE, outfit.name))
		return sendTaskStore(player)
	end

	-- Grant both variants so the purchased outfit remains available after a sex change.
	player:addOutfit(outfit.female, 3)
	player:addOutfit(outfit.male, 3)
	if not player:hasOutfit(lookType, 3) then
		message(player, "The outfit could not be delivered. No Task Coins were charged.")
		return sendTaskStore(player)
	end

	kv:set("points", balance - TASK_STORE_OUTFIT_PRICE)
	player:save()
	message(player, string.format("You bought %s with Addon 1 and Addon 2 for %d Task Coins.", outfit.name, TASK_STORE_OUTFIT_PRICE))
	sendTaskStore(player)
end

local HALL_MILESTONES = { 2, 4, 6 }

-- Rewards deliberately use items that exist in Crystal.  The Hall screen always
-- shows the next unclaimed milestone, while the overview lists every task.
local function getHallReward(category, tier)
	if category == 5 then
		return {
			{ item = 61718, count = 1, name = "Mystic Bag" },
			{ item = 61608, count = 1, name = "Tigrinho Roulette Coin" },
			{ item = 61722, count = 1, name = "Paladin's Chest" },
			{ item = 61720, count = 1, name = "Druid's Chest" },
			{ item = 61721, count = 1, name = "Knight's Chest" },
			{ item = 61719, count = 1, name = "Sorcerer's Chest" },
		}
	end
	if tier == 1 then
		return { { item = 30316, count = category, name = "Mystic Bag" } }
	elseif tier == 2 then
		return { { item = 61608, count = math.max(1, category), name = "Roulette Coin" } }
	end
	return {
		{ item = 30316, count = category + 1, name = "Mystic Bag" },
		{ item = 61608, count = math.max(1, category), name = "Roulette Coin" },
	}
end

local function getHallProgress(player, category)
	local kv = storage(player)
	local isGod = player:getGroup():getAccess()
	local completed = 0
	local rows = {}
	for _, task in ipairs(TASKS) do
		if task.category == category then
			local progress = kv:get("progress-" .. task.id) or 0
			local claimed = kv:get("claimed-" .. task.id) and true or false
			if claimed or isGod then completed = completed + 1 end
			rows[#rows + 1] = {
				name = task.name,
				progress = (claimed or isGod) and 100 or math.min(99, math.floor(progress * 100 / task.kills)),
				second = claimed or isGod,
			}
		end
	end
	return completed, rows
end

local function sendHall(player, category)
	category = tonumber(category) or 0
	if category < 1 or category > 5 then return sendCategory(player, 1) end
	local kv = storage(player)
	local completed, tasks = getHallProgress(player, category)
	local claimedTier = math.max(0, math.min(3, kv:get("hall-reward-" .. category) or 0))
	local nextTier = math.min(3, claimedTier + 1)
	local state = claimedTier >= 3 and 2 or (completed >= HALL_MILESTONES[nextTier] and 1 or 0)
	local rewardRows = {}
	for _, reward in ipairs(getHallReward(category, nextTier)) do
		rewardRows[#rewardRows + 1] = string.format('{"item":%d,"count":%d,"name":"%s"}', reward.item, reward.count, escape(reward.name))
	end
	local taskRows = {}
	for _, task in ipairs(tasks) do
		taskRows[#taskRows + 1] = string.format('{"name":"%s","progress":%d,"second":%s}', escape(task.name), task.progress, task.second and "true" or "false")
	end
	send(player, string.format('{"type":"reward","taskPoints":%d,"level":%d,"state":%d,"rewards":[%s],"tasks":[%s]}', kv:get("points") or 0, category, state, table.concat(rewardRows, ","), table.concat(taskRows, ",")))
end

local function claimHall(player, category)
	category = tonumber(category) or 0
	if category < 1 or category > 5 then return message(player, "Invalid Task Hall.") end
	local kv = storage(player)
	local completed = getHallProgress(player, category)
	local claimedTier = math.max(0, math.min(3, kv:get("hall-reward-" .. category) or 0))
	if claimedTier >= 3 then return message(player, "All rewards from this Task Hall were already claimed.") end
	local nextTier = claimedTier + 1
	local required = HALL_MILESTONES[nextTier]
	if completed < required then return message(player, string.format("Complete %d tasks in this Hall to unlock the next reward.", required)) end
	for _, reward in ipairs(getHallReward(category, nextTier)) do
		player:addItemStoreInbox(reward.item, reward.count, true, false)
	end
	kv:set("hall-reward-" .. category, nextTier)
	player:save()
	message(player, string.format("Task Hall milestone %d/3 claimed! The rewards were sent to your Store Inbox.", nextTier))
	sendHall(player, category)
end

local opcodeEvent = CreatureEvent("CrystalLinkedTasksOpcode")
function opcodeEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= OPCODE then return end
	local actionName = buffer:match('"action"%s*:%s*"([^"]+)"')
	local action = tonumber(buffer:match('"action"%s*:%s*(%d+)'))
	local id = tonumber(buffer:match('"id"%s*:%s*(%d+)')) or 0
	logger.info("[LinkedTasks] action={} id={} player={}", actionName or tostring(action), id, player:getName())
	if actionName == "category" then return sendCategory(player, id) end
	if actionName == "task_store" then return sendTaskStore(player) end
	if actionName == "task_store_buy" then return buyTaskStoreProduct(player, id) end
	if actionName == "task_store_buy_outfit" then return buyTaskStoreOutfit(player, id) end
	local actionMap = { request = 0, start = 1, cancel = 2, claim = 3 }
	action = action or actionMap[actionName]
	if action == 0 then
		if id >= 1000 and id % 1000 == 0 then
			sendHall(player, math.floor(id / 1000))
		elseif id == 0 then sendCategory(player, 1) else
			local task = BY_ID[id]
			if task then sendDetail(player, task) else sendList(player) end
		end
		return
	end
	if action == 3 and id >= 1000 and id % 1000 == 0 then
		return claimHall(player, math.floor(id / 1000))
	end
	local task = BY_ID[id]
	if not task then return message(player, "Invalid task.") end
	local kv = storage(player)
	if action == 1 then
		if (kv:get("active") or 0) ~= 0 then return message(player, "You already have an active task.") end
		local state = getState(player, task)
		if state ~= 1 and state ~= 4 then return message(player, "This task is still locked.") end
		kv:set("active", id)
		kv:set("progress-" .. id, 0)
		kv:set("run-finished-" .. id, false)
		player:save()
		message(player, "Task started: " .. task.name .. ".")
		sendDetail(player, task)
		sendTracker(player)
	elseif action == 2 then
		if (kv:get("active") or 0) ~= id then return message(player, "This task is not active.") end
		kv:set("active", 0)
		kv:set("progress-" .. id, 0)
		kv:set("run-finished-" .. id, false)
		player:save()
		message(player, "Task cancelled.")
		sendDetail(player, task)
		sendTracker(player)
	elseif action == 3 then
		if not kv:get("run-finished-" .. id) then return message(player, "Finish all kills before claiming.") end
		if kv:get("claimed-run-" .. id) then return message(player, "This task reward was already claimed.") end
		local isRepetition = kv:get("claimed-" .. id) and true or false
		local rewardExperience = isRepetition and (task.repeatExperience or math.max(0, math.floor(task.experience / 2))) or task.experience
		local baseCoins = taskCoinReward(task)
		local rewardPoints = baseCoins
		if rewardExperience > 0 then player:addExperience(rewardExperience, true) end
		if task.itemRewards and (not isRepetition or task.repeatItemRewards) then
			for _, reward in ipairs(task.itemRewards) do
				player:addItemStoreInbox(reward.item, reward.count, true, false)
			end
		elseif not isRepetition and not task.noItemReward then
			player:addItemStoreInbox(30316, 1, true, false)
		end
		kv:set("points", (kv:get("points") or 0) + rewardPoints)
		kv:set("claimed-" .. id, true)
		kv:set("claimed-run-" .. id, true)
		kv:set("active", 0)
		player:save()
		if task.itemRewards and (not isRepetition or task.repeatItemRewards) then
			message(player, string.format("Task completed! You received %d experience, %d Task Coins and a Mystic Bag.", rewardExperience, rewardPoints))
		elseif task.noItemReward then
			message(player, string.format("Task completed! You received %d experience.", rewardExperience))
		elseif isRepetition then
			message(player, string.format("Task repeated! You received %d experience and %d Task Coins.", rewardExperience, rewardPoints))
		else
			message(player, string.format("Task completed! You received %d experience, %d Task Coins and a Mystic Bag.", rewardExperience, rewardPoints))
		end
		sendCategory(player, task.category)
		sendTracker(player)
	end
end
opcodeEvent:register()

local killEvent = CreatureEvent("CrystalLinkedTasksKill")
function killEvent.onDeath(target, corpse, killer)
	if not target or not target:isMonster() or not killer then return true end
	local player
	if killer:isPlayer() then
		player = killer:getPlayer()
	else
		local master = killer:getMaster()
		if master and master:isPlayer() then
			player = master:getPlayer()
		end
	end
	if not player then return true end
	local kv = storage(player)
	local active = kv:get("active") or 0
	local task = BY_ID[active]
	if not task or BY_MONSTER[target:getName():lower()] ~= task or kv:get("run-finished-" .. active) then return true end
	local progress = math.min((kv:get("progress-" .. active) or 0) + 1, task.kills)
	kv:set("progress-" .. active, progress)
	if progress >= task.kills then
		kv:set("run-finished-" .. active, true)
		kv:set("claimed-run-" .. active, false)
		message(player, "Task finished! Open the Task window to claim your reward.")
	elseif progress == 1 or progress % math.max(1, math.floor(task.kills / 10)) == 0 then
		message(player, string.format("%s: %d/%d", task.name, progress, task.kills))
	end
	player:save()
	sendTracker(player)
	return true
end
killEvent:register()

-- onKill registered on every player is deprecated and runs through the
-- expensive kill-event path. Register both progression handlers directly on
-- monster deaths instead; the handlers still credit only the last-hit player.
local progressionDeathStartup = GlobalEvent("CrystalProgressionDeathStartup")
function progressionDeathStartup.onStartup()
	local count = 0
	for _, monsterType in pairs(Game.getMonsterTypes()) do
		monsterType:registerEvent("CrystalLinkedTasksKill")
		monsterType:registerEvent("CrystalBattlePassKill")
		count = count + 1
	end
	logger.info("[CrystalProgression] Registered death handlers on {} monster types.", count)
	return true
end
progressionDeathStartup:register()

CrystalLinkedTasks = CrystalLinkedTasks or {}

function CrystalLinkedTasks.onCommand(player, param)
	local kv = storage(player)
	local task = BY_ID[kv:get("active") or 0]
	param = (param or ""):lower():match("^%s*(.-)%s*$")
	if param == "clear" then
		if not task then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You do not have an active Linked Task.")
			return false
		end
		kv:set("active", 0)
		kv:set("progress-" .. task.id, 0)
		kv:set("run-finished-" .. task.id, false)
		player:save()
		message(player, "Your active Linked Task was cleared.")
		sendTracker(player)
		return false
	elseif param == "bonus" then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You currently have no temporary Linked Task bonus active.")
		return false
	elseif param == "test" and (player:getGroup():getAccess() or player:getName() == "Paladin Sample") then
		if not task then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Start a task before using the test command.")
			return false
		end
		kv:set("progress-" .. task.id, task.kills)
		kv:set("run-finished-" .. task.id, true)
		kv:set("claimed-run-" .. task.id, false)
		player:save()
		message(player, "Test progress completed. Open Linked Tasks and claim the reward.")
		sendTracker(player)
		return false
	end
	if not task then return player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You do not have an active Linked Task.") end
	local progress = kv:get("progress-" .. task.id) or 0
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("%s: %d/%d %s.", task.name, progress, task.kills, task.monster))
	return false
end
