-- cooldown
local cdonclicking = os.clock() -- For click cooldown, it can be modified in the following variable
local maincd = 5 -- 5 seconds cooldown
-- button to continue
local button = script.Parent.Continue
-- event and module
local event = game.ReplicatedStorage.DialogueEvent
local DialogueModule = require(game.ReplicatedStorage:WaitForChild("Dialogues"))
-- defining TextLabel with speaker and text
local speaker
local text 
local icon
local maincon
-- dialogue for defining the name and current line
local dialogue 
local sound = game.SoundService.DialogueSound
local firstline = false
local currentLine = 1
-- Everything with TweenService
local ts = game:GetService("TweenService")
-- reading the line from the module script
local function showDialogueLine(speaker, text, icon)
	local line = dialogue[currentLine]
	if line then
		
		speaker.Text = line.Speaker
		text.Text = line.Text
		icon.Image = line.Icon
		currentLine += 1
		print(currentLine)
	else

		button.Interactable = false
		for _,v in pairs(script.Parent:GetChildren()) do
			if v:IsA("Frame") then
				v:Destroy()
			end
		end
		currentLine = 1
		firstline = false
		speaker = nil
		text = nil
		icon = nil
		dialogue = nil
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
		game.Players.LocalPlayer.Character.Humanoid.JumpPower= 50
		script.Enabled = false
		task.wait(0.1)
		script.Enabled = true
	end
end 

-- Calling the function to show the next dialogue line
maincon = event.OnClientEvent:Connect(function(status, namedialogue)
	dialogue = DialogueModule[namedialogue]
	print(dialogue)
	local screen = game.ReplicatedStorage.ScreenDialogue:Clone()
	screen.Parent = script.Parent
	screen.Position = UDim2.new(0.208,0,0.707,0)
	sound:Play()
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 0
	game.Players.LocalPlayer.Character.Humanoid.JumpPower= 0
	local PresentTS = ts:Create(screen, TweenInfo.new(1), {Position = UDim2.new(0.298, 0,  0.434, 0), Size = UDim2.new(0,533,0,70), BackgroundTransparency = 0.7})
	speaker = screen.Speaker
	text = screen.Dialogue
	icon = screen.Icon
	
	showDialogueLine(speaker, text, icon)
	button.Interactable = true
	button.MouseButton1Click:Connect(function()
		warn("Clicked on button")
		if os.clock() - cdonclicking >= maincd then
			if firstline == false then
			PresentTS:Play()
			for _, v in pairs(screen:GetChildren()) do
				if v:IsA("TextLabel") or v:IsA("ImageLabel") then
					local tween
					if v.Name == "Speaker" then
						tween = ts:Create(v, TweenInfo.new(1), {Size = UDim2.new(0,49,0,21),TextSize = 14, TextTransparency = 0.7})
					elseif v.Name == "Dialogue" then
						tween = ts:Create(v, TweenInfo.new(1), {Size = UDim2.new(0,429,0,34), TextSize = 14, TextTransparency = 0.7})
					elseif v.Name == "Icon" then
						tween = ts:Create(v, TweenInfo.new(1), {Size = UDim2.new(0,77,0,70),ImageTransparency = 0.7})
					end
					if tween then tween:Play() end
				end
			end
			firstline = true
				screen.Name = "TrashDialogue"
			end
			for _,v in pairs(script.Parent:GetChildren()) do
				if v.Name == "TrashDialogue" then
					local PreviousTS = ts:Create(v, TweenInfo.new(1), {Position = UDim2.new(0.298, 0,  0.2, 0), Size = UDim2.new(0, 250, 0, 35), BackgroundTransparency = 1})
					PreviousTS:Play()
					for _, b in pairs(v:GetChildren()) do
						if b:IsA("TextLabel") or b:IsA("ImageLabel") then
							local tween
							if b.Name == "Speaker" then
								tween = ts:Create(b, TweenInfo.new(1), {TextTransparency = 1})
							elseif b.Name == "Dialogue" then
								tween = ts:Create(b, TweenInfo.new(1), {TextTransparency = 1})
							elseif b.Name == "Icon" then
								tween = ts:Create(b, TweenInfo.new(1), {ImageTransparency = 1})
							end
							if tween then tween:Play() print("Playing") end
						end
					end
					PreviousTS.Completed:Connect(function(state)
						v:Destroy()
					end)
				end
			end
			local secondscreen =  game.ReplicatedStorage.ScreenDialogue:Clone()
			secondscreen.Parent = script.Parent
			secondscreen.Position = UDim2.new(0.208,0,1.3,0)
			for _,v in pairs(script.Parent:GetChildren()) do
			   if v.Name == "PresentScreen" then
				   local Present1TS = ts:Create(v, TweenInfo.new(1), {Position = UDim2.new(0.298, 0,  0.434, 0), Size = UDim2.new(0,533,0,70), BackgroundTransparency = 0.7})
				   Present1TS:Play()
				   v.Name = "TrashDialogue"
					for _, v in pairs(v:GetChildren()) do
						if v:IsA("TextLabel") or v:IsA("ImageLabel") then
							local tween
							if v.Name == "Speaker" then
								tween = ts:Create(v, TweenInfo.new(1), {Size = UDim2.new(0,49,0,21),TextSize = 14, TextTransparency = 0.7})
							elseif v.Name == "Dialogue" then
								tween = ts:Create(v, TweenInfo.new(1), {Size = UDim2.new(0,429,0,34), TextSize = 14, TextTransparency = 0.7})
							elseif v.Name == "Icon" then
								tween = ts:Create(v, TweenInfo.new(1), {Size = UDim2.new(0,77,0,70),ImageTransparency = 0.7})
							end
							if tween then tween:Play() end
						end
					end
			   end
		    end
			secondscreen.Name = "PresentScreen"
			showDialogueLine(secondscreen.Speaker, secondscreen.Dialogue, secondscreen.Icon)
			local IncomingTS = ts:Create(secondscreen, TweenInfo.new(1), {Position = UDim2.new(0.208, 0,  0.707, 0)})
			IncomingTS:Play()
		end
	end) 
end) 
