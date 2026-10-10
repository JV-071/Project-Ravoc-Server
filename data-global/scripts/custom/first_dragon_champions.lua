-- The First Dragon: five champions test encounter.
-- Lever position: 32744, 31532, 15 (Action ID 9001 in the map editor).

local config = {
	leverPosition = Position(32744, 31532, 15),
	-- The two appearances of the lever placed in the map editor.
	leverOffId = 36973,
	leverOnId = 36974,
	arenaCenter = Position(32745, 31569, 15),
	entrance = Position(32745, 31578, 15),
	exit = Position(32702, 31594, 7),
	exitTeleport = Position(32745, 31577, 15),
	arena = {
		from = Position(32724, 31542, 15),
		to = Position(32765, 31582, 15),
	},
	champions = {
		{ name = "Fiona Firstdream", position = Position(32739, 31562, 15) },
		{ name = "Grendel Greenlunch", position = Position(32750, 31562, 15) },
		{ name = "Nigel Neverguess", position = Position(32745, 31566, 15) },
		{ name = "Percy Peacetinker", position = Position(32739, 31571, 15) },
		{ name = "Yorik Youngbook", position = Position(32750, 31571, 15) },
	},
}

local championNames = {}
for _, champion in ipairs(config.champions) do
	championNames[champion.name:lower()] = true
end

local function isInArena(position)
	return position:isInRange(config.arena.from, config.arena.to)
end

local function removeEncounterMonsters()
	for _, creature in ipairs(Game.getSpectators(config.arenaCenter, false, false, 22, 22, 22, 22)) do
		local monster = creature:getMonster()
		if monster then
			local name = monster:getName():lower()
			if championNames[name] or name == "fatal bug" then
				monster:remove()
			end
		end
	end
end

local function championsAlive()
	for _, creature in ipairs(Game.getSpectators(config.arenaCenter, false, false, 22, 22, 22, 22)) do
		local monster = creature:getMonster()
		if monster and championNames[monster:getName():lower()] then
			return true
		end
	end
	return false
end

local function fatalBugAlive()
	for _, creature in ipairs(Game.getSpectators(config.arenaCenter, false, false, 22, 22, 22, 22)) do
		local monster = creature:getMonster()
		if monster and monster:getName():lower() == "fatal bug" then
			return true
		end
	end
	return false
end

local function createExitTeleport()
	local tile = Tile(config.exitTeleport)
	if tile and tile:getItemById(35502) then
		return
	end

	local teleport = Game.createItem(35502, 1, config.exitTeleport)
	if teleport and teleport:isTeleport() then
		teleport:setDestination(config.exit)
		config.exitTeleport:sendMagicEffect(CONST_ME_TELEPORT)
	end
end

local function setLeverState(item, active)
	if not item or item:isRemoved() then
		return
	end

	local wantedId = active and config.leverOnId or config.leverOffId
	if item:getId() ~= wantedId then
		item:transform(wantedId)
	end
end

local function resetLever()
	local tile = Tile(config.leverPosition)
	if not tile then
		return
	end

	for _, item in ipairs(tile:getItems() or {}) do
		if item:getId() == config.leverOnId or item:getId() == config.leverOffId then
			setLeverState(item, false)
			return
		end
	end
end

local function markArenaPlayersAsFinished()
	for _, creature in ipairs(Game.getSpectators(config.arenaCenter, false, true, 22, 22, 22, 22)) do
		local player = creature:getPlayer()
		if player then
			player:kv():scoped("first-dragon-champions"):set("fatal-bug-defeated", true)
		end
	end
end

local firstDragonDeath = CreatureEvent("FirstDragonChampionsDeath")

function firstDragonDeath.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	if not creature or not creature:isMonster() or not isInArena(creature:getPosition()) then
		return true
	end

	local name = creature:getName():lower()
	if championNames[name] then
		addEvent(function()
			if not championsAlive() and not fatalBugAlive() then
				Game.createMonster("Fatal Bug", config.arenaCenter, true, true)
				config.arenaCenter:sendMagicEffect(CONST_ME_MORTAREA)
			end
		end, 1000)
	elseif name == "fatal bug" then
		markArenaPlayersAsFinished()
		addEvent(createExitTeleport, 1000)
		addEvent(resetLever, 1000)
	end

	return true
end

firstDragonDeath:register()

local firstDragonLever = Action()

function firstDragonLever.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not player then
		return false
	end

	if championsAlive() or fatalBugAlive() then
		player:sendCancelMessage("The First Dragon encounter is already in progress.")
		return true
	end

	setLeverState(item, true)
	player:teleportTo(config.entrance, true)
	config.entrance:sendMagicEffect(CONST_ME_TELEPORT)

	for _, champion in ipairs(config.champions) do
		Game.createMonster(champion.name, champion.position, true, true)
	end

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The five champions of The First Dragon have appeared.")
	return true
end

-- Bind both ways: Action ID is convenient in the editor, while the exact
-- position keeps this particular lever working even if its map attribute is
-- accidentally reset.
firstDragonLever:aid(9001)
firstDragonLever:position(config.leverPosition)
firstDragonLever:register()

local firstDragonStartup = GlobalEvent("FirstDragonChampionsStartup")

function firstDragonStartup.onStartup()
	for _, champion in ipairs(config.champions) do
		local monsterType = MonsterType(champion.name)
		if monsterType then
			monsterType:registerEvent("FirstDragonChampionsDeath")
		end
	end

	local fatalBug = MonsterType("Fatal Bug")
	if fatalBug then
		fatalBug:registerEvent("FirstDragonChampionsDeath")
	end
	return true
end

firstDragonStartup:register()
