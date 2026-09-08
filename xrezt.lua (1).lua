--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Custom Script
    Author: OYB
    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "XreztHub_567935",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "Xrezt Hub Key System"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua'))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = 'Xrezt Hub',
    Footer = 'Xrezt Revamped',
    NotifySide = 'Right',
    ShowCustomCursor = true,
})

local MainTab = Window:AddTab('Main', 'sword')
local VisualTab = Window:AddTab('Visual', 'eye')
local MiscTab = Window:AddTab('Misc', 'box')
local AutoTab = Window:AddTab('Auto', 'zap')
local TuningTab = Window:AddTab('Tuning', 'wrench')
local SideDashTab = Window:AddTab('Side Dash', 'wind')
local ConfigTab = Window:AddTab('Settings', 'settings')

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Workspace = game:GetService('Workspace')
local UserInputService = game:GetService('UserInputService')
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local math_abs = math.abs
local math_clamp = math.clamp
local math_acos = math.acos
local math_floor = math.floor
local math_max = math.max
local math_exp = math.exp
local Vector3_new = Vector3.new
local Vector2_new = Vector2.new
local CFrame_new = CFrame.new
local RaycastParams_new = RaycastParams.new
local Enum_RaycastFilterType_Exclude = Enum.RaycastFilterType.Exclude

local ActiveConnections = {}
local MobileButtons = {}
local LastHitGlowTime = 0
local AlwaysDownslamActive = false
local InfiniteParkourActive = false
local AutoParkourActive = false
local InfiniteDashActive = false
local DETECTION_DISTANCE = 3.5
local CLIMB_SPEED = 40
local FORWARD_SPEED = 12

local glideInProgress = false
local positionHistory = {}
local ghostModel = nil
local ghostPartsCache = {}
local MAX_HISTORY = 150



-- Lock-on target state (hoisted for Auto Block cross-system access)
local AimlockTarget = nil
local OP_Locked = false
local OP_Target = nil


-- =========================================
-- AUTO BLOCK SHARED SCOPE LOCALS (LIMIT BYPASS)
-- =========================================
local ScriptActive = true
local BlockRemoteCache
local BlockStateMachine
local EnemyTracker
local DynamicAnimationCache
local DynamicCacheHits = 0
local DynamicCacheMisses = 0


local AllAnimationNames = {"Loading animations..."}
local AnimationExclusionList = {}


local MovementStateKeywords = {
    "run", "chase", "down", "fall", "ragdoll", "idle",
    "walk", "jump", "dash", "climb", "getup", "land",
    "sprint", "movement", "turn", "halt", "hover", "sleep",
    "emote", "spawn", "dance", "wave", "sit", "block"
}



local AnimationTriggers = {
    ["rbxassetid://100962226150441"] = 0.19,
    ["rbxassetid://95852624447551"]  = 0.19,
    ["rbxassetid://74145636023952"]  = 0.19,
    ["rbxassetid://72475960800126"]  = 0.20,
}

local StraightAnimations = {
    ["rbxassetid://123171106092050"] = true,
}

local MAHITO_BF_ANIM = "72475960800126"
local MahitoConnection = nil

local function SetupMahitoCharacter(character)
    if MahitoConnection then
        MahitoConnection:Disconnect()
        MahitoConnection = nil
    end
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    local animator = humanoid:WaitForChild("Animator", 5)
    if not animator then return end
    MahitoConnection = animator.AnimationPlayed:Connect(function(track)
        if not Toggles.AutoMahitoBlackflash or not Toggles.AutoMahitoBlackflash.Value then return end
        local animId = track.Animation and track.Animation.AnimationId or ""
        if string.find(animId, MAHITO_BF_ANIM, 1, true) then
            task.spawn(function()
                task.wait(0.2)
                pcall(function()
                    local knit = ReplicatedStorage:WaitForChild("Knit", 3)
                    local inner = knit:WaitForChild("Knit", 3)
                    local services = inner:WaitForChild("Services", 3)
                    local fss = services:WaitForChild("FocusStrikeService", 3)
                    local re = fss:WaitForChild("RE", 3)
                    local activated = re:WaitForChild("Activated", 3)
                    local moveset = character:WaitForChild("Moveset", 3)
                    local focusStrike = moveset:WaitForChild("Focus Strike", 3)
                    activated:FireServer(focusStrike)
                end)
            end)
        end
    end)
    table.insert(ActiveConnections, MahitoConnection)
end


local cachedServices = nil
local function GetKnitServices()
    if cachedServices then return cachedServices end
    local knit = ReplicatedStorage:FindFirstChild("Knit")
    if not knit then return nil end
    local innerKnit = knit:FindFirstChild("Knit")
    if not innerKnit then return nil end
    cachedServices = innerKnit:FindFirstChild("Services")
    return cachedServices
end

local networkPing = 0.06
task.spawn(function()
    local stats = game:GetService("Stats")
    while task.wait(1.5) do
        pcall(function()
            local pingItem = stats.Network.ServerStatsItem["Data Ping"]
            if pingItem then
                local pingStr = pingItem:GetValueString()
                local pingNum = tonumber(pingStr:match("%d+"))
                if pingNum then networkPing = pingNum / 1000 end
            end
        end)
    end
end)

local staticRayParams = RaycastParams_new()
staticRayParams.FilterType = Enum_RaycastFilterType_Exclude
staticRayParams.IgnoreWater = true

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }

    if AlwaysDownslamActive and method == "FireServer" and self.Name == "Activated" and self.Parent and self.Parent.Name == "RE" then
        local service = self.Parent.Parent
        if service and service.Name == (LocalPlayer:GetAttribute("Moveset") .. "Service") then
            if args[1] == false then
                args[1] = "Down"
            end
            return oldNamecall(self, unpack(args))
        end
    end



    return oldNamecall(self, unpack(args))
end)



local function IsLocalPlayerIncapacitated()
    local localChar = LocalPlayer.Character
    if not localChar then return true end
    if localChar:GetAttribute("Dead") then return true end
    local ragdollVal = localChar:GetAttribute("Ragdoll")
    if ragdollVal and ragdollVal > 0 then return true end
    return false
end

local function RegisterTrackToDropdown(animationName)
    local lowerName = string.lower(animationName)
    for i = 1, #MovementStateKeywords do
        if string.find(lowerName, MovementStateKeywords[i]) then return end
    end
    if not table.find(AllAnimationNames, animationName) then
        if AllAnimationNames[1] == "Loading animations..." then
            table.remove(AllAnimationNames, 1)
        end
        table.insert(AllAnimationNames, animationName)
        table.sort(AllAnimationNames)
        if Options.AnimationsList then Options.AnimationsList:SetValues(AllAnimationNames) end
    end
end



local function GetCurrentMoveset()
    local localChar = LocalPlayer.Character
    if not localChar then return nil end
    local attr = localChar:GetAttribute("Moveset")
    if attr then return attr end
    local obj = localChar:FindFirstChild("Moveset")
    if obj then
        if obj:IsA("StringValue") then
            return obj.Value
        else
            return obj.Name
        end
    end
    return nil
end



local function fireManjiKickService()
    if not Toggles.AutoCounterEnabled or not Toggles.AutoCounterEnabled.Value then return end
    local char = LocalPlayer.Character
    if not char then return end
    local moveset = char:FindFirstChild("Moveset")
    if not moveset then return end
    local move = moveset:FindFirstChild("Manji Kick")
    if not move then return end
    local services = GetKnitServices()
    if not services then return end
    local manjiService = services:FindFirstChild("ManjiKickService")
    if not manjiService then return end
    local re = manjiService:FindFirstChild("RE")
    if not re then return end
    local activated = re:FindFirstChild("Activated")
    if not activated then return end
    pcall(function() activated:FireServer(move) end)
end

local function HandleManjiCounterAnimationPlay(character, animationTrack)
    if not Toggles.AutoCounterEnabled or not Toggles.AutoCounterEnabled.Value then return end
    if not animationTrack or not animationTrack.Animation then return end
    local animationName = animationTrack.Animation.Name
    local lowerName = string.lower(animationName)
    for i = 1, #MovementStateKeywords do
        if string.find(lowerName, MovementStateKeywords[i]) then return end
    end
    local charPlayer = Players:GetPlayerFromCharacter(character)
    if charPlayer == LocalPlayer then return end
    if IsLocalPlayerIncapacitated() then return end
    if character:GetAttribute("Dead") then return end
    local localChar = LocalPlayer.Character
    if not localChar then return end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = character:FindFirstChild("HumanoidRootPart")
    if not localRoot or not targetRoot then return end
    local distance = (localRoot.Position - targetRoot.Position).Magnitude
    if distance > Options.CounterRange.Value then return end
    if Toggles.CounterFacingCheck and Toggles.CounterFacingCheck.Value then
        local enemyLookVector = targetRoot.CFrame.LookVector
        local directionToUs = (localRoot.Position - targetRoot.Position).Unit
        local facingDotProduct = enemyLookVector:Dot(directionToUs)
        if facingDotProduct < Options.CounterFacingThreshold.Value then return end
    end
    fireManjiKickService()
end



local function ConnectCharacter(char)
    local charPlayer = Players:GetPlayerFromCharacter(char)
    if charPlayer == LocalPlayer then return end
    local humanoid = char:WaitForChild('Humanoid', 5)
    if humanoid then
        local conn = humanoid.AnimationPlayed:Connect(function(track)
            if track.Animation then RegisterTrackToDropdown(track.Animation.Name) end
            HandleManjiCounterAnimationPlay(char, track)
        end)
        table.insert(ActiveConnections, conn)
    end
end

local function SetupWorkspaceConnections()
    local CharactersFolder = Workspace:WaitForChild('Characters', 10) or Workspace:FindFirstChild('Characters')
    if not CharactersFolder then return end
    for _, char in pairs(CharactersFolder:GetChildren()) do ConnectCharacter(char) end
    local childAddedConn = CharactersFolder.ChildAdded:Connect(function(newChar)
        task.wait(0.5)
        ConnectCharacter(newChar)
    end)
    table.insert(ActiveConnections, childAddedConn)
end

local function CreateMobileButton(name, icon, callback, position)
    if not UserInputService.TouchEnabled then return end
    if MobileButtons[name] then MobileButtons[name]:Destroy() MobileButtons[name] = nil end
    local mobileControls = LocalPlayer:WaitForChild("PlayerGui", 10):WaitForChild("Controls", 5):WaitForChild("Mobile", 5)
    local jumpButton = mobileControls:WaitForChild("Jump", 5)
    if not jumpButton then return end
    local newButton = jumpButton:FindFirstChild("Block") and jumpButton.Block:Clone() or jumpButton:Clone()
    newButton.Name = name; newButton.Position = position or UDim2.new(-0.7, 0, -2.4, 0)
    newButton.Parent = jumpButton; newButton.Visible = true
    local iconLabel = newButton:FindFirstChildWhichIsA("ImageLabel", true)
    if iconLabel then iconLabel.Image = icon end
    local connection = newButton.MouseButton1Click:Connect(callback)
    table.insert(ActiveConnections, connection)
    MobileButtons[name] = newButton
end

local function RemoveMobileButton(name)
    if MobileButtons[name] then MobileButtons[name]:Destroy() MobileButtons[name] = nil end
end

-- =========================================
-- AUTO QTE LOGIC
-- =========================================
local qtePollActive = false
local qteHeartbeatConnection = nil

local function fireQTEConnections(button)
    if not button then return end
    if getconnections then
        for _, eventName in ipairs({"MouseButton1Down", "MouseButton1Click", "Activated"}) do
            local event = button[eventName]
            if event then
                for _, connection in ipairs(getconnections(event)) do
                    pcall(function()
                        connection:Fire()
                        connection:Fire()
                        connection:Fire()
                    end)
                end
            end
        end
    else
        pcall(function()
            button:Activate()
        end)
    end
end

local function processAutoQTE()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    
    local qteInstance = playerGui:FindFirstChild("QTE")
    if qteInstance then
        for burst = 1, 10 do
            if UserInputService.TouchEnabled then
                local mobileBtn = qteInstance:FindFirstChild("QTE_MOBILE")
                if mobileBtn then
                    fireQTEConnections(mobileBtn)
                end
            else
                local pcLabel = qteInstance:FindFirstChild("QTE_PC")
                if pcLabel and pcLabel:IsA("TextLabel") then
                    local keyStr = pcLabel.Text
                    if keyStr and keyStr ~= "" then
                        local success, keyCode = pcall(function() return Enum.KeyCode[keyStr] end)
                        if success and keyCode then
                            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                        end
                    end
                end
            end
        end
    end
end

local function startAutoQTE()
    qtePollActive = true
    
    task.spawn(function()
        while qtePollActive do
            pcall(processAutoQTE)
            task.wait()
        end
    end)
    
    qteHeartbeatConnection = RunService.Heartbeat:Connect(function()
        pcall(processAutoQTE)
    end)
end

local function stopAutoQTE()
    qtePollActive = false
    if qteHeartbeatConnection then
        qteHeartbeatConnection:Disconnect()
        qteHeartbeatConnection = nil
    end
end

-- =========================================
-- PREMIUM REWRITTEN AIMLOCK SYSTEM
-- =========================================
AimlockTarget = nil
local AimlockSmoothPos = nil
local AimlockLastTargetPos = nil
local AimlockLastTargetTime = 0
local AimlockLookDir = nil 
local AimlockSmoothedVelocity = Vector3_new(0, 0, 0)

local AimlockStoredStates = {
    MouseBehavior = nil,
    RotationType = nil,
    AutoRotate = nil
}

local function RestoreAimlockStates()
    if AimlockStoredStates.MouseBehavior ~= nil then
        pcall(function() UserInputService.MouseBehavior = AimlockStoredStates.MouseBehavior end)
        AimlockStoredStates.MouseBehavior = nil
    end
    if AimlockStoredStates.RotationType ~= nil then
        pcall(function() UserGameSettings.RotationType = AimlockStoredStates.RotationType end)
        AimlockStoredStates.RotationType = nil
    end
    if AimlockStoredStates.AutoRotate ~= nil then
        pcall(function()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h then h.AutoRotate = AimlockStoredStates.AutoRotate end
        end)
        AimlockStoredStates.AutoRotate = nil
    end
end

local function GetAimlockTarget()
    local localChar = LocalPlayer.Character
    if not localChar then return nil end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end

    local currentCamera = workspace.CurrentCamera
    local screenCenter = Vector2_new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)

    if Toggles.HardLockEnabled and Toggles.HardLockEnabled.Value and AimlockTarget then
        local targetRoot = AimlockTarget:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = AimlockTarget:FindFirstChildOfClass("Humanoid")
        if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and not AimlockTarget:GetAttribute("Dead") and AimlockTarget.Parent then
            local distance = (localRoot.Position - targetRoot.Position).Magnitude
            if distance <= Options.AimlockRange.Value then
                return AimlockTarget
            end
        end
        AimlockTarget = nil
    end

    local closestTarget = nil
    local bestScore = math.huge
    local camPos = currentCamera.CFrame.Position

    local function evaluateCharacter(char)
        if char == localChar then return end
        local targetRoot = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not targetRoot or not humanoid or humanoid.Health <= 0 then return end
        if char:GetAttribute("Dead") then return end

        local distance = (localRoot.Position - targetRoot.Position).Magnitude
        if distance > Options.AimlockRange.Value then return end

        staticRayParams.FilterDescendantsInstances = {localChar}
        local result = workspace:Raycast(camPos, targetRoot.Position - camPos, staticRayParams)
        if result and not result.Instance:IsDescendantOf(char) then return end

        local screenPos, onScreen = currentCamera:WorldToViewportPoint(targetRoot.Position)
        if not onScreen then return end

        local screenOffset = (screenCenter - Vector2_new(screenPos.X, screenPos.Y)).Magnitude
        -- Weight screen distance heavily with localized distances to preserve flawless lock stability
        local score = screenOffset * 3.5 + distance * 0.15

        if score < bestScore then
            bestScore = score
            closestTarget = char
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            evaluateCharacter(plr.Character)
        end
    end

    local CharactersFolder = Workspace:FindFirstChild("Characters")
    if CharactersFolder then
        for _, char in pairs(CharactersFolder:GetChildren()) do
            if char:IsA("Model") then
                evaluateCharacter(char)
            end
        end
    end

    return closestTarget
end

local function StartAimlockMonitor()
    RunService:BindToRenderStep("AimlockLoop", Enum.RenderPriority.Camera.Value + 1, function(dt)
        -- Protect against delta-time spikes (FPS Lag spikes) to prevent targeting stutters
        dt = math.min(dt, 0.05)

        if not Toggles.AimlockEnabled or not Toggles.AimlockEnabled.Value then
            RestoreAimlockStates()
            AimlockTarget = nil
            AimlockSmoothPos = nil
            AimlockLastTargetPos = nil
            AimlockLookDir = nil
            return
        end

        local target = GetAimlockTarget()
        if not target then
            RestoreAimlockStates()
            AimlockTarget = nil
            AimlockSmoothPos = nil
            AimlockLastTargetPos = nil
            AimlockLookDir = nil
            return
        end

        AimlockTarget = target
        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        local localHum = localChar and localChar:FindFirstChildOfClass("Humanoid")

        if not targetRoot or not localRoot or not localHum then
            RestoreAimlockStates()
            AimlockTarget = nil
            return
        end

        local targetPos = targetRoot.Position
        local now = tick()
        local rawVelocity = Vector3_new(0, 0, 0)
        
        if AimlockLastTargetPos and (now - AimlockLastTargetTime) > 0.0001 then
            rawVelocity = (targetPos - AimlockLastTargetPos) / (now - AimlockLastTargetTime)
            -- Filter anomalous speed spikes (teleports / flings) to prevent aimlock throwing errors
            if rawVelocity.Magnitude > 300 then
                rawVelocity = Vector3_new(0, 0, 0)
            end
        end
        AimlockLastTargetPos = targetPos
        AimlockLastTargetTime = now

        -- Filter raw velocity utilizing exponential moving average for ultra-smooth tracking
        local velSmoothAlpha = 1 - math_exp(-18 * dt)
        AimlockSmoothedVelocity = AimlockSmoothedVelocity:Lerp(rawVelocity, velSmoothAlpha)

        -- Predictive positioning heavily scales off of your current network latency
        local predictionStrength = Options.PredictionStrength.Value / 10
        local predictedPosition = targetPos + (AimlockSmoothedVelocity * (networkPing * predictionStrength))

        if not AimlockSmoothPos then
            AimlockSmoothPos = predictedPosition
        else
            -- If positions desync heavily, fast snap to prevent target sliding. Else, interpolate silky-smooth.
            if (predictedPosition - AimlockSmoothPos).Magnitude > 40 then
                AimlockSmoothPos = predictedPosition
            else
                local smoothAlpha = 1 - math_exp(-15 * dt)
                AimlockSmoothPos = AimlockSmoothPos:Lerp(predictedPosition, smoothAlpha)
            end
        end

        local lockMode = Options.AimlockMode.Value
        local currentCamera = workspace.CurrentCamera

        if lockMode == "Camera" then
            if AimlockStoredStates.AutoRotate ~= nil then
                pcall(function()
                    local c = LocalPlayer.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if h then h.AutoRotate = AimlockStoredStates.AutoRotate end
                end)
                AimlockStoredStates.AutoRotate = nil
            end

            if AimlockStoredStates.MouseBehavior == nil then
                AimlockStoredStates.MouseBehavior = UserInputService.MouseBehavior
            end
            if AimlockStoredStates.RotationType == nil then
                AimlockStoredStates.RotationType = UserGameSettings.RotationType
            end

            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserGameSettings.RotationType = Enum.RotationType.CameraRelative

            local camPos = currentCamera.CFrame.Position
            -- Adjust height offset dynamically to point directly at upper torso/neck junction
            local lookAt = AimlockSmoothPos + Vector3_new(0, 1.25, 0)
            currentCamera.CFrame = CFrame_new(camPos, lookAt)

        elseif lockMode == "Character" then
            if AimlockStoredStates.MouseBehavior ~= nil then
                pcall(function() UserInputService.MouseBehavior = AimlockStoredStates.MouseBehavior end)
                AimlockStoredStates.MouseBehavior = nil
            end
            if AimlockStoredStates.RotationType ~= nil then
                pcall(function() UserGameSettings.RotationType = AimlockStoredStates.RotationType end)
                AimlockStoredStates.RotationType = nil
            end

            if AimlockStoredStates.AutoRotate == nil then
                pcall(function()
                    local c = LocalPlayer.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    if h then AimlockStoredStates.AutoRotate = h.AutoRotate end
                end)
            end
            pcall(function()
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if h then h.AutoRotate = false end
            end)

            local currentPos = localRoot.Position
            local targetDir = Vector3_new(AimlockSmoothPos.X - currentPos.X, 0, AimlockSmoothPos.Z - currentPos.Z)

            if targetDir.Magnitude > 0.001 then
                targetDir = targetDir.Unit

                if not AimlockLookDir then
                    AimlockLookDir = targetDir
                else
                    local alpha = 1 - math_exp(-18 * dt)
                    local newDir = AimlockLookDir:Lerp(targetDir, alpha)
                    AimlockLookDir = newDir.Magnitude > 0.001 and newDir.Unit or targetDir
                end

                localRoot.CFrame = CFrame_new(currentPos, currentPos + AimlockLookDir)
            end
        end
    end)
end

table.insert(ActiveConnections, LocalPlayer.CharacterAdded:Connect(function()
    AimlockStoredStates.MouseBehavior = nil
    AimlockStoredStates.RotationType = nil
    AimlockStoredStates.AutoRotate = nil
    AimlockLookDir = nil
end))



-- ========================================================
-- OP LOCK-ON SYSTEM (WITH REWRITTEN ULTRA-STABLE DRAGGING)
-- ========================================================
local KEY = Enum.KeyCode.T
local MAX_DIST = 1200
local LOCK_FOV = 75
local CAM_OFFSET = Vector3_new(3, 1, 22)
local ICON = "rbxassetid://263401222"
local MAX_ANGLE = math.rad(80)

OP_Locked = false
OP_Target = nil
local cloneUI = nil
local humConn = nil
local tHumConn = nil
local unlockTween = nil
local fovTween = nil
local oldAutoRotate = nil
local oldMouseLock = nil
local oldRotationType = nil
local oldFOV = nil
local smoothCamPos = nil
local smoothLookDir = nil
local renderConn = nil
local rotConn = nil

local lockChar = LocalPlayer.Character
local lockHum = lockChar and lockChar:FindFirstChildOfClass("Humanoid")
local lockRoot = lockChar and lockChar:FindFirstChild("HumanoidRootPart")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockOnGui"; screenGui.ResetOnSpawn = false; screenGui.IgnoreGuiInset = true; screenGui.Parent = LocalPlayer.PlayerGui

local btnSize = 80
local btn = Instance.new("ImageButton")
btn.Name = "LockButton"; btn.Size = UDim2.new(0, btnSize, 0, btnSize); btn.Position = UDim2.new(1, -btnSize - 20, 1, -btnSize - 120)
btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); btn.BackgroundTransparency = 0.2; btn.Image = ICON
btn.ImageColor3 = Color3.fromRGB(255, 255, 255); btn.Visible = false; btn.Parent = screenGui
Instance.new("UICorner", btn).CornerRadius = UDim.new(0.25, 0)
local btnStroke = Instance.new("UIStroke", btn)
btnStroke.Color = Color3.fromRGB(255, 255, 255); btnStroke.Thickness = 2; btnStroke.Transparency = 0.1

-- Completely rebuilt, ultra-robust dragging logic that tracks absolute viewport pixels
local isDragging = false
local dragStart = Vector2_new(0, 0)
local startBtnPos = Vector2_new(0, 0)
local activeInput = nil

btn.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        activeInput = input
        dragStart = Vector2_new(input.Position.X, input.Position.Y)
        -- Maintain correct starting metrics from absolute pixel layout
        startBtnPos = Vector2_new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y)
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == activeInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = Vector2_new(input.Position.X, input.Position.Y) - dragStart
        if not isDragging and delta.Magnitude > 6 then
            isDragging = true
        end
        if isDragging then
            local finalX = math_clamp(startBtnPos.X + delta.X, 0, screenGui.AbsoluteSize.X - btnSize)
            local finalY = math_clamp(startBtnPos.Y + delta.Y, 0, screenGui.AbsoluteSize.Y - btnSize)
            btn.Position = UDim2.new(0, finalX, 0, finalY)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == activeInput then
        activeInput = nil
        -- Yield dragging frame slightly to avoid registering immediate accidental click release triggers
        task.defer(function()
            isDragging = false
        end)
    end
end)

local function refreshButton()
    local c = OP_Locked and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 255, 255)
    TweenService:Create(btn, TweenInfo.new(0.12), {ImageColor3 = c}):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.12), {Color = c}):Play()
end

local function createIndicator(targetHead)
    if not targetHead then return end
    if cloneUI then cloneUI:Destroy() end
    local gui = Instance.new("BillboardGui")
    gui.Name = "LockIndicator"; gui.Adornee = targetHead; gui.Size = UDim2.new(0, 70, 0, 70)
    gui.StudsOffset = Vector3_new(0, 2.5, 0); gui.AlwaysOnTop = true; gui.Parent = targetHead
    local glow = Instance.new("Frame", gui)
    glow.Name = "Glow"; glow.Size = UDim2.new(1.2, 0, 1.2, 0); glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
    glow.BackgroundTransparency = 1; Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)
    local glowStroke = Instance.new("UIStroke", glow)
    glowStroke.Color = Color3.fromRGB(255, 255, 255); glowStroke.Thickness = 3; glowStroke.Transparency = 0.6
    local img = Instance.new("ImageLabel", gui)
    img.Name = "Icon"; img.Size = UDim2.new(1, 0, 1, 0); img.BackgroundTransparency = 1
    img.Image = ICON; img.ImageColor3 = Color3.fromRGB(255, 255, 255)
    cloneUI = gui
end

local function cleanupConnections()
    if renderConn then renderConn:Disconnect(); renderConn = nil end
    if rotConn then rotConn:Disconnect(); rotConn = nil end
    if humConn then humConn:Disconnect(); humConn = nil end
    if tHumConn then tHumConn:Disconnect(); tHumConn = nil end
    if fovTween then fovTween:Cancel(); fovTween = nil end
end

local function stopLock()
    if not OP_Locked and not unlockTween then return end
    cleanupConnections()
    if cloneUI then cloneUI:Destroy(); cloneUI = nil end
    if unlockTween then unlockTween:Cancel(); unlockTween = nil end
    if lockHum and oldAutoRotate ~= nil then lockHum.AutoRotate = oldAutoRotate; oldAutoRotate = nil end
    if oldMouseLock ~= nil then LocalPlayer.DevEnableMouseLock = oldMouseLock; oldMouseLock = nil end
    if oldRotationType ~= nil then UserGameSettings.RotationType = oldRotationType; oldRotationType = nil end
    local restoreFOV = oldFOV or 70; oldFOV = nil
    OP_Locked = false; OP_Target = nil; smoothCamPos = nil; smoothLookDir = nil; refreshButton()
    local currentRoot = lockChar and lockChar:FindFirstChild("HumanoidRootPart")
    if currentRoot and currentRoot.Parent then
        local behindCF = currentRoot.CFrame * CFrame_new(0, 3, 14)
        local lookAt = currentRoot.Position + Vector3_new(0, 2, 0)
        unlockTween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            CFrame = CFrame_new(behindCF.Position, lookAt), FieldOfView = restoreFOV
        })
        local conn; conn = unlockTween.Completed:Connect(function() conn:Disconnect(); unlockTween = nil; workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
        unlockTween:Play()
    else
        workspace.CurrentCamera.FieldOfView = restoreFOV; workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end

local function startLock(targetHead)
    cleanupConnections()
    if unlockTween then unlockTween:Cancel(); unlockTween = nil end
    OP_Target = targetHead; OP_Locked = true; smoothCamPos = workspace.CurrentCamera.CFrame.Position; oldFOV = workspace.CurrentCamera.FieldOfView
    createIndicator(targetHead); refreshButton()
    local targetHum = targetHead.Parent:FindFirstChildOfClass("Humanoid")
    if targetHum then tHumConn = targetHum.Died:Connect(stopLock) end
    if lockHum then oldAutoRotate = lockHum.AutoRotate; lockHum.AutoRotate = false; humConn = lockHum.Died:Connect(stopLock) end
    oldMouseLock = LocalPlayer.DevEnableMouseLock; LocalPlayer.DevEnableMouseLock = false
    oldRotationType = UserGameSettings.RotationType; UserGameSettings.RotationType = Enum.RotationType.MovementRelative
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    fovTween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = LOCK_FOV}); fovTween:Play()
    local initRoot = lockChar and lockChar:FindFirstChild("HumanoidRootPart")
    if initRoot then local lv = initRoot.CFrame.LookVector; local flat = Vector3_new(lv.X, 0, lv.Z); smoothLookDir = flat.Magnitude > 0.001 and flat.Unit or Vector3_new(0, 0, -1) else smoothLookDir = Vector3_new(0, 0, -1) end
    rotConn = RunService.Heartbeat:Connect(function(dt)
        if not OP_Locked or not OP_Target or not OP_Target.Parent then return end
        local currentRoot = lockChar and lockChar:FindFirstChild("HumanoidRootPart")
        if not currentRoot or not smoothLookDir then return end
        local targetPos = OP_Target.Position; local rootPos = currentRoot.Position
        local targetDir = Vector3_new(targetPos.X - rootPos.X, 0, targetPos.Z - rootPos.Z)
        if targetDir.Magnitude <= 0.001 then return end
        targetDir = targetDir.Unit; local newDir = smoothLookDir:Lerp(targetDir, 1 - math_exp(-15 * dt))
        smoothLookDir = newDir.Magnitude > 0.001 and newDir.Unit or targetDir
        currentRoot.CFrame = CFrame_new(rootPos, rootPos + smoothLookDir)
    end)
    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not OP_Locked then return end
        if not OP_Target or not OP_Target.Parent then stopLock(); return end
        if not lockChar or not lockChar.Parent then stopLock(); return end
        local currentRoot = lockChar:FindFirstChild("HumanoidRootPart")
        if not currentRoot or not smoothCamPos then stopLock(); return end
        local rootPos = currentRoot.Position; local targetPos = OP_Target.Position
        local basePos = currentRoot.CFrame * Vector3_new(CAM_OFFSET.X, 0, CAM_OFFSET.Z)
        local stableY = rootPos.Y + lockHum.HipHeight + CAM_OFFSET.Y
        local xzAlpha = 1 - math_exp(-10 * dt); local yAlpha = 1 - math_exp(-6 * dt)
        smoothCamPos = Vector3_new(
            smoothCamPos.X + (basePos.X - smoothCamPos.X) * xzAlpha,
            smoothCamPos.Y + (stableY - smoothCamPos.Y) * yAlpha,
            smoothCamPos.Z + (basePos.Z - smoothCamPos.Z) * xzAlpha
        )
        workspace.CurrentCamera.CFrame = CFrame_new(smoothCamPos, targetPos)
    end)
end

local function getBestTarget()
    local camPos = workspace.CurrentCamera.CFrame.Position; local camLook = workspace.CurrentCamera.CFrame.LookVector; local bestTarget = nil; local bestScore = math.huge
    local function checkCharacter(model)
        if model == lockChar then return end
        local head = model:FindFirstChild("Head"); local humanoid = model:FindFirstChildOfClass("Humanoid")
        if not head or not humanoid or humanoid.Health <= 0 then return end
        local pos = head.Position; local dist = (pos - camPos).Magnitude
        if dist > MAX_DIST then return end
        local dir = (pos - camPos).Unit; local angle = math_acos(math_clamp(camLook:Dot(dir), -1, 1))
        if angle > MAX_ANGLE then return end
        local score = dist * 0.3 + (angle * 80)
        
        staticRayParams.FilterDescendantsInstances = {lockChar}
        local result = workspace:Raycast(camPos, pos - camPos, staticRayParams)
        if not result or result.Instance:IsDescendantOf(model) then if score < bestScore then bestScore = score; bestTarget = head end end
    end
    for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and plr.Character then checkCharacter(plr.Character) end end
    local charsFolder = workspace:FindFirstChild("Characters")
    if charsFolder then for _, model in ipairs(charsFolder:GetChildren()) do if model:IsA("Model") then checkCharacter(model) end end end
    return bestTarget
end

local function tryLock()
    if isDragging then return end
    if OP_Locked then stopLock(); return end
    local targetHead = getBestTarget()
    if not targetHead then return end
    startLock(targetHead)
end

ContextActionService:BindAction("LockOn", function(_, inputState) if inputState ~= Enum.UserInputState.Begin then return end; tryLock() end, false, KEY)
btn.Activated:Connect(function() tryLock() end)
btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, btnSize * 0.9, 0, btnSize * 0.9)}):Play() end end)
btn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, btnSize, 0, btnSize)}):Play() end end)

LocalPlayer.CharacterAdded:Connect(function(c)
    cleanupConnections()
    if unlockTween then unlockTween:Cancel(); unlockTween = nil end
    if fovTween then fovTween:Cancel(); fovTween = nil end
    if cloneUI then cloneUI:Destroy(); cloneUI = nil end
    if oldRotationType ~= nil then UserGameSettings.RotationType = oldRotationType; oldRotationType = nil end
    if oldMouseLock ~= nil then LocalPlayer.DevEnableMouseLock = oldMouseLock; oldMouseLock = nil end
    oldAutoRotate = nil; workspace.CurrentCamera.FieldOfView = oldFOV or 70; oldFOV = nil; workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    OP_Locked = false; OP_Target = nil; smoothCamPos = nil; smoothLookDir = nil
    lockChar = c; lockHum = c:WaitForChild("Humanoid", 10); lockRoot = c:WaitForChild("HumanoidRootPart", 10); refreshButton()
end)
LocalPlayer.CharacterRemoving:Connect(function() stopLock() end)

-- =========================================================================
-- GORGEOUS GRADIENT ESP SYSTEM (ROBLOX GUI BASED - ENCAPSULATED SCOPE)
-- =========================================================================
local StartEspLoop
local CleanupEsp
local updateCategoryGradients
local getGradientSequence
local refreshAllVisualGradients

local function LoadVisuals()
    local activeESP = {}
    local activeGradients = {
        Box = {},
        Corner = {},
        Skeleton = {},
        Name = {},
        Tracer = {},
        ItemEsp = {},
        ItemTracer = {}
    }

    getGradientSequence = function(color)
        local h, s, v = Color3.toHSV(color)
        
        local hShift = Options.GradientHueShift and Options.GradientHueShift.Value or 0.08
        local sShift = Options.GradientSatShift and Options.GradientSatShift.Value or 1.0
        local vShift = Options.GradientValueShift and Options.GradientValueShift.Value or 0.4
        
        local endColor = Color3.fromHSV(
            (h + hShift) % 1,
            math.clamp(s * sShift, 0, 1),
            math.clamp(v * vShift, 0.1, 1)
        )
        
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(1, endColor)
        })
    end

    refreshAllVisualGradients = function()
        local categories = {"Box", "Corner", "Skeleton", "Name", "Tracer", "ItemEsp", "ItemTracer"}
        local optionFlag = {
            Box = "BoxEspColor",
            Corner = "CornerEspColor",
            Skeleton = "SkeletonEspColor",
            Name = "NameEspColor",
            Tracer = "TracerColor",
            ItemEsp = "ItemEspColor",
            ItemTracer = "ItemTracerColor"
        }
        for _, cat in ipairs(categories) do
            local flag = optionFlag[cat]
            if flag and Options[flag] then
                updateCategoryGradients(cat, Options[flag].Value)
            end
        end
    end

    local function getCategorySequence(category)
        local defaultColors = {
            Box = Color3.fromRGB(0, 200, 255),
            Corner = Color3.fromRGB(0, 255, 200),
            Skeleton = Color3.fromRGB(200, 50, 255),
            Name = Color3.fromRGB(255, 255, 255),
            Tracer = Color3.fromRGB(255, 50, 80),
            ItemEsp = Color3.fromRGB(100, 255, 150),
            ItemTracer = Color3.fromRGB(255, 50, 120)
        }
        local color = defaultColors[category]
        local optionFlag = {
            Box = "BoxEspColor",
            Corner = "CornerEspColor",
            Skeleton = "SkeletonEspColor",
            Name = "NameEspColor",
            Tracer = "TracerColor",
            ItemEsp = "ItemEspColor",
            ItemTracer = "ItemTracerColor"
        }
        local flag = optionFlag[category]
        if flag and Options[flag] then
            color = Options[flag].Value
        end
        return getGradientSequence(color)
    end

    local function registerGradient(grad, category)
        table.insert(activeGradients[category], grad)
        grad.Destroying:Connect(function()
            for i, g in ipairs(activeGradients[category]) do
                if g == grad then
                    table.remove(activeGradients[category], i)
                    break
                end
            end
        end)
    end

    updateCategoryGradients = function(category, color)
        local seq = getGradientSequence(color)
        for _, grad in ipairs(activeGradients[category]) do
            pcall(function()
                grad.Color = seq
            end)
        end
    end

    local function addEspGradient(parentFrame, category)
        local grad = Instance.new("UIGradient")
        grad.Color = getCategorySequence(category)
        grad.Rotation = 90
        grad.Parent = parentFrame
        registerGradient(grad, category)
    end

    local overlay = Instance.new("ScreenGui")
    overlay.Name = "ENI_ESP_Overlay"
    overlay.ResetOnSpawn = false
    overlay.IgnoreGuiInset = true
    pcall(function()
        overlay.Parent = game:GetService("CoreGui")
    end)
    if not overlay.Parent then
        overlay.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local function updateLine(lineFrame, pA, pB, thickness)
        local distance = (pA - pB).Magnitude
        lineFrame.Size = UDim2.new(0, thickness or 2, 0, distance)
        lineFrame.Position = UDim2.new(0, (pA.X + pB.X)/2, 0, (pA.Y + pB.Y)/2)
        local angle = math.deg(math.atan2(pB.Y - pA.Y, pB.X - pA.X)) - 90
        lineFrame.Rotation = angle
    end

    local function getJointPairs(char)
        local function get(name)
            return char:FindFirstChild(name)
        end
        
        local head = get("Head")
        local upperTorso = get("UpperTorso") or get("Torso")
        local lowerTorso = get("LowerTorso") or get("Torso")
        
        if not head or not upperTorso then return nil end
        
        local joints = {
            {head, upperTorso}
        }
        
        if get("LeftUpperArm") then
            table.insert(joints, {upperTorso, get("LeftUpperArm")})
            table.insert(joints, {get("LeftUpperArm"), get("LeftLowerArm")})
            table.insert(joints, {get("LeftLowerArm"), get("LeftHand")})
            
            table.insert(joints, {upperTorso, get("RightUpperArm")})
            table.insert(joints, {get("RightUpperArm"), get("RightLowerArm")})
            table.insert(joints, {get("RightLowerArm"), get("RightHand")})
            
            table.insert(joints, {lowerTorso, get("LeftUpperLeg")})
            table.insert(joints, {get("LeftUpperLeg"), get("LeftLowerLeg")})
            table.insert(joints, {get("LeftLowerLeg"), get("LeftFoot")})
            
            table.insert(joints, {lowerTorso, get("RightUpperLeg")})
            table.insert(joints, {get("RightUpperLeg"), get("RightLowerLeg")})
            table.insert(joints, {get("RightLowerLeg"), get("RightFoot")})
        else
            table.insert(joints, {upperTorso, get("Left Arm")})
            table.insert(joints, {upperTorso, get("Right Arm")})
            table.insert(joints, {lowerTorso, get("Left Leg")})
            table.insert(joints, {lowerTorso, get("Right Leg")})
        end
        
        return joints
    end

    local function createESP(char)
        if activeESP[char] then return end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local espData = {}
        
        local frame = Instance.new("Frame")
        frame.Name = "ESPBox"
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.Visible = false
        frame.Parent = overlay
        espData.Frame = frame
        
        local boxLines = {}
        local lineThickness = 2
        local linesSetup = {
            Top = {Size = UDim2.new(1, 0, 0, lineThickness), Pos = UDim2.new(0, 0, 0, 0)},
            Bottom = {Size = UDim2.new(1, 0, 0, lineThickness), Pos = UDim2.new(0, 0, 1, -lineThickness)},
            Left = {Size = UDim2.new(0, lineThickness, 1, 0), Pos = UDim2.new(0, 0, 0, 0)},
            Right = {Size = UDim2.new(0, lineThickness, 1, 0), Pos = UDim2.new(1, -lineThickness, 0, 0)}
        }
        
        for name, data in pairs(linesSetup) do
            local line = Instance.new("Frame")
            line.Name = name
            line.Size = data.Size
            line.Position = data.Pos
            line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            line.BorderSizePixel = 0
            line.Parent = frame
            addEspGradient(line, "Box")
            boxLines[name] = line
        end
        espData.BoxLines = boxLines
        
        local corners = {}
        local cornerLines = {
            {Size = UDim2.new(0, 12, 0, 2), Pos = UDim2.new(0, 0, 0, 0)},
            {Size = UDim2.new(0, 2, 0, 12), Pos = UDim2.new(0, 0, 0, 0)},
            {Size = UDim2.new(0, 12, 0, 2), Pos = UDim2.new(1, -12, 0, 0)},
            {Size = UDim2.new(0, 2, 0, 12), Pos = UDim2.new(1, -2, 0, 0)},
            {Size = UDim2.new(0, 12, 0, 2), Pos = UDim2.new(0, 0, 1, -2)},
            {Size = UDim2.new(0, 2, 0, 12), Pos = UDim2.new(0, 0, 1, -12)},
            {Size = UDim2.new(0, 12, 0, 2), Pos = UDim2.new(1, -12, 1, -2)},
            {Size = UDim2.new(0, 2, 0, 12), Pos = UDim2.new(1, -2, 1, -12)}
        }
        
        for _, lineData in ipairs(cornerLines) do
            local line = Instance.new("Frame")
            line.Size = lineData.Size
            line.Position = lineData.Pos
            line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            line.BorderSizePixel = 0
            line.Parent = frame
            addEspGradient(line, "Corner")
            table.insert(corners, line)
        end
        espData.Corners = corners
        
        local tracer = Instance.new("Frame")
        tracer.Name = "ESPTracer"
        tracer.AnchorPoint = Vector2.new(0.5, 0.5)
        tracer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tracer.BorderSizePixel = 0
        tracer.Visible = false
        tracer.Parent = overlay
        addEspGradient(tracer, "Tracer")
        espData.TracerLine = tracer
        
        local skeletonFrame = Instance.new("Frame")
        skeletonFrame.Name = "ESPSkeleton"
        skeletonFrame.BackgroundTransparency = 1
        skeletonFrame.Size = UDim2.new(1, 0, 1, 0)
        skeletonFrame.Visible = false
        skeletonFrame.Parent = overlay
        espData.SkeletonFrame = skeletonFrame
        
        local skeletonLines = {}
        for i = 1, 14 do
            local sLine = Instance.new("Frame")
            sLine.AnchorPoint = Vector2.new(0.5, 0.5)
            sLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sLine.BorderSizePixel = 0
            sLine.Visible = false
            sLine.Parent = skeletonFrame
            addEspGradient(sLine, "Skeleton")
            table.insert(skeletonLines, sLine)
        end
        espData.SkeletonLines = skeletonLines
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Size = UDim2.new(0, 200, 0, 20)
        nameLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        nameLabel.Visible = false
        nameLabel.Parent = overlay
        addEspGradient(nameLabel, "Name")
        espData.NameLabel = nameLabel

        activeESP[char] = espData
    end

    local function removeESP(char)
        local espData = activeESP[char]
        if espData then
            if espData.Frame then espData.Frame:Destroy() end
            if espData.TracerLine then espData.TracerLine:Destroy() end
            if espData.SkeletonFrame then espData.SkeletonFrame:Destroy() end
            if espData.NameLabel then espData.NameLabel:Destroy() end
            activeESP[char] = nil
        end
    end

    local function validateCharacter(char)
        if char == LocalPlayer.Character then return false end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return false end
        
        local isDummy = char.Name:lower():find("dummy") or char:FindFirstChild("Enemy") or false
        local isPlayer = Players:GetPlayerFromCharacter(char) ~= nil
        
        if isPlayer then
            return true
        elseif isDummy and Toggles.DummyEspEnabled and Toggles.DummyEspEnabled.Value then
            return true
        end
        
        return false
    end

    local function updateESPFrame()
        local screenCenterBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        
        for char, espData in pairs(activeESP) do
            if not validateCharacter(char) then
                removeESP(char)
            else
                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                
                if root and head then
                    local rootPos = root.Position
                    local extents = char:GetExtentsSize()
                    
                    local topPos = rootPos + Vector3.new(0, extents.Y / 2 + 0.5, 0)
                    local bottomPos = rootPos - Vector3.new(0, extents.Y / 2 + 0.5, 0)
                    
                    local top2D, topOnScreen = Camera:WorldToViewportPoint(topPos)
                    local bottom2D, bottomOnScreen = Camera:WorldToViewportPoint(bottomPos)
                    
                    local boxOn = Toggles.BoxEspEnabled and Toggles.BoxEspEnabled.Value
                    local cornerOn = Toggles.CornerEspEnabled and Toggles.CornerEspEnabled.Value
                    
                    if topOnScreen and bottomOnScreen and (boxOn or cornerOn) then
                        local height = math.abs(top2D.Y - bottom2D.Y)
                        local width = height * 0.65
                        
                        espData.Frame.Visible = true
                        espData.Frame.Size = UDim2.new(0, width, 0, height)
                        espData.Frame.Position = UDim2.new(0, top2D.X - width/2, 0, top2D.Y)
                        
                        if boxOn then
                            for _, line in pairs(espData.BoxLines) do
                                line.Visible = true
                            end
                            for _, corner in ipairs(espData.Corners) do
                                corner.Visible = false
                            end
                        elseif cornerOn then
                            for _, line in pairs(espData.BoxLines) do
                                line.Visible = false
                            end
                            for _, corner in ipairs(espData.Corners) do
                                corner.Visible = true
                            end
                        end
                    else
                        espData.Frame.Visible = false
                    end
                    
                    local head2D, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                    if Toggles.TracerEnabled and Toggles.TracerEnabled.Value and headOnScreen then
                        espData.TracerLine.Visible = true
                        updateLine(espData.TracerLine, screenCenterBottom, Vector2.new(head2D.X, head2D.Y), Options.TracerThickness and Options.TracerThickness.Value or 2)
                    else
                        espData.TracerLine.Visible = false
                    end
                    
                    if Toggles.SkeletonEspEnabled and Toggles.SkeletonEspEnabled.Value then
                        local joints = getJointPairs(char)
                        if joints then
                            espData.SkeletonFrame.Visible = true
                            local lineIndex = 1
                            for _, pair in ipairs(joints) do
                                local partA, partB = pair[1], pair[2]
                                local pA, onScreenA = Camera:WorldToViewportPoint(partA.Position)
                                local pB, onScreenB = Camera:WorldToViewportPoint(partB.Position)
                                
                                local lineFrame = espData.SkeletonLines[lineIndex]
                                if lineFrame then
                                    if onScreenA and onScreenB then
                                        lineFrame.Visible = true
                                        updateLine(lineFrame, Vector2.new(pA.X, pA.Y), Vector2.new(pB.X, pB.Y), 2)
                                    else
                                        lineFrame.Visible = false
                                    end
                                end
                                lineIndex = lineIndex + 1
                            end
                            for i = lineIndex, #espData.SkeletonLines do
                                espData.SkeletonLines[i].Visible = false
                            end
                        else
                            espData.SkeletonFrame.Visible = false
                        end
                    else
                        espData.SkeletonFrame.Visible = false
                    end

                    if Toggles.NameEspEnabled and Toggles.NameEspEnabled.Value and headOnScreen then
                        local player = Players:GetPlayerFromCharacter(char)
                        local displayName = player and player.DisplayName or (char.Name:lower():find("dummy") and "Dummy" or char.Name)
                        local dist = (Camera.CFrame.Position - root.Position).Magnitude
                        espData.NameLabel.Text = displayName .. " [" .. math.floor(dist) .. "m]"
                        espData.NameLabel.Position = UDim2.new(0, head2D.X, 0, top2D.Y - 15)
                        espData.NameLabel.Size = UDim2.new(0, 200, 0, 20)
                        espData.NameLabel.TextSize = Options.NameTextSize and Options.NameTextSize.Value or 13
                        espData.NameLabel.Visible = true
                    else
                        espData.NameLabel.Visible = false
                    end
                else
                    removeESP(char)
                end
            end
        end
    end

    local function handleCharacter(char)
        if char == LocalPlayer.Character then return end
        local humanoid = char:WaitForChild("Humanoid", 15)
        if not humanoid then return end
        local root = char:WaitForChild("HumanoidRootPart", 15)
        if not root then return end
        
        humanoid.Died:Connect(function()
            removeESP(char)
        end)
        
        createESP(char)
    end

    local function onChildAdded(child)
        if child:IsA("Model") then
            local humanoid = child:WaitForChild("Humanoid", 15)
            if humanoid then
                task.spawn(handleCharacter, child)
            end
        end
    end

    local function fullScan()
        local charsFolder = workspace:FindFirstChild("Characters")
        if charsFolder then
            for _, child in ipairs(charsFolder:GetChildren()) do
                if child:IsA("Model") then
                    task.spawn(handleCharacter, child)
                end
            end
        end
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Model") and (child.Name:lower():find("dummy") or child:FindFirstChild("Humanoid")) then
                task.spawn(handleCharacter, child)
            end
        end
    end

    -- // ===================== ITEMS ESP (FROM items_esp.luau) ===================== //
    local ItemEspObjects = {}
    local ItemEspConnections = {}
    local TRACER_COLOR = Color3.fromRGB(255, 50, 80)
    local TRACER_COLOR_2 = Color3.fromRGB(120, 40, 255)
    local NAME_COLOR = Color3.fromRGB(255, 255, 255)
    local TEXT_SIZE = 12
    local TRACER_THICKNESS = 1.5

    local function createItemESP(item)
        if ItemEspObjects[item] then return end

        local espData = {}

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "ItemName"
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Size = UDim2.new(0, 200, 0, 20)
        nameLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        nameLabel.Visible = false
        nameLabel.Parent = overlay
        addEspGradient(nameLabel, "ItemEsp")
        espData.nameLabel = nameLabel

        local tracer = Instance.new("Frame")
        tracer.Name = "ItemTracer"
        tracer.AnchorPoint = Vector2.new(0.5, 0.5)
        tracer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tracer.BorderSizePixel = 0
        tracer.Visible = false
        tracer.Parent = overlay
        addEspGradient(tracer, "ItemTracer")
        espData.tracer = tracer

        ItemEspObjects[item] = espData
        return espData
    end

    local function removeItemESP(item)
        local obj = ItemEspObjects[item]
        if obj then
            if obj.nameLabel then obj.nameLabel:Destroy() end
            if obj.tracer then obj.tracer:Destroy() end
            ItemEspObjects[item] = nil
        end
    end

    local function updateItemESP(item)
        local obj = ItemEspObjects[item]
        if not obj then return end
        
        local nameOn = Toggles.ItemEspEnabled and Toggles.ItemEspEnabled.Value or false
        local tracerOn = Toggles.ItemTracerEnabled and Toggles.ItemTracerEnabled.Value or false

        if not nameOn and not tracerOn then
            obj.nameLabel.Visible = false
            obj.tracer.Visible = false
            return
        end

        local rootPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
        if not rootPart then
            local model = item:IsA("Model") and item or nil
            if model then
                rootPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            end
        end
        if not rootPart then return end

        local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local screenPos = Vector2.new(pos.X, pos.Y)
            local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

            if tracerOn then
                obj.tracer.Visible = true
                updateLine(obj.tracer, screenBottom, screenPos, TRACER_THICKNESS)
            else
                obj.tracer.Visible = false
            end

            if nameOn then
                local camPos = Camera.CFrame.Position
                local dist = (rootPart.Position - camPos).Magnitude
                local itemName = item.Name
                if item:IsA("Model") then
                    itemName = item:GetAttribute("DisplayName") or item.Name
                end
                obj.nameLabel.Text = string.format("[%s]  %.0f studs", itemName, dist)
                obj.nameLabel.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - 18)
                obj.nameLabel.Visible = true
            else
                obj.nameLabel.Visible = false
            end
        else
            obj.nameLabel.Visible = false
            obj.tracer.Visible = false
        end
    end

    local EspRenderConnection = nil
    local WorkspaceChildConnection = nil
    local CharactersChildConnection = nil
    local CharactersRemovedConnection = nil

    StartEspLoop = function()
        EspRenderConnection = RunService.RenderStepped:Connect(function()
            pcall(updateESPFrame)
            pcall(function()
                for item, obj in pairs(ItemEspObjects) do
                    if item and item.Parent then
                        updateItemESP(item)
                    else
                        removeItemESP(item)
                    end
                end
            end)
        end)

        local charsFolder = workspace:FindFirstChild("Characters")
        if charsFolder then
            CharactersChildConnection = charsFolder.ChildAdded:Connect(onChildAdded)
            CharactersRemovedConnection = charsFolder.ChildRemoved:Connect(removeESP)
        end
        WorkspaceChildConnection = workspace.ChildAdded:Connect(onChildAdded)
        
        fullScan()

        -- Item Esp Monitor Setup
        local itemsFolder = workspace:FindFirstChild("Items")
        if itemsFolder then
            local function onItemAdded(item)
                task.wait()
                createItemESP(item)
            end

            local function onItemRemoved(item)
                removeItemESP(item)
            end

            for _, item in ipairs(itemsFolder:GetChildren()) do
                task.spawn(onItemAdded, item)
            end

            table.insert(ItemEspConnections, itemsFolder.ChildAdded:Connect(onItemAdded))
            table.insert(ItemEspConnections, itemsFolder.ChildRemoved:Connect(onItemRemoved))
        end
    end

    CleanupEsp = function()
        if EspRenderConnection then EspRenderConnection:Disconnect(); EspRenderConnection = nil end
        if WorkspaceChildConnection then WorkspaceChildConnection:Disconnect(); WorkspaceChildConnection = nil end
        if CharactersChildConnection then CharactersChildConnection:Disconnect(); CharactersChildConnection = nil end
        if CharactersRemovedConnection then CharactersRemovedConnection:Disconnect(); CharactersRemovedConnection = nil end
        
        for char, _ in pairs(activeESP) do
            removeESP(char)
        end
        table.clear(activeESP)

        for item, _ in pairs(ItemEspObjects) do
            removeItemESP(item)
        end
        table.clear(ItemEspObjects)

        for _, conn in ipairs(ItemEspConnections) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(ItemEspConnections)
        
        if overlay then
            overlay:Destroy()
        end
        for cat, tbl in pairs(activeGradients) do
            table.clear(tbl)
        end
    end
end
LoadVisuals()


-- ========================================================
-- VARIANT CONTROL LOGIC
-- ========================================================
local variantConnections = { Nue = {}, Frog = {} }

local function disconnectVariantConnections(tbl)
    for _, conn in ipairs(tbl) do
        if conn.Disconnect then conn:Disconnect() end
    end
    table.clear(tbl)
end

local function setupNueVariant(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    table.insert(variantConnections.Nue, humanoid.AnimationPlayed:Connect(function(track)
        if Toggles.AutoNueVariant and Toggles.AutoNueVariant.Value and track.Animation and track.Animation.AnimationId == "rbxassetid://111077341852080" then
            local MegumiService = GetKnitServices():FindFirstChild("MegumiService")
            if MegumiService and MegumiService:FindFirstChild("RE") then
                MegumiService.RE.RightActivated:FireServer()
            end
        end
    end))
end

local function setupFrogVariant(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    table.insert(variantConnections.Frog, humanoid.AnimationPlayed:Connect(function(track)
        if Toggles.AutoFrogVariant and Toggles.AutoFrogVariant.Value and track.Animation and track.Animation.AnimationId == "rbxassetid://116432619539029" then
            local moveset = character:FindFirstChild("Moveset")
            if moveset and moveset:FindFirstChild("Nue") then
                local NueService = GetKnitServices():FindFirstChild("NueService")
                if NueService and NueService:FindFirstChild("RE") then
                    NueService.RE.Activated:FireServer(moveset.Nue)
                end
            end
        end
    end))
end

local function hookVariantCharacter(character)
    disconnectVariantConnections(variantConnections.Nue)
    disconnectVariantConnections(variantConnections.Frog)
    setupNueVariant(character)
    setupFrogVariant(character)
end

-- Refined Logic: Auto Perfect Swap
local ExtraConnections = {
    PerfectSwap = nil,
    AutoRatio = nil,
    AutoDomain = nil
}

local function HandlePerfectSwap(state)
    local KnitServices = GetKnitServices()
    if state then
        local TodoService = KnitServices and KnitServices:WaitForChild("TodoService", 5)
        if TodoService and TodoService:FindFirstChild("RE") then
            ExtraConnections.PerfectSwap = TodoService.RE.Effects.OnClientEvent:Connect(function(...)
                local args = {...}
                if args[1] == "Swap" or args[1] == "Swap2" or args[1] == "Fakeout" then
                    TodoService.RE.Activated:FireServer(false)
                end
            end)
        end
    else
        if ExtraConnections.PerfectSwap then
            ExtraConnections.PerfectSwap:Disconnect()
            ExtraConnections.PerfectSwap = nil
        end
    end
end

-- Refined Logic: Auto Ratio
local function HandleAutoRatio(state)
    local KnitServices = GetKnitServices()
    if state then
        local NanamiService = KnitServices and KnitServices:WaitForChild("NanamiService", 5)
        if NanamiService and NanamiService:FindFirstChild("RE") then
            ExtraConnections.AutoRatio = NanamiService.RE.Effects.OnClientEvent:Connect(function(...)
                local args = {...}
                if args[1] == "SpawnRatio" and args[2] == LocalPlayer then
                    local dataPing = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                    local timeMult = type(args[6]) == "number" and args[6] or 1
                    
                    local waitTime = timeMult * math.clamp(0.56 - ((math.floor(dataPing) - 100) / 1000) * 0.9, 0.25, 0.85)
                    task.wait(waitTime)
                    
                    NanamiService.RE.RightActivated:FireServer()
                end
            end)
        end
    else
        if ExtraConnections.AutoRatio then
            ExtraConnections.AutoRatio:Disconnect()
            ExtraConnections.AutoRatio = nil
        end
    end
end

-- Refined Logic: Auto Domain Vote
local function HandleAutoDomain(state)
    if state then
        local lastCheck = 0
        local alreadyVoted = false
        ExtraConnections.AutoDomain = RunService.Heartbeat:Connect(function()
            if not Toggles.AutoDomain or not Toggles.AutoDomain.Value then return end
            if tick() - lastCheck < 0.2 then return end
            lastCheck = tick()

            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if not playerGui then return end

            local choose = playerGui:FindFirstChild("Choose")
            if not choose then return end

            local timer = choose:FindFirstChild("Timer")
            if not timer or timer.Text ~= "1" then
                alreadyVoted = false
                return
            end

            if alreadyVoted then return end

            local domains = workspace:FindFirstChild("Domains")
            if not domains then return end
            local domain = domains:FindFirstChild("Domain")
            if not domain then return end
            if domain:GetAttribute("UI2") == true then return end

            local confessCount = domain:GetAttribute("ConfessCount") or 0
            local denialCount = domain:GetAttribute("DenialCount") or 0
            local silenceCount = domain:GetAttribute("SilenceCount") or 0

            local allUnvoted = (confessCount == -1) and (denialCount == -1) and (silenceCount == -1)
            if not allUnvoted then return end

            local btn = choose:FindFirstChildWhichIsA("GuiButton")
            if btn and type(getconnections) == "function" then
                pcall(function()
                    for _, conn in ipairs(getconnections(btn.MouseButton1Down)) do
                        pcall(function() conn:Fire() end)
                    end
                end)
                pcall(function()
                    for _, conn in ipairs(getconnections(btn.Activated)) do
                        pcall(function() conn:Fire() end)
                    end
                end)
                pcall(function()
                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                        pcall(function() conn:Fire() end)
                    end
                end)
                alreadyVoted = true
            end
        end)
    else
        if ExtraConnections.AutoDomain then
            ExtraConnections.AutoDomain:Disconnect()
            ExtraConnections.AutoDomain = nil
        end
    end
end

-- Helper: Find nearest enemy target
local function FindNearestEnemy(maxDist)
    maxDist = maxDist or 50
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position

    local closestTarget = nil
    local closestDist = maxDist

    local function checkChar(char)
        if char == myChar then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and hrp and not char:GetAttribute("Dead") then
            local dist = (myPos - hrp.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestTarget = char
            end
        end
    end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then checkChar(pl.Character) end
    end

    local charactersFolder = workspace:FindFirstChild("Characters")
    if charactersFolder then
        for _, obj in ipairs(charactersFolder:GetChildren()) do
            if obj:IsA("Model") then checkChar(obj) end
        end
    end
    return closestTarget
end

-- Animation listeners for auto-hakari and auto-garuda features
local function setupCustomAnimationTriggers(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    local animator = humanoid and humanoid:WaitForChild("Animator", 5)
    if not animator then return end

    local animConn = animator.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        
        -- Auto WCS (131506102901134)
        if Toggles.AutoWCS and Toggles.AutoWCS.Value and string.find(animId, "131506102901134", 1, true) then
            task.spawn(function()
                pcall(function()
                    local services = GetKnitServices()
                    local moveset = char:FindFirstChild("Moveset")
                    if not services or not moveset then return end

                    local rushSvc = services:FindFirstChild("RushService")
                    local rushRemote = rushSvc and rushSvc:FindFirstChild("RE") and rushSvc.RE:FindFirstChild("Activated")
                    local flameSvc = services:FindFirstChild("FlameArrowService")
                    local flameRemote = flameSvc and flameSvc:FindFirstChild("RE") and flameSvc.RE:FindFirstChild("Activated")
                    local itadoriSvc = services:FindFirstChild("ItadoriService")
                    local itadoriRemote = itadoriSvc and itadoriSvc:FindFirstChild("RE") and itadoriSvc.RE:FindFirstChild("RightActivated")

                    local rushMove = moveset:FindFirstChild("Rush")
                    local openMove = moveset:FindFirstChild("Open")

                    if rushRemote and rushMove then
                        rushRemote:FireServer(rushMove)
                    end
                    task.wait(0.05)
                    if flameRemote and openMove then
                        flameRemote:FireServer(openMove)
                    end
                    task.wait(1.1)
                    if itadoriRemote then
                        for _ = 1, 8 do
                            itadoriRemote:FireServer()
                            task.wait(0.05)
                        end
                    end
                end)
            end)
        end

        -- Auto Door (82541714192027)
        if Toggles.AutoDoor and Toggles.AutoDoor.Value and string.find(animId, "82541714192027", 1, true) then
            task.spawn(function()
                task.wait(0.2)
                pcall(function()
                    local services = GetKnitServices()
                    local moveset = char:FindFirstChild("Moveset")
                    if not services or not moveset then return end
                    local shutterDoors = moveset:FindFirstChild("Shutter Doors")
                    if not shutterDoors then return end
                    local shutterSvc = services:FindFirstChild("ShutterDoorService")
                    local shutterRemote = shutterSvc and shutterSvc:FindFirstChild("RE") and shutterSvc.RE:FindFirstChild("Activated")
                    if shutterRemote then
                        shutterRemote:FireServer(shutterDoors)
                        shutterRemote:FireServer(shutterDoors)
                    end
                end)
            end)
        end

        -- Fever Crusher (108123475959041)
        if Toggles.FeverCrusher and Toggles.FeverCrusher.Value and string.find(animId, "108123475959041", 1, true) then
            task.spawn(function()
                task.wait(0.2)
                pcall(function()
                    local services = GetKnitServices()
                    local moveset = char:FindFirstChild("Moveset")
                    if not services or not moveset then return end
                    local shutterDoors = moveset:FindFirstChild("Shutter Doors")
                    if not shutterDoors then return end
                    local shutterSvc = services:FindFirstChild("ShutterDoorService")
                    local shutterRemote = shutterSvc and shutterSvc:FindFirstChild("RE") and shutterSvc.RE:FindFirstChild("Activated")
                    if shutterRemote then
                        shutterRemote:FireServer(shutterDoors)
                        shutterRemote:FireServer(shutterDoors)
                    end
                end)
            end)
        end

        -- Garuda Rebound (115097960689033)
        if Toggles.GarudaRebound and Toggles.GarudaRebound.Value and string.find(animId, "115097960689033", 1, true) then
            task.spawn(function()
                local target = FindNearestEnemy(50)
                local moveset = char:FindFirstChild("Moveset")
                if not moveset then return end
                local garudaMove = moveset:FindFirstChild("Garuda Rebound")
                if not garudaMove then return end

                local delayVal = Options.GarudaDelay and Options.GarudaDelay.Value or 1
                if delayVal > 0 then
                    task.wait(delayVal)
                end

                pcall(function()
                    local services = GetKnitServices()
                    if not services then return end
                    local svc = services:FindFirstChild("GarudaReboundService")
                    if not svc then return end
                    local activated = svc:FindFirstChild("RE") and svc.RE:FindFirstChild("Activated")
                    local deactivated = svc:FindFirstChild("RE") and svc.RE:FindFirstChild("Deactivated")
                    if activated then activated:FireServer(garudaMove, target) end
                    if deactivated then deactivated:FireServer(garudaMove, target) end
                end)
            end)
        end
    end)
    table.insert(ActiveConnections, animConn)
end

-- ========================================================
-- AUTO BLACKFLASH SYSTEM (extracted from blackflash.lua)
-- ========================================================
local BlackflashState = {
    GlideInProgress = false,
    TriggerCooldown = false
}

local function getHRP(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function isFacingFront(myHRP, tHRP)
    if not (myHRP and tHRP) then return false end
    local targetLook = Vector3.new(tHRP.CFrame.LookVector.X, 0, tHRP.CFrame.LookVector.Z)
    if targetLook.Magnitude < 0.001 then return false end
    targetLook = targetLook.Unit
    local directionToPlayer = (myHRP.Position - tHRP.Position)
    if directionToPlayer.Magnitude < 0.001 then return false end
    directionToPlayer = directionToPlayer.Unit
    return targetLook:Dot(directionToPlayer) > 0.1
end

local function getNearestTarget()
    local myChar = LocalPlayer.Character
    local myHRP = getHRP(myChar)
    if not myHRP then return nil end

    local closestTarget = nil
    local closestDist = Options.BlackflashMaxRange and Options.BlackflashMaxRange.Value or 25

    local function checkChar(char)
        if char == myChar then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = getHRP(char)
        if hum and hum.Health > 0 and hrp then
            local dist = (myHRP.Position - hrp.Position).Magnitude
            if dist < closestDist then
                if isFacingFront(myHRP, hrp) then
                    closestDist = dist
                    closestTarget = char
                end
            end
        end
    end

    if Toggles.BlackflashTargetPlayers and Toggles.BlackflashTargetPlayers.Value then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then checkChar(pl.Character) end
        end
    end

    if Toggles.BlackflashTargetDummies and Toggles.BlackflashTargetDummies.Value then
        local charactersFolder = workspace:FindFirstChild("Characters") or workspace:FindFirstChild("NPCs")
        if charactersFolder then
            for _, obj in ipairs(charactersFolder:GetChildren()) do
                if obj:IsA("Model") then checkChar(obj) end
            end
        else
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                    checkChar(obj)
                end
            end
        end
    end
    return closestTarget
end

local cachedDivergentRE = nil
local function getDivergentRE()
    if cachedDivergentRE and cachedDivergentRE.Parent then return cachedDivergentRE end

    local paths = {
        function()
            return ReplicatedStorage:WaitForChild("Knit", 5)
                :WaitForChild("Knit", 5)
                :WaitForChild("Services", 5)
                :WaitForChild("DivergentFistService", 5)
                :WaitForChild("RE", 5)
                :WaitForChild("Activated", 5)
        end,
        function()
            return ReplicatedStorage:WaitForChild("Knit", 5)
                :WaitForChild("Services", 5)
                :WaitForChild("DivergentFistService", 5)
                :WaitForChild("RE", 5)
                :WaitForChild("Activated", 5)
        end,
        function()
            return ReplicatedStorage:WaitForChild("KnitServices", 5)
                :WaitForChild("DivergentFistService", 5)
                :WaitForChild("RE", 5)
                :WaitForChild("Activated", 5)
        end,
    }

    for i, pathFunc in ipairs(paths) do
        local ok, re = pcall(pathFunc)
        if ok and re then
            cachedDivergentRE = re
            return re
        end
    end

    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc:IsA("RemoteEvent") and desc.Name == "Activated" then
            local path = desc:GetFullName()
            if string.find(path, "Divergent") then
                cachedDivergentRE = desc
                return desc
            end
        end
    end
    return nil
end

local function fireDivergentRemote()
    local char = LocalPlayer.Character
    if not char then return end

    local moveset = char:FindFirstChild("Moveset")
    if not moveset then return end

    local move = moveset:FindFirstChild("Divergent Fist")
    if not move then return end

    local re = getDivergentRE()
    if re then
        re:FireServer(move)
    end
end

local function executeCurveGlide(targetChar)
    if BlackflashState.GlideInProgress then return end
    BlackflashState.GlideInProgress = true

    local myChar = LocalPlayer.Character
    local myHRP = getHRP(myChar)
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local tHRP = getHRP(targetChar)

    if not (myHRP and hum and tHRP) then BlackflashState.GlideInProgress = false return end

    local elapsed = 0
    local startPos = myHRP.Position

    local targetCF = tHRP.CFrame
    local flatLook = Vector3.new(targetCF.LookVector.X, 0, targetCF.LookVector.Z)
    if flatLook.Magnitude < 0.001 then BlackflashState.GlideInProgress = false return end
    local targetLook = flatLook.Unit
    local flatRight = Vector3.new(targetCF.RightVector.X, 0, targetCF.RightVector.Z)
    if flatRight.Magnitude < 0.001 then BlackflashState.GlideInProgress = false return end
    local targetRight = flatRight.Unit
    local toPlayer = (startPos - tHRP.Position)
    local sideSign = toPlayer:Dot(targetRight) >= 0 and 1 or -1

    local stopDistance = 3.2
    local curveStrengthVal = Options.BlackflashCurveStrength and Options.BlackflashCurveStrength.Value or 10
    local controlPoint = tHRP.Position + (targetRight * (curveStrengthVal * sideSign))

    local previousAutoRotate = hum.AutoRotate
    local previousCamType = Camera.CameraType
    local previousAnchor = myHRP.Anchored

    hum.AutoRotate = false
    myHRP.Anchored = true
    Camera.CameraType = Enum.CameraType.Custom

    local dashDurationVal = Options.BlackflashDashDuration and Options.BlackflashDashDuration.Value or 0.18

    local runConnection
    runConnection = RunService.RenderStepped:Connect(function(dt)
        local myHRPNow = getHRP(LocalPlayer.Character)
        local tHRPNow = getHRP(targetChar)

        if not myHRPNow or not tHRPNow or not tHRPNow.Parent or not (Toggles.BlackflashEnabled and Toggles.BlackflashEnabled.Value) then
            runConnection:Disconnect()
            pcall(function() 
                hum.AutoRotate = previousAutoRotate
                myHRPNow.Anchored = previousAnchor
            end)
            Camera.CameraType = previousCamType
            BlackflashState.GlideInProgress = false
            return
        end

        elapsed = elapsed + dt
        local alpha = math.clamp(elapsed / dashDurationVal, 0, 1)

        local p0 = startPos
        local p1 = controlPoint
        local p2 = tHRPNow.Position - (Vector3.new(tHRPNow.CFrame.LookVector.X, 0, tHRPNow.CFrame.LookVector.Z).Unit * stopDistance)

        local currentPosition = (1 - alpha)^2 * p0 + 2 * (1 - alpha) * alpha * p1 + alpha^2 * p2
        local nextHeight = myHRPNow.Position.Y
        currentPosition = Vector3.new(currentPosition.X, nextHeight, currentPosition.Z)

        myHRPNow.CFrame = CFrame.new(currentPosition, Vector3.new(tHRPNow.Position.X, nextHeight, tHRPNow.Position.Z))

        if Toggles.BlackflashCameraLock and Toggles.BlackflashCameraLock.Value then
            local targetCenter = tHRPNow.Position + Vector3.new(0, 1.5, 0)
            local camPos = myHRPNow.Position + (myHRPNow.CFrame.LookVector * -7) + Vector3.new(0, 3.5, 0)
            Camera.CFrame = CFrame.new(camPos, targetCenter)
        end

        if alpha >= 1 then
            runConnection:Disconnect()
            pcall(function() 
                hum.AutoRotate = previousAutoRotate
                myHRPNow.Anchored = previousAnchor
            end)
            Camera.CameraType = previousCamType
            BlackflashState.GlideInProgress = false
        end
    end)
    table.insert(ActiveConnections, runConnection)
end

local function triggerBlackflashProcedure()
    if BlackflashState.TriggerCooldown then return end
    BlackflashState.TriggerCooldown = true
    task.delay(0.5, function() BlackflashState.TriggerCooldown = false end)

    local target = getNearestTarget()
    if Toggles.BlackflashDashBehind and Toggles.BlackflashDashBehind.Value and target then
        task.spawn(function() executeCurveGlide(target) end)
    end
    task.spawn(function()
        local t = 0
        local fireDelay = Options.BlackflashAutoFireDelay and Options.BlackflashAutoFireDelay.Value or 0.23
        while t < fireDelay do
            t = t + RunService.RenderStepped:Wait()
        end
        if Toggles.BlackflashEnabled and Toggles.BlackflashEnabled.Value then fireDivergentRemote() end
    end)
end

local function setupBlackflashCharacterMonitor(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    local animator = humanoid and humanoid:WaitForChild("Animator", 5)
    if not animator then return end

    local animCooldown = 0.5
    local lastTriggerTime = 0

    local animConn = animator.AnimationPlayed:Connect(function(track)
        if not (Toggles.BlackflashEnabled and Toggles.BlackflashEnabled.Value) then return end
        local animId = track.Animation.AnimationId
        if string.find(animId, "100962226150441") or string.find(animId, "95852624447551") or string.find(animId, "74145636023952") or string.find(animId, "72475960800126") then
            local now = os.clock()
            if now - lastTriggerTime > animCooldown then
                lastTriggerTime = now
                triggerBlackflashProcedure()
            end
        end
    end)
    table.insert(ActiveConnections, animConn)
end

local blackflashKeybindConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if Options.BlackflashKeybind and input.KeyCode == Options.BlackflashKeybind.Value then
        if Toggles.BlackflashEnabled and Toggles.BlackflashEnabled.Value then
            triggerBlackflashProcedure()
        end
    end
end)
table.insert(ActiveConnections, blackflashKeybindConnection)

-- ========================================================
-- INVISIBILITY SYSTEM (extracted from invisible_gui.lua)
-- ========================================================
local InvisibilityState = {
    Active = false,
    Connections = {},
    FakeTorso = nil,
    MeditationTrack = nil,
    OriginalCameraSubject = nil,
}

local function InvisNotify(msg)
    if Toggles.ShowNotifications and Toggles.ShowNotifications.Value then
        Library:Notify({ Title = "Invisibility", Description = msg, Time = 3 })
    end
end

local function GetInvisCharacterParts()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    return char, hrp, hum, animator
end

local function DisconnectInvisAll()
    for name, conn in pairs(InvisibilityState.Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
        InvisibilityState.Connections[name] = nil
    end
end

local function EnableInvisibility()
    if InvisibilityState.Active then return end

    local char, hrp, hum, animator = GetInvisCharacterParts()
    if not char or not hrp or not hum or not animator then
        InvisNotify("No valid character found")
        Toggles.Invisibility:SetValue(false)
        return
    end

    InvisibilityState.Active = true
    InvisibilityState.OriginalCameraSubject = Camera.CameraSubject

    hum.AutoRotate = false
    hrp.Anchored = true
  
    InvisibilityState.Connections.Noclip = RunService.Stepped:Connect(function()
        if not InvisibilityState.Active then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)

    local torso = Instance.new("Part")
    torso.Name = "InvisibleFakeTorso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.Transparency = 1
    torso.CanCollide = false
    torso.Anchored = true
    torso.Parent = workspace
    InvisibilityState.FakeTorso = torso

    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = torso

    RunService:BindToRenderStep("InvisCameraSync", Enum.RenderPriority.Camera.Value - 1, function()
        if not InvisibilityState.Active or not hrp or not hrp.Parent or not torso then return end
        local camCF = Camera.CFrame
        local lookDir = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
        if lookDir.Magnitude > 0.001 then
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookDir.Unit)
        end
        torso.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1.5, 0))
    end)

    local meditationAnim = ReplicatedStorage:WaitForChild("Modules", 5)
        and ReplicatedStorage.Modules:WaitForChild("MVP", 5)
        and ReplicatedStorage.Modules.MVP:WaitForChild("Meditation", 5)
        and ReplicatedStorage.Modules.MVP.Meditation:FindFirstChild("Character")

    if meditationAnim then
        local track = animator:LoadAnimation(meditationAnim)
        track.Priority = Enum.AnimationPriority.Action4
        track:Play()
        task.wait(0.1)
        track.TimePosition = 0.1
        track:AdjustSpeed(0)
        InvisibilityState.MeditationTrack = track
    else
        InvisNotify("Meditation animation not found - visual hide may not work")
    end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track ~= InvisibilityState.MeditationTrack then
            track:Stop(0)
        end
    end

    InvisibilityState.Connections.AnimSuppress = animator.AnimationPlayed:Connect(function(playedTrack)
        if playedTrack ~= InvisibilityState.MeditationTrack then
            playedTrack:Stop(0)
        end
    end)

    InvisNotify("Invisibility Enabled")
end

local function DisableInvisibility()
    if not InvisibilityState.Active then return end
    InvisibilityState.Active = false

    DisconnectInvisAll()

    pcall(function()
        RunService:UnbindFromRenderStep("InvisCameraSync")
    end)

    local char, hrp, hum = GetInvisCharacterParts()

    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    if hrp then
        hrp.Anchored = false
    end

    if hum then
        hum.AutoRotate = true
        Camera.CameraSubject = hum
    elseif InvisibilityState.OriginalCameraSubject then
        Camera.CameraSubject = InvisibilityState.OriginalCameraSubject
    end

    if InvisibilityState.FakeTorso then
        InvisibilityState.FakeTorso:Destroy()
        InvisibilityState.FakeTorso = nil
    end

    if InvisibilityState.MeditationTrack then
        pcall(function() InvisibilityState.MeditationTrack:Stop(0) end)
        pcall(function() InvisibilityState.MeditationTrack:Destroy() end)
        InvisibilityState.MeditationTrack = nil
    end

    InvisNotify("Invisibility Disabled")
end

-- ========================================================
-- SIDE DASH SYSTEM (extracted from side dahs assist)
-- ========================================================
local LEFT_DASH_ANIM = "rbxassetid://75203303352791"
local RIGHT_DASH_ANIM = "rbxassetid://117223862448096"

local sideDashInProgress = false
local lastSideDashEnd = 0
local sideDashMobileBtn = nil
local sideDashBtnSize = 70

local dashRemote = nil
pcall(function()
    dashRemote = ReplicatedStorage:WaitForChild("Keybind", 5)
        :WaitForChild("Combat", 5)
        :WaitForChild("Dash", 5)
        :WaitForChild("Gamepad", 5)
end)

local function moveCharTo(char, cf)
    pcall(function()
        char:PivotTo(cf)
    end)
end

local function getSideDashTarget(maxRange)
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local nearest = nil
    local nearestDist = maxRange

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if not plr.Character:GetAttribute("Dead") then
                    local dist = (myHRP.Position - hrp.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = plr.Character
                    end
                end
            end
        end
    end

    local charsFolder = workspace:FindFirstChild("Characters")
    if charsFolder then
        for _, char in pairs(charsFolder:GetChildren()) do
            if char:IsA("Model") and char ~= myChar then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    if not char:GetAttribute("Dead") then
                        local dist = (myHRP.Position - hrp.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = char
                        end
                    end
                end
            end
        end
    end

    return nearest
end

local function startSideDash()
    if sideDashInProgress then return end
    if tick() - lastSideDashEnd < 0.5 then return end
    if not Toggles.SideDashEnabled or not Toggles.SideDashEnabled.Value then return end

    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    if myChar:GetAttribute("Dead") then return end

    local ragdoll = myChar:GetAttribute("Ragdoll")
    if ragdoll and ragdoll > 0 then return end

    local maxRange = Options.SideDashRange and Options.SideDashRange.Value or 20
    local target = getSideDashTarget(maxRange)
    if not target then print("no target found") return end

    local tHRP = target:FindFirstChild("HumanoidRootPart")
    if not tHRP or not tHRP.Parent then return end

    sideDashInProgress = true

    local stopDist = Options.SideDashDistance and Options.SideDashDistance.Value or 3.0
    local duration = Options.SideDashDuration and Options.SideDashDuration.Value or 0.35
    local camLift = Options.SideDashCamLift and Options.SideDashCamLift.Value or 3.0
    local arcWidth = Options.SideDashArcWidth and Options.SideDashArcWidth.Value or 8

    local startTime = tick()
    local myY = myHRP.Position.Y

    local myStartPos = Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z)
    local targetPos = Vector3.new(tHRP.Position.X, 0, tHRP.Position.Z)

    local targetRightVec = Vector3.new(
        tHRP.CFrame.RightVector.X, 0, tHRP.CFrame.RightVector.Z
    ).Unit

    local targetLookVec = Vector3.new(
        tHRP.CFrame.LookVector.X, 0, tHRP.CFrame.LookVector.Z
    ).Unit

    local toPlayer = myStartPos - targetPos
    local sideSign = toPlayer:Dot(targetRightVec) >= 0 and 1 or -1

    local sidePos = targetPos + (targetRightVec * arcWidth * sideSign)
    local behindPos = targetPos - (targetLookVec * stopDist)

    local animId = sideSign > 0 and RIGHT_DASH_ANIM or LEFT_DASH_ANIM
    print("dashing to", sideSign > 0 and "right" or "left", "using anim:", animId)

    local animator = hum:FindFirstChildOfClass("Animator")
    local dashTrack = nil
    if animator then
        pcall(function()
            local anim = Instance.new("Animation")
            anim.AnimationId = animId
            dashTrack = animator:LoadAnimation(anim)
            dashTrack:Play()
            print("animation playing")
        end)
    end

    local phase1Time = duration * 0.45
    local phase2Time = duration * 0.55

    hum.AutoRotate = false
    local prevCam = Camera.CameraType
    Camera.CameraType = Enum.CameraType.Custom

    local dashTimeout = duration + 1.5

    local conn
    conn = RunService.Heartbeat:Connect(function()
        local now = tick()
        local elapsed = now - startTime

        local function abort()
            pcall(function() conn:Disconnect() end)
            pcall(function()
                if hum and hum.Parent then hum.AutoRotate = true end
            end)
            pcall(function() Camera.CameraType = prevCam end)
            pcall(function()
                if dashTrack then dashTrack:Stop() end
            end)
            sideDashInProgress = false
            lastSideDashEnd = tick()
        end

        if elapsed > dashTimeout then abort() return end
        if not Toggles.SideDashEnabled or not Toggles.SideDashEnabled.Value then abort() return end
        if not target or not target.Parent then abort() return end

        local targetHum = target:FindFirstChildOfClass("Humanoid")
        if not targetHum or targetHum.Health <= 0 then abort() return end
        if target:GetAttribute("Dead") then abort() return end

        tHRP = target:FindFirstChild("HumanoidRootPart")
        if not tHRP or not tHRP.Parent then abort() return end

        myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not myHRP.Parent then abort() return end
        if not hum or hum.Health <= 0 then abort() return end

        local currentY = myHRP.Position.Y
        local currentPos
        local lookTarget

        if elapsed < phase1Time then
            local alpha = math.clamp(elapsed / phase1Time, 0, 1)
            local eased = 1 - (1 - alpha) ^ 2
            currentPos = myStartPos:Lerp(sidePos, eased)
            lookTarget = Vector3.new(tHRP.Position.X, currentY, tHRP.Position.Z)

            pcall(function()
                Camera.CFrame = CFrame.new(
                    myHRP.Position + Vector3.new(0, camLift * alpha, 0),
                    tHRP.Position
                )
            end)

        else
            local phase2Elapsed = elapsed - phase1Time
            local alpha = math.clamp(phase2Elapsed / phase2Time, 0, 1)
            local eased = alpha < 0.5
                and 2 * alpha * alpha
                or 1 - (-2 * alpha + 2) ^ 2 / 2
            currentPos = sidePos:Lerp(behindPos, eased)
            lookTarget = Vector3.new(tHRP.Position.X, currentY, tHRP.Position.Z)

            pcall(function()
                Camera.CFrame = CFrame.new(
                    myHRP.Position + Vector3.new(0, camLift * (1 - alpha), 0),
                    tHRP.Position
                )
            end)
        end

        if currentPos then
            local newCF = CFrame.new(
                Vector3.new(currentPos.X, currentY, currentPos.Z),
                lookTarget
            )
            moveCharTo(myChar, newCF)
        end

        if elapsed >= duration then
            pcall(function()
                if myHRP and myHRP.Parent and tHRP and tHRP.Parent then
                    local finalY = myHRP.Position.Y
                    moveCharTo(myChar, CFrame.new(
                        Vector3.new(behindPos.X, finalY, behindPos.Z),
                        Vector3.new(tHRP.Position.X, finalY, tHRP.Position.Z)
                    ))
                end
            end)
            abort()
        end
    end)
    table.insert(ActiveConnections, conn)
end

local function createSideDashMobileButton()
    if sideDashMobileBtn then return end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SideDashMobileGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local btn = Instance.new("ImageButton")
    btn.Name = "SideDashBtn"
    btn.Size = UDim2.new(0, sideDashBtnSize, 0, sideDashBtnSize)
    btn.Position = UDim2.new(0, 20, 1, -sideDashBtnSize - 140)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BackgroundTransparency = 0.2
    btn.Image = "rbxassetid://11738355467"
    btn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    btn.Visible = true
    btn.ZIndex = 10
    btn.Parent = screenGui

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.25, 0)

    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness = 2
    btnStroke.Transparency = 0.1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "DASH"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.ZIndex = 11
    label.Parent = btn

    local isDragging = false
    local dragStart = nil
    local startBtnPos = nil
    local activeInput = nil
    local tapThreshold = 6

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            activeInput = input
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startBtnPos = Vector2.new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y)
            isDragging = false

            TweenService:Create(btn, TweenInfo.new(0.1), {
                Size = UDim2.new(0, sideDashBtnSize * 0.85, 0, sideDashBtnSize * 0.85)
            }):Play()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == activeInput then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            if delta.Magnitude > tapThreshold then
                isDragging = true
            end
            if isDragging and startBtnPos then
                local finalX = math.clamp(
                    startBtnPos.X + delta.X,
                    0,
                    screenGui.AbsoluteSize.X - sideDashBtnSize
                )
                local finalY = math.clamp(
                    startBtnPos.Y + delta.Y,
                    0,
                    screenGui.AbsoluteSize.Y - sideDashBtnSize
                )
                btn.Position = UDim2.new(0, finalX, 0, finalY)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == activeInput then
            TweenService:Create(btn, TweenInfo.new(0.1), {
                Size = UDim2.new(0, sideDashBtnSize, 0, sideDashBtnSize)
            }):Play()

            if not isDragging then
                startSideDash()
            end

            activeInput = nil
            isDragging = false
            dragStart = nil
            startBtnPos = nil
        end
    end)

    sideDashMobileBtn = screenGui
end

local function removeSideDashMobileButton()
    if sideDashMobileBtn then
        sideDashMobileBtn:Destroy()
        sideDashMobileBtn = nil
    end
end

local sideDashInputConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if not input then return end
    if processed then return end
    if not Toggles.SideDashEnabled or not Toggles.SideDashEnabled.Value then return end

    local keybindOption = Options.SideDashKeybind
    if not keybindOption then return end

    local keybind = keybindOption.Value
    if keybind and input.KeyCode == keybind then
        startSideDash()
    end
end)
table.insert(ActiveConnections, sideDashInputConnection)

table.insert(ActiveConnections, LocalPlayer.CharacterAdded:Connect(function()
    sideDashInProgress = false
    lastSideDashEnd = 0
end))

-- ========================================================
-- TAB LAYOUT & UI COMPONENT BUILDING
-- ========================================================




local function LoadAutoBlock()
-- =========================================================================
-- AUTO BLOCK MODULE (WRAPPED TO BYPASS 200 LOCAL VARIABLES LIMIT)
-- =========================================================================
local math_abs = math.abs
local math_clamp = math.clamp
local math_max = math.max
local math_min = math.min
local math_floor = math.floor
local math_sqrt = math.sqrt
local math_huge = math.huge
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new
local tick = tick
local table_insert = table.insert
local table_remove = table.remove
local table_clear = table.clear
local table_find = table.find
local table_sort = table.sort
local pairs = pairs
local ipairs = ipairs
local pcall = pcall
local type = type
local tostring = tostring
local tonumber = tonumber
local string_lower = string.lower
local string_find = string.find
local string_match = string.match
local string_sub = string.sub
local string_len = string.len
local task_spawn = task.spawn
local task_delay = task.delay
local task_wait = task.wait
local task_cancel = task.cancel
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local getmetatable = getmetatable
local unpack = unpack
local select = select
local next = next

ScriptActive = true

BlockRemoteCache = {
    _activatedRemote = nil,
    _deactivatedRemote = nil,
    _resolved = false,
    _lastResolveAttempt = 0,
}

function BlockRemoteCache:Resolve()
    if self._resolved then return true end
    local now = tick()
    if now - self._lastResolveAttempt < 2 then return false end
    self._lastResolveAttempt = now
    local ok = pcall(function()
        local knit = ReplicatedStorage:WaitForChild("Knit", 3)
        local inner = knit:WaitForChild("Knit", 3)
        local services = inner:WaitForChild("Services", 3)
        local blockService = services:FindFirstChild("BlockService")
        if blockService then
            local re = blockService:FindFirstChild("RE")
            if re then
                self._activatedRemote = re:FindFirstChild("Activated")
                self._deactivatedRemote = re:FindFirstChild("Deactivated")
                if self._activatedRemote and self._deactivatedRemote then
                    self._resolved = true
                end
            end
        end
    end)
    return self._resolved
end

function BlockRemoteCache:GetActivated()
    if not self._resolved then self:Resolve() end
    return self._activatedRemote
end

function BlockRemoteCache:GetDeactivated()
    if not self._resolved then self:Resolve() end
    return self._deactivatedRemote
end

BlockStateMachine = {
    _activeReasons = {},
    _nextId = 0,
    _isBlocking = false,
    _lastBlockTime = 0,
    _releaseTime = 0,
    _totalBlocksActivated = 0,
    _totalBlocksReleased = 0,
    _consecutiveBlocks = 0,
    _lastReason = "",
    _blockStartTime = 0,
    _minHoldThread = nil,
}

function BlockStateMachine:Request(reason, duration)
    self._nextId = self._nextId + 1
    local id = self._nextId
    local now = tick()

    self._activeReasons[id] = {
        reason = reason or "unknown",
        createdAt = now,
        expiresAt = duration and (now + duration) or nil,
        priority = 1,
    }

    if not self._isBlocking then
        local cooldown = Options.BlockCooldown and Options.BlockCooldown.Value or 0
        local timeSinceRelease = now - self._releaseTime
        if timeSinceRelease < cooldown then
            task_delay(cooldown - timeSinceRelease, function()
                if not self._isBlocking then
                    local stillHasReasons = false
                    for _ in pairs(self._activeReasons) do stillHasReasons = true break end
                    if stillHasReasons then
                        self:_activateBlock()
                    end
                end
            end)
        else
            self:_activateBlock()
        end
    end

    self._lastBlockTime = now
    self._lastReason = reason or "unknown"
    return id
end

function BlockStateMachine:_activateBlock()
    if self._isBlocking then return end
    local remote = BlockRemoteCache:GetActivated()
    if remote then
        pcall(function()
            remote:FireServer()
        end)
    end
    self._isBlocking = true
    self._blockStartTime = tick()
    self._totalBlocksActivated = self._totalBlocksActivated + 1
    self._consecutiveBlocks = self._consecutiveBlocks + 1
end

function BlockStateMachine:_deactivateBlock()
    if not self._isBlocking then return end
    local remote = BlockRemoteCache:GetDeactivated()
    if remote then
        pcall(function()
            remote:FireServer()
        end)
    end
    self._isBlocking = false
    self._releaseTime = tick()
    self._totalBlocksReleased = self._totalBlocksReleased + 1
end

function BlockStateMachine:Release(id)
    if id and self._activeReasons[id] then
        self._activeReasons[id] = nil
    end
    self:_evaluateState()
end

function BlockStateMachine:ReleaseAll()
    table_clear(self._activeReasons)
    if self._isBlocking then
        self:_deactivateBlock()
    end
    self._consecutiveBlocks = 0
end

function BlockStateMachine:_evaluateState()
    local now = tick()
    local hasAlive = false

    for id, data in pairs(self._activeReasons) do
        if data.expiresAt and now > data.expiresAt then
            self._activeReasons[id] = nil
        else
            hasAlive = true
        end
    end

    if not hasAlive and self._isBlocking then
        local holdTime = now - self._lastBlockTime
        local minHold = Options.MinBlockHold and Options.MinBlockHold.Value or 0.08
        if holdTime < minHold then
            local delayTime = minHold - holdTime
            if self._minHoldThread then
                pcall(task_cancel, self._minHoldThread)
            end
            self._minHoldThread = task_delay(delayTime, function()
                self._minHoldThread = nil
                local stillEmpty = true
                for _ in pairs(self._activeReasons) do stillEmpty = false break end
                if stillEmpty and self._isBlocking then
                    self:_deactivateBlock()
                    self._consecutiveBlocks = 0
                end
            end)
        else
            self:_deactivateBlock()
            self._consecutiveBlocks = 0
        end
    end
end

function BlockStateMachine:IsBlocking()
    return self._isBlocking
end

function BlockStateMachine:GetActiveCount()
    local count = 0
    for _ in pairs(self._activeReasons) do count = count + 1 end
    return count
end

function BlockStateMachine:GetStats()
    return {
        totalActivated = self._totalBlocksActivated,
        totalReleased = self._totalBlocksReleased,
        consecutiveBlocks = self._consecutiveBlocks,
        lastReason = self._lastReason,
        isBlocking = self._isBlocking,
        activeReasons = self:GetActiveCount(),
        blockDuration = self._isBlocking and (tick() - self._blockStartTime) or 0,
    }
end

function BlockStateMachine:GetReasonsList()
    local reasons = {}
    for id, data in pairs(self._activeReasons) do
        table_insert(reasons, {id = id, reason = data.reason, age = tick() - data.createdAt})
    end
    return reasons
end

table_insert(ActiveConnections, RunService.Heartbeat:Connect(function()
    if BlockStateMachine._isBlocking then
        BlockStateMachine:_evaluateState()
    end
end))

local AttackAnimationRegistry = {}

AttackAnimationRegistry["132748613906344"] = { name = "Gojo.HollowPurple", range = 80, duration = 1.8, isProjectile = true, priority = 10, charClass = "Gojo", threatLevel = 5 }
AttackAnimationRegistry["137654778575373"] = { name = "Gojo.ReversalRed", range = 60, duration = 0.8, isProjectile = true, priority = 8, charClass = "Gojo", threatLevel = 4 }
AttackAnimationRegistry["137865634124104"] = { name = "Gojo.LapseBlue", range = 50, duration = 0.7, isProjectile = true, priority = 8, charClass = "Gojo", threatLevel = 4 }
AttackAnimationRegistry["101162958113766"] = { name = "Gojo.LapseBlueMaximum", range = 60, duration = 1.0, isProjectile = true, priority = 9, charClass = "Gojo", threatLevel = 4 }
AttackAnimationRegistry["84716311536982"] = { name = "Gojo.UltimatePurple", range = 100, duration = 2.0, isProjectile = true, priority = 10, charClass = "Gojo", threatLevel = 5 }
AttackAnimationRegistry["132725601768618"] = { name = "Gojo.InfiniteVoid", range = 100, duration = 2.0, isProjectile = true, priority = 10, charClass = "Gojo", threatLevel = 5 }
AttackAnimationRegistry["95421145178968"] = { name = "Gojo.RapidPunches", range = 20, duration = 1.5, isProjectile = false, priority = 7, charClass = "Gojo", threatLevel = 3 }
AttackAnimationRegistry["127851700400958"] = { name = "Gojo.Melee1", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Gojo", threatLevel = 1 }
AttackAnimationRegistry["72548435296350"] = { name = "Gojo.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Gojo", threatLevel = 1 }
AttackAnimationRegistry["84547415708554"] = { name = "Gojo.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Gojo", threatLevel = 1 }
AttackAnimationRegistry["124937162378188"] = { name = "Gojo.ReversalRedMaximum", range = 65, duration = 1.2, isProjectile = true, priority = 9, charClass = "Gojo", threatLevel = 4 }
AttackAnimationRegistry["104749346956269"] = { name = "Gojo.TwofoldKick", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Gojo", threatLevel = 2 }
AttackAnimationRegistry["132673356426065"] = { name = "Gojo.TwofoldHit", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Gojo", threatLevel = 2 }
AttackAnimationRegistry["116811846715462"] = { name = "Gojo.ShortVoid", range = 50, duration = 1.0, isProjectile = false, priority = 8, charClass = "Gojo", threatLevel = 4 }

AttackAnimationRegistry["77200218033775"] = { name = "Itadori.CursedStrike", range = 18, duration = 0.5, isProjectile = false, priority = 5, charClass = "Itadori", threatLevel = 2 }
AttackAnimationRegistry["124901309160375"] = { name = "Itadori.CrushingBlow", range = 18, duration = 0.5, isProjectile = false, priority = 5, charClass = "Itadori", threatLevel = 2 }
AttackAnimationRegistry["82987093810211"] = { name = "Itadori.ManjiKick", range = 16, duration = 0.5, isProjectile = false, priority = 5, charClass = "Itadori", threatLevel = 2 }
AttackAnimationRegistry["121923107958102"] = { name = "Itadori.SlaughterDemon", range = 18, duration = 0.5, isProjectile = false, priority = 6, charClass = "Itadori", threatLevel = 2 }
AttackAnimationRegistry["111593784328268"] = { name = "Sukuna.Cleave", range = 20, duration = 0.6, isProjectile = false, priority = 7, charClass = "Sukuna", threatLevel = 3 }
AttackAnimationRegistry["131506102901134"] = { name = "Sukuna.Dismantle", range = 45, duration = 0.6, isProjectile = true, priority = 8, charClass = "Sukuna", threatLevel = 4 }
AttackAnimationRegistry["137611726964398"] = { name = "Sukuna.FlameArrow", range = 80, duration = 1.5, isProjectile = true, priority = 9, charClass = "Sukuna", threatLevel = 5 }
AttackAnimationRegistry["121984128639453"] = { name = "Sukuna.MalevolentShrine", range = 100, duration = 2.0, isProjectile = false, priority = 10, charClass = "Sukuna", threatLevel = 5 }
AttackAnimationRegistry["107554693613496"] = { name = "Itadori.Rush", range = 22, duration = 0.8, isProjectile = false, priority = 6, charClass = "Itadori", threatLevel = 3 }
AttackAnimationRegistry["110146909061402"] = { name = "Itadori.Melee1", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Itadori", threatLevel = 1 }
AttackAnimationRegistry["123414935051274"] = { name = "Itadori.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Itadori", threatLevel = 1 }
AttackAnimationRegistry["108636011034323"] = { name = "Itadori.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Itadori", threatLevel = 1 }
AttackAnimationRegistry["105376952884290"] = { name = "Itadori.Melee4", range = 15, duration = 0.40, isProjectile = false, isM1 = true, priority = 3, charClass = "Itadori", threatLevel = 1 }
AttackAnimationRegistry["95295463826732"] = { name = "Heian.Melee1", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Heian", threatLevel = 1 }
AttackAnimationRegistry["105077924973072"] = { name = "Heian.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Heian", threatLevel = 1 }
AttackAnimationRegistry["124862357369335"] = { name = "Heian.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Heian", threatLevel = 1 }
AttackAnimationRegistry["81630213087988"] = { name = "Heian.Melee4", range = 15, duration = 0.40, isProjectile = false, isM1 = true, priority = 3, charClass = "Heian", threatLevel = 1 }
AttackAnimationRegistry["100962226150441"] = { name = "Itadori.DivergentFist1", range = 16, duration = 0.45, isProjectile = false, priority = 5, charClass = "Itadori", threatLevel = 2 }
AttackAnimationRegistry["95852624447551"] = { name = "Itadori.DivergentFist2", range = 16, duration = 0.45, isProjectile = false, priority = 5, charClass = "Itadori", threatLevel = 2 }
AttackAnimationRegistry["74145636023952"] = { name = "Itadori.DivergentFist3", range = 16, duration = 0.45, isProjectile = false, priority = 5, charClass = "Itadori", threatLevel = 2 }
AttackAnimationRegistry["123171106092050"] = { name = "Itadori.DivergentFist4", range = 16, duration = 0.45, isProjectile = false, priority = 5, charClass = "Itadori", threatLevel = 2 }
AttackAnimationRegistry["81633998750531"] = { name = "Itadori.UltimateEnchain", range = 18, duration = 0.5, isProjectile = false, priority = 7, charClass = "Itadori", threatLevel = 3 }
AttackAnimationRegistry["130206074036010"] = { name = "Itadori.Instincts", range = 20, duration = 0.5, isProjectile = false, priority = 6, charClass = "Itadori", threatLevel = 2 }

AttackAnimationRegistry["73243807139765"] = { name = "Ryu.GraniteBlast", range = 120, duration = 1.5, isProjectile = true, priority = 10, charClass = "Ryu", threatLevel = 5 }
AttackAnimationRegistry["70394890117813"] = { name = "Ryu.Appetizer", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Ryu", threatLevel = 2 }
AttackAnimationRegistry["138826705245289"] = { name = "Ryu.SecondHelping", range = 25, duration = 0.7, isProjectile = false, priority = 6, charClass = "Ryu", threatLevel = 3 }
AttackAnimationRegistry["131917532383382"] = { name = "Ryu.ThisDessert", range = 25, duration = 0.7, isProjectile = false, priority = 6, charClass = "Ryu", threatLevel = 3 }
AttackAnimationRegistry["86568794583359"] = { name = "Ryu.WhatAreYouAfter", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Ryu", threatLevel = 2 }
AttackAnimationRegistry["86463226245064"] = { name = "Ryu.WerentInvited", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Ryu", threatLevel = 2 }
AttackAnimationRegistry["116910683335467"] = { name = "Ryu.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Ryu", threatLevel = 1 }
AttackAnimationRegistry["121322029260156"] = { name = "Ryu.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Ryu", threatLevel = 1 }
AttackAnimationRegistry["92698956945928"] = { name = "Ryu.Melee3_Alt", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Ryu", threatLevel = 1 }
AttackAnimationRegistry["113479860283691"] = { name = "Ryu.UltimateBlast", range = 100, duration = 2.0, isProjectile = true, priority = 10, charClass = "Ryu", threatLevel = 5 }

AttackAnimationRegistry["127171275866632"] = { name = "Choso.PiercingBlood", range = 100, duration = 1.0, isProjectile = true, priority = 9, charClass = "Choso", threatLevel = 5 }
AttackAnimationRegistry["85569553424083"] = { name = "Choso.Supernova", range = 30, duration = 0.8, isProjectile = true, priority = 7, charClass = "Choso", threatLevel = 3 }
AttackAnimationRegistry["100446064103831"] = { name = "Choso.BloodEdge", range = 20, duration = 0.5, isProjectile = false, priority = 5, charClass = "Choso", threatLevel = 2 }
AttackAnimationRegistry["132928484483887"] = { name = "Choso.Hairpin", range = 40, duration = 0.6, isProjectile = true, priority = 7, charClass = "Choso", threatLevel = 3 }
AttackAnimationRegistry["114321791577837"] = { name = "Choso.SlicingExorcism", range = 25, duration = 0.6, isProjectile = false, priority = 6, charClass = "Choso", threatLevel = 3 }
AttackAnimationRegistry["117371289990421"] = { name = "Choso.BloodRain", range = 35, duration = 0.8, isProjectile = false, priority = 7, charClass = "Choso", threatLevel = 3 }
AttackAnimationRegistry["95097480425566"] = { name = "Choso.WingKing", range = 50, duration = 1.2, isProjectile = true, priority = 8, charClass = "Choso", threatLevel = 4 }
AttackAnimationRegistry["119042572747325"] = { name = "Choso.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Choso", threatLevel = 1 }
AttackAnimationRegistry["105287938257399"] = { name = "Choso.Melee4", range = 15, duration = 0.40, isProjectile = false, isM1 = true, priority = 3, charClass = "Choso", threatLevel = 1 }

AttackAnimationRegistry["72063002791216"] = { name = "Hakari.ShutterDoors", range = 25, duration = 0.6, isProjectile = true, priority = 6, charClass = "Hakari", threatLevel = 3 }
AttackAnimationRegistry["72467492674240"] = { name = "Hakari.RoughEnergy", range = 20, duration = 0.5, isProjectile = false, priority = 5, charClass = "Hakari", threatLevel = 2 }
AttackAnimationRegistry["82541714192027"] = { name = "Hakari.ReserveBalls", range = 40, duration = 0.6, isProjectile = true, priority = 7, charClass = "Hakari", threatLevel = 3 }
AttackAnimationRegistry["95901746347992"] = { name = "Hakari.LuckyVolley", range = 30, duration = 0.6, isProjectile = false, priority = 6, charClass = "Hakari", threatLevel = 3 }
AttackAnimationRegistry["108123475959041"] = { name = "Hakari.FeverBreaker", range = 25, duration = 0.7, isProjectile = false, priority = 6, charClass = "Hakari", threatLevel = 3 }
AttackAnimationRegistry["140588454098230"] = { name = "Hakari.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Hakari", threatLevel = 1 }
AttackAnimationRegistry["138826758216894"] = { name = "Hakari.Melee4", range = 15, duration = 0.40, isProjectile = false, isM1 = true, priority = 3, charClass = "Hakari", threatLevel = 1 }

AttackAnimationRegistry["116432619539029"] = { name = "Megumi.Toad", range = 40, duration = 0.6, isProjectile = true, priority = 7, charClass = "Megumi", threatLevel = 3 }
AttackAnimationRegistry["111077341852080"] = { name = "Megumi.Nue", range = 40, duration = 0.7, isProjectile = true, priority = 7, charClass = "Megumi", threatLevel = 3 }
AttackAnimationRegistry["81112033595734"] = { name = "Megumi.DivineDog", range = 30, duration = 0.6, isProjectile = true, priority = 6, charClass = "Megumi", threatLevel = 3 }
AttackAnimationRegistry["75390215999547"] = { name = "Megumi.GreatSerpent", range = 35, duration = 0.6, isProjectile = false, priority = 6, charClass = "Megumi", threatLevel = 3 }
AttackAnimationRegistry["115683433001643"] = { name = "Megumi.DivinePummel", range = 25, duration = 0.8, isProjectile = false, priority = 7, charClass = "Megumi", threatLevel = 3 }
AttackAnimationRegistry["138852224035589"] = { name = "Megumi.GroundPitch", range = 30, duration = 0.6, isProjectile = false, priority = 6, charClass = "Megumi", threatLevel = 3 }
AttackAnimationRegistry["85024950165903"] = { name = "Megumi.Earthquake", range = 30, duration = 0.7, isProjectile = false, priority = 7, charClass = "Megumi", threatLevel = 3 }
AttackAnimationRegistry["131219281339199"] = { name = "Megumi.MaxElephant", range = 40, duration = 0.8, isProjectile = true, priority = 8, charClass = "Megumi", threatLevel = 4 }
AttackAnimationRegistry["138489871864252"] = { name = "Megumi.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Megumi", threatLevel = 1 }

AttackAnimationRegistry["89092734635186"] = { name = "Mahito.Soulfire", range = 30, duration = 0.6, isProjectile = true, priority = 7, charClass = "Mahito", threatLevel = 3 }
AttackAnimationRegistry["127727754867974"] = { name = "Mahito.SpikeWrath", range = 25, duration = 0.7, isProjectile = false, priority = 6, charClass = "Mahito", threatLevel = 3 }
AttackAnimationRegistry["105068005007692"] = { name = "Mahito.FaceBlitz", range = 20, duration = 0.5, isProjectile = false, priority = 5, charClass = "Mahito", threatLevel = 2 }
AttackAnimationRegistry["108319980293313"] = { name = "Mahito.BodyRepel", range = 30, duration = 0.7, isProjectile = false, priority = 6, charClass = "Mahito", threatLevel = 3 }
AttackAnimationRegistry["76313364850487"] = { name = "Mahito.WideStrike", range = 25, duration = 0.6, isProjectile = false, priority = 6, charClass = "Mahito", threatLevel = 3 }
AttackAnimationRegistry["94223344057046"] = { name = "Mahito.HeartPiercer", range = 22, duration = 0.6, isProjectile = false, priority = 6, charClass = "Mahito", threatLevel = 3 }
AttackAnimationRegistry["128779949980528"] = { name = "Mahito.DrillSplit", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Mahito", threatLevel = 2 }
AttackAnimationRegistry["86073608599582"] = { name = "Mahito.HeadSplitter", range = 20, duration = 0.5, isProjectile = false, priority = 5, charClass = "Mahito", threatLevel = 2 }

AttackAnimationRegistry["94720627091769"] = { name = "Todo.SwiftKick", range = 18, duration = 0.5, isProjectile = false, priority = 5, charClass = "Todo", threatLevel = 2 }
AttackAnimationRegistry["111720035828971"] = { name = "Todo.PebbleThrow", range = 50, duration = 0.6, isProjectile = true, priority = 7, charClass = "Todo", threatLevel = 3 }
AttackAnimationRegistry["136536827155962"] = { name = "Todo.BruteForce", range = 15, duration = 0.5, isProjectile = false, priority = 5, charClass = "Todo", threatLevel = 2 }
AttackAnimationRegistry["121343824534765"] = { name = "Todo.ElbowDrop", range = 18, duration = 0.6, isProjectile = false, priority = 5, charClass = "Todo", threatLevel = 2 }
AttackAnimationRegistry["107029561762376"] = { name = "Todo.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Todo", threatLevel = 1 }
AttackAnimationRegistry["117831239064143"] = { name = "Todo.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Todo", threatLevel = 1 }

AttackAnimationRegistry["124340599144108"] = { name = "Hiromi.TwirlingStrikes", range = 18, duration = 0.6, isProjectile = false, priority = 5, charClass = "Hiromi", threatLevel = 2 }
AttackAnimationRegistry["132754851925571"] = { name = "Hiromi.Verdict", range = 20, duration = 0.5, isProjectile = false, priority = 5, charClass = "Hiromi", threatLevel = 2 }
AttackAnimationRegistry["86362077638309"] = { name = "Hiromi.GavelThrow", range = 40, duration = 0.6, isProjectile = true, priority = 7, charClass = "Hiromi", threatLevel = 3 }
AttackAnimationRegistry["124243904748268"] = { name = "Hiromi.TripleSentence", range = 22, duration = 0.7, isProjectile = false, priority = 6, charClass = "Hiromi", threatLevel = 3 }
AttackAnimationRegistry["124759375124281"] = { name = "Hiromi.JudgeReach", range = 25, duration = 0.6, isProjectile = false, priority = 6, charClass = "Hiromi", threatLevel = 3 }
AttackAnimationRegistry["122573730331631"] = { name = "Hiromi.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Hiromi", threatLevel = 1 }
AttackAnimationRegistry["82400997593751"] = { name = "Hiromi.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Hiromi", threatLevel = 1 }
AttackAnimationRegistry["118634493886688"] = { name = "Hiromi.Melee4", range = 15, duration = 0.40, isProjectile = false, isM1 = true, priority = 3, charClass = "Hiromi", threatLevel = 1 }

AttackAnimationRegistry["80465501985014"] = { name = "Mechamaru.MiracleCannon", range = 80, duration = 1.0, isProjectile = true, priority = 9, charClass = "Mechamaru", threatLevel = 5 }
AttackAnimationRegistry["118652212972529"] = { name = "Mechamaru.GunShot", range = 60, duration = 0.6, isProjectile = true, priority = 8, charClass = "Mechamaru", threatLevel = 4 }
AttackAnimationRegistry["93901924492394"] = { name = "Mechamaru.UltraCannon", range = 100, duration = 1.5, isProjectile = true, priority = 10, charClass = "Mechamaru", threatLevel = 5 }
AttackAnimationRegistry["137638103122538"] = { name = "Mechamaru.AbsoluteDestruction", range = 100, duration = 2.0, isProjectile = true, priority = 10, charClass = "Mechamaru", threatLevel = 5 }
AttackAnimationRegistry["89009042593684"] = { name = "Mechamaru.PigeonViola", range = 70, duration = 1.0, isProjectile = true, priority = 8, charClass = "Mechamaru", threatLevel = 4 }
AttackAnimationRegistry["114277419400774"] = { name = "Mechamaru.HeatEmission", range = 30, duration = 0.7, isProjectile = false, priority = 6, charClass = "Mechamaru", threatLevel = 3 }
AttackAnimationRegistry["85148168523745"] = { name = "Mechamaru.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Mechamaru", threatLevel = 1 }
AttackAnimationRegistry["108686045412945"] = { name = "Mechamaru.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Mechamaru", threatLevel = 1 }

AttackAnimationRegistry["104793932628579"] = { name = "Yuki.MassBreaker", range = 25, duration = 0.7, isProjectile = false, priority = 6, charClass = "Yuki", threatLevel = 3 }
AttackAnimationRegistry["94347210073500"] = { name = "Yuki.RisingStar", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Yuki", threatLevel = 2 }
AttackAnimationRegistry["77833820443705"] = { name = "Yuki.GarudaStab", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Yuki", threatLevel = 2 }
AttackAnimationRegistry["115097960689033"] = { name = "Yuki.GarudaRebound", range = 25, duration = 0.6, isProjectile = false, priority = 6, charClass = "Yuki", threatLevel = 3 }
AttackAnimationRegistry["72575786212990"] = { name = "Yuki.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Yuki", threatLevel = 1 }
AttackAnimationRegistry["119248903710146"] = { name = "Yuki.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Yuki", threatLevel = 1 }

AttackAnimationRegistry["81971779090581"] = { name = "Goku.Kamehameha", range = 120, duration = 1.5, isProjectile = true, priority = 10, charClass = "Goku", threatLevel = 5 }
AttackAnimationRegistry["87481059409847"] = { name = "Goku.StaffExtend", range = 50, duration = 0.6, isProjectile = true, priority = 7, charClass = "Goku", threatLevel = 3 }
AttackAnimationRegistry["128537969081721"] = { name = "Goku.KiSpam", range = 80, duration = 1.5, isProjectile = true, priority = 9, charClass = "Goku", threatLevel = 5 }
AttackAnimationRegistry["117318845383884"] = { name = "Goku.StaffUppercut", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Goku", threatLevel = 2 }
AttackAnimationRegistry["97215638330770"] = { name = "Goku.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Goku", threatLevel = 1 }
AttackAnimationRegistry["100474683542881"] = { name = "Goku.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Goku", threatLevel = 1 }

AttackAnimationRegistry["89582140026963"] = { name = "Yuta.ResoluteSlash", range = 25, duration = 0.6, isProjectile = false, priority = 6, charClass = "Yuta", threatLevel = 3 }
AttackAnimationRegistry["116737527523542"] = { name = "Yuta.LoveBeam", range = 80, duration = 1.2, isProjectile = true, priority = 9, charClass = "Yuta", threatLevel = 5 }
AttackAnimationRegistry["74676954665401"] = { name = "Yuta.Slam", range = 25, duration = 0.6, isProjectile = false, priority = 6, charClass = "Yuta", threatLevel = 3 }
AttackAnimationRegistry["95169958463123"] = { name = "Yuta.Throw", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Yuta", threatLevel = 2 }
AttackAnimationRegistry["140288981168553"] = { name = "Yuta.Smash", range = 25, duration = 0.6, isProjectile = false, priority = 6, charClass = "Yuta", threatLevel = 3 }
AttackAnimationRegistry["73482562876920"] = { name = "Yuta.JacobLadder", range = 60, duration = 1.5, isProjectile = true, priority = 9, charClass = "Yuta", threatLevel = 5 }
AttackAnimationRegistry["88005970155216"] = { name = "Yuta.CursedSpeech", range = 35, duration = 0.8, isProjectile = false, priority = 7, charClass = "Yuta", threatLevel = 3 }
AttackAnimationRegistry["130806585141471"] = { name = "Yuta.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Yuta", threatLevel = 1 }
AttackAnimationRegistry["131967150738931"] = { name = "Yuta.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Yuta", threatLevel = 1 }

AttackAnimationRegistry["105121164520635"] = { name = "Naoya.ProjectionBreaker", range = 25, duration = 0.6, isProjectile = false, priority = 6, charClass = "Naoya", threatLevel = 3 }
AttackAnimationRegistry["122607727974119"] = { name = "Naoya.Flicker", range = 20, duration = 0.5, isProjectile = false, priority = 5, charClass = "Naoya", threatLevel = 2 }
AttackAnimationRegistry["86045680364061"] = { name = "Naoya.DecisiveStrike", range = 20, duration = 0.5, isProjectile = false, priority = 5, charClass = "Naoya", threatLevel = 2 }
AttackAnimationRegistry["129944486689528"] = { name = "Naoya.Acceleration", range = 30, duration = 0.8, isProjectile = false, priority = 7, charClass = "Naoya", threatLevel = 3 }
AttackAnimationRegistry["108708446862011"] = { name = "Naoya.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Naoya", threatLevel = 1 }
AttackAnimationRegistry["77583711129628"] = { name = "Naoya.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Naoya", threatLevel = 1 }

AttackAnimationRegistry["100811576955331"] = { name = "Nanami.BluntCut", range = 18, duration = 0.5, isProjectile = false, priority = 5, charClass = "Nanami", threatLevel = 2 }
AttackAnimationRegistry["122015481201264"] = { name = "Nanami.Collapse", range = 25, duration = 0.7, isProjectile = false, priority = 6, charClass = "Nanami", threatLevel = 3 }
AttackAnimationRegistry["130957217409359"] = { name = "Nanami.SeveranceKick", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Nanami", threatLevel = 2 }
AttackAnimationRegistry["79436586236026"] = { name = "Nanami.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Nanami", threatLevel = 1 }
AttackAnimationRegistry["102285403332509"] = { name = "Nanami.Melee3", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Nanami", threatLevel = 1 }

AttackAnimationRegistry["103960582499076"] = { name = "Haruta.AnkleCutter", range = 15, duration = 0.5, isProjectile = false, priority = 5, charClass = "Haruta", threatLevel = 2 }
AttackAnimationRegistry["118326207788271"] = { name = "Haruta.Jawbreaker", range = 15, duration = 0.5, isProjectile = false, priority = 5, charClass = "Haruta", threatLevel = 2 }
AttackAnimationRegistry["133303451091615"] = { name = "Haruta.Backstab", range = 16, duration = 0.5, isProjectile = false, priority = 5, charClass = "Haruta", threatLevel = 2 }
AttackAnimationRegistry["113963875117859"] = { name = "Haruta.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Haruta", threatLevel = 1 }

AttackAnimationRegistry["139956651661073"] = { name = "MeiMei.Bounding", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "MeiMei", threatLevel = 2 }
AttackAnimationRegistry["99180695169591"] = { name = "MeiMei.BirdCall", range = 50, duration = 0.7, isProjectile = true, priority = 7, charClass = "MeiMei", threatLevel = 3 }
AttackAnimationRegistry["108449614447004"] = { name = "MeiMei.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "MeiMei", threatLevel = 1 }

AttackAnimationRegistry["113722638806911"] = { name = "Hanami.RootSwarm", range = 35, duration = 0.7, isProjectile = false, priority = 6, charClass = "Hanami", threatLevel = 3 }
AttackAnimationRegistry["96466374346823"] = { name = "Hanami.BudShot", range = 50, duration = 0.6, isProjectile = true, priority = 7, charClass = "Hanami", threatLevel = 3 }
AttackAnimationRegistry["92595499555055"] = { name = "Hanami.SurgingThorns", range = 30, duration = 0.7, isProjectile = false, priority = 6, charClass = "Hanami", threatLevel = 3 }
AttackAnimationRegistry["88849926869776"] = { name = "Hanami.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Hanami", threatLevel = 1 }

AttackAnimationRegistry["116119661056362"] = { name = "Kurourushi.RoachSwarm", range = 40, duration = 0.8, isProjectile = true, priority = 7, charClass = "Kurourushi", threatLevel = 3 }
AttackAnimationRegistry["83430571986421"] = { name = "Kurourushi.FesteringStrikes", range = 20, duration = 0.6, isProjectile = false, priority = 5, charClass = "Kurourushi", threatLevel = 2 }
AttackAnimationRegistry["93751660565233"] = { name = "Kurourushi.EarthenTrance", range = 30, duration = 0.7, isProjectile = false, priority = 6, charClass = "Kurourushi", threatLevel = 3 }
AttackAnimationRegistry["86519781516542"] = { name = "Kurourushi.Melee2", range = 15, duration = 0.35, isProjectile = false, isM1 = true, priority = 3, charClass = "Kurourushi", threatLevel = 1 }

local LongRangeAttackIds = {
    ["132748613906344"] = true,
    ["84716311536982"] = true,
    ["132725601768618"] = true,
    ["137654778575373"] = true,
    ["137865634124104"] = true,
    ["101162958113766"] = true,
    ["124937162378188"] = true,
    ["73243807139765"] = true,
    ["113479860283691"] = true,
    ["127171275866632"] = true,
    ["95097480425566"] = true,
    ["131506102901134"] = true,
    ["137611726964398"] = true,
    ["121984128639453"] = true,
    ["80465501985014"] = true,
    ["93901924492394"] = true,
    ["137638103122538"] = true,
    ["89009042593684"] = true,
    ["118652212972529"] = true,
    ["81971779090581"] = true,
    ["128537969081721"] = true,
    ["116737527523542"] = true,
    ["73482562876920"] = true,
    ["111720035828971"] = true,
    ["86362077638309"] = true,
    ["99180695169591"] = true,
    ["96466374346823"] = true,
    ["116119661056362"] = true,
    ["87481059409847"] = true,
    ["132928484483887"] = true,
    ["82541714192027"] = true,
    ["116432619539029"] = true,
    ["111077341852080"] = true,
    ["81112033595734"] = true,
    ["131219281339199"] = true,
    ["89092734635186"] = true,
    ["85569553424083"] = true,
    ["72063002791216"] = true,
}

local LongRangeTimingOverrides = {
    ["132748613906344"] = { preBlockMs = 150, holdDurationMs = 2000 },
    ["84716311536982"] = { preBlockMs = 200, holdDurationMs = 2200 },
    ["132725601768618"] = { preBlockMs = 200, holdDurationMs = 2200 },
    ["73243807139765"] = { preBlockMs = 100, holdDurationMs = 1700 },
    ["113479860283691"] = { preBlockMs = 200, holdDurationMs = 2200 },
    ["127171275866632"] = { preBlockMs = 50, holdDurationMs = 1200 },
    ["137611726964398"] = { preBlockMs = 150, holdDurationMs = 1700 },
    ["121984128639453"] = { preBlockMs = 250, holdDurationMs = 2500 },
    ["80465501985014"] = { preBlockMs = 100, holdDurationMs = 1200 },
    ["93901924492394"] = { preBlockMs = 150, holdDurationMs = 1700 },
    ["137638103122538"] = { preBlockMs = 200, holdDurationMs = 2200 },
    ["81971779090581"] = { preBlockMs = 100, holdDurationMs = 1700 },
    ["128537969081721"] = { preBlockMs = 150, holdDurationMs = 1700 },
    ["116737527523542"] = { preBlockMs = 100, holdDurationMs = 1400 },
    ["73482562876920"] = { preBlockMs = 150, holdDurationMs = 1700 },
    ["131506102901134"] = { preBlockMs = 80, holdDurationMs = 800 },
    ["89009042593684"] = { preBlockMs = 100, holdDurationMs = 1200 },
    ["118652212972529"] = { preBlockMs = 50, holdDurationMs = 800 },
}

local MovementFilterKeywords = {
    "run", "chase", "down", "fall", "ragdoll", "idle",
    "walk", "jump", "dash", "climb", "getup", "land",
    "sprint", "movement", "turn", "halt", "hover", "sleep",
    "emote", "spawn", "dance", "wave", "sit", "block",
    "equip", "unequip", "sheath", "unsheath", "holster",
    "swim", "freefall", "climbidle", "crouch", "prone",
    "stun", "recover", "wind", "breathe", "loop", "breathing",
    "aura", "charge", "power", "transform", "shift", "activate", "idleloop",
    "stance", "guard", "parry", "counter", "deflect", "evade",
    "awaken", "mode", "form", "intro", "outro", "cinematic",
    "taunt", "celebrate", "victory", "defeat", "death", "die",
    "pickup", "interact", "use", "consume", "eat", "drink",
    "revive", "respawn", "tp", "teleport", "warp", "phase",
    "float", "fly", "glide", "soar", "levitate", "ascend",
    "descend", "mount", "dismount", "ride", "vehicle", "board",
}

local NonAttackPatterns = {
    "effect", "particle", "sound", "camera", "shake",
    "flash", "screen", "ui", "menu", "cursor",
    "blink", "talk", "look", "point", "nod", "shakehead",
    "shrug", "grab", "carry", "hold", "lift", "push", "pull",
    "heal", "revive", "buff", "debuff", "shield",
    "barrier", "teleport", "dodge", "roll", "slide",
    "grapple", "web", "swing", "success", "user",
    "victim", "hit", "warn", "stun", "ragdoll", "knockback", "reaction", "stagger",
    "notification", "alert", "popup", "toast", "badge",
    "loading", "progress", "bar", "meter", "gauge",
    "footstep", "cloth", "hair", "cape", "tail", "wing",
    "ambient", "environment", "weather", "rain", "snow",
    "expression", "face", "eye", "mouth", "brow",
    "gesture", "signal", "callout", "ping", "mark",
    "overlay", "hud", "indicator", "reticle", "crosshair",
}

local AttackIndicatorKeywords = {
    "attack", "slash", "strike", "kick", "punch", "melee",
    "swing", "smash", "slam", "crush", "cleave", "cut",
    "stab", "pierce", "thrust", "jab", "hook", "uppercut",
    "combo", "finisher", "barrage", "flurry", "rush",
    "shoot", "fire", "blast", "beam", "cannon", "shot",
    "throw", "toss", "hurl", "launch", "fling",
    "skill", "ability", "special", "ultimate", "ult",
    "m1", "m2", "heavy", "light",
    "damage", "hurt", "pain", "destroy", "break",
    "explode", "detonate", "burst", "shatter", "crack",
    "bite", "claw", "rip", "tear", "rend",
    "whip", "lash", "flail", "batter", "pummel",
    "chop", "hack", "slice", "dice", "mince",
    "impale", "skewer", "gore", "maul", "mangle",
    "bombard", "volley", "salvo", "fusillade", "rain",
    "decimate", "annihilate", "obliterate", "eradicate",
}

DynamicAnimationCache = {}
DynamicCacheHits = 0
DynamicCacheMisses = 0
local DynamicCacheMaxSize = 2048

local function PurgeOldestCacheEntries()
    local count = 0
    for _ in pairs(DynamicAnimationCache) do count = count + 1 end
    if count < DynamicCacheMaxSize then return end
    local entries = {}
    for id, data in pairs(DynamicAnimationCache) do
        table_insert(entries, {id = id, lastSeen = data.lastSeen or 0})
    end
    table_sort(entries, function(a, b) return a.lastSeen < b.lastSeen end)
    local removeCount = math_floor(#entries * 0.3)
    for i = 1, removeCount do
        DynamicAnimationCache[entries[i].id] = nil
    end
end

local function GetLocalCharacter()
    return LocalPlayer and LocalPlayer.Character
end

local function GetLocalRoot()
    local char = GetLocalCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetLocalHumanoid()
    local char = GetLocalCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function IsLocalPlayerAlive()
    local char = GetLocalCharacter()
    if not char then return false end
    if char:GetAttribute("Dead") then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    return true
end

local function IsLocalPlayerIncapacitated()
    local char = GetLocalCharacter()
    if not char then return true end
    if char:GetAttribute("Dead") then return true end
    local ragdollVal = char:GetAttribute("Ragdoll")
    if ragdollVal and ragdollVal > 0 then return true end
    if char:GetAttribute("Stun") == true then return true end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
    return false
end

local function IsLocalPlayerAttacking()
    local char = GetLocalCharacter()
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return false end

    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        if track.IsPlaying and track.Animation then
            local animName = string_lower(track.Animation.Name)
            local rawId = tostring(track.Animation.AnimationId):match("%d+")
            if rawId and AttackAnimationRegistry[rawId] then
                return true
            end
            local isMovement = false
            for i = 1, #MovementFilterKeywords do
                if string_find(animName, MovementFilterKeywords[i]) then
                    isMovement = true
                    break
                end
            end
            if not isMovement then
                local isNonAttack = false
                for i = 1, #NonAttackPatterns do
                    if string_find(animName, NonAttackPatterns[i]) then
                        isNonAttack = true
                        break
                    end
                end
                if not isNonAttack then
                    for i = 1, #AttackIndicatorKeywords do
                        if string_find(animName, AttackIndicatorKeywords[i]) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

local function IsCharacterAlive(character)
    if not character or not character.Parent then return false end
    if character:GetAttribute("Dead") then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return false end
    return true
end

local function IsCharacterIncapacitated(character)
    if not character then return true end
    if character:GetAttribute("Dead") then return true end
    local ragdollVal = character:GetAttribute("Ragdoll")
    if ragdollVal and ragdollVal > 0 then return true end
    if character:GetAttribute("Stun") == true then return true end
    return false
end

local function GetDistanceBetween(rootA, rootB)
    if not rootA or not rootB then return math_huge end
    return (rootA.Position - rootB.Position).Magnitude
end

local function GetFacingDot(attackerRoot, defenderRoot)
    if not attackerRoot or not defenderRoot then return -1 end
    local enemyLookVector = attackerRoot.CFrame.LookVector
    local directionToDefender = (defenderRoot.Position - attackerRoot.Position).Unit
    return enemyLookVector:Dot(directionToDefender)
end

local function GetVelocityTowardTarget(partPos, partVelocity, targetPos)
    if not partPos or not partVelocity or not targetPos then return 0, -1 end
    local speed = partVelocity.Magnitude
    if speed < 1 then return 0, -1 end
    local dirToTarget = (targetPos - partPos).Unit
    local velDir = partVelocity.Unit
    local dot = velDir:Dot(dirToTarget)
    return speed, dot
end

local function IsEnemyFeinting(character)
    if not Toggles.AntiFeintEnabled or not Toggles.AntiFeintEnabled.Value then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local feintInstance = rootPart:FindFirstChild("Feint")
    if feintInstance then
        local ringParticle = feintInstance:FindFirstChild("Ring")
        if ringParticle and ringParticle:IsA("ParticleEmitter") then
            for _, keypoint in ipairs(ringParticle.Color.Keypoints) do
                local val = keypoint.Value
                if math_abs(val.R - val.G) < 0.05 and math_abs(val.G - val.B) < 0.05 then
                    return true
                end
            end
        end
    end

    if character:GetAttribute("Feinting") then return true end

    local moveset = character:FindFirstChild("Moveset")
    if moveset then
        local feintVal = moveset:FindFirstChild("Feint")
        if feintVal and feintVal:IsA("BoolValue") and feintVal.Value then
            return true
        end
    end

    return false
end

local function ClassifyAnimation(animationTrack)
    if not animationTrack or not animationTrack.Animation then
        return false, false, 0, nil
    end

    local animId = animationTrack.Animation.AnimationId
    local animName = animationTrack.Animation.Name
    local lowerName = string_lower(animName)
    local rawId = tostring(animId):match("%d+")

    if rawId and AttackAnimationRegistry[rawId] then
        local reg = AttackAnimationRegistry[rawId]
        local priority = reg.priority or (reg.isM1 and 3 or 1)
        return true, reg.isProjectile or false, priority, reg
    end

    if rawId and DynamicAnimationCache[rawId] then
        local cached = DynamicAnimationCache[rawId]
        cached.lastSeen = tick()
        DynamicCacheHits = DynamicCacheHits + 1
        return cached.isAttack, cached.isProjectile, cached.priority, cached.regInfo
    end

    DynamicCacheMisses = DynamicCacheMisses + 1

    for i = 1, #MovementFilterKeywords do
        if string_find(lowerName, MovementFilterKeywords[i]) then
            if rawId then
                DynamicAnimationCache[rawId] = {
                    isAttack = false, isProjectile = false, priority = 0, regInfo = nil, lastSeen = tick()
                }
            end
            PurgeOldestCacheEntries()
            return false, false, 0, nil
        end
    end

    for i = 1, #NonAttackPatterns do
        if string_find(lowerName, NonAttackPatterns[i]) then
            if rawId then
                DynamicAnimationCache[rawId] = {
                    isAttack = false, isProjectile = false, priority = 0, regInfo = nil, lastSeen = tick()
                }
            end
            PurgeOldestCacheEntries()
            return false, false, 0, nil
        end
    end

    local hasAttackKeyword = false
    for i = 1, #AttackIndicatorKeywords do
        if string_find(lowerName, AttackIndicatorKeywords[i]) then
            hasAttackKeyword = true
            break
        end
    end

    if not hasAttackKeyword then
        if rawId then
            DynamicAnimationCache[rawId] = {
                isAttack = false, isProjectile = false, priority = 0, regInfo = nil, lastSeen = tick()
            }
        end
        PurgeOldestCacheEntries()
        return false, false, 0, nil
    end

    local trackLength = 0
    pcall(function() trackLength = animationTrack.Length end)

    if trackLength > 0 and trackLength < 0.2 then
        if rawId then
            DynamicAnimationCache[rawId] = {
                isAttack = false, isProjectile = false, priority = 0, regInfo = nil, lastSeen = tick()
            }
        end
        PurgeOldestCacheEntries()
        return false, false, 0, nil
    end

    local priority = 2
    if animationTrack.Speed and animationTrack.Speed > 1.5 then
        priority = 3
    end

    local fallbackReg = {
        name = "Dynamic." .. animName,
        range = 20,
        duration = trackLength > 0 and math_min(trackLength, 1.5) or 0.5,
        isProjectile = false,
        priority = priority,
        charClass = "Unknown",
        threatLevel = 2,
        isDynamic = true,
    }

    if rawId then
        DynamicAnimationCache[rawId] = {
            isAttack = true, isProjectile = false, priority = priority, regInfo = fallbackReg, lastSeen = tick()
        }
    end
    PurgeOldestCacheEntries()

    return true, false, priority, fallbackReg
end

local CombatTracker = {
    _inCombatWith = {},
    _lastCombatTime = 0,
    _combatTimeout = 5.0,
}

function CombatTracker:MarkCombat(character)
    local charName = character.Name
    self._inCombatWith[charName] = tick()
    self._lastCombatTime = tick()
end

function CombatTracker:IsInCombatWith(character)
    local charName = character.Name
    local lastTime = self._inCombatWith[charName]
    if not lastTime then return false end
    if tick() - lastTime > self._combatTimeout then
        self._inCombatWith[charName] = nil
        return false
    end
    return true
end

function CombatTracker:IsInAnyCombat()
    local now = tick()
    for charName, lastTime in pairs(self._inCombatWith) do
        if now - lastTime > self._combatTimeout then
            self._inCombatWith[charName] = nil
        else
            return true
        end
    end
    return false
end

function CombatTracker:Cleanup()
    local now = tick()
    for charName, lastTime in pairs(self._inCombatWith) do
        if now - lastTime > self._combatTimeout then
            self._inCombatWith[charName] = nil
        end
    end
end

EnemyTracker = {
    _enemies = {},
    _totalTracked = 0,
    _totalReleased = 0,
}

function EnemyTracker:TrackAttack(character, animTrack, isProjectile, regInfo)
    local charName = character:GetFullName()
    if not self._enemies[charName] then
        self._enemies[charName] = {
            attacks = {},
            blockIds = {},
            character = character,
            firstAttackTime = tick(),
            totalAttacks = 0,
        }
    end

    local enemyData = self._enemies[charName]
    local trackId = tostring(animTrack)

    if enemyData.attacks[trackId] then return end

    CombatTracker:MarkCombat(character)

    enemyData.totalAttacks = enemyData.totalAttacks + 1
    self._totalTracked = self._totalTracked + 1

    enemyData.attacks[trackId] = {
        track = animTrack,
        startedAt = tick(),
        isProjectile = isProjectile,
        regInfo = regInfo,
    }

    local duration = nil
    local rawId = nil
    if animTrack.Animation then
        rawId = tostring(animTrack.Animation.AnimationId):match("%d+")
    end

    if rawId and LongRangeTimingOverrides[rawId] then
        local override = LongRangeTimingOverrides[rawId]
        duration = override.holdDurationMs / 1000
    elseif regInfo and regInfo.duration then
        duration = regInfo.duration
    elseif Toggles.BlockForAnimation and Toggles.BlockForAnimation.Value then
        duration = nil
    elseif Toggles.BlockForDuration and Toggles.BlockForDuration.Value then
        duration = Options.BlockDuration and Options.BlockDuration.Value or 0.5
    else
        duration = 0.6
    end

    local reason = "anim_"
    if regInfo then
        reason = reason .. regInfo.name .. "_" .. charName
    elseif isProjectile then
        reason = reason .. "proj_" .. charName
    else
        reason = reason .. "melee_" .. charName
    end

    local blockId = BlockStateMachine:Request(reason, duration)
    table_insert(enemyData.blockIds, blockId)

    local stoppedConn
    stoppedConn = animTrack.Stopped:Once(function()
        enemyData.attacks[trackId] = nil
        local bufferTime = Options.ReleaseBuffer and Options.ReleaseBuffer.Value or 0.05
        task_delay(bufferTime, function()
            for idx, bid in ipairs(enemyData.blockIds) do
                if bid == blockId then
                    table_remove(enemyData.blockIds, idx)
                    break
                end
            end
            BlockStateMachine:Release(blockId)
            self._totalReleased = self._totalReleased + 1

            local hasAttacks = false
            for _ in pairs(enemyData.attacks) do hasAttacks = true break end
            if not hasAttacks then
                self._enemies[charName] = nil
            end
        end)
    end)
    table_insert(ActiveConnections, stoppedConn)

    local maxTrackDuration = 2.5
    if regInfo and regInfo.duration then
        maxTrackDuration = regInfo.duration + 0.5
    end
    if maxTrackDuration > 3.0 then maxTrackDuration = 3.0 end
    task_delay(maxTrackDuration, function()
        if enemyData.attacks[trackId] then
            enemyData.attacks[trackId] = nil
            for idx, bid in ipairs(enemyData.blockIds) do
                if bid == blockId then
                    table_remove(enemyData.blockIds, idx)
                    break
                end
            end
            BlockStateMachine:Release(blockId)
            self._totalReleased = self._totalReleased + 1
        end
    end)
end

function EnemyTracker:ClearCharacter(character)
    local charName = character:GetFullName()
    local enemyData = self._enemies[charName]
    if enemyData then
        for _, bid in ipairs(enemyData.blockIds) do
            BlockStateMachine:Release(bid)
            self._totalReleased = self._totalReleased + 1
        end
        self._enemies[charName] = nil
    end
end

function EnemyTracker:GetActiveEnemyCount()
    local count = 0
    for _ in pairs(self._enemies) do count = count + 1 end
    return count
end

function EnemyTracker:GetStats()
    return {
        activeEnemies = self:GetActiveEnemyCount(),
        totalTracked = self._totalTracked,
        totalReleased = self._totalReleased,
    }
end

local function HandleAnimationPlay(character, animationTrack)
    if not ScriptActive then return end
    if not Toggles.AutoBlockEnabled.Value and not Toggles.ProjectileBlock.Value then return end
    if not animationTrack or not animationTrack.Animation then return end

    local charPlayer = Players:GetPlayerFromCharacter(character)
    if charPlayer == LocalPlayer then return end

    if IsLocalPlayerIncapacitated() then return end

    if not IsCharacterAlive(character) then return end
    if IsCharacterIncapacitated(character) then return end

    if Toggles.OnlyBlockLocked and Toggles.OnlyBlockLocked.Value then
        local isTarget = false
        if AimlockTarget then
            isTarget = (character == AimlockTarget)
        end
        if OP_Locked and OP_Target and OP_Target.Parent then
            isTarget = isTarget or (character == OP_Target.Parent)
        end
        if not isTarget then return end
    end

    local isAttack, isProjectile, priority, regInfo = ClassifyAnimation(animationTrack)
    if not isAttack then return end

    if regInfo and regInfo.isM1 and Toggles.BlockM1s and not Toggles.BlockM1s.Value then return end
    if isProjectile and not Toggles.ProjectileBlock.Value then return end
    if not isProjectile and not Toggles.AutoBlockEnabled.Value then return end

    if Toggles.BlockWhileAttacking and not Toggles.BlockWhileAttacking.Value and IsLocalPlayerAttacking() then return end

    local localRoot = GetLocalRoot()
    local targetRoot = character:FindFirstChild("HumanoidRootPart")
    if not localRoot or not targetRoot then return end

    local distance = GetDistanceBetween(localRoot, targetRoot)
    local maxRange = 35

    local rawId = nil
    if animationTrack.Animation then
        rawId = tostring(animationTrack.Animation.AnimationId):match("%d+")
    end

    if regInfo then
        maxRange = regInfo.range
    elseif rawId and LongRangeAttackIds[rawId] then
        maxRange = 120
    elseif isProjectile then
        maxRange = Options.ProjectileRange and Options.ProjectileRange.Value or 50
    else
        maxRange = Options.DetectionRange and Options.DetectionRange.Value or 35
    end

    if distance > maxRange then return end

    local function checkFacing()
        local threshold
        if isProjectile then
            if Toggles.ProjectileFacingCheck and not Toggles.ProjectileFacingCheck.Value then return true end
            threshold = Options.ProjectileFacingThreshold and Options.ProjectileFacingThreshold.Value or 0.4
        else
            if Toggles.FacingCheckEnabled and not Toggles.FacingCheckEnabled.Value then return true end
            threshold = Options.FacingAngleThreshold and Options.FacingAngleThreshold.Value or 0.6
        end
        local dot = GetFacingDot(targetRoot, localRoot)
        return dot >= threshold
    end

    if not checkFacing() then return end

    if not isProjectile and IsEnemyFeinting(character) then return end

    EnemyTracker:TrackAttack(character, animationTrack, isProjectile, regInfo)
end

local function StartEffectsMonitorBlock()
    local EffectsFolder = Workspace:WaitForChild("Effects", 10) or Workspace:FindFirstChild("Effects")
    if not EffectsFolder then return end

    local effectConn = EffectsFolder.ChildAdded:Connect(function(child)
        if not ScriptActive then return end
        if not Toggles.HitGlowBlock or not Toggles.HitGlowBlock.Value then return end
        if not Toggles.AutoBlockEnabled.Value then return end
        if child.Name ~= "HitGlow" and child.Name ~= "BlockHit" then return end

        local localChar = GetLocalCharacter()
        if not localChar then return end
        local localRoot = GetLocalRoot()
        if not localRoot then return end

        local foundWeld = false
        for _, descendant in ipairs(child:GetDescendants()) do
            if foundWeld then break end
            if descendant:IsA("Weld") or descendant:IsA("WeldConstraint") then
                local part0 = descendant.Part0
                local part1 = descendant.Part1
                if (part0 and part0:IsDescendantOf(localChar)) or (part1 and part1:IsDescendantOf(localChar)) then
                    BlockStateMachine:Request("hitglow_weld", 0.25)
                    foundWeld = true
                end
            end
        end

        if not foundWeld then
            for _, descendant in ipairs(child:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    local dist = (descendant.Position - localRoot.Position).Magnitude
                    if dist < 8 then
                        BlockStateMachine:Request("hitglow_proximity", 0.3)
                        break
                    end
                end
            end
        end
    end)
    table_insert(ActiveConnections, effectConn)
end

local PhysicsProjectileScanner = {
    _lastScanTime = 0,
    _scanInterval = 0.15,
    _minSpeed = 40,
    _maxSpeed = 500,
    _minDistance = 5,
    _maxDistance = 50,
}

local ProjectileNamePatterns = {
    "projectile", "bullet", "fireball", "arrow", "bolt",
    "shuriken", "orb", "sphere", "beam", "laser",
    "missile", "rocket", "bomb", "grenade", "stone",
    "ice", "rock", "fire", "wind", "water",
    "cursed", "energy", "blast", "wave", "slab",
    "kunai", "spike", "thorn", "needle", "dart",
    "cannon", "shot", "slug", "round", "pellet",
    "blood", "plasma", "void", "purple", "red",
    "blue", "black", "white", "gold", "silver",
}

local function IsLikelyProjectilePart(part)
    if not part:IsA("BasePart") then return false end
    if part.Anchored then return false end
    if part.Transparency >= 1 then return false end
    local size = part.Size
    if size.Magnitude > 12 then return false end
    if size.Magnitude < 0.3 then return false end
    local lowerName = string_lower(part.Name)
    for _, pattern in ipairs(ProjectileNamePatterns) do
        if string_find(lowerName, pattern) then return true end
    end
    if part.Material == Enum.Material.Neon or part.Material == Enum.Material.ForceField then
        if not part.CanCollide and size.X < 5 and size.Y < 5 and size.Z < 5 then
            return true
        end
    end
    return false
end

local function ScanPhysicsProjectiles()
    local now = tick()
    if now - PhysicsProjectileScanner._lastScanTime < PhysicsProjectileScanner._scanInterval then return end
    PhysicsProjectileScanner._lastScanTime = now

    if not ScriptActive then return end
    if not Toggles.ProjectileBlock or not Toggles.ProjectileBlock.Value then return end
    if IsLocalPlayerIncapacitated() then return end

    local localRoot = GetLocalRoot()
    if not localRoot then return end
    local localPos = localRoot.Position

    local EffectsFolder = Workspace:FindFirstChild("Effects")
    if not EffectsFolder then return end

    for _, child in ipairs(EffectsFolder:GetChildren()) do
        if child:IsA("BasePart") and IsLikelyProjectilePart(child) then
            local partPos = child.Position
            local dist = (localPos - partPos).Magnitude
            if dist > PhysicsProjectileScanner._minDistance and dist < PhysicsProjectileScanner._maxDistance then
                local velocity
                pcall(function() velocity = child.AssemblyLinearVelocity end)
                if not velocity then pcall(function() velocity = child.Velocity end) end
                if velocity then
                    local speed, dot = GetVelocityTowardTarget(partPos, velocity, localPos)
                    if speed > PhysicsProjectileScanner._minSpeed and speed < PhysicsProjectileScanner._maxSpeed and dot > 0.5 then
                        local timeToImpact = dist / speed
                        if timeToImpact < 1.0 then
                            BlockStateMachine:Request("physics_proj", math_min(timeToImpact + 0.15, 0.8))
                        end
                    end
                end
            end
        elseif child:IsA("Model") then
            for _, descendant in ipairs(child:GetDescendants()) do
                if descendant:IsA("BasePart") and IsLikelyProjectilePart(descendant) then
                    local partPos = descendant.Position
                    local dist = (localPos - partPos).Magnitude
                    if dist > PhysicsProjectileScanner._minDistance and dist < PhysicsProjectileScanner._maxDistance then
                        local velocity
                        pcall(function() velocity = descendant.AssemblyLinearVelocity end)
                        if not velocity then pcall(function() velocity = descendant.Velocity end) end
                        if velocity then
                            local speed, dot = GetVelocityTowardTarget(partPos, velocity, localPos)
                            if speed > PhysicsProjectileScanner._minSpeed and speed < PhysicsProjectileScanner._maxSpeed and dot > 0.5 then
                                local timeToImpact = dist / speed
                                if timeToImpact < 1.0 then
                                    BlockStateMachine:Request("physics_proj_d", math_min(timeToImpact + 0.15, 0.8))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

table_insert(ActiveConnections, RunService.Heartbeat:Connect(function()
    pcall(ScanPhysicsProjectiles)
end))

local LastHealthValue = nil
local DamageReactionCooldown = 0

local function ProcessDamageReaction()
    if not ScriptActive then return end
    if not Toggles.DamageReaction or not Toggles.DamageReaction.Value then return end
    if IsLocalPlayerIncapacitated() then return end

    local humanoid = GetLocalHumanoid()
    if not humanoid then return end

    local currentHealth = humanoid.Health
    local now = tick()

    if LastHealthValue and currentHealth < LastHealthValue then
        local damageAmount = LastHealthValue - currentHealth
        local minDamageThreshold = Options.DamageThreshold and Options.DamageThreshold.Value or 5
        if damageAmount > minDamageThreshold and now > DamageReactionCooldown then
            local holdTime = Options.DamageReactionHold and Options.DamageReactionHold.Value or 0.4
            BlockStateMachine:Request("damage_reaction", holdTime)
            DamageReactionCooldown = now + 0.2
        end
    end
    LastHealthValue = currentHealth
end

table_insert(ActiveConnections, RunService.Heartbeat:Connect(function()
    pcall(ProcessDamageReaction)
end))

table_insert(ActiveConnections, RunService.Heartbeat:Connect(function()
    if IsLocalPlayerIncapacitated() and BlockStateMachine:IsBlocking() then
        BlockStateMachine:ReleaseAll()
    end
end))

table_insert(ActiveConnections, RunService.Heartbeat:Connect(function()
    CombatTracker:Cleanup()
end))

local function ConnectCharacterBlock(char)
    if not ScriptActive then return end
    local charPlayer = Players:GetPlayerFromCharacter(char)
    if charPlayer == LocalPlayer then return end

    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        local animator = humanoid:WaitForChild("Animator", 5) or humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local conn = animator.AnimationPlayed:Connect(function(track)
                HandleAnimationPlay(char, track)
            end)
            table_insert(ActiveConnections, conn)
        end

        local remConn = char.AncestryChanged:Connect(function(_, parent)
            if not parent then
                EnemyTracker:ClearCharacter(char)
            end
        end)
        table_insert(ActiveConnections, remConn)

        local diedConn
        diedConn = humanoid.Died:Connect(function()
            EnemyTracker:ClearCharacter(char)
        end)
        table_insert(ActiveConnections, diedConn)
    end
end

local function SetupWorkspaceConnectionsBlock()
    local CharactersFolder = Workspace:WaitForChild("Characters", 10) or Workspace:FindFirstChild("Characters")
    if not CharactersFolder then return end

    for _, char in pairs(CharactersFolder:GetChildren()) do
        task_spawn(ConnectCharacterBlock, char)
    end

    local childAddedConn = CharactersFolder.ChildAdded:Connect(function(newChar)
        task_wait(0.1)
        ConnectCharacterBlock(newChar)
    end)
    table_insert(ActiveConnections, childAddedConn)

    local childRemovedConn = CharactersFolder.ChildRemoved:Connect(function(char)
        EnemyTracker:ClearCharacter(char)
    end)
    table_insert(ActiveConnections, childRemovedConn)
end

local function SetupLocalCharacterRespawnBlock()
    local function onCharacterAdded(char)
        LastHealthValue = nil
        DamageReactionCooldown = 0
        BlockStateMachine:ReleaseAll()
        task_wait(0.5)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then
            LastHealthValue = humanoid.Health
        end
    end

    if LocalPlayer.Character then
        task_spawn(onCharacterAdded, LocalPlayer.Character)
    end

    local respawnConn = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table_insert(ActiveConnections, respawnConn)
end

local PerformanceMonitor = {
    _frameCount = 0,
    _lastFpsCheck = 0,
    _currentFps = 60,
}

function PerformanceMonitor:Update()
    self._frameCount = self._frameCount + 1
    local now = tick()
    local elapsed = now - self._lastFpsCheck
    if elapsed >= 1.0 then
        self._currentFps = self._frameCount / elapsed
        self._frameCount = 0
        self._lastFpsCheck = now
    end
end

function PerformanceMonitor:GetFps()
    return math_floor(self._currentFps)
end

function PerformanceMonitor:GetPing()
    local ping = 0
    pcall(function()
        ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return math_floor(ping)
end

table_insert(ActiveConnections, RunService.Heartbeat:Connect(function()
    PerformanceMonitor:Update()
end))



local StatusHudGroup = MainTab:AddLeftGroupbox('Combat HUD')
local HudBlockState = StatusHudGroup:AddLabel('Block: Inactive')
local HudClosestEnemy = StatusHudGroup:AddLabel('Threat: None')
local HudEnemyDistance = StatusHudGroup:AddLabel('Distance: N/A')
local HudActiveReasons = StatusHudGroup:AddLabel('Reasons: 0')
local HudTrackedEnemies = StatusHudGroup:AddLabel('Tracked: 0')
local HudPerformance = StatusHudGroup:AddLabel('FPS: -- | Ping: --')
local HudCombatState = StatusHudGroup:AddLabel('Combat: Idle')

task_spawn(function()
    while ScriptActive do
        task_wait(0.1)

        if not Toggles.AutoBlockEnabled.Value and not Toggles.ProjectileBlock.Value then
            HudBlockState:SetText('Block: Disabled')
            HudClosestEnemy:SetText('Threat: None')
            HudEnemyDistance:SetText('Distance: N/A')
            HudActiveReasons:SetText('Reasons: 0')
            HudTrackedEnemies:SetText('Tracked: 0')
            HudCombatState:SetText('Combat: Idle')
        else
            local stats = BlockStateMachine:GetStats()
            if stats.isBlocking then
                local duration = string.format("%.1f", stats.blockDuration)
                HudBlockState:SetText('Block: <font color="#49ff49">Active</font> (' .. stats.activeReasons .. 'r / ' .. duration .. 's)')
            else
                HudBlockState:SetText('Block: <font color="#ff3c3c">Ready</font>')
            end

            HudActiveReasons:SetText('Reasons: ' .. stats.activeReasons .. ' | Total: ' .. stats.totalActivated)

            local trackerStats = EnemyTracker:GetStats()
            HudTrackedEnemies:SetText('Tracked: ' .. trackerStats.activeEnemies .. ' | Processed: ' .. trackerStats.totalTracked)

            if CombatTracker:IsInAnyCombat() then
                HudCombatState:SetText('Combat: <font color="#ff6600">Engaged</font>')
            else
                HudCombatState:SetText('Combat: <font color="#aaaaaa">Idle</font>')
            end

            HudPerformance:SetText('FPS: ' .. PerformanceMonitor:GetFps() .. ' | Ping: ' .. PerformanceMonitor:GetPing() .. 'ms')

            local closestOpponent = nil
            local closestDistance = math_huge
            local localRoot = GetLocalRoot()
            if localRoot then
                local CharactersFolder = Workspace:FindFirstChild("Characters")
                if CharactersFolder then
                    for _, char in pairs(CharactersFolder:GetChildren()) do
                        local charPlayer = Players:GetPlayerFromCharacter(char)
                        if charPlayer ~= LocalPlayer and IsCharacterAlive(char) then
                            local enemyRoot = char:FindFirstChild("HumanoidRootPart")
                            if enemyRoot then
                                local distance = GetDistanceBetween(localRoot, enemyRoot)
                                local maxRange = math_max(
                                    Options.DetectionRange and Options.DetectionRange.Value or 35,
                                    Options.ProjectileRange and Options.ProjectileRange.Value or 50
                                )
                                if distance < closestDistance and distance <= maxRange then
                                    closestDistance = distance
                                    closestOpponent = char.Name
                                end
                            end
                        end
                    end
                end
            end

            if closestOpponent then
                HudClosestEnemy:SetText('Threat: <font color="#ffaa00">' .. closestOpponent .. '</font>')
                HudEnemyDistance:SetText('Distance: ' .. math_floor(closestDistance) .. ' studs')
            else
                HudClosestEnemy:SetText('Threat: None in Range')
                HudEnemyDistance:SetText('Distance: N/A')
            end
        end
    end
end)

local BlockSettingsGroup = MainTab:AddLeftGroupbox('Auto Block', 'shield')
BlockSettingsGroup:AddToggle('AutoBlockEnabled', { Text = 'Enable Auto Block', Default = false })
BlockSettingsGroup:AddToggle('BlockM1s', { Text = 'Block M1 Attacks', Default = true })
BlockSettingsGroup:AddToggle('BlockWhileAttacking', { Text = 'Block While Attacking', Default = false })
BlockSettingsGroup:AddToggle('OnlyBlockLocked', { Text = 'Only Block Locked Target', Default = false })
BlockSettingsGroup:AddSlider('DetectionRange', { Text = 'Detection Range (studs)', Min = 3, Max = 60, Default = 15, Rounding = 1 })

local ProjectileGroup = MainTab:AddRightGroupbox('Projectile Block')
ProjectileGroup:AddToggle('ProjectileBlock', { Text = 'Enable Projectile Block', Default = true })
ProjectileGroup:AddSlider('ProjectileRange', { Text = 'Projectile Detection Range', Min = 5, Max = 120, Default = 50, Rounding = 1 })
ProjectileGroup:AddToggle('ProjectileFacingCheck', { Text = 'Projectile Facing Check', Default = true })
ProjectileGroup:AddSlider('ProjectileFacingThreshold', { Text = 'Projectile Facing Sensitivity', Min = 0.1, Max = 1.0, Default = 0.4, Rounding = 2 })

local DetectionGroup = MainTab:AddRightGroupbox('Detection Layers')
DetectionGroup:AddToggle('HitGlowBlock', { Text = 'React to HitGlow/BlockHit', Default = true })
DetectionGroup:AddToggle('AntiFeintEnabled', { Text = 'Bypass Feints', Default = true })
DetectionGroup:AddToggle('DamageReaction', { Text = 'Damage Reaction Block', Default = true })

local TuningBlockGroup = TuningTab:AddLeftGroupbox('Block Timing', 'sliders')
TuningBlockGroup:AddToggle('FacingCheckEnabled', { Text = 'Facing Check', Default = true })
TuningBlockGroup:AddSlider('FacingAngleThreshold', { Text = 'Facing Sensitivity', Min = 0.1, Max = 1.0, Default = 0.6, Rounding = 2 })
TuningBlockGroup:AddToggle('BlockForAnimation', { Text = 'Block Full Animation', Default = false, Callback = function(value) if value and Toggles.BlockForDuration then Toggles.BlockForDuration:SetValue(false) end end })
TuningBlockGroup:AddToggle('BlockForDuration', { Text = 'Block Custom Duration', Default = false, Callback = function(value) if value and Toggles.BlockForAnimation then Toggles.BlockForAnimation:SetValue(false) end end })
TuningBlockGroup:AddSlider('BlockDuration', { Text = 'Custom Block Duration', Min = 0.1, Max = 3.0, Default = 0.5, Rounding = 2 })
TuningBlockGroup:AddSlider('MinBlockHold', { Text = 'Min Block Hold', Min = 0.02, Max = 0.3, Default = 0.06, Rounding = 3 })
TuningBlockGroup:AddSlider('BlockCooldown', { Text = 'Block Cooldown', Min = 0, Max = 0.5, Default = 0, Rounding = 3 })
TuningBlockGroup:AddSlider('ReleaseBuffer', { Text = 'Release Buffer', Min = 0, Max = 0.3, Default = 0.05, Rounding = 3 })
TuningBlockGroup:AddSlider('DamageThreshold', { Text = 'Damage Threshold', Min = 1, Max = 50, Default = 5, Rounding = 0 })
TuningBlockGroup:AddSlider('DamageReactionHold', { Text = 'Damage Reaction Hold', Min = 0.1, Max = 1.0, Default = 0.4, Rounding = 2 })

local TuningInfoGroup = TuningTab:AddRightGroupbox('Registry Info')
local RegistryCountLabel = TuningInfoGroup:AddLabel('Registry Entries: 0')
local DynamicCacheLabel = TuningInfoGroup:AddLabel('Dynamic Cache: 0')
local LongRangeCountLabel = TuningInfoGroup:AddLabel('Long Range IDs: 0')

task_spawn(function()
    while ScriptActive do
        task_wait(2)
        local regCount = 0
        for _ in pairs(AttackAnimationRegistry) do regCount = regCount + 1 end
        RegistryCountLabel:SetText('Registry Entries: ' .. regCount)

        local cacheCount = 0
        for _ in pairs(DynamicAnimationCache) do cacheCount = cacheCount + 1 end
        DynamicCacheLabel:SetText('Dynamic Cache: ' .. cacheCount .. ' (H:' .. DynamicCacheHits .. ' M:' .. DynamicCacheMisses .. ')')

        local lrCount = 0
        for _ in pairs(LongRangeAttackIds) do lrCount = lrCount + 1 end
        LongRangeCountLabel:SetText('Long Range IDs: ' .. lrCount)
    end
end)




task.spawn(function()
    BlockRemoteCache:Resolve()
    task.wait(1)
    SetupWorkspaceConnectionsBlock()
end)
task.spawn(StartEffectsMonitorBlock)
task.spawn(SetupLocalCharacterRespawnBlock)

end

LoadAutoBlock()

do
local OPLockGroup = MainTab:AddLeftGroupbox('OP Lock-On', 'lock')
OPLockGroup:AddToggle('OPLockEnabled', { Text = 'Enable OP Lock-On', Default = false, Tooltip = 'Souls-like camera lock-on. Button spawns draggable.', Callback = function(value) btn.Visible = value; if not value then stopLock() end end })
OPLockGroup:AddLabel('Press T or tap button to lock/unlock')

local AimlockSettingsGroup = MainTab:AddRightGroupbox('Aimlock / Lock-On', 'crosshair')
AimlockSettingsGroup:AddToggle('AimlockEnabled', { Text = 'Enable Aimlock', Default = false, Callback = function() end })
AimlockSettingsGroup:AddDropdown('AimlockMode', { Values = {'Camera', 'Character'}, Default = 'Camera', Multi = false, Text = 'Aimlock Mode', Callback = function() end })
AimlockSettingsGroup:AddSlider('AimlockRange', { Text = 'Aimlock Range (studs)', Min = 10, Max = 200, Default = 80, Rounding = 1, Callback = function() end })
AimlockSettingsGroup:AddSlider('PredictionStrength', { Text = 'Prediction Multiplier', Min = 0, Max = 30, Default = 12, Rounding = 1, Callback = function() end })
AimlockSettingsGroup:AddToggle('HardLockEnabled', { Text = 'Hard-Lock Target', Default = false, Callback = function() end })
AimlockSettingsGroup:AddToggle('AimlockMobileButton', { Text = 'Aimlock Mobile Button', Default = false, Callback = function(state) if state then CreateMobileButton("LockOn", "rbxassetid://11738355467", function() Toggles.AimlockEnabled:SetValue(not Toggles.AimlockEnabled.Value) end) else RemoveMobileButton("LockOn") end end })
local AimlockBindLabel = AimlockSettingsGroup:AddLabel('Aimlock Bind')
AimlockBindLabel:AddKeyPicker('AimlockKeybind', { NoUI = false, Default = 'Q', Text = 'Aimlock keybind' })

local keybindConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if Options.AimlockKeybind and input.KeyCode == Options.AimlockKeybind.Value then Toggles.AimlockEnabled:SetValue(not Toggles.AimlockEnabled.Value) end
end)
table.insert(ActiveConnections, keybindConnection)

local ManjiCounterGroup = MainTab:AddRightGroupbox('Auto Counter - Manji Kick', 'sword')
ManjiCounterGroup:AddToggle('AutoCounterEnabled', { Text = 'Enable Auto Counter', Default = false })
ManjiCounterGroup:AddSlider('CounterRange', { Text = 'Counter Range', Min = 3, Max = 35, Default = 15, Rounding = 1 })
ManjiCounterGroup:AddToggle('CounterFacingCheck', { Text = 'Facing Check', Default = true, Tooltip = 'Only counter if the attacker is facing you.' })
ManjiCounterGroup:AddSlider('CounterFacingThreshold', { Text = 'Facing Sensitivity', Min = 0.1, Max = 1.0, Default = 0.7, Rounding = 2 })
end

do
local BoxEspGroup = VisualTab:AddLeftGroupbox('Player Bounds', 'box')
local BoxToggle = BoxEspGroup:AddToggle('BoxEspEnabled', {
    Text = 'Enable Full Box',
    Default = false,
    Callback = function(val)
        if val and Toggles.CornerEspEnabled then
            Toggles.CornerEspEnabled:SetValue(false)
        end
    end
})
BoxToggle:AddColorPicker('BoxEspColor', {
    Default = Color3.fromRGB(0, 200, 255),
    Callback = function(color)
        updateCategoryGradients("Box", color)
    end
})

local CornerToggle = BoxEspGroup:AddToggle('CornerEspEnabled', {
    Text = 'Enable Corners',
    Default = false,
    Callback = function(val)
        if val and Toggles.BoxEspEnabled then
            Toggles.BoxEspEnabled:SetValue(false)
        end
    end
})
CornerToggle:AddColorPicker('CornerEspColor', {
    Default = Color3.fromRGB(0, 255, 200),
    Callback = function(color)
        updateCategoryGradients("Corner", color)
    end
})

local SkeletonGroup = VisualTab:AddLeftGroupbox('Skeleton ESP', 'user')
local SkeletonToggle = SkeletonGroup:AddToggle('SkeletonEspEnabled', { Text = 'Enable Skeleton', Default = false })
SkeletonToggle:AddColorPicker('SkeletonEspColor', {
    Default = Color3.fromRGB(200, 50, 255),
    Callback = function(color)
        updateCategoryGradients("Skeleton", color)
    end
})

local NameEspGroup = VisualTab:AddLeftGroupbox('Name Tags', 'text')
local NameToggle = NameEspGroup:AddToggle('NameEspEnabled', { Text = 'Enable Names', Default = false })
NameToggle:AddColorPicker('NameEspColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        updateCategoryGradients("Name", color)
    end
})
NameEspGroup:AddSlider('NameTextSize', { Text = 'Text Size', Min = 10, Max = 20, Default = 13, Rounding = 0 })

local DummyEspGroup = VisualTab:AddLeftGroupbox('Dummy ESP', 'ghost')
DummyEspGroup:AddToggle('DummyEspEnabled', { Text = 'Track Dummies', Default = false })

local presetMap = {
    ['Neon Blue'] = Color3.fromRGB(0, 200, 255),
    ['Crimson Velvet'] = Color3.fromRGB(255, 30, 80),
    ['Lime Neon'] = Color3.fromRGB(100, 255, 100),
    ['Sunset Gold'] = Color3.fromRGB(255, 150, 0),
    ['Purple Orchid'] = Color3.fromRGB(200, 50, 255),
    ['Cyberpunk Mint'] = Color3.fromRGB(0, 255, 200)
}
local ThemeGroup = VisualTab:AddRightGroupbox('Gradient Theme', 'wrench')
ThemeGroup:AddDropdown('EspTheme', {
    Values = {'Neon Blue', 'Crimson Velvet', 'Lime Neon', 'Sunset Gold', 'Purple Orchid', 'Cyberpunk Mint'},
    Default = 'Neon Blue',
    Multi = false,
    Text = 'Theme Preset',
    Callback = function(value)
        local baseColor = presetMap[value]
        if baseColor then
            pcall(function() Options.BoxEspColor:SetValueRGB(baseColor) end)
            pcall(function() Options.CornerEspColor:SetValueRGB(baseColor) end)
            pcall(function() Options.SkeletonEspColor:SetValueRGB(baseColor) end)
            pcall(function() Options.NameEspColor:SetValueRGB(baseColor) end)
            pcall(function() Options.TracerColor:SetValueRGB(baseColor) end)
            pcall(function() Options.ItemEspColor:SetValueRGB(baseColor) end)
            pcall(function() Options.ItemTracerColor:SetValueRGB(baseColor) end)
        end
    end
})

ThemeGroup:AddSlider('GradientHueShift', {
    Text = 'Accent Hue Shift',
    Min = -0.5,
    Max = 0.5,
    Default = 0.08,
    Rounding = 2,
    Callback = function()
        pcall(refreshAllVisualGradients)
    end
})

ThemeGroup:AddSlider('GradientSatShift', {
    Text = 'Accent Saturation Multiplier',
    Min = 0.0,
    Max = 2.0,
    Default = 1.0,
    Rounding = 2,
    Callback = function()
        pcall(refreshAllVisualGradients)
    end
})

ThemeGroup:AddSlider('GradientValueShift', {
    Text = 'Accent Brightness Multiplier',
    Min = 0.0,
    Max = 1.0,
    Default = 0.4,
    Rounding = 2,
    Callback = function()
        pcall(refreshAllVisualGradients)
    end
})


local TracerGroup = VisualTab:AddRightGroupbox('Head Tracers', 'point')
local TracerToggle = TracerGroup:AddToggle('TracerEnabled', { Text = 'Enable Tracers', Default = false })
TracerToggle:AddColorPicker('TracerColor', {
    Default = Color3.fromRGB(255, 50, 80),
    Callback = function(color)
        updateCategoryGradients("Tracer", color)
    end
})
TracerGroup:AddSlider('TracerThickness', { Text = 'Thickness', Min = 1, Max = 4, Default = 2, Rounding = 0 })

local ItemGroup = VisualTab:AddRightGroupbox('Item ESP', 'box')
local ItemEspToggle = ItemGroup:AddToggle('ItemEspEnabled', { Text = 'Item Esp', Default = false })
ItemEspToggle:AddColorPicker('ItemEspColor', {
    Default = Color3.fromRGB(100, 255, 150),
    Callback = function(color)
        updateCategoryGradients("ItemEsp", color)
    end
})
local ItemTracerToggle = ItemGroup:AddToggle('ItemTracerEnabled', { Text = 'Item Tracer', Default = false })
ItemTracerToggle:AddColorPicker('ItemTracerColor', {
    Default = Color3.fromRGB(255, 50, 120),
    Callback = function(color)
        updateCategoryGradients("ItemTracer", color)
    end
})
end


do
local MiscGroup = MiscTab:AddLeftGroupbox('Customization', 'box')

MiscGroup:AddToggle('UnlockEmotes', {
    Text = 'Unlock Extra Emote Slots',
    Default = false,
    Tooltip = 'Forces hidden emote slots and switch button to be visible',
    Callback = function(state)
        pcall(function()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
            if not playerGui then return end
            
            local emote = playerGui:WaitForChild("Emotes", 5):WaitForChild("Emote", 5)
            local page1 = emote:WaitForChild("Page1", 5)
            local page2 = emote:WaitForChild("Page2", 5)
            local switch = emote:WaitForChild("Switch", 5)
            local equipped = playerGui:WaitForChild("Menus", 5):WaitForChild("Group", 5):WaitForChild("Inventory", 5):WaitForChild("Items", 5):WaitForChild("Emotes", 5):WaitForChild("Equipped", 5)

            local function show(gui)
                if gui:IsA("GuiObject") then
                    gui.Visible = state
                    for _, child in ipairs(gui:GetChildren()) do
                        if child:IsA("GuiObject") then
                            child.Visible = state
                        end
                    end
                end
            end

            switch.Visible = state

            if state then
                show(page1)
                show(equipped)
                
                if not _G.EmoteSwitchConn then
                    local active = false
                    page2.Visible = false
                    _G.EmoteSwitchConn = switch.MouseButton1Click:Connect(function()
                        active = not active
                        page1.Visible = not active
                        page2.Visible = active
                        if active then show(page2) else show(page1) end
                    end)
                end
            else
                page2.Visible = false
                switch.Visible = false
            end
        end)
    end
})

MiscGroup:AddToggle('AlwaysDownslam', {
    Text = 'Always Downslam',
    Default = false,
    Tooltip = 'Forces moveset activation parameters to register as a downslam, immediately ragdolling players.',
    Callback = function(state)
        AlwaysDownslamActive = state
    end
})

MiscGroup:AddToggle('InfiniteParkour', {
    Text = 'Infinite Parkour',
    Default = false,
    Tooltip = 'Allows infinite wall-running and double jumping by continuously resetting your local parkour upvalues.',
    Callback = function(state)
        InfiniteParkourActive = state
    end
})

local UtilityGroup = MiscTab:AddLeftGroupbox('Utility', 'zap')

UtilityGroup:AddToggle('InfiniteDash', {
    Text = 'Infinite Dash',
    Default = false,
    Tooltip = 'Allows you to dash infinitely with no cooldown.',
    Callback = function(state)
        InfiniteDashActive = state
    end
})

UtilityGroup:AddToggle('AutoParkour', {
    Text = 'Auto Parkour / Vault',
    Default = false,
    Tooltip = 'Automatically vaults you over walls you face.',
    Callback = function(state)
        AutoParkourActive = state
    end
})

UtilityGroup:AddSlider('ParkourClimbSpeed', {
    Text = 'Parkour Speed',
    Min = 20,
    Max = 100,
    Default = 40,
    Rounding = 0,
    Callback = function(val)
        CLIMB_SPEED = val
    end
})

UtilityGroup:AddSlider('ParkourWallDistance', {
    Text = 'Wall Distance (studs)',
    Min = 1,
    Max = 10,
    Default = 3.5,
    Rounding = 1,
    Callback = function(val)
        DETECTION_DISTANCE = val
    end
})

local InvisUtilityGroup = MiscTab:AddRightGroupbox('Utility', 'eye')
InvisUtilityGroup:AddToggle('Invisibility', {
    Text = 'Invisibility',
    Default = false,
    Callback = function(state)
        if state then
            EnableInvisibility()
        else
            DisableInvisibility()
        end
    end
})

local XreztACBypassGroup = MiscTab:AddRightGroupbox('Xrezt AC Bypass', 'box')

XreztACBypassGroup:AddToggle('ACBypassEnabled', {
    Text = 'AC Bypass',
    Default = false,
    Tooltip = 'Launches the Xrezt AC Bypass GUI script.',
    Callback = function(state)
        if state then
            task.spawn(function()
                local _Players = game:GetService("Players")
                local _UserInputService = game:GetService("UserInputService")
                local _TweenService = game:GetService("TweenService")
                local _ReplicatedStorage = game:GetService("ReplicatedStorage")
                local _LocalPlayer = _Players.LocalPlayer

                local _ResetRemote
                pcall(function()
                    _ResetRemote = _ReplicatedStorage.Knit.Knit.Services.JoinService.RE.Reset
                end)

                local _Theme = {
                    DeepSpace    = Color3.fromRGB(6, 10, 28),
                    CosmicBlue   = Color3.fromRGB(10, 20, 48),
                    NebulaBlue   = Color3.fromRGB(16, 32, 72),
                    Starlight    = Color3.fromRGB(150, 190, 255),
                    InfinityBlue = Color3.fromRGB(0, 130, 255),
                    BrightBlue   = Color3.fromRGB(60, 150, 255),
                    DeepGlow     = Color3.fromRGB(20, 60, 150),
                    White        = Color3.fromRGB(240, 248, 255),
                    TextBlue     = Color3.fromRGB(130, 170, 230),
                    SubText      = Color3.fromRGB(90, 110, 155),
                    CardBg       = Color3.fromRGB(12, 22, 48),
                    CardStroke   = Color3.fromRGB(28, 55, 110),
                    ToggleOff    = Color3.fromRGB(20, 28, 52),
                    ToggleOn     = Color3.fromRGB(0, 110, 230),
                    KnobOff      = Color3.fromRGB(95, 115, 155),
                    KnobOn       = Color3.fromRGB(240, 248, 255),
                    Green        = Color3.fromRGB(30, 255, 130),
                    Red          = Color3.fromRGB(255, 70, 90),
                    Orange       = Color3.fromRGB(255, 170, 50),
                    CloseRed     = Color3.fromRGB(200, 40, 50),
                    CloseHover   = Color3.fromRGB(235, 55, 65),
                }

                local _FONT_TITLE = Enum.Font.LuckiestGuy
                local _FONT_BODY  = Enum.Font.FredokaOne

                local _ScreenGui = Instance.new("ScreenGui")
                _ScreenGui.Name = "XreztACBypass"
                _ScreenGui.ResetOnSpawn = false
                _ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                _ScreenGui.IgnoreGuiInset = true

                pcall(function()
                    _ScreenGui.Parent = game:GetService("CoreGui")
                end)
                if not _ScreenGui.Parent then
                    _ScreenGui.Parent = _LocalPlayer:WaitForChild("PlayerGui")
                end

                local _CanvasGroup = Instance.new("CanvasGroup")
                _CanvasGroup.Name = "Entrance"
                _CanvasGroup.Size = UDim2.new(0, 348, 0, 275)
                _CanvasGroup.Position = UDim2.new(0.5, -174, 0.5, -137)
                _CanvasGroup.BackgroundTransparency = 1
                _CanvasGroup.GroupTransparency = 1
                _CanvasGroup.Parent = _ScreenGui

                local _Glow2 = Instance.new("Frame")
                _Glow2.Size = UDim2.new(0, 334, 0, 259)
                _Glow2.Position = UDim2.new(0, 7, 0, 8)
                _Glow2.BackgroundColor3 = Color3.fromRGB(0, 40, 120)
                _Glow2.BackgroundTransparency = 0.95
                _Glow2.BorderSizePixel = 0
                _Glow2.Parent = _CanvasGroup
                local _g2c = Instance.new("UICorner")
                _g2c.CornerRadius = UDim.new(0, 20)
                _g2c.Parent = _Glow2
                local _g2s = Instance.new("UIStroke")
                _g2s.Color = Color3.fromRGB(0, 70, 160)
                _g2s.Thickness = 8
                _g2s.Transparency = 0.85
                _g2s.Parent = _Glow2

                local _Glow1 = Instance.new("Frame")
                _Glow1.Size = UDim2.new(0, 322, 0, 247)
                _Glow1.Position = UDim2.new(0, 13, 0, 14)
                _Glow1.BackgroundColor3 = Color3.fromRGB(0, 55, 140)
                _Glow1.BackgroundTransparency = 0.92
                _Glow1.BorderSizePixel = 0
                _Glow1.Parent = _CanvasGroup
                local _g1c = Instance.new("UICorner")
                _g1c.CornerRadius = UDim.new(0, 15)
                _g1c.Parent = _Glow1
                local _g1s = Instance.new("UIStroke")
                _g1s.Color = Color3.fromRGB(0, 100, 200)
                _g1s.Thickness = 4
                _g1s.Transparency = 0.7
                _g1s.Parent = _Glow1

                local _MainFrame = Instance.new("Frame")
                _MainFrame.Size = UDim2.new(0, 310, 0, 235)
                _MainFrame.Position = UDim2.new(0, 19, 0, 20)
                _MainFrame.BackgroundColor3 = _Theme.DeepSpace
                _MainFrame.BorderSizePixel = 0
                _MainFrame.Parent = _CanvasGroup
                local _mfCorner = Instance.new("UICorner")
                _mfCorner.CornerRadius = UDim.new(0, 11)
                _mfCorner.Parent = _MainFrame
                local _bgGradient = Instance.new("UIGradient")
                _bgGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 14, 38)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 24, 56)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 16, 42)),
                })
                _bgGradient.Rotation = 0
                _bgGradient.Parent = _MainFrame
                local _mfStroke = Instance.new("UIStroke")
                _mfStroke.Color = _Theme.BrightBlue
                _mfStroke.Thickness = 1.5
                _mfStroke.Transparency = 0.3
                _mfStroke.Parent = _MainFrame

                local _starData = {
                    {x = 24,  y = 6,   size = 2, phase = 0},
                    {x = 210, y = 8,   size = 2, phase = 0.4},
                    {x = 285, y = 18,  size = 2, phase = 0.8},
                    {x = 8,   y = 64,  size = 2, phase = 0.2},
                    {x = 300, y = 125, size = 2, phase = 0.6},
                    {x = 6,   y = 188, size = 2, phase = 0.5},
                    {x = 298, y = 200, size = 2, phase = 0.1},
                }
                local _stars = {}
                for i, s in ipairs(_starData) do
                    local star = Instance.new("Frame")
                    star.Size = UDim2.new(0, s.size, 0, s.size)
                    star.Position = UDim2.new(0, s.x, 0, s.y)
                    star.BackgroundColor3 = _Theme.Starlight
                    star.BackgroundTransparency = 0.6
                    star.BorderSizePixel = 0
                    star.Parent = _MainFrame
                    local sc = Instance.new("UICorner")
                    sc.CornerRadius = UDim.new(1, 0)
                    sc.Parent = star
                    _stars[i] = {frame = star, phase = s.phase}
                end

                task.spawn(function()
                    while _ScreenGui.Parent do
                        for _, s in ipairs(_stars) do
                            local t = os.clock() + s.phase
                            local alpha = (math.sin(t * 1.5) + 1) / 2
                            s.frame.BackgroundTransparency = 0.35 + (alpha * 0.5)
                        end
                        task.wait(0.1)
                    end
                end)

                local _TopBar = Instance.new("Frame")
                _TopBar.Size = UDim2.new(1, 0, 0, 50)
                _TopBar.BackgroundColor3 = _Theme.NebulaBlue
                _TopBar.BorderSizePixel = 0
                _TopBar.Parent = _MainFrame
                local _tbCorner = Instance.new("UICorner")
                _tbCorner.CornerRadius = UDim.new(0, 11)
                _tbCorner.Parent = _TopBar
                local _tbCover = Instance.new("Frame")
                _tbCover.Size = UDim2.new(1, 0, 0, 14)
                _tbCover.Position = UDim2.new(0, 0, 1, -14)
                _tbCover.BackgroundColor3 = _Theme.NebulaBlue
                _tbCover.BorderSizePixel = 0
                _tbCover.Parent = _TopBar
                local _tbGradient = Instance.new("UIGradient")
                _tbGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 28, 65)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 50, 110)),
                })
                _tbGradient.Rotation = 90
                _tbGradient.Parent = _TopBar

                local _InfinityAccent = Instance.new("TextLabel")
                _InfinityAccent.Size = UDim2.new(0, 20, 0, 16)
                _InfinityAccent.Position = UDim2.new(0, 14, 0, 4)
                _InfinityAccent.BackgroundTransparency = 1
                _InfinityAccent.Text = "∞"
                _InfinityAccent.TextColor3 = _Theme.BrightBlue
                _InfinityAccent.Font = _FONT_TITLE
                _InfinityAccent.TextSize = 14
                _InfinityAccent.TextXAlignment = Enum.TextXAlignment.Left
                _InfinityAccent.Parent = _TopBar

                local _Title = Instance.new("TextLabel")
                _Title.Size = UDim2.new(1, -60, 0, 16)
                _Title.Position = UDim2.new(0, 14, 0, 20)
                _Title.BackgroundTransparency = 1
                _Title.Text = "Xrezt AC Bypass"
                _Title.TextColor3 = _Theme.White
                _Title.Font = _FONT_TITLE
                _Title.TextSize = 15
                _Title.TextXAlignment = Enum.TextXAlignment.Left
                _Title.Parent = _TopBar

                local _Subtitle = Instance.new("TextLabel")
                _Subtitle.Size = UDim2.new(1, -60, 0, 12)
                _Subtitle.Position = UDim2.new(0, 14, 0, 36)
                _Subtitle.BackgroundTransparency = 1
                _Subtitle.Text = "Hollow Protocol"
                _Subtitle.TextColor3 = _Theme.TextBlue
                _Subtitle.Font = _FONT_BODY
                _Subtitle.TextSize = 9
                _Subtitle.TextXAlignment = Enum.TextXAlignment.Left
                _Subtitle.Parent = _TopBar

                local _CloseBtn = Instance.new("TextButton")
                _CloseBtn.Size = UDim2.new(0, 24, 0, 24)
                _CloseBtn.Position = UDim2.new(1, -33, 0, 13)
                _CloseBtn.BackgroundColor3 = _Theme.CloseRed
                _CloseBtn.BackgroundTransparency = 0.1
                _CloseBtn.Text = "×"
                _CloseBtn.TextColor3 = _Theme.White
                _CloseBtn.Font = Enum.Font.GothamBold
                _CloseBtn.TextSize = 14
                _CloseBtn.AutoButtonColor = false
                _CloseBtn.Parent = _TopBar
                local _cbCorner = Instance.new("UICorner")
                _cbCorner.CornerRadius = UDim.new(0, 6)
                _cbCorner.Parent = _CloseBtn
                local _cbStroke = Instance.new("UIStroke")
                _cbStroke.Color = _Theme.CloseRed
                _cbStroke.Thickness = 1
                _cbStroke.Transparency = 0.5
                _cbStroke.Parent = _CloseBtn

                _CloseBtn.MouseEnter:Connect(function()
                    _TweenService:Create(_CloseBtn, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundColor3 = _Theme.CloseHover, BackgroundTransparency = 0}):Play()
                    _TweenService:Create(_cbStroke, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0.2}):Play()
                end)
                _CloseBtn.MouseLeave:Connect(function()
                    _TweenService:Create(_CloseBtn, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundColor3 = _Theme.CloseRed, BackgroundTransparency = 0.1}):Play()
                    _TweenService:Create(_cbStroke, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0.5}):Play()
                end)
                _CloseBtn.MouseButton1Click:Connect(function()
                    local outTween = _TweenService:Create(_CanvasGroup, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {GroupTransparency = 1, Position = _CanvasGroup.Position + UDim2.new(0, 0, 0, 10)})
                    outTween:Play()
                    outTween.Completed:Connect(function()
                        _ScreenGui:Destroy()
                        Toggles.ACBypassEnabled:SetValue(false)
                    end)
                end)

                local _Divider = Instance.new("Frame")
                _Divider.Size = UDim2.new(1, -28, 0, 1)
                _Divider.Position = UDim2.new(0, 14, 0, 54)
                _Divider.BackgroundColor3 = _Theme.BrightBlue
                _Divider.BackgroundTransparency = 0.5
                _Divider.BorderSizePixel = 0
                _Divider.Parent = _MainFrame
                local _divGradient = Instance.new("UIGradient")
                _divGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 150, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 180, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 150, 255)),
                })
                _divGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.2, 0.4),
                    NumberSequenceKeypoint.new(0.8, 0.4),
                    NumberSequenceKeypoint.new(1, 1),
                })
                _divGradient.Parent = _Divider

                local _dragging = false
                local _dragInput, _mousePos, _framePos
                _TopBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        _dragging = true
                        _mousePos = input.Position
                        _framePos = _CanvasGroup.Position
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                _dragging = false
                            end
                        end)
                    end
                end)
                _TopBar.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        _dragInput = input
                    end
                end)
                _UserInputService.InputChanged:Connect(function(input)
                    if input == _dragInput and _dragging then
                        local delta = input.Position - _mousePos
                        _CanvasGroup.Position = UDim2.new(
                            _framePos.X.Scale, _framePos.X.Offset + delta.X,
                            _framePos.Y.Scale, _framePos.Y.Offset + delta.Y
                        )
                    end
                end)

                local function _createToggle(name, desc, yPos, parent, onToggle)
                    local Card = Instance.new("Frame")
                    Card.Size = UDim2.new(1, -28, 0, 52)
                    Card.Position = UDim2.new(0, 14, 0, yPos)
                    Card.BackgroundColor3 = _Theme.CardBg
                    Card.BackgroundTransparency = 0.35
                    Card.BorderSizePixel = 0
                    Card.Parent = parent
                    local cardCorner = Instance.new("UICorner")
                    cardCorner.CornerRadius = UDim.new(0, 9)
                    cardCorner.Parent = Card
                    local cardStroke = Instance.new("UIStroke")
                    cardStroke.Color = _Theme.CardStroke
                    cardStroke.Thickness = 1
                    cardStroke.Transparency = 0.4
                    cardStroke.Parent = Card
                    Card.MouseEnter:Connect(function()
                        _TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2}):Play()
                        _TweenService:Create(cardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0.25, Color = _Theme.BrightBlue}):Play()
                    end)
                    Card.MouseLeave:Connect(function()
                        _TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35}):Play()
                        _TweenService:Create(cardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0.4, Color = _Theme.CardStroke}):Play()
                    end)
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -72, 0, 18)
                    Label.Position = UDim2.new(0, 14, 0, 9)
                    Label.BackgroundTransparency = 1
                    Label.Text = name
                    Label.TextColor3 = _Theme.White
                    Label.Font = _FONT_BODY
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = Card
                    local DescLabel = Instance.new("TextLabel")
                    DescLabel.Size = UDim2.new(1, -72, 0, 14)
                    DescLabel.Position = UDim2.new(0, 14, 0, 29)
                    DescLabel.BackgroundTransparency = 1
                    DescLabel.Text = desc
                    DescLabel.TextColor3 = _Theme.SubText
                    DescLabel.Font = _FONT_BODY
                    DescLabel.TextSize = 9
                    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
                    DescLabel.Parent = Card
                    local ToggleTrack = Instance.new("TextButton")
                    ToggleTrack.Size = UDim2.new(0, 50, 0, 26)
                    ToggleTrack.Position = UDim2.new(1, -64, 0.5, -13)
                    ToggleTrack.BackgroundColor3 = _Theme.ToggleOff
                    ToggleTrack.BackgroundTransparency = 0.05
                    ToggleTrack.Text = ""
                    ToggleTrack.AutoButtonColor = false
                    ToggleTrack.Parent = Card
                    local trackCorner = Instance.new("UICorner")
                    trackCorner.CornerRadius = UDim.new(1, 0)
                    trackCorner.Parent = ToggleTrack
                    local trackStroke = Instance.new("UIStroke")
                    trackStroke.Color = _Theme.BrightBlue
                    trackStroke.Thickness = 1.5
                    trackStroke.Transparency = 1
                    trackStroke.Parent = ToggleTrack
                    local Knob = Instance.new("Frame")
                    Knob.Size = UDim2.new(0, 18, 0, 18)
                    Knob.Position = UDim2.new(0, 4, 0.5, -9)
                    Knob.BackgroundColor3 = _Theme.KnobOff
                    Knob.BorderSizePixel = 0
                    Knob.Parent = ToggleTrack
                    local knobCorner = Instance.new("UICorner")
                    knobCorner.CornerRadius = UDim.new(1, 0)
                    knobCorner.Parent = Knob
                    local knobStroke = Instance.new("UIStroke")
                    knobStroke.Color = Color3.fromRGB(50, 70, 110)
                    knobStroke.Thickness = 1
                    knobStroke.Transparency = 0.3
                    knobStroke.Parent = Knob
                    local tState = false
                    local pulseRunning = false
                    local function updateVisual()
                        local tiBounce = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        local tiSine   = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                        if tState then
                            _TweenService:Create(ToggleTrack, tiSine, {BackgroundColor3 = _Theme.ToggleOn, BackgroundTransparency = 0}):Play()
                            _TweenService:Create(Knob, tiBounce, {Position = UDim2.new(1, -22, 0.5, -9), BackgroundColor3 = _Theme.KnobOn}):Play()
                            _TweenService:Create(knobStroke, tiSine, {Color = _Theme.BrightBlue, Transparency = 0.5}):Play()
                            _TweenService:Create(trackStroke, tiSine, {Transparency = 0.3}):Play()
                            pulseRunning = true
                            task.spawn(function()
                                while pulseRunning and tState do
                                    _TweenService:Create(trackStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.65}):Play()
                                    task.wait(0.9)
                                    if not (pulseRunning and tState) then break end
                                    _TweenService:Create(trackStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.15}):Play()
                                    task.wait(0.9)
                                end
                            end)
                        else
                            pulseRunning = false
                            _TweenService:Create(ToggleTrack, tiSine, {BackgroundColor3 = _Theme.ToggleOff, BackgroundTransparency = 0.05}):Play()
                            _TweenService:Create(Knob, tiBounce, {Position = UDim2.new(0, 4, 0.5, -9), BackgroundColor3 = _Theme.KnobOff}):Play()
                            _TweenService:Create(knobStroke, tiSine, {Color = Color3.fromRGB(50, 70, 110), Transparency = 0.3}):Play()
                            _TweenService:Create(trackStroke, tiSine, {Transparency = 1}):Play()
                        end
                    end
                    ToggleTrack.MouseButton1Click:Connect(function()
                        tState = not tState
                        updateVisual()
                        if onToggle then
                            task.spawn(onToggle, tState)
                        end
                    end)
                    return {
                        get = function() return tState end,
                        set = function(v)
                            tState = v
                            updateVisual()
                        end,
                        card = Card,
                    }
                end

                local _StatusCard = Instance.new("Frame")
                _StatusCard.Size = UDim2.new(1, -28, 0, 34)
                _StatusCard.Position = UDim2.new(0, 14, 0, 184)
                _StatusCard.BackgroundColor3 = _Theme.CardBg
                _StatusCard.BackgroundTransparency = 0.35
                _StatusCard.BorderSizePixel = 0
                _StatusCard.Parent = _MainFrame
                local _scCorner = Instance.new("UICorner")
                _scCorner.CornerRadius = UDim.new(0, 9)
                _scCorner.Parent = _StatusCard
                local _scStroke = Instance.new("UIStroke")
                _scStroke.Color = _Theme.CardStroke
                _scStroke.Thickness = 1
                _scStroke.Transparency = 0.4
                _scStroke.Parent = _StatusCard

                local _PingRing = Instance.new("Frame")
                _PingRing.Size = UDim2.new(0, 10, 0, 10)
                _PingRing.Position = UDim2.new(0, 15, 0.5, -5)
                _PingRing.BackgroundColor3 = _Theme.Orange
                _PingRing.BackgroundTransparency = 1
                _PingRing.BorderSizePixel = 0
                _PingRing.Parent = _StatusCard
                local _prCorner = Instance.new("UICorner")
                _prCorner.CornerRadius = UDim.new(1, 0)
                _prCorner.Parent = _PingRing

                local _StatusDot = Instance.new("Frame")
                _StatusDot.Size = UDim2.new(0, 10, 0, 10)
                _StatusDot.Position = UDim2.new(0, 15, 0.5, -5)
                _StatusDot.BackgroundColor3 = _Theme.SubText
                _StatusDot.BorderSizePixel = 0
                _StatusDot.Parent = _StatusCard
                local _sdCorner = Instance.new("UICorner")
                _sdCorner.CornerRadius = UDim.new(1, 0)
                _sdCorner.Parent = _StatusDot
                local _sdStroke = Instance.new("UIStroke")
                _sdStroke.Color = _Theme.BrightBlue
                _sdStroke.Thickness = 1
                _sdStroke.Transparency = 0.5
                _sdStroke.Parent = _StatusDot

                local _StatusText = Instance.new("TextLabel")
                _StatusText.Size = UDim2.new(1, -42, 1, 0)
                _StatusText.Position = UDim2.new(0, 32, 0, 0)
                _StatusText.BackgroundTransparency = 1
                _StatusText.Text = "Idle"
                _StatusText.TextColor3 = _Theme.SubText
                _StatusText.Font = _FONT_BODY
                _StatusText.TextSize = 11
                _StatusText.TextXAlignment = Enum.TextXAlignment.Left
                _StatusText.Parent = _StatusCard

                local _pingRunning = false
                local function _updateStatus(text, color)
                    _StatusText.Text = text
                    _TweenService:Create(_StatusDot, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundColor3 = color}):Play()
                    _TweenService:Create(_StatusText, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = color}):Play()
                    if color == _Theme.Orange or color == _Theme.Green then
                        _PingRing.BackgroundColor3 = color
                        if not _pingRunning then
                            _pingRunning = true
                            task.spawn(function()
                                while _pingRunning do
                                    _PingRing.Size = UDim2.new(0, 10, 0, 10)
                                    _PingRing.Position = UDim2.new(0, 15, 0.5, -5)
                                    _PingRing.BackgroundTransparency = 0.2
                                    _TweenService:Create(_PingRing, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                                        Size = UDim2.new(0, 30, 0, 30),
                                        Position = UDim2.new(0, 5, 0.5, -15),
                                        BackgroundTransparency = 1
                                    }):Play()
                                    task.wait(0.65)
                                end
                            end)
                        end
                    else
                        _pingRunning = false
                    end
                end

                local function _getRandomPlayer()
                    local valid = {}
                    for _, p in ipairs(_Players:GetPlayers()) do
                        if p ~= _LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            table.insert(valid, p)
                        end
                    end
                    if #valid == 0 then return nil end
                    return valid[math.random(1, #valid)]
                end

                local function _getCFrame()
                    local char = _LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        return char.HumanoidRootPart.CFrame
                    end
                    return nil
                end

                local function _teleportTo(targetPlayer)
                    local char = _LocalPlayer.Character
                    local target = targetPlayer.Character
                    if not char or not target then return false end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local thrp = target:FindFirstChild("HumanoidRootPart")
                    if not hrp or not thrp then return false end
                    hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 4)
                    return true
                end

                local function _isRubberBanded(originalCFrame)
                    local current = _getCFrame()
                    if not current then return true end
                    return (current.Position - originalCFrame.Position).Magnitude < 8
                end

                local function _knitReset()
                    if _ResetRemote then
                        pcall(function() _ResetRemote:FireServer() end)
                    end
                end

                local function _waitForRespawn()
                    local oldChar = _LocalPlayer.Character
                    local t = 0
                    while _LocalPlayer.Character == oldChar and t < 10 do
                        task.wait(0.1)
                        t = t + 0.1
                    end
                    local newChar = _LocalPlayer.Character
                    if not newChar or not newChar.Parent or newChar == oldChar then
                        newChar = _LocalPlayer.CharacterAdded:Wait()
                    end
                    newChar:WaitForChild("HumanoidRootPart", 10)
                    task.wait(0.3)
                end

                local _acBypassToggle
                local _rapidTPToggle
                local _acBypassRunning = false

                local function _startACBypass()
                    if _acBypassRunning then return end
                    _acBypassRunning = true
                    local attempts = 0
                    task.spawn(function()
                        while _acBypassRunning do
                            if not _acBypassToggle.get() then
                                _acBypassRunning = false
                                break
                            end
                            local originalCFrame = _getCFrame()
                            if not originalCFrame then
                                task.wait(1)
                            else
                                local target = _getRandomPlayer()
                                if not target then
                                    _updateStatus("No valid player found", _Theme.Red)
                                    task.wait(2)
                                else
                                    attempts = attempts + 1
                                    _updateStatus("Attempt " .. attempts .. " → " .. target.Name, _Theme.Orange)
                                    if _teleportTo(target) then
                                        task.wait(0.35)
                                        if _isRubberBanded(originalCFrame) then
                                            _updateStatus("Rubber-banded - resetting...", _Theme.Orange)
                                            _knitReset()
                                            _waitForRespawn()
                                            task.wait(0.3)
                                            if not _acBypassToggle.get() then
                                                _acBypassRunning = false
                                                break
                                            end
                                        else
                                            _updateStatus("AC Bypassed", _Theme.Green)
                                            _TweenService:Create(_scStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = _Theme.Green, Transparency = 0}):Play()
                                            task.delay(1.5, function()
                                                _TweenService:Create(_scStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Color = _Theme.CardStroke, Transparency = 0.4}):Play()
                                            end)
                                            task.wait(0.5)
                                            local char = _LocalPlayer.Character
                                            if char and char:FindFirstChild("HumanoidRootPart") then
                                                char.HumanoidRootPart.CFrame = originalCFrame
                                            end
                                            _acBypassToggle.set(false)
                                            _acBypassRunning = false
                                            break
                                        end
                                    else
                                        task.wait(0.5)
                                    end
                                end
                            end
                        end
                    end)
                end

                local _rapidTPRunning = false
                local function _startRapidTP()
                    if _rapidTPRunning then return end
                    _rapidTPRunning = true
                    task.spawn(function()
                        while _rapidTPRunning do
                            if not _rapidTPToggle.get() then
                                _rapidTPRunning = false
                                break
                            end
                            for _, p in ipairs(_Players:GetPlayers()) do
                                if not _rapidTPRunning or not _rapidTPToggle.get() then break end
                                if p ~= _LocalPlayer then
                                    local char = _LocalPlayer.Character
                                    local target = p.Character
                                    if char and target then
                                        local hrp = char:FindFirstChild("HumanoidRootPart")
                                        local thrp = target:FindFirstChild("HumanoidRootPart")
                                        if hrp and thrp then
                                            hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 3)
                                        end
                                    end
                                    task.wait(0.05)
                                end
                            end
                            task.wait(0.1)
                        end
                    end)
                end

                _acBypassToggle = _createToggle("AC Bypass", "TP to random player + Knit reset on rubber-band", 62, _MainFrame, function(s)
                    if s then
                        _startACBypass()
                    else
                        _acBypassRunning = false
                        _pingRunning = false
                        _updateStatus("Idle", _Theme.SubText)
                    end
                end)

                _rapidTPToggle = _createToggle("Rapid TP", "Cycle teleport through all players", 118, _MainFrame, function(s)
                    if s then
                        _startRapidTP()
                    else
                        _rapidTPRunning = false
                    end
                end)

                local _entranceTarget = _CanvasGroup.Position
                _CanvasGroup.Position = _entranceTarget + UDim2.new(0, 0, 0, 14)
                task.wait(0.05)
                _TweenService:Create(_CanvasGroup, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
                _TweenService:Create(_CanvasGroup, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = _entranceTarget}):Play()

                task.spawn(function()
                    local rotation = 0
                    while _ScreenGui.Parent do
                        rotation = rotation + 0.3
                        if rotation >= 360 then rotation = 0 end
                        _bgGradient.Rotation = rotation
                        task.wait(0.08)
                    end
                end)

                task.spawn(function()
                    local t = 0
                    while _ScreenGui.Parent do
                        t = t + 0.04
                        local alpha = (math.sin(t) + 1) / 2
                        _g1s.Transparency = 0.55 + (alpha * 0.3)
                        _g2s.Transparency = 0.72 + (alpha * 0.25)
                        _mfStroke.Transparency = 0.2 + (alpha * 0.25)
                        task.wait(0.04)
                    end
                end)

                _updateStatus("Idle", _Theme.SubText)
            end)
        else
            local coreGui = game:GetService("CoreGui")
            local existingGui = coreGui:FindFirstChild("XreztACBypass")
            if existingGui then
                existingGui:Destroy()
            else
                local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                if pGui then
                    local g = pGui:FindFirstChild("XreztACBypass")
                    if g then g:Destroy() end
                end
            end
        end
    end
})
end



do
local YujiGroup = AutoTab:AddLeftGroupbox('Yuji', 'sword')
YujiGroup:AddToggle('BlackflashEnabled', { Text = 'Enable Auto Blackflash', Default = false })
YujiGroup:AddToggle('BlackflashDashBehind', { Text = 'Dash Behind Target', Default = true })
YujiGroup:AddToggle('BlackflashCameraLock', { Text = 'Target Lock-On', Default = true })
YujiGroup:AddToggle('BlackflashTargetPlayers', { Text = 'Target Players', Default = true })
YujiGroup:AddToggle('BlackflashTargetDummies', { Text = 'Target Dummies / NPCs', Default = true })

YujiGroup:AddSlider('BlackflashDashDuration', { Text = 'Dash Glide Speed', Min = 0.05, Max = 0.5, Default = 0.18, Rounding = 2 })
YujiGroup:AddSlider('BlackflashCurveStrength', { Text = 'Bezier Arc Deviation', Min = 2, Max = 20, Default = 10, Rounding = 1 })
YujiGroup:AddSlider('BlackflashMaxRange', { Text = 'Maximum Lock Distance', Min = 10, Max = 50, Default = 25, Rounding = 1 })
YujiGroup:AddSlider('BlackflashAutoFireDelay', { Text = 'Black Flash Fire Delay', Min = 0.05, Max = 0.4, Default = 0.23, Rounding = 2 })

local BlackflashBindLabel = YujiGroup:AddLabel('Manual Blackflash Keybind')
BlackflashBindLabel:AddKeyPicker('BlackflashKeybind', { NoUI = false, Default = 'Q', Text = 'Manual Blackflash keybind' })

YujiGroup:AddToggle('AutoWCS', { Text = 'Auto WCS', Default = false })

local HakariGroup = AutoTab:AddLeftGroupbox('Hakari', 'ticket')
HakariGroup:AddToggle('AutoDoor', { Text = 'Auto Door (Hakari)', Default = false })
HakariGroup:AddToggle('FeverCrusher', { Text = 'Fever Crusher', Default = false })

local YukiGroup = AutoTab:AddLeftGroupbox('Yuki', 'star')
YukiGroup:AddToggle('GarudaRebound', { Text = 'Garuda Rebound', Default = false })
YukiGroup:AddSlider('GarudaDelay', { Text = 'Garuda Delay', Min = 0.0, Max = 5.0, Default = 1.0, Rounding = 1 })

local MahitoGroup = AutoTab:AddRightGroupbox('Mahito', 'zap')
MahitoGroup:AddToggle('AutoMahitoBlackflash', {
    Text = 'Auto Mahito Blackflash',
    Default = false,
    Tooltip = 'Automatically fires Focus Strike when Mahito Black Flash animation plays.',
    Callback = function(state)
        if state then
            if LocalPlayer.Character then
                SetupMahitoCharacter(LocalPlayer.Character)
            end
        else
            if MahitoConnection then
                MahitoConnection:Disconnect()
                MahitoConnection = nil
            end
        end
    end
})

local HiromiGroup = AutoTab:AddRightGroupbox('Hiromi', 'gavel')
HiromiGroup:AddToggle('AutoQTEEnabled', {
    Text = 'Enable Auto QTE',
    Default = false,
    Callback = function(state)
        if state then
            startAutoQTE()
        else
            stopAutoQTE()
        end
    end
})
HiromiGroup:AddToggle('AutoDomain', {
    Text = 'Auto Domain Vote',
    Default = false,
    Callback = HandleAutoDomain
})

local PotentialFraudGroup = AutoTab:AddRightGroupbox('Potential Fraud', 'zap')
PotentialFraudGroup:AddToggle('AutoNueVariant', { Text = 'Auto Nue Variant', Default = false })
PotentialFraudGroup:AddToggle('AutoFrogVariant', { Text = 'Auto Frog Variant', Default = false })

local NanamiGroup = AutoTab:AddRightGroupbox('Nanami', 'zap')
NanamiGroup:AddToggle('AutoRatio', { Text = 'Auto Ratio', Default = false, Callback = HandleAutoRatio })

local TodoGroup = AutoTab:AddRightGroupbox('Todo', 'zap')
TodoGroup:AddToggle('PerfectSwap', { Text = 'Perfect Swap', Default = false, Callback = HandlePerfectSwap })
end


local SideDashGroup = SideDashTab:AddLeftGroupbox("Side Dash Assist", "zap")

SideDashGroup:AddToggle("SideDashEnabled", {
    Text = "Enable Side Dash Assist",
    Default = false,
    Tooltip = "auto dash behind nearest enemy",
})

SideDashGroup:AddToggle("SideDashMobileButton", {
    Text = "Show Mobile Button",
    Default = false,
    Tooltip = "draggable button for mobile",
    Callback = function(state)
        if state then
            createSideDashMobileButton()
        else
            removeSideDashMobileButton()
        end
    end,
})

SideDashGroup:AddLabel("Side Dash Keybind"):AddKeyPicker("SideDashKeybind", {
    Default = "Q",
    Mode = "Press",
    Text = "Side Dash Keybind",
    NoUI = false,
    Callback = function()
        startSideDash()
    end,
})

SideDashGroup:AddSlider("SideDashRange", {
    Text = "Target Range",
    Min = 5,
    Max = 50,
    Default = 20,
    Rounding = 0,
})

SideDashGroup:AddSlider("SideDashDistance", {
    Text = "Stop Distance Behind",
    Min = 1,
    Max = 10,
    Default = 3,
    Rounding = 1,
})

SideDashGroup:AddSlider("SideDashDuration", {
    Text = "Dash Duration",
    Min = 0.05,
    Max = 1.0,
    Default = 0.35,
    Rounding = 2,
})

SideDashGroup:AddSlider("SideDashArcWidth", {
    Text = "Side Step Width",
    Min = 0,
    Max = 30,
    Default = 8,
    Rounding = 0,
})

SideDashGroup:AddSlider("SideDashCamLift", {
    Text = "Camera Lift",
    Min = 0,
    Max = 10,
    Default = 3,
    Rounding = 1,
})

do
local SystemGroup = ConfigTab:AddLeftGroupbox('System', 'settings')
SystemGroup:AddToggle('ShowNotifications', { Text = 'Show Notifications', Default = true, Callback = function() end })
SystemGroup:AddToggle('DebugMode', { Text = 'Debug Mode (F9 Console)', Default = false, Callback = function() end })
SystemGroup:AddToggle('ShowKeybinds', {
    Text = 'Show Keybind List',
    Default = false,
    Callback = function(state)
        if Library.KeybindFrame then
            Library.KeybindFrame.Visible = state
        end
    end
})

local MenuBindLabel = SystemGroup:AddLabel('Menu Keybind')
MenuBindLabel:AddKeyPicker('MenuKeybind', {
    Default = 'RightControl',
    NoUI = true,
    Text = 'Toggle Menu'
})
Library.ToggleKeybind = Options.MenuKeybind

local MenuGroup = ConfigTab:AddRightGroupbox('Script Control', 'wrench')
MenuGroup:AddButton('Unload Script', function()
    ScriptActive = false
    DisableInvisibility()
    removeSideDashMobileButton()
    if BlockStateMachine then BlockStateMachine:ReleaseAll() end
    AlwaysDownslamActive = false
    InfiniteParkourActive = false
    AutoParkourActive = false
    InfiniteDashActive = false
    for _, conn in pairs(ActiveConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(ActiveConnections)
    if _G.EmoteSwitchConn then pcall(function() _G.EmoteSwitchConn:Disconnect() end); _G.EmoteSwitchConn = nil end
    RemoveMobileButton("LockOn")
    RestoreAimlockStates()
    pcall(function() RunService:UnbindFromRenderStep("AimlockLoop") end)
    stopLock(); pcall(function() ContextActionService:UnbindAction("LockOn") end); pcall(function() screenGui:Destroy() end)
    CleanupEsp()
    Library:Unload()
end)

MenuGroup:AddButton('Force Release All Blocks', function()
    BlockStateMachine:ReleaseAll()
    for charName, _ in pairs(EnemyTracker._enemies) do
        EnemyTracker._enemies[charName] = nil
    end
    if Toggles.ShowNotifications and Toggles.ShowNotifications.Value then
        Library:Notify({ Title = 'Phantom Block', Description = 'All blocks force released', Time = 2 })
    end
end)

MenuGroup:AddButton('Clear Animation Cache', function()
    table_clear(DynamicAnimationCache)
    DynamicCacheHits = 0
    DynamicCacheMisses = 0
    if Toggles.ShowNotifications and Toggles.ShowNotifications.Value then
        Library:Notify({ Title = 'Phantom Block', Description = 'Animation cache cleared', Time = 2 })
    end
end)

MenuGroup:AddButton('Re-resolve Block Remotes', function()
    BlockRemoteCache._resolved = false
    BlockRemoteCache._lastResolveAttempt = 0
    BlockRemoteCache:Resolve()
    if Toggles.ShowNotifications and Toggles.ShowNotifications.Value then
        local status = BlockRemoteCache._resolved and "Success" or "Failed"
        Library:Notify({ Title = 'Phantom Block', Description = 'Remote resolve: ' .. status, Time = 2 })
    end
end)
end







task.spawn(SetupWorkspaceConnections)
task.spawn(StartAimlockMonitor)
task.spawn(StartEspLoop)

task.spawn(function()
    local movementController = nil
    local conn
    local _dbgLib = (function()
        local ok, lib = pcall(function() return rawget(_G, "\100\101\98\117\103") end)
        if ok and lib then return lib end
        return nil
    end)()
    local hasDebug = _dbgLib ~= nil and _dbgLib.getupvalues ~= nil and _dbgLib.setupvalue ~= nil
    conn = RunService.Heartbeat:Connect(function()
        if not InfiniteParkourActive then return end
        if not hasDebug then InfiniteParkourActive = false; return end
        if not movementController then
            pcall(function()
                movementController = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Controllers"):WaitForChild("Character"):WaitForChild("MovementController"))
            end)
            return
        end
        pcall(function()
            for name, val in pairs(_dbgLib.getupvalues(movementController.Parkour)) do
                if type(val) == "number" then
                    _dbgLib.setupvalue(movementController.Parkour, name, 0)
                end
            end
        end)
    end)
    table.insert(ActiveConnections, conn)
end)


task.spawn(function()
    local Knit = ReplicatedStorage:WaitForChild("Knit", 5)
    local MC = nil
    
    local setupval = (function()
        local ok, lib = pcall(function() return rawget(_G, "\100\101\98\117\103") end)
        if ok and lib and lib.setupvalue then return lib.setupvalue end
        return setupvalue
    end)()
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local isParkouring = false
    local lastParkourTime = 0
    local activeVelocityTime = 0
    local parkourTrack = nil

    local function playParkourAnimation(animator)
        local animAsset = ReplicatedStorage:FindFirstChild("Animations")
        if animAsset then
            local misc = animAsset:FindFirstChild("Misc")
            local movement = misc and misc:FindFirstChild("Movement")
            local parkourAnim = movement and movement:FindFirstChild("Parkour")
            if parkourAnim then
                local ok, track = pcall(function() return animator:LoadAnimation(parkourAnim) end)
                if ok and track then
                    parkourTrack = track
                    track:Play(0.1)
                end
            end
        end
    end

    local conn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if not MC then
            pcall(function()
                local controllers = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Controllers"):WaitForChild("Character"):WaitForChild("MovementController"))
                MC = controllers
            end)
        end
        
        -- Infinite Dash Handler
        if InfiniteDashActive and setupval and MC and MC.Dash then
            pcall(function()
                setupval(MC.Dash, 6, 0)
            end)
        end
        
        if not AutoParkourActive then return end
        
        -- Keep wall run chain count at 0
        if setupval and MC and MC.Parkour then
            pcall(function()
                setupval(MC.Parkour, 2, 0)
            end)
        end
        
        local now = os.clock()
        
        if isParkouring and (now - activeVelocityTime < 0.35) then
            local lookVec = hrp.CFrame.LookVector
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, CLIMB_SPEED, hrp.AssemblyLinearVelocity.Z) + (lookVec * FORWARD_SPEED)
            return
        end
        
        if now - lastParkourTime < 0.70 then return end
        isParkouring = false
        
        if hum.MoveDirection.Magnitude <= 0.1 then return end
        
        local filterList = {char}
        local charactersFolder = workspace:FindFirstChild("Characters")
        if charactersFolder then
            table.insert(filterList, charactersFolder)
        end
        raycastParams.FilterDescendantsInstances = filterList
        
        local origin = hrp.Position
        local direction = hrp.CFrame.LookVector * DETECTION_DISTANCE
        local result = workspace:Raycast(origin, direction, raycastParams)
        
        if result and result.Instance and not (result.Instance.CanCollide == false) then
            if math.abs(result.Normal.Y) < 0.5 then
                isParkouring = true
                lastParkourTime = now
                activeVelocityTime = now
                
                hum.Jump = true
                
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    playParkourAnimation(animator)
                end
                
                if MC and MC.Parkour then
                    pcall(function()
                        MC:Parkour(char, hrp, hum)
                    end)
                end
            end
        end
    end)
    table.insert(ActiveConnections, conn)
end)

if LocalPlayer.Character then 
    hookVariantCharacter(LocalPlayer.Character)
    if Toggles.AutoMahitoBlackflash and Toggles.AutoMahitoBlackflash.Value then
        SetupMahitoCharacter(LocalPlayer.Character)
    end
    setupBlackflashCharacterMonitor(LocalPlayer.Character)
    setupCustomAnimationTriggers(LocalPlayer.Character)
end
table.insert(ActiveConnections, LocalPlayer.CharacterAdded:Connect(hookVariantCharacter))
table.insert(ActiveConnections, LocalPlayer.CharacterAdded:Connect(function(char)
    if Toggles.AutoMahitoBlackflash and Toggles.AutoMahitoBlackflash.Value then
        SetupMahitoCharacter(char)
    end
    setupBlackflashCharacterMonitor(char)
    setupCustomAnimationTriggers(char)
    if InvisibilityState.Active then
        task.wait(1)
        Toggles.Invisibility:SetValue(false)
    end
end))

ThemeManager:SetLibrary(Library); SaveManager:SetLibrary(Library);
SaveManager:IgnoreThemeSettings(); SaveManager:SetIgnoreIndexes({'MenuKeybind', 'AimlockKeybind', 'BlackflashKeybind', 'SideDashKeybind', 'BoxEspColor', 'NameEspColor', 'DummyChamsColor', 'TracerColor'})
ThemeManager:SetFolder('XreztBlocker'); SaveManager:SetFolder('XreztBlocker/configs')
SaveManager:BuildConfigSection(ConfigTab); ThemeManager:ApplyToTab(ConfigTab); SaveManager:LoadAutoloadConfig()

if Toggles.AutoMahitoBlackflash and Toggles.AutoMahitoBlackflash.Value then
    if LocalPlayer.Character then
        SetupMahitoCharacter(LocalPlayer.Character)
    end
end

if Toggles.ShowNotifications.Value then
    Library:Notify({ Title = 'Xrezt Hub Initialized', Description = 'V1 - Release', Time = 4 })
end