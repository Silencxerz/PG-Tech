local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

ReplicatedFirst:RemoveDefaultLoadingScreen()
local screen = Instance.new("ScreenGui")
screen.Name = "PGLoading"
screen.IgnoreGuiInset = true
screen.DisplayOrder = 100
screen.ResetOnSpawn = false
screen.Parent = player:WaitForChild("PlayerGui")

local surface = Instance.new("CanvasGroup")
surface.Size = UDim2.fromScale(1, 1)
surface.BackgroundColor3 = Color3.fromRGB(17, 28, 28)
surface.BorderSizePixel = 0
surface.Parent = screen

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.fromScale(0.5, 0.44)
title.Size = UDim2.fromScale(0.9, 0.12)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 38
title.TextColor3 = Color3.fromRGB(232, 236, 222)
title.Text = "PARADOX GENETICS"
title.Parent = surface

local status = title:Clone()
status.Position = UDim2.fromScale(0.5, 0.55)
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.Text = "Preparing field interface…"
status.Parent = surface

local startedAt = os.clock()
-- This waits for actual interface readiness and yields on every iteration.
while not player:GetAttribute("PGMenuReady") and os.clock() - startedAt < 20 do
    task.wait(0.1)
end
if not player:GetAttribute("PGMenuReady") then
    status.Text = "Interface unavailable. Please rejoin the session."
    return
end

local fade = TweenService:Create(surface, TweenInfo.new(0.3), { GroupTransparency = 1 })
fade:Play()
fade.Completed:Wait()
screen:Destroy()
