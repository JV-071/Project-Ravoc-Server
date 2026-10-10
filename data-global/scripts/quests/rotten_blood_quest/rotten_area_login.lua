local rottenTaintGain = CreatureEvent("RottenTaintGain")

function rottenTaintGain.onLogin(player)
	if not player or not player:isPlayer() then
		return true
	end

	player:removeIcon("rotten-hazard")
	local areaKv = player:kv():scoped("rotten-blood-area-icons")
	local jadedProgress = areaKv:get("jaded-roots-progress") or 0
	if jadedProgress > 0 then
		player:setIcon("rotten-area", CreatureIconCategory_Quests, CreatureIconQuests_ArrowUp, jadedProgress)
	else
		player:removeIcon("rotten-area")
	end
	player:removeIcon("white-cross")

	logger.debug("Player Login: Cleaned up all rotten blood icons from player {}", player:getName())

	addEvent(function()
		if player and player:isPlayer() then
			if updateRottenHazardIcon then
				updateRottenHazardIcon(player)
			end
		end
	end, 2000)

	return true
end

rottenTaintGain:register()
