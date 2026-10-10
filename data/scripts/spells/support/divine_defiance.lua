local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local player = creature:getPlayer()
	if player and player:getStance() == STANCE_DIVINE_DEFIANCE then
		player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, AttrSubId_DivineDefiance)
		player:setStance(STANCE_NONE)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end
	if player then
		player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, AttrSubId_Sharpshooter)
		player:removeCondition(CONDITION_ATTRIBUTES, CONDITIONID_COMBAT, AttrSubId_DivineDefiance)

		if not player:setStance(STANCE_DIVINE_DEFIANCE) then
			player:sendTextMessage(MESSAGE_FAILURE, "Divine Defiance could not be activated for your current vocation.")
			logger.error(
				"[DivineDefiance] Activation rejected for {} (vocation {}, base vocation {}).",
				player:getName(),
				player:getVocation():getId(),
				player:getVocation():getBaseId()
			)
			return false
		end

		local condition = Condition(CONDITION_ATTRIBUTES)
		condition:setParameter(CONDITION_PARAM_SUBID, AttrSubId_DivineDefiance)
		condition:setParameter(CONDITION_PARAM_TICKS, -1)
		condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
		player:addCondition(condition)
		local specializedBonus = math.max(1, math.ceil(player:getSkillLevel(SKILL_DISTANCE) * 0.06))
		player:sendTextMessage(
			MESSAGE_EVENT_ADVANCE,
			string.format("Divine Defiance active: Holy Magic Level +%d, Healing Magic Level +%d and 12%% ranged dodge.", specializedBonus, specializedBonus)
		)
		logger.info(
			"[DivineDefiance] {} activated stance with Distance {}: Holy ML +{}, Healing ML +{}.",
			player:getName(),
			player:getSkillLevel(SKILL_DISTANCE),
			specializedBonus,
			specializedBonus
		)
	end
	creature:getPosition():sendMagicEffect(299)
	return true
end

spell:name("Divine Defiance")
spell:words("utori hur")
spell:group("support", "stance")
spell:vocation("paladin;true", "royal paladin;true")
spell:id(314)
spell:cooldown(10 * 1000)
spell:groupCooldown(2 * 1000, 10 * 1000)
spell:level(20)
spell:mana(250)
spell:needLearn(false)
spell:isSelfTarget(true)
spell:isAggressive(false)
spell:isPremium(true)

spell:register()
