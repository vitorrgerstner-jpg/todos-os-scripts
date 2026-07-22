-- =============================================
-- MM2 SCRIPT COMPLETO - Sem bloqueio geral de animações
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
    
    if character:FindFirstChild("GlitchPart") then
        character.GlitchPart:Destroy()
    end

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

    local massaTravada = false
    local escalando = false

    local function setOffset(z)
        weld.C0 = CFrame.new(0,0,z)
    end

    local function deslocarMassa()
        massaTravada = true
        setOffset(13.5)
    end

    local function resetarMassa()
        massaTravada = false
        setOffset(0)
    end

    humanoid.StateChanged:Connect(function(_, newState)
        escalando = (newState == Enum.HumanoidStateType.Climbing)
    end)

    character.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then
            if escalando then
                deslocarMassa()
            else
                resetarMassa()
            end
        end
    end)

    character.ChildRemoved:Connect(function(obj)
        if obj:IsA("Tool") and not escalando then
            resetarMassa()
        end
    end)

    local backpack = player:WaitForChild("Backpack")
    backpack.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") and not escalando then resetarMassa() end
    end)
    backpack.ChildRemoved:Connect(function(obj)
        if obj:IsA("Tool") and not escalando then resetarMassa() end
    end)
end

-- ==================== 3. Gun System (Mantido) ====================
local SOUND_ID = "rbxassetid://6968135315"
local TARGET_TOOL_NAME = "Gun"
local COOLDOWN_DURATION = 5

local actionSound = Instance.new("Sound")
actionSound.SoundId = SOUND_ID
actionSound.Volume = 1
actionSound.Parent = SoundService

local function setupGunSystem(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local animator = humanoid and humanoid:WaitForChild("Animator", 10)
    local lastUnequippedTime = 0

    if animator then
        animator.AnimationPlayed:Connect(function(track)
            local tool = character:FindFirstChildOfClass("Tool")
            local isHoldingGun = tool and tool.Name == TARGET_TOOL_NAME
            local timeSinceUnequip = tick() - lastUnequippedTime
            local withinCooldown = timeSinceUnequip <= COOLDOWN_DURATION

            if isHoldingGun or withinCooldown then
                if track.Priority == Enum.AnimationPriority.Action then
                    track:Stop()
                end
            end
        end)
    end

    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == TARGET_TOOL_NAME then
            actionSound:Play()
        end
    end)

    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child.Name == TARGET_TOOL_NAME then
            actionSound:Play()
            lastUnequippedTime = tick()
        end
    end)
end

-- ==================== 4. Skibidi Ghost Glitch ====================
local currentOffset = CFrame.new(0, 0, 0)
local activeGhost, activeWeld = nil, nil
local cachedRoot, cachedTorso = nil, nil

local function isGlitchTarget(child)
    if child:IsA("Tool") then return true end
    return string.find(string.lower(child.Name), "radio") ~= nil
end

local function deployGhostGlitch()
    local char = player.Character
    if not char then return end
    cachedRoot = char:FindFirstChild("HumanoidRootPart")
    cachedTorso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not cachedTorso or not cachedRoot then return end

    local rawCF = cachedRoot.CFrame:ToObjectSpace(cachedTorso.CFrame)
    currentOffset = CFrame.new(rawCF.Position * 1.9) * rawCF.Rotation

    if char:FindFirstChild("Skibidi_Ghost_Active") then
        char.Skibidi_Ghost_Active:Destroy()
    end

    local newGhost = Instance.new("Part")
    newGhost.Name = "Skibidi_Ghost_Active"
    newGhost.Size = Vector3.new(1, 1, 1)
    newGhost.CustomPhysicalProperties = PhysicalProperties.new(40, 0.7, 0.3, 1, 1)
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

local function setupGhostListeners(char)
    if not char then return end
    task.defer(deployGhostGlitch)

    char.ChildAdded:Connect(function(child)
        if isGlitchTarget(child) then
            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("BasePart") then part.Massless = true end
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

-- ==================== 5. Lighting Fix ====================
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
local holdingS = false
local holdingAorD = false

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.S then holdingS = true end
    if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then holdingAorD = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.S then holdingS = false end
    if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then holdingAorD = false end
end)

local function setupSlope(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    local function isInclined()
        return root.CFrame.UpVector.Y < 0.7
    end

    humanoid.Jumping:Connect(function()
        if isInclined() and holdingS and holdingAorD then
            root.AssemblyLinearVelocity = Vector3.new(0,0,0)
            root.AssemblyLinearVelocity += Vector3.new(0, SLOPE_BOOST, 0)
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
statusLabel.Active = true
statusLabel.Parent = screenGui

local function atualizarPainelLag()
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

    local start = tick()
    local connection = RunService.RenderStepped:Connect(function()
        if tick() - start < LAG_DURATION then
            task.wait(math.random(0.05, 0.15))
        else
            connection:Disconnect()
        end
    end)

    task.delay(LAG_DURATION, function()
        pcall(function()
            NetworkSettings.IncomingReplicationLag = 0
            NetworkSettings.OutgoingReplicationLag = 0
        end)
    end)
end

-- ==================== 8. Disable Retargeting ====================
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

-- Tecla R = Fake Lag
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.R then
        sistemaLagAtivo = not sistemaLagAtivo
        atualizarPainelLag()
        if not sistemaLagAtivo then
            pcall(function()
                NetworkSettings.IncomingReplicationLag = 0
                NetworkSettings.OutgoingReplicationLag = 0
            end)
        end
    end
end)

-- Monitor de mortes para lag
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then hum.Died:Connect(simulateLag) end
    end)
end)

-- Lighting
fixLighting()
workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("PointLight") or desc:IsA("SpotLight") or desc:IsA("SurfaceLight") then
        task.wait(0.1)
        fixLighting()
    end
end)

-- Heartbeat Ghost
RunService.Heartbeat:Connect(function()
    if activeWeld then
        activeWeld.C0 = currentOffset
    elseif player.Character and (not activeGhost or activeGhost.Parent ~= player.Character) then
        deployGhostGlitch()
    end
end)
