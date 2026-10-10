-- Individual Rotten Blood boss-difficulty progression.
-- Defeating a boss unlocks up to three more levels for that same boss.

local bosses = {
	["murcion"] = { storage = 910200, center = Position(33008, 32367, 15), radiusX = 12, radiusY = 12 },
	["ichgahal"] = { storage = 910201, center = Position(33008, 32334, 15), radiusX = 14, radiusY = 14 },
	["chagorz"] = { storage = 910202, center = Position(33043, 32366, 15), radiusX = 12, radiusY = 12 },
	["vemiath"] = { storage = 910203, center = Position(33043, 32335, 15), radiusX = 14, radiusY = 14 },
	["bakragore"] = { storage = 910204, center = Position(33043, 32397, 15), radiusX = 15, radiusY = 15 },
	
}

local progress = CreatureEvent("RottenBloodDifficultyProgress")

function progress.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	if not creature or not creature:isMonster() then
		return true
	end

	local config = bosses[creature:getName():lower()]
	if not config then
		return true
	end

	local difficulty = creature:getStorageValue("RottenBloodBossDifficulty")
	if not difficulty or difficulty < 0 then
		difficulty = Game.getStorageValue("RottenBloodBossDifficulty")
	end
	difficulty = difficulty and difficulty >= 0 and difficulty or 1
	-- Training mode never grants loot or progression.
	if difficulty <= 0 then
		if corpse then
			for _, corpseItem in ipairs(corpse:getItems(true)) do
				corpseItem:remove()
			end
		end
		return true
	end

	local creditedPlayers = {}
	local function addPlayer(candidate)
		if not candidate then
			return
		end
		local player = candidate:getPlayer()
		if not player and candidate:getMaster() then
			player = candidate:getMaster():getPlayer()
		end
		if not player or creditedPlayers[player:getId()] then
			return
		end
		creditedPlayers[player:getId()] = player

		local party = player:getParty()
		if party then
			local leader = party:getLeader()
			if leader then
				creditedPlayers[leader:getId()] = leader
			end
			for _, member in ipairs(party:getMembers()) do
				creditedPlayers[member:getId()] = member
			end
		end
	end

	-- BossLever may remove players from the arena as soon as the boss dies.
	-- The killer/most-damage killer is therefore the reliable source of credit.
	addPlayer(killer)
	addPlayer(mostDamageKiller)

	-- Fallback for scripted deaths that have no killer information.
	if next(creditedPlayers) == nil then
		for _, spectator in ipairs(Game.getSpectators(config.center, false, true, config.radiusX, config.radiusY, config.radiusX, config.radiusY)) do
			addPlayer(spectator)
		end
	end

	local newMaximum = math.min(25, difficulty + 3)
	for _, player in pairs(creditedPlayers) do
		local currentMaximum = math.max(1, player:getStorageValue(config.storage))
		if newMaximum > currentMaximum then
			player:setStorageValue(config.storage, newMaximum)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You unlocked Rotten Blood difficulty %d for %s.", newMaximum, creature:getName()))
			logger.info("[RottenBloodDifficulty] {} unlocked difficulty {} for {}", player:getName(), newMaximum, creature:getName())
		end
	end

	return true
end

progress:register()
