local onBossDeath = CreatureEvent("BossLeverOnDeath")

function onBossDeath.onDeath(creature)
	if not creature then
		return true
	end

	local name = creature:getName()
	local key = "boss." .. toKey(name)
	local zone = Zone(key)

	if not zone then
		return true
	end

	local bossLever = BossLever[name:lower()]
	if not bossLever then
		return true
	end

	local attempt = bossLever.activeAttempt
	if not attempt or (attempt.bossId and attempt.bossId ~= creature:getId()) then
		return true
	end

	if attempt.timeoutEvent then
		stopEvent(attempt.timeoutEvent)
		attempt.timeoutEvent = nil
		bossLever.timeoutEvent = nil
	end

	if bossLever.timeAfterKill > 0 then
		zone:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The " .. name .. " has been defeated. You have " .. bossLever.timeAfterKill .. " seconds to leave the room.")
		attempt.timeoutEvent = addEvent(function(zn, lever, attemptId)
			if not lever.activeAttempt or lever.activeAttempt.id ~= attemptId then
				return
			end
			zn:refresh()
			zn:removePlayers()
			zn:removeMonsters()
			lever.activeAttempt = nil
			lever.timeoutEvent = nil
		end, bossLever.timeAfterKill * 1000, zone, bossLever, attempt.id)
		bossLever.timeoutEvent = attempt.timeoutEvent
	else
		bossLever.activeAttempt = nil
		bossLever.timeoutEvent = nil
	end
	onDeathForDamagingPlayers(creature, function(creature, player)
		player:sendBannerType(BANNER_TYPE_BOSSDEFEATED)
	end)
	return true
end

onBossDeath:register()
