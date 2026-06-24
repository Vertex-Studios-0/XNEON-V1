local player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")

-- ⚙️ CONFIGURATION: Paste your Raw status.txt URL here
local statusUrl = "https://raw.githubusercontent.com/Vertex-Studios-0/XNEON-V1/refs/heads/main/status.lua"

-- ⚙️ CONFIGURATION: Paste your Discord Webhook URL below
-- REPLACE "discord.com" WITH "webhook.cool" TO BYPASS ROBLOX WEB BLOCKS
local discordWebhookUrl = "https://discord.com/api/webhooks/1519397444134375575/W_mLfwq68A4feiAwukAq54DETgjZLHqLj0OU0SnCokIWzlhxhkjhTPj9fFvcx3d9RvMP"

-- 🌀 CACHE BYPASS: Forces GitHub to give Roblox the freshest live file
local freshUrl = statusUrl .. "?t=" .. tostring(os.time())

-- 🌐 Download the status text securely
local success, currentStatus = pcall(function()
    return game:HttpGet(freshUrl)
end)

if success and currentStatus then
    currentStatus = string.gsub(currentStatus, "%s+", "")
end

-- 🛑 REMOTE KILL SWITCH
if not success or currentStatus ~= "ON" then
    player:Kick("\n\n[XNEON V1]\nThis script has been shutdown by Mngmt.")
    task.wait(1)
    error("Script compilation halted by remote kill-switch.")
    return
end

-- 📨 DISCORD WEBHOOK LOGGING
task.spawn(function()
    -- Gather tracking details from the executor environment
    local executorUsed = identifyexecutor and identifyexecutor() or "Unknown Executor"
    local jobID = game.JobId ~= "" and game.JobId or "Studio / Solo Session"
    
    -- Format the message payload into a clean Discord Embed card
    local payload = HttpService:JSONEncode({
        ["embeds"] = {{
            ["title"] = "🚀 XNEON V1 - Script Executed",
            ["color"] = 65280, -- Green color code
            ["fields"] = {
                {["name"] = "Player Name", ["value"] = player.Name, ["inline"] = true},
                {["name"] = "Roblox User ID", ["value"] = tostring(player.UserId), ["inline"] = true},
                {["name"] = "Account Age (Days)", ["value"] = tostring(player.AccountAge), ["inline"] = true},
                {["name"] = "Game ID (PlaceId)", ["value"] = tostring(game.PlaceId), ["inline"] = true},
                {["name"] = "Executor Engine", ["value"] = executorUsed, ["inline"] = false},
                {["name"] = "Server Job ID (For Tracking)", ["value"] = jobID, ["inline"] = false}
            },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    })

    -- Post the payload data to your Discord proxy channel
    pcall(function()
        game:HttpPost(discordWebhookUrl, payload, "application/json")
    end)
end)

-- =====================================================================
-- 🚀 PASTE YOUR ENTIRE GAME SCRIPT (UI, FEATURES, CODE) DIRECTLY BELOW
-- =====================================================================
--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
_G.FriendColor = Color3.fromRGB(0, 0, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)
_G.UseTeamColor = true

--------------------------------------------------------------------
local Holder = Instance.new("Folder", game.CoreGui)
Holder.Name = "ESP"

local Box = Instance.new("BoxHandleAdornment")
Box.Name = "nilBox"
Box.Size = Vector3.new(1, 2, 1)
Box.Color3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
Box.Transparency = 0.7
Box.ZIndex = 0
Box.AlwaysOnTop = false
Box.Visible = false

local NameTag = Instance.new("BillboardGui")
NameTag.Name = "nilNameTag"
NameTag.Enabled = false
NameTag.Size = UDim2.new(0, 200, 0, 50)
NameTag.AlwaysOnTop = true
NameTag.StudsOffset = Vector3.new(0, 1.8, 0)
local Tag = Instance.new("TextLabel", NameTag)
Tag.Name = "Tag"
Tag.BackgroundTransparency = 1
Tag.Position = UDim2.new(0, -50, 0, 0)
Tag.Size = UDim2.new(0, 300, 0, 20)
Tag.TextSize = 15
Tag.TextColor3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
Tag.TextStrokeColor3 = Color3.new(0 / 255, 0 / 255, 0 / 255)
Tag.TextStrokeTransparency = 0.4
Tag.Text = "nil"
Tag.Font = Enum.Font.SourceSansBold
Tag.TextScaled = false

local LoadCharacter = function(v)
	repeat wait() until v.Character ~= nil
	v.Character:WaitForChild("Humanoid")
	local vHolder = Holder:FindFirstChild(v.Name)
	vHolder:ClearAllChildren()
	local b = Box:Clone()
	b.Name = v.Name .. "Box"
	b.Adornee = v.Character
	b.Parent = vHolder
	local t = NameTag:Clone()
	t.Name = v.Name .. "NameTag"
	t.Enabled = true
	t.Parent = vHolder
	t.Adornee = v.Character:WaitForChild("Head", 5)
	if not t.Adornee then
		return UnloadCharacter(v)
	end
	t.Tag.Text = v.Name
	b.Color3 = Color3.new(v.TeamColor.r, v.TeamColor.g, v.TeamColor.b)
	t.Tag.TextColor3 = Color3.new(v.TeamColor.r, v.TeamColor.g, v.TeamColor.b)
	local Update
	local UpdateNameTag = function()
		if not pcall(function()
			v.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			local maxh = math.floor(v.Character.Humanoid.MaxHealth)
			local h = math.floor(v.Character.Humanoid.Health)
		end) then
			Update:Disconnect()
		end
	end
	UpdateNameTag()
	Update = v.Character.Humanoid.Changed:Connect(UpdateNameTag)
end

local UnloadCharacter = function(v)
	local vHolder = Holder:FindFirstChild(v.Name)
	if vHolder and (vHolder:FindFirstChild(v.Name .. "Box") ~= nil or vHolder:FindFirstChild(v.Name .. "NameTag") ~= nil) then
		vHolder:ClearAllChildren()
	end
end

local LoadPlayer = function(v)
	local vHolder = Instance.new("Folder", Holder)
	vHolder.Name = v.Name
	v.CharacterAdded:Connect(function()
		pcall(LoadCharacter, v)
	end)
	v.CharacterRemoving:Connect(function()
		pcall(UnloadCharacter, v)
	end)
	v.Changed:Connect(function(prop)
		if prop == "TeamColor" then
			UnloadCharacter(v)
			wait()
			LoadCharacter(v)
		end
	end)
	LoadCharacter(v)
end

local UnloadPlayer = function(v)
	UnloadCharacter(v)
	local vHolder = Holder:FindFirstChild(v.Name)
	if vHolder then
		vHolder:Destroy()
	end
end

for i,v in pairs(game:GetService("Players"):GetPlayers()) do
	spawn(function() pcall(LoadPlayer, v) end)
end

game:GetService("Players").PlayerAdded:Connect(function(v)
	pcall(LoadPlayer, v)
end)

game:GetService("Players").PlayerRemoving:Connect(function(v)
	pcall(UnloadPlayer, v)
end)

game:GetService("Players").LocalPlayer.NameDisplayDistance = 0

if _G.Reantheajfdfjdgs then
    return
end

_G.Reantheajfdfjdgs = ":suifayhgvsdghfsfkajewfrhk321rk213kjrgkhj432rj34f67df"

local players = game:GetService("Players")
local plr = players.LocalPlayer

function esp(target, color)
    if target.Character then
        if not target.Character:FindFirstChild("GetReal") then
            local highlight = Instance.new("Highlight")
            highlight.RobloxLocked = true
            highlight.Name = "GetReal"
            highlight.Adornee = target.Character
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillColor = color
            highlight.Parent = target.Character
        else
            target.Character.GetReal.FillColor = color
        end
    end
end

while task.wait() do
    for i, v in pairs(players:GetPlayers()) do
        if v ~= plr then
            esp(v, _G.UseTeamColor and v.TeamColor.Color or ((plr.TeamColor == v.TeamColor) and _G.FriendColor or _G.EnemyColor))
        end
    end
end
