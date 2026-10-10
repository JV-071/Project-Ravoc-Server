-- Temporary GOD command to test the quest cosmetics before the full quests
-- award them naturally.
local summerRewards = TalkAction("/summer1530rewards")

function summerRewards.onSay(player, words, param)
	if param:trim():lower() ~= "grant" then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Usage: /summer1530rewards grant")
		return false
	end

	-- Illuminated Warrior (female/male), including all three quest addons.
	for _, lookType in ipairs({ 1973, 1974 }) do
		player:addOutfit(lookType)
		player:addOutfitAddon(lookType, 1)
		player:addOutfitAddon(lookType, 2)
		player:addOutfitAddon(lookType, 3)
	end

	-- IDs already registered in data/XML/mounts.xml.
	player:addMount(250) -- Jaracal
	player:addMount(251) -- Radiant Nimbus

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Summer 15.30 test rewards added: Illuminated Warrior, Jaracal and Radiant Nimbus.")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	return false
end

summerRewards:separator(" ")
summerRewards:groupType("god")
summerRewards:register()
