
-- dEnz GUI Test
-- GUI latihan untuk Roblox Studio

local aktif = {
    Eat = false,
    Sell = false,
    Collect = false
}

local function ubahStatus(nama)
    aktif[nama] = not aktif[nama]
    print(nama .. ": " .. (aktif[nama] and "ON" or "OFF"))
end

-- Tes logika tombol di Lua
ubahStatus("Eat")
ubahStatus("Sell")
ubahStatus("Collect")
