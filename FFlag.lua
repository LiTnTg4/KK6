--[[
纯自定义 FFlag 编辑器
只能自己输入 FFlag，没有预设
]]

-- 初始化
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
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
local function setFFlag(name, value)
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

-- 删除 FFlag
local function removeFFlag(name)
    fflags[name] = nil
    saveFFlags()
end

-- 创建 GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FFlagCustomEditor"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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
mainFrame.Size = UDim2.new(0, 500, 0, 450)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- 圆角
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- 标题栏
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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
title.Text = "FFlag 自定义编辑器"
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

-- 添加区域标题
local addTitle = Instance.new("TextLabel")
addTitle.Size = UDim2.new(1, -20, 0, 30)
addTitle.Position = UDim2.new(0, 10, 0, 45)
addTitle.BackgroundTransparency = 1
addTitle.Text = "添加 / 更新 FFlag"
addTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
addTitle.TextXAlignment = Enum.TextXAlignment.Left
addTitle.Font = Enum.Font.GothamBold
addTitle.TextSize = 14
addTitle.Parent = mainFrame

-- 名称输入框
local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(1, -20, 0, 35)
nameBox.Position = UDim2.new(0, 10, 0, 80)
nameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
nameBox.PlaceholderText = "FFlag 名称 (例如: DFIntTaskSchedulerTargetFps)"
nameBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
nameBox.Text = ""
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 13
nameBox.ClearTextOnFocus = false
nameBox.Parent = mainFrame

local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 6)
nameCorner.Parent = nameBox

-- 值输入框
local valueBox = Instance.new("TextBox")
valueBox.Size = UDim2.new(1, -20, 0, 35)
valueBox.Position = UDim2.new(0, 10, 0, 125)
valueBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
valueBox.PlaceholderText = "值 (数字、true/false 或文本)"
valueBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
valueBox.Text = ""
valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
valueBox.Font = Enum.Font.Gotham
valueBox.TextSize = 13
valueBox.ClearTextOnFocus = false
valueBox.Parent = mainFrame

local valueCorner = Instance.new("UICorner")
valueCorner.CornerRadius = UDim.new(0, 6)
valueCorner.Parent = valueBox

-- 添加按钮
local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(1, -20, 0, 40)
addBtn.Position = UDim2.new(0, 10, 0, 170)
addBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
addBtn.Text = "添加 / 更新 FFlag"
addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 14
addBtn.Parent = mainFrame

local addCorner = Instance.new("UICorner")
addCorner.CornerRadius = UDim.new(0, 6)
addCorner.Parent = addBtn

-- 状态提示
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 215)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

-- 列表区域标题
local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, -20, 0, 30)
listTitle.Position = UDim2.new(0, 10, 0, 245)
listTitle.BackgroundTransparency = 1
listTitle.Text = "当前 FFlag 列表"
listTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.Font = Enum.Font.GothamBold
listTitle.TextSize = 14
listTitle.Parent = mainFrame

-- 清空所有按钮
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 80, 0, 25)
clearBtn.Position = UDim2.new(1, -90, 0, 245)
clearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
clearBtn.Text = "清空所有"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.Gotham
clearBtn.TextSize = 11
clearBtn.Parent = mainFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 4)
clearCorner.Parent = clearBtn

-- FFlag 列表区域
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -20, 0, 130)
listFrame.Position = UDim2.new(0, 10, 0, 280)
listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
listFrame.BorderSizePixel = 0
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.ScrollBarThickness = 6
listFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
listFrame.Parent = mainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = listFrame

-- 列表布局
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listFrame

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.Parent = listFrame

-- 刷新 FFlag 列表
local function refreshFFlagList()
    -- 清空列表
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- 添加每个 FFlag
    for name, value in pairs(fflags) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(0.95, 0, 0, 50)
        itemFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        itemFrame.Parent = listFrame
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 4)
        itemCorner.Parent = itemFrame
        
        -- FFlag 名称
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.6, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 10, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 11
        nameLabel.TextWrapped = true
        nameLabel.Parent = itemFrame
        
        -- FFlag 值
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.6, 0, 0, 20)
        valueLabel.Position = UDim2.new(0, 10, 0, 25)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = "值: " .. tostring(value)
        valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextSize = 10
        valueLabel.Parent = itemFrame
        
        -- 删除按钮
        local removeBtn = Instance.new("TextButton")
        removeBtn.Size = UDim2.new(0, 50, 0, 30)
        removeBtn.Position = UDim2.new(1, -60, 0, 10)
        removeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        removeBtn.Text = "删除"
        removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeBtn.Font = Enum.Font.Gotham
        removeBtn.TextSize = 11
        removeBtn.Parent = itemFrame
        
        local removeCorner = Instance.new("UICorner")
        removeCorner.CornerRadius = UDim.new(0, 4)
        removeCorner.Parent = removeBtn
        
        -- 删除功能
        removeBtn.MouseButton1Click:Connect(function()
            removeFFlag(name)
            refreshFFlagList()
            statusLabel.Text = "✅ 已删除: " .. name
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end)
        
        -- 编辑功能（点击项目可以填入编辑框）
        itemFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                nameBox.Text = name
                valueBox.Text = tostring(value)
            end
        end)
    end
    
    -- 更新画布大小
    listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    
    -- 更新标题显示数量
    listTitle.Text = "当前 FFlag 列表 (" .. table.count(fflags) .. ")"
end

-- 添加按钮功能
addBtn.MouseButton1Click:Connect(function()
    local name = nameBox.Text
    local value = valueBox.Text
    
    if name == "" then
        statusLabel.Text = "❌ 请输入 FFlag 名称"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    if value == "" then
        statusLabel.Text = "❌ 请输入值"
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
    
    local success = setFFlag(name, processedValue)
    if success then
        statusLabel.Text = "✅ 成功: " .. name .. " = " .. tostring(processedValue)
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        nameBox.Text = ""
        valueBox.Text = ""
        refreshFFlagList()
    else
        statusLabel.Text = "❌ 设置失败，可能不支持此 FFlag"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- 清空所有按钮功能
clearBtn.MouseButton1Click:Connect(function()
    fflags = {}
    saveFFlags()
    refreshFFlagList()
    statusLabel.Text = "✅ 已清空所有 FFlag"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
end)

-- 回车键快速添加
nameBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and nameBox.Text ~= "" then
        valueBox:CaptureFocus()
    end
end)

valueBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and nameBox.Text ~= "" and valueBox.Text ~= "" then
        addBtn.MouseButton1Click:Fire()
    end
end)

-- 初始化列表
refreshFFlagList()

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

-- 返回 GUI
return screenGui