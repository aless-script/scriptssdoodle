--// DEBUG CONFIRM
warn("[Aidez Reborn] Script executing")

--// Prevent AFK Kick
pcall(function()
    for _,v in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
        v:Disable()
    end
end)

--// SERVICES
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

--// SAFE CLIENT REQUIRE
local ok, Client = pcall(function()
    return require(Player.Packer.Client)
end)

if not ok or not Client then
    warn("[Aidez Reborn] FAILED to load Client")
    return
end

warn("[Aidez Reborn] Client loaded")

--// GLOBAL SETTINGS
getgenv().Settings = {
    Enabled = false,
    FastForward = true,
    RebattlerFarm = false,
    AutoHeal = true,
    MinStars = 3,
    TargetDoodle = "",
    Misprint = false
}

--// FAST FORWARD
task.spawn(function()
    repeat task.wait() until Client.Utilities and Client.Utilities.Halt

    Client.Utilities.Halt = function(t)
        if getgenv().Settings.FastForward then
            local gui = Player.PlayerGui:FindFirstChild("MainGui")
            local inBattle = gui and gui:FindFirstChild("MainBattle") and gui.MainBattle.Visible
            if inBattle then
                task.wait(getgenv().Settings.RebattlerFarm and 0.025 or nil)
                return
            end
            if t and t >= 2 then
                task.wait(0.01)
                return
            end
        end
        task.wait(t or 0.03)
    end

    if Client.Camera then
        Client.Camera.Zoom = function() end
    end
end)

--// BATTLE HANDLER
local function HandleBattle()
    local battle = Client.Battle.CurrentBattle
    if not battle then return end

    local gui = Player.PlayerGui:WaitForChild("MainGui",5)
    if not gui then return end
    local battleGui = gui:WaitForChild("MainBattle",5)
    if not battleGui then return end

    local t0 = os.clock()
    repeat task.wait()
    until battleGui.BottomBar.Actions.Visible
        or not Client.Battle.CurrentBattle
        or os.clock() - t0 > 5

    if not Client.Battle.CurrentBattle then return end

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

    if
        (getgenv().Settings.TargetDoodle == "" or
        string.lower(Enemy.Name) == string.lower(getgenv().Settings.TargetDoodle))
        and Enemy.Star >= getgenv().Settings.MinStars
        and (not getgenv().Settings.Misprint or Enemy.Shiny)
    then
        getgenv().Settings.Enabled = false
        warn("[Aidez Reborn] MATCH FOUND:", Enemy.Name, Enemy.Star)
        return
    end

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
end

--// GUI (EXECUTOR SAFE)
local Gui = Instance.new("ScreenGui")
Gui.Name = "AidezReborn"
Gui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(Gui)
end

Gui.Parent = game:GetService("CoreGui")

--// MAIN FRAME
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromOffset(350,500)
Main.Position = UDim2.fromScale(0.3,0.2)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,50)
Title.Text = "Aidez Reborn: Pro Edition"
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)

--// SEARCH BOX
local SearchBox = Instance.new("TextBox", Main)
SearchBox.Size = UDim2.new(0.9,0,0,45)
SearchBox.Position = UDim2.new(0.05,0,0,65)
SearchBox.PlaceholderText = "Type Doodle Name..."
SearchBox.BackgroundColor3 = Color3.fromRGB(15,15,15)
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    getgenv().Settings.TargetDoodle = SearchBox.Text
end)

--// STAR LABEL
local StarLabel = Instance.new("TextLabel", Main)
StarLabel.Size = UDim2.new(0.9,0,0,30)
StarLabel.Position = UDim2.new(0.05,0,0,115)
StarLabel.Text = "Minimum Stars: 3"
StarLabel.TextSize = 18
StarLabel.BackgroundTransparency = 1
StarLabel.TextColor3 = Color3.new(1,1,1)

--// TOGGLE CREATOR
local function CreateToggle(text, y, key)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9,0,0,45)
    b.Position = UDim2.new(0.05,0,0,y)
    b.Text = text..": OFF"
    b.Font = Enum.Font.Gotham
    b.TextSize = 16
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.TextColor3 = Color3.new(1,1,1)

    b.MouseButton1Click:Connect(function()
        getgenv().Settings[key] = not getgenv().Settings[key]
        b.Text = text..": "..(getgenv().Settings[key] and "ON" or "OFF")
        b.BackgroundColor3 = getgenv().Settings[key]
            and Color3.fromRGB(0,150,0)
            or Color3.fromRGB(45,45,45)

        if key == "Enabled" and getgenv().Settings.Enabled then
            task.spawn(function()
                while getgenv().Settings.Enabled do
                    if getgenv().Settings.AutoHeal then
                        Client.Network:post("PlayerData","Heal","Lakewood")
                    end

                    local region = Client.DataManager and Client.DataManager.RegionData
                    if region and region.Encounters then
                        for e,_ in pairs(region.Encounters) do
                            Client.Battle.WildBattIe(nil,nil,e)
                            HandleBattle()
                            break
                        end
                    end
                    task.wait(1)
                end
                b.Text = text..": OFF"
                b.BackgroundColor3 = Color3.fromRGB(45,45,45)
            end)
        end
    end)
end

CreateToggle("Auto-Farm Wild",210,"Enabled")
CreateToggle("Rebattler Farm",265,"RebattlerFarm")
CreateToggle("Fast Forward",320,"FastForward")
CreateToggle("Only Misprints",375,"Misprint")
CreateToggle("Auto-Heal",430,"AutoHeal")

warn("[Aidez Reborn] GUI LOADED")
