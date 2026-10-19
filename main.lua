
-- dEnz Mini Control Panel
-- Untuk latihan GUI di lingkungan Roblox milik sendiri

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("dEnzGUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "dEnzGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Tombol kecil untuk buka/tutup panel
local toggle = Instance.new("TextButton")
toggle.Name = "OpenControl"
toggle.Size = UDim2.fromOffset(105, 30)
toggle.Position = UDim2.new(0, 12, 0.35, 0)
toggle.BackgroundColor3 = Color3.fromRGB(35, 120, 210)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Text = "dEnz  [≡]"
toggle.TextSize = 13
toggle.Parent = gui

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 7)
tc.Parent = toggle

-- Control panel kecil
local panel = Instance.new("Frame")
panel.Name = "ControlPanel"
panel.Size = UDim2.fromOffset(180, 160)
panel.Position = UDim2.new(0, 12, 0.35, 38)
panel.BackgroundColor3 = Color3.fromRGB(27, 29, 38)
panel.Visible = false
panel.Parent = gui

local pc = Instance.new("UICorner")
pc.CornerRadius = UDim.new(0, 8)
pc.Parent = panel

local heading = Instance.new("TextLabel")
heading.Size = UDim2.new(1, -12, 0, 28)
heading.Position = UDim2.fromOffset(6, 3)
heading.BackgroundTransparency = 1
heading.Text = "CONTROL PANEL"
heading.TextColor3 = Color3.new(1, 1, 1)
heading.TextSize = 13
heading.Font = Enum.Font.GothamBold
heading.Parent = panel

toggle.Activated:Connect(function()
    panel.Visible = not panel.Visible
end)

local function makeButton(name, y)
    local active = false
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -16, 0, 30)
    button.Position = UDim2.fromOffset(8, y)
    button.BackgroundColor3 = Color3.fromRGB(65, 68, 82)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12
    button.Text = name .. ": OFF"
    button.Parent = panel

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = button

    button.Activated:Connect(function()
        active = not active
        button.Text = name .. (active and ": ON" or ": OFF")
        button.BackgroundColor3 = active
            and Color3.fromRGB(30, 145, 90)
            or Color3.fromRGB(65, 68, 82)
        print(name .. ": " .. (active and "ON" or "OFF"))
    end)
end

makeButton("Auto Eat", 35)
makeButton("Auto Sell", 69)
makeButton("Auto Collect", 103)
