-- Random boss invasion at Thais temple every five minutes.
-- Disabled: the server now uses the official Tibia raid definitions from
-- data-global/raids/raids.xml instead of spawning a boss inside the temple.
local ENABLED = false

if not ENABLED then
	return
end

local config = {
	interval = 5 * 60 * 1000,
	templePosition = Position(32370, 32215, 7),
	bosses = {
		"Orshabaal",
		"Morgaroth",
		"Ghazbaran",
		"Zugurosh",
		"Apocalypse",
		"Morshabaal",
	},
	spawnOffsets = {
		{ x = 0, y = 0 },
	},
}

local activeBossId
local previousBoss

local function removePreviousBoss()
	if not activeBossId then
		return
	end

	local creature = Creature(activeBossId)
	if creature and creature:isMonster() then
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		creature:remove()
	end
	activeBossId = nil
end

local function chooseBoss()
	if #config.bosses == 1 then
		return config.bosses[1]
	end

	local selected
	repeat
		selected = config.bosses[math.random(#config.bosses)]
	until selected ~= previousBoss
	previousBoss = selected
	return selected
end

local function createTempleBoss()
	removePreviousBoss()

	local bossName = chooseBoss()
	local startIndex = math.random(#config.spawnOffsets)
	for index = 0, #config.spawnOffsets - 1 do
		local offset = config.spawnOffsets[((startIndex + index - 1) % #config.spawnOffsets) + 1]
		local position = Position(
			config.templePosition.x + offset.x,
			config.templePosition.y + offset.y,
			config.templePosition.z
		)
		local boss = Game.createMonster(bossName, position, true, true)
		if boss then
			activeBossId = boss:getId()
			position:sendMagicEffect(CONST_ME_TELEPORT)
			Game.broadcastMessage(
				string.format("[Temple Boss] %s invaded the temple of Thais! A new boss appears every 5 minutes.", bossName),
				MESSAGE_GAME_HIGHLIGHT
			)
			logger.info("[Temple Boss] {} spawned at {}.", bossName, position)
			return true
		end
	end

	logger.error("[Temple Boss] Could not find a position to spawn {} near Thais temple.", bossName)
	return false
end

local templeBossEvent = GlobalEvent("ThaisTempleRandomBoss")
function templeBossEvent.onThink(interval)
	createTempleBoss()
	return true
end
templeBossEvent:interval(config.interval)
templeBossEvent:register()

local templeBossCommand = TalkAction("/templeboss")
function templeBossCommand.onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if createTempleBoss() then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "A random boss was summoned at Thais temple.")
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The temple boss could not be summoned. Check the server log.")
	end
	return false
end
templeBossCommand:separator(" ")
templeBossCommand:groupType("god")
templeBossCommand:register()
