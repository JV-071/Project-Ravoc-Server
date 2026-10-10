local internalNpcName = "Eldoran the Ambitious"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = { name = internalNpcName, description = internalNpcName, health = 100, maxHealth = 100, walkInterval = 2000, walkRadius = 2,
	outfit = { lookType = 133, lookHead = 95, lookBody = 19, lookLegs = 19, lookFeet = 95, lookAddons = 2 }, flags = { floorchange = false } }
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local stag = Storage.Quest.U15_20.TheOrderOfTheStag

npcType.onThink = function(npc, interval) npcHandler:onThink(npc, interval) end
npcType.onAppear = function(npc, creature) npcHandler:onAppear(npc, creature) end
npcType.onDisappear = function(npc, creature) npcHandler:onDisappear(npc, creature) end
npcType.onMove = function(npc, creature, fromPosition, toPosition) npcHandler:onMove(npc, creature, fromPosition, toPosition) end
npcType.onSay = function(npc, creature, type, message) npcHandler:onSay(npc, creature, type, message) end
npcType.onCloseChannel = function(npc, creature) npcHandler:onCloseChannel(npc, creature) end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local id = player:getId()
	local quest = player:getStorageValue(stag.Questline)
	if MsgContains(message, "word") and quest == 6 then
		npcHandler:say("Kesar sent you and you know my true heritage? Are you truly willing to aid the Order of the Stag?", npc, creature)
		npcHandler:setTopic(id, 1)
		return true
	end
	if MsgContains(message, "yes") and npcHandler:getTopic(id) == 1 then
		player:setStorageValue(stag.Questline, 7)
		npcHandler:say("Burn the putrid, poisonous and vile corpse piles in the lower dungeons, then return with news.", npc, creature)
		npcHandler:setTopic(id, 0)
		return true
	end
	if MsgContains(message, "news") or MsgContains(message, "corpses") then
		if quest == 8 then
			player:setStorageValue(stag.Questline, 9)
			npcHandler:say("Most excellent. The lower ward and silver mines are open. Reach the warlock's tower and defeat the Court Warlock.", npc, creature)
			return true
		elseif quest == 10 then
			player:setStorageValue(stag.Questline, 11)
			player:addItem(52824, 1)
			player:addAchievement("Bastard")
			npcHandler:say("Outstanding! Take the broken sword of my forefather. I name you an honourable member of the Order of the Stag. Return to Kesar.", npc, creature)
			return true
		end
	end
	return false
end

npcHandler:setMessage(MESSAGE_GREET, "Someone made it! Do you bring {word} from my men in the outskirts?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Until we meet again.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)
npcType:register(npcConfig)
