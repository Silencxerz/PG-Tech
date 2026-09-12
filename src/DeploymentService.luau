-- Server-owned role validation and spawning. The client receives an explicit result.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local DeploymentService = {}
local requests = {}
local lastRequest = {}
local allowedSpecimens = {
    Edmontosaurus = "EdmontosaurusMale",
    Suchomimus = "SuchomimusMale",
    Padillasaurus = "PadillasaurusMale",
}
local roleColors = {
    ["TEST SUBJECTS"] = BrickColor.new("Steel blue"),
    ["PARADOX GENETICS"] = BrickColor.new("Really black"),
    ["DINOSAURS"] = BrickColor.new("Bright red"),
}

local function playerValue(player, className, name, value)
    local object = player:FindFirstChild(name) or Instance.new(className)
    object.Name = name
    object.Value = value
    object.Parent = player
end

local function initializePlayer(player)
    playerValue(player, "BoolValue", "Intelligence", false)
    playerValue(player, "StringValue", "PlayerType", "")
end

local function copyScripts(source, destination)
    for _, template in ipairs(source:GetChildren()) do
        local previous = destination:FindFirstChild(template.Name)
        if not previous then template:Clone().Parent = destination end
    end
end

local function performDeployment(player, role, specimen)
    if type(role) ~= "string" or not roleColors[role] then
        return { ok = false, message = "Choose an available role." }
    end
    if role == "PARADOX GENETICS" then
        local success, rank = pcall(player.GetRankInGroup, player, 12858014)
        if not success or rank < 2 then
            return { ok = false, message = "Staff access requires Paradox Genetics group rank 2 or above." }
        end
    end

    local clientDetails = ReplicatedStorage:FindFirstChild("ClientDetails")
    local scripts = clientDetails and clientDetails:FindFirstChild("Scripts")
    if not scripts then return { ok = false, message = "Character scripts are unavailable." } end

    local template
    if role == "DINOSAURS" then
        local rigName = type(specimen) == "string" and allowedSpecimens[specimen]
        local details = ServerStorage:FindFirstChild("ServerDetails")
        local rigs = details and details:FindFirstChild("Assets") and details.Assets:FindFirstChild("Rigs")
        template = rigName and rigs and rigs:FindFirstChild(rigName)
        if not template or not template:FindFirstChildOfClass("Humanoid") then
            return { ok = false, message = "That specimen is not available." }
        end
    end

    player.TeamColor = roleColors[role]
    for _, team in ipairs(Teams:GetTeams()) do
        if team.TeamColor == roleColors[role] then player.Team = team break end
    end
    playerValue(player, "BoolValue", "Intelligence", role ~= "DINOSAURS")
    playerValue(player, "StringValue", "PlayerType", role == "DINOSAURS" and "DINOSAUR" or "HUMAN")

    if template then
        local previous = player.Character
        local character = template:Clone()
        character.Name = player.Name
        copyScripts(scripts.Dinos.CharacterScripts, character)
        character.Parent = workspace
        player.Character = character
        if previous then previous:Destroy() end
    else
        player:LoadCharacterAsync()
        local character = player.Character
        if not character then return { ok = false, message = "Character did not load. Please retry." } end
        local defaultAnimate = character:FindFirstChild("Animate")
        if defaultAnimate and scripts.Humans.CharacterScripts:FindFirstChild("NewAnimate") then
            defaultAnimate:Destroy()
        end
        copyScripts(scripts.Humans.CharacterScripts, character)
        playerValue(character, "StringValue", "CommunicationType", "Human")
    end
    player:SetAttribute("PGDeployed", true)
    return { ok = true }
end

local function deploy(player, role, specimen)
    local now = os.clock()
    if requests[player] or now - (lastRequest[player] or -10) < 2 then
        return { ok = false, message = "Please wait before deploying again." }
    end
    requests[player] = true
    lastRequest[player] = now
    local success, result = pcall(performDeployment, player, role, specimen)
    requests[player] = nil
    if not success then
        warn("PG deployment failed: " .. tostring(result))
        return { ok = false, message = "Deployment failed. Please retry." }
    end
    return result
end

local remote = ReplicatedStorage:FindFirstChild("PGDeployment") or Instance.new("RemoteFunction")
remote.Name = "PGDeployment"
remote.Parent = ReplicatedStorage
remote.OnServerInvoke = deploy

-- Retain the existing human-entry remote for dependent interfaces.
ReplicatedStorage._0xS0URCEC3X.Remotes.EnterGame.OnServerEvent:Connect(function(player, role)
    if role ~= "DINOSAURS" then deploy(player, role) end
end)
Players.PlayerAdded:Connect(initializePlayer)
Players.PlayerRemoving:Connect(function(player)
    requests[player] = nil
    lastRequest[player] = nil
end)
for _, player in ipairs(Players:GetPlayers()) do initializePlayer(player) end

return DeploymentService
