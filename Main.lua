-- TridentWave Menu v1.0 🇹🇷
setfflag("DebugRunParallelLuaOnMainThread", "True")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки
local Settings = {
    ESP = true,
    SilentAim = true,
    ShowFOV = true,
    FOV = 150,
    FOVColor = Color3.new(1,1,1),
    TargetNames = {"Player", "Solidar", "GasMasker", "Officer"},
    MenuVisible = true
}

-- UI создание
local Library = {}
do
    local UserInputService = UIS
    local RunService = RunService
    local TweenService = game:GetService("TweenService")
    local GuiService = game:GetService("GuiService")

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TridentWaveMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 280, 0, 360)
    Frame.Position = UDim2.new(0, 20, 0, 100)
    Frame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    Frame.Active = true
    Frame.Draggable = true

    -- Заголовок с флагом Турции (прямоугольник + полумесяц + звезда)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(220, 20, 60) -- красный
    Header.Parent = Frame

    local FlagRect = Instance.new("Frame")
    FlagRect.Size = UDim2.new(0, 60, 0, 30)
    FlagRect.Position = UDim2.new(0, 10, 0, 5)
    FlagRect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FlagRect.Parent = Header
    FlagRect.AnchorPoint = Vector2.new(0, 0)

    local Moon = Instance.new("TextLabel")
    Moon.Size = UDim2.new(0, 30, 0, 30)
    Moon.Position = UDim2.new(0, 10, 0, 0)
    Moon.BackgroundTransparency = 1
    Moon.Text = "◐"
    Moon.Font = Enum.Font.SourceSansBold
    Moon.TextColor3 = Color3.fromRGB(220, 20, 60)
    Moon.TextScaled = true
    Moon.Parent = FlagRect

    local Star = Instance.new("TextLabel")
    Star.Size = UDim2.new(0, 30, 0, 30)
    Star.Position = UDim2.new(0, 18, 0, 0)
    Star.BackgroundTransparency = 1
    Star.Text = "★"
    Star.Font = Enum.Font.SourceSansBold
    Star.TextColor3 = Color3.fromRGB(220, 20, 60)
    Star.TextScaled = true
    Star.Parent = FlagRect

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 70, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "TridentWave"
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextScaled = true
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    -- Функция создания чекбокса
    function Library.CreateCheckbox(text, initial, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundTransparency = 1
        container.Parent = Frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -40, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = Enum.Font.SourceSans
        label.TextColor3 = Color3.fromRGB(30, 30, 30)
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local box = Instance.new("TextButton")
        box.Size = UDim2.new(0, 25, 0, 25)
        box.Position = UDim2.new(1, -35, 0, 2)
        box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        box.BorderColor3 = Color3.fromRGB(200, 200, 200)
        box.Text = ""
        box.Parent = container

        local checked = initial
        local function updateBox()
            if checked then
                box.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                box.Text = "✓"
                box.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                box.Text = ""
            end
        end
        updateBox()

        box.MouseButton1Click:Connect(function()
            checked = not checked
            updateBox()
            callback(checked)
        end)
        return container
    end

    -- Функция создания ползунка
    function Library.CreateSlider(text, min, max, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 50)
        container.BackgroundTransparency = 1
        container.Parent = Frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(default)
        label.Font = Enum.Font.SourceSans
        label.TextColor3 = Color3.fromRGB(30, 30, 30)
        label.TextScaled = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local slider = Instance.new("TextButton")
        slider.Size = UDim2.new(1, -20, 0, 20)
        slider.Position = UDim2.new(0, 10, 0, 25)
        slider.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        slider.BorderSizePixel = 0
        slider.Text = ""
        slider.Parent = container

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        fill.Parent = slider

        local dragging = false
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        slider.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relativeX = math.clamp(input.Position.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
                local value = math.floor((relativeX / slider.AbsoluteSize.X) * (max - min) + min)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                label.Text = text .. ": " .. tostring(value)
                callback(value)
            end
        end)

        return container
    end

    Library.ScreenGui = ScreenGui
    Library.Frame = Frame
end

-- Создаем UI элементы
local y = 50
local function addElement(el)
    el.Position = UDim2.new(0, 0, 0, y)
    y = y + el.AbsoluteSize.Y + 5
end

local espCheckbox = Library.CreateCheckbox("ESP", Settings.ESP, function(state)
    Settings.ESP = state
end)
addElement(espCheckbox)

local silentAimCheckbox = Library.CreateCheckbox("SilentAim", Settings.SilentAim, function(state)
    Settings.SilentAim = state
end)
addElement(silentAimCheckbox)

local fovCheckbox = Library.CreateCheckbox("Показывать FOV", Settings.ShowFOV, function(state)
    Settings.ShowFOV = state
end)
addElement(fovCheckbox)

local fovSlider = Library.CreateSlider("FOV радиус", 10, 500, Settings.FOV, function(value)
    Settings.FOV = value
    fovCircle.Radius = value
end)
addElement(fovSlider)

-- FOV КРУГ
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = Settings.FOV
fovCircle.Thickness = 2
fovCircle.Transparency = 1
fovCircle.Color = Settings.FOVColor
fovCircle.Filled = false
fovCircle.Visible = Settings.ShowFOV

-- ESP ЛОГИКА
local espTable = {}
local function isValidTarget(model)
    if not model or not model:FindFirstChild("HumanoidRootPart") then return false end
    for _, name in ipairs(Settings.TargetNames) do
        if string.find(model.Name, name) then
            return true
        end
    end
    return false
end

local Camera = workspace.CurrentCamera
RunService.RenderStepped:Connect(function()
    local mousePos = UIS:GetMouseLocation()
    fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    fovCircle.Visible = Settings.ShowFOV

    for model, text in pairs(espTable) do
        if model and model:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Camera:WorldToViewportPoint(model.HumanoidRootPart.Position)
            if visible and Settings.ESP then
                text.Position = Vector2.new(pos.X, pos.Y - 20)
                text.Text = "[" .. model.Name .. "]"
                text.Visible = true
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if isValidTarget(obj) and not espTable[obj] then
                espTable[obj] = Drawing.new("Text")
                espTable[obj].Size = 16
                espTable[obj].Center = true
                espTable[obj].Outline = true
                espTable[obj].Color = Color3.new(1, 1, 1)
                espTable[obj].Visible = false
            end
        end
    end
end)

-- SilentAim логика
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if Settings.SilentAim and tostring(self):lower():find("shoot") and method == "FireServer" then
        local closest, dist = nil, Settings.FOV
        for _, obj in ipairs(workspace:GetDescendants()) do
            if isValidTarget(obj) then
                local pos, visible = Camera:WorldToViewportPoint(obj.HumanoidRootPart.Position)
                if visible then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then
                        closest = obj
                        dist = mag
                    end
                end
            end
        end
        if closest then
            args[1] = closest.HumanoidRootPart.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

print("✅ TridentWave Menu Loaded")
