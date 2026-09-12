-- Builds the interface. Navigation and deployment live in MenuController.
local TweenService = game:GetService("TweenService")

local MenuView = {}
local Colors = {
    background = Color3.fromRGB(17, 28, 28),
    panel = Color3.fromRGB(25, 39, 38),
    text = Color3.fromRGB(232, 236, 222),
    muted = Color3.fromRGB(150, 170, 159),
    accent = Color3.fromRGB(186, 217, 128),
}

local function create(className, parent, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    instance.Parent = parent
    return instance
end

local function frame(parent, name, x, y, width, height, color)
    return create("Frame", parent, {
        Name = name,
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = color or Colors.panel,
        BackgroundTransparency = color and 0 or 1,
        BorderSizePixel = 0,
    })
end

local function label(parent, name, text, x, y, width, height, size, color)
    return create("TextLabel", parent, {
        Name = name,
        Text = text,
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height),
        TextSize = size or 14,
        Font = Enum.Font.Gotham,
        TextColor3 = color or Colors.text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    })
end

local function rule(parent, x, y, width)
    local line = frame(parent, "Rule", x, y, width, 1, Colors.muted)
    line.BackgroundTransparency = 0.78
end

local function button(parent, name, text, x, y, width, height, primary)
    local control = create("TextButton", parent, {
        Name = name,
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height),
        Text = "",
        BackgroundColor3 = primary and Colors.accent or Colors.panel,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    })
    label(control, "Label", text, 18, 0, width - 36, height, 15,
        primary and Colors.background or Colors.text)
    create("UIStroke", control, {
        Color = Colors.muted,
        Transparency = primary and 1 or 0.7,
        Thickness = 1,
    })
    local function hover(active)
        TweenService:Create(control, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
            BackgroundColor3 = active
                and (primary and Color3.fromRGB(210, 234, 166) or Color3.fromRGB(42, 61, 55))
                or (primary and Colors.accent or Colors.panel),
        }):Play()
    end
    control.MouseEnter:Connect(function() hover(true) end)
    control.MouseLeave:Connect(function() hover(false) end)
    control.SelectionGained:Connect(function() hover(true) end)
    control.SelectionLost:Connect(function() hover(false) end)
    return control
end

function MenuView.Create(menu)
    local view = { buttons = {}, pages = {}, settings = {} }
    local surface = create("Frame", menu, {
        Name = "FieldMenu",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.background,
        BorderSizePixel = 0,
        ZIndex = 20,
    })
    view.root = surface
    local canvas = create("CanvasGroup", surface, {
        Name = "Canvas",
        Size = UDim2.fromOffset(1180, 700),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1,
    })
    local scale = create("UIScale", canvas, { Scale = 1 })
    view.canvas = canvas
    view.scale = scale

    label(canvas, "Mark", "PG", 40, 26, 65, 48, 34, Colors.accent).Font = Enum.Font.GothamBold
    label(canvas, "Brand", "PARADOX GENETICS", 118, 30, 410, 24, 15)
    label(canvas, "Edition", "FIELD OPERATIONS / TECH SHOWCASE", 118, 56, 470, 18, 10, Colors.muted)
    view.status = label(canvas, "Status", "LOCAL SESSION", 860, 38, 280, 30, 11, Colors.muted)
    view.status.TextXAlignment = Enum.TextXAlignment.Right
    view.buttons.Close = button(canvas, "ReturnToField", "Return to field  →", 895, 33, 245, 40)
    view.buttons.Close.Visible = false
    rule(canvas, 40, 98, 1100)

    local navigation = { {"Home", "Overview"}, {"Roles", "Choose role"}, {"Specimens", "Specimen index"}, {"Settings", "Preferences"} }
    for index, item in ipairs(navigation) do
        local control = button(canvas, item[1], item[2], 40 + (index - 1) * 278, 116, 266, 38)
        control.Label.TextSize = 13
        view.buttons[item[1]] = control
    end

    for _, name in ipairs({"Home", "Roles", "Specimens", "Settings"}) do
        view.pages[name] = frame(canvas, name, 40, 176, 1100, 430)
        view.pages[name].Visible = false
    end

    local home = view.pages.Home
    label(home, "Eyebrow", "ISLA ACHERON / OPERATIONS BRIEF", 0, 6, 500, 22, 11, Colors.accent)
    label(home, "Title", "Beyond the\nperimeter.", -3, 40, 570, 134, 57).TextYAlignment = Enum.TextYAlignment.Top
    local summary = label(home, "Summary", "Explore the facility, select your role, or enter the field as a dinosaur.", 0, 188, 430, 66, 17, Colors.muted)
    summary.TextWrapped = true
    summary.TextYAlignment = Enum.TextYAlignment.Top
    view.buttons.Deploy = button(home, "Deploy", "Enter the field  →", 0, 285, 290, 56, true)
    view.role = label(home, "SelectedRole", "Selected role: Test subjects", 0, 357, 485, 24, 13, Colors.muted)
    label(home, "RoleHint", "Change your role above before deploying.", 0, 386, 480, 20, 11, Colors.muted)

    local specimenPanel = frame(home, "SpecimenPanel", 560, 0, 540, 430, Colors.panel)
    label(specimenPanel, "Index", "SPECIMEN 01", 24, 20, 270, 24, 11, Colors.accent)
    label(specimenPanel, "Name", "EDMONTOSAURUS", 24, 342, 480, 33, 25)
    label(specimenPanel, "Classification", "HERBIVORE / FIELD COLLECTION", 24, 382, 480, 22, 11, Colors.muted)
    rule(specimenPanel, 24, 329, 492)
    view.preview = create("ViewportFrame", specimenPanel, {
        Name = "SpecimenPreview",
        Position = UDim2.fromOffset(10, 42),
        Size = UDim2.fromOffset(520, 285),
        BackgroundTransparency = 1,
        Ambient = Color3.fromRGB(180, 195, 172),
        LightColor = Color3.fromRGB(240, 244, 223),
        LightDirection = Vector3.new(-1, -1, -1),
    })

    local roles = view.pages.Roles
    label(roles, "Title", "Choose your role", 0, 0, 800, 54, 36)
    label(roles, "Hint", "Access requirements are checked before deployment.", 0, 65, 1000, 26, 14, Colors.muted)
    view.roleButtons = {}
    local roleOptions = {
        {"TEST SUBJECTS", "Test subjects", "Enter the facility as a human participant."},
        {"DINOSAURS", "Dinosaurs", "Choose a specimen and explore on foot."},
        {"PARADOX GENETICS", "Paradox Genetics", "Staff access. Group membership and rank required."},
    }
    for index, entry in ipairs(roleOptions) do
        local y = 112 + (index - 1) * 97
        local control = button(roles, entry[1], entry[2], 0, y, 1100, 80)
        control.Label.Position = UDim2.fromOffset(22, 6)
        control.Label.Size = UDim2.fromOffset(990, 30)
        control.Label.TextSize = 20
        label(control, "Description", entry[3], 22, 43, 1000, 22, 13, Colors.muted)
        view.roleButtons[entry[1]] = control
    end

    local specimens = view.pages.Specimens
    label(specimens, "Title", "Specimen index", 0, 0, 900, 54, 36)
    label(specimens, "Hint", "Available field rigs / select a specimen to deploy as a dinosaur", 0, 65, 1050, 26, 14, Colors.muted)
    view.specimenButtons = {}
    for index, name in ipairs({"Edmontosaurus", "Suchomimus", "Padillasaurus"}) do
        local control = button(specimens, name, name, (index - 1) * 374, 130, 352, 180)
        control.Label.Position = UDim2.fromOffset(22, 63)
        control.Label.TextSize = 23
        label(control, "Number", string.format("%02d / SPECIMEN", index), 22, 22, 308, 24, 11, Colors.accent)
        label(control, "Action", "Deploy male rig  →", 22, 140, 308, 24, 13, Colors.muted)
        view.specimenButtons[name] = control
    end

    local settings = view.pages.Settings
    label(settings, "Title", "Preferences", 0, 0, 800, 54, 36)
    label(settings, "Hint", "These settings apply to the current session.", 0, 65, 1000, 26, 14, Colors.muted)
    for index, setting in ipairs({{"Music", "Menu music"}, {"Motion", "Reduced motion"}}) do
        local y = 130 + (index - 1) * 110
        label(settings, setting[1], setting[2], 0, y, 620, 42, 21)
        view.settings[setting[1]] = button(settings, setting[1] .. "Toggle", "On", 870, y, 230, 45)
        rule(settings, 0, y + 76, 1100)
    end

    rule(canvas, 40, 630, 1100)
    view.notice = label(canvas, "Notice", "Choose a role to begin.", 40, 647, 850, 25, 12, Colors.muted)
    label(canvas, "Build", "PG TECH / 01", 940, 647, 200, 25, 11, Colors.muted).TextXAlignment = Enum.TextXAlignment.Right
    return view
end

return MenuView
