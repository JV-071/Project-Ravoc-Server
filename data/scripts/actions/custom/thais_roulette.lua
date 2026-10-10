local config = {
	leverPosition = Position(32240, 32494, 7),
	requiredItemId = 61608, -- Tigrinho token / roulette coin appearance (client 15.30)
	winningIndex = 5,
	positions = {
		Position(32234, 32492, 7),
		Position(32235, 32492, 7),
		Position(32236, 32492, 7),
		Position(32237, 32492, 7),
		Position(32238, 32492, 7),
		Position(32239, 32492, 7),
		Position(32240, 32492, 7),
		Position(32241, 32492, 7),
		Position(32242, 32492, 7),
		Position(32243, 32492, 7),
		Position(32244, 32492, 7),
		Position(32245, 32492, 7),
	},
	rewards = {
		{ id = 3587, min = 10, max = 30, weight = 500 },
		{ id = 22118, min = 10, max = 50, weight = 400 },
		{ id = 3043, min = 1, max = 5, weight = 300 },
		{ id = 6529, min = 1, max = 1, weight = 200 },
		{ id = 3363, min = 1, max = 1, weight = 150 },
		{ id = 3423, min = 1, max = 1, weight = 100 },
		{ id = 44602, min = 1, max = 1, weight = 20 },
		{ id = 44605, min = 1, max = 1, weight = 20 },
		{ id = 44608, min = 1, max = 1, weight = 20 },
		{ id = 44611, min = 1, max = 1, weight = 20 },
		{ id = 36729, min = 1, max = 1, weight = 15 },
		{ id = 36730, min = 1, max = 1, weight = 15 },
		{ id = 36731, min = 1, max = 1, weight = 15 },
		{ id = 36732, min = 1, max = 1, weight = 15 },
		{ id = 36733, min = 1, max = 1, weight = 15 },
		{ id = 36734, min = 1, max = 1, weight = 15 },
		{ id = 36735, min = 1, max = 1, weight = 15 },
		{ id = 51275, min = 1, max = 1, weight = 10 },
		{ id = 44603, min = 1, max = 1, weight = 5, rare = true },
		{ id = 44606, min = 1, max = 1, weight = 5, rare = true },
		{ id = 44609, min = 1, max = 1, weight = 5, rare = true },
		{ id = 44612, min = 1, max = 1, weight = 5, rare = true },
		{ id = 51588, min = 1, max = 1, weight = 5, rare = true },
		{ id = 36723, min = 1, max = 1, weight = 5, rare = true },
		{ id = 36724, min = 1, max = 1, weight = 5, rare = true },
		{ id = 36725, min = 1, max = 1, weight = 5, rare = true },
		{ id = 51462, min = 1, max = 1, weight = 3, rare = true },
		{ id = 51464, min = 1, max = 1, weight = 3, rare = true },
		{ id = 51467, min = 1, max = 1, weight = 3, rare = true },
		{ id = 44604, min = 1, max = 1, weight = 1, rare = true },
		{ id = 44607, min = 1, max = 1, weight = 1, rare = true },
		{ id = 44610, min = 1, max = 1, weight = 1, rare = true },
		{ id = 44613, min = 1, max = 1, weight = 1, rare = true },
		{ id = 51589, min = 1, max = 1, weight = 1, rare = true },
		{ id = 37110, min = 1, max = 1, weight = 1, rare = true },
		{ id = 34254, min = 1, max = 1, weight = 0.5, rare = true },
		{ id = 34253, min = 1, max = 1, weight = 0.5, rare = true },
		{ id = 34157, min = 1, max = 1, weight = 0.5, rare = true },
		{ id = 30393, min = 1, max = 1, weight = 0.5, rare = true },
		{ id = 30398, min = 1, max = 1, weight = 0.5, rare = true },
		{ id = 28719, min = 1, max = 1, weight = 0.3, rare = true },
		{ id = 28720, min = 1, max = 1, weight = 0.3, rare = true },
		{ id = 39147, min = 1, max = 1, weight = 0.05, rare = true },
		{ id = 39148, min = 1, max = 1, weight = 0.05, rare = true },
		{ id = 39149, min = 1, max = 1, weight = 0.05, rare = true },
		{ id = 34082, min = 1, max = 1, weight = 0.05, rare = true },
		{ id = 34088, min = 1, max = 1, weight = 0.05, rare = true },
		{ id = 34097, min = 1, max = 1, weight = 0.05, rare = true },
		{ id = 43864, min = 1, max = 1, weight = 0.005, rare = true },
		{ id = 43865, min = 1, max = 1, weight = 0.001, rare = true },
		{ id = 43876, min = 1, max = 1, weight = 0.005, rare = true },
		{ id = 43877, min = 1, max = 1, weight = 0.005, rare = true },
		{ id = 43878, min = 1, max = 1, weight = 0.001, rare = true },
		{ id = 43881, min = 1, max = 1, weight = 0.005, rare = true },
		{ id = 43884, min = 1, max = 1, weight = 0.005, rare = true },
		{ id = 50157, min = 1, max = 1, weight = 0.005, rare = true },
		{ id = 50158, min = 1, max = 1, weight = 0.001, rare = true },
	},
}

local running = false
local displayedItems = {}

local function removeDisplayedItems()
	for _, displayItem in ipairs(displayedItems) do
		if displayItem and displayItem:isItem() then
			displayItem:remove()
		end
	end
	displayedItems = {}
end

local function randomReward()
	local total = 0
	for _, reward in ipairs(config.rewards) do
		total = total + reward.weight
	end

	local roll = math.random() * total
	for _, reward in ipairs(config.rewards) do
		roll = roll - reward.weight
		if roll <= 0 then
			return reward
		end
	end
	return config.rewards[#config.rewards]
end

local function drawRow()
	removeDisplayedItems()
	for index, position in ipairs(config.positions) do
		local reward = randomReward()
		local displayItem = Game.createItem(reward.id, 1, position)
		if displayItem then
			displayedItems[index] = displayItem
			position:sendMagicEffect(CONST_ME_MAGIC_BLUE)
		end
	end
end

local function finishRoulette(playerId)
	local player = Player(playerId)
	if not player then
		removeDisplayedItems()
		running = false
		return
	end

	local reward = randomReward()
	local amount = math.random(reward.min, reward.max)
	local rewardItem = player:addItem(reward.id, amount)
	if not rewardItem then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "There is not enough room to receive the roulette prize.")
		removeDisplayedItems()
		running = false
		return
	end

	for index, position in ipairs(config.positions) do
		if displayedItems[index] and displayedItems[index]:isItem() then
			displayedItems[index]:transform(reward.id, 1)
		end
		position:sendMagicEffect(index == config.winningIndex and CONST_ME_FIREWORK_RED or CONST_ME_FIREWORK_YELLOW)
	end

	local itemName = ItemType(reward.id):getName()
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Congratulations! You won %dx %s.", amount, itemName))
	if reward.rare then
		Game.broadcastMessage(string.format("%s won a roulette prize: %dx %s!", player:getName(), amount, itemName), MESSAGE_EVENT_ADVANCE)
	end

	addEvent(function()
		removeDisplayedItems()
		running = false
	end, 3000)
end

local roulette = Action()

function roulette.onUse(player, item, fromPosition)
	if running then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The roulette is already running. Please wait.")
		return true
	end

	if fromPosition ~= config.leverPosition then
		return false
	end

	if not player:removeItem(config.requiredItemId, 1) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need a Tigrinho token to use the roulette.")
		return true
	end

	running = true
	removeDisplayedItems()
	for step = 1, 12 do
		addEvent(drawRow, step * (100 + step * 35))
	end
	addEvent(finishRoulette, 12 * (100 + 12 * 35) + 700, player:getId())
	return true
end

roulette:position(config.leverPosition)
roulette:register()
