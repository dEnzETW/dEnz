-- rEm_EatGrab_Sell_Test.lua
-- Standalone EAT + GRAB + Auto-Sell-on-full test.
-- Separate from ETW.DRAMA; intended for a private/test environment only.
-- Uses the same general bar-detection and Sell-event approach found in rEm.lua.
-- Status messages report local detection/call attempts, not server-confirmed success.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local eatGrabRunning = false
local autoSellEnabled = false
local eatGrabConnection = nil
local sellConnection = nil
local isSelling = false
local cachedBar = nil
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

local function findBar()
    if cachedBar and cachedBar.Parent then
        return cachedBar
    end
    cachedBar = nil
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, obj in ipairs(playerGui:GetDescendants()) do
            if obj:IsA("Frame") then
                local name = string.lower(obj.Name)
                if string.find(name, "bar", 1, true) or string.find(name, "meter", 1, true) then
                    cachedBar = obj
                    return obj
                end
            end
        end
    end
    return nil
end

local function getSellEvent()
    local character = LocalPlayer.Character
    local events = character and character:FindFirstChild("Events")
    local sell = events and events:FindFirstChild("Sell")
    if sell and sell:IsA("RemoteEvent") then
        return sell
    end
    return nil
end

local function stopEatGrab()
    eatGrabRunning = false
    if eatGrabConnection then
        eatGrabConnection:Disconnect()
        eatGrabConnection = nil
    end
    setStatus(autoSellEnabled and "EAT/GRAB: OFF | AUTO-SELL: ON" or "EAT/GRAB: OFF | AUTO-SELL: OFF")
end

local function startEatGrab()
    if eatGrabRunning then return end
    eatGrabRunning = true
    setStatus("EAT/GRAB: ON | AUTO-SELL: " .. (autoSellEnabled and "ON" or "OFF"))

    -- Match rEm.lua timing: process the Eat/Grab events on each Heartbeat.
    -- Note: this can send frequent RemoteEvent calls; use only in a test place
    -- you control and stop the loop if the game becomes unstable.
    eatGrabConnection = RunService.Heartbeat:Connect(function()
        if not eatGrabRunning then return end

        local character, eatEvent, grabEvent = getCharacterEvents()
        if not character then
            setStatus("Waiting for character...")
            return
        end

        local sentEat, sentGrab = false, false
        if grabEvent and grabEvent:IsA("RemoteEvent") then
            sentGrab = pcall(function()
                grabEvent:FireServer(false, false, false)
            end)
        end
        if eatEvent and eatEvent:IsA("RemoteEvent") then
            sentEat = pcall(function()
                eatEvent:FireServer()
            end)
        end

        if sentEat and sentGrab then
            setStatus("EAT/GRAB: ON | AUTO-SELL: " .. (autoSellEnabled and "ON" or "OFF"))
        elseif sentEat or sentGrab then
            setStatus("One event sent; check game behavior")
        else
            setStatus("Eat/Grab event not found")
        end
    end)
end

local function setAutoSell(enabled)
    autoSellEnabled = enabled
    if enabled then
        if not sellConnection then
            local elapsed = 0
            sellConnection = RunService.Heartbeat:Connect(function(dt)
                if not autoSellEnabled or isSelling then return end
                elapsed += dt
                if elapsed < 0.2 then return end
                elapsed = 0

                local bar = findBar()
                if not bar then
                    setStatus("AUTO-SELL: ON | bar not found")
                    return
                end

                -- Matches the source script's scale-based full-bar check.
                if bar.Size.X.Scale >= 0.999 then
                    local sellEvent = getSellEvent()
                    if sellEvent then
                        isSelling = true
                        local ok = pcall(function()
                            sellEvent:FireServer()
                        end)
                        setStatus(ok and "Bar full — sell event sent" or "Sell call failed")
                        task.delay(0.6, function()
                            isSelling = false
                            cachedBar = nil
                        end)
                    else
                        setStatus("Bar full, but Sell event not found")
                    end
                end
            end)
        end
        setStatus("EAT/GRAB: " .. (eatGrabRunning and "ON" or "OFF") .. " | AUTO-SELL: ON")
    else
        if sellConnection then
            sellConnection:Disconnect()
            sellConnection = nil
        end
        isSelling = false
        setStatus("EAT/GRAB: " .. (eatGrabRunning and "ON" or "OFF") .. " | AUTO-SELL: OFF")
    end
end

local function makeButton(parent, name, text, y, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = parent
    button.Position = UDim2.new(0, 10, 0, y)
    button.Size = UDim2.new(1, -20, 0, 34)
    button.BackgroundColor3 = Color3.fromRGB(7, 37, 45)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
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
screenGui.Name = "rEm_EatGrab_Sell_Test"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Parent = screenGui
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0, 270, 0, 220)
panel.BackgroundColor3 = Color3.fromRGB(4, 10, 15)
panel.BackgroundTransparency = 0.08
panel.Active = true
panel.Draggable = true -- draggable panel, including on older Roblox UI behavior

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
title.Position = UDim2.new(0, 10, 0, 5)
title.Size = UDim2.new(1, -20, 0, 24)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "EAT / GRAB + AUTO-SELL"
title.TextXAlignment = Enum.TextXAlignment.Left

makeButton(panel, "StartButton", "START EAT + GRAB", 34, startEatGrab)
makeButton(panel, "StopButton", "STOP EAT + GRAB", 72, stopEatGrab)
makeButton(panel, "AutoSellButton", "AUTO-SELL WHEN BAR FULL: OFF", 110, function()
    setAutoSell(not autoSellEnabled)
    local button = panel:FindFirstChild("AutoSellButton")
    if button then
        button.Text = "AUTO-SELL WHEN BAR FULL: " .. (autoSellEnabled and "ON" or "OFF")
    end
end)

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Parent = panel
status.BackgroundTransparency = 1
status.Position = UDim2.new(0, 10, 0, 151)
status.Size = UDim2.new(1, -20, 0, 55)
status.Font = Enum.Font.GothamSemibold
status.TextSize = 10
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(220, 245, 250)
status.Text = "EAT/GRAB: OFF | AUTO-SELL: OFF"
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top

local camera = workspace.CurrentCamera
if camera then
    local viewport = camera.ViewportSize
    if viewport.X < 420 then
        panel.Size = UDim2.new(0, math.max(230, viewport.X - 24), 0, 220)
    end
end

screenGui.Destroying:Connect(function()
    stopEatGrab()
    setAutoSell(false)
end)
