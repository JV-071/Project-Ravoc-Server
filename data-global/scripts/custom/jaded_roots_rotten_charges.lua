-- Jaded Roots: Rotten Charges
-- Organic Acid used on a Small Spore Resevour grants one Rotten Charge.
-- The position below is the reservoir at which the mechanic is being tested.

local config = {
	maxCharges = 100,
	-- Test setting: four Organic Acids complete the 100 Rotten Charges.
	chargesPerUse = 25,
	reservoirs = {
		Position(33842, 31650, 13),
	},
}

local function isReservoir(position)
	for _, reservoirPosition in ipairs(config.reservoirs) do
		if position.x == reservoirPosition.x and position.y == reservoirPosition.y and position.z == reservoirPosition.z then
			return true
		end
	end
	return false
end

local organicAcid = Action()

function organicAcid.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or not target:isItem() or not isReservoir(toPosition) then
		return false
	end

	local questData = player:kv():scoped("rotten-blood-quest")
	local currentCharges = questData:get("jaded-roots-charges") or 0
	if currentCharges >= config.maxCharges then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your Rotten Charges are already full.")
		return true
	end

	item:remove(1)
	local newCharges = math.min(currentCharges + config.chargesPerUse, config.maxCharges)
	questData:set("jaded-roots-charges", newCharges)
	player:setIcon("jaded-roots-rotten-charges", CreatureIconCategory_Quests, CreatureIconQuests_WhiteCross, newCharges)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("The reservoir absorbs the Organic Acid. Rotten Charges: %d/%d.", newCharges, config.maxCharges))
	toPosition:sendMagicEffect(CONST_ME_POISONAREA)
	return true
end

local organicAcidId = ItemType("organic acid"):getId()
if organicAcidId > 0 then
	organicAcid:id(organicAcidId)
	organicAcid:register()
else
	logger.error("[Jaded Roots] Organic Acid item was not found; Rotten Charge action was not registered.")
end
