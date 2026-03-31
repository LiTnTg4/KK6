-- 废土终端 - 完整单脚本版（包含所有功能）
-- 复制整个代码，在 Roblox 的开发者控制台(F9)中运行

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ==================== 状态管理 ====================
local State = {
    Graphics = false,
    R6Leg = false,
    R15Leg = false,
    Hat = false
}

-- ==================== 无头效果模块 ====================
local Headless = {active = true}

function Headless.enable(bool)
    Headless.active = bool
    local c = player.Character
    if c then
        local head = c:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            head.CanCollide = false
        end
        local face = c:FindFirstChild("Face")
        if face then face:Destroy() end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        local c = player.Character
        if c then
            local head = c:FindFirstChild("Head")
            if head and head.Transparency ~= 1 then
                head.Transparency = 1
            end
        end
    end
end)

-- ==================== 断腿效果模块 ====================
local LegEffects = {
    r6S = false,
    r15S = false,
    sR = {}
}

local r6Leg = nil
local r15Leg = nil

local function findPart(container, names)
    if not container then return nil end
    for _, name in ipairs(names) do
        local part = container:FindFirstChild(name)
        if part then return part end
    end
    return nil
end

local function createR6Leg()
    if r6Leg and r6Leg.Parent then r6Leg:Destroy() end
    r6Leg = Instance.new("Part")
    r6Leg.Name = "R6BrokenLeg"
    r6Leg.Size = Vector3.new(0.832, 0.2496, 0.832)
    r6Leg.BrickColor = BrickColor.new("Medium stone grey")
    r6Leg.Material = Enum.Material.SmoothPlastic
    r6Leg.Transparency = 0
    r6Leg.Anchored = true
    r6Leg.CanCollide = false
    r6Leg.Parent = workspace
    
    local m = Instance.new("SpecialMesh")
    m.MeshId = "http://www.roblox.com/asset/?id=902942096"
    m.TextureId = "http://www.roblox.com/asset/?id=902843398"
    m.Scale = Vector3.new(0.936, 0.9984, 0.936)
    m.Parent = r6Leg
end

local function createR15Leg()
    if r15Leg and r15Leg.Parent then r15Leg:Destroy() end
    r15Leg = Instance.new("Part")
    r15Leg.Name = "R15BrokenLeg"
    r15Leg.Size = Vector3.new(0.832, 0.2496, 0.832)
    r15Leg.BrickColor = BrickColor.new("Medium stone grey")
    r15Leg.Material = Enum.Material.SmoothPlastic
    r15Leg.Transparency = 0
    r15Leg.Anchored = true
    r15Leg.CanCollide = false
    r15Leg.Parent = workspace
    
    local m = Instance.new("SpecialMesh")
    m.MeshId = "http://www.roblox.com/asset/?id=902942096"
    m.TextureId = "http://www.roblox.com/asset/?id=902843398"
    m.Scale = Vector3.new(0.936, 0.9984, 0.936)
    m.Parent = r15Leg
end

local function forceHideR6(c)
    if not c then return end
    local upper = findPart(c, {"RightUpperLeg", "Right Leg"})
    local lower = findPart(c, {"RightLowerLeg"})
    local foot = findPart(c, {"RightFoot", "Right Foot"})
    if upper then upper.Transparency = 1; upper.CanCollide = false end
    if lower then lower.Transparency = 1; lower.CanCollide = false end
    if foot then foot.Transparency = 1; foot.CanCollide = false end
end

local function forceShowR6(c)
    if not c then return end
    local upper = findPart(c, {"RightUpperLeg", "Right Leg"})
    local lower = findPart(c, {"RightLowerLeg"})
    local foot = findPart(c, {"RightFoot", "Right Foot"})
    if upper then upper.Transparency = 0; upper.CanCollide = true end
    if lower then lower.Transparency = 0; lower.CanCollide = true end
    if foot then foot.Transparency = 0; foot.CanCollide = true end
end

local function forceHideR15(c)
    if not c then return end
    local upper = findPart(c, {"RightUpperLeg"})
    local lower = findPart(c, {"RightLowerLeg"})
    local foot = findPart(c, {"RightFoot", "Right Foot"})
    if upper then LegEffects.sR[upper] = {Transparency = upper.Transparency}; upper.Transparency = 1 end
    if lower then LegEffects.sR[lower] = {Transparency = lower.Transparency}; lower.Transparency = 1 end
    if foot then LegEffects.sR[foot] = {Transparency = foot.Transparency}; foot.Transparency = 1 end
end

function LegEffects.enableR6(bool)
    LegEffects.r6S = bool
    if bool then
        if player.Character then
            createR6Leg()
            forceHideR6(player.Character)
        end
    else
        if r6Leg then r6Leg:Destroy(); r6Leg = nil end
        if player.Character then forceShowR6(player.Character) end
    end
end

function LegEffects.enableR15(bool)
    LegEffects.r15S = bool
    if bool then
        if player.Character then
            createR15Leg()
            forceHideR15(player.Character)
        end
    else
        for part, data in pairs(LegEffects.sR) do
            if part and part.Parent then part.Transparency = data.Transparency or 0 end
        end
        LegEffects.sR = {}
        if r15Leg then r15Leg:Destroy(); r15Leg = nil end
    end
end

function LegEffects.update()
    local c = player.Character
    if not c then return end
    
    if LegEffects.r6S and r6Leg then
        local upper = findPart(c, {"RightUpperLeg", "Right Leg"})
        if upper then r6Leg.CFrame = upper.CFrame * CFrame.new(0, 0.7, 0) end
        forceHideR6(c)
    end
    
    if LegEffects.r15S and r15Leg then
        local upper = findPart(c, {"RightUpperLeg"})
        if upper then r15Leg.CFrame = upper.CFrame * CFrame.new(0, 0.19, 0) end
    end
end

-- ==================== 画质优化模块 ====================
local Graphics = {active = false, materials = {}}

function Graphics.enable(bool)
    Graphics.active = bool
    if bool then
        pcall(function()
            local L = game:GetService("Lighting")
            L.GlobalShadows = false
            L.FogEnabled = false
            for _, v in L:GetChildren() do
                if v:IsA("PostEffect") then v.Enabled = false end
            end
        end)
        pcall(function()
            local U = game:GetService("UserSettings")
            local u = U:GetService("UserGameSettings")
            u.GraphicsQuality = Enum.GraphicsQuality.Level01
            u.RenderScale = 0.2
            u.Shadows = false
            u.TextureQuality = Enum.TextureQuality.Level01
        end)
        for _, o in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if o:IsA("BasePart") and o.Parent ~= player.Character then
                    if not Graphics.materials[o] then Graphics.materials[o] = o.Material end
                    o.Material = Enum.Material.Plastic
                end
                if o:IsA("Texture") or o:IsA("Decal") then o:Destroy() end
                if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then o:Destroy() end
            end)
        end
    else
        pcall(function()
            local L = game:GetService("Lighting")
            L.GlobalShadows = true
            L.FogEnabled = true
        end)
        pcall(function()
            local U = game:GetService("UserSettings")
            local u = U:GetService("UserGameSettings")
            u.GraphicsQuality = Enum.GraphicsQuality.Automatic
            u.RenderScale = 1
            u.Shadows = true
            u.TextureQuality = Enum.TextureQuality.Automatic
        end)
        for o, m in pairs(Graphics.materials) do
            pcall(function() if o and o.Parent then o.Material = m end end)
        end
        Graphics.materials = {}
    end
end

-- ==================== 隐藏饰品模块 ====================
local HatHider = {}

function HatHider.enable(bool)
    local c = player.Character
    if not c then return end
    local kw = {"hair", "hat", "helmet", "cap", "hood", "headgear", "beanie", "visor", "accessory"}
    local t = bool and 1 or 0
    for _, o in c:GetDescendants() do
        if o:IsA("BasePart") then
            local n = o.Name:lower()
            for _, k in ipairs(kw) do
                if n:find(k) then
                    o.Transparency = t
                    break
                end
            end
        end
        if o:IsA("Accessory") then
            local h = o:FindFirstChild("Handle")
            if h then h.Transparency = t end
        end
    end
end

-- ==================== 性能监控面板 ====================
local function createPerfMonitor()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WastelandPerfMonitor"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local function getScale()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local referenceHeight = 1080
        return math.max(0.8, math.min(1.5, viewportSize.Y / referenceHeight))
    end
    
    local scale = getScale()
    local savedPosition = nil
    
    local dragFrame = Instance.new("Frame")
    dragFrame.Size = UDim2.new(0, 0, 0, 21 * scale)
    dragFrame.Position = UDim2.new(0.5, 0, 0.05, 0)
    dragFrame.BackgroundTransparency = 1
    dragFrame.Active = true
    dragFrame.Draggable = true
    dragFrame.Parent = screenGui
    
    dragFrame:GetPropertyChangedSignal("Position"):Connect(function()
        savedPosition = dragFrame.Position
    end)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 15, 10)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = dragFrame
    
    local border = Instance.new("UIStroke")
    border.Thickness = 2
    border.Color = Color3.fromRGB(180, 100, 40)
    border.Transparency = 0.3
    border.Parent = frame
    
    local function addCorner(parent, x, y)
        local corner = Instance.new("Frame")
        corner.Size = UDim2.new(0, 5, 0, 5)
        corner.Position = UDim2.new(x, x == 0 and 0 or -5, y, y == 0 and 0 or -5)
        corner.BackgroundColor3 = Color3.fromRGB(180, 100, 40)
        corner.BackgroundTransparency = 0.5
        corner.BorderSizePixel = 0
        corner.Parent = parent
    end
    
    task.defer(function()
        addCorner(frame, 0, 0)
        addCorner(frame, 1, 0)
        addCorner(frame, 0, 1)
        addCorner(frame, 1, 1)
    end)
    
    local perfText = Instance.new("TextButton")
    perfText.Name = "PerfText"
    perfText.BackgroundTransparency = 1
    perfText.Text = "FPS:060 PING:088ms"
    perfText.TextColor3 = Color3.fromRGB(255, 180, 80)
    perfText.TextSize = math.floor(16 * scale)
    perfText.Font = Enum.Font.Code
    perfText.TextXAlignment = Enum.TextXAlignment.Left
    perfText.TextYAlignment = Enum.TextYAlignment.Center
    perfText.Active = false
    perfText.Draggable = false
    perfText.Visible = true
    perfText.Parent = frame
    
    local cursor = Instance.new("TextLabel")
    cursor.Size = UDim2.new(0, 10, 1, 0)
    cursor.Position = UDim2.new(1, -12, 0, 0)
    cursor.BackgroundTransparency = 1
    cursor.Text = "_"
    cursor.TextColor3 = Color3.fromRGB(255, 180, 80)
    cursor.TextSize = math.floor(16 * scale)
    cursor.Font = Enum.Font.Code
    cursor.TextYAlignment = Enum.TextYAlignment.Center
    cursor.Parent = perfText
    
    task.spawn(function()
        while screenGui.Parent do
            task.wait(0.5)
            cursor.Text = cursor.Text == "_" and " " or "_"
        end
    end)
    
    local function updateFrameSize()
        local textBounds = perfText.TextBounds
        local textWidth = textBounds.X
        local textHeight = textBounds.Y
        
        local padding = math.floor(10 * scale)
        local newWidth = textWidth + padding
        local newHeight = textHeight + math.floor(8 * scale)
        
        dragFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        
        if savedPosition then
            dragFrame.Position = savedPosition
        else
            dragFrame.Position = UDim2.new(0.5, -newWidth / 2, 0.05, 0)
        end
        
        frame.Size = UDim2.new(1, 0, 1, 0)
        perfText.Size = UDim2.new(1, -padding, 1, 0)
        perfText.Position = UDim2.new(0, padding/2, 0, 0)
    end
    
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        scale = getScale()
        border.Thickness = math.max(1, math.floor(2 * scale))
        perfText.TextSize = math.floor(16 * scale)
        cursor.TextSize = math.floor(16 * scale)
        updateFrameSize()
    end)
    
    updateFrameSize()
    
    local fc = 0
    local lastTime = os.clock()
    
    RunService.RenderStepped:Connect(function()
        local now = os.clock()
        local delta = now - lastTime
        
        if delta >= 1 then
            local fps = math.floor(fc / delta)
            local ping = 0
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            perfText.Text = string.format("FPS:%03d PING:%03dms", fps, ping)
            updateFrameSize()
            fc = 0
            lastTime = now
        end
        fc = fc + 1
    end)
    
    return {
        textButton = perfText
    }
end

-- ==================== 废土风格菜单 ====================
local function createMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WastelandMenu"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local menuSize = 1.0
    local minSize = 0.6
    local maxSize = 1.5
    local menuFrame = nil
    local timerTextObj = nil
    local isAnimating = false
    local startTime = os.time()
    local minButton = nil
    
    local BASE_WIDTH = 380
    local BASE_HEIGHT = 580
    
    local FONT_SIZES = {
        title = 15,
        button = 18,
        userName = 18,
        timer = 14,
        itemName = 20,
        status = 17,
        unload = 19,
        unloadTip = 12,
        footer = 12,
        flicker = 14
    }
    
    local function formatTime(seconds)
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local secs = seconds % 60
        if hours > 0 then
            return string.format("%02d:%02d:%02d", hours, minutes, secs)
        else
            return string.format("%02d:%02d", minutes, secs)
        end
    end
    
    local function getUptimeString()
        local elapsed = os.time() - startTime
        return formatTime(elapsed)
    end
    
    local function getBaseScale()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        return math.min(1.3, math.max(0.7, viewportSize.Y / 1080))
    end
    
    local function getScale()
        return getBaseScale() * menuSize
    end
    
    local function ss(value)
        return math.floor(value * getScale())
    end
    
    local function getFontSize(baseSize)
        return math.floor(baseSize * getScale())
    end
    
    local uiElements = {
        titleText = nil,
        zoomText = nil,
        zoomInBtn = nil,
        zoomOutBtn = nil,
        userName = nil,
        timerLabel = nil,
        itemFrames = {},
        unloadText = nil,
        unloadTip = nil,
        footerText = nil,
        flickerText = nil
    }
    
    local function updateAllUI()
        if not menuFrame then return end
        
        local s = getScale()
        local newWidth = ss(BASE_WIDTH)
        local newHeight = ss(BASE_HEIGHT)
        
        local oldCenterX = menuFrame.AbsolutePosition.X + menuFrame.AbsoluteSize.X / 2
        local oldCenterY = menuFrame.AbsolutePosition.Y + menuFrame.AbsoluteSize.Y / 2
        
        menuFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        
        local newPosX = oldCenterX - newWidth / 2
        local newPosY = oldCenterY - newHeight / 2
        menuFrame.Position = UDim2.new(0, newPosX, 0, newPosY)
        
        local titleBar = menuFrame:FindFirstChild("TitleBar")
        if titleBar then
            titleBar.Size = UDim2.new(1, 0, 0, ss(48))
            if uiElements.titleText then
                uiElements.titleText.TextSize = getFontSize(FONT_SIZES.title)
                uiElements.titleText.Size = UDim2.new(0.5, -ss(12), 1, 0)
                uiElements.titleText.Position = UDim2.new(0, ss(12), 0, 0)
            end
            
            local buttonContainer = titleBar:FindFirstChild("ButtonContainer")
            if buttonContainer then
                buttonContainer.Size = UDim2.new(0, ss(140), 1, 0)
                buttonContainer.Position = UDim2.new(1, -ss(150), 0, 0)
                
                if uiElements.zoomText then
                    uiElements.zoomText.Size = UDim2.new(0, ss(55), 1, 0)
                    uiElements.zoomText.Position = UDim2.new(1, -ss(108), 0, 0)
                    uiElements.zoomText.TextSize = getFontSize(14)
                end
                if uiElements.zoomInBtn then
                    uiElements.zoomInBtn.Size = UDim2.new(0, ss(38), 1, 0)
                    uiElements.zoomInBtn.Position = UDim2.new(1, -ss(156), 0, 0)
                    uiElements.zoomInBtn.TextSize = getFontSize(FONT_SIZES.button)
                end
                if uiElements.zoomOutBtn then
                    uiElements.zoomOutBtn.Size = UDim2.new(0, ss(38), 1, 0)
                    uiElements.zoomOutBtn.Position = UDim2.new(1, -ss(204), 0, 0)
                    uiElements.zoomOutBtn.TextSize = getFontSize(FONT_SIZES.button)
                end
            end
        end
        
        local userFrame = menuFrame:FindFirstChild("UserFrame")
        if userFrame then
            userFrame.Size = UDim2.new(1, -ss(20), 0, ss(64))
            userFrame.Position = UDim2.new(0, ss(10), 0, ss(56))
            if uiElements.userName then
                uiElements.userName.TextSize = getFontSize(FONT_SIZES.userName)
                uiElements.userName.Size = UDim2.new(1, -ss(10), 0, ss(28))
                uiElements.userName.Position = UDim2.new(0, ss(8), 0, ss(6))
            end
            if uiElements.timerLabel then
                uiElements.timerLabel.TextSize = getFontSize(FONT_SIZES.timer)
                uiElements.timerLabel.Size = UDim2.new(1, -ss(10), 0, ss(26))
                uiElements.timerLabel.Position = UDim2.new(0, ss(8), 0, ss(34))
            end
        end
        
        local scrollFrame = menuFrame:FindFirstChild("ScrollFrame")
        if scrollFrame then
            scrollFrame.Size = UDim2.new(1, -ss(20), 0, ss(350))
            scrollFrame.Position = UDim2.new(0, ss(10), 0, ss(128))
            scrollFrame.ScrollBarThickness = ss(4)
            
            for i, itemFrame in ipairs(uiElements.itemFrames) do
                if itemFrame then
                    itemFrame.Size = UDim2.new(1, 0, 0, ss(64))
                    itemFrame.Position = UDim2.new(0, 0, 0, (i - 1) * ss(68))
                    
                    local nl = itemFrame:FindFirstChild("ItemName")
                    if nl then
                        nl.TextSize = getFontSize(FONT_SIZES.itemName)
                        nl.Size = UDim2.new(0.65, -ss(10), 1, 0)
                        nl.Position = UDim2.new(0, ss(12), 0, 0)
                    end
                    
                    local status = itemFrame:FindFirstChild("StatusIndicator")
                    if status then
                        status.TextSize = getFontSize(FONT_SIZES.status)
                        status.Size = UDim2.new(0, ss(80), 1, 0)
                        status.Position = UDim2.new(1, -ss(90), 0, 0)
                    end
                end
            end
        end
        
        local unloadFrame = menuFrame:FindFirstChild("UnloadFrame")
        if unloadFrame then
            unloadFrame.Size = UDim2.new(1, -ss(20), 0, ss(64))
            unloadFrame.Position = UDim2.new(0, ss(10), 0, ss(460))
            if uiElements.unloadText then
                uiElements.unloadText.TextSize = getFontSize(FONT_SIZES.unload)
                uiElements.unloadText.Size = UDim2.new(1, -ss(15), 0, ss(32))
                uiElements.unloadText.Position = UDim2.new(0, ss(12), 0, ss(10))
            end
            if uiElements.unloadTip then
                uiElements.unloadTip.TextSize = getFontSize(FONT_SIZES.unloadTip)
                uiElements.unloadTip.Size = UDim2.new(1, -ss(15), 0, ss(22))
                uiElements.unloadTip.Position = UDim2.new(0, ss(12), 1, -ss(20))
            end
        end
        
        local footer = menuFrame:FindFirstChild("Footer")
        if footer then
            footer.Size = UDim2.new(1, -ss(20), 0, ss(32))
            footer.Position = UDim2.new(0, ss(10), 1, -ss(36))
            if uiElements.footerText then
                uiElements.footerText.TextSize = getFontSize(FONT_SIZES.footer)
                uiElements.footerText.Size = UDim2.new(1, -ss(10), 1, 0)
                uiElements.footerText.Position = UDim2.new(0, ss(5), 0, 0)
            end
        end
        
        if uiElements.flickerText then
            uiElements.flickerText.TextSize = getFontSize(FONT_SIZES.flicker)
            uiElements.flickerText.Size = UDim2.new(0, ss(30), 0, ss(22))
            uiElements.flickerText.Position = UDim2.new(0.5, ss(20), 0, ss(10))
        end
    end
    
    local function showMenu()
        if not menuFrame then return end
        if isAnimating then return end
        
        menuFrame.Visible = true
        isAnimating = true
        
        local targetSize = menuFrame.Size
        local targetPosition = menuFrame.Position
        local targetTransparency = menuFrame.BackgroundTransparency
        
        menuFrame.Size = UDim2.new(targetSize.X.Scale, targetSize.X.Offset * 0.7, targetSize.Y.Scale, targetSize.Y.Offset * 0.7)
        menuFrame.Position = targetPosition
        menuFrame.BackgroundTransparency = 0.5
        
        local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local sizeTween = TweenService:Create(menuFrame, tweenInfo, {Size = targetSize})
        local transTween = TweenService:Create(menuFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = targetTransparency})
        
        sizeTween:Play()
        transTween:Play()
        
        sizeTween.Completed:Connect(function()
            isAnimating = false
        end)
    end
    
    local function hideMenu()
        if not menuFrame then return end
        if isAnimating then return end
        if not menuFrame.Visible then return end
        
        isAnimating = true
        
        local targetSize = menuFrame.Size
        local targetPosition = menuFrame.Position
        
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        local sizeTween = TweenService:Create(menuFrame, tweenInfo, {Size = UDim2.new(targetSize.X.Scale, targetSize.X.Offset * 0.7, targetSize.Y.Scale, targetSize.Y.Offset * 0.7)})
        local transTween = TweenService:Create(menuFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5})
        
        sizeTween:Play()
        transTween:Play()
        
        sizeTween.Completed:Connect(function()
            menuFrame.Visible = false
            menuFrame.Size = targetSize
            menuFrame.Position = targetPosition
            menuFrame.BackgroundTransparency = 0.05
            isAnimating = false
        end)
    end
    
    local function zoomMenu(delta)
        local newSize = menuSize + delta
        if newSize >= minSize and newSize <= maxSize then
            menuSize = newSize
            updateAllUI()
            if uiElements.zoomText then
                uiElements.zoomText.Text = string.format("%.0f%%", menuSize * 100)
            end
        end
    end
    
    local function buildMenu()
        local s = getScale()
        
        local mf = Instance.new("Frame")
        mf.Size = UDim2.new(0, ss(BASE_WIDTH), 0, ss(BASE_HEIGHT))
        mf.Position = UDim2.new(0.5, -ss(BASE_WIDTH) / 2, 0.5, -ss(BASE_HEIGHT) / 2)
        mf.BackgroundColor3 = Color3.fromRGB(15, 12, 8)
        mf.BackgroundTransparency = 0.05
        mf.Active = true
        mf.Draggable = true
        mf.Visible = false
        mf.Parent = screenGui
        
        local mainBorder = Instance.new("UIStroke")
        mainBorder.Thickness = 3
        mainBorder.Color = Color3.fromRGB(180, 100, 40)
        mainBorder.Transparency = 0.2
        mainBorder.Parent = mf
        
        local scanline = Instance.new("Frame")
        scanline.Name = "Scanline"
        scanline.Size = UDim2.new(1, 0, 0, 2)
        scanline.Position = UDim2.new(0, 0, 0, 0)
        scanline.BackgroundColor3 = Color3.fromRGB(255, 180, 80)
        scanline.BackgroundTransparency = 0.7
        scanline.BorderSizePixel = 0
        scanline.Parent = mf
        
        task.spawn(function()
            local y = 0
            while mf and mf.Parent do
                task.wait(0.03)
                y = y + ss(4)
                if y > ss(BASE_HEIGHT) then y = 0 end
                if scanline then scanline.Position = UDim2.new(0, 0, 0, y) end
            end
        end)
        
        local function addWastelandCorner(parent, x, y)
            local cornerGroup = Instance.new("Frame")
            cornerGroup.Size = UDim2.new(0, ss(20), 0, ss(20))
            cornerGroup.Position = UDim2.new(x, x == 0 and 0 or -ss(20), y, y == 0 and 0 or -ss(20))
            cornerGroup.BackgroundTransparency = 1
            cornerGroup.Parent = parent
            
            local line1 = Instance.new("Frame")
            line1.Size = UDim2.new(0, ss(15), 0, 2)
            line1.Position = UDim2.new(0, x == 0 and 0 or -ss(15), 0, y == 0 and 0 or ss(18))
            line1.BackgroundColor3 = Color3.fromRGB(180, 100, 40)
            line1.BackgroundTransparency = 0.4
            line1.BorderSizePixel = 0
            line1.Parent = cornerGroup
            
            local line2 = Instance.new("Frame")
            line2.Size = UDim2.new(0, 2, 0, ss(15))
            line2.Position = UDim2.new(0, x == 0 and ss(18) or -ss(20), 0, y == 0 and 0 or -ss(15))
            line2.BackgroundColor3 = Color3.fromRGB(180, 100, 40)
            line2.BackgroundTransparency = 0.4
            line2.BorderSizePixel = 0
            line2.Parent = cornerGroup
        end
        
        addWastelandCorner(mf, 0, 0)
        addWastelandCorner(mf, 1, 0)
        addWastelandCorner(mf, 0, 1)
        addWastelandCorner(mf, 1, 1)
        
        local titleBar = Instance.new("Frame")
        titleBar.Name = "TitleBar"
        titleBar.Size = UDim2.new(1, 0, 0, ss(48))
        titleBar.BackgroundColor3 = Color3.fromRGB(25, 18, 12)
        titleBar.BackgroundTransparency = 0.2
        titleBar.BorderSizePixel = 0
        titleBar.Parent = mf
        
        uiElements.titleText = Instance.new("TextLabel")
        uiElements.titleText.Text = "Reming祝大家天天开心❤️"
        uiElements.titleText.TextColor3 = Color3.fromRGB(255, 180, 80)
        uiElements.titleText.TextSize = getFontSize(FONT_SIZES.title)
        uiElements.titleText.Font = Enum.Font.Code
        uiElements.titleText.TextXAlignment = Enum.TextXAlignment.Left
        uiElements.titleText.TextYAlignment = Enum.TextYAlignment.Center
        uiElements.titleText.BackgroundTransparency = 1
        uiElements.titleText.Size = UDim2.new(0.5, -ss(12), 1, 0)
        uiElements.titleText.Position = UDim2.new(0, ss(12), 0, 0)
        uiElements.titleText.Parent = titleBar
        
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Name = "ButtonContainer"
        buttonContainer.Size = UDim2.new(0, ss(140), 1, 0)
        buttonContainer.Position = UDim2.new(1, -ss(150), 0, 0)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = titleBar
        
        minButton = Instance.new("TextButton")
        minButton.Size = UDim2.new(0, ss(38), 1, 0)
        minButton.Position = UDim2.new(1, -ss(38), 0, 0)
        minButton.BackgroundTransparency = 1
        minButton.Text = "[-]"
        minButton.TextColor3 = Color3.fromRGB(255, 180, 80)
        minButton.TextSize = getFontSize(FONT_SIZES.button)
        minButton.Font = Enum.Font.Code
        minButton.Parent = buttonContainer
        
        uiElements.zoomText = Instance.new("TextLabel")
        uiElements.zoomText.Name = "ZoomText"
        uiElements.zoomText.Size = UDim2.new(0, ss(55), 1, 0)
        uiElements.zoomText.Position = UDim2.new(1, -ss(108), 0, 0)
        uiElements.zoomText.BackgroundTransparency = 1
        uiElements.zoomText.Text = string.format("%.0f%%", menuSize * 100)
        uiElements.zoomText.TextColor3 = Color3.fromRGB(200, 150, 80)
        uiElements.zoomText.TextSize = getFontSize(14)
        uiElements.zoomText.Font = Enum.Font.Code
        uiElements.zoomText.TextXAlignment = Enum.TextXAlignment.Center
        uiElements.zoomText.TextYAlignment = Enum.TextYAlignment.Center
        uiElements.zoomText.Parent = buttonContainer
        
        uiElements.zoomInBtn = Instance.new("TextButton")
        uiElements.zoomInBtn.Size = UDim2.new(0, ss(38), 1, 0)
        uiElements.zoomInBtn.Position = UDim2.new(1, -ss(156), 0, 0)
        uiElements.zoomInBtn.BackgroundTransparency = 1
        uiElements.zoomInBtn.Text = "[+]"
        uiElements.zoomInBtn.TextColor3 = Color3.fromRGB(255, 180, 80)
        uiElements.zoomInBtn.TextSize = getFontSize(FONT_SIZES.button)
        uiElements.zoomInBtn.Font = Enum.Font.Code
        uiElements.zoomInBtn.Parent = buttonContainer
        
        uiElements.zoomOutBtn = Instance.new("TextButton")
        uiElements.zoomOutBtn.Size = UDim2.new(0, ss(38), 1, 0)
        uiElements.zoomOutBtn.Position = UDim2.new(1, -ss(204), 0, 0)
        uiElements.zoomOutBtn.BackgroundTransparency = 1
        uiElements.zoomOutBtn.Text = "[-]"
        uiElements.zoomOutBtn.TextColor3 = Color3.fromRGB(255, 180, 80)
        uiElements.zoomOutBtn.TextSize = getFontSize(FONT_SIZES.button)
        uiElements.zoomOutBtn.Font = Enum.Font.Code
        uiElements.zoomOutBtn.Parent = buttonContainer
        
        local userFrame = Instance.new("Frame")
        userFrame.Name = "UserFrame"
        userFrame.Size = UDim2.new(1, -ss(20), 0, ss(64))
        userFrame.Position = UDim2.new(0, ss(10), 0, ss(56))
        userFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 10)
        userFrame.BackgroundTransparency = 0.3
        userFrame.BorderSizePixel = 0
        userFrame.Parent = mf
        
        local function addRivet(parent, x, y)
            local rivet = Instance.new("Frame")
            rivet.Size = UDim2.new(0, ss(8), 0, ss(8))
            rivet.Position = UDim2.new(x, x == 0 and ss(5) or -ss(13), y, y == 0 and ss(5) or -ss(13))
            rivet.BackgroundColor3 = Color3.fromRGB(100, 60, 30)
            rivet.BorderSizePixel = 0
            local rivetCorner = Instance.new("UICorner")
            rivetCorner.CornerRadius = UDim.new(1, 0)
            rivetCorner.Parent = rivet
            rivet.Parent = parent
        end
        
        addRivet(userFrame, 0, 0)
        addRivet(userFrame, 1, 0)
        addRivet(userFrame, 0, 1)
        addRivet(userFrame, 1, 1)
        
        uiElements.userName = Instance.new("TextLabel")
        uiElements.userName.Text = "> 操作员: " .. player.Name
        uiElements.userName.TextColor3 = Color3.fromRGB(220, 170, 100)
        uiElements.userName.TextSize = getFontSize(FONT_SIZES.userName)
        uiElements.userName.Font = Enum.Font.Code
        uiElements.userName.TextXAlignment = Enum.TextXAlignment.Left
        uiElements.userName.TextYAlignment = Enum.TextYAlignment.Center
        uiElements.userName.BackgroundTransparency = 1
        uiElements.userName.Size = UDim2.new(1, -ss(10), 0, ss(28))
        uiElements.userName.Position = UDim2.new(0, ss(8), 0, ss(6))
        uiElements.userName.Parent = userFrame
        
        uiElements.timerLabel = Instance.new("TextLabel")
        uiElements.timerLabel.Text = "[系统运行: " .. getUptimeString() .. "]"
        uiElements.timerLabel.TextColor3 = Color3.fromRGB(180, 140, 80)
        uiElements.timerLabel.TextSize = getFontSize(FONT_SIZES.timer)
        uiElements.timerLabel.Font = Enum.Font.Code
        uiElements.timerLabel.TextXAlignment = Enum.TextXAlignment.Left
        uiElements.timerLabel.TextYAlignment = Enum.TextYAlignment.Center
        uiElements.timerLabel.BackgroundTransparency = 1
        uiElements.timerLabel.Size = UDim2.new(1, -ss(10), 0, ss(26))
        uiElements.timerLabel.Position = UDim2.new(0, ss(8), 0, ss(34))
        uiElements.timerLabel.Parent = userFrame
        timerTextObj = uiElements.timerLabel
        
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = "ScrollFrame"
        scrollFrame.Size = UDim2.new(1, -ss(20), 0, ss(350))
        scrollFrame.Position = UDim2.new(0, ss(10), 0, ss(128))
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = ss(4)
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 100, 40)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, ss(440))
        scrollFrame.Parent = mf
        
        local items = {
            {name = "R6断腿", key = "R6Leg", offColor = Color3.fromRGB(25, 18, 12), onColor = Color3.fromRGB(60, 40, 20)},
            {name = "R15断腿", key = "R15Leg", offColor = Color3.fromRGB(25, 18, 12), onColor = Color3.fromRGB(55, 35, 18)},
            {name = "画质优化", key = "Graphics", offColor = Color3.fromRGB(25, 18, 12), onColor = Color3.fromRGB(55, 35, 18)},
            {name = "隐藏饰品", key = "Hat", offColor = Color3.fromRGB(25, 18, 12), onColor = Color3.fromRGB(55, 35, 18)},
        }
        
        for i, item in ipairs(items) do
            local itemFrame = Instance.new("TextButton")
            itemFrame.Size = UDim2.new(1, 0, 0, ss(64))
            itemFrame.Position = UDim2.new(0, 0, 0, (i - 1) * ss(68))
            itemFrame.BackgroundColor3 = item.offColor
            itemFrame.BackgroundTransparency = 0
            itemFrame.BorderSizePixel = 0
            itemFrame.Text = ""
            itemFrame.AutoButtonColor = false
            itemFrame.Parent = scrollFrame
            table.insert(uiElements.itemFrames, itemFrame)
            
            local itBorder = Instance.new("UIStroke")
            itBorder.Thickness = 1
            itBorder.Color = Color3.fromRGB(180, 100, 40)
            itBorder.Transparency = 0.5
            itBorder.Parent = itemFrame
            
            local nl = Instance.new("TextLabel")
            nl.Name = "ItemName"
            nl.Text = item.name
            nl.TextColor3 = Color3.fromRGB(200, 150, 90)
            nl.TextSize = getFontSize(FONT_SIZES.itemName)
            nl.Font = Enum.Font.Code
            nl.TextXAlignment = Enum.TextXAlignment.Left
            nl.BackgroundTransparency = 1
            nl.Size = UDim2.new(0.65, -ss(10), 1, 0)
            nl.Position = UDim2.new(0, ss(12), 0, 0)
            nl.Parent = itemFrame
            
            local statusIndicator = Instance.new("TextLabel")
            statusIndicator.Name = "StatusIndicator"
            statusIndicator.Text = "[关闭]"
            statusIndicator.TextSize = getFontSize(FONT_SIZES.status)
            statusIndicator.Font = Enum.Font.Code
            statusIndicator.TextColor3 = Color3.fromRGB(150, 80, 50)
            statusIndicator.BackgroundTransparency = 1
            statusIndicator.Size = UDim2.new(0, ss(80), 1, 0)
            statusIndicator.Position = UDim2.new(1, -ss(90), 0, 0)
            statusIndicator.TextXAlignment = Enum.TextXAlignment.Right
            statusIndicator.TextYAlignment = Enum.TextYAlignment.Center
            statusIndicator.Parent = itemFrame
            
            local isOn = false
            
            itemFrame.MouseButton1Click:Connect(function()
                isOn = not isOn
                if isOn then
                    itemFrame.BackgroundColor3 = item.onColor
                    nl.TextColor3 = Color3.fromRGB(255, 200, 120)
                    statusIndicator.Text = "[开启]"
                    statusIndicator.TextColor3 = Color3.fromRGB(255, 180, 80)
                    State[item.key] = true
                else
                    itemFrame.BackgroundColor3 = item.offColor
                    nl.TextColor3 = Color3.fromRGB(200, 150, 90)
                    statusIndicator.Text = "[关闭]"
                    statusIndicator.TextColor3 = Color3.fromRGB(150, 80, 50)
                    State[item.key] = false
                end
                
                if item.key == "R6Leg" then
                    LegEffects.enableR6(isOn)
                elseif item.key == "R15Leg" then
                    LegEffects.enableR15(isOn)
                elseif item.key == "Graphics" then
                    Graphics.enable(isOn)
                elseif item.key == "Hat" then
                    HatHider.enable(isOn)
                end
            end)
            
            itemFrame.MouseEnter:Connect(function()
                if not isOn then itemFrame.BackgroundColor3 = Color3.fromRGB(40, 28, 18) end
            end)
            
            itemFrame.MouseLeave:Connect(function()
                if not isOn then itemFrame.BackgroundColor3 = item.offColor end
            end)
        end
        
        local unloadFrame = Instance.new("Frame")
        unloadFrame.Name = "UnloadFrame"
        unloadFrame.Size = UDim2.new(1, -ss(20), 0, ss(64))
        unloadFrame.Position = UDim2.new(0, ss(10), 0, ss(460))
        unloadFrame.BackgroundColor3 = Color3.fromRGB(45, 20, 15)
        unloadFrame.BackgroundTransparency = 0
        unloadFrame.BorderSizePixel = 0
        unloadFrame.Parent = scrollFrame
        
        local unloadBorder = Instance.new("UIStroke")
        unloadBorder.Thickness = 1
        unloadBorder.Color = Color3.fromRGB(200, 80, 40)
        unloadBorder.Transparency = 0.3
        unloadBorder.Parent = unloadFrame
        
        uiElements.unloadText = Instance.new("TextLabel")
        uiElements.unloadText.Text = "> 卸载脚本"
        uiElements.unloadText.TextColor3 = Color3.fromRGB(255, 120, 60)
        uiElements.unloadText.TextSize = getFontSize(FONT_SIZES.unload)
        uiElements.unloadText.Font = Enum.Font.Code
        uiElements.unloadText.TextXAlignment = Enum.TextXAlignment.Left
        uiElements.unloadText.TextYAlignment = Enum.TextYAlignment.Center
        uiElements.unloadText.BackgroundTransparency = 1
        uiElements.unloadText.Size = UDim2.new(1, -ss(15), 0, ss(32))
        uiElements.unloadText.Position = UDim2.new(0, ss(12), 0, ss(10))
        uiElements.unloadText.Parent = unloadFrame
        
        uiElements.unloadTip = Instance.new("TextLabel")
        uiElements.unloadTip.Text = "关闭所有功能并删除脚本"
        uiElements.unloadTip.TextColor3 = Color3.fromRGB(150, 70, 40)
        uiElements.unloadTip.TextSize = getFontSize(FONT_SIZES.unloadTip)
        uiElements.unloadTip.Font = Enum.Font.Code
        uiElements.unloadTip.TextXAlignment = Enum.TextXAlignment.Left
        uiElements.unloadTip.TextYAlignment = Enum.TextYAlignment.Center
        uiElements.unloadTip.BackgroundTransparency = 1
        uiElements.unloadTip.Size = UDim2.new(1, -ss(15), 0, ss(22))
        uiElements.unloadTip.Position = UDim2.new(0, ss(12), 1, -ss(20))
        uiElements.unloadTip.Parent = unloadFrame
        
        local unloadButton = Instance.new("TextButton")
        unloadButton.Size = UDim2.new(1, 0, 1, 0)
        unloadButton.BackgroundTransparency = 1
        unloadButton.Text = ""
        unloadButton.Parent = unloadFrame
        
        unloadButton.MouseButton1Click:Connect(function()
            -- 关闭所有功能
            if State.R6Leg then LegEffects.enableR6(false) end
            if State.R15Leg then LegEffects.enableR15(false) end
            if State.Graphics then Graphics.enable(false) end
            if State.Hat then HatHider.enable(false) end
            
            -- 恢复角色
            local c = player.Character
            if c then
                local head = c:FindFirstChild("Head")
                if head then head.Transparency = 0; head.CanCollide = true end
                local legParts = {"RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Right Leg", "Left Leg"}
                for _, partName in ipairs(legParts) do
                    local part = c:FindFirstChild(partName)
                    if part then part.Transparency = 0; part.Material = Enum.Material.SmoothPlastic end
                end
            end
            
            -- 删除GUI
            screenGui:Destroy()
            local perfParent = player.PlayerGui:FindFirstChild("WastelandPerfMonitor")
            if perfParent then perfParent:Destroy() end 
        
        unloadFrame.MouseEnter:Connect(function() unloadFrame.BackgroundColor3 = Color3.fromRGB(80, 35, 25) end)
        unloadFrame.MouseLeave:Connect(function() unloadFrame.BackgroundColor3 = Color3.fromRGB(45, 20, 15) end)
        
        local footer = Instance.new("Frame")
        footer.Name = "Footer"
        footer.Size = UDim2.new(1, -ss(20), 0, ss(32))
        footer.Position = UDim2.new(0, ss(10), 1, -ss(36))
        footer.BackgroundColor3 = Color3.fromRGB(20, 15, 10)
        footer.BackgroundTransparency = 0.3
        footer.BorderSizePixel = 0
        footer.Parent = mf
        
        uiElements.footerText = Instance.new("TextLabel")
        uiElements.footerText.Text = "> Reming V2.1<"
        uiElements.footerText.TextColor3 = Color3.fromRGB(150, 100, 60)
        uiElements.footerText.TextSize = getFontSize(FONT_SIZES.footer)
        uiElements.footerText.Font = Enum.Font.Code
        uiElements.footerText.TextXAlignment = Enum.TextXAlignment.Center
        uiElements.footerText.TextYAlignment = Enum.TextYAlignment.Center
        uiElements.footerText.BackgroundTransparency = 1
        uiElements.footerText.Size = UDim2.new(1, -ss(10), 1, 0)
        uiElements.footerText.Position = UDim2.new(0, ss(5), 0, 0)
        uiElements.footerText.Parent = footer
        
        local flickerChars = {"█", "▒", "░", " "}
        uiElements.flickerText = Instance.new("TextLabel")
        uiElements.flickerText.Size = UDim2.new(0, ss(30), 0, ss(22))
        uiElements.flickerText.Position = UDim2.new(0.5, ss(20), 0, ss(10))
        uiElements.flickerText.BackgroundTransparency = 1
        uiElements.flickerText.Text = "▒"
        uiElements.flickerText.TextColor3 = Color3.fromRGB(180, 100, 40)
        uiElements.flickerText.TextSize = getFontSize(FONT_SIZES.flicker)
        uiElements.flickerText.Font = Enum.Font.Code
        uiElements.flickerText.Parent = mf
        
        task.spawn(function()
            while mf and mf.Parent do
                task.wait(0.2)
                if uiElements.flickerText and uiElements.flickerText.Parent then
                    uiElements.flickerText.Text = flickerChars[math.random(1, #flickerChars)]
                end
            end
        end)
        
        uiElements.zoomInBtn.MouseButton1Click:Connect(function()
            zoomMenu(0.1)
        end)
        
        uiElements.zoomOutBtn.MouseButton1Click:Connect(function()
            zoomMenu(-0.1)
        end)
        
        task.spawn(function()
            while mf and mf.Parent do
                task.wait(1)
                if timerTextObj and timerTextObj.Parent then
                    timerTextObj.Text = "[系统运行: " .. getUptimeString() .. "]"
                end
            end
        end)
        
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            updateAllUI()
        end)
        
        return mf
    end
    
    menuFrame = buildMenu()
    
    return {
        show = showMenu,
        hide = hideMenu,
        isVisible = function() return menuFrame and menuFrame.Visible end,
        setMinButtonCallback = function(callback)
            if minButton then
                minButton.MouseButton1Click:Connect(callback)
            end
        end
    }
end

-- ==================== 公告弹窗模块 ====================
local function showAnnouncement(title, content, contentPosition, duration, onConfirm)
    duration = duration or 6
    contentPosition = contentPosition or "center"
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnnouncementGui"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local function getScale()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local referenceHeight = 1080
        return math.min(1.3, math.max(0.7, viewportSize.Y / referenceHeight))
    end
    
    local scale = getScale()
    
    local function ss(value)
        return math.floor(value * scale)
    end
    
    -- 深色悲伤遮罩层
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.Parent = screenGui
    
    -- 弹窗框架
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, ss(520), 0, ss(440))
    frame.Position = UDim2.new(0.5, -ss(260), 0.5, -ss(220))
    frame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame
    
    local border = Instance.new("UIStroke")
    border.Thickness = 2
    border.Color = Color3.fromRGB(70, 90, 120)
    border.Transparency = 0.3
    border.Parent = frame
    
    -- 公告栏内下雨效果
    local rainContainer = Instance.new("Frame")
    rainContainer.Size = UDim2.new(1, 0, 1, 0)
    rainContainer.BackgroundTransparency = 1
    rainContainer.ClipsDescendants = true
    rainContainer.Parent = frame
    
    local rainDrops = {}
    local rainCount = 70
    
    for i = 1, rainCount do
        local drop = Instance.new("Frame")
        drop.Size = UDim2.new(0, 2, 0, math.random(10, 18))
        drop.Position = UDim2.new(math.random() * 1, 0, math.random() * 1, 0)
        drop.BackgroundColor3 = Color3.fromRGB(100, 130, 180)
        drop.BackgroundTransparency = 0.5
        drop.BorderSizePixel = 0
        drop.Parent = rainContainer
        
        local speed = math.random(50, 90)
        
        table.insert(rainDrops, {
            frame = drop,
            speed = speed
        })
    end
    
    local rainConnection
    rainConnection = RunService.Heartbeat:Connect(function(dt)
        for _, drop in ipairs(rainDrops) do
            local newY = drop.frame.Position.Y.Scale + (drop.speed * dt) / 100
            if newY > 1 then
                newY = -0.1
                drop.frame.Position = UDim2.new(math.random() * 1, 0, newY, 0)
            else
                drop.frame.Position = UDim2.new(drop.frame.Position.X.Scale, 0, newY, 0)
            end
        end
    end)
    
    -- 模糊雾气效果
    local fog = Instance.new("Frame")
    fog.Size = UDim2.new(1, 0, 1, 0)
    fog.BackgroundColor3 = Color3.fromRGB(80, 100, 130)
    fog.BackgroundTransparency = 0.85
    fog.BorderSizePixel = 0
    fog.Parent = frame
    
    -- 标题
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -ss(20), 0, ss(55))
    titleLabel.Position = UDim2.new(0, ss(10), 0, ss(10))
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or " "
    titleLabel.TextColor3 = Color3.fromRGB(160, 190, 220)
    titleLabel.TextSize = ss(24)
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = frame
    titleLabel.ZIndex = 2
    
    -- 分割线
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -ss(20), 0, 1)
    divider.Position = UDim2.new(0, ss(10), 0, ss(65))
    divider.BackgroundColor3 = Color3.fromRGB(70, 90, 120)
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = frame
    divider.ZIndex = 2
    
    -- 内容
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -ss(40), 0, ss(190))
    contentLabel.Position = UDim2.new(0, ss(20), 0, ss(80))
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content or "欢迎使用脚本\n\n请仔细阅读使用说明"
    contentLabel.TextColor3 = Color3.fromRGB(180, 190, 210)
    contentLabel.TextSize = ss(16)
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.LineHeight = 1.5
    contentLabel.Parent = frame
    contentLabel.ZIndex = 2
    
    if contentPosition == "center" then
        contentLabel.TextXAlignment = Enum.TextXAlignment.Center
        contentLabel.TextYAlignment = Enum.TextYAlignment.Center
    elseif contentPosition == "left" then
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    elseif contentPosition == "right" then
        contentLabel.TextXAlignment = Enum.TextXAlignment.Right
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    end
    
    -- 进度条背景
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0, ss(280), 0, ss(8))
    progressBg.Position = UDim2.new(0.5, -ss(140), 0, ss(295))
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = frame
    progressBg.ZIndex = 2
    
    local progressBgCorner = Instance.new("UICorner")
    progressBgCorner.CornerRadius = UDim.new(1, 0)
    progressBgCorner.Parent = progressBg
    
    -- 进度条
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    
    local progressBarCorner = Instance.new("UICorner")
    progressBarCorner.CornerRadius = UDim.new(1, 0)
    progressBarCorner.Parent = progressBar
    
    -- 倒计时文字
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, 0, 0, ss(30))
    timerLabel.Position = UDim2.new(0, 0, 0, ss(315))
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "等待 " .. duration .. " 秒"
    timerLabel.TextColor3 = Color3.fromRGB(130, 150, 180)
    timerLabel.TextSize = ss(14)
    timerLabel.Font = Enum.Font.Gotham
    timerLabel.TextXAlignment = Enum.TextXAlignment.Center
    timerLabel.Parent = frame
    timerLabel.ZIndex = 2
    
    -- 悲伤小图标
    local tearIcon = Instance.new("TextLabel")
    tearIcon.Size = UDim2.new(0, ss(30), 0, ss(30))
    tearIcon.Position = UDim2.new(0.5, -ss(15), 0, ss(355))
    tearIcon.BackgroundTransparency = 1
    tearIcon.Text = "💧"
    tearIcon.TextColor3 = Color3.fromRGB(100, 150, 200)
    tearIcon.TextSize = ss(20)
    tearIcon.Font = Enum.Font.Gotham
    tearIcon.TextXAlignment = Enum.TextXAlignment.Center
    tearIcon.Parent = frame
    tearIcon.ZIndex = 2
    
    -- 确认按钮
    local confirmButton = Instance.new("TextButton")
    confirmButton.Size = UDim2.new(0, ss(140), 0, ss(45))
    confirmButton.Position = UDim2.new(0.5, -ss(70), 0, ss(360))
    confirmButton.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
    confirmButton.BackgroundTransparency = 0
    confirmButton.Text = "确认"
    confirmButton.TextColor3 = Color3.fromRGB(150, 170, 200)
    confirmButton.TextSize = ss(18)
    confirmButton.Font = Enum.Font.Gotham
    confirmButton.AutoButtonColor = false
    confirmButton.Parent = frame
    confirmButton.ZIndex = 2
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = confirmButton
    
    local btnBorder = Instance.new("UIStroke")
    btnBorder.Thickness = 1
    btnBorder.Color = Color3.fromRGB(100, 120, 150)
    btnBorder.Transparency = 0.5
    btnBorder.Parent = confirmButton
    
    -- 倒计时逻辑
    local startTime = os.time()
    
    timerLabel.Text = "等待 " .. duration .. " 秒"
    
    local function updateProgress()
        local elapsed = os.time() - startTime
        local percent = math.min(1, elapsed / duration)
        local width = ss(280) * percent
        progressBar:TweenSize(UDim2.new(0, width, 1, 0), "Out", "Linear", 0.1)
    end
    
    updateProgress()
    
    local timerConnection
    timerConnection = RunService.Heartbeat:Connect(function()
        local elapsed = os.time() - startTime
        local remainingTime = duration - elapsed
        
        if remainingTime <= 0 then
            if timerConnection then timerConnection:Disconnect() end
            timerLabel.Text = "💧 可以确认了"
            timerLabel.TextColor3 = Color3.fromRGB(150, 200, 230)
            confirmButton.BackgroundColor3 = Color3.fromRGB(80, 100, 130)
            confirmButton.TextColor3 = Color3.fromRGB(200, 220, 250)
            progressBar.BackgroundColor3 = Color3.fromRGB(150, 200, 230)
            tearIcon.Text = "✓"
            tearIcon.TextColor3 = Color3.fromRGB(150, 200, 230)
        else
            local displayTime = math.ceil(remainingTime)
            timerLabel.Text = "等待 " .. displayTime .. " 秒"
            updateProgress()
        end
    end)
    
    -- 悬停效果
    confirmButton.MouseEnter:Connect(function()
        if os.time() - startTime >= duration then
            confirmButton.BackgroundColor3 = Color3.fromRGB(100, 120, 150)
            confirmButton.TextColor3 = Color3.fromRGB(220, 240, 255)
        end
    end)
    
    confirmButton.MouseLeave:Connect(function()
        if os.time() - startTime >= duration then
            confirmButton.BackgroundColor3 = Color3.fromRGB(80, 100, 130)
            confirmButton.TextColor3 = Color3.fromRGB(200, 220, 250)
        end
    end)
    
    confirmButton.MouseButton1Click:Connect(function()
        if os.time() - startTime >= duration then
            if timerConnection then timerConnection:Disconnect() end
            if rainConnection then rainConnection:Disconnect() end
            screenGui:Destroy()
            if onConfirm then onConfirm() end
        end
    end)
end

-- ==================== 启动 ====================
-- 开启无头效果
Headless.enable(true)

-- 初始化性能监控
local perf = createPerfMonitor()

-- 初始化菜单
local menu = createMenu()

-- 设置菜单最小化按钮回调
menu.setMinButtonCallback(function()
    menu.hide()
end)

-- 点击性能监控打开/关闭菜单
perf.textButton.MouseButton1Click:Connect(function()
    if menu.isVisible() then
        menu.hide()
    else
        menu.show()
    end
end)

-- 显示公告弹窗
task.spawn(function()
    showAnnouncement(
        "",
        "💧Reming是tsb最忧郁之人\n\n本次更新新加了这个公告和修改了布局\n\n下次更新添加防甩飞\n\n还有FF配置功能\n\n━━━━━━━━━━━━\n\n我太急吧忧郁了\n\n",
        "center",
        6,
        function() end
    )
end)

-- 移除脸部贴图
task.spawn(function()
    while true do
        task.wait(1)
        local c = player.Character
        if c then
            for _, obj in c:GetDescendants() do
                if obj:IsA("Decal") and obj.Name:lower():find("face") then
                    obj:Destroy()
                end
                if obj:IsA("Texture") and obj.Name:lower():find("face") then
                    obj:Destroy()
                end
            end
        end
    end
end)

-- 更新断腿效果
RunService.Heartbeat:Connect(function()
    LegEffects.update()
end)

print("✅ 废土终端已启动")
print("📊 性能监控: 16px 可拖拽")
print("🎮 菜单: 380x580 紧凑尺寸")
print("🖱️ 点击FPS面板打开/关闭菜单")
print("🌧️ 公告弹窗已显示，等待6秒后可确认")
print("🦿 断腿效果 | 🎨 画质优化 | 🎩 隐藏饰品 均已就绪")