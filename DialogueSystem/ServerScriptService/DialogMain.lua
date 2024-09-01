local mainpart = workspace.dialoguepart
local detector = mainpart.ClickDetector
local dialogEv = game.ReplicatedStorage.DialogueEvent

detector.MouseClick:Connect(function(plr)
	warn("Clicked")
	dialogEv:FireClient(plr, "Start", "dialoguethree") -- The 3rd argument is the name of the dialogue; the dialogues themselves can be created in a module script
end)
