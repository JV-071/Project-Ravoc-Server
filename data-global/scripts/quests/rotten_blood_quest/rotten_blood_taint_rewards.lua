-- Rotten Blood: progression through the four lair bosses.
-- Each boss grants one permanent Taint to players still inside its arena.

local bosses = {
	["murcion"] = { key = "taint-murcion", difficultyStorage = 910200, center = Position(33008, 32367, 15), radiusX = 12, radiusY = 12 },
	["ichgahal"] = { key = "taint-ichgahal", difficultyStorage = 910201, center = Position(33008, 32334, 15), radiusX = 14, radiusY = 14 },
	["chagorz"] = { key = "taint-chagorz", difficultyStorage = 910202, center = Position(33043, 32366, 15), radiusX = 12, radiusY = 12 },
	["vemiath"] = { key = "taint-vemiath", difficultyStorage = 910203, center = Position(33043, 32335, 15), radiusX = 14, radiusY = 14 },
}

local function completedTaints(kv)
	local total = 0
	for _, boss in pairs(bosses) do
		if kv:get(boss.key) then
			total = total + 1
		end
	end
	return total
end

local function applyTaint(player, level)
	player:removeCondition(CONDITION_BAKRAGORE, CONDITIONID_DEFAULT)
	local condition = Condition(CONDITION_BAKRAGORE, CONDITIONID_DEFAULT)
	condition:setParameter(CONDITION_PARAM_SUBID, level)
	condition:setParameter(CONDITION_PARAM_TICKS, 68 * 60 * 60 * 1000)
	player:addCondition(condition)
	player:setIcon("rotten-hazard", CreatureIconCategory_Quests, CreatureIconQuests_Hazard, level)
end

local function getEligiblePlayers(creature, boss)
	local players = {}
	local seen = {}
	local instanceId = creature:getStorageValue("RottenBloodInstanceId")

	-- Instance bosses live in copied rooms, so the original arena coordinates
	-- cannot be used to find their party. Resolve the exact instance instead.
	if instanceId and instanceId > 0 and RottenBloodInstances and RottenBloodInstances.active then
		local instance = RottenBloodInstances.active[instanceId]
		if instance then
			for playerId in pairs(instance.players) do
				local player = Player(playerId)
				if player and RottenBloodInstances.playerInstances[playerId] == instanceId then
					local position = player:getPosition()
					if position.z == instance.from.z
						and position.x >= instance.from.x and position.x <= instance.to.x
						and position.y >= instance.from.y and position.y <= instance.to.y
					then
						players[#players + 1] = player
						seen[playerId] = true
					end
				end
			end
			return players
		end
	end

	-- Preserve support for the original, non-instanced boss rooms.
	for _, spectator in ipairs(Game.getSpectators(boss.center, false, true, boss.radiusX, boss.radiusX, boss.radiusY, boss.radiusY)) do
		local player = spectator:getPlayer()
		if player and not seen[player:getId()] then
			players[#players + 1] = player
			seen[player:getId()] = true
		end
	end
	return players
end

local taintReward = CreatureEvent("RottenBloodTaintReward")

function taintReward.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	if not creature or not creature:isMonster() then
		return true
	end

	local boss = bosses[creature:getName():lower()]
	if not boss then
		return true
	end

	for _, player in ipairs(getEligiblePlayers(creature, boss)) do
			-- This event is guaranteed to run for the four descendants, so it is
			-- also the reliable place to persist their individual difficulty progress.
			local difficulty = creature:getStorageValue("RottenBloodBossDifficulty")
			if not difficulty or difficulty < 0 then
				difficulty = Game.getStorageValue("RottenBloodBossDifficulty")
			end
			difficulty = difficulty and difficulty >= 0 and difficulty or 1
			if difficulty > 0 then
				local currentMaximum = math.max(1, player:getStorageValue(boss.difficultyStorage))
				local unlockedMaximum = math.min(25, difficulty + 3)
				if unlockedMaximum > currentMaximum then
					player:setStorageValue(boss.difficultyStorage, unlockedMaximum)
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You unlocked Rotten Blood difficulty %d for %s.", unlockedMaximum, creature:getName()))
					logger.info("[RottenBloodDifficulty] {} unlocked difficulty {} for {}", player:getName(), unlockedMaximum, creature:getName())
				end
			end

			local kv = player:kv():scoped("rotten-blood-quest")
			if not kv:get(boss.key) then
				kv:set(boss.key, true)
				local completed = completedTaints(kv)
				-- The fourth descendant unlocks Bakragore's Final Taint (level 5),
				-- which strengthens the four previous effects.
				local level = completed >= 4 and 5 or completed
				kv:set("taints", level)
				applyTaint(player, level)
				if level == 5 then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You received Bakragore's Final Taint (5/5).")
				else
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You received Taint %d/4 for defeating %s.", level, creature:getName()))
				end
				player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
				if level == 5 then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "All four Taints are active. Bakragore's lair is now available.")
				end
			else
				-- Upgrade players that completed the four bosses before the Final
				-- Taint was added to this server.
				if completedTaints(kv) >= 4 and (kv:get("taints") or 0) < 5 then
					kv:set("taints", 5)
					applyTaint(player, 5)
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your four completed boss Taints have been upgraded to Bakragore's Final Taint (5/5).")
				else
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have already received the Taint from " .. creature:getName() .. ".")
				end
			end
	end

	return true
end

taintReward:register()
