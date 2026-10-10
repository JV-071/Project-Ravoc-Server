local taintCooldown = {}
local positionSwapCooldown = {}
local rootCooldown = {}
local elementalCooldown = {}

local function getPlayerHazardLevel(player)
	local kv = player:kv():scoped("rotten-blood-quest")
	local level = kv:get("taints") or 0
	local condition = player:getCondition(CONDITION_BAKRAGORE, CONDITIONID_DEFAULT)
	if condition then
		level = math.max(level, condition:getParameter(CONDITION_PARAM_SUBID) or 0)
	end
	return level
end

local function getTaintElement(position)
	if RottenBloodInstances and RottenBloodInstances.getByPosition then
		local instance = RottenBloodInstances.getByPosition(position)
		if instance then
			local elements = {
				murcion = { COMBAT_DEATHDAMAGE, CONST_ME_MORTAREA, "death" },
				ichgahal = { COMBAT_EARTHDAMAGE, CONST_ME_POISONAREA, "earth" },
				chagorz = { COMBAT_ENERGYDAMAGE, CONST_ME_ENERGYHIT, "energy" },
				vemiath = { COMBAT_FIREDAMAGE, CONST_ME_FIREAREA, "fire" },
				bakragore = { COMBAT_AGONYDAMAGE, CONST_ME_AGONY, "agony" },
			}
			local element = elements[instance.bossKey]
			if element then
				return element[1], element[2], element[3]
			end
		end
	end

	-- Each Rotten Blood hunting ground has its own fourth damage element.
	if position.x >= 33800 and position.x <= 33941 and position.y >= 31653 and position.y <= 31771 and (position.z == 14 or position.z == 15) then
		return COMBAT_DEATHDAMAGE, CONST_ME_MORTAREA, "death" -- Jaded Roots
	end
	if position.x >= 34002 and position.x <= 34115 and position.y >= 31658 and position.y <= 31770 and (position.z == 14 or position.z == 15) then
		return COMBAT_EARTHDAMAGE, CONST_ME_POISONAREA, "earth" -- Putrefactory
	end
	if position.x >= 33800 and position.x <= 33937 and position.y >= 31809 and position.y <= 31931 and (position.z == 14 or position.z == 15) then
		return COMBAT_ENERGYDAMAGE, CONST_ME_ENERGYHIT, "energy" -- Gloom Pillars
	end
	if position.x >= 34000 and position.x <= 34137 and position.y >= 31809 and position.y <= 31932 and (position.z == 14 or position.z == 15) then
		return COMBAT_FIREDAMAGE, CONST_ME_FIREAREA, "fire" -- Darklight Core
	end
	return nil
end

local function isInBakragoreZone(player)
	local bakragoreMonsters = {
		"sopping corpus",
		"oozing corpus",
		"mycobiontic beetle",
		"bloated man-maggot",
		"walking pillar",
		"darklight matter",
		"darklight source",
		"darklight striker",
		"darklight emitter",
		"darklight construct",
		"wandering pillar",
		"converter",
		"oozing carcass",
		"sopping carcass",
		"rotten man-maggot",
		"meandering mushroom",
	}
	local bakragoreBosses = {
		"bakragore",
		"vemiath",
		"chagorz",
		"murcion",
		"ichgahal",
	}

	local pos = player:getPosition()
	if RottenBloodInstances and RottenBloodInstances.getByPosition and RottenBloodInstances.getByPosition(pos) then
		return true
	end
	return (pos.x >= 33800 and pos.x <= 34137 and pos.y >= 31653 and pos.y <= 31932 and (pos.z == 14 or pos.z == 15))
end

local function createElderBloodjawInstant(player, spawnPosition)
	local playerId = player:getId()

	if not taintCooldown[playerId] or os.time() > taintCooldown[playerId] then
		taintCooldown[playerId] = os.time() + 30
		local elderBloodjaw = Game.createMonster("elderbloodjaw", spawnPosition, true, true)
		if elderBloodjaw then
			logger.debug("Elder Bloodjaw spawned instantly for player {} at position {},{},{}", player:getName(), spawnPosition.x, spawnPosition.y, spawnPosition.z)
			return true
		else
			logger.warn("Failed to spawn Elder Bloodjaw for player {} at position {},{},{}", player:getName(), spawnPosition.x, spawnPosition.y, spawnPosition.z)
		end
	else
		logger.debug("Elder Bloodjaw spawn blocked by cooldown for player {}", player:getName())
	end
	return false
end

local function handlePositionSwap(monster, target, chance)
	local targetPlayer = target:getPlayer()
	if not targetPlayer then
		return
	end

	local hazardLevel = getPlayerHazardLevel(targetPlayer)

	if not isInBakragoreZone(targetPlayer) then
		return
	end

	local swapChance = 0
	if hazardLevel >= 1 and hazardLevel <= 4 then
		swapChance = 2
	elseif hazardLevel >= 5 then
		swapChance = 5
	end

	if swapChance > 0 and math.random(1, 100) <= swapChance then
		local playerId = targetPlayer:getId()
		if not positionSwapCooldown[playerId] or os.time() > positionSwapCooldown[playerId] then
			positionSwapCooldown[playerId] = os.time() + 60

			local playerPos = targetPlayer:getPosition()

			playerPos:sendMagicEffect(CONST_ME_MORTAREA)

			addEvent(function(monsterId, playerId)
				local eventMonster = Monster(monsterId)
				local eventPlayer = Player(playerId)
				if eventMonster and eventPlayer then
					if not isInBakragoreZone(eventPlayer) then
						logger.debug("Position swap cancelled: player {} is no longer in Rotten Blood zone", eventPlayer:getName())
						return
					end

					local monsterPosition = eventMonster:getPosition()
					local playerPosition = eventPlayer:getPosition()

					if monsterPosition.z ~= playerPosition.z then
						logger.debug("Position swap cancelled: player {} is on different floor (monster z: {}, player z: {})", eventPlayer:getName(), monsterPosition.z, playerPosition.z)
						return
					end

					local distance = monsterPosition:getDistance(playerPosition)
					if distance > 2 then
						logger.debug("Position swap cancelled: player {} is too far from monster (distance: {} sqm)", eventPlayer:getName(), distance)
						return
					end

					eventMonster:teleportTo(playerPosition, true)
					eventPlayer:teleportTo(monsterPosition, true)

					playerPosition:sendMagicEffect(CONST_ME_TELEPORT)
					monsterPosition:sendMagicEffect(CONST_ME_TELEPORT)

					logger.debug("Position swap executed: player {} and monster {} swapped positions", eventPlayer:getName(), eventMonster:getName())
				end
			end, 2000, monster:getId(), targetPlayer:getId())
		end
	end
end

local function onPlayerKillMonster(player, target)
	local monster = target:getMonster()
	if not monster then
		return
	end

	local hazardLevel = getPlayerHazardLevel(player)
	if not isInBakragoreZone(player) then
		return
	end

	local bakragoreMonsters = {
		"sopping corpus",
		"oozing corpus",
		"mycobiontic beetle",
		"bloated man-maggot",
		"walking pillar",
		"darklight matter",
		"darklight source",
		"darklight striker",
		"darklight emitter",
		"darklight construct",
		"wandering pillar",
		"converter",
		"oozing carcass",
		"sopping carcass",
		"rotten man-maggot",
		"meandering mushroom",
	}

	local monsterName = monster:getName():lower()
	if not table.contains(bakragoreMonsters, monsterName) then
		return
	end

	local spawnChance = 0
	if hazardLevel >= 6 then
		spawnChance = 9 -- 9% chance
	elseif hazardLevel >= 2 then
		spawnChance = 6 -- 6% chance
	end

	if spawnChance > 0 and math.random(1, 100) <= spawnChance then
		local spawnPosition = monster:getPosition()
		createElderBloodjawInstant(player, spawnPosition)
	end
end

local function applyRootEffect(monster, target)
	local targetPlayer = target:getPlayer()
	if not targetPlayer then
		return
	end

	local hazardLevel = getPlayerHazardLevel(targetPlayer)

	if not isInBakragoreZone(targetPlayer) then
		return
	end

	if hazardLevel >= 3 then
		local rootChance = hazardLevel >= 5 and 6 or 3
		if math.random(1, 100) <= rootChance then
			local playerId = targetPlayer:getId()
			if not rootCooldown[playerId] or os.time() > rootCooldown[playerId] then
				rootCooldown[playerId] = os.time() + 5

				local playerPos = targetPlayer:getPosition()
				playerPos:sendMagicEffect(CONST_ME_ROOTS)

				addEvent(function(pId)
					local eventPlayer = Player(pId)
					if eventPlayer then
						if not isInBakragoreZone(eventPlayer) then
							return
						end

						local condition = Condition(CONDITION_ROOTED)
					condition:setParameter(CONDITION_PARAM_TICKS, hazardLevel >= 5 and 4000 or 3000)
						eventPlayer:addCondition(condition)

						eventPlayer:getPosition():sendMagicEffect(CONST_ME_ROOTS)
					end
				end, 500, playerId)
			end
		end
	end
end

local function applyAdditionalElement(monster, target)
	local player = target:getPlayer()
	if not player then
		return
	end

	local taintLevel = getPlayerHazardLevel(player)
	if taintLevel < 3 or not isInBakragoreZone(player) then
		return
	end

	local damageType, effect = getTaintElement(player:getPosition())
	if not damageType then
		return
	end

	local playerId = player:getId()
	if elementalCooldown[playerId] and elementalCooldown[playerId] > os.time() then
		return
	end

	local chance = taintLevel >= 5 and 12 or 6
	if math.random(1, 100) > chance then
		return
	end

	elementalCooldown[playerId] = os.time() + 2
	local multiplier = taintLevel >= 5 and 0.08 or 0.05
	local damage = math.max(15, math.ceil(player:getMaxHealth() * multiplier))
	doTargetCombatHealth(monster, player, damageType, -damage, -damage, effect)
end

local function onMonsterAttackPlayer(target, primaryValue, secondaryValue)
	local targetPlayer = target:getPlayer()
	if not targetPlayer then
		return primaryValue, secondaryValue
	end

	local hazardLevel = getPlayerHazardLevel(targetPlayer)
	if not isInBakragoreZone(targetPlayer) then
		return primaryValue, secondaryValue
	end

	local damageIncrease = 0

	if hazardLevel >= 5 then
		damageIncrease = 21 -- Final Taint strengthens the official 14% penalty.
	elseif hazardLevel >= 4 then
		damageIncrease = 14
	end

	if damageIncrease > 0 then
		primaryValue = primaryValue + math.ceil(primaryValue * damageIncrease / 100)
		secondaryValue = secondaryValue + math.ceil(secondaryValue * damageIncrease / 100)
	end

	return primaryValue, secondaryValue
end

local callback = EventCallback("CreatureOnCombatRottenBlood")

function callback.creatureOnCombat(caster, target, primaryValue, primaryType, secondaryValue, secondaryType, origin)
	if not caster or not target then
		return primaryValue, primaryType, secondaryValue, secondaryType
	end

	if caster:getMonster() and target:getPlayer() then
		local difficulty = caster:getStorageValue("RottenBloodBossDifficulty")
		if difficulty == 0 then
			-- Difficulty 0 is the safe training mode.
			primaryValue = math.floor(primaryValue * 0.30)
			secondaryValue = math.floor(secondaryValue * 0.30)
		elseif difficulty and difficulty > 1 then
			local multiplier = 1 + (difficulty - 1) * 0.08
			primaryValue = math.floor(primaryValue * multiplier)
			secondaryValue = math.floor(secondaryValue * multiplier)
		end

		handlePositionSwap(caster, target, 0)

		applyRootEffect(caster, target)
		applyAdditionalElement(caster, target)

		primaryValue, secondaryValue = onMonsterAttackPlayer(target, primaryValue, secondaryValue)
	end

	return primaryValue, primaryType, secondaryValue, secondaryType
end

callback:register()

local deathCallback = CreatureEvent("RottenBloodMonsterDeath")

function deathCallback.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	if not creature or creature:isPlayer() or creature:getMaster() then
		return true
	end

	local killerPlayer = nil
	if killer and killer:isPlayer() then
		killerPlayer = killer
	elseif mostDamageKiller and mostDamageKiller:isPlayer() then
		killerPlayer = mostDamageKiller
	end

	if killerPlayer then
		onPlayerKillMonster(killerPlayer, creature)
	end

	return true
end

deathCallback:register()
