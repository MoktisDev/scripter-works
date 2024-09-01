-- Setup
local plr = game.Players.LocalPlayer
local chrctr = plr.Character
local gamechrctr = plr:WaitForChild("CurrentCharacter").Value
local phase = plr:WaitForChild("CurrentPhase").Value
local M1Ev = game.ReplicatedStorage.Events.M1Remote
local uis = game:GetService("UserInputService")
local configs = game.ReplicatedStorage.Configs
local hit1, hit2, hit3, hit4, downslam, uppercut
local cnt = 1
local lastattack = os.clock()
local blockcd = os.clock()
local holdspace = false 
local blockanim = chrctr:WaitForChild("Humanoid"):LoadAnimation(game.ReplicatedStorage.BasicAnims.Block)

-- Main load function
local function Load()
	if gamechrctr == "Restless Gambler" then
		if phase == 1 then
			local anims = configs["Restless Gambler"]["1th phase"]["m1's"].Anims 
			hit1 = anims.Kick1 
			hit2 = anims.Kick2 
			hit3 = anims.Kick3 
			hit4 = anims.Kick4
			downslam = anims.Downslam
			uppercut = anims.Uppercut
		end
	end
end

-- Dynamic variables
plr.CurrentCharacter.Changed:Connect(function(value)
	gamechrctr = value
end)

plr.CurrentPhase.Changed:Connect(function(value)
	phase = value
	Load()
end)

task.wait(3)
Load()

-- Function to play animations
local function playAnimations(lasthit)
	M1Ev:FireServer("M1")
	chrctr.Humanoid.WalkSpeed = 0
	chrctr.Humanoid.JumpPower = 0
	local animation
	if cnt == 1 then
		animation = hit1
	elseif cnt == 2 then
		animation = hit2
	elseif cnt == 3 then
		animation = hit3
	elseif cnt == 4 then
		if lasthit ~= nil then
			animation = lasthit

			
		else
		animation = hit4
		end
	end
     
	if animation then
		local track = chrctr.Humanoid:LoadAnimation(animation)
		track:Play()
		track:AdjustSpeed(1.5)
		lastattack = os.clock()
		track.KeyframeReached:Connect(function(hit)
			if animation == downslam then
				M1Ev:FireServer("Hit", "Downslam")
				print("Downslam")
			elseif animation == uppercut then
				M1Ev:FireServer("Hit", "Uppercut")
			    print("Uppercut")
			else 
				M1Ev:FireServer("Hit")
			end
		end)

		track.Ended:Connect(function()
			chrctr.Humanoid.WalkSpeed = 16
			chrctr.Humanoid.JumpPower = 50
			M1Ev:FireServer("EndAnim")

			if uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				if plr.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall and cnt == 4 then
					playAnimations(downslam)
				elseif holdspace and cnt == 4 then
					playAnimations(uppercut)
				else
					playAnimations()
				end
			end
		end)
	else
		warn("Animation not found for cnt: " .. tostring(cnt))
	end

	cnt += 1
	if cnt > 4 then 
		cnt = 1 
	end
end

uis.InputBegan:Connect(function(input, istyping)
	if istyping then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and os.clock() - lastattack <= 1.5 and holdspace == false then
		if plr.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
			playAnimations(downslam)
		elseif holdspace then
			playAnimations(uppercut)
		else
			playAnimations()
		end
	elseif os.clock() - lastattack > 1.5 and input.UserInputType == Enum.UserInputType.MouseButton1 and not istyping then
		cnt = 1
		M1Ev:FireServer("Reset")
		playAnimations()
	end
	if input.KeyCode == Enum.KeyCode.Space then
		holdspace = true
	end
	if input.KeyCode == Enum.KeyCode.F and os.clock() - blockcd >= 0.2 then
		blockanim:Play()
		chrctr.Humanoid.WalkSpeed = 4
		chrctr.Humanoid.JumpPower = 0
		print("Block")
		M1Ev:FireServer("Block")
	end
end)

uis.InputEnded:Connect(function(input, istyping)
	if input.KeyCode == Enum.KeyCode.Space  then
		holdspace = false
	end
	if input.KeyCode == Enum.KeyCode.F  then
		blockcd = os.clock()
		print("Endblock")
		chrctr.Humanoid.WalkSpeed = 16
		chrctr.Humanoid.JumpPower = 50
		blockanim:Stop()
		M1Ev:FireServer("EndBlock")
	end
end)

