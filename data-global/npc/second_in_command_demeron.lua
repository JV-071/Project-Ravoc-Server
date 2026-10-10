local internalNpcName = "Second in Command Demeron"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = { name = internalNpcName, description = internalNpcName, health = 100, maxHealth = 100, walkInterval = 2000, walkRadius = 2,
	outfit = { lookType = 131, lookHead = 78, lookBody = 76, lookLegs = 94, lookFeet = 116, lookAddons = 2 }, flags = { floorchange = false } }
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
	if MsgContains(message, "mission") or MsgContains(message, "tell") or MsgContains(message, "certificate") then
		if quest ~= 3 then
			npcHandler:say("I cannot discuss the Order's affairs with you.", npc, creature)
			return true
		end
		if player:getItemCount(52586) < 1 then
			npcHandler:say("Kesar would have given you proof. Bring me the ice-covered certificate of ancestry.", npc, creature)
			return true
		end
		npcHandler:say("A certificate of ancestry... This is serious. Do you swear Kesar sent you to find Eldoran and aid the Order of the Stag?", npc, creature)
		npcHandler:setTopic(id, 1)
		return true
	end
	if MsgContains(message, "yes") and npcHandler:getTopic(id) == 1 then
		player:removeItem(52586, 1)
		player:setStorageValue(stag.Questline, 4)
		npcHandler:say("Then cross the mines, reach the bastion and find Guard Captain Hartford. The Order is surrounded and every moment matters.", npc, creature)
		npcHandler:setTopic(id, 0)
		return true
	end
	return false
end

npcHandler:setMessage(MESSAGE_GREET, "If you don't carry any spares, state your {mission} quickly or move along.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Move along.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)
npcType:register(npcConfig)
