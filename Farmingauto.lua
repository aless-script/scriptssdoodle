warn("[Aidez Reborn] Vega X load start")

-- AFK
pcall(function()
    for _,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
        v:Disable()
    end
end)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- SAFE CLIENT LOAD
local ok, Client = pcall(function()
    return require(Player.Packer.Client)
end)

if not ok then
    warn("[Aidez Reborn] Client failed")
    return
end

warn("[Aidez Reborn] Client OK")

getgenv().Settings = {
    Enabled = false,
    FastForward = true,
    RebattlerFarm = false,
    AutoHeal = true,
    MinStars = 3,
    TargetDoodle = "",
    Misprint = false
}

-- FAST FORWARD
task.spawn(function()
    repeat task.wait() until Client.Utilities and Client.Utilities.Halt
    Client.Utilities.Halt = function(t)
        if getgenv().Settings.FastForward then
            task.wait(0.01)
            return
        end
        task.wait(t or 0.03)
    end
end)

-- GUI (VEGA X SAFE)
local Gui = Instance.new("ScreenGui")
Gui.Name = "AidezReborn"
Gui.ResetOnSpawn = false

local hui = gethui and gethui() or game:GetService("CoreGui")
Gui.Parent = hui

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromOffset(350,500)
Main.Position = UDim2.fromScale(0.3,0.2)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,50)
Title.Text = "Aidez Reborn (Vega X)"
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- TOGGLE TEST (CONFIRM GUI WORKS)
local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(0.9,0,0,50)
Toggle.Position = UDim2.new(0.05,0,0,80)
Toggle.Text = "GUI WORKING"
Toggle.TextSize = 18
Toggle.BackgroundColor3 = Color3.fromRGB(0,150,0)
Toggle.TextColor3 = Color3.new(1,1,1)

warn("[Aidez Reborn] GUI SHOWN")
