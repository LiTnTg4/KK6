--[[
Bloxstrap 精简版 - 只保留引擎设置(1) 和 FFlag模组(2)
完全独立运行，无依赖
]]

-- 初始化
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- 配置文件
local CONFIG_FILE = "BloxstrapLite.json"
local FFLAG_FILE = "BloxstrapFFlags.json"

-- 存储配置
local settings = {
    -- 引擎设置
    FPS = 120,
    AntiAliasing = "Automatic",
    DisableShadows = false,
    DisablePostFX = false,
    DisableTerrain = false,
    ShowFPS = false,
    LightingTech = "Chosen by game",
    TextureQuality = "Automatic",
    
    -- FFlag模组
    GraySky = false,
    Desync = false,
    HitregFix = false,
    CustomFont = false,
    FontName = "Gotham",
}

-- 存储 FFlag
local fflags = {}

-- 加载配置
local function loadConfig()
    if isfile and isfile(CONFIG_FILE) then
        pcall(function()
            local data = readfile(CONFIG_FILE)
            local loaded = HttpService:JSONDecode(data)
            for k, v in pairs(loaded) do
                settings[k] = v
            end
        end)
    end
    
    if isfile and isfile(FFLAG_FILE) then
        pcall(function()
            fflags = HttpService:JSONDecode(readfile(FFLAG_FILE))
        end)
    end
end

-- 保存配置
local function saveConfig()
    if writefile then
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode(settings))
            writefile(FFLAG_FILE, HttpService:JSONEncode(fflags))
        end)
    end
end

-- 设置 FFlag
local function setFFlag(name, value)
    if not name then return end
    
    -- 保存到列表
    fflags[name] = value
    saveConfig()
    
    -- 应用 FFlag
    pcall(function()
        if setfflag then
            setfflag(name, tostring(value))
        end
    end)
    
    -- 尝试隐藏属性
    pcall(function()
        if sethiddenproperty then
            local network = game:FindService("NetworkClient")
            if network then
                sethiddenproperty(network, name, value)
            end
        end
    end)
end

-- 应用所有已保存的 FFlag
local function applyAllFFlags()
    for name, value in pairs(fflags) do
        pcall(function()
            if setfflag then
                setfflag(name, tostring(value))
            end
        end)
    end
end

-- 应用引擎设置
local function applyEngineSettings()
    -- FPS 解锁
    pcall(function()
        if settings.FPS and settings.FPS > 0 then
            setfflag("DFIntTaskSchedulerTargetFps", tostring(settings.FPS))
            setfflag("FFlagTaskSchedulerLimitTargetFpsTo2402", settings.FPS >= 70 and "true" or "false")
        end
    end)
    
    -- 显示 FPS
    pcall(function()
        setfflag("FFlagDebugDisplayFPS", settings.ShowFPS and "true" or "false")
    end)
    
    -- 阴影
    pcall(function()
        setfflag("FIntRenderShadowIntensity", settings.DisableShadows and "0" or "1")
    end)
    
    -- 后期特效
    pcall(function()
        setfflag("FFlagDisablePostFx", settings.DisablePostFX and "true" or "false")
    end)
    
    -- 地形纹理
    pcall(function()
        setfflag("FIntTerrainArraySliceSize", settings.DisableTerrain and "0" or "32")
    end)
    
    -- 抗锯齿
    if settings.AntiAliasing ~= "Automatic" then
        local msaa = settings.AntiAliasing:gsub("x", "")
        pcall(function()
            setfflag("FIntDebugForceMSAASamples", msaa)
        end)
    end
    
    -- 纹理质量
    local textureMap = {
        ["Lowest"] = {enabled = true, quality = 0, skip = 2},
        ["Low"] = {enabled = true, quality = 0, skip = 0},
        ["Medium"] = {enabled = true, quality = 1, skip = 0},
        ["High"] = {enabled = true, quality = 2, skip = 0},
        ["Highest"] = {enabled = true, quality = 3, skip = 0},
    }
    
    local tex = textureMap[settings.TextureQuality]
    if tex then
        pcall(function()
            setfflag("DFFlagTextureQualityOverrideEnabled", tostring(tex.enabled))
            setfflag("DFIntTextureQualityOverride", tostring(tex.quality))
            setfflag("FIntDebugTextureManagerSkipMips", tostring(tex.skip))
        end)
    end
    
    -- 光照技术
    local lightingMap = {
        ["Voxel"] = {voxel = true, shadow = false, future = false},
        ["Shadow Map"] = {voxel = false, shadow = true, future = false},
        ["Future"] = {voxel = false, shadow = false, future = true},
    }
    
    local light = lightingMap[settings.LightingTech]
    if light then
        pcall(function()
            setfflag("DFFlagDebugRenderForceTechnologyVoxel", tostring(light.voxel))
            setfflag("DFFlagDebugRenderForceFutureIsBrightPhase2", tostring(light.shadow))
            setfflag("DFFlagDebugRenderForceFutureIsBrightPhase3", tostring(light.future))
        end)
    end
end

-- 应用 FFlag 模组
local function applyMods()
    -- 灰色天空
    pcall(function()
        setfflag("FFlagDebugSkyGray", settings.GraySky and "true" or "false")
    end)
    
    -- Desync
    pcall(function()
        setfflag("DFIntS2PhysicsSenderRate", settings.Desync and "38000" or "15")
    end)
    
    -- Hitreg Fix
    if settings.HitregFix then
        local hitregFlags = {
            DFIntCodecMaxIncomingPackets = 100,
            DFIntCodecMaxOutgoingFrames = 10000,
            DFIntLargePacketQueueSizeCutoffMB = 1000,
            DFIntMaxProcessPacketsJobScaling = 10000,
            DFIntMaxProcessPacketsStepsAccumulated = 0,
            DFIntMaxProcessPacketsStepsPerCyclic = 5000,
            DFIntMegaReplicatorNetworkQualityProcessorUnit = 10,
            DFIntNetworkLatencyTolerance = 1,
            DFIntNetworkPrediction = 120,
            DFIntOptimizePingThreshold = 50,
            DFIntPlayerNetworkUpdateQueueSize = 20,
            DFIntPlayerNetworkUpdateRate = 60,
            DFIntRaknetBandwidthInfluxHundredthsPercentageV2 = 10000,
            DFIntRaknetBandwidthPingSendEveryXSeconds = 1,
            DFIntRakNetLoopMs = 1,
            DFIntRakNetResendRttMultiple = 1,
            DFIntServerPhysicsUpdateRate = 60,
            DFIntServerTickRate = 60,
            DFIntWaitOnRecvFromLoopEndedMS = 100,
            DFIntWaitOnUpdateNetworkLoopEndedMS = 100,
            FFlagOptimizeNetwork = true,
            FFlagOptimizeNetworkRouting = true,
            FFlagOptimizeNetworkTransport = true,
            FFlagOptimizeServerTickRate = true,
            FIntRakNetResendBufferArrayLength = 128,
        }
        for name, value in pairs(hitregFlags) do
            pcall(function()
                setfflag(name, tostring(value))
            end)
        end
    end
end

-- 加载配置
loadConfig()
applyAllFFlags()
applyEngineSettings()
applyMods()

-- 创建简单的 GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BloxstrapLite"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- 主框架
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 450)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- 标题栏
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Bloxstrap 精简版 (引擎设置 + FFlag模组)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.Gotham
title.TextSize = 13
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 18
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- 标签页按钮
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 35)
tabFrame.Position = UDim2.new(0, 10, 0, 40)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabs = {"引擎设置", "FFlag模组", "自定义FFlag"}
local currentTab = "引擎设置"
local tabButtons = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -3, 0, 30)
    btn.Position = UDim2.new((i-1) * 0.33, 2, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = tabFrame
    
    tabButtons[tabName] = btn
    
    btn.MouseButton1Click:Connect(function()
        currentTab = tabName
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        updateTab()
    end)
end

-- 内容区域
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -125)
contentFrame.Position = UDim2.new(0, 10, 0, 85)
contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
contentFrame.BorderSizePixel = 0
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.ScrollBarThickness = 4
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 5)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.Parent = contentFrame

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 5)
contentPadding.PaddingBottom = UDim.new(0, 5)
contentPadding.Parent = contentFrame

-- 创建设置项
local function createToggle(text, desc, setting, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = contentFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 25)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 25)
    toggle.Position = UDim2.new(1, -50, 0, 12.5)
    toggle.BackgroundColor3 = settings[setting] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
    toggle.Text = settings[setting] and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 11
    toggle.Parent = frame
    
    toggle.MouseButton1Click:Connect(function()
        settings[setting] = not settings[setting]
        toggle.BackgroundColor3 = settings[setting] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        toggle.Text = settings[setting] and "ON" or "OFF"
        if callback then
            callback(settings[setting])
        end
        saveConfig()
    end)
end

local function createSlider(text, desc, setting, min, max, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = contentFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 25)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(settings[setting])
    valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.8, 0, 0, 5)
    slider.Position = UDim2.new(0.1, 0, 0, 55)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((settings[setting] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    fill.Parent = slider
    
    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 15, 0, 15)
    drag.Position = UDim2.new(fill.Size.X.Scale, -7.5, 0, -5)
    drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    drag.Text = ""
    drag.Parent = slider
    
    local dragging = false
    drag.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = UDim2.new(0, Mouse.X - slider.AbsolutePosition.X, 0, 0)
            local percent = math.clamp(pos.X.Offset / slider.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            
            fill.Size = UDim2.new(percent, 0, 1, 0)
            drag.Position = UDim2.new(percent, -7.5, 0, -5)
            valueLabel.Text = tostring(value)
            settings[setting] = value
            if callback then
                callback(value)
            end
            saveConfig()
        end
    end)
end

local function createDropdown(text, desc, setting, options)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = contentFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 25)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0, 100, 0, 25)
    dropdown.Position = UDim2.new(1, -110, 0, 22.5)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdown.Text = settings[setting] or options[1]
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 11
    dropdown.Parent = frame
    
    local expanded = false
    local dropdownList
    
    dropdown.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            dropdownList = Instance.new("ScrollingFrame")
            dropdownList.Size = UDim2.new(0, 100, 0, 100)
            dropdownList.Position = UDim2.new(1, -110, 0, 47.5)
            dropdownList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            dropdownList.BorderSizePixel = 0
            dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
            dropdownList.Parent = frame
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = dropdownList
            
            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 25)
                optBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                optBtn.Text = opt
                optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 11
                optBtn.Parent = dropdownList
                
                optBtn.MouseButton1Click:Connect(function()
                    dropdown.Text = opt
                    settings[setting] = opt
                    saveConfig()
                    expanded = false
                    dropdownList:Destroy()
                end)
            end
        else
            if dropdownList then
                dropdownList:Destroy()
            end
        end
    end)
end

-- 更新标签页内容
local function updateTab()
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if currentTab == "引擎设置" then
        createSlider("FPS 限制", "设置游戏帧数上限 (0 = 无限制)", "FPS", 30, 360, function(val)
            setfflag("DFIntTaskSchedulerTargetFps", tostring(val))
            setfflag("FFlagTaskSchedulerLimitTargetFpsTo2402", val >= 70 and "true" or "false")
        end)
        
        createToggle("显示 FPS", "在屏幕角落显示帧数", "ShowFPS", function(val)
            setfflag("FFlagDebugDisplayFPS", tostring(val))
        end)
        
        createDropdown("抗锯齿", "MSAA 抗锯齿质量", "AntiAliasing", {"Automatic", "1x", "2x", "4x"})
        
        createToggle("禁用阴影", "关闭玩家阴影效果", "DisableShadows", function(val)
            setfflag("FIntRenderShadowIntensity", val and "0" or "1")
        end)
        
        createToggle("禁用后期特效", "关闭 PostFX 效果", "DisablePostFX", function(val)
            setfflag("FFlagDisablePostFx", tostring(val))
        end)
        
        createToggle("禁用地形纹理", "关闭地形纹理", "DisableTerrain", function(val)
            setfflag("FIntTerrainArraySliceSize", val and "0" or "32")
        end)
        
        createDropdown("光照技术", "强制使用特定光照", "LightingTech", {"Chosen by game", "Voxel", "Shadow Map", "Future"})
        
        createDropdown("纹理质量", "调整纹理清晰度", "TextureQuality", {"Automatic", "Lowest", "Low", "Medium", "High", "Highest"})
        
    elseif currentTab == "FFlag模组" then
        createToggle("灰色天空", "将天空变为灰色 (需重进)", "GraySky", function(val)
            setfflag("FFlagDebugSkyGray", tostring(val))
        end)
        
        createToggle("Desync", "不同步效果 (物理发送率 38000)", "Desync", function(val)
            setfflag("DFIntS2PhysicsSenderRate", val and "38000" or "15")
        end)
        
        createToggle("Hitreg Fix", "命中优化 (28个网络参数)", "HitregFix", function(val)
            if val then
                local flags = {
                    DFIntCodecMaxIncomingPackets = 100,
                    DFIntCodecMaxOutgoingFrames = 10000,
                    DFIntLargePacketQueueSizeCutoffMB = 1000,
                    DFIntMaxProcessPacketsJobScaling = 10000,
                    DFIntMaxProcessPacketsStepsAccumulated = 0,
                    DFIntMaxProcessPacketsStepsPerCyclic = 5000,
                    DFIntMegaReplicatorNetworkQualityProcessorUnit = 10,
                    DFIntNetworkLatencyTolerance = 1,
                    DFIntNetworkPrediction = 120,
                    DFIntOptimizePingThreshold = 50,
                    DFIntPlayerNetworkUpdateQueueSize = 20,
                    DFIntPlayerNetworkUpdateRate = 60,
                    DFIntRaknetBandwidthInfluxHundredthsPercentageV2 = 10000,
                    DFIntRaknetBandwidthPingSendEveryXSeconds = 1,
                    DFIntRakNetLoopMs = 1,
                    DFIntRakNetResendRttMultiple = 1,
                    DFIntServerPhysicsUpdateRate = 60,
                    DFIntServerTickRate = 60,
                    DFIntWaitOnRecvFromLoopEndedMS = 100,
                    DFIntWaitOnUpdateNetworkLoopEndedMS = 100,
                    FFlagOptimizeNetwork = true,
                    FFlagOptimizeNetworkRouting = true,
                    FFlagOptimizeNetworkTransport = true,
                    FFlagOptimizeServerTickRate = true,
                    FIntRakNetResendBufferArrayLength = 128,
                }
                for n, v in pairs(flags) do
                    setfflag(n, tostring(v))
                end
            end
        end)
        
    elseif currentTab == "自定义FFlag" then
        local nameBox = Instance.new("TextBox")
        nameBox.Size = UDim2.new(0.95, 0, 0, 35)
        nameBox.Position = UDim2.new(0.025, 0, 0, 5)
        nameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        nameBox.PlaceholderText = "FFlag 名称"
        nameBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        nameBox.Text = ""
        nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameBox.Font = Enum.Font.Gotham
        nameBox.TextSize = 13
        nameBox.Parent = contentFrame
        
        local valueBox = Instance.new("TextBox")
        valueBox.Size = UDim2.new(0.95, 0, 0, 35)
        valueBox.Position = UDim2.new(0.025, 0, 0, 45)
        valueBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        valueBox.PlaceholderText = "值"
        valueBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        valueBox.Text = ""
        valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueBox.Font = Enum.Font.Gotham
        valueBox.TextSize = 13
        valueBox.Parent = contentFrame
        
        local addBtn = Instance.new("TextButton")
        addBtn.Size = UDim2.new(0.95, 0, 0, 35)
        addBtn.Position = UDim2.new(0.025, 0, 0, 85)
        addBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        addBtn.Text = "添加自定义 FFlag"
        addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        addBtn.Font = Enum.Font.Gotham
        addBtn.TextSize = 14
        addBtn.Parent = contentFrame
        
        local listLabel = Instance.new("TextLabel")
        listLabel.Size = UDim2.new(0.95, 0, 0, 25)
        listLabel.Position = UDim2.new(0.025, 0, 0, 125)
        listLabel.BackgroundTransparency = 1
        listLabel.Text = "已添加的自定义 FFlag:"
        listLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        listLabel.TextXAlignment = Enum.TextXAlignment.Left
        listLabel.Font = Enum.Font.Gotham
        listLabel.TextSize = 12
        listLabel.Parent = contentFrame
        
        local listFrame = Instance.new("ScrollingFrame")
        listFrame.Size = UDim2.new(0.95, 0, 0, 150)
        listFrame.Position = UDim2.new(0.025, 0, 0, 155)
        listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        listFrame.BorderSizePixel = 0
        listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        listFrame.Parent = contentFrame
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = listFrame
        
        local function refreshFFlagList()
            for _, child in ipairs(listFrame:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end
            
            for name, value in pairs(fflags) do
                local item = Instance.new("Frame")
                item.Size = UDim2.new(1, 0, 0, 40)
                item.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                item.Parent = listFrame
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.6, 0, 0, 18)
                nameLabel.Position = UDim2.new(0, 5, 0, 2)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.TextSize = 10
                nameLabel.Parent = item
                
                local valLabel = Instance.new("TextLabel")
                valLabel.Size = UDim2.new(0.6, 0, 0, 18)
                valLabel.Position = UDim2.new(0, 5, 0, 20)
                valLabel.BackgroundTransparency = 1
                valLabel.Text = "值: " .. tostring(value)
                valLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                valLabel.TextXAlignment = Enum.TextXAlignment.Left
                valLabel.Font = Enum.Font.Gotham
                valLabel.TextSize = 9
                valLabel.Parent = item
                
                local removeBtn = Instance.new("TextButton")
                removeBtn.Size = UDim2.new(0, 40, 0, 25)
                removeBtn.Position = UDim2.new(1, -45, 0, 7.5)
                removeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                removeBtn.Text = "删"
                removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                removeBtn.Font = Enum.Font.Gotham
                removeBtn.TextSize = 11
                removeBtn.Parent = item
                
                removeBtn.MouseButton1Click:Connect(function()
                    fflags[name] = nil
                    saveConfig()
                    refreshFFlagList()
                end)
            end
            
            listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
        end
        
        addBtn.MouseButton1Click:Connect(function()
            local name = nameBox.Text
            local val = valueBox.Text
            
            if name == "" or val == "" then
                return
            end
            
            local processed = val:lower() == "true" and true or 
                            val:lower() == "false" and false or 
                            tonumber(val) or val
            
            setFFlag(name, processed)
            refreshFFlagList()
            nameBox.Text = ""
            valueBox.Text = ""
        end)
        
        refreshFFlagList()
    end
    
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
end

-- 初始化
updateTab()

-- 窗口拖动
local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

return screenGui