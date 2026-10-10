-- Generic outgoing damage scaling for bosses created through BossLever.
-- Rotten Blood keeps its quest-specific callback to avoid applying the bonus twice.
local callback = EventCallback("CreatureOnCombatBossLeverDifficulty")

function callback.creatureOnCombat(caster, target, primaryValue, primaryType, secondaryValue, secondaryType, origin)
	if not caster or not target or not caster:getMonster() or not target:getPlayer() then
		return primaryValue, primaryType, secondaryValue, secondaryType
	end

	if caster:getStorageValue("RottenBloodBossDifficulty") ~= nil then
		return primaryValue, primaryType, secondaryValue, secondaryType
	end

	local difficulty = caster:getStorageValue("BossLeverDifficulty")
	if difficulty == nil then
		return primaryValue, primaryType, secondaryValue, secondaryType
	end

	if difficulty == 0 then
		primaryValue = math.floor(primaryValue * 0.30)
		secondaryValue = math.floor(secondaryValue * 0.30)
	elseif difficulty > 1 then
		local multiplier = 1 + (difficulty - 1) * 0.08
		primaryValue = math.floor(primaryValue * multiplier)
		secondaryValue = math.floor(secondaryValue * multiplier)
	end

	return primaryValue, primaryType, secondaryValue, secondaryType
end

callback:register()
