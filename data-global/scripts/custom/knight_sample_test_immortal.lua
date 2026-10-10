local protectedCharacter = "knight sample"
local protectionEventName = "KnightSampleTestImmortal"

local immortal = CreatureEvent(protectionEventName)

function immortal.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature or not creature:isPlayer() or creature:getName():lower() ~= protectedCharacter then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	-- Keep normal healing, but cancel every kind of incoming damage.
	if primaryType == COMBAT_HEALING or secondaryType == COMBAT_HEALING then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	return 0, primaryType, 0, secondaryType
end

immortal:register()

local login = CreatureEvent("KnightSampleTestImmortalLogin")

function login.onLogin(player)
	if player:getName():lower() == protectedCharacter then
		player:registerEvent(protectionEventName)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Test protection enabled: your character is immortal.")
	end
	return true
end

login:register()
