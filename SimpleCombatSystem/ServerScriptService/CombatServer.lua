local M1Ev = game.ReplicatedStorage.Events.M1Remote
local sss = game:GetService("ServerScriptService")
local data = require(sss.Data) -- IMPORTANT DO NOT TOUCH THE PATH
local modules = sss.Modules

local hitbox = require(modules.TomatoHitbox)
local rgmod = require(modules.ragdoll)
local kbmod = require(modules.knockback)
local stunnermod = require(modules.StunHandlerV2)
local statusmod = require(modules.StatusModule)
--Setup(if there's a "mod" on the end of the name variable, its module script)

--connect everything
M1Ev.OnServerEvent:Connect(function(plr, status, Type)
	local hum = plr.Character.Humanoid
	local hrp = hum.Parent.HumanoidRootPart
	local curcharacter = plr.CurrentCharacter.Value
	local blockbreaker = false
	local phase = plr.CurrentPhase.Value
	local isattack = data.IsAttack[plr.Name]
	local combocnt = data.Combocnt[plr.Name]
	local isblocking = data.IsBlocking[plr.Name]
	local canattack = data.CanAttack[plr.Name]
	if data.IsAttack[plr.Name] == false and data.CanAttack[plr.Name] == true then
		print(status)
		statusmod[status](plr, combocnt, isblocking, isattack, canattack, curcharacter, phase, Type, rgmod, kbmod, stunnermod, blockbreaker)
		--it was shitcode with ifs and other stuff
		--now its organised LESS GOOOOOOOOOO
	end
end)
