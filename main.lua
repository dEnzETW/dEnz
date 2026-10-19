
-- dEnz GUI
-- Letakkan sebagai LocalScript di StarterPlayerScripts
-- Untuk game milik sendiri di Roblox Studio

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "dEnzGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 230, 0, 190)
panel.Position = UDim2.new(0.5, -115, 0.5, -95)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "dEnz GUI"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextSize = 22
title.Parent = panel

local function buatTombol(nama, posisi)
    local aktif = false

    local tombol = Instance.new("TextButton")
    tombol.Size = UDim2.new(0, 200, 0, 35)
    tombol.Position = UDim2.new(0, 15, 0, posisi)
    tombol.Text = nama .. ": OFF"
    tombol.TextSize = 16
    tombol.Parent = panel

    tombol.Activated:Connect(function()
        aktif = not aktif
        tombol.Text = nama .. (aktif and ": ON" or ": OFF")
        print(nama, aktif and "ON" or "OFF")
    end)
end

buatTombol("Auto Eat", 45)
buatTombol("Auto Sell", 90)
buatTombol("Auto Collect", 135)
