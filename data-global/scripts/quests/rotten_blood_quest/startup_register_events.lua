local rottenBloodStartup = GlobalEvent("RottenBloodStartup")

function rottenBloodStartup.onStartup()
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

	for _, monsterName in ipairs(bakragoreMonsters) do
		local mType = MonsterType(monsterName)
		if mType then
			mType:registerEvent("RottenBloodMonsterDeath")
			logger.debug("Registered RottenBloodMonsterDeath event for monster: {}", monsterName)
		else
			logger.error("Monster type not found: {}", monsterName)
		end
	end

	for _, bossName in ipairs({ "Murcion", "Ichgahal", "Chagorz", "Vemiath", "Bakragore" }) do
		local mType = MonsterType(bossName)
		if mType then
			if bossName ~= "Bakragore" then
				mType:registerEvent("RottenBloodTaintReward")
			end
		else
			logger.error("Rotten Blood boss type not found: {}", bossName)
		end
	end

	logger.info("Rotten Blood events registered successfully for {} monsters", #bakragoreMonsters)
	return true
end

rottenBloodStartup:register()
