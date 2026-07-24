local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local currentOffset = CFrame.new(0, 0, 0)
local activeGhost, activeWeld = nil, nil
local cachedRoot, cachedTorso = nil, nil

-- Helper function to check if an object is a Radio or a Tool
local function isGlitchTarget(child)
    if child:IsA("Tool") then return true end

    -- Checks if the item name contains "radio" (case-insensitive)
    if string.find(string.lower(child.Name), "radio") then 
        return true 
    end

    return false
end

local function deployGhostGlitch()
    local char = player.Character
    if not char then return end

    cachedRoot = char:FindFirstChild("HumanoidRootPart")
    cachedTorso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

    if not cachedTorso or not cachedRoot then return end

    local rawCF = cachedRoot.CFrame:ToObjectSpace(cachedTorso.CFrame)
    currentOffset = CFrame.new(rawCF.Position * 1.9) * rawCF.Rotation

    local oldGhost = char:FindFirstChild("Skibidi_Ghost_Active")
    if oldGhost then
        oldGhost:Destroy() 
    end

    local newGhost = Instance.new("Part")
    newGhost.Name = "Skibidi_Ghost_Active"
    newGhost.Size = Vector3.new(1, 1, 1)
    
    local targetMass = 16
    local volume = newGhost.Size.X * newGhost.Size.Y * newGhost.Size.Z
    local requiredDensity = targetMass / volume
    
    newGhost.CustomPhysicalProperties = PhysicalProperties.new(requiredDensity, 0.7, 0.3, 1, 1)

    newGhost.CFrame = cachedTorso.CFrame 
    newGhost.Transparency = 1 
    newGhost.CanCollide = false
    newGhost.Parent = char

    activeWeld = Instance.new("Weld")
    activeWeld.Part0 = cachedTorso
    activeWeld.Part1 = newGhost
    activeWeld.C0 = currentOffset
    activeWeld.Parent = newGhost

    activeGhost = newGhost
end

local function setupListeners(char)
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            activeGhost = nil
            activeWeld = nil
            cachedRoot = nil
            cachedTorso = nil
        end)
    end

    task.defer(deployGhostGlitch)

    char.ChildAdded:Connect(function(child)
        if isGlitchTarget(child) then 

            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless = true
                end
            end
            deployGhostGlitch() 
        end
    end)
 
    char.ChildRemoved:Connect(function(child)
        if isGlitchTarget(child) then 
            deployGhostGlitch() 
        end
    end)
end

if player.Character then setupListeners(player.Character) end
player.CharacterAdded:Connect(setupListeners)

RunService.Heartbeat:Connect(function()
    if activeWeld then
        activeWeld.C0 = currentOffset
    else
        if player.Character and (not activeGhost or activeGhost.Parent ~= player.Character) then
            deployGhostGlitch()
        end
    end
end)

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- CONFIGURATION
local SOUND_ID = "rbxassetid://6968135315"
local TARGET_TOOL_NAME = "Gun"
local COOLDOWN_DURATION = 5 -- Seconds to keep stopping animations after unequip

-- SETUP SOUNDw
local actionSound = Instance.new("Sound")
actionSound.SoundId = SOUND_ID
actionSound.Volume = 1
actionSound.Parent = SoundService

--------------------------------------------------
-- CORE LOGIC
--------------------------------------------------

local function setupGunSystem(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local animator = humanoid and humanoid:WaitForChild("Animator", 10)
    
    -- Track when the gun was last put away
    local lastUnequippedTime = 0

    -- 1. ANIMATION STOPPER LOGIC
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            local tool = character:FindFirstChildOfClass("Tool")
            local isHoldingGun = (tool and tool.Name == TARGET_TOOL_NAME)
            
            -- Calculate how long it has been since we unequipped
            local timeSinceUnequip = tick() - lastUnequippedTime
            local withinCooldown = timeSinceUnequip <= COOLDOWN_DURATION

            -- Stop animation if holding the gun OR if we are within the 5s window
            if isHoldingGun or withinCooldown then
