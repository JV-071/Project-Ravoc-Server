local linkedTasksCommand = TalkAction("!task")

function linkedTasksCommand.onSay(player, words, param)
	if not CrystalLinkedTasks or not CrystalLinkedTasks.onCommand then
		player:sendCancelMessage("Linked Tasks is not available right now.")
		return true
	end

	CrystalLinkedTasks.onCommand(player, param)
	return true
end

linkedTasksCommand:separator(" ")
linkedTasksCommand:setDescription("[Usage]: !task, !task clear, !task bonus or !task test (staff)")
linkedTasksCommand:groupType("normal")
linkedTasksCommand:register()
