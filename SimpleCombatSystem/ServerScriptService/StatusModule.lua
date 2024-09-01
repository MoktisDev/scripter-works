local data = require(game.ServerScriptService.Data)
local hitbox = require(game.ServerScriptService.Modules.TomatoHitbox)
local M1Ev = game.ReplicatedStorage.Events.M1Remote
local StatusModule = {
	Reset = function(plr, combocnt, isblocking, isattack, canattack)
		print("Reset")
		data.Combocnt[plr.Name] = 1
	end,
	Block = function(plr, combocnt, isblocking, isattack, canattack)
		print("Block")
		data.IsBlocking[plr.Name] = true
		M1Ev:FireClient(plr, "Block")
	end,
	EndBlock = function(plr, combocnt, isblocking, isattack, canattack)
		print("EndBlock")
		M1Ev:FireClient(plr, "EndBlock")
		data.IsBlocking[plr.Name] = false
	end,
	Hit = function(plr, combocnt, isblocking, isattack, canattack, curcharacter, phase, Type, rg, kb, stunner, blockbreaker)

		local newhitbox = hitbox.new()
		local blocked = false
		newhitbox.Size = plr.Character["Right Leg"].Size
		local hrp = plr.Character:WaitForChild("HumanoidRootPart")
		local hum = plr.Character:WaitForChild("Humanoid")
		newhitbox.CFrame = data.Combocnt[plr.Name] == 1 and plr.Character["Right Leg"] or plr.Character["Left Leg"] --Set the hitbox correctly
		--HITBOX CFRAME IS CORRECT ONLY FOR ONE CHARACTER IN ONE PHASE, WILL BE FINISHED
		if Type == "Downslam" or Type == "Uppercut" then --Make the hitbox bigger and with offset
			newhitbox.Offset = CFrame.new(0,-5,0)
			newhitbox.Size += Vector3.new(5,5,5)
		end

		blockbreaker = Type == "Downslam" and true or false --Downslam is blockbreake
 		print("WHERE")
		newhitbox.onTouch = function(enemyhum) --Dealing damage,ragdoll and knockback
			
			print("Got em")
			if enemyhum ~= hum and enemyhum.Parent.Ragdoll.Value == false then --Check if touched humanoid is not owned by attacker
				print("LESS GOOOOOOOOOOOOO")
				local enemyhrp = enemyhum.Parent.HumanoidRootPart

				data.CanAttack[enemyhum.Parent.Name] = false
				if blockbreaker == false and data.IsBlocking[enemyhum.Parent.Name] == true then
					local direction = (hrp.Position - enemyhrp.Position).Unit
					local enemylook = enemyhrp.CFrame.LookVector
					local dot = direction:Dot(enemylook)
					if dot > -0.4 then
						blocked = true
					end
				end
				--Check if enemy blocking(Not finished)


				if data.Combocnt[plr.Name] < 4 and not blocked then
					enemyhum:TakeDamage(2.5)
					enemyhum:LoadAnimation(game.ReplicatedStorage.BasicAnims["Stun"..math.random(1,3)]):Play()
					if data.Combocnt[plr.Name]  == 3 then
						stunner.Stun(enemyhum, 1.5)
					end
					if curcharacter == "Restless Gambler" and phase == 1 then
						local sound = game.SoundService.Configs["Restless Gambler"]["1th phase"]["m1's"].Sounds["Kick"..data.Combocnt[plr.Name]]
						sound:Play()		
						enemyhum.Parent:GetAttributeChangedSignal("Stunned"):Connect(function()
							if enemyhum.Parent:GetAttribute("Stunned") == false then
								data.CanAttack[enemyhum.Parent.Name] = false
							end
						end)
					end
				elseif not blocked then
					enemyhum:TakeDamage(7.5)
					rg.Start(enemyhum.Parent)
					local sound
					if Type == "Downslam" then
						sound = game.SoundService.BasicSounds["Downslam"..math.random(1,3)]
						kb.Start(enemyhum.Parent, Vector3.new(0, -30, 0))
					elseif Type == "Uppercut" then
						sound = game.SoundService.BasicSounds["Uppercut"..math.random(1,3)]
						kb.Start(enemyhum.Parent, Vector3.new(0, 60, 0))
					else
					    
						sound = game.SoundService.Configs["Restless Gambler"]["1th phase"]["m1's"].Sounds["Kick"..data.Combocnt[plr.Name]]
						kb.Start(enemyhum.Parent, (enemyhrp.Position - hrp.Position).Unit * 50 + Vector3.new(0, 15, 0))
					end
					sound:Play()
				end
				----First three hits with stun(if statement). Last hit with ragdoll, knockback and sound(else statement)


				enemyhum.Parent.Ragdoll:GetPropertyChangedSignal("Value"):Connect(function()
					if enemyhum.Parent.Ragdoll.Value == true then
						task.wait(2)
						rg.Stop(enemyhum.Parent)
					end
				end)
				--Turn off the ragdoll after 4th hit


			end
		end
		newhitbox:Start()
		task.wait(0.3)
		newhitbox:Stop()
		newhitbox:Destroy()
	end,
	M1 = function(plr, combocnt, isblocking, isattack, canattack, curcharacter, phase)
		print("M1")
		M1Ev:FireClient(plr, "Attack")
		if plr.CurrentCharacter.Value == "Restless Gambler" then
			curcharacter = "Restless Gambler"
			if plr.CurrentPhase.Value == 1 then
				phase = 1 
			end
		end
	end,
	EndAnim = function(plr, combocnt, isblocking, isattack, canattack, curcharacter, phase)
		print("EndAnim")
		M1Ev:FireClient(plr, "EndAttack")
		data.IsAttack[plr.Name] = false
		curcharacter = ""
		phase = 0
		data.Combocnt[plr.Name] += 1
		if data.Combocnt[plr.Name] > 4 then
			data.Combocnt[plr.Name] = 1
		end
		if data.Combocnt[plr.Name] == 4  then
			
		end
	end,
	FrontDash = function(plr)
		local dashhitbox = hitbox.new()
		local blocked = false
		local char = plr.Character
		local hrp = char:WaitForChild("HumanoidRootPart")
		local hum = char:WaitForChild("Humanoid")
		dashhitbox.CFrame = plr.Character["Right Arm"]
		dashhitbox.onTouch = function(enemyhum) --Dealing damage,ragdoll and knockback

			print("Got em")
			if enemyhum ~= hum and enemyhum.Parent.Ragdoll.Value == false then --Check if touched humanoid is not owned by attacker
			M1Ev:FireClient(plr, "StartPunch")
			end
		end
		dashhitbox:Start()
	end,
	HitFrontDash = function(plr)
		  local dashhitbox = hitbox.new()
		  local blocked = false
		  local char = plr.Character
		  local hrp = char:WaitForChild("HumanoidRootPart")
		  local hum = char:WaitForChild("Humanoid")
		dashhitbox.CFrame = plr.Character["Right Arm"]
	     dashhitbox.onTouch = function(enemyhum) --Dealing damage,ragdoll and knockback

			print("Got em")
			if enemyhum ~= hum and enemyhum.Parent.Ragdoll.Value == false then --Check if touched humanoid is not owned by attacker
				print("LESS GOOOOOOOOOOOOO")
				local enemyhrp = enemyhum.Parent.HumanoidRootPart

				data.CanAttack[enemyhum.Parent.Name] = false
				if data.IsBlocking[enemyhum.Parent.Name] == true then
					local direction = (hrp.Position - enemyhrp.Position).Unit
					local enemylook = enemyhrp.CFrame.LookVector
					local dot = direction:Dot(enemylook)
					if dot > -0.4 then
						blocked = true
						end
				end
				if not blocked then
					enemyhum:TakeDamage(3)
					enemyhum:LoadAnimation(game.ReplicatedStorage.BasicAnims["Stun"..math.random(1,3)]):Play()
					local sound = game.SoundService.Configs["Restless Gambler"]["1th phase"]["m1's"].Sounds["Kick"..data.Combocnt[plr.Name]]
					sound:Play()
				end
				end
		 end
		 dashhitbox:Start()
		 task.wait(0.1)
		 dashhitbox:Stop()
	end,
}

return StatusModule

