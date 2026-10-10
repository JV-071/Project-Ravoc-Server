-- Crystal Battle Pass protocol for the OTClient module (extended JSON opcode 22).
-- Progress is stored in the player's key/value store and survives restarts.

local OPCODE = 22
local SCOPE = "battle-pass-season-4"

-- Summer Update 15.30 equipment, priced using RubinOT Season 4 shop tiers.
local SHOP_ITEMS = {
	{ id = 1, itemId = 53074, price = 800, name = "Adventurer Backpack" },
	{ id = 2, itemId = 53196, price = 700, name = "Flamingo Amulet of Destruction" },
	{ id = 3, itemId = 53197, price = 700, name = "Flamingo Amulet of Nature" },
	{ id = 4, itemId = 53198, price = 700, name = "Flamingo Amulet of Precision" },
	{ id = 5, itemId = 53199, price = 700, name = "Flamingo Amulet of Valor" },
	{ id = 6, itemId = 53200, price = 700, name = "Swan Amulet of Balance" },
	{ id = 7, itemId = 53201, price = 900, name = "Enchanted Flamingo Amulet of Destruction" },
	{ id = 8, itemId = 53202, price = 900, name = "Enchanted Flamingo Amulet of Nature" },
	{ id = 9, itemId = 53203, price = 900, name = "Enchanted Flamingo Amulet of Precision" },
	{ id = 10, itemId = 53204, price = 900, name = "Enchanted Flamingo Amulet of Valor" },
	{ id = 11, itemId = 53205, price = 900, name = "Enchanted Swan Amulet of Balance" },
	{ id = 12, itemId = 53207, price = 1200, name = "Moonsilver Epee" },
	{ id = 13, itemId = 53208, price = 1900, name = "Stellar Moonsilver Epee" },
	{ id = 14, itemId = 53209, price = 1200, name = "Moonsilver Claymore" },
	{ id = 15, itemId = 53210, price = 1900, name = "Stellar Moonsilver Claymore" },
	{ id = 16, itemId = 53211, price = 1200, name = "Moonsilver Axe" },
	{ id = 17, itemId = 53212, price = 1900, name = "Stellar Moonsilver Axe" },
	{ id = 18, itemId = 53213, price = 1200, name = "Moonsilver Chopper" },
	{ id = 19, itemId = 53214, price = 1900, name = "Stellar Moonsilver Chopper" },
	{ id = 20, itemId = 53215, price = 1200, name = "Moonsilver Crusher" },
	{ id = 21, itemId = 53216, price = 1900, name = "Stellar Moonsilver Crusher" },
	{ id = 22, itemId = 53219, price = 1200, name = "Moonsilver Channeler" },
	{ id = 23, itemId = 53220, price = 1900, name = "Stellar Moonsilver Channeler" },
	{ id = 24, itemId = 53223, price = 1200, name = "Moonsilver Katar" },
	{ id = 25, itemId = 53224, price = 1900, name = "Stellar Moonsilver Katar" },
	{ id = 26, itemId = 53225, price = 1200, name = "Moonsilver Bow" },
	{ id = 27, itemId = 53226, price = 1900, name = "Stellar Moonsilver Bow" },
	{ id = 28, itemId = 53227, price = 1200, name = "Moonsilver Crossbow" },
	{ id = 29, itemId = 53228, price = 1900, name = "Stellar Moonsilver Crossbow" },
	{ id = 30, itemId = 53229, price = 1200, name = "Moonsilver Battle Visor" },
	{ id = 31, itemId = 53230, price = 1200, name = "Moonsilver Trail Hood" },
	{ id = 32, itemId = 53231, price = 1200, name = "Moonsilver Nimbus Hat" },
	{ id = 33, itemId = 53232, price = 1200, name = "Moonsilver Spirit Mask" },
	{ id = 34, itemId = 53233, price = 1200, name = "Moonsilver Strike Helm" },
}

local function getShopItem(id)
	for _, item in ipairs(SHOP_ITEMS) do
		if item.id == id then return item end
	end
	return nil
end

local MISSION_VARIANTS = {
	[1] = {
		{ "Daily Hunter", "Kill 20 monsters today.", 20 },
		{ "Relentless Pursuit", "Kill 25 monsters today.", 25 },
		{ "Speed Test", "Kill 30 monsters before the daily reset.", 30 },
	},
	[2] = {
		{ "Deluxe Daily Hunter", "Kill 40 monsters today.", 40 },
		{ "Combined Strength", "Kill 50 monsters for the Deluxe daily mission.", 50 },
		{ "Bestiary Specialist", "Kill 60 monsters for the Deluxe daily mission.", 60 },
	},
	[101] = {
		{ "Bronze Hunter", "Kill 100 monsters during the season.", 100 },
		{ "Fugitive Hunter", "Kill 150 monsters during the season.", 150 },
		{ "Calculating Predator", "Kill 200 monsters during the season.", 200 },
	},
	[201] = {
		{ "Silver Hunter", "Kill 300 monsters during the season.", 300 },
		{ "Combined Strength", "Kill 400 monsters during the season.", 400 },
		{ "Master of Arms", "Kill 500 monsters during the season.", 500 },
	},
	[301] = {
		{ "Gold Hunter", "Kill 700 monsters during the season.", 700 },
		{ "Bane of Giants", "Kill 800 monsters during the season.", 800 },
		{ "Obsessed Target", "Kill 900 monsters during the season.", 900 },
	},
}

local function selectedMission(kv, missionId)
	local variants = MISSION_VARIANTS[missionId]
	local index = (kv:get("mission-variant-" .. missionId) or 0) + 1
	return variants[index] or variants[1]
end

local function sendShop(player)
	local kv = player:kv():scoped(SCOPE)
	local rows = {}
	for _, item in ipairs(SHOP_ITEMS) do
		table.insert(rows, string.format(
			'{"type":"item","id":%d,"itemId":%d,"price":%d,"name":"%s","description":"Summer Update 15.30 equipment. Sent to your Store Inbox."}',
			item.id, item.itemId, item.price, item.name
		))
	end
	local balance = kv:get("shop-points") or 0
	player:sendExtendedOpcode(OPCODE, string.format('{"action":"shop","shopItems":[%s],"shopPoints":%d}', table.concat(rows, ","), balance))
end

local function escape(value)
	return tostring(value):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")
end

local function missionJson(id, name, description, maximum, progress, points, premium)
	return string.format(
		'{"missionId":%d,"missionName":"%s","missionDescription":"%s","maxProgress":%d,"currentProgress":%d,"rewardPoints":%d,"isPremium":%s}',
		id, escape(name), escape(description), maximum, math.min(progress, maximum), points, premium and "true" or "false"
	)
end

local function requiredPoints(step)
	if step <= 50 then
		return step * 100
	end
	return 5000 + ((step - 50) * 120)
end

local function rewardFor(step, rewardType)
	if rewardType == "free" then
		if step % 4 ~= 0 then return nil end
		if step % 12 == 0 then
			return 61608, math.min(1 + math.floor(step / 24), 4), "Roulette Coins"
		end
		return 30316, math.min(1 + math.floor(step / 32), 3), "Mystic Bags"
	end
	if step % 5 == 0 then
		return 30316, math.min(1 + math.floor(step / 20), 5), "Mystic Bags"
	end
	if step % 3 == 0 then
		return 61608, math.min(1 + math.floor(step / 30), 3), "Roulette Coins"
	end
	return 30316, math.min(1 + math.floor(step / 40), 3), "Mystic Bags"
end

local function sendRewards(player)
	local kv = player:kv():scoped(SCOPE)
	local steps = {}
	for step = 1, 80 do
		local rewards = {}
		for _, rewardType in ipairs({ "premium", "free" }) do
			local itemId, count, label = rewardFor(step, rewardType)
			if itemId then
				local claimed = kv:get("claimed-" .. rewardType .. "-" .. step) and true or false
				table.insert(rewards, string.format(
					'{"freeReward":%s,"hasClamedReward":%s,"rewardName":"%d %s","itemId":%d,"count":%d}',
					rewardType == "free" and "true" or "false", claimed and "true" or "false", count, label, itemId, count
				))
			end
		end
		table.insert(steps, string.format('{"stepId":%d,"requiredPoints":%d,"rewards":[%s]}', step, requiredPoints(step), table.concat(rewards, ",")))
	end
	player:sendExtendedOpcode(OPCODE, '{"action":"rewards","rewardSteps":[' .. table.concat(steps, ",") .. ']}')
end

local function state(player)
	local kv = player:kv():scoped(SCOPE)
	-- One-time recovery for the progress lost during the development restart on
	-- 2026-08-22. The values come from the last confirmed client screenshot.
	if player:getName() == "Paladin Sample" and not kv:get("restart-recovery-20260822")
		and (kv:get("bronze-kills") or 0) == 0 and (kv:get("points") or 0) == 0 then
		kv:set("daily-kills", 20)
		kv:set("daily-premium-kills", 40)
		kv:set("bronze-kills", 41)
		kv:set("silver-kills", 41)
		kv:set("gold-kills", 41)
		kv:set("points", 90)
		kv:set("restart-recovery-20260822", true)
		player:save()
	end
	-- Requested test access: unlock the complete reward track for Paladin Sample.
	if player:getName() == "Paladin Sample" and not kv:get("level-80-test-20260822") then
		kv:set("points", 8600)
		kv:set("deluxe", true)
		kv:set("level-80-test-20260822", true)
		player:save()
	end
	if player:getName() == "Paladin Sample" and (kv:get("points") or 0) == 8000 and not kv:get("level-80-points-fix") then
		kv:set("points", 8600)
		kv:set("level-80-points-fix", true)
		player:save()
	end
	if player:getName() == "Paladin Sample" and not kv:get("shop-test-points-20260822") then
		kv:set("shop-points", 10000)
		kv:set("shop-test-points-20260822", true)
		player:save()
	end
	return kv, kv:get("daily-kills") or 0, kv:get("daily-premium-kills") or 0,
		kv:get("bronze-kills") or 0, kv:get("silver-kills") or 0, kv:get("gold-kills") or 0,
		kv:get("points") or 0
end

local function sendState(player)
	local kv, daily, dailyPremium, bronze, silver, gold, points = state(player)
	local deluxe = kv:get("deluxe") and true or false
	local now = os.time()
	local dayStart = now - (now % 86400)
	local step = 0
	for index = 80, 1, -1 do
		if points >= requiredPoints(index) then step = index break end
	end
	local stepBase = step > 0 and requiredPoints(step) or 0
	local nextStepPoints = step < 80 and (requiredPoints(step + 1) - stepBase) or 120
	local dailyFreeMission = selectedMission(kv, 1)
	local dailyDeluxeMission = selectedMission(kv, 2)
	local bronzeMission = selectedMission(kv, 101)
	local silverMission = selectedMission(kv, 201)
	local goldMission = selectedMission(kv, 301)
	local dailyJson = table.concat({
		missionJson(1, dailyFreeMission[1], dailyFreeMission[2], dailyFreeMission[3], daily, 30, false),
		missionJson(2, dailyDeluxeMission[1], dailyDeluxeMission[2], dailyDeluxeMission[3], dailyPremium, 60, true)
	}, ",")
	local generalJson = table.concat({
		missionJson(101, bronzeMission[1], bronzeMission[2], bronzeMission[3], bronze, 100, false),
		missionJson(201, silverMission[1], silverMission[2], silverMission[3], silver, 200, false),
		missionJson(301, goldMission[1], goldMission[2], goldMission[3], gold, 300, false)
	}, ",")
	local shopPoints = kv:get("shop-points") or 0
	local payload = string.format(
		'{"action":"missions","beginTime":%d,"endTime":%d,"points":%d,"rerollPrice":%d,"battlePassActive":%s,"currentRewardStep":%d,"nextStepPoints":%d,"dailyBeginTime":%d,"dailyEndTime":%d,"dailyMissions":[%s],"generalMissions":[%s],"coinsBalance":0,"bankBalance":%d,"goldBalance":%d,"battlepasPoints":%d}',
		now - 86400, now + 120 * 86400, points - stepBase, 800 * math.max(player:getLevel(), 1),
		deluxe and "true" or "false", step, nextStepPoints, dayStart, dayStart + 86400, dailyJson, generalJson, player:getBankBalance(), player:getMoney(), shopPoints
	)
	player:sendExtendedOpcode(OPCODE, payload)
	sendRewards(player)
	sendShop(player)
end

_G.sendCrystalBattlePassState = sendState

local opcodeEvent = CreatureEvent("CrystalBattlePassOpcode")
function opcodeEvent.onExtendedOpcode(player, opcode, buffer)
	if opcode ~= OPCODE then
		return
	end
	local action = buffer:match('"action"%s*:%s*"([^"]+)"')
	logger.info("[BattlePass] Received action '{}' from {} on opcode {}.", action or "invalid", player:getName(), opcode)
	if action == "requestData" then
		sendState(player)
	elseif action == "reroll" then
		local missionId = tonumber(buffer:match('"missionId"%s*:%s*(%d+)'))
		local variants = MISSION_VARIANTS[missionId]
		if not variants then
			return player:sendTextMessage(MESSAGE_FAILURE, "This mission cannot be rerolled.")
		end
		local costs = { [101] = 300000, [201] = 500000, [301] = 1000000 }
		local cost = costs[missionId] or (800 * math.max(player:getLevel(), 1))
		if not player:removeMoneyBank(cost) then
			return player:sendTextMessage(MESSAGE_FAILURE, "You do not have enough gold for this reroll.")
		end
		local kv = player:kv():scoped(SCOPE)
		local current = kv:get("mission-variant-" .. missionId) or 0
		kv:set("mission-variant-" .. missionId, (current + 1) % #variants)
		local progressKeys = { [1] = "daily-kills", [2] = "daily-premium-kills", [101] = "bronze-kills", [201] = "silver-kills", [301] = "gold-kills" }
		kv:set(progressKeys[missionId], 0)
		player:save()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Battle Pass mission rerolled successfully.")
		sendState(player)
	elseif action == "redeem" then
		local stepId = tonumber(buffer:match('"stepId"%s*:%s*(%d+)'))
		local rewardType = buffer:match('"rewardType"%s*:%s*"([^"]+)"')
		local kv, _, _, _, _, _, points = state(player)
		if not stepId or stepId < 1 or stepId > 80 or (rewardType ~= "free" and rewardType ~= "premium") then
			return player:sendTextMessage(MESSAGE_FAILURE, "Invalid Battle Pass reward.")
		end
		if points < requiredPoints(stepId) then
			return player:sendTextMessage(MESSAGE_FAILURE, "This Battle Pass level is still locked.")
		end
		if rewardType == "premium" and not kv:get("deluxe") then
			return player:sendTextMessage(MESSAGE_FAILURE, "The Deluxe Battle Pass is required.")
		end
		local claimKey = "claimed-" .. rewardType .. "-" .. stepId
		if kv:get(claimKey) then
			return player:sendTextMessage(MESSAGE_FAILURE, "This reward was already collected.")
		end
		local itemId, count, label = rewardFor(stepId, rewardType)
		if not itemId then
			return player:sendTextMessage(MESSAGE_FAILURE, "There is no free reward at this level.")
		end
		player:addItemStoreInbox(itemId, count, true, false)
		kv:set(claimKey, true)
		player:save()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Battle Pass: %d %s sent to your Store Inbox.", count, label))
		sendRewards(player)
	elseif action == "buyShopItem" then
		local shopItemId = tonumber(buffer:match('"shopItemId"%s*:%s*(%d+)'))
		local item = getShopItem(shopItemId)
		local kv = player:kv():scoped(SCOPE)
		local balance = kv:get("shop-points") or 0
		if not item then
			return player:sendTextMessage(MESSAGE_FAILURE, "Invalid Battle Pass Shop item.")
		end
		if balance < item.price then
			return player:sendTextMessage(MESSAGE_FAILURE, "You do not have enough Battle Pass Points.")
		end
		player:addItemStoreInbox(item.itemId, 1, true, false)
		kv:set("shop-points", balance - item.price)
		player:save()
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, item.name .. " was sent to your Store Inbox.")
		sendState(player)
	else
		player:sendTextMessage(MESSAGE_FAILURE, "This Battle Pass option is not configured yet.")
	end
end
opcodeEvent:register()

local killEvent = CreatureEvent("CrystalBattlePassKill")
function killEvent.onDeath(target, corpse, killer)
    if not target or not target:isMonster() or not killer then
        return true
    end

    local player
    if killer:isPlayer() then
        player = killer:getPlayer()
    else
        local master = killer:getMaster()
        if master and master:isPlayer() then
            player = master:getPlayer()
        end
    end

    if not player then
        return true
    end

    local kv, daily, dailyPremium, bronze, silver, gold, points = state(player)
	local dailyMax = selectedMission(kv, 1)[3]
	local dailyPremiumMax = selectedMission(kv, 2)[3]
	local bronzeMax = selectedMission(kv, 101)[3]
	local silverMax = selectedMission(kv, 201)[3]
	local goldMax = selectedMission(kv, 301)[3]
	local gains = 0
	local function advance(key, current, maximum, reward)
		if current >= maximum then return current end
		local updated = math.min(current + 1, maximum)
		kv:set(key, updated)
		if updated == maximum then gains = gains + reward end
		return updated
	end
	daily = advance("daily-kills", daily, dailyMax, 30)
	dailyPremium = advance("daily-premium-kills", dailyPremium, dailyPremiumMax, 60)
	bronze = advance("bronze-kills", bronze, bronzeMax, 100)
	silver = advance("silver-kills", silver, silverMax, 200)
	gold = advance("gold-kills", gold, goldMax, 300)
	if gains > 0 then
		if points >= requiredPoints(80) then
			kv:set("shop-points", (kv:get("shop-points") or 0) + gains)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Battle Pass: mission completed! +%d Battle Pass Shop Points.", gains))
		else
			kv:set("points", points + gains)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Battle Pass: mission completed! +%d points.", gains))
		end
	end
	-- KV data is normally flushed on logout. Save here as Battle Pass progress
	-- must also survive an unexpected server restart.
	player:save()
	sendState(player)
	return true
end
killEvent:register()
