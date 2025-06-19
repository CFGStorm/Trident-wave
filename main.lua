setfflag("DebugRunParallelLuaOnMainThread", "True")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = true,
    SilentAim = true,
    ShowFOV = true,
    FOV = 150,
    FOVColor = Color3.new(1, 1, 1),
    TargetNames = {"Player", "Solidar", "GasMasker", "Officer"}
}

local fovCircle = Drawing.new("Circle")
fovCircle.Radius = Settings.FOV
fovCircle.Thickness = 2
fovCircle.Transparency = 1
fovCircle.Color = Settings.FOVColor
fovCircle.Filled = false
fovCircle.Visible = Settings.ShowFOV

local function createESP(target)
    local box = Drawing.new("Text")
    box.Size = 16
    box.Center = true
    box.Outline = true
    box.Color = Color3.new(1, 1, 1)
    box.Visible = false
    return box
end

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

local function getClosestTarget()
    local closest, dist = nil, Settings.FOV
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isValidTarget(obj) then
            local pos, visible = Camera:WorldToViewportPoint(obj.HumanoidRootPart.Position)
            if visible then
                local magnitude = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if magnitude < dist then
                    closest = obj
                    dist = magnitude
                end
            end
        end
    end
    return closest
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if Settings.SilentAim and tostring(self):lower():find("shoot") and method == "FireServer" then
        local target = getClosestTarget()
        if target then
            args[1] = target.HumanoidRootPart.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

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
                espTable[obj] = createESP(obj)
            end
        end
    end
end)

print("✅ TridentWave Hook Loaded")
