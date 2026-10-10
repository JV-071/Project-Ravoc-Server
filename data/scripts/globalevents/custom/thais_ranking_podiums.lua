local podiums = {
	{
		title = "Top Level",
		actorType = "Ranking Level Champion",
		position = Position(32375, 32213, 7),
		query = "SELECT `name`, `level` AS `score`, `looktype`, `lookhead`, `lookbody`, `looklegs`, `lookfeet`, `lookaddons` FROM `players` WHERE `group_id` < 3 ORDER BY `level` DESC, `experience` DESC LIMIT 1",
	},
	{
		title = "Top Magic Level",
		actorType = "Ranking Magic Champion",
		position = Position(32377, 32213, 7),
		query = "SELECT `name`, `maglevel` AS `score`, `looktype`, `lookhead`, `lookbody`, `looklegs`, `lookfeet`, `lookaddons` FROM `players` WHERE `group_id` < 3 ORDER BY `maglevel` DESC, `manaspent` DESC LIMIT 1",
	},
	{
		title = "Top Sword",
		actorType = "Ranking Sword Champion",
		position = Position(32373, 32213, 7),
		query = "SELECT `name`, `skill_sword` AS `score`, `looktype`, `lookhead`, `lookbody`, `looklegs`, `lookfeet`, `lookaddons` FROM `players` WHERE `group_id` < 3 ORDER BY `skill_sword` DESC, `skill_sword_tries` DESC LIMIT 1",
	},
}

local rankingActors = {}

local function updateRankingActor(entry, playerName, outfit)
	local actor = rankingActors[entry.title]
	if not actor or actor:isRemoved() then
		actor = Game.createNpc(entry.actorType, entry.position, false, true)
		rankingActors[entry.title] = actor
	end
	if not actor then
		return false
	end
	actor:setName(playerName)
	actor:setOutfit(outfit)
	return true
end

local function setPodiumOutfit(podium, outfit)
	podium:setCustomAttribute("LookType", outfit.lookType or 0)
	podium:setCustomAttribute("LookHead", outfit.lookHead or 0)
	podium:setCustomAttribute("LookBody", outfit.lookBody or 0)
	podium:setCustomAttribute("LookLegs", outfit.lookLegs or 0)
	podium:setCustomAttribute("LookFeet", outfit.lookFeet or 0)
	podium:setCustomAttribute("LookAddons", outfit.lookAddons or 0)

	if outfit.lookMount and outfit.lookMount > 0 then
		podium:setCustomAttribute("LookMount", outfit.lookMount)
		podium:setCustomAttribute("LookMountHead", outfit.lookMountHead or 0)
		podium:setCustomAttribute("LookMountBody", outfit.lookMountBody or 0)
		podium:setCustomAttribute("LookMountLegs", outfit.lookMountLegs or 0)
		podium:setCustomAttribute("LookMountFeet", outfit.lookMountFeet or 0)
	else
		podium:removeCustomAttribute("LookMount")
		podium:removeCustomAttribute("LookMountHead")
		podium:removeCustomAttribute("LookMountBody")
		podium:removeCustomAttribute("LookMountLegs")
		podium:removeCustomAttribute("LookMountFeet")
	end
end

local function getPodium(position)
	local tile = Tile(position)
	if not tile then
		return nil
	end

	return tile:getItemById(35973) or tile:getItemById(35974)
end

local function updatePodium(entry)
	local query = db.storeQuery(entry.query)
	if not query then
		return
	end

	-- Configure the replacement outside the map. Moving it in afterwards sends
	-- the complete podium outfit/name to clients that are already nearby.
	local podium = Game.createItem(35973, 1)
	if podium then
		local playerName = result.getString(query, "name")
		local score = result.getNumber(query, "score")
		local onlinePlayer = Player(playerName)
		local outfit
		if onlinePlayer then
			-- Uses exactly what the ranked character is wearing right now.
			outfit = onlinePlayer:getOutfit()
		else
			outfit = {
				lookType = result.getNumber(query, "looktype"),
				lookHead = result.getNumber(query, "lookhead"),
				lookBody = result.getNumber(query, "lookbody"),
				lookLegs = result.getNumber(query, "looklegs"),
				lookFeet = result.getNumber(query, "lookfeet"),
				lookAddons = result.getNumber(query, "lookaddons"),
				lookMount = 0,
			}
		end
		if updateRankingActor(entry, playerName, outfit) then
			-- The NPC supplies the visible character and floating player name.
			-- Keep only the stone base from the podium item.
			podium:setCustomAttribute("LookType", 0)
			podium:removeCustomAttribute("LookMount")
		else
			setPodiumOutfit(podium, outfit)
		end
		podium:setCustomAttribute("LookDirection", DIRECTION_SOUTH)
		podium:setCustomAttribute("PodiumVisible", 1)
		podium:setAttribute(ITEM_ATTRIBUTE_NAME, playerName)
		podium:setAttribute(ITEM_ATTRIBUTE_ARTICLE, "")
		podium:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, string.format("%s\n%s: %d", playerName, entry.title, score))

		local oldPodium = getPodium(entry.position)
		if oldPodium then
			oldPodium:remove()
		end
		podium:moveTo(entry.position)
	end
	result.free(query)
end

local rankingPodiums = GlobalEvent("ThaisRankingPodiums")

function rankingPodiums.onThink(interval)
	for _, entry in ipairs(podiums) do
		updatePodium(entry)
	end
	return true
end

rankingPodiums:interval(30 * 1000)
rankingPodiums:register()

local rankingPodiumsStartup = GlobalEvent("ThaisRankingPodiumsStartup")

function rankingPodiumsStartup.onStartup()
	for _, entry in ipairs(podiums) do
		updatePodium(entry)
	end
	return true
end

rankingPodiumsStartup:register()
