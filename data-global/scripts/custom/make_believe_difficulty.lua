-- Offline test control for the Make Believe bosses.
-- The selected difficulty applies to bosses created after this command.
local makeBelieveDifficulty = TalkAction("/mbdifficulty")

function makeBelieveDifficulty.onSay(player, words, param)
	local difficulty = tonumber(param)
	if not difficulty or difficulty < 0 or difficulty > 25 or difficulty % 1 ~= 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Usage: /mbdifficulty 0-25")
		return false
	end

	Game.setStorageValue("MakeBelieveDifficulty", difficulty)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Make Believe difficulty set to %d. Spawn Mimar Haffar or Maior Domus now.", difficulty))
	return false
end

makeBelieveDifficulty:separator(" ")
makeBelieveDifficulty:groupType("god")
makeBelieveDifficulty:register()
