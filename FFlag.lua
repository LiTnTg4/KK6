--[[
FFlag 编辑器 - 通用兼容版
在 Delta 和其他执行器上都能稳定运行
]]

-- 初始化
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local FFLAG_FILE = "FFlags.json"  -- 通用文件名

-- 存储 FFlag
local fflags = {}

-- 安全执行函数
local function safe(func, default)
    local success, result = pcall(func)
    return success and result or default
end

-- 加载保存的 FFlag
local function loadFFlags()
    if safe(function() return isfile(FFLAG_FILE) end) then
        safe(function()
            local data = readfile(FFLAG_FILE)
            fflags = HttpService:JSONDecode(data)
        end)
    end
end

-- 保存 FFlag
local function saveFFlags()
    safe(function()
        writefile(FFLAG_FILE, HttpService:JSONEncode(fflags))
    end)
end

-- 加载已有配置
loadFFlags()

-- 设置 FFlag（兼容多种环境）
local function setFFlag(name, value)
    if not name then return false end
    
    -- 保存到本地
    fflags[name] = value
    saveFFlags()
    
    -- 尝试多种方式设置
    local success = false
    
    -- 方式1: setfflag
    success = safe(function()
        if setfflag then
            setfflag(name, tostring(value))
            return true
        end
        return false
    end) or false
    
    -- 方式2: sethiddenproperty (如果方式1失败)
    if not success then
        success = safe(function()
            if sethiddenproperty then
                local network = game:FindService("NetworkClient")
                if network then
                    sethiddenproperty(network, name, value)
                    return true
                end
            end
            return false
        end) or false
    end
    
    return success
end

-- 删除 FFlag
local function removeFFlag(name)
    fflags[name] = nil
    saveFFlags()
end

-- 获取所有 FFlag 数量
local function getFFlagCount()
    local count = 0
    for _ in pairs(fflags) do
        count = count + 1
    end
    return count
end

-- 创建 GUI（兼容性优先）
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FFlagEditor"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = safe(function() 
    return game:GetService("CoreGui") 
end) or LocalPlayer:WaitForChild("PlayerGui")

-- 主框架
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 450)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- 标题栏
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FFlag 编辑器"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.Gotham
title.TextSize = 15
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

-- 添加区域
local addLabel = Instance.new("TextLabel")
addLabel.Size = UDim2.new(1, -20, 0, 25)
addLabel.Position = UDim2.new(0, 10, 0, 45)
addLabel.BackgroundTransparency = 1
addLabel.Text = "添加新 FFlag"
addLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
addLabel.TextXAlignment = Enum.TextXAlignment.Left
addLabel.Font = Enum.Font.Gotham
addLabel.TextSize = 14
addLabel.Parent = mainFrame

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(1, -20, 0, 35)
nameBox.Position = UDim2.new(0, 10, 0, 75)
nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
nameBox.PlaceholderText = "FFlag 名称 (如: DFIntTaskSchedulerTargetFps)"
nameBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
nameBox.Text = ""
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 13
nameBox.ClearTextOnFocus = false
nameBox.Parent = mainFrame

local valueBox = Instance.new("TextBox")
valueBox.Size = UDim2.new(1, -20, 0, 35)
valueBox.Position = UDim2.new(0, 10, 0, 115)
valueBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
valueBox.PlaceholderText = "值 (数字、true/false 或文本)"
valueBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
valueBox.Text = ""
valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
valueBox.Font = Enum.Font.Gotham
valueBox.TextSize = 13
valueBox.ClearTextOnFocus = false
valueBox.Parent = mainFrame

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(1, -20, 0, 35)
addBtn.Position = UDim2.new(0, 10, 0, 160)
addBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
addBtn.Text = "添加 / 更新"
addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addBtn.Font = Enum.Font.Gotham
addBtn.TextSize = 14
addBtn.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

-- 列表区域
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -20, 0, 25)
listLabel.Position = UDim2.new(0, 10, 0, 230)
listLabel.BackgroundTransparency = 1
listLabel.Text = "当前 FFlag 列表 (0)"
listLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Font = Enum.Font.Gotham
listLabel.TextSize = 14
listLabel.Parent = mainFrame

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 70, 0, 25)
clearBtn.Position = UDim2.new(1, -80, 0, 230)
clearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
clearBtn.Text = "清空"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.Gotham
clearBtn.TextSize = 12
clearBtn.Parent = mainFrame

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -20, 0, 140)
listFrame.Position = UDim2.new(0, 10, 0, 260)
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
listFrame.BorderSizePixel = 0
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.ScrollBarThickness = 4
listFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 120, 255)
listFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listFrame

-- 刷新列表
local function refreshList()
    -- 清空列表
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- 添加每个 FFlag
    for name, value in pairs(fflags) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(0.98, 0, 0, 45)
        itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        itemFrame.Parent = listFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.7, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 5, 0, 2)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 11
        nameLabel.TextWrapped = true
        nameLabel.Parent = itemFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.7, 0, 0, 18)
        valueLabel.Position = UDim2.new(0, 5, 0, 22)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = "值: " .. tostring(value)
        valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextSize = 10
        valueLabel.Parent = itemFrame
        
        local removeBtn = Instance.new("TextButton")
        removeBtn.Size = UDim2.new(0, 45, 0, 30)
        removeBtn.Position = UDim2.new(1, -50, 0, 7.5)
        removeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        removeBtn.Text = "删除"
        removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeBtn.Font = Enum.Font.Gotham
        removeBtn.TextSize = 11
        removeBtn.Parent = itemFrame
        
        removeBtn.MouseButton1Click:Connect(function()
            removeFFlag(name)
            refreshList()
            statusLabel.Text = "✅ 已删除: " .. name
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end)
        
        -- 点击项目填充到输入框
        itemFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                nameBox.Text = name
                valueBox.Text = tostring(value)
            end
        end)
    end
    
    -- 更新画布大小
    listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
    listLabel.Text = "当前 FFlag 列表 (" .. getFFlagCount() .. ")"
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
    
    -- 转换值类型
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
        refreshList()
    else
        statusLabel.Text = "❌ 设置失败 (环境不支持)"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- 清空按钮功能
clearBtn.MouseButton1Click:Connect(function()
    fflags = {}
    saveFFlags()
    refreshList()
    statusLabel.Text = "✅ 已清空所有 FFlag"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
end)

-- 回车快捷添加
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
refreshList()

-- 窗口拖动功能
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