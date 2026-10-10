-- Charred Skull: final interaction after the Fatal Bug encounter.

local skullPosition = Position(32702, 31594, 7)
local charredSkull = Action()

function charredSkull.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local progress = player:kv():scoped("first-dragon-champions")
	if not progress:get("fatal-bug-defeated") then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The Charred Skull remains silent. Defeat the Fatal Bug first.")
		return true
	end

	if progress:get("charred-skull-used") then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have already completed this stage of The First Dragon.")
		return true
	end

	progress:set("charred-skull-used", true)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The Charred Skull acknowledges your victory. The First Dragon stage has been completed.")
	skullPosition:sendMagicEffect(CONST_ME_HOLYDAMAGE)
	return true
end

charredSkull:position(skullPosition)
charredSkull:register()

-- The official Charred Skull (introduced in 15.20) is not defined by this
-- datapack yet. Place an existing skull after the map has loaded, so it is
-- always visible at the quest position.
local skullSpawner = GlobalEvent("FirstDragonCharredSkullSpawner")

function skullSpawner.onStartup()
	local tile = Tile(skullPosition)
	if tile and not tile:getItemById(7558) then
		Game.createItem(7558, 1, skullPosition)
	end
	return true
end

skullSpawner:register()
