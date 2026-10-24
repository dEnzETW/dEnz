
-- rEm_EatGrab_Test.lua
-- Standalone EAT/GRAB test for a private/test environment.
-- This is intentionally separate from ETW.DRAMA.
-- It does NOT include the source script's whitelist, giant platform,
-- speed/teleport, ESP, anti-ragdoll, sell, or attack features.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local running = false
local connection = nil
local screenGui

local function getCharacterEvents()
    local character = LocalPlayer.Character
    if not character then
        return nil, nil, nil
    end

    local events = character:FindFirstChild("Events")
    if not events then
        return character, nil, nil
    end

    return character, events:FindFirstChild("Eat"), events:FindFirstChild("Grab")
end

local function setStatus(text)
    if screenGui and screenGui:FindFirstChild("Panel") then
        local status = screenGui.Panel:FindFirstChild("Status")
        if status then status.Text = text end
    end
end

local function stopTest()
    running = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
    setStatus("Status: OFF")
end

local function startTest()
    if running then return end
    running = true
    setStatus("Status: ON — checking character events")

    -- Throttled test loop instead of firing remotes every Heartbeat.
    local elapsed = 0
    connection = RunService.Heartbeat:Connect(function(dt)
        if not running then return end
        elapsed += dt
        if elapsed < 0.25 then return end
        elapsed = 0

        local character, eatEvent, grabEvent = getCharacterEvents()
        if not character then
            setStatus("Status: waiting for character")
            return
        end

        local firedEat, firedGrab = false, false

        if grabEvent and grabEvent:IsA("RemoteEvent") then
            local ok = pcall(function()
                grabEvent:FireServer(false, false, false)
            end)
            firedGrab = ok
        end

        if eatEvent and eatEvent:IsA("RemoteEvent") then
            local ok = pcall(function()
                eatEvent:FireServer()
            end)
            firedEat = ok
        end

        if firedEat and firedGrab then
            setStatus("Status: ON — Eat + Grab events sent")
        elseif firedEat then
            setStatus("Status: ON — Eat sent; Grab event missing")
        elseif firedGrab then
            setStatus("Status: ON — Grab sent; Eat event missing")
        else
            setStatus("Status: ON — Eat/Grab RemoteEvent not found")
        end
    end)
end

local function makeButton(parent, text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = text:gsub("%W", "") .. "Button"
    button.Parent = parent
    button.Position = position
    button.Size = UDim2.new(1, -20, 0, 38)
    button.BackgroundColor3 = Color3.fromRGB(7, 37, 45)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Text = text
    button.AutoButtonColor = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 225, 245)
    stroke.Thickness = 1.5
    stroke.Parent = button

    button.Activated:Connect(callback)
    return button
end

screenGui = Instance.new("ScreenGui")
screenGui.Name = "rEm_EatGrab_Test"
screenGui.ResetOnSpawn = false

local okParent = pcall(function()
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)
if not okParent then
    warn("Could not create test UI in PlayerGui.")
    return
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Parent = screenGui
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0, 250, 0, 174)
panel.BackgroundColor3 = Color3.fromRGB(4, 10, 15)
panel.BackgroundTransparency = 0.08
panel.Active = true

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(0, 225, 245)
panelStroke.Thickness = 2
panelStroke.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = panel
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 6)
title.Size = UDim2.new(1, -20, 0, 26)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "EAT / GRAB TEST"
title.TextXAlignment = Enum.TextXAlignment.Left

makeButton(panel, "START EAT + GRAB", UDim2.new(0, 10, 0, 38), startTest)
makeButton(panel, "STOP", UDim2.new(0, 10, 0, 82), stopTest)

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Parent = panel
status.BackgroundTransparency = 1
status.Position = UDim2.new(0, 10, 0, 126)
status.Size = UDim2.new(1, -20, 0, 34)
status.Font = Enum.Font.GothamSemibold
status.TextSize = 10
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(210, 245, 250)
status.Text = "Status: OFF"
status.TextXAlignment = Enum.TextXAlignment.Left

-- Keep the panel on-screen on small displays.
local camera = workspace.CurrentCamera
if camera then
    local viewport = camera.ViewportSize
    if viewport.X < 400 then
        panel.Size = UDim2.new(0, math.max(220, viewport.X - 24), 0, 174)
    end
end

-- Cleanup if the test UI is removed.
screenGui.Destroying:Connect(stopTest)
