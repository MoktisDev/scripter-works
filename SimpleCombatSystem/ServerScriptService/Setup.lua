local dss = game:GetService("DataStoreService")
local mydss = dss:GetDataStore("mydss") --MyDataStore heh

game.Players.PlayerAdded:Connect(function(player)
	-- Setup
	
	player.CharacterAdded:Connect(function(chrctr)
		local bool = Instance.new("BoolValue")
		bool.Name = "Ragdoll"
		bool.Value = false
		bool.Parent = chrctr
	end)
	local Phase = Instance.new("IntValue")
	Phase.Name = "CurrentPhase"
	Phase.Parent = player
	Phase.Value = 1
	--Leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local Kills = Instance.new("IntValue")
	Kills.Name = "Kills"
	Kills.Parent = leaderstats

	local TotalKills = Instance.new("IntValue")
	TotalKills.Name = "Total kills"
	TotalKills.Parent = leaderstats

    
	player.CharacterAdded:Wait()

	local cc = Instance.new("StringValue")
	cc.Name = "CurrentCharacter"
	cc.Parent = player

	local Id = "Player_"..player.UserId

	-- Load Data
	local data
	local success, errormessage = pcall(function()
		data = mydss:GetAsync(Id)
	end)

	if success then
		if data then
			Kills.Value = data.Kills or 0
			TotalKills.Value = data.TotalKills or 0
			player.CurrentCharacter.Value = data.CurrentCharacter
			if player.CurrentCharacter.Value == "" then
				player.CurrentCharacter.Value = "Restless Gambler"
			end
		end
	else
		warn("Error loading data: "..errormessage)
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	local Id = "Player_"..player.UserId

	local data = {
		Kills = player.leaderstats.Kills.Value,
		TotalKills = player.leaderstats["Total kills"].Value,
		CurrentCharacter = player.CurrentCharacter.Value
	}

	local success, errormessage = pcall(function()
		mydss:SetAsync(Id, data)
	end)

	if success then
		print("Data saved")
	else
		print("Error saving data: "..errormessage)
	end
end)

--Yuipeee
