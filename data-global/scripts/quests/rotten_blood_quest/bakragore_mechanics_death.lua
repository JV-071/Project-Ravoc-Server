if not GlobalRottenBloodStates then
	GlobalRottenBloodStates = {}
end

local function cleanupBakragore()
	if GlobalRottenBloodStates["Bakragore"] then
		if GlobalRottenBloodStates["Bakragore"].teleportTimer then
			stopEvent(GlobalRottenBloodStates["Bakragore"].teleportTimer)
		end
		GlobalRottenBloodStates["Bakragore"] = nil
	end
end

local bakragoreDeath = CreatureEvent("BakragoreMechanicsDeath")

function bakragoreDeath.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	if not creature or creature:getName() ~= "Bakragore" then
		return true
	end

	if corpse then
		local essenceCount = creature:getStorageValue(88888) or 0
		local difficulty = math.max(1, creature:getStorageValue("RottenBloodBossDifficulty") or 1)

		-- Bakragore: from difficulty 25 onward, the Bag You Covet chance is
		-- 1.25%, then rises by 0.05 percentage point per further difficulty.
		-- The integer roll avoids rounding errors (1.25% = 1250 / 100000).
		local bagChance = difficulty >= 25 and (1.25 + (difficulty - 25) * 0.05) or 0
		local roll = math.random(1, 100000)
		if bagChance > 0 and roll <= math.floor(bagChance * 1000) then
			local bag = corpse:addItem(43895, 1)
			if bag and essenceCount > 0 then
				-- Only bags from a Burden fight can award a Grand Sanguine item.
				bag:setCustomAttribute("bakragore-burden-stage", essenceCount)
			end
			logger.info("[Bakragore] Bag You Covet dropped at difficulty {} ({}%, roll {}/100000, burden {}).", difficulty, bagChance, roll, essenceCount)
		else
			logger.info("[Bakragore] No Bag You Covet at difficulty {} ({}%, roll {}/100000).", difficulty, bagChance, roll)
		end
	end

	cleanupBakragore()

	Game.setStorageValue("BakragoreTeleportPaused", -1)
	Game.setStorageValue("BakragoreElderBloodjawSpawnPaused", -1)

	return true
end

bakragoreDeath:register()
