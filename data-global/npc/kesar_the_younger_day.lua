local internalNpcName = "Kesar the Younger"
local npcType = Game.createNpcType("Kesar the Younger (Day)")
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 1317,
	lookHead = 38,
	lookBody = 76,
	lookLegs = 57,
	lookFeet = 114,
	lookAddons = 2,
}

npcConfig.respawnType = {
	period = RESPAWNPERIOD_DAY,
	underground = false,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {}

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

local TEN_MINUTES = 10 * 60
local ONE_TIBIAN_DAY = 60 * 60
local TWENTY_HOURS = 20 * 60 * 60

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()
	local stag = Storage.Quest.U15_20.TheOrderOfTheStag
	local stagQuest = player:getStorageValue(stag.Questline)

	if MsgContains(message, "help") or MsgContains(message, "stag") or MsgContains(message, "eldoran") then
		if player:getStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.KesarMission) < 5 then
			npcHandler:say("First, Bounac must be freed from the siege before I can burden you with another family matter.", npc, creature)
			return true
		end
		if stagQuest < 1 then
			npcHandler:say("There are whispers of a forgotten fourth heir and an Order of the Stag. Will you investigate an old frozen trophy in the castle for proof?", npc, creature)
			npcHandler:setTopic(playerId, 50)
			return true
		elseif stagQuest == 2 then
			if player:getItemCount(52586) < 1 then
				npcHandler:say("Return when you have recovered the certificate hidden beneath the frozen trophy.", npc, creature)
				return true
			end
			npcHandler:say("This certificate proves Eldoran's ancestry. Will you sail to the Isle of Ada and find him?", npc, creature)
			npcHandler:setTopic(playerId, 51)
			return true
		elseif stagQuest == 11 then
			if player:getStorageValue(stag.Reward) == 1 then
				npcHandler:say("The Order of the Stag will not be forgotten again.", npc, creature)
				return true
			end
			player:addItem(52828, 1)
			player:addOutfitAddon(1436, 2)
			player:addOutfitAddon(1437, 2)
			player:addAchievement("King's Council")
			player:setStorageValue(stag.Reward, 1)
			player:setStorageValue(stag.Questline, 12)
			npcHandler:say("Eldoran lives and his order stands. Accept this brass-shod chest and the insignia of a Royal Bounacean Advisor. You have earned a place in the King's Council.", npc, creature)
			return true
		else
			npcHandler:say("Follow the trail of the Order of the Stag and return when you bring news of Eldoran.", npc, creature)
			return true
		end
	end

	if MsgContains(message, "siege") then
		local mission = player:getStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.KesarMission)
		local timer = player:getStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.KesarSiegeTimer)
		local now = os.time()

		if mission < 1 then
			player:setStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.KesarMission, 1)
			player:setStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.KesarSiegeTimer, now)
			npcHandler:say({
				"You will have to wait until I have time to take care of your request. In the meantime, take a seat. ...",
				"Usually they're reserved for my council but they never seem to sit down... and somehow I doubt you will, either.",
			}, npc, creature)
			return true
		end

		if mission == 1 then
			if (now - timer) >= TEN_MINUTES then
				npcHandler:say({
					"So, I trust you're not here to join the usurpers besieging our humble enclave. Otherwise my men would've surely put you in your place before you even passed the gate. ...",
					"Sources are telling me that you helped our small community quite a bit. And you seem to know your way around the usurpers. ...",
					"I will trust you, as I trust my men who already put faith in you. What do you say, are you interested in a plan?",
				}, npc, creature)
				npcHandler:setTopic(playerId, 1)
			else
				npcHandler:say("I am still quite occupied, traveller. Please be patient and give me some time.", npc, creature)
			end
			return true
		end

		if mission == 2 then
			local lastSpawn = player:getStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.FugueSpawnTime)
			local fugueSpawned = player:getStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.FugueSpawned)

			if (now - timer) < ONE_TIBIAN_DAY then
				npcHandler:say("I am still preparing. Give it some more time, traveller.", npc, creature)
				return true
			end

			if fugueSpawned == 1 and lastSpawn > 0 and (now - lastSpawn) >= TWENTY_HOURS then
				player:setStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.FugueSpawned, 0)
				npcHandler:say({
					"I expected them to show up last night but nothing happened. Perhaps they are waiting for the right moment. ...",
					"Return to my chambers when night falls and stay alert. They will come.",
				}, npc, creature)
			elseif fugueSpawned == 1 then
				npcHandler:say("I know they appeared last night. You need to deal with them - go back to my chambers when night comes.", npc, creature)
			else
				npcHandler:say("I am still preparing. Give it some more time, traveller.", npc, creature)
			end
			return true
		end

		if mission == 3 then
			local hasFalcon = player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.FalconBastion.Access) >= 1
			local hasCobra = player:getStorageValue(Storage.Quest.U12_20.GraveDanger.CobraBastion.Access) >= 1

			if hasFalcon and hasCobra then
				npcHandler:say({
					"Fugue... he attacked right away and had to be punished. You did the right thing. However, this will probably mean all out war if Drume does not come to his senses. ...",
					"I will have to arrange a meeting with him immediately to prevent the worst from happening. There is still another way. ...",
					"Will you escort me to the camp of the usurpers?",
				}, npc, creature)
				npcHandler:setTopic(playerId, 2)
			else
				npcHandler:say({
					"Last night I had an idea. It came to my mind that we must not stand alone against this onslaught. There are other knights. Other orders who may sympathise with our cause ...",
					"As you might already know, I am a direct descendant of Kesar, leader of the knightly order of the Lion. ...",
					"He was one of three knights who once served King Xenom and left Edron in search of a greater purpose. ...",
					"Travel to the city of Edron and find out what you can about the order of the Falcon. ...",
					"And there is another order, I am not quite sure of its name but they travelled far south of Edron, into the desert.",
				}, npc, creature)
			end
			return true
		end

		if mission == 4 then
			npcHandler:say({
				"What news from the orders of the Falcon and the other successor order? ...",
				"The Order of the Cobra you say? Both destroyed...? The flame of virtue, the power of righteousness - diminished? In all of them? Oh... ...",
				"Far too long have I stayed silent and idle. Drume wants war. We will meet him in battle near the eastern coast of Bounac. ...",
				"Prepare yourself and I will see you on the battlefield. Good luck, my friend.",
			}, npc, creature)
			return true
		end

		if mission >= 5 then
			npcHandler:say({
				"It is done. Drume's forces lie broken on the battlefield. You witnessed the fall of a great enemy of the Order of the Lion. ...",
				"You stood tall against the enemy forces and helped our cause wherever you could. ...",
				"I will therefore announce you the 'Hero of Bounac'. You are an honourable citizen of this town now. ...",
				"Feel free to roam Bounac as you please. This also means certain benefits when trading with our court trader Augustin. ...",
				"Whenever you're here for a visit, the large house to the south of Bounac is now completely at your disposal. ...",
				"And if we can persuade you into a longer stay perhaps, there is a small house further to the south of the island which may pique your interest. ...",
				"Thank you for your service to Bounac, Hero.",
			}, npc, creature)
			player:setStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.AugustinDoor, 1)
			if not player:hasAchievement("Lionheart") then
				player:addAchievement("Lionheart")
			end
			return true
		end
	end

	if message:lower() == "yes" then
		if npcHandler:getTopic(playerId) == 50 and stagQuest < 1 then
			player:setStorageValue(stag.Questline, 1)
			npcHandler:say("Take a frozen starlight to the old trophy stand at 32402, 32467, 4. Its cold light should expose what lies beneath.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		if npcHandler:getTopic(playerId) == 51 and stagQuest == 2 then
			player:setStorageValue(stag.Questline, 3)
			npcHandler:say("Use the small vessel south of Bounac at 32397, 32512, 7. Show the certificate to Second in Command Demeron on Ada.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		local mission = player:getStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.KesarMission)

		if npcHandler:getTopic(playerId) == 1 and mission == 1 then
			player:setStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.KesarMission, 2)
			player:setStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.KesarSiegeTimer, os.time())
			npcHandler:say({
				"Excellent. Here is my plan. Either Fugue, Drume or both will appear here soon. If they try anything funny - defend yourself. ...",
				"If we can get them both at the right moment, they're done for. They will pay for what they have done. ...",
				"However, if only one of them appears and one of them is left... well, we shall not think of that now.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end

		if npcHandler:getTopic(playerId) == 2 and mission == 3 then
			player:setStorageValue(Storage.Quest.U12_40.TheOrderOfTheLion.KesarMission, 4)
			npcHandler:say({
				"Good, however, we have to wait until the recent skirmishes along the coast have settled down. ...",
				"We will venture down to the battlefield as soon as the other fights have died down.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
	end
end

npcHandler:setMessage(MESSAGE_GREET, "Hail, traveller. What brings you here during these dire times under siege? The fair Bounac is suffering greatly.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
