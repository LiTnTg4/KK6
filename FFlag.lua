--[[
FFlag 管理器（带独立GUI界面）
完全独立运行，不需要任何外部文件
]]

-- 初始化
local FFlagManager = {}
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local FFLAG_FILE = "FFlagEditor.json"

-- 存储 FFlag
local fflags = {}

-- 加载保存的 FFlag
local function loadFFlags()
    if isfile and isfile(FFLAG_FILE) then
        pcall(function()
            fflags = HttpService:JSONDecode(readfile(FFLAG_FILE))
        end)
    end
end

-- 保存 FFlag
local function saveFFlags()
    if writefile then
        pcall(function()
            writefile(FFLAG_FILE, HttpService:JSONEncode(fflags))
        end)
    end
end

-- 加载已有配置
loadFFlags()

-- 设置 FFlag
function FFlagManager:set(name, value)
    if not name then return false end
    fflags[name] = value
    saveFFlags()
    
    local success = false
    pcall(function()
        if setfflag then
            setfflag(name, tostring(value))
            success = true
        end
    end)
    
    if not success then
        pcall(function()
            if sethiddenproperty then
                local network = game:FindService("NetworkClient")
                if network then
                    sethiddenproperty(network, name, value)
                    success = true
                end
            end
        end)
    end
    
    return success
end

-- 获取 FFlag
function FFlagManager:get(name)
    if fflags[name] ~= nil then
        return fflags[name]
    end
    
    local value = nil
    pcall(function()
        if getfflag then
            value = getfflag(name)
        elseif gethiddenproperty then
            local network = game:FindService("NetworkClient")
            if network then
                value = gethiddenproperty(network, name)
            end
        end
    end)
    
    return value
end

-- 删除 FFlag
function FFlagManager:remove(name)
    fflags[name] = nil
    saveFFlags()
end

-- 预设配置
FFlagManager.PRESETS = {
    performance = {
        DFIntTaskSchedulerTargetFps = 240,
        FFlagDebugDisplayFPS = true,
        FFlagDisablePostFx = false,
    },
    graphics = {
        DFIntTextureQualityOverride = 3,
        FFlagTextureQualityOverrideEnabled = true,
        FFlagDebugRenderForceFutureIsBrightPhase2 = true,
    },
    hitreg = {
        DFIntCodecMaxIncomingPackets = 100,
        DFIntCodecMaxOutgoingFrames = 10000,
        DFIntPlayerNetworkUpdateRate = 60,
        DFIntServerTickRate = 60,
        FFlagOptimizeNetwork = true,
    },
    desync = {
        DFIntS2PhysicsSenderRate = 38000,
    }
}

-- 创建 GUI
local function createGUI()
    -- 确保 CoreGui 存在
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FFlagManagerGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- 适配不同执行环境
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    pcall(function()
        if not screenGui.Parent then
            screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)

    -- 主框架
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    -- 圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- 阴影
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.Parent = mainFrame

    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    -- 标题文字
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "FFlag 管理器"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = titleBar

    -- 关闭按钮
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 2.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- 标签页按钮
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -20, 0, 40)
    tabFrame.Position = UDim2.new(0, 10, 0, 40)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame

    local tabs = {"FFlag列表", "添加FFlag", "预设", "关于"}
    local currentTab = "FFlag列表"
    local tabButtons = {}

    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tabName
        btn.Size = UDim2.new(0.25, -5, 0, 30)
        btn.Position = UDim2.new((i-1) * 0.25, 2.5, 0, 5)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = tabFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn

        tabButtons[tabName] = btn

        btn.MouseButton1Click:Connect(function()
            currentTab = tabName
            updateTab()
            
            -- 更新按钮颜色
            for _, b in pairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end
            btn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        end)
    end

    -- 内容区域
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -90)
    contentFrame.Position = UDim2.new(0, 10, 0, 85)
    contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    contentFrame.BorderSizePixel = 0
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.ScrollBarThickness = 6
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(65, 105, 225)
    contentFrame.Parent = mainFrame

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentFrame

    -- 内容列表（用于放置实际内容）
    local contentList = Instance.new("UIListLayout")
    contentList.Padding = UDim.new(0, 8)
    contentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Parent = contentFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = contentFrame

    -- 更新标签页内容
    local function updateTab()
        -- 清空内容
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") or child:IsA("ScrollingFrame") then
                child:Destroy()
            end
        end

        if currentTab == "FFlag列表" then
            -- 显示所有 FFlag
            local listFrame = Instance.new("ScrollingFrame")
            listFrame.Size = UDim2.new(1, 0, 1, -10)
            listFrame.BackgroundTransparency = 1
            listFrame.BorderSizePixel = 0
            listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            listFrame.ScrollBarThickness = 4
            listFrame.Parent = contentFrame

            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 5)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Parent = listFrame

            -- 添加每个 FFlag
            for name, value in pairs(fflags) do
                local itemFrame = Instance.new("Frame")
                itemFrame.Size = UDim2.new(0.95, 0, 0, 45)
                itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                itemFrame.Parent = listFrame

                local itemCorner = Instance.new("UICorner")
                itemCorner.CornerRadius = UDim.new(0, 4)
                itemCorner.Parent = itemFrame

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.6, 0, 0, 20)
                nameLabel.Position = UDim2.new(0, 10, 0, 5)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.TextSize = 12
                nameLabel.Parent = itemFrame

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0.6, 0, 0, 20)
                valueLabel.Position = UDim2.new(0, 10, 0, 25)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = "值: " .. tostring(value)
                valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.TextSize = 11
                valueLabel.Parent = itemFrame

                local removeBtn = Instance.new("TextButton")
                removeBtn.Size = UDim2.new(0, 50, 0, 30)
                removeBtn.Position = UDim2.new(1, -60, 0, 7.5)
                removeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                removeBtn.Text = "删除"
                removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                removeBtn.Font = Enum.Font.Gotham
                removeBtn.TextSize = 12
                removeBtn.Parent = itemFrame

                local removeCorner = Instance.new("UICorner")
                removeCorner.CornerRadius = UDim.new(0, 4)
                removeCorner.Parent = removeBtn

                removeBtn.MouseButton1Click:Connect(function()
                    FFlagManager:remove(name)
                    itemFrame:Destroy()
                end)
            end

            -- 更新画布大小
            listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)

        elseif currentTab == "添加FFlag" then
            local nameBox = Instance.new("TextBox")
            nameBox.Size = UDim2.new(0.9, 0, 0, 35)
            nameBox.Position = UDim2.new(0.05, 0, 0, 10)
            nameBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            nameBox.PlaceholderText = "FFlag 名称 (例如: DFIntTaskSchedulerTargetFps)"
            nameBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            nameBox.Text = ""
            nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameBox.Font = Enum.Font.Gotham
            nameBox.TextSize = 14
            nameBox.ClearTextOnFocus = false
            nameBox.Parent = contentFrame

            local nameCorner = Instance.new("UICorner")
            nameCorner.CornerRadius = UDim.new(0, 6)
            nameCorner.Parent = nameBox

            local valueBox = Instance.new("TextBox")
            valueBox.Size = UDim2.new(0.9, 0, 0, 35)
            valueBox.Position = UDim2.new(0.05, 0, 0, 55)
            valueBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            valueBox.PlaceholderText = "值 (例如: 240, true, false)"
            valueBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            valueBox.Text = ""
            valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            valueBox.Font = Enum.Font.Gotham
            valueBox.TextSize = 14
            valueBox.ClearTextOnFocus = false
            valueBox.Parent = contentFrame

            local valueCorner = Instance.new("UICorner")
            valueCorner.CornerRadius = UDim.new(0, 6)
            valueCorner.Parent = valueBox

            local addBtn = Instance.new("TextButton")
            addBtn.Size = UDim2.new(0.9, 0, 0, 40)
            addBtn.Position = UDim2.new(0.05, 0, 0, 100)
            addBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
            addBtn.Text = "添加/更新 FFlag"
            addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            addBtn.Font = Enum.Font.GothamBold
            addBtn.TextSize = 16
            addBtn.Parent = contentFrame

            local addCorner = Instance.new("UICorner")
            addCorner.CornerRadius = UDim.new(0, 6)
            addCorner.Parent = addBtn

            local statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
            statusLabel.Position = UDim2.new(0.05, 0, 0, 150)
            statusLabel.BackgroundTransparency = 1
            statusLabel.Text = ""
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            statusLabel.Font = Enum.Font.Gotham
            statusLabel.TextSize = 12
            statusLabel.Parent = contentFrame

            addBtn.MouseButton1Click:Connect(function()
                local name = nameBox.Text
                local value = valueBox.Text
                
                if name == "" then
                    statusLabel.Text = "❌ 请输入 FFlag 名称"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    return
                end
                
                -- 尝试转换值
                local processedValue
                if value:lower() == "true" then
                    processedValue = true
                elseif value:lower() == "false" then
                    processedValue = false
                elseif tonumber(value) then
                    processedValue = tonumber(value)
                else
                    processedValue = value
                end
                
                local success = FFlagManager:set(name, processedValue)
                if success then
                    statusLabel.Text = "✅ 成功设置 " .. name .. " = " .. tostring(processedValue)
                    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    nameBox.Text = ""
                    valueBox.Text = ""
                else
                    statusLabel.Text = "❌ 设置失败，可能不支持此 FFlag"
                    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end)

        elseif currentTab == "预设" then
            local yPos = 10
            
            for presetName, presetFlags in pairs(FFlagManager.PRESETS) do
                local presetFrame = Instance.new("Frame")
                presetFrame.Size = UDim2.new(0.9, 0, 0, 70)
                presetFrame.Position = UDim2.new(0.05, 0, 0, yPos)
                presetFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                presetFrame.Parent = contentFrame

                local presetCorner = Instance.new("UICorner")
                presetCorner.CornerRadius = UDim.new(0, 6)
                presetCorner.Parent = presetFrame

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.7, 0, 0, 25)
                nameLabel.Position = UDim2.new(0, 10, 0, 5)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = presetName:upper()
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 14
                nameLabel.Parent = presetFrame

                local descLabel = Instance.new("TextLabel")
                descLabel.Size = UDim2.new(0.7, 0, 0, 35)
                descLabel.Position = UDim2.new(0, 10, 0, 30)
                descLabel.BackgroundTransparency = 1
                descLabel.Text = table.count(presetFlags) .. " 个 FFlag"
                descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.TextWrapped = true
                descLabel.Font = Enum.Font.Gotham
                descLabel.TextSize = 11
                descLabel.Parent = presetFrame

                local applyBtn = Instance.new("TextButton")
                applyBtn.Size = UDim2.new(0, 70, 0, 35)
                applyBtn.Position = UDim2.new(1, -80, 0, 17.5)
                applyBtn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
                applyBtn.Text = "应用"
                applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                applyBtn.Font = Enum.Font.GothamBold
                applyBtn.TextSize = 14
                applyBtn.Parent = presetFrame

                local applyCorner = Instance.new("UICorner")
                applyCorner.CornerRadius = UDim.new(0, 4)
                applyCorner.Parent = applyBtn

                applyBtn.MouseButton1Click:Connect(function()
                    for name, value in pairs(presetFlags) do
                        FFlagManager:set(name, value)
                    end
                    
                    local notif = Instance.new("TextLabel")
                    notif.Size = UDim2.new(0.9, 0, 0, 30)
                    notif.Position = UDim2.new(0.05, 0, 0, yPos + 75)
                    notif.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    notif.Text = "✅ 已应用 " .. presetName .. " 预设"
                    notif.TextColor3 = Color3.fromRGB(100, 255, 100)
                    notif.Font = Enum.Font.Gotham
                    notif.TextSize = 12
                    notif.Parent = contentFrame

                    local notifCorner = Instance.new("UICorner")
                    notifCorner.CornerRadius = UDim.new(0, 4)
                    notifCorner.Parent = notif

                    task.wait(2)
                    notif:Destroy()
                end)

                yPos = yPos + 80
            end

        elseif currentTab == "关于" then
            local infoFrame = Instance.new("Frame")
            infoFrame.Size = UDim2.new(0.9, 0, 0, 200)
            infoFrame.Position = UDim2.new(0.05, 0, 0, 10)
            infoFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            infoFrame.Parent = contentFrame

            local infoCorner = Instance.new("UICorner")
            infoCorner.CornerRadius = UDim.new(0, 8)
            infoCorner.Parent = infoFrame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 40)
            titleLabel.Position = UDim2.new(0, 0, 0, 20)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = "FFlag 管理器"
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextSize = 24
            titleLabel.Parent = infoFrame

            local versionLabel = Instance.new("TextLabel")
            versionLabel.Size = UDim2.new(1, 0, 0, 30)
            versionLabel.Position = UDim2.new(0, 0, 0, 60)
            versionLabel.BackgroundTransparency = 1
            versionLabel.Text = "版本 1.0.0"
            versionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            versionLabel.Font = Enum.Font.Gotham
            versionLabel.TextSize = 14
            versionLabel.Parent = infoFrame

            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(0.9, 0, 0, 60)
            descLabel.Position = UDim2.new(0.05, 0, 0, 100)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = "简单的 FFlag 管理工具\n可以添加、删除、应用预设"
            descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextSize = 14
            descLabel.TextWrapped = true
            descLabel.Parent = infoFrame

            local countLabel = Instance.new("TextLabel")
            countLabel.Size = UDim2.new(0.9, 0, 0, 30)
            countLabel.Position = UDim2.new(0.05, 0, 0, 160)
            countLabel.BackgroundTransparency = 1
            countLabel.Text = "当前 FFlag 数量: " .. table.count(fflags)
            countLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            countLabel.Font = Enum.Font.Gotham
            countLabel.TextSize = 14
            countLabel.Parent = infoFrame
        end
    end

    -- 初始化第一个标签页
    updateTab()

    -- 使窗口可拖动
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
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
end

-- 创建并返回 GUI
return createGUI()