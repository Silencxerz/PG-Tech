-- Install each available interface independently so one missing template cannot block the menu.
local Players = game:GetService("Players")
local templates = game:GetService("ServerStorage"):WaitForChild("GameUIs")
local interfaceNames = {
    "Menu", "UIs", "_0xS0URCEC3X", "Alpha_UI", "Damaged",
    "DeployGUI", "NotificationUI", "RoleSelection", "StatGUI",
}

local function installInterfaces(player)
    local playerGui = player:WaitForChild("PlayerGui")
    for _, name in ipairs(interfaceNames) do
        local template = templates:FindFirstChild(name)
        if template and not playerGui:FindFirstChild(name) then
            local interface = template:Clone()
            if name == "Menu" then interface.ResetOnSpawn = false end
            interface.Parent = playerGui
        end
    end
end

Players.PlayerAdded:Connect(installInterfaces)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(installInterfaces, player)
end
