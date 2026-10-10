local internalNpcName = "Guard Captain Hartford"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = { name = internalNpcName, description = internalNpcName, health = 100, maxHealth = 100, walkInterval = 2000, walkRadius = 2,
	outfit = { lookType = 131, lookHead = 78, lookBody = 52, lookLegs = 94, lookFeet = 116, lookAddons = 3 }, flags = { floorchange = false } }
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
	if MsgContains(message, "business") or MsgContains(message, "explain") then
		if quest ~= 4 then
			npcHandler:say("The bastion is under siege. Outsiders have no business here.", npc, creature)
			return true
		end
		npcHandler:say("Kesar sent you? We are pinned down by cursed puppets and night harpies. Will you bring me proof of twenty dead harpies?", npc, creature)
		npcHandler:setTopic(id, 1)
		return true
	end
	if MsgContains(message, "yes") and npcHandler:getTopic(id) == 1 then
		player:setStorageValue(stag.Questline, 5)
		player:setStorageValue(stag.HarpyBeaks, 0)
		npcHandler:say("Use an obsidian knife on fresh night harpy corpses and bring me twenty beaks.", npc, creature)
		npcHandler:setTopic(id, 0)
		return true
	end
	if MsgContains(message, "harpies") or MsgContains(message, "beaks") or MsgContains(message, "news") then
		if quest ~= 5 then return false end
		local count = math.max(player:getStorageValue(stag.HarpyBeaks), 0)
		if count < 20 or player:getItemCount(52632) < 20 then
			npcHandler:say(string.format("You have proven the death of %d of 20 night harpies.", count), npc, creature)
			return true
		end
		player:removeItem(52632, 20)
		player:setStorageValue(stag.Questline, 6)
		npcHandler:say("Good work. You have earned access to the upper hall. Find Eldoran and tell him you bring word from the outskirts.", npc, creature)
		return true
	end
	return false
end

npcHandler:setMessage(MESSAGE_GREET, "HALT! Outsider, state your {business}!")
npcHandler:setMessage(MESSAGE_FAREWELL, "Stay vigilant.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)
npcType:register(npcConfig)
