-- Discord: entitysixxer | Roblox: Entltysix
-- The view owns layout; this controller owns input, presentation state, and deployment feedback.
-- Spawning and role permissions remain server-side so changing this UI cannot grant access.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local menu = script.Parent
local view = require(script:WaitForChild("MenuView")).Create(menu)
local deployment = ReplicatedStorage:WaitForChild("PGDeployment", 15)
local resources = ReplicatedStorage:FindFirstChild("_0xS0URCEC3X")
local sounds = resources and resources:FindFirstChild("Client") and resources.Client:FindFirstChild("SFX")
local menuMusic = sounds and sounds:FindFirstChild("MenuTheme")
local selectedRole = menu:WaitForChild("SelectedTeam")

local currentPage = "Home"
local reducedMotion = false
local musicEnabled = true
local requestVersion = 0
local deploying = false
local transition
local destroyed = false

local function playSound(name)
    local sound = sounds and sounds:FindFirstChild(name)
    if sound and sound:IsA("Sound") then
        sound:Play()
    end
end

local function updateMusic()
    if not menuMusic then return end
    menuMusic.Volume = 0.35
    menuMusic.Looped = true
    if musicEnabled and view.root.Visible then
        if not menuMusic.IsPlaying then menuMusic:Play() end
    else
        menuMusic:Pause()
    end
end

local function showPage(pageName)
    if not view.pages[pageName] or deploying then return end
    currentPage = pageName
    for name, page in pairs(view.pages) do
        page.Visible = name == pageName
        view.buttons[name].Label.TextColor3 = name == pageName
            and Color3.fromRGB(186, 217, 128) or Color3.fromRGB(232, 236, 222)
    end
    -- Cancel the previous tween so rapid navigation cannot leave two writers on the canvas.
    if transition then transition:Cancel() end
    view.canvas.Position = UDim2.fromScale(0.5, reducedMotion and 0.5 or 0.515)
    view.canvas.GroupTransparency = reducedMotion and 0 or 0.2
    transition = TweenService:Create(view.canvas, TweenInfo.new(reducedMotion and 0 or 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.5),
        GroupTransparency = 0,
    })
    transition:Play()
    menu:SetAttribute("CurrentPage", pageName)
end

local function selectRole(roleName)
    selectedRole.Value = roleName
    menu.Main.SelectedTeam.Text = "SELECTED TEAM: " .. roleName
    view.role.Text = "Selected role: " .. roleName:lower()
    view.notice.Text = "Role selected. Return to Overview when you are ready."
    for name, control in pairs(view.roleButtons) do
        control.UIStroke.Color = name == roleName
            and Color3.fromRGB(186, 217, 128) or Color3.fromRGB(150, 170, 159)
    end
end

local function deploy(specimen)
    if deploying then return end
    if not deployment then
        view.notice.Text = "Deployment service is unavailable. Rejoin the session."
        return
    end
    if selectedRole.Value == "DINOSAURS" and not specimen then
        showPage("Specimens")
        return
    end

    deploying = true
    requestVersion += 1
    local version = requestVersion
    local requestedRole = selectedRole.Value
    view.notice.Text = "Preparing deployment…"
    view.buttons.Deploy.Label.Text = "Preparing…"

    -- A lost response must not leave every menu control permanently locked.
    task.delay(18, function()
        if not destroyed and deploying and requestVersion == version then
            deploying = false
            requestVersion += 1
            view.buttons.Deploy.Label.Text = "Enter the field  →"
            view.notice.Text = "Deployment took too long. Please try again."
        end
    end)

    task.spawn(function()
        local success, response = pcall(function()
            return deployment:InvokeServer(requestedRole, specimen)
        end)
        -- A timeout invalidates this response locally; it does not cancel the server's work.
        if destroyed or version ~= requestVersion then return end
        deploying = false
        view.buttons.Deploy.Label.Text = "Enter the field  →"
        if success and type(response) == "table" and response.ok then
            local playerScripts = player:WaitForChild("PlayerScripts")
            for _, template in ipairs(ReplicatedStorage.ClientDetails.Scripts.Dinos.PlayerScripts:GetChildren()) do
                local previous = playerScripts:FindFirstChild(template.Name)
                if previous and previous:GetAttribute("PGDinosaurController") then previous:Destroy() end
                if specimen then
                    local controller = template:Clone()
                    controller:SetAttribute("PGDinosaurController", true)
                    controller.Parent = playerScripts
                end
            end
            if specimen then
                menu.Main.DinosaurSelector.DinosaurSelection.MorphBasis.Value = specimen
            end
            view.root.Visible = false
            menu:SetAttribute("InField", true)
            view.notice.Text = "Press M in the field to reopen this menu."
            view.buttons.Close.Visible = true
            view.status.Visible = false
            updateMusic()
            playSound("EnterGame")
        else
            view.notice.Text = success and type(response) == "table" and type(response.message) == "string" and response.message
                or "Deployment failed. Please try again."
            playSound("Error")
        end
    end)
end

for name, control in pairs(view.buttons) do
    control.Activated:Connect(function()
        playSound("UIClick")
        if name == "Deploy" then
            deploy()
        elseif name == "Close" then
            view.root.Visible = false
            updateMusic()
        else
            showPage(name)
        end
    end)
    control.MouseEnter:Connect(function() playSound("Hover") end)
end
for name, control in pairs(view.roleButtons) do
    control.Activated:Connect(function()
        if deploying then return end
        selectRole(name)
        playSound("UIClick")
    end)
end
for name, control in pairs(view.specimenButtons) do
    control.Activated:Connect(function()
        if deploying then return end
        selectRole("DINOSAURS")
        deploy(name)
    end)
end
view.settings.Music.Activated:Connect(function()
    musicEnabled = not musicEnabled
    view.settings.Music.Label.Text = musicEnabled and "On" or "Off"
    updateMusic()
end)
view.settings.Motion.Label.Text = "Off"
view.settings.Motion.Activated:Connect(function()
    reducedMotion = not reducedMotion
    view.settings.Motion.Label.Text = reducedMotion and "On" or "Off"
    showPage(currentPage)
end)

-- Clone only geometry for the preview; executable scripts never enter the viewport.
local previewCamera
local previewCenter
local previewDistance
local sourceRig = workspace:FindFirstChild("EdmontosaurusMale")
if sourceRig then
    local model = sourceRig:Clone()
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound") then
            descendant:Destroy()
        elseif descendant:IsA("BasePart") then
            descendant.Anchored = true
        end
    end
    local world = Instance.new("WorldModel")
    world.Parent = view.preview
    model.Parent = world
    local boundingCFrame, bounds = model:GetBoundingBox()
    previewCenter = boundingCFrame.Position
    previewDistance = math.max(bounds.X, bounds.Y, bounds.Z) * 0.95
    previewCamera = Instance.new("Camera")
    previewCamera.FieldOfView = 35
    previewCamera.Parent = view.preview
    view.preview.CurrentCamera = previewCamera
end

-- Resize only when the viewport changes, including when Roblox replaces CurrentCamera.
local viewportConnection
local function bindViewport()
    if viewportConnection then viewportConnection:Disconnect() end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local function resize()
        view.scale.Scale = math.min(camera.ViewportSize.X / 1220, camera.ViewportSize.Y / 740)
    end
    viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
    resize()
end
local cameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport)
bindViewport()

local renderConnection = RunService.RenderStepped:Connect(function()
    if view.root.Visible and previewCamera then
        -- Sine bounds the orbit; lookAt keeps its focus at the rig's bounding-box center.
        -- Only the private preview camera moves, leaving the player's world camera untouched.
        local angle = reducedMotion and 0.65 or 0.65 + math.sin(os.clock() * 0.18) * 0.13
        local offset = Vector3.new(math.cos(angle), 0.24, math.sin(angle)) * previewDistance
        previewCamera.CFrame = CFrame.lookAt(previewCenter + offset, previewCenter)
    end
end)

local inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed or input.KeyCode ~= Enum.KeyCode.M or not menu:GetAttribute("InField") then return end
    view.root.Visible = not view.root.Visible
    updateMusic()
end)
menu.Destroying:Connect(function()
    -- Service events outlive this ScreenGui, so disconnect them explicitly on removal.
    destroyed = true
    requestVersion += 1
    renderConnection:Disconnect()
    inputConnection:Disconnect()
    cameraConnection:Disconnect()
    if viewportConnection then viewportConnection:Disconnect() end
    if transition then transition:Cancel() end
    if menuMusic then menuMusic:Stop() end
end)

view.buttons.Home.Modal = true
selectRole(selectedRole.Value)
showPage("Home")
updateMusic()
player:SetAttribute("PGMenuReady", true)
