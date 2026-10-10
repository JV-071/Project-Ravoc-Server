local stag = Storage.Quest.U15_20.TheOrderOfTheStag

local certificate = Action()
function certificate.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(stag.Questline) ~= 1 then
		return false
	end
	if not player:removeItem(3249, 1) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You need a frozen starlight to reveal what is hidden here.")
		return true
	end
	player:addItem(52586, 1)
	player:setStorageValue(stag.Certificate, 1)
	player:setStorageValue(stag.Questline, 2)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The frozen light reveals an ice-covered certificate of ancestry beneath the trophy.")
	toPosition:sendMagicEffect(CONST_ME_ICEAREA)
	return true
end
certificate:position(Position(32402, 32467, 4))
certificate:register()

local adaBoat = Action()
function adaBoat.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(stag.Questline) < 3 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You do not know how to navigate this vessel yet.")
		return true
	end
	player:teleportTo(Position(33873, 32245, 7))
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	return true
end
adaBoat:position(Position(32397, 32512, 7))
adaBoat:register()

local corpsePiles = {
	{ position = Position(33858, 32117, 5), storage = stag.PutridPile },
	{ position = Position(33869, 32114, 5), storage = stag.PoisonousPile },
	{ position = Position(33869, 32134, 5), storage = stag.VilePile },
}
for _, config in ipairs(corpsePiles) do
	local pile = Action()
	function pile.onUse(player, item, fromPosition, target, toPosition, isHotkey)
		if player:getStorageValue(stag.Questline) ~= 7 then
			return false
		end
		if player:getStorageValue(config.storage) < 1 then
			player:setStorageValue(config.storage, 1)
			toPosition:sendMagicEffect(CONST_ME_HITBYFIRE)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You set fire to the foul corpse pile.")
		end
		if player:getStorageValue(stag.PutridPile) == 1 and player:getStorageValue(stag.PoisonousPile) == 1 and player:getStorageValue(stag.VilePile) == 1 then
			player:setStorageValue(stag.Questline, 8)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "All three corpse piles have been burned. Report to Eldoran.")
		end
		return true
	end
	pile:position(config.position)
	pile:register()
end

local courtWarlockDeath = CreatureEvent("OrderOfTheStagCourtWarlockDeath")
function courtWarlockDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	for participant, _ in pairs(creature:getMonster():getDamageMap()) do
		local player = Player(participant)
		if player and player:getStorageValue(stag.Questline) == 9 then
			player:setStorageValue(stag.CourtWarlockKilled, 1)
			player:setStorageValue(stag.Questline, 10)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The Court Warlock has fallen. Report to Eldoran the Ambitious.")
		end
	end
	return true
end
courtWarlockDeath:register()

local courtLever = Action()
function courtLever.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(stag.Questline) ~= 9 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Eldoran has not authorised you to confront the warlock.")
		return true
	end
	local arenaCenter = Position(33838, 32133, 3)
	local spectators = Game.getSpectators(arenaCenter, false, false, 8, 8, 8, 8)
	for _, spectator in ipairs(spectators) do
		if spectator:isPlayer() then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Another party is already fighting in the tower.")
			return true
		end
	end
	for _, spectator in ipairs(spectators) do
		if spectator:isMonster() then
			spectator:remove()
		end
	end
	local party = { player }
	if player:getParty() then
		party = player:getParty():getMembers()
		table.insert(party, player:getParty():getLeader())
	end
	local destinations = {
		Position(33835, 32138, 3), Position(33836, 32138, 3), Position(33837, 32138, 3), Position(33838, 32138, 3),
	}
	local moved = 0
	for _, member in ipairs(party) do
		if member:getPosition():getDistance(player:getPosition()) <= 4 and member:getStorageValue(stag.Questline) == 9 and destinations[moved + 1] then
			member:teleportTo(destinations[moved + 1])
			member:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			moved = moved + 1
		end
	end
	if moved == 0 then
		return true
	end
	Game.createMonster("Raging Raubritter", Position(33834, 32131, 3), true, true)
	Game.createMonster("Frozen Raubritter", Position(33842, 32131, 3), true, true)
	Game.createMonster("Poisoned Raubritter", Position(33834, 32135, 3), true, true)
	Game.createMonster("Energised Raubritter", Position(33842, 32135, 3), true, true)
	addEvent(function()
		local boss = Game.createMonster("Court Warlock", arenaCenter, true, true)
		if boss then
			boss:registerEvent("OrderOfTheStagCourtWarlockDeath")
		end
	end, 15000)
	return true
end
courtLever:position(Position(33838, 32139, 3))
courtLever:register()
