local internalNpcName = "Golden Buyer"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = "the golden buyer"

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 1

npcConfig.outfit = {
	lookType = 1210,
	lookHead = 79,
	lookBody = 79,
	lookLegs = 79,
	lookFeet = 79,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- LootShopConfig is generated from every item that has a configured sell price.
npcConfig.shop = LootShopConfig

local function creatureSayCallback(npc, player, type, message)
	if not npcHandler:checkInteraction(npc, player) then
		return false
	end

	local normalizedMessage = message:lower()
	local categoryTable = LootShopConfigTable[normalizedMessage]
	if MsgContains(message, "shop options") or MsgContains(message, "categorias") then
		npcHandler:say("Eu compro itens das categorias: " .. GetFormattedShopCategoryNames(LootShopConfigTable) .. ".", npc, player)
	elseif categoryTable then
		local remainingCategories = npc:getRemainingShopCategories(normalizedMessage, LootShopConfigTable)
		npcHandler:say("Claro. Voce tambem pode consultar " .. remainingCategories .. ".", npc, player)
		npc:openShopWindowTable(player, categoryTable)
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, "Bem-vindo, |PLAYERNAME|! Eu compro todos os itens que possuem valor de venda. Diga {trade}.")
npcHandler:setMessage(MESSAGE_SENDTRADE, "Aqui estao todos os itens que eu compro. Voce tambem pode filtrar pelas categorias.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Volte quando tiver mais itens para vender.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Ate a proxima.")

npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end

npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Voce vendeu %ix %s por %i gold.", amount, name, totalCost))
end

npcType.onCheckItem = function(npc, player, clientId, subType)
end

npcType:addDialogOptions("trade", "bye")

npcType:register(npcConfig)
