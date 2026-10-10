local talk = TalkAction("/addtaint")

function talk.onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	-- Aplica os 4 taints diretamente no escopo KV da Rotten Blood
	player:kv():scoped("rotten-blood-quest"):set("taints", 4)

	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Os 4 Taints da Rotten Blood foram adicionados com sucesso no seu KV!")
	player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
	return false
end

talk:separator(" ")
talk:groupType("god")
talk:register()