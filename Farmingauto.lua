-- SETTINGS
getgenv().AutoFarm = false
getgenv().FastMode = false

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local Remotes = lp:WaitForChild("Remotes")
local EncounterRemote = Remotes:WaitForChild("DudeWhyld")

-- ALL AREAS
local Areas = {
    "Route_1","006_Route2","007_Lakewood","011_Sewer","010_Route3",
    "013_Route4","014_GraphiteLodge","017_Crossroads","018_CrystalCaverns",
    "020_GraphiteForest","022_ForestMaze","024_Route5","028_PirateCabin",
    "025_Sweetsville","031_CandyFactory"
}

-- GUI
local sg = Instance.new("ScreenGui", lp.PlayerGui)
sg.Name = "DoodleAuto"

local toggleBtn = Instance.new("TextButton", sg)
toggleBtn.Size = UDim2.new(0, 180, 0, 45)
toggleBtn.Position = UDim2.new(0, 30, 0.5, -50)
toggleBtn.Text = "AUTO FARM: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(150,30,30)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
Instance.new("UICorner", toggleBtn)

local modeBtn = Instance.new("TextButton", sg)
modeBtn.Size = UDim2.new(0, 180, 0, 35)
modeBtn.Position = UDim2.new(0, 30, 0.5, 5)
modeBtn.Text = "MODE: SAFE"
modeBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
modeBtn.TextColor3 = Color3.new(1,1,1)
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 14
Instance.new("UICorner", modeBtn)

-- AUTO FARM LOOP
task.spawn(function()
    while true do
        task.wait(getgenv().FastMode and 0.5 or 1)
        if getgenv().AutoFarm then
            for _, area in ipairs(Areas) do
                if not getgenv().AutoFarm then break end
                local success, err = pcall(function()
                    EncounterRemote:FireServer(area, "WildGrass")
                end)
                if not success then warn("Failed to fire remote:", err) end
                task.wait(getgenv().FastMode and 0.5 or 1)
            end
        end
    end
end)

-- BUTTONS
toggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    toggleBtn.Text = getgenv().AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    toggleBtn.BackgroundColor3 = getgenv().AutoFarm and Color3.fromRGB(0,150,70) or Color3.fromRGB(150,30,30)
end)

modeBtn.MouseButton1Click:Connect(function()
    getgenv().FastMode = not getgenv().FastMode
    modeBtn.Text = getgenv().FastMode and "MODE: FAST (0.5s)" or "MODE: SAFE (1s)"
    modeBtn.BackgroundColor3 = getgenv().FastMode and Color3.fromRGB(200,100,0) or Color3.fromRGB(50,50,50)
end)
