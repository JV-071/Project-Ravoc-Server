local essenciasID = {
	[43501] = { str = 52280 }, -- essence of Murcion
	[43502] = { str = 52281 }, -- essence of Ichgahal
	[43503] = { str = 52283 }, -- essence of Vemiath
	[43504] = { str = 52282 }, -- essence of Chagorz
}

local pillarID = 43507
local flamesID

local essencesRottenBlood = Action("essencesRottenBlood")

function essencesRottenBlood.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local info = essenciasID[item:getId()]
	if not info then
		return true
	end

	local burden = flamesID[info.str]
	if not burden then
		return true
	end

	-- The sacrifice flames are blocking map objects. The player uses the
	-- essence from an adjacent tile onto the corresponding flame.
	local targetPosition = target and target:getPosition() or toPosition
	if not targetPosition
		or targetPosition.x ~= burden.flamePos.x
		or targetPosition.y ~= burden.flamePos.y
		or targetPosition.z ~= burden.flamePos.z
	then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Use the essence on the correct sacrifice flame for " .. burden.name .. ".")
		return true
	end

	if Game.getStorageValue(burden.globalstr) > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The essence of " .. burden.name .. " has already been sacrificed for this fight.")
		return true
	end

	local flameTile = Tile(burden.flamePos)
	local pillarTile = Tile(burden.pillarPos)
	local flameItem = flameTile and flameTile:getItemById(burden.flameID)
	local pillarItem = pillarTile and pillarTile:getItemById(pillarID)
	if not flameItem or not pillarItem then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The Burden altar is not ready. Please contact an administrator.")
		logger.error("[BakragoreBurden] Missing flame {} or pillar {} for {}.", burden.flameID, pillarID, burden.name)
		return true
	end

	flameItem:transform(burden.transformflameID)
	pillarItem:transform(pillarID + 1)
	Game.setStorageValue(burden.globalstr, 1)
	item:remove(1)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You sacrifice the essence of " .. burden.name .. "! The corresponding Burden pillar has been activated.")
	return true
end

essencesRottenBlood:id(43501, 43502, 43503, 43504)
essencesRottenBlood:register()

flamesID = {
	[52280] = {
		globalstr = "essenceOfMurcion",
		name = "Murcion",
		essenceId = 43501,
		flameID = 43983,
		transformflameID = 43984,
		flamePos = Position(33085, 32398, 15),
		pillarPos = Position(33081, 32398, 15),
	},
	[52281] = {
		globalstr = "essenceOfIchgahal",
		name = "Ichgahal",
		essenceId = 43502,
		flameID = 43497,
		transformflameID = 43498,
		flamePos = Position(33076, 32389, 15),
		pillarPos = Position(33076, 32395, 15),
	},
	[52282] = {
		globalstr = "essenceOfChagorz",
		name = "Chagorz",
		essenceId = 43504,
		flameID = 43987,
		transformflameID = 43988,
		flamePos = Position(33067, 32398, 15),
		pillarPos = Position(33071, 32398, 15),
	},
	[52283] = {
		globalstr = "essenceOfVemiath",
		name = "Vemiath",
		essenceId = 43503,
		flameID = 43985,
		transformflameID = 43986,
		flamePos = Position(33076, 32407, 15),
		pillarPos = Position(33076, 32401, 15),
	},
}

local sacrificeFlame = Action("BakragoreBurdenSacrificeFlame")

function sacrificeFlame.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local info
	for _, candidate in pairs(flamesID) do
		if candidate.flameID == item:getId() then
			info = candidate
			break
		end
	end
	if not info then
		return true
	end

	local position = item:getPosition()
	if position.x ~= info.flamePos.x or position.y ~= info.flamePos.y or position.z ~= info.flamePos.z then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "This is not a Bakragore's Burden sacrifice flame.")
		return true
	end
	if Game.getStorageValue(info.globalstr) > 0 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The essence of " .. info.name .. " has already been sacrificed for this fight.")
		return true
	end
	if player:getItemCount(info.essenceId) < 1 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need the essence of " .. info.name .. " to activate this pillar.")
		return true
	end

	local pillarTile = Tile(info.pillarPos)
	local pillarItem = pillarTile and pillarTile:getItemById(pillarID)
	if not pillarItem then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The Burden pillar is not ready. Please contact an administrator.")
		logger.error("[BakragoreBurden] Missing pillar {} for {}.", pillarID, info.name)
		return true
	end

	if not player:removeItem(info.essenceId, 1) then
		return true
	end
	item:transform(info.transformflameID)
	pillarItem:transform(pillarID + 1)
	Game.setStorageValue(info.globalstr, 1)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You sacrifice the essence of " .. info.name .. "! The corresponding Burden pillar has been activated.")
	return true
end

sacrificeFlame:id(43983, 43497, 43987, 43985)
sacrificeFlame:register()
