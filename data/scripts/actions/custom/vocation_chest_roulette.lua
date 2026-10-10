local config = {
	leverPosition = Position(32212, 32501, 7),
	requiredItemId = 61608, -- Tigrinho token / roulette coin appearance (client 15.30)
	winningIndex = 5,
	positions = {
		Position(32210, 32500, 7),
		Position(32210, 32501, 7),
		Position(32210, 32502, 7),
		Position(32209, 32500, 7),
		Position(32209, 32501, 7),
		Position(32209, 32502, 7),
		Position(32208, 32500, 7),
		Position(32208, 32501, 7),
		Position(32208, 32502, 7),
	},
	rewards = {
		{ id = 3043, min = 10, max = 100, weight = 500 }, -- crystal coins
		{ id = 28486, min = 1, max = 1, weight = 80 }, -- lemon cupcake
		{ id = 28485, min = 1, max = 1, weight = 80 }, -- strawberry cupcake
		{ id = 28484, min = 1, max = 1, weight = 80 }, -- blueberry cupcake
		{ id = 36730, min = 1, max = 1, weight = 25 }, -- ice resilience
		{ id = 36732, min = 1, max = 1, weight = 25 }, -- energy resilience
		{ id = 36735, min = 1, max = 1, weight = 25 }, -- physical resilience
		{ id = 36731, min = 1, max = 1, weight = 25 }, -- earth resilience
		{ id = 36729, min = 1, max = 1, weight = 25 }, -- fire resilience
		{ id = 36734, min = 1, max = 1, weight = 25 }, -- death resilience
		{ id = 36733, min = 1, max = 1, weight = 25 }, -- holy resilience
		{ id = 61721, min = 1, max = 1, weight = 1, rare = true }, -- knight's chest
		{ id = 61722, min = 1, max = 1, weight = 1, rare = true }, -- paladin's chest
		{ id = 61720, min = 1, max = 1, weight = 1, rare = true }, -- druid's chest
		{ id = 61719, min = 1, max = 1, weight = 1, rare = true }, -- sorcerer's chest
	},
}

local running = false
local displayedItems = {}

local function clearDisplay()
	for _, displayItem in ipairs(displayedItems) do
		if displayItem and displayItem:isItem() then
			displayItem:remove()
		end
	end
	displayedItems = {}
end

local function randomReward()
	local totalWeight = 0
	for _, reward in ipairs(config.rewards) do
		totalWeight = totalWeight + reward.weight
	end

	local roll = math.random() * totalWeight
	for _, reward in ipairs(config.rewards) do
		roll = roll - reward.weight
		if roll <= 0 then
			return reward
		end
	end
	return config.rewards[#config.rewards]
end

local function drawGrid()
	clearDisplay()
	for index, position in ipairs(config.positions) do
		local reward = randomReward()
		local displayItem = Game.createItem(reward.id, 1, position)
		if displayItem then
			displayedItems[index] = displayItem
			position:sendMagicEffect(CONST_ME_MAGIC_BLUE)
		end
	end
end

local winningLines = {
	{ 1, 4, 7 }, -- top row
	{ 2, 5, 8 }, -- middle row
	{ 3, 6, 9 }, -- bottom row
	{ 1, 2, 3 }, -- right column
	{ 4, 5, 6 }, -- middle column
	{ 7, 8, 9 }, -- left column
	{ 1, 5, 9 }, -- diagonal
	{ 3, 5, 7 }, -- diagonal
}

local function finishRoulette(playerId)
	local player = Player(playerId)
	if not player then
		clearDisplay()
		running = false
		return
	end

	-- Build the final grid without replacing every slot by the same item.
	clearDisplay()
	local finalRewards = {}
	for index, position in ipairs(config.positions) do
		local reward = randomReward()
		finalRewards[index] = reward
		local displayItem = Game.createItem(reward.id, 1, position)
		if displayItem then
			displayedItems[index] = displayItem
		end
	end

	local winningReward = nil
	local winningLine = nil
	for _, line in ipairs(winningLines) do
		local first = finalRewards[line[1]]
		local second = finalRewards[line[2]]
		local third = finalRewards[line[3]]
		if first and second and third and first.id == second.id and first.id == third.id then
			winningReward = first
			winningLine = line
			break
		end
	end

	if winningReward then
		local amount = math.random(winningReward.min, winningReward.max)
		local receivedItem = player:addItem(winningReward.id, amount)
		if not receivedItem then
			player:addItem(config.requiredItemId, 1)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "There is not enough room for the prize. Your roulette coin was returned.")
		else
			local itemName = ItemType(winningReward.id):getName()
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Three matching symbols! You won %dx %s.", amount, itemName))
			if winningReward.rare then
				Game.broadcastMessage(string.format("%s won a rare vocation chest from the roulette: %s!", player:getName(), itemName), MESSAGE_EVENT_ADVANCE)
			end
		end

		local winningIndexes = {}
		for _, index in ipairs(winningLine) do
			winningIndexes[index] = true
		end
		for index, position in ipairs(config.positions) do
			position:sendMagicEffect(winningIndexes[index] and CONST_ME_FIREWORK_RED or CONST_ME_FIREWORK_YELLOW)
		end
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "No sequence of three matching symbols. You won nothing.")
		for _, position in ipairs(config.positions) do
			position:sendMagicEffect(CONST_ME_POFF)
		end
	end

	addEvent(function()
		-- Keep the final result visible. The next lever use clears the grid
		-- immediately before starting the new animation.
		running = false
	end, 3000)
end

local roulette = Action()

function roulette.onUse(player, item, fromPosition)
	if running then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The vocation roulette is already running. Please wait.")
		return true
	end

	if fromPosition ~= config.leverPosition then
		return false
	end

	if not player:removeItem(config.requiredItemId, 1) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need a roulette coin to use this roulette.")
		return true
	end

	running = true
	clearDisplay()
	for step = 1, 12 do
		addEvent(drawGrid, step * (100 + step * 35))
	end
	addEvent(finishRoulette, 12 * (100 + 12 * 35) + 700, player:getId())
	return true
end

roulette:position(config.leverPosition)
roulette:register()
