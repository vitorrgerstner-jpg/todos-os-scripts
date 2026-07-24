-- =============================================
-- MM2 SCRIPT COMPLETO OTIMIZADO (9 scripts)
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local NetworkSettings = settings():GetService("NetworkSettings")

local player = Players.LocalPlayer

-- ==================== 1. Anti-Coins ====================
loadstring(game:HttpGet("https://raw.githubusercontent.com/oipdrin971-source/mm2-script/main/anti_coins_mm2.lua"))()

-- ==================== 2. GlitchPart Mass System ====================
local function aplicarSistema(character)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    if character:FindFirstChild("GlitchPart") then character.GlitchPart:Destroy() end

    local glitchPart = Instance.new("Part")
    glitchPart.Name = "GlitchPart"
    glitchPart.Size = Vector3.new(2,2,2)
    glitchPart.Transparency = 1
    glitchPart.CanCollide = false
    glitchPart.CanTouch = false
    glitchPart.CanQuery = false
    glitchPart.Anchored = false
    glitchPart.Massless = false
    glitchPart.Parent = character

    local weld = Instance.new("Weld")
    weld.Part0 = rootPart
    weld.Part1 = glitchPart
    weld.C0 = CFrame.new(0,0,0)
    weld.Parent = glitchPart

    local escalando = false

    humanoid.StateChanged:Connect(function(_, newState)
        escalando = (newState == Enum.HumanoidStateType.Climbing)
    end)

    character.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then
            if escalando then
                weld.C0 = CFrame.new(0,0,13.5)
            else
                weld.C0 = CFrame.new(0,0,0)
            end
        end
    end)

    character.ChildRemoved:Connect(function(obj)
        if obj:IsA("Tool") then
            weld.C0 = CFrame.new(0,0,0)
        end
    end)
end

-- ==================== 3. Gun System ====================
local actionSound = Instance.new("Sound")
actionSound.SoundId = "rbxassetid://6968135315"
actionSound.Volume = 1
actionSound.Parent = SoundService

local function setupGunSystem(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local animator = humanoid and humanoid:WaitForChild("Animator", 10)
    local lastUnequippedTime = 0

    if animator then
        animator.AnimationPlayed:Connect(function(track)
            local tool = character:FindFirstChildOfClass("Tool")
            local isHoldingGun = (tool and tool.Name == "Gun")
            local withinCooldown = (tick() - lastUnequippedTime) <= 5

            if isHoldingGun or withinCooldown then
                if track.Priority == Enum.AnimationPriority.Action then
                    track:Stop()
                end
            end
        end)
    end

    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == "Gun" then
            actionSound:Play()
        end
    end)

    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child.Name == "Gun" then
            actionSound:Play()
            lastUnequippedTime = tick()
        end
    end)
end

-- ==================== 4. Skibidi Ghost Glitch ====================
local currentOffset = CFrame.new(0, 0, 0)
local activeGhost, activeWeld = nil, nil

local function isGlitchTarget(child)
    if child:IsA("Tool") then return true end
    return string.find(string.lower(child.Name or ""), "radio") ~= nil
end

local function deployGhostGlitch(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso or not root then return end

    local rawCF = root.CFrame:ToObjectSpace(torso.CFrame)
    currentOffset = CFrame.new(rawCF.Position * 1.9) * rawCF.Rotation

    if char:FindFirstChild("Skibidi_Ghost_Active") then
        char.Skibidi_Ghost_Active:Destroy()
    end

    local ghost = Instance.new("Part")
    ghost.Name = "Skibidi_Ghost_Active"
    ghost.Size = Vector3.new(1,1,1)
    ghost.CustomPhysicalProperties = PhysicalProperties.new(40, 0.7, 0.3, 1, 1)
    ghost.Transparency = 1
    ghost.CanCollide = false
    ghost.Parent = char

    activeWeld = Instance.new("Weld")
    activeWeld.Part0 = torso
    activeWeld.Part1 = ghost
    activeWeld.C0 = currentOffset
    activeWeld.Parent = ghost
    activeGhost = ghost
end

local function setupGhostListeners(char)
    task.defer(function() deployGhostGlitch(char) end)

    char.ChildAdded:Connect(function(child)
        if isGlitchTarget(child) then
            deployGhostGlitch(char)
        end
    end)

    char.ChildRemoved:Connect(function(child)
        if isGlitchTarget(child) then
            deployGhostGlitch(char)
        end
    end)
end

-- ==================== 5. Lighting ====================
local function fixLighting()
    for _, light in ipairs(workspace:GetDescendants()) do
        if light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight") then
            light.Color = Color3.fromRGB(200, 200, 200)
            light.Brightness = math.clamp(light.Brightness, 0.1, 1.8)
            light.Range = math.min(light.Range, 5000)
            light.Shadows = true
        end
    end
end

-- ==================== 6. Slope Boost ====================
local SLOPE_BOOST = 170
local holdingS, holdingAorD = false, false

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.S then holdingS = true end
    if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then holdingAorD = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.S then holdingS = false end
    if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then holdingAorD = false end
end)

local function setupSlope(character)
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    local function isInclined()
        return root.CFrame.UpVector.Y < 0.7
    end

    humanoid.Jumping:Connect(function()
        if isInclined() and holdingS and holdingAorD then
            root.AssemblyLinearVelocity = Vector3.new(0, SLOPE_BOOST, 0)
        end
    end)
end

-- ==================== 7. Fake Lag (Tecla R) ====================
local LAG_DURATION = 0.6
local REPLICATION_LAG = 0.7
local sistemaLagAtivo = false

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 50)
statusLabel.Position = UDim2.new(1, -210, 1, -60)
statusLabel.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Text = "Sistema OFF ❌"
statusLabel.Parent = screenGui

local function atualizarPainel()
    if sistemaLagAtivo then
        statusLabel.Text = "Sistema ON 📶"
        statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        statusLabel.Text = "Sistema OFF ❌"
        statusLabel.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end

local function simulateLag()
    if not sistemaLagAtivo then return end
    pcall(function()
        NetworkSettings.IncomingReplicationLag = REPLICATION_LAG
        NetworkSettings.OutgoingReplicationLag = REPLICATION_LAG
    end)
    task.delay(LAG_DURATION, function()
        pcall(function()
            NetworkSettings.IncomingReplicationLag = 0
            NetworkSettings.OutgoingReplicationLag = 0
        end)
    end)
end

-- ==================== 8. Retargeting ====================
game.Workspace.Retargeting = Enum.AnimatorRetargetingMode.Disabled

-- ==================== Inicialização ====================
if player.Character then
    aplicarSistema(player.Character)
    setupGunSystem(player.Character)
    setupGhostListeners(player.Character)
    setupSlope(player.Character)
end

player.CharacterAdded:Connect(function(char)
    aplicarSistema(char)
    setupGunSystem(char)
    setupGhostListeners(char)
    setupSlope(char)
end)

-- Tecla R - Fake Lag
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.R then
        sistemaLagAtivo = not sistemaLagAtivo
        atualizarPainel()
        if sistemaLagAtivo then simulateLag() end
    end
end)

-- Lighting
fixLighting()

-- Heartbeat (mais leve)
RunService.Heartbeat:Connect(function()
    if activeWeld then
        activeWeld.C0 = currentOffset
    end
end)

print("✅ Todos os 9 scripts carregados (otimizado)")
