-- Prevent AFK Kick
for _,v in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
    v:Disable()
end

-- Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Client = require(Player.Packer.Client)

-- GLOBAL SETTINGS
getgenv().Settings = {
    Enabled = false,
    FastForward = true,
    RebattlerFarm = false,
    AutoHeal = true,
    MinStars = 3,
    TargetDoodle = "",
    Misprint = false
}

-- FAST FORWARD PATCH
task.spawn(function()
    repeat task.wait() until Client.Utilities and Client.Utilities.Halt
    Client.Utilities.Halt = function(t)
        if getgenv().Settings.FastForward then
            local gui = Player.PlayerGui:FindFirstChild("MainGui")
            local inBattle = gui and gui.MainBattle and gui.MainBattle.Visible
            if inBattle then
                task.wait(getgenv().Settings.RebattlerFarm and 0.025 or 0)
                return
            end
            if t and t >= 2 then
                task.wait(0.01)
                return
            end
        end
        task.wait(t or 0.03)
    end
    Client.Camera.Zoom = function() end
end)

-- BATTLE HANDLER
local function HandleBattle()
    local battle = Client.Battle.CurrentBattle
    if not battle then return end

    local MainGui = Player.PlayerGui:WaitForChild("MainGui",5)
    if not MainGui then return end
    local BattleGui = MainGui:WaitForChild("MainBattle",5)
    if not BattleGui then return end

    local timeout = os.clock()
    repeat task.wait()
    until BattleGui.BottomBar.Actions.Visible
        or not Client.Battle.CurrentBattle
        or os.clock() - timeout > 5

    if not Client.Battle.CurrentBattle then return end

    -- Detect sides
    local myParty, enemyParty
    if battle.Player1 == Player then
        myParty = battle.Player1Party
        enemyParty = battle.Player2Party
    else
        myParty = battle.Player2Party
        enemyParty = battle.Player1Party
    end

    local MyDoodle = myParty[1]
    local Enemy = enemyParty[1]
    if not MyDoodle or not Enemy then return end

    -- Match logic
    local nameMatch =
        getgenv().Settings.TargetDoodle == "" or
        string.lower(Enemy.Name) == string.lower(getgenv().Settings.TargetDoodle)
    local starMatch = Enemy.Star >= getgenv().Settings.MinStars
    local misprintMatch = not getgenv().Settings.Misprint or Enemy.Shiny

    if nameMatch and starMatch and misprintMatch then
        getgenv().Settings.Enabled = false
        warn("MATCH FOUND:", Enemy.Name, Enemy.Star)
        return
    end

    -- Action
    if getgenv().Settings.RebattlerFarm then
        Client.Network:post("BattleAction",{
            [1] = {
                ActionType = "Attack",
                Action = MyDoodle.Moves[1].Name,
                Target = Enemy.ID,
                User = MyDoodle.ID
            }
        })
    else
        Client.Network:post("BattleAction",{
            [1] = {
                ActionType = "Run",
                User = MyDoodle.ID
            }
        })
    end

    task.wait(0.4)
end

-- GUI
local Gui = Instance.new("ScreenGui", Player.PlayerGui)
Gui.Name = "AidezReborn"

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0,350,0,500)
Main.Position = UDim2.new(0.3,0,0.2,0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.BorderSizePixel = 2
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,50)
Title.Text = "Aidez Reborn: Pro Edition"
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- Search Box
local SearchBox = Instance.new("TextBox", Main)
SearchBox.Size = UDim2.new(0.9,0,0,45)
SearchBox.Position = UDim2.new(0.05,0,0,65)
SearchBox.PlaceholderText = "Type Doodle Name..."
SearchBox.Text = ""
SearchBox.TextSize = 16
SearchBox.BackgroundColor3 = Color3.fromRGB(15,15,15)
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    getgenv().Settings.TargetDoodle = SearchBox.Text
end)

-- Star Control
local StarLabel = Instance.new("TextLabel", Main)
StarLabel.Size = UDim2.new(0.9,0,0,30)
StarLabel.Position = UDim2.new(0.05,0,0,115)
StarLabel.Text = "Minimum Stars: 3"
StarLabel.TextSize = 18
StarLabel.BackgroundTransparency = 1
StarLabel.TextColor3 = Color3.new(1,1,1)

local StarMinus = Instance.new("TextButton", Main)
StarMinus.Size = UDim2.new(0.43,0,0,40)
StarMinus.Position = UDim2.new(0.05,0,0,150)
StarMinus.Text = "- Star"
StarMinus.TextSize = 16
StarMinus.BackgroundColor3 = Color3.fromRGB(55,55,55)
StarMinus.TextColor3 = Color3.new(1,1,1)
StarMinus.MouseButton1Click:Connect(function()
    getgenv().Settings.MinStars = math.max(1, getgenv().Settings.MinStars - 1)
    StarLabel.Text = "Minimum Stars: "..getgenv().Settings.MinStars
end)

local StarPlus = Instance.new("TextButton", Main)
StarPlus.Size = UDim2.new(0.43,0,0,40)
StarPlus.Position = UDim2.new(0.52,0,0,150)
StarPlus.Text = "+ Star"
StarPlus.TextSize = 16
StarPlus.BackgroundColor3 = Color3.fromRGB(55,55,55)
StarPlus.TextColor3 = Color3.new(1,1,1)
StarPlus.MouseButton1Click:Connect(function()
    getgenv().Settings.MinStars = math.min(6, getgenv().Settings.MinStars + 1)
    StarLabel.Text = "Minimum Stars: "..getgenv().Settings.MinStars
end)

-- Toggle Creator
local function CreateToggle(text, pos, key)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9,0,0,45)
    btn.Position = UDim2.new(0.05,0,0,pos)
    btn.Text = text..": OFF"
    btn.TextSize = 16
    btn.Font = Enum.Font.Gotham
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.new(1,1,1)

    btn.MouseButton1Click:Connect(function()
        getgenv().Settings[key] = not getgenv().Settings[key]
        btn.Text = text..": "..(getgenv().Settings[key] and "ON" or "OFF")
        btn.BackgroundColor3 = getgenv().Settings[key] and Color3.fromRGB(0,150,0) or Color3.fromRGB(45,45,45)

        if key == "Enabled" and getgenv().Settings.Enabled then
            task.spawn(function()
                while getgenv().Settings.Enabled do
                    if getgenv().Settings.AutoHeal then
                        Client.Network:post("PlayerData","Heal","Lakewood")
                    end

                    local region = Client.DataManager and Client.DataManager.RegionData
                    if region and region.Encounters then
                        for encounter,_ in pairs(region.Encounters) do
                            Client.Battle.WildBattIe(nil,nil,encounter)
                            HandleBattle()
                            break
                        end
                    end

                    task.wait(1)
                end
                btn.Text = text..": OFF"
                btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            end)
        end
    end)
end

-- Add toggles
CreateToggle("Auto-Farm Wild",210,"Enabled")
CreateToggle("Rebattler Farm",265,"RebattlerFarm")
CreateToggle("Fast Forward",320,"FastForward")
CreateToggle("Only Misprints",375,"Misprint")
CreateToggle("Auto-Heal",430,"AutoHeal")
