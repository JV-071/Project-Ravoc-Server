-- Offline difficulty selector for the five Rotten Blood bosses.
-- Set it before pulling the boss lever.

local setDifficulty = TalkAction("/rbdifficulty")

function setDifficulty.onSay(player, words, param)
	local difficulty = tonumber(param)
	if not difficulty or difficulty < 0 or difficulty > 25 or difficulty % 1 ~= 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Usage: /rbdifficulty 0-25")
		return false
	end

	Game.setStorageValue("RottenBloodBossDifficulty", difficulty)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Rotten Blood boss difficulty set to %d. Pull a boss lever now.", difficulty))
	return false
end

setDifficulty:separator(" ")
setDifficulty:groupType("god")
setDifficulty:register()
