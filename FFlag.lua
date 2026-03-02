local cloneref = cloneref or function(...) return ... end
local HttpService = cloneref(game:GetService('HttpService'))

makefolder('Bloxstrap')
makefolder('Bloxstrap/Main')
makefolder('Bloxstrap/Main/Functions')
makefolder('Bloxstrap/Main/Configs')
makefolder('Bloxstrap/Main/Fonts')
makefolder('Bloxstrap/Images')
makefolder('Bloxstrap/Logs')

writefile("Bloxstrap/Main/Functions/GuiLibrary.lua", [[
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerMouse = Player:GetMouse()

local redzlib = {
	Themes = {
		Darker = {
			["Color Hub 1"] = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(25, 25, 25)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(32.5, 32.5, 32.5)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 25, 25))
			}),
			["Color Hub 2"] = Color3.fromRGB(30, 30, 30),
			["Color Stroke"] = Color3.fromRGB(40, 40, 40),
			["Color Theme"] = Color3.fromRGB(88, 101, 242),
			["Color Text"] = Color3.fromRGB(243, 243, 243),
			["Color Dark Text"] = Color3.fromRGB(180, 180, 180)
		},
		Dark = {
			["Color Hub 1"] = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 40)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(47.5, 47.5, 47.5)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(40, 40, 40))
			}),
			["Color Hub 2"] = Color3.fromRGB(45, 45, 45),
			["Color Stroke"] = Color3.fromRGB(65, 65, 65),
			["Color Theme"] = Color3.fromRGB(65, 150, 255),
			["Color Text"] = Color3.fromRGB(245, 245, 245),
			["Color Dark Text"] = Color3.fromRGB(190, 190, 190)
		},
		Purple = {
			["Color Hub 1"] = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(27.5, 25, 30)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(32.5, 32.5, 32.5)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(27.5, 25, 30))
			}),
			["Color Hub 2"] = Color3.fromRGB(30, 30, 30),
			["Color Stroke"] = Color3.fromRGB(40, 40, 40),
			["Color Theme"] = Color3.fromRGB(150, 0, 255),
			["Color Text"] = Color3.fromRGB(240, 240, 240),
			["Color Dark Text"] = Color3.fromRGB(180, 180, 180)
		}
	},
	Info = {
		Version = "1.1.0"
	},
	Save = {
		UISize = {550, 380},
		TabSize = 160,
		Theme = "Darker"
	},
	Settings = {},
	Connection = {},
	Instances = {},
	Elements = {},
	Options = {},
	Flags = {},
	Tabs = {},
	Icons = {}
}

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIScale = ViewportSize.Y / 450

local Settings = redzlib.Settings
local Flags = redzlib.Flags

local SetProps, SetChildren, InsertTheme, Create do
	InsertTheme = function(Instance, Type)
		table.insert(redzlib.Instances, {
			Instance = Instance,
			Type = Type
		})
		return Instance
	end
	
	SetChildren = function(Instance, Children)
		if Children then
			table.foreach(Children, function(_,Child)
				Child.Parent = Instance
			end)
		end
		return Instance
	end
	
	SetProps = function(Instance, Props)
		if Props then
			table.foreach(Props, function(prop, value)
				Instance[prop] = value
			end)
		end
		return Instance
	end
	
	Create = function(...)
		local args = {...}
		if type(args) ~= "table" then return end
		local new = Instance.new(args[1])
		local Children = {}
		
		if type(args[2]) == "table" then
			SetProps(new, args[2])
			SetChildren(new, args[3])
			Children = args[3] or {}
		elseif typeof(args[2]) == "Instance" then
			new.Parent = args[2]
			SetProps(new, args[3])
			SetChildren(new, args[4])
			Children = args[4] or {}
		end
		return new
	end
	
	local function Save(file)
		if readfile and isfile and isfile(file) then
			local decode = HttpService:JSONDecode(readfile(file))
			
			if type(decode) == "table" then
				if rawget(decode, "UISize") then redzlib.Save["UISize"] = decode["UISize"] end
				if rawget(decode, "TabSize") then redzlib.Save["TabSize"] = decode["TabSize"] end
				if rawget(decode, "Theme") and VerifyTheme(decode["Theme"]) then redzlib.Save["Theme"] = decode["Theme"] end
			end
		end
	end
	
	pcall(Save, "redz library V5.json")
end

local Funcs = {} do
	function Funcs:InsertCallback(tab, func)
		if type(func) == "function" then
			table.insert(tab, func)
		end
		return func
	end
	
	function Funcs:FireCallback(tab, ...)
		for _,v in ipairs(tab) do
			if type(v) == "function" then
				task.spawn(v, ...)
				if Bloxstrap ~= nil then
					Bloxstrap.SaveConfig()
				end
			end
		end
	end
	
	function Funcs:ToggleVisible(Obj, Bool)
		Obj.Visible = Bool ~= nil and Bool or Obj.Visible
	end
	
	function Funcs:ToggleParent(Obj, Parent)
		if Bool ~= nil then
			Obj.Parent = Bool
		else
			Obj.Parent = not Obj.Parent and Parent
		end
	end
	
	function Funcs:GetConnectionFunctions(ConnectedFuncs, func)
		local Connected = { Function = func, Connected = true }
		
		function Connected:Disconnect()
			if self.Connected then
				table.remove(ConnectedFuncs, table.find(ConnectedFuncs, self.Function))
				self.Connected = false
			end
		end
		
		function Connected:Fire(...)
			if self.Connected then
				task.spawn(self.Function, ...)
			end
		end
		
		return Connected
	end
	
	function Funcs:GetCallback(Configs, index)
		local func = Configs[index] or Configs.Callback or function()end
		
		if type(func) == "table" then
			return ({function(Value) func[1][func[2]] = Value end})
		end
		return {func}
	end
end

local Connections, Connection = {}, redzlib.Connection do
	local function NewConnectionList(List)
		if type(List) ~= "table" then return end
		
		for _,CoName in ipairs(List) do
			local ConnectedFuncs, Connect = {}, {}
			Connection[CoName] = Connect
			Connections[CoName] = ConnectedFuncs
			Connect.Name = CoName
			
			function Connect:Connect(func)
				if type(func) == "function" then
					table.insert(ConnectedFuncs, func)
					return Funcs:GetConnectionFunctions(ConnectedFuncs, func)
				end
			end
			
			function Connect:Once(func)
				if type(func) == "function" then
					local Connected;
					
					local _NFunc;_NFunc = function(...)
						task.spawn(func, ...)
						Connected:Disconnect()
					end
					
					Connected = Funcs:GetConnectionFunctions(ConnectedFuncs, _NFunc)
					return Connected
				end
			end
		end
	end
	
	function Connection:FireConnection(CoName, ...)
		local Connection = type(CoName) == "string" and Connections[CoName] or Connections[CoName.Name]
		for _,Func in pairs(Connection) do
			task.spawn(Func, ...)
		end
	end
	
	NewConnectionList({"FlagsChanged", "ThemeChanged", "FileSaved", "ThemeChanging", "OptionAdded"})
end

local GetFlag, SetFlag, CheckFlag do
	CheckFlag = function(Name)
		return type(Name) == "string" and Flags[Name] ~= nil
	end
	
	GetFlag = function(Name)
		return type(Name) == "string" and Flags[Name]
	end
	
	SetFlag = function(Flag, Value)
		if Flag and (Value ~= Flags[Flag] or type(Value) == "table") then
			Flags[Flag] = Value
			Connection:FireConnection("FlagsChanged", Flag, Value)
		end
	end
	
	local db
	Connection.FlagsChanged:Connect(function(Flag, Value)
		local ScriptFile = Settings.ScriptFile
		if not db and ScriptFile and writefile then
			db=true;task.wait(0.1);db=false
			
			local Success, Encoded = pcall(function()
				return HttpService:JSONEncode(Flags)
			end)
			
			if Success then
				local Success = pcall(writefile, ScriptFile, Encoded)
				if Success then
					Connection:FireConnection("FileSaved", "Script-Flags", ScriptFile, Encoded)
				end
			end
		end
	end)
end

local ScreenGui = Create("ScreenGui", CoreGui, {
	Name = "redz Library V5",
}, {
	Create("UIScale", {
		Scale = UIScale,
		Name = "Scale"
	})
})

local ScreenFind = CoreGui:FindFirstChild(ScreenGui.Name)
if ScreenFind and ScreenFind ~= ScreenGui then
	ScreenFind:Destroy()
end

local function GetStr(val)
	if type(val) == "function" then
		return val()
	end
	return val
end

local function ConnectSave(Instance, func)
	Instance.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
			end
		end
		func()
	end)
end

local function CreateTween(Configs)
	local Instance = Configs[1] or Configs.Instance
	local Prop = Configs[2] or Configs.Prop
	local NewVal = Configs[3] or Configs.NewVal
	local Time = Configs[4] or Configs.Time or 0.5
	local TweenWait = Configs[5] or Configs.wait or false
	local TweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Quint)
	
	local Tween = TweenService:Create(Instance, TweenInfo, {[Prop] = NewVal})
	Tween:Play()
	if TweenWait then
		Tween.Completed:Wait()
	end
	return Tween
end

local function MakeDrag(Instance)
	Instance.Active = true
	Instance.Draggable = true
	return Instance
end

local function VerifyTheme(Theme)
	for name,_ in pairs(redzlib.Themes) do
		if name == Theme then
			return true
		end
	end
end

local function SaveJson(FileName, save)
	if writefile then
		local json = HttpService:JSONEncode(save)
		writefile(FileName, json)
	end
end

local Theme = redzlib.Themes[redzlib.Save.Theme]

local function AddEle(Name, Func)
	redzlib.Elements[Name] = Func
end

local function Make(Ele, Instance, props, ...)
	local Element = redzlib.Elements[Ele](Instance, props, ...)
	return Element
end

AddEle("Corner", function(parent, CornerRadius)
	local New = SetProps(Create("UICorner", parent, {
		CornerRadius = CornerRadius or UDim.new(0, 7)
	}), props)
	return New
end)

AddEle("Stroke", function(parent, props, ...)
	local args = {...}
	local New = InsertTheme(SetProps(Create("UIStroke", parent, {
		Color = args[1] or Theme["Color Stroke"],
		Thickness = args[2] or 1,
		ApplyStrokeMode = "Border"
	}), props), "Stroke")
	return New
end)

AddEle("Button", function(parent, props, ...)
	local args = {...}
	local New = InsertTheme(SetProps(Create("TextButton", parent, {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme["Color Hub 2"],
		AutoButtonColor = false
	}), props), "Frame")
	
	New.MouseEnter:Connect(function()
		New.BackgroundTransparency = 0.4
	end)
	New.MouseLeave:Connect(function()
		New.BackgroundTransparency = 0
	end)
	if args[1] then
		New.Activated:Connect(args[1])
	end
	return New
end)

AddEle("Gradient", function(parent, props, ...)
	local args = {...}
	local New = InsertTheme(SetProps(Create("UIGradient", parent, {
		Color = Theme["Color Hub 1"]
	}), props), "Gradient")
	return New
end)

local function ButtonFrame(Instance, Title, Description, HolderSize)
	local TitleL = InsertTheme(Create("TextLabel", {
		Font = Enum.Font.GothamMedium,
		TextColor3 = Theme["Color Text"],
		Size = UDim2.new(1, -20),
		AutomaticSize = "Y",
		Position = UDim2.new(0, 0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		TextTruncate = "AtEnd",
		TextSize = 10,
		TextXAlignment = "Left",
		Text = "",
		RichText = true
	}), "Text")
	
	local DescL = InsertTheme(Create("TextLabel", {
		Font = Enum.Font.Gotham,
		TextColor3 = Theme["Color Dark Text"],
		Size = UDim2.new(1, -20),
		AutomaticSize = "Y",
		Position = UDim2.new(0, 12, 0, 15),
		BackgroundTransparency = 1,
		TextWrapped = true,
		TextSize = 8,
		TextXAlignment = "Left",
		Text = "",
		RichText = true
	}), "DarkText")

	local Frame = Make("Button", Instance, {
		Size = UDim2.new(1, 0, 0, 25),
		AutomaticSize = "Y",
		Name = "Option"
	})Make("Corner", Frame, UDim.new(0, 6))
	
	LabelHolder = Create("Frame", Frame, {
		AutomaticSize = "Y",
		BackgroundTransparency = 1,
		Size = HolderSize,
		Position = UDim2.new(0, 10, 0),
		AnchorPoint = Vector2.new(0, 0)
	}, {
		Create("UIListLayout", {
			SortOrder = "LayoutOrder",
			VerticalAlignment = "Center",
			Padding = UDim.new(0, 2)
		}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5)
		}),
		TitleL,
		DescL,
	})
	
	local Label = {}
	function Label:SetTitle(NewTitle)
		if type(NewTitle) == "string" and NewTitle:gsub(" ", ""):len() > 0 then
			TitleL.Text = NewTitle
		end
	end
	function Label:SetDesc(NewDesc)
		if type(NewDesc) == "string" and NewDesc:gsub(" ", ""):len() > 0 then
			DescL.Visible = true
			DescL.Text = NewDesc
			LabelHolder.Position = UDim2.new(0, 10, 0)
			LabelHolder.AnchorPoint = Vector2.new(0, 0)
		else
			DescL.Visible = false
			DescL.Text = ""
			LabelHolder.Position = UDim2.new(0, 10, 0.5)
			LabelHolder.AnchorPoint = Vector2.new(0, 0.5)
		end
	end
	
	Label:SetTitle(Title)
	Label:SetDesc(Description)
	return Frame, Label
end

local function GetColor(Instance)
	if Instance:IsA("Frame") then
		return "BackgroundColor3"
	elseif Instance:IsA("ImageLabel") then
		return "ImageColor3"
	elseif Instance:IsA("TextLabel") then
		return "TextColor3"
	elseif Instance:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	elseif Instance:IsA("UIStroke") then
		return "Color"
	end
	return ""
end

function redzlib:GetIcon(index)
	return ''
end

function redzlib:SetTheme(NewTheme)
	if not VerifyTheme(NewTheme) then return end
	
	redzlib.Save.Theme = NewTheme
	SaveJson("redz library V5.json", redzlib.Save)
	Theme = redzlib.Themes[NewTheme]
	
	Connection:FireConnection("ThemeChanged", NewTheme)
	table.foreach(redzlib.Instances, function(_,Val)
		if Val.Type == "Gradient" then
			Val.Instance.Color = Theme["Color Hub 1"]
		elseif Val.Type == "Frame" then
			Val.Instance.BackgroundColor3 = Theme["Color Hub 2"]
		elseif Val.Type == "Stroke" then
			Val.Instance[GetColor(Val.Instance)] = Theme["Color Stroke"]
		elseif Val.Type == "Theme" then
			Val.Instance[GetColor(Val.Instance)] = Theme["Color Theme"]
		elseif Val.Type == "Text" then
			Val.Instance[GetColor(Val.Instance)] = Theme["Color Text"]
		elseif Val.Type == "DarkText" then
			Val.Instance[GetColor(Val.Instance)] = Theme["Color Dark Text"]
		elseif Val.Type == "ScrollBar" then
			Val.Instance[GetColor(Val.Instance)] = Theme["Color Theme"]
		end
	end)
end

function redzlib:SetScale(NewScale)
	NewScale = ViewportSize.Y / math.clamp(NewScale, 300, 2000)
	UIScale, ScreenGui.Scale.Scale = NewScale, NewScale
end

function redzlib:MakeWindow(Configs)
	local WTitle = Configs[1] or Configs.Name or Configs.Title or "redz Library V5"
	local WMiniText = Configs[2] or Configs.SubTitle or "by : redz9999"
	
	Settings.ScriptFile = Configs[3] or Configs.SaveFolder or false
	
	local function LoadFile()
		local File = Settings.ScriptFile
		if type(File) ~= "string" then return end
		if not readfile or not isfile then return end
		local s, r = pcall(isfile, File)
		
		if s and r then
			local s, _Flags = pcall(readfile, File)
			
			if s and type(_Flags) == "string" then
				local s,r = pcall(function() return HttpService:JSONDecode(_Flags) end)
				Flags = s and r or {}
			end
		end
	end;LoadFile()
	
	local UISizeX, UISizeY = unpack(redzlib.Save.UISize)
	local MainFrame = InsertTheme(Create("ImageButton", ScreenGui, {
		Size = UDim2.fromOffset(UISizeX, UISizeY),
		Position = UDim2.new(0.5, -UISizeX/2, 0.5, -UISizeY/2),
		BackgroundTransparency = 0.03,
		Name = "Hub"
	}), "Main")
	Make("Gradient", MainFrame, {
		Rotation = 45
	})MakeDrag(MainFrame)
	
	local MainCorner = Make("Corner", MainFrame)
	
	local Components = Create("Folder", MainFrame, {
		Name = "Components"
	})
	
	local DropdownHolder = Create("Folder", ScreenGui, {
		Name = "Dropdown"
	})
	
	local TopBar = Create("Frame", Components, {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		Name = "Top Bar"
	})
	
	local Title = InsertTheme(Create("TextLabel", TopBar, {
		Position = UDim2.new(0, 15, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		AutomaticSize = "XY",
		Text = WTitle,
		TextXAlignment = "Left",
		TextSize = 12,
		TextColor3 = Theme["Color Text"],
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Name = "Title"
	}, {
		InsertTheme(Create("TextLabel", {
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = "X",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(1, 5, 0.9),
			Text = WMiniText,
			TextColor3 = Theme["Color Dark Text"],
			BackgroundTransparency = 1,
			TextXAlignment = "Left",
			TextYAlignment = "Bottom",
			TextSize = 8,
			Font = Enum.Font.Gotham,
			Name = "SubTitle"
		}), "DarkText")
	}), "Text")
	
	local MainScroll = InsertTheme(Create("ScrollingFrame", Components, {
		Size = UDim2.new(0, redzlib.Save.TabSize, 1, -TopBar.Size.Y.Offset),
		ScrollBarImageColor3 = Theme["Color Theme"],
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		ScrollBarThickness = 1.5,
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 0.2,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = "Y",
		ScrollingDirection = "Y",
		BorderSizePixel = 0,
		Name = "Tab Scroll"
	}, {
		Create("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10)
		}), Create("UIListLayout", {
			Padding = UDim.new(0, 5)
		})
	}), "ScrollBar")
	
	local Containers = Create("Frame", Components, {
		Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Name = "Containers"
	})
	
	local ControlSize1, ControlSize2 = MakeDrag(Create("ImageButton", MainFrame, {
		Size = UDim2.new(0, 35, 0, 35),
		Position = MainFrame.Size,
		Active = true,
		AnchorPoint = Vector2.new(0.8, 0.8),
		BackgroundTransparency = 1,
		Name = "Control Hub Size"
	})), MakeDrag(Create("ImageButton", MainFrame, {
		Size = UDim2.new(0, 20, 1, -30),
		Position = UDim2.new(0, MainScroll.Size.X.Offset, 1, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		Active = true,
		BackgroundTransparency = 1,
		Name = "Control Tab Size"
	}))
	
	local function ControlSize()
		local Pos1, Pos2 = ControlSize1.Position, ControlSize2.Position
		ControlSize1.Position = UDim2.fromOffset(math.clamp(Pos1.X.Offset, 430, 1000), math.clamp(Pos1.Y.Offset, 200, 500))
		ControlSize2.Position = UDim2.new(0, math.clamp(Pos2.X.Offset, 135, 250), 1, 0)
		
		MainScroll.Size = UDim2.new(0, ControlSize2.Position.X.Offset, 1, -TopBar.Size.Y.Offset)
		Containers.Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset)
		MainFrame.Size = ControlSize1.Position
	end
	
	ControlSize1:GetPropertyChangedSignal("Position"):Connect(ControlSize)
	ControlSize2:GetPropertyChangedSignal("Position"):Connect(ControlSize)
	
	ConnectSave(ControlSize1, function()
		if not Minimized then
			redzlib.Save.UISize = {MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset}
			SaveJson("redz library V5.json", redzlib.Save)
		end
	end)
	
	ConnectSave(ControlSize2, function()
		redzlib.Save.TabSize = MainScroll.Size.X.Offset
		SaveJson("redz library V5.json", redzlib.Save)
	end)
	
	local ButtonsFolder = Create("Folder", TopBar, {
		Name = "Buttons"
	})
	
	local CloseButton = Create("ImageButton", {
		Size = UDim2.new(0, 14, 0, 14),
		Position = UDim2.new(1, -10, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://10747384394",
		AutoButtonColor = false,
		Name = "Close"
	})
	
	local MinimizeButton = SetProps(CloseButton:Clone(), {
		Position = UDim2.new(1, -35, 0.5),
		Image = "rbxassetid://10734896206",
		Name = "Minimize"
	})
	
	SetChildren(ButtonsFolder, {
		CloseButton,
		MinimizeButton
	})
	
	local Minimized, SaveSize, WaitClick
	local Window, FirstTab = {}, false
	function Window:Visible(bool)
		game.CoreGui["redz Library V5"].Enabled = bool
	end
	function Window:CloseBtn()
		local Dialog = Window:Dialog({
			Title = "Close",
			Text = "Are you sure you want to close this script??",
			Options = {
				{"Confirm", function()
					ScreenGui:Destroy()
				end},
				{"Cancel"}
			}
		})
	end
	function Window:MinimizeBtn()
		if WaitClick then return end
		WaitClick = true
		
		if Minimized then
			MinimizeButton.Image = "rbxassetid://10734896206"
			CreateTween({MainFrame, "Size", SaveSize, 0.25, true})
			ControlSize1.Visible = true
			ControlSize2.Visible = true
			Minimized = false
		else
			MinimizeButton.Image = "rbxassetid://10734924532"
			SaveSize = MainFrame.Size
			ControlSize1.Visible = false
			ControlSize2.Visible = false
			CreateTween({MainFrame, "Size", UDim2.fromOffset(MainFrame.Size.X.Offset, 28), 0.25, true})
			Minimized = true
		end
		
		WaitClick = false
	end
	function Window:Minimize()
		MainFrame.Visible = not MainFrame.Visible
	end
	function Window:AddMinimizeButton(Configs)
		local Button = MakeDrag(Create("ImageButton", ScreenGui, {
			Size = UDim2.fromOffset(35, 35),
			Position = UDim2.fromScale(0.15, 0.15),
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme["Color Hub 2"],
			AutoButtonColor = false
		}))
		
		local Stroke, Corner
		if Configs.Corner then
			Corner = Make("Corner", Button)
			SetProps(Corner, Configs.Corner)
		end
		if Configs.Stroke then
			Stroke = Make("Stroke", Button)
			SetProps(Stroke, Configs.Corner)
		end
		
		SetProps(Button, Configs.Button)
		Button.Activated:Connect(Window.Minimize)
		
		return {
			Stroke = Stroke,
			Corner = Corner,
			Button = Button
		}
	end
	function Window:Set(Val1, Val2)
		if type(Val1) == "string" and type(Val2) == "string" then
			Title.Text = Val1
			Title.SubTitle.Text = Val2
		elseif type(Val1) == "string" then
			Title.Text = Val1
		end
	end
	function Window:Dialog(Configs)
		if MainFrame:FindFirstChild("Dialog") then return end
		if Minimized then
			Window:MinimizeBtn()
		end
		
		local DTitle = Configs[1] or Configs.Title or "Dialog"
		local DText = Configs[2] or Configs.Text or "This is a Dialog"
		local DOptions = Configs[3] or Configs.Options or {}
		
		local Frame = Create("Frame", {
			Active = true,
			Size = UDim2.fromOffset(250 * 1.08, 150 * 1.08),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5)
		}, {
			InsertTheme(Create("TextLabel", {
				Font = Enum.Font.GothamBold,
				Size = UDim2.new(1, 0, 0, 20),
				Text = DTitle,
				TextXAlignment = "Left",
				TextColor3 = Theme["Color Text"],
				TextSize = 15,
				Position = UDim2.fromOffset(15, 5),
				BackgroundTransparency = 1
			}), "Text"),
			InsertTheme(Create("TextLabel", {
				Font = Enum.Font.GothamMedium,
				Size = UDim2.new(1, -25),
				AutomaticSize = "Y",
				Text = DText,
				TextXAlignment = "Left",
				TextColor3 = Theme["Color Dark Text"],
				TextSize = 12,
				Position = UDim2.fromOffset(15, 25),
				BackgroundTransparency = 1,
				TextWrapped = true
			}), "DarkText")
		})Make("Gradient", Frame, {Rotation = 270})Make("Corner", Frame)
		
		local ButtonsHolder = Create("Frame", Frame, {
			Size = UDim2.fromScale(1, 0.35),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Theme["Color Hub 2"],
			BackgroundTransparency = 1
		}, {
			Create("UIListLayout", {
				Padding = UDim.new(0, 10),
				VerticalAlignment = "Center",
				FillDirection = "Horizontal",
				HorizontalAlignment = "Center"
			})
		})
		
		local Screen = InsertTheme(Create("Frame", MainFrame, {
			BackgroundTransparency = 0.6,
			Active = true,
			BackgroundColor3 = Theme["Color Hub 2"],
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Theme["Color Stroke"],
			Name = "Dialog"
		}), "Stroke")
		
		MainCorner:Clone().Parent = Screen
		Frame.Parent = Screen
		CreateTween({Frame, "Size", UDim2.fromOffset(250, 150), 0.2})
		CreateTween({Frame, "Transparency", 0, 0.15})
		CreateTween({Screen, "Transparency", 0.3, 0.15})
		
		local ButtonCount, Dialog = 1, {}
		function Dialog:Button(Configs)
			local Name = Configs[1] or Configs.Name or Configs.Title or ""
			local Callback = Configs[2] or Configs.Callback or function()end
			
			ButtonCount = ButtonCount + 1
			local Button = Make("Button", ButtonsHolder)
			Make("Corner", Button)
			SetProps(Button, {
				Text = Name,
				Font = Enum.Font.GothamBold,
				TextColor3 = Theme["Color Text"],
				TextSize = 12
			})
			
			for _,Button in pairs(ButtonsHolder:GetChildren()) do
				if Button:IsA("TextButton") then
					Button.Size = UDim2.new(1 / ButtonCount, -(((ButtonCount - 1) * 20) / ButtonCount), 0, 32)
				end
			end
			Button.Activated:Connect(Dialog.Close)
			Button.Activated:Connect(Callback)
		end
		function Dialog:Close()
			CreateTween({Frame, "Size", UDim2.fromOffset(250 * 1.08, 150 * 1.08), 0.2})
			CreateTween({Screen, "Transparency", 1, 0.15})
			CreateTween({Frame, "Transparency", 1, 0.15, true})
			Screen:Destroy()
		end
		table.foreach(DOptions, function(_,Button)
			Dialog:Button(Button)
		end)
		return Dialog
	end
	function Window:SelectTab(TabSelect)
		if type(TabSelect) == "number" then
			redzlib.Tabs[TabSelect].func:Enable()
		else
			for _,Tab in pairs(redzlib.Tabs) do
				if Tab.Cont == TabSelect.Cont then
					Tab.func:Enable()
				end
			end
		end
	end
	
	local ContainerList = {}
	function Window:MakeTab(paste, Configs)
		if type(paste) == "table" then Configs = paste end
		local TName = Configs[1] or Configs.Title or "Tab!"
		local TIcon = Configs[2] or Configs.Icon or ""
		
		TIcon = redzlib:GetIcon(TIcon)
		if not TIcon:find("rbxassetid://") or TIcon:gsub("rbxassetid://", ""):len() < 6 then
			TIcon = false
		end
		
		local TabSelect = Make("Button", MainScroll, {
			Size = UDim2.new(1, 0, 0, 24)
		})Make("Corner", TabSelect)
		
		local LabelTitle = InsertTheme(Create("TextLabel", TabSelect, {
			Size = UDim2.new(1, TIcon and -25 or -15, 1),
			Position = UDim2.fromOffset(TIcon and 25 or 15),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = TName,
			TextColor3 = Theme["Color Text"],
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = (FirstTab and 0.3) or 0,
			TextTruncate = "AtEnd"
		}), "Text")
		
		local LabelIcon = InsertTheme(Create("ImageLabel", TabSelect, {
			Position = UDim2.new(0, 8, 0.5),
			Size = UDim2.new(0, 13, 0, 13),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = TIcon or "",
			BackgroundTransparency = 1,
			ImageTransparency = (FirstTab and 0.3) or 0
		}), "Text")
		
		local Selected = InsertTheme(Create("Frame", TabSelect, {
			Size = FirstTab and UDim2.new(0, 4, 0, 4) or UDim2.new(0, 4, 0, 13),
			Position = UDim2.new(0, 1, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme["Color Theme"],
			BackgroundTransparency = FirstTab and 1 or 0
		}), "Theme")Make("Corner", Selected, UDim.new(0.5, 0))
		
		local Container = InsertTheme(Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 1),
			AnchorPoint = Vector2.new(0, 1),
			ScrollBarThickness = 1.5,
			BackgroundTransparency = 1,
			ScrollBarImageTransparency = 0.2,
			ScrollBarImageColor3 = Theme["Color Theme"],
			AutomaticCanvasSize = "Y",
			ScrollingDirection = "Y",
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			Name = ("Container %i [ %s ]"):format(#ContainerList + 1, TName)
		}, {
			Create("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10)
			}), Create("UIListLayout", {
				Padding = UDim.new(0, 5)
			})
		}), "ScrollBar")
		
		table.insert(ContainerList, Container)
		
		if not FirstTab then Container.Parent = Containers end
		
		local function Tabs()
			if Container.Parent then return end
			for _,Frame in pairs(ContainerList) do
				if Frame:IsA("ScrollingFrame") and Frame ~= Container then
					Frame.Parent = nil
				end
			end
			Container.Parent = Containers
			Container.Size = UDim2.new(1, 0, 1, 150)
			table.foreach(redzlib.Tabs, function(_,Tab)
				if Tab.Cont ~= Container then
					Tab.func:Disable()
				end
			end)
			CreateTween({Container, "Size", UDim2.new(1, 0, 1, 0), 0.3})
			CreateTween({LabelTitle, "TextTransparency", 0, 0.35})
			CreateTween({LabelIcon, "ImageTransparency", 0, 0.35})
			CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 13), 0.35})
			CreateTween({Selected, "BackgroundTransparency", 0, 0.35})
		end
		TabSelect.Activated:Connect(Tabs)
		
		FirstTab = true
		local Tab = {}
		table.insert(redzlib.Tabs, {TabInfo = {Name = TName, Icon = TIcon}, func = Tab, Cont = Container})
		Tab.Cont = Container
		
		function Tab:Disable()
			Container.Parent = nil
			CreateTween({LabelTitle, "TextTransparency", 0.3, 0.35})
			CreateTween({LabelIcon, "ImageTransparency", 0.3, 0.35})
			CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 4), 0.35})
			CreateTween({Selected, "BackgroundTransparency", 1, 0.35})
		end
		function Tab:Enable()
			Tabs()
		end
		function Tab:Visible(Bool)
			Funcs:ToggleVisible(TabSelect, Bool)
			Funcs:ToggleParent(Container, Bool, Containers)
		end
		function Tab:Destroy() TabSelect:Destroy() Container:Destroy() end
		
		function Tab:AddSection(Configs)
			local SectionName = type(Configs) == "string" and Configs or Configs[1] or Configs.Name or Configs.Title or Configs.Section
			
			local SectionFrame = Create("Frame", Container, {
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Name = "Option"
			})
			
			local SectionLabel = InsertTheme(Create("TextLabel", SectionFrame, {
				Font = Enum.Font.GothamBold,
				Text = SectionName,
				TextColor3 = Theme["Color Text"],
				Size = UDim2.new(1, -25, 1, 0),
				Position = UDim2.new(0, 5),
				BackgroundTransparency = 1,
				TextTruncate = "AtEnd",
				TextSize = 14,
				TextXAlignment = "Left"
			}), "Text")
			
			local Section = {}
			table.insert(redzlib.Options, {type = "Section", Name = SectionName, func = Section})
			function Section:Visible(Bool)
				if Bool == nil then SectionFrame.Visible = not SectionFrame.Visible return end
				SectionFrame.Visible = Bool
			end
			function Section:Destroy()
				SectionFrame:Destroy()
			end
			function Section:Set(New)
				if New then
					SectionLabel.Text = GetStr(New)
				end
			end
			return Section
		end
		function Tab:AddParagraph(Configs)
			local PName = Configs[1] or Configs.Title or "Paragraph"
			local PDesc = Configs[2] or Configs.Text or ""
			
			local Frame, LabelFunc = ButtonFrame(Container, PName, PDesc, UDim2.new(1, -20))
			
			local Paragraph = {}
			function Paragraph:Visible(...) Funcs:ToggleVisible(Frame, ...) end
			function Paragraph:Destroy() Frame:Destroy() end
			function Paragraph:SetTitle(Val)
				LabelFunc:SetTitle(GetStr(Val))
			end
			function Paragraph:SetDesc(Val)
				LabelFunc:SetDesc(GetStr(Val))
			end
			function Paragraph:Set(Val1, Val2)
				if Val1 and Val2 then
					LabelFunc:SetTitle(GetStr(Val1))
					LabelFunc:SetDesc(GetStr(Val2))
				elseif Val1 then
					LabelFunc:SetDesc(GetStr(Val1))
				end
			end
			return Paragraph
		end
		function Tab:AddButton(Configs)
			local BName = Configs[1] or Configs.Name or Configs.Title or "Button!"
			local BDescription = Configs.Desc or Configs.Description or ""
			local Callback = Funcs:GetCallback(Configs, 2)
			
			local FButton, LabelFunc = ButtonFrame(Container, BName, BDescription, UDim2.new(1, -20))
			
			local ButtonIcon = Create("ImageLabel", FButton, {
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, -10, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://10709791437"
			})
			
			FButton.Activated:Connect(function()
				Funcs:FireCallback(Callback)
			end)
			
			local Button = {}
			function Button:Visible(...) Funcs:ToggleVisible(FButton, ...) end
			function Button:Destroy() FButton:Destroy() end
			function Button:Callback(...) Funcs:InsertCallback(Callback, ...) end
			function Button:Set(Val1, Val2)
				if type(Val1) == "string" and type(Val2) == "string" then
					LabelFunc:SetTitle(Val1)
					LabelFunc:SetDesc(Val2)
				elseif type(Val1) == "string" then
					LabelFunc:SetTitle(Val1)
				elseif type(Val1) == "function" then
					Callback = Val1
				end
			end
			return Button
		end
		function Tab:AddToggle(Configs)
			local TName = Configs[1] or Configs.Name or Configs.Title or "Toggle"
			local TDesc = Configs.Desc or Configs.Description or ""
			local Callback = Funcs:GetCallback(Configs, 3)
			local Flag = Configs[4] or Configs.Flag or false
			local Default = Configs[2] or Configs.Default or false
			if CheckFlag(Flag) then Default = GetFlag(Flag) end
			
			local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))
			
			local ToggleHolder = InsertTheme(Create("Frame", Button, {
				Size = UDim2.new(0, 35, 0, 18),
				Position = UDim2.new(1, -10, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme["Color Stroke"]
			}), "Stroke")Make("Corner", ToggleHolder, UDim.new(0.5, 0))
			
			local Slider = Create("Frame", ToggleHolder, {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.8, 0, 0.8, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5)
			})
			
			local Toggle = InsertTheme(Create("Frame", Slider, {
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new(0, 0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Theme["Color Theme"]
			}), "Theme")Make("Corner", Toggle, UDim.new(0.5, 0))
			
			local WaitClick = false
			local function SetToggle(Val)
				if WaitClick then return end
				
				WaitClick, Default = true, Val
				SetFlag(Flag, Default)
				Funcs:FireCallback(Callback, Default)
				if tostring(Default) == "true" then
					CreateTween({Toggle, "Position", UDim2.new(1, 0, 0.5), 0.25})
					CreateTween({Toggle, "BackgroundTransparency", 0, 0.25})
					CreateTween({Toggle, "AnchorPoint", Vector2.new(1, 0.5), 0.25, Wait or false})
				else
					CreateTween({Toggle, "Position", UDim2.new(0, 0, 0.5), 0.25})
					CreateTween({Toggle, "BackgroundTransparency", 0.8, 0.25})
					CreateTween({Toggle, "AnchorPoint", Vector2.new(0, 0.5), 0.25, Wait or false})
				end
				WaitClick = false
			end;task.spawn(SetToggle, Default)
			
			Button.Activated:Connect(function()
				SetToggle(not Default)
			end)
	
			
			local Toggle = {}
			function Toggle:Retoggle()
			    if Default then
			        SetToggle(false)
			        SetToggle(true)
			    end
			end
			function Toggle:Toggle(bool) SetToggle(bool) end
			function Toggle:Visible(...) Funcs:ToggleVisible(Button, ...) end
			function Toggle:Destroy() Button:Destroy() end
			function Toggle:Callback(...) Funcs:InsertCallback(Callback, ...)() end
			function Toggle:Set(Val1, Val2)
				if type(Val1) == "string" and type(Val2) == "string" then
					LabelFunc:SetTitle(Val1)
					LabelFunc:SetDesc(Val2)
				elseif type(Val1) == "string" then
					LabelFunc:SetTitle(Val1, false, true)
				elseif type(Val1) == "boolean" then
					Toggle:Toggle(Val1)
				elseif type(Val1) == "function" then
					Callback = Val1
				end
			end
			return Toggle
		end
		function Tab:AddDropdown(Configs)
			local DName = Configs[1] or Configs.Name or Configs.Title or "Dropdown"
			local DDesc = Configs.Desc or Configs.Description or ""
			local DOptions = Configs[2] or Configs.Options or {}
			local OpDefault = Configs[3] or Configs.Default or {}
			local Flag = Configs[5] or Configs.Flag or false
			local DMultiSelect = Configs.MultiSelect or false
			local Callback = Funcs:GetCallback(Configs, 4)
			
			local Button, LabelFunc = ButtonFrame(Container, DName, DDesc, UDim2.new(1, -180))
			
			local SelectedFrame = InsertTheme(Create("Frame", Button, {
				Size = UDim2.new(0, 150, 0, 18),
				Position = UDim2.new(1, -10, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme["Color Stroke"]
			}), "Stroke")Make("Corner", SelectedFrame, UDim.new(0, 4))
			
			local ActiveLabel = InsertTheme(Create("TextLabel", SelectedFrame, {
				Size = UDim2.new(0.85, 0, 0.85, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextScaled = true,
				TextColor3 = Theme["Color Text"],
				Text = "..."
			}), "Text")
			
			local Arrow = Create("ImageLabel", SelectedFrame, {
				Size = UDim2.new(0, 15, 0, 15),
				Position = UDim2.new(0, -5, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				Image = "rbxassetid://10709791523",
				BackgroundTransparency = 1
			})
			
			local NoClickFrame = Create("TextButton", DropdownHolder, {
				Name = "AntiClick",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Visible = false,
				Text = ""
			})
			
			local DropFrame = Create("Frame", NoClickFrame, {
				Size = UDim2.new(SelectedFrame.Size.X, 0, 0),
				BackgroundTransparency = 0.1,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AnchorPoint = Vector2.new(0, 1),
				Name = "DropdownFrame",
				ClipsDescendants = true,
				Active = true
			})Make("Corner", DropFrame)Make("Stroke", DropFrame)Make("Gradient", DropFrame, {Rotation = 60})
			
			local ScrollFrame = InsertTheme(Create("ScrollingFrame", DropFrame, {
				ScrollBarImageColor3 = Theme["Color Theme"],
				Size = UDim2.new(1, 0, 1, 0),
				ScrollBarThickness = 1.5,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = UDim2.new(),
				ScrollingDirection = "Y",
				AutomaticCanvasSize = "Y",
				Active = true
			}, {
				Create("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5)
				}), Create("UIListLayout", {
					Padding = UDim.new(0, 4)
				})
			}), "ScrollBar")
			
			local ScrollSize, WaitClick = 5
			local function Disable()
				WaitClick = true
				CreateTween({Arrow, "Rotation", 0, 0.2})
				CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true})
				CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
				Arrow.Image = "rbxassetid://10709791523"
				NoClickFrame.Visible = false
				WaitClick = false
			end
			
			local function GetFrameSize()
				return UDim2.fromOffset(152, ScrollSize)
			end
			
			local function CalculateSize()
				local Count = 0
				for _,Frame in pairs(ScrollFrame:GetChildren()) do
					if Frame:IsA("Frame") or Frame.Name == "Option" then
						Count = Count + 1
					end
				end
				ScrollSize = (math.clamp(Count, 0, 10) * 25) + 10
				if NoClickFrame.Visible then
					NoClickFrame.Visible = true
					CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
				end
			end
			
			local opened = false
			local function Minimize()
				if WaitClick then return end
				WaitClick = true
				if NoClickFrame.Visible then
					Arrow.Image = "rbxassetid://10709791523"
					CreateTween({Arrow, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
					CreateTween({DropFrame, "Size", UDim2.new(0, 152, 0, 0), 0.2, true})
					NoClickFrame.Visible = false
				else
					NoClickFrame.Visible = true
					Arrow.Image = "rbxassetid://10709790948"
					CreateTween({Arrow, "ImageColor3", Theme["Color Theme"], 0.2})
					CreateTween({DropFrame, "Size", GetFrameSize(), 0.2, true})
				end
				WaitClick = false
				opened = not opened
			end
			
			local function CalculatePos()
				local FramePos = SelectedFrame.AbsolutePosition
				local ScreenSize = ScreenGui.AbsoluteSize
				local ClampX = math.clamp((FramePos.X / UIScale), 0, ScreenSize.X / UIScale - DropFrame.Size.X.Offset)
				local ClampY = math.clamp((FramePos.Y / UIScale) , 0, ScreenSize.Y / UIScale)
				
				local NewPos = UDim2.fromOffset(ClampX, ClampY)
				local AnchorPoint = FramePos.Y > ScreenSize.Y / 1.4 and 1 or ScrollSize > 80 and 0.5 or 0
				DropFrame.AnchorPoint = Vector2.new(0, AnchorPoint)
				CreateTween({DropFrame, "Position", NewPos, 0.1})
			end
			
			local Options = {}
			local AddNewOptions, GetOptions, AddOption, RemoveOption, Selected do
				local Default = type(OpDefault) ~= "table" and {OpDefault} or OpDefault
				local MultiSelect = DMultiSelect
				Selected = MultiSelect and {} or CheckFlag(Flag) and GetFlag(Flag) or Default[1]
				
				if MultiSelect then
					for index, Value in pairs(CheckFlag(Flag) and GetFlag(Flag) or Default) do
						if type(index) == "string" and (DOptions[index] or table.find(DOptions, index)) then
							Selected[index] = Value
						elseif DOptions[Value] then
							Selected[Value] = true
						end
					end
				end
				
				local function CallbackSelected()
					SetFlag(Flag, MultiSelect and Selected or tostring(Selected))
					Funcs:FireCallback(Callback, Selected)
				end
				
				local function UpdateLabel()
					if MultiSelect then
						local list = {}
						for index, Value in pairs(Selected) do
							if Value then
								table.insert(list, index)
							end
						end
						ActiveLabel.Text = #list > 0 and table.concat(list, ", ") or "..."
					else
						ActiveLabel.Text = tostring(Selected or "...")
					end
				end
				
				local function UpdateSelected()
					if MultiSelect then
						for _,v in pairs(Options) do
							local nodes, Stats = v.nodes, v.Stats
							CreateTween({nodes[2], "BackgroundTransparency", Stats and 0 or 0.8, 0.35})
							CreateTween({nodes[2], "Size", Stats and UDim2.fromOffset(4, 12) or UDim2.fromOffset(4, 4), 0.35})
							CreateTween({nodes[3], "TextTransparency", Stats and 0 or 0.4, 0.35})
						end
					else
						for _,v in pairs(Options) do
							local Slt = v.Value == Selected
							local nodes = v.nodes
							CreateTween({nodes[2], "BackgroundTransparency", Slt and 0 or 1, 0.35})
							CreateTween({nodes[2], "Size", Slt and UDim2.fromOffset(4, 14) or UDim2.fromOffset(4, 4), 0.35})
							CreateTween({nodes[3], "TextTransparency", Slt and 0 or 0.4, 0.35})
						end
					end
					UpdateLabel()
					if Bloxstrap.canUpdate then Minimize() end
				end
				
				local function Select(Option)
					if MultiSelect then
						Option.Stats = not Option.Stats
						Option.LastCB = tick()
						
						Selected[Option.Name] = Option.Stats
						CallbackSelected()
					else
						Option.LastCB = tick()
						
						Selected = Option.Value
						CallbackSelected()
					end
					UpdateSelected()
				end
				
				AddOption = function(index, Value)
					local Name = tostring(type(index) == "string" and index or Value)
					
					if Options[Name] then return end
					Options[Name] = {
						index = index,
						Value = Value,
						Name = Name,
						Stats = false,
						Activate = function() return Select(Options[Name]) end,
						LastCB = 0
					}
					
					if MultiSelect then
						local Stats = Selected[Name]
						Selected[Name] = Stats or false
						Options[Name].Stats = Stats
					end
					
					local Button = Make("Button", ScrollFrame, {
						Name = "Option",
						Size = UDim2.new(1, 0, 0, 21),
						Position = UDim2.new(0, 0, 0.5),
						AnchorPoint = Vector2.new(0, 0.5)
					})Make("Corner", Button, UDim.new(0, 4))
					
					local IsSelected = InsertTheme(Create("Frame", Button, {
						Position = UDim2.new(0, 1, 0.5),
						Size = UDim2.new(0, 4, 0, 4),
						BackgroundColor3 = Theme["Color Theme"],
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0, 0.5)
					}), "Theme")Make("Corner", IsSelected, UDim.new(0.5, 0))
					
					local OptioneName = InsertTheme(Create("TextLabel", Button, {
						Size = UDim2.new(1, 0, 1),
						Position = UDim2.new(0, 10),
						Text = Name,
						TextColor3 = Theme["Color Text"],
						Font = Enum.Font.GothamBold,
						TextXAlignment = "Left",
						BackgroundTransparency = 1,
						TextTransparency = 0.4
					}), "Text")
					
					Button.Activated:Connect(function()
						Select(Options[Name])
					end)
					
					Options[Name].nodes = {Button, IsSelected, OptioneName}
				end
				
				RemoveOption = function(index, Value)
					local Name = tostring(type(index) == "string" and index or Value)
					if Options[Name] then
						if MultiSelect then Selected[Name] = nil else Selected = nil end
						Options[Name].nodes[1]:Destroy()
						table.clear(Options[Name])
						Options[Name] = nil
					end
				end
				
				GetOptions = function()
					return Options
				end
				
				AddNewOptions = function(List, Clear)
					if Clear then
						table.foreach(Options, RemoveOption)
					end
					table.foreach(List, AddOption)
					CallbackSelected()
					UpdateSelected()
				end
				
				table.foreach(DOptions, AddOption)
				CallbackSelected()
				UpdateSelected()
			end
			
			Button.Activated:Connect(Minimize)
			NoClickFrame.MouseButton1Down:Connect(Disable)
			NoClickFrame.MouseButton1Click:Connect(Disable)
			MainFrame:GetPropertyChangedSignal("Visible"):Connect(Disable)
			SelectedFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(CalculatePos)
			
			Button.Activated:Connect(CalculateSize)
			ScrollFrame.ChildAdded:Connect(CalculateSize)
			ScrollFrame.ChildRemoved:Connect(CalculateSize)
			CalculatePos()
			CalculateSize()
			
			local Dropdown = {}
			function Dropdown:Visible(...) Funcs:ToggleVisible(Button, ...) end
			function Dropdown:Destroy() Button:Destroy() end
			function Dropdown:Callback(...) Funcs:InsertCallback(Callback, ...)(Selected) end
			
			function Dropdown:Add(...)
				local NewOptions = {...}
				if type(NewOptions[1]) == "table" then
					table.foreach(Option, function(_,Name)
						AddOption(Name)
					end)
				else
					table.foreach(NewOptions, function(_,Name)
						AddOption(Name)
					end)
				end
			end
			function Dropdown:Remove(Option)
				for index, Value in pairs(GetOptions()) do
					if type(Option) == "number" and index == Option or Value.Name == "Option" then
						RemoveOption(index, Value.Value)
					end
				end
			end
			function Dropdown:Select(Option)
				if type(Option) == "string" then
					for _,Val in Options do
						if Val.Name == Option then
							Val.Activate()
						end
					end
				elseif type(Option) == "number" then
					for ind,Val in Options do
						if ind == Option then
							Val.Activate()
						end
					end
				end
			end
			function Dropdown:Set(Val1, Clear)
				if type(Val1) == "table" then
					AddNewOptions(Val1, not Clear)
				elseif type(Val1) == "function" then
					Callback = Val1
				elseif type(Val1) == "string" or type(Val1) == "number" then
					Dropdown:Select(Val1)
				end
			end
			return Dropdown
		end
		function Tab:AddSlider(Configs)
			local SName = Configs[1] or Configs.Name or Configs.Title or "Slider!"
			local SDesc = Configs.Desc or Configs.Description or ""
			local Min = Configs[2] or Configs.MinValue or Configs.Min or 10
			local Max = Configs[3] or Configs.MaxValue or Configs.Max or 100
			local Increase = Configs[4] or Configs.Increase or 1
			local Callback = Funcs:GetCallback(Configs, 6)
			local Flag = Configs[7] or Configs.Flag or false
			local Default = Configs[5] or Configs.Default or 25
			if CheckFlag(Flag) then Default = GetFlag(Flag) end
			Min, Max = Min / Increase, Max / Increase
			
			local Button, LabelFunc = ButtonFrame(Container, SName, SDesc, UDim2.new(1, -180))
			
			local SliderHolder = Create("TextButton", Button, {
				Size = UDim2.new(0.45, 0, 1),
				Position = UDim2.new(1),
				AnchorPoint = Vector2.new(1, 0),
				AutoButtonColor = false,
				Text = "",
				BackgroundTransparency = 1
			})
			
			local SliderBar = InsertTheme(Create("Frame", SliderHolder, {
				BackgroundColor3 = Theme["Color Stroke"],
				Size = UDim2.new(1, -20, 0, 6),
				Position = UDim2.new(0.5, 0, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5)
			}), "Stroke")Make("Corner", SliderBar)
			
			local Indicator = InsertTheme(Create("Frame", SliderBar, {
				BackgroundColor3 = Theme["Color Theme"],
				Size = UDim2.fromScale(0.3, 1),
				BorderSizePixel = 0
			}), "Theme")Make("Corner", Indicator)
			
			local SliderIcon = Create("Frame", SliderBar, {
				Size = UDim2.new(0, 6, 0, 12),
				BackgroundColor3 = Color3.fromRGB(220, 220, 220),
				Position = UDim2.fromScale(0.3, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 0.2
			})Make("Corner", SliderIcon)
			
			local LabelVal = InsertTheme(Create("TextLabel", SliderHolder, {
				Size = UDim2.new(0, 14, 0, 14),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(0, 0, 0.5),
				BackgroundTransparency = 1,
				TextColor3 = Theme["Color Text"],
				Font = Enum.Font.FredokaOne,
				TextSize = 12
			}), "Text")
			
			local UIScale = Create("UIScale", LabelVal)
			
			local BaseMousePos = Create("Frame", SliderBar, {
				Position = UDim2.new(0, 0, 0.5, 0),
				Visible = false
			})
			
			local function UpdateLabel(NewValue)
				local Number = tonumber(NewValue * Increase)
				Number = math.floor(Number * 100) / 100
				
				Default, LabelVal.Text = Number, tostring(Number)
				Funcs:FireCallback(Callback, Default)
			end
			
			local function ControlPos()
				local MousePos = Player:GetMouse()
				local APos = MousePos.X - BaseMousePos.AbsolutePosition.X
				local ConfigureDpiPos = APos / SliderBar.AbsoluteSize.X
				
				SliderIcon.Position = UDim2.new(math.clamp(ConfigureDpiPos, 0, 1), 0, 0.5, 0)
			end
			
			local function UpdateValues()
				Indicator.Size = UDim2.new(SliderIcon.Position.X.Scale, 0, 1, 0)
				local SliderPos = SliderIcon.Position.X.Scale
				local NewValue = math.floor(((SliderPos * Max) / Max) * (Max - Min) + Min)
				UpdateLabel(NewValue)
			end
			
			SliderHolder.MouseButton1Down:Connect(function()
				CreateTween({SliderIcon, "Transparency", 0, 0.3})
				Container.ScrollingEnabled = false
				while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
					ControlPos()
				end
				CreateTween({SliderIcon, "Transparency", 0.2, 0.3})
				Container.ScrollingEnabled = true
				SetFlag(Flag, Default)
			end)
			
			LabelVal:GetPropertyChangedSignal("Text"):Connect(function()
				UIScale.Scale = 0.3
				CreateTween({UIScale, "Scale", 1.2, 0.1})
				CreateTween({LabelVal, "Rotation", math.random(-1, 1) * 5, 0.15, true})
				CreateTween({UIScale, "Scale", 1, 0.2})
				CreateTween({LabelVal, "Rotation", 0, 0.1})
			end)
			
			function SetSlider(NewValue)
				if type(NewValue) ~= "number" then return end
				
				local Min, Max = Min * Increase, Max * Increase
				
				local SliderPos = (NewValue - Min) / (Max - Min)
				
				SetFlag(Flag, NewValue)
				CreateTween({ SliderIcon, "Position", UDim2.fromScale(math.clamp(SliderPos, 0, 1), 0.5), 0.3, true })
			end;SetSlider(Default)
			
			SliderIcon:GetPropertyChangedSignal("Position"):Connect(UpdateValues)UpdateValues()
			
			local Slider = {}
			function Slider:Set(NewVal1, NewVal2)
				if NewVal1 and NewVal2 then
					LabelFunc:SetTitle(NewVal1)
					LabelFunc:SetDesc(NewVal2)
				elseif type(NewVal1) == "string" then
					LabelFunc:SetTitle(NewVal1)
				elseif type(NewVal1) == "function" then
					Callback = NewVal1
				elseif type(NewVal1) == "number" then
					SetSlider(NewVal1)
				end
			end
			function Slider:Callback(...) Funcs:InsertCallback(Callback, ...)(tonumber(Default)) end
			function Slider:Visible(...) Funcs:ToggleVisible(Button, ...) end
			function Slider:Destroy() Button:Destroy() end
			return Slider
		end
		function Tab:AddTextBox(Configs)
			local TName = Configs[1] or Configs.Name or Configs.Title or "Text Box"
			local TDesc = Configs.Desc or Configs.Description or ""
			local TDefault = Configs[2] or Configs.Default or ""
			local TPlaceholderText = Configs[5] or Configs.PlaceholderText or "Input"
			local TClearText = Configs[3] or Configs.ClearText or false
			local Callback = Funcs:GetCallback(Configs, 4)
			
			if type(TDefault) ~= "string" or TDefault:gsub(" ", ""):len() < 1 then
				TDefault = tostring(TDefault)
			end
			
			local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))
			
			local SelectedFrame = InsertTheme(Create("Frame", Button, {
				Size = UDim2.new(0, 150, 0, 18),
				Position = UDim2.new(1, -10, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme["Color Stroke"]
			}), "Stroke")Make("Corner", SelectedFrame, UDim.new(0, 4))
			
			local TextBoxInput = InsertTheme(Create("TextBox", SelectedFrame, {
				Size = UDim2.new(0.85, 0, 0.85, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextScaled = true,
				TextWrapped = true,
				TextColor3 = Theme["Color Text"],
				ClearTextOnFocus = TClearText,
				PlaceholderText = TPlaceholderText,
				Text = ""
			}), "Text")
			
			local Pencil = Create("ImageLabel", SelectedFrame, {
				Size = UDim2.new(0, 12, 0, 12),
				Position = UDim2.new(0, -5, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				Image = "rbxassetid://15637081879",
				BackgroundTransparency = 1
			})
			
			local TextBox = {}
			local function Input()
				local Text = TextBoxInput.Text
				if Text:gsub(" ", ""):len() > 0 then
					if TextBox.OnChanging then Text = TextBox.OnChanging(Text) or Text end
					Funcs:FireCallback(Callback, Text)
					TextBoxInput.Text = Text
				end
			end
			
			function TextBox:Set(Val1)
				Text = Val1
				Funcs:FireCallback(Callback, Val1)
				TextBoxInput.Text = Val1
			end
			TextBox:Set(TDefault)
			
			TextBoxInput.FocusLost:Connect(Input)Input()
			
			TextBoxInput.FocusLost:Connect(function()
				CreateTween({Pencil, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
			end)
			TextBoxInput.Focused:Connect(function()
				CreateTween({Pencil, "ImageColor3", Theme["Color Theme"], 0.2})
			end)
			
			TextBox.OnChanging = false
			function TextBox:Visible(...) Funcs:ToggleVisible(Button, ...) end
			function TextBox:Destroy() Button:Destroy() end
			return TextBox
		end
		function Tab:AddDiscordInvite(Configs)
			local Title = Configs[1] or Configs.Name or Configs.Title or "Discord"
			local Desc = Configs.Desc or Configs.Description or ""
			local Logo = Configs[2] or Configs.Logo or ""
			local Invite = Configs[3] or Configs.Invite or ""
			
			local InviteHolder = Create("Frame", Container, {
				Size = UDim2.new(1, 0, 0, 80),
				Name = "Option",
				BackgroundTransparency = 1
			})
			
			local InviteLabel = Create("TextLabel", InviteHolder, {
				Size = UDim2.new(1, 0, 0, 15),
				Position = UDim2.new(0, 5),
				TextColor3 = Color3.fromRGB(40, 150, 255),
				Font = Enum.Font.GothamBold,
				TextXAlignment = "Left",
				BackgroundTransparency = 1,
				TextSize = 10,
				Text = Invite
			})
			
			local FrameHolder = InsertTheme(Create("Frame", InviteHolder, {
				Size = UDim2.new(1, 0, 0, 65),
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 0, 1),
				BackgroundColor3 = Theme["Color Hub 2"]
			}), "Frame")Make("Corner", FrameHolder)
			
			local ImageLabel = Create("ImageLabel", FrameHolder, {
				Size = UDim2.new(0, 30, 0, 30),
				Position = UDim2.new(0, 7, 0, 7),
				Image = Logo,
				BackgroundTransparency = 1
			})Make("Corner", ImageLabel, UDim.new(0, 4))Make("Stroke", ImageLabel)
			
			local LTitle = InsertTheme(Create("TextLabel", FrameHolder, {
				Size = UDim2.new(1, -52, 0, 15),
				Position = UDim2.new(0, 44, 0, 7),
				Font = Enum.Font.GothamBold,
				TextColor3 = Theme["Color Text"],
				TextXAlignment = "Left",
				BackgroundTransparency = 1,
				TextSize = 10,
				Text = Title
			}), "Text")
			
			local LDesc = InsertTheme(Create("TextLabel", FrameHolder, {
				Size = UDim2.new(1, -52, 0, 0),
				Position = UDim2.new(0, 44, 0, 22),
				TextWrapped = "Y",
				AutomaticSize = "Y",
				Font = Enum.Font.Gotham,
				TextColor3 = Theme["Color Dark Text"],
				TextXAlignment = "Left",
				BackgroundTransparency = 1,
				TextSize = 8,
				Text = Desc
			}), "DarkText")
			
			local JoinButton = Create("TextButton", FrameHolder, {
				Size = UDim2.new(1, -14, 0, 16),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -7),
				Text = "Join",
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = Color3.fromRGB(220, 220, 220),
				BackgroundColor3 = Color3.fromRGB(50, 150, 50)
			})Make("Corner", JoinButton, UDim.new(0, 5))
			
			local ClickDelay
			JoinButton.Activated:Connect(function()
				setclipboard(Invite)
				if ClickDelay then return end
				
				ClickDelay = true
				SetProps(JoinButton, {
					Text = "Copied to Clipboard",
					BackgroundColor3 = Color3.fromRGB(100, 100, 100),
					TextColor3 = Color3.fromRGB(150, 150, 150)
				})task.wait(5)
				SetProps(JoinButton, {
					Text = "Join",
					BackgroundColor3 = Color3.fromRGB(50, 150, 50),
					TextColor3 = Color3.fromRGB(220, 220, 220)
				})ClickDelay = false
			end)
			
			local DiscordInvite = {}
			function DiscordInvite:Destroy() InviteHolder:Destroy() end
			function DiscordInvite:Visible(...) Funcs:ToggleVisible(InviteHolder, ...) end
			return DiscordInvite
		end
		return Tab
	end
	
	CloseButton.Activated:Connect(Window.CloseBtn)
	MinimizeButton.Activated:Connect(Window.MinimizeBtn)
	return Window
end

return redzlib
]])

writefile("Bloxstrap/Main/Functions/GetFFlag.lua", [[
return function(flag, value)
	if type(flag) ~= "string" then return task.spawn(error, "string expected, got "..type(flag)) end
	local FFlag = Bloxstrap.TouchEnabled and flag:gsub("DFInt", ""):gsub("DFFlag", ""):gsub("FFlag", ""):gsub("FInt", ""):gsub("DFString", ""):gsub("FString", "") or flag
	
	if getfflag(FFlag) ~= nil then
		return getfflag(FFlag)
	else
		return task.spawn(error, "FFlag expected, got "..FFlag)
	end
end
]])

writefile("Bloxstrap/Main/Functions/ToggleFFlag.lua", [[
local cloneref = cloneref or function(...) return ... end
local HttpService = cloneref(game.GetService(game, "HttpService"))
return function(flag, value)
	local type = type or typeof
	if type(flag) ~= "string" then return task.spawn(error, "string expected, got "..type(flag)) end
	local FFlag = Bloxstrap.TouchEnabled and flag:gsub("DFInt", ""):gsub("DFFlag", ""):gsub("FFlag", ""):gsub("FInt", ""):gsub("DFString", ""):gsub("FString", "") or flag
	
	if getfflag(FFlag) ~= nil then
		local fflagfile = HttpService:JSONDecode(readfile("Bloxstrap/FFlags.json"))
		fflagfile[flag] = tostring(value)
		writefile("Bloxstrap/FFlags.json", HttpService:JSONEncode(fflagfile))
		return setfflag(FFlag, tostring(value))
	else
		local err = isfile(errorlog) and readfile(errorlog) or "Error while loading FFlags: "
		return writefile(errorlog, err.."\nFFlag expected, got "..FFlag)
	end
end;
]])

writefile("Bloxstrap/Main/Bloxstrap.lua", [[
if not isfile("Bloxstrap/FFlags.json") then writefile("Bloxstrap/FFlags.json", "[]") end
local function loadFunction(func)
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/refs/heads/main/Main/Functions/"..func..".lua"))()
end
local loadFunc = loadFunction
local cloneref = cloneref or function(...) return ... end
local players = cloneref(game:GetService('Players'))
local lplr = cloneref(game:GetService('Players')).LocalPlayer;
local humanoid = lplr.Character:FindFirstChild('Humanoid');
local HttpService = cloneref(game.GetService(game, "HttpService"))
local UserInputService = cloneref(game.GetService(game, "UserInputService"))
local getgenv = getgenv or _G
local files = {};
local writefile = writefile or function(name, src)
	files[name] = src
end
local isfile = isfile or function(file)
	return readfile(file) ~= nil and true or false;
end;

getgenv().Bloxstrap = {}
    Bloxstrap.TouchEnabled = UserInputService.TouchEnabled
    Bloxstrap.Config = setmetatable({
    OofSound = false,
    FPS = 120,
    AntiAliasingQuality = "Automatic",
    LightingTechnology = "Chosen by game",
    TextureQuality = "Automatic",
    DisablePlayerShadows = false,
    DisablePostFX = false,
    DisableTerrainTextures = false,
    GraySky = false,
    Desync = false,
    HitregFix = false,
    customfonttoggle = false,
    customfontroblox = '',
    customtopbar = false,
    CustomFont = '',
    CameraSensitivity = 1,
    CrosshairImage = '',
    TouchUiSize = 1
}, {
    __index = function(s, i)
        s[i] = false
        return s[i]
    end
})
local conf = Bloxstrap.Config
Bloxstrap.canUpdate = false
Bloxstrap.UpdateConfig = function(obj, val)
	if not Bloxstrap.canUpdate then Bloxstrap.Config = conf return end
	Bloxstrap.Config[obj] = val
end
Bloxstrap.SaveConfig = function()
    return writefile("Bloxstrap/Main/Configs/Default.json", HttpService:JSONEncode(Bloxstrap.Config))
end
if isfile("Bloxstrap/Main/Configs/Default.json") then
    Bloxstrap.Config = HttpService:JSONDecode(readfile("Bloxstrap/Main/Configs/Default.json"))
    conf = Bloxstrap.Config
end

local notif = function(a, b)
    cloneref(game:GetService("StarterGui")):SetCore("SendNotification", {
    	Title = 'Bloxstrap', 
    	Text = a,
    	Duration = b or 6
    })
end

Bloxstrap.error = notif
Bloxstrap.success = notif
Bloxstrap.info = notif

Bloxstrap.ToggleFFlag = loadFunc("ToggleFFlag")
Bloxstrap.GetFFlag = loadFunc("GetFFlag")
Bloxstrap.start = function(vis)
	vis = vis or true

	if not vis then
	    setidentity(8);
	    game:GetService('CoreGui')["redz Library V5"].Enabled = false
	end

	getgenv().errorlog = getgenv().errorlog or "Bloxstrap/Logs/crashlog"..HttpService:GenerateGUID(false)..".txt"
	local GUI = loadfile('Bloxstrap/Main/Functions/GuiLibrary.lua')()
	local main = GUI:MakeWindow({
	    Title = "Bloxstrap",
	    SubTitle = "",
	    SaveFolder = "Bloxstrap/Main/Configs"
	})
	main:Visible(vis)

	local Integrations = main:MakeTab({"Integrations", "cross"})
	local FastFlags = main:MakeTab({"Mods", "wrench"})
	local EngineSettings = main:MakeTab({"Engine Settings", "flag"})
	local Appearance = main:MakeTab({"Appearance", "paintbrush-2"})
	Appearance:AddSection('Player')
	local storeeffects = {}
	local isalive = function(v)
	      v = v or lplr
	      local a, b = pcall(function()
	          return v.Character and v.Character.PrimaryPart and v.Character:FindFirstChild('Humanoid') and v.Character.Humanoid.Health > 0
	      end)
	      return a and b or false
	end
	local derendering = Appearance:AddToggle({
	    Name = 'De Rendering',
	    Description = 'Stops effects and player animations from rendering.',
	    Default = Bloxstrap.Config.DeRendering,
	    Callback = function(call)
	        Bloxstrap.UpdateConfig('DeRendering', call)
	        Bloxstrap.ToggleFFlag('FFlagDisablePostFx', call)
	        if call then
	            repeat
	                for i,v in players:GetPlayers() do
	                    if not isalive(lplr) then break end
	                    if v ~= lplr and isalive(v) then
	                        local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
	                        for i,v in v.Character.Humanoid:GetPlayingAnimationTracks() do
	                            v:AdjustSpeed(mag <= 100 and 1 or 0)
	                        end
	                    end
	                end
	                task.wait()
	            until not Bloxstrap.Config.DeRendering
	        end
	    end
	})
	pcall(function()
	local camerascript = require and require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput) or {}
	local old = camerascript.getRotation
	local camsensitivity = Appearance:AddSlider({
	    Name = 'Camera Sensitivity',
	    Min = 1,
	    Max = 7,
	    Increase = 0.1,
	    Default = Bloxstrap.Config.CameraSensitivity,
	    Callback = function(val)
	        Bloxstrap.UpdateConfig('CameraSensitivity', val)
	        camerascript.getRotation = function(...)
	            return old(...) * val
	        end
	    end
	})  
	        end)
	local funnycon
	local guisets = {}
	local guiscale = Appearance:AddToggle({
	    Name = 'GUIScaler',
	    Description = 'Decrease the roblox gui scales',
	    Default = Bloxstrap.Config.GUIScale,
	    Callback = function(call)
	        Bloxstrap.UpdateConfig('GUIScale', call)
	        if call then
	            funnycon = lplr.PlayerGui.ChildAdded: Connect(function(v)
	                if v.Name == 'TouchGui' then return end
	                local oldui = v:FindFirstChildWhichIsA('UIScale', true)
	                if oldui then
	                    table.insert(guisets, {oldscale = oldui.Scale, scaler = oldui})
	                    oldui.Scale = 0.5
	                else
	                    local uiscale = Instance.new('UIScale', v)
	                    uiscale.Scale = 0.7
	                    table.insert(guisets, {oldscale = 9e9, scaler = uiscale})
	                end
	           end)
	            for i,v in lplr.PlayerGui:GetChildren() do
	                if v.Name == 'TouchGui' then continue end
	                local oldui = v:FindFirstChildWhichIsA('UIScale', true)
	                if oldui then
	                    table.insert(guisets, {oldscale = oldui.Scale, scaler = oldui})
	                    oldui.Scale = 0.5
	                else
	                    local uiscale = Instance.new('UIScale', v)
	                    uiscale.Scale = 0.7
	                    table.insert(guisets, {oldscale = 9e9, scaler = uiscale})
	                end
	            end
	            for i,v in game.CoreGui:GetChildren() do
	                local oldui = v:FindFirstChildWhichIsA('UIScale')
	                if oldui then
	                    table.insert(guisets, {oldscale = oldui.Scale, scaler = oldui})
	                    oldui.Scale -= 0.3
	                else
	                    local uiscale = Instance.new('UIScale', v)
	                    uiscale.Scale = 0.7
	                    table.insert(guisets, {oldscale = 9e9, scaler = uiscale})
	                end
	            end
	        else
	            pcall(function() funnycon:Disconnect() funnycon = nil end)
	            for i,v in guisets do
	                if v.oldscale == 9e9 then
	                    v.scaler:Destroy()
	                else
	                    v.scaler.Scale = v.oldscale
	                end
	            end
	            table.clear(guisets)
	        end
	    end
	})

	local touchuuval = 1.2
	local touchuiscale
	local touchui = Appearance:AddToggle({
	    Name = 'TouchGui Size',
	    Description = 'Increases your touchgui size.',
	    Default = Bloxstrap.Config.TouchUI,
	    Callback = function(call)
	        if call then
	            touchuiscale = Instance.new('UIScale', lplr.PlayerGui.TouchGui)
	            touchuiscale.Scale = touchuuval
	        else
	            if touchuiscale then
	                touchuiscale:Destroy()
	                touchuiscale = nil
	            end
	        end
	    end
	})
	Appearance:AddSlider({
	    Name = 'Scale',
	    Min = 1,
	    Max = 2,
	    Increase = 0.1,
	    Callback = function(val)
	        Bloxstrap.UpdateConfig('TouchUiSize', val)
	        touchuuval = val
	        if touchuiscale then
	            touchuiscale.Scale = val
	        end
	    end
	})

	local chosenimage = ''
	local imagelabel
	local screengui = Instance.new('ScreenGui', game.CoreGui)
	screengui.IgnoreGuiInset = true
	local crosshaircons = {}
	local crosshair = Appearance:AddToggle({
	    Name = 'Crosshair',
	    Default = Bloxstrap.Config.Crosshair,
	    Callback = function(call)
	        Bloxstrap.UpdateConfig('Crosshair', call)
	        if call then
	            imagelabel = Instance.new('ImageLabel', screengui)
	            imagelabel.Size = UDim2.new(0, 19, 0, 19)
	            imagelabel.AnchorPoint = Vector2.new(0.5, 0.5)
	            imagelabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	            imagelabel.BackgroundTransparency = 1
	            imagelabel.Image = chosenimage
	            imagelabel.Visible = true
	            repeat
	              task.wait()
	              if not isalive() then continue end
	              local mag = (lplr.Character.Head.Position - workspace.CurrentCamera.CFrame.Position).magnitude
	              imagelabel.Visible = (mag <= 3)
	            until not Bloxstrap.Config.Crosshair
	        else
	            for i,v in crosshaircons do
	                crosshaircons:Disconnect()
	            end
	            table.clear(crosshaircons)
	            if imagelabel then
	                imagelabel:Destroy()
	            end
	        end
	    end
	})
	Appearance:AddDropdown({
	    Name = 'Image',
	    Options = listfiles('Bloxstrap/Images'),
	    Default = Bloxstrap.Config.CrosshairImage,
	    Callback = function(val)
	        Bloxstrap.UpdateConfig('CrosshairImage', val)
	        chosenimage = getcustomasset(val)
	        if imagelabel then
	            imagelabel.Image = chosenimage
	        end
	    end
	})
	Appearance:AddSection('Customizations')
	local gradients = {}
	local fakerobloxbutton
	pcall(function() fakerobloxbutton = Instance.new('TextButton', game:GetService('CoreGui').TopBarApp.UnibarLeftFrame)
	fakerobloxbutton.BorderSizePixel = 0
	fakerobloxbutton.BackgroundTransparency = 0.07
	fakerobloxbutton.Text = ''
	fakerobloxbutton.Name = 'funni'
	fakerobloxbutton.ZIndex = 999
	fakerobloxbutton.BackgroundColor3 = Color3.new()
	fakerobloxbutton.Size = UDim2.new(0, 44, 0, 44)
	fakerobloxbutton.Position = UDim2.new(0, -52, 0, 0)
	fakerobloxbutton.Visible = false
	fakerobloxbutton.MouseButton1Click:Connect(function()
	    firesignal(game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.Activated)
	end)

	local imagelabel = Instance.new('ImageLabel', fakerobloxbutton)
	imagelabel.Size = UDim2.new(0, 22, 0, 22)
	imagelabel.Position = UDim2.new(0.25, 0, 0.25, 0)
	imagelabel.BackgroundTransparency = 1
	imagelabel.Image = getcustomasset('Bloxstrap/icon.png')
	imagelabel.ImageColor3 = Color3.new(1, 1, 1)

	Instance.new('UICorner', fakerobloxbutton).CornerRadius = UDim.new(1, 0) end)


	local customtopbar = Appearance:AddToggle({
	    Name = 'Bloxstrap Topbars',
	    Description = 'Gives you a cool unique topbar.',
	    Default = Bloxstrap.Config.customtopbar,
	    Callback = function(call)
	        game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Visible = not call
	        fakerobloxbutton.Visible = call 
	        Bloxstrap.UpdateConfig('customtopbar', call)
	        local topbarinstances = {game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat.IntegrationIconFrame.IntegrationIcon, game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].nine_dot.IntegrationIconFrame.IntegrationIcon.Overflow, game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].nine_dot.IntegrationIconFrame.IntegrationIcon.Close, imagelabel}
	        if call then
	            woahwoah = game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"].ChildAdded:Connect(function(v)
	                grad = Instance.new('UIGradient', v)
	                grad.Rotation = -60
	                grad.Color = ColorSequence.new({
	                    ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
	                    ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
	                })
	                v.Text.TextColor3 = Color3.new()
	                v.Text.TextTruncate = 'None'
	                table.insert(gradients, grad)
	            end)
	            if game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"]:FindFirstChild('Badge') then
	                grad = Instance.new('UIGradient', game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"]:FindFirstChild('Badge'))
	                game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"]:FindFirstChild('Badge').Text.TextTruncate = 'None'
	                game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"]:FindFirstChild('Badge').Text.TextColor3 = Color3.new()
	                grad.Rotation = -60
	                grad.Color = ColorSequence.new({
	                    ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
	                    ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
	                })
	                table.insert(gradients, grad)
	            end
	            for i,v in topbarinstances do
	                grad = Instance.new('UIGradient', v)
	                grad.Rotation = 60
	                grad.Color = ColorSequence.new({
	                    ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
	                    ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
	                })
	                table.insert(gradients, grad)
	            end
	        else
	            pcall(function() woahwoah:Disconnect() end)
	            for i,v in gradients do pcall(function() v:Destroy() end) end
	        end
	    end
	})

	local rotatinghotbar = Appearance:AddToggle({
	    Name = 'Spin Hotbar',
	    Description = 'Spins the roblox logo around for whatever reason.',
	    Default = Bloxstrap.Config.RotatingHotbar,
	    Callback = function(call)
	        Bloxstrap.UpdateConfig('RotatingHotbar', call)
	        if call then
	            repeat
	                game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon.Rotation += 1.5
	                imagelabel.Rotation += 1.5
	                task.wait(0)
	            until not Bloxstrap.Config.RotatingHotbar
	        else
	            game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon.Rotation = 0
	            imagelabel.Rotation = 0
	        end
	    end
	})

	local ActivityTracking = Integrations:AddSection("Activity Tracking")

	local FFlagEditor = FastFlags:AddSection("Fast Flag Editor")
	local usefilepath = false
	local FFETextbox = FastFlags:AddTextBox({
	    Name = "Paste Fast Flags (json)",
	    Description = "Use with caution. Misusing this can lead to instability or unexpected things happening.",
	    Default = readfile('Bloxstrap/FFlags.json'),
	    Callback = function(call)
	        writefile("Bloxstrap/FFlags.json", call)
	        local fflags = HttpService:JSONDecode(call:gsub('"True"', "true"):gsub('"False"', "false"))
	        for i,v in fflags do
	            Bloxstrap.ToggleFFlag(i,v)
	        end
	    end
	})

	local Presets = FastFlags:AddSection("Presets: Unbannable")

	local GraySky = FastFlags:AddToggle({
	Name = "Gray sky",
	Description = "Turns the sky gray. (Requires rejoin)",
	Default = Bloxstrap.Config.GraySky,
	Callback = function(callback)
	    Bloxstrap.UpdateConfig("GraySky", callback)
	    Bloxstrap.ToggleFFlag("FFlagDebugSkyGray", callback)
	end
	})

	local updatedfonts = {};
	local font = 'Arimo'
	local fonttdropdown
	local uriekfqjkfjqekf = false
	local currentcustomfont = nil
	local funnycon84
	local usecustomfont
	local fontchanger = FastFlags:AddToggle({
	    Name = 'Change Game Fonts',
	    Description = 'Changes The Game font to the one you chose',
	    Callback = function(call)
	    uriekfqjkfjqekf = call
	    Bloxstrap.UpdateConfig('customfonttoggle', call);
	    if call then
	        print(currentcustomfont)
	        funnycon84 = game.DescendantAdded:Connect(function(v)
	            if v.ClassName and (v.ClassName == 'TextLabel' or v.ClassName == 'TextButton' or v.ClassName == 'TextBox') and uriekfqjkfjqekf and font ~= nil then
	                local currfont = font
	                table.insert(updatedfonts, {inst = v, font = tostring(v.Font):split('.')[3], connection = v:GetPropertyChangedSignal('Font'):Connect(function()
	                if currentcustomfont then
	                    v.FontFace = currentcustomfont
	                else
	                    v.Font = Enum.Font[currfont]
	                end
	                end)})
	                if currentcustomfont then
	                    v.FontFace = currentcustomfont
	                else
	                    v.Font = Enum.Font[currfont]
	                end
	            end
	        end)
	        for i,v in game:GetDescendants() do
	            if v.ClassName and (v.ClassName == 'TextLabel' or v.ClassName == 'TextButton' or v.ClassName == 'TextBox') and font ~= nil then
	                local currfont = font
	                pcall(function() table.insert(updatedfonts, {inst = v, font = tostring(v.Font):split('.')[3], connection = v:GetPropertyChangedSignal('Font'):Connect(function()
	                    if currentcustomfont then
	                        v.FontFace = currentcustomfont
	                    else
	                        v.Font = Enum.Font[currfont]
	                    end
	                end)}) end)
	                if currentcustomfont then
	                    v.FontFace = currentcustomfont
	                else
	                    v.Font = Enum.Font[currfont]
	                end
	            end;
	        end
	    else
	            pcall(function() funnycon84:Disconnect() end)
	            for i,v in updatedfonts do
	                v.connection:Disconnect()
	                v.connection = nil
	                v.inst.Font = Enum.Font[v.font]
	            end;
	            table.clear(updatedfonts);
	        end
	    end
	})
	local list = {}
	for i,v in Enum.Font:GetEnumItems() do
	    table.insert(list, tostring(v):split('.')[3]);
	end
	fonttdropdown = FastFlags:AddDropdown({
	    Name = "Preset-Fonts",
	    Description = "",
	    Options = list,
	    Default = Bloxstrap.Config.customfontroblox or '',
	    Callback = function(qweqweq)
	        Bloxstrap.UpdateConfig('customfontroblox', qweqweq);
	    font = qweqweq
	    end
	})
	local fontlists = {'none'}
	for i,v in listfiles('Bloxstrap/Main/Fonts') do
	    if v:find('.ttf') then
	        table.insert(fontlists, v)
	    end
	end
	usecustomfont = FastFlags:AddDropdown({
	    Name = 'Custom Fonts',
	    Options = fontlists,
	    Description = 'All fonts that are inside "Bloxstrap/Main/Fonts" folder.',
	    Default = Bloxstrap.Config.CustomFont,
	    Callback = function(val)
	        local json = val:gsub('.ttf', '.json')
	        if val == 'none' then
	            currentcustomfont = nil
	            return Bloxstrap.UpdateConfig('CustomFont', '')
	        end
	        Bloxstrap.UpdateConfig('CustomFont', val)
	        if not isfile(json) then
	            writefile(json, HttpService:JSONEncode({name = 'font', faces = {
	                {
	                    name = 'Regular',
	                    weight = 600,
	                    style = 'normal',
	                    assetId = getcustomasset(val)
	                }
	            }}))
	        end
	          currentcustomfont = Font.new(getcustomasset(json), Enum.FontWeight.Regular)
	          if Bloxstrap.Config.customfonttoggle then
	            fontchanger:Toggle(false)
	            fontchanger:Toggle(true)
	          end
	    end
	})

	fontchanger:Toggle(Bloxstrap.Config.customfonttoggle)

	local Presets = FastFlags:AddSection("Presets: Bannable")

	local Desync = FastFlags:AddToggle({
	    Name = "Desync",
	    Description = "Lags your character behind on other screens.",
	    Default = Bloxstrap.Config.Desync,
	    Callback = function(callback)
	        Bloxstrap.UpdateConfig("Desync", callback)
	        Bloxstrap.ToggleFFlag("DFIntS2PhysicsSenderRate", callback and 38000 or 15)
	    end
	})

	local HitregFix = FastFlags:AddToggle({
	    Name = "Hitreg Fix",
	    Description = "Makes your hitreg in most games better. (reset fflags to remove)",
	    Default = Bloxstrap.Config.HitregFix,
	    Callback = function(callback)
	        Bloxstrap.UpdateConfig("HitregFix", callback)
	        local FFlags = [[
	        { 
	          "DFIntCodecMaxIncomingPackets": "100",
	          "DFIntCodecMaxOutgoingFrames": "10000",
	          "DFIntLargePacketQueueSizeCutoffMB": "1000",
	          "DFIntMaxProcessPacketsJobScaling": "10000",
	          "DFIntMaxProcessPacketsStepsAccumulated": "0",
	          "DFIntMaxProcessPacketsStepsPerCyclic": "5000",
	          "DFIntMegaReplicatorNetworkQualityProcessorUnit": "10",
	          "DFIntNetworkLatencyTolerance": "1",
	          "DFIntNetworkPrediction": "120",
	          "DFIntOptimizePingThreshold": "50",
	          "DFIntPlayerNetworkUpdateQueueSize": "20",
	          "DFIntPlayerNetworkUpdateRate": "60",
	          "DFIntRaknetBandwidthInfluxHundredthsPercentageV2": "10000",
	          "DFIntRaknetBandwidthPingSendEveryXSeconds": "1",
	          "DFIntRakNetLoopMs": "1",
	          "DFIntRakNetResendRttMultiple": "1",
	          "DFIntServerPhysicsUpdateRate": "60",
	          "DFIntServerTickRate": "60",
	          "DFIntWaitOnRecvFromLoopEndedMS": "100",
	          "DFIntWaitOnUpdateNetworkLoopEndedMS": "100",
	          "FFlagOptimizeNetwork": "true",
	          "FFlagOptimizeNetworkRouting": "true",
	          "FFlagOptimizeNetworkTransport": "true",
	          "FFlagOptimizeServerTickRate": "true",
	          "FIntRakNetResendBufferArrayLength": "128"
	        }]]
	        FFlags = HttpService:JSONDecode(FFlags:gsub('"True"', "true"):gsub('"False"', "false"))
	        for i, v in FFlags do
	        Bloxstrap.ToggleFFlag(i, v)
	        end
	    end
	})

	local Presets = EngineSettings:AddSection("Presets")

	local deathsoundConnection;
	local enabled
	local notified = false
	local addcon = function()
	    if getcustomasset == nil  then
	        return
	    end
	    if deathsoundConnection then
	        deathsoundConnection:Disconnect()
	        deathsoundConnection = nil
	    end
	    if not lplr.Character then
	        repeat task.wait() until lplr.Character
	    end
	    if not lplr.Character:FindFirstChild('Humanoid') then
	        repeat task.wait() until lplr.Character:FindFirstChild('Humanoid')
	    end
	    repeat task.wait() until humanoid.Parent ~= nil
	    deathsoundConnection = humanoid.HealthChanged:Connect(function()
	        if humanoid.Health <= 0 then
	            game:GetService("Players").LocalPlayer.PlayerScripts.RbxCharacterSounds.Enabled = false
	            local sound = Instance.new("Sound", workspace)
	            sound.SoundId = isfile('Bloxstrap/deathsound.mp3') and getcustomasset('Bloxstrap/deathsound.mp3') or isfile('Bloxstrap/oofsound.mp3') and getcustomasset('Bloxstrap/oofsound.mp3')
	            sound.PlayOnRemove = true 
	            sound.Volume = 0.5
	            sound:Destroy()
	        end
	    end)
	end
	local olddeathsound = EngineSettings:AddToggle({
	    Name = isfile('Bloxstrap/deathsound.mp3') and 'Use custom death sound' or 'Use old death sound',
	    Description = isfile('Bloxstrap/deathsound.mp3') and 'Gives you a custom death sound.' or "Bring back the classic 'oof' death sound.",
	    Default = Bloxstrap.Config.OofSound,
	    Callback = function(call)
	    Bloxstrap.UpdateConfig("OofSound", call)
	        if call then
	            addcon()
	            lplr.CharacterAdded:Connect(addcon)
	        else
	            deathsoundConnection:Disconnect()
	            deathsoundConnection = nil
	        end
	    end
	})

	lplr.CharacterAdded:Connect(function()
	    if not lplr.Character then
	        repeat task.wait() until lplr.Character
	    end
	    if not lplr.Character:FindFirstChild('Humanoid') then
	        repeat task.wait() until isalive()
	    end
	    humanoid = lplr.Character:FindFirstChild('Humanoid')
	    game:GetService("Players").LocalPlayer.PlayerScripts.RbxCharacterSounds.Enabled = true
	end)

	local defaultMSAA = 0
	local AntiAliasingQuality = EngineSettings:AddDropdown({
	    Name = "Anti-aliasing quality (MSAA)",
	    Description = "",
	    Options = {"Automatic", "1x", "2x", "4x"},
	    Default = Bloxstrap.Config.AntiAliasingQuality,
	    Callback = function(msaa)
	        if not UserInputService.TouchEnabled then return end
	        Bloxstrap.UpdateConfig("AntiAliasingQuality", msaa)
	        Bloxstrap.ToggleFFlag("FIntDebugForceMSAASamples", msaa:find("x") and msaa:gsub("x", "") or defaultMSAA)
	    end
	})

	local shadowIntense = 1
	local DisablePlayerShadows = EngineSettings:AddToggle({
	    Name = "Disable player shadows",
	    Description = "",
	    Default = Bloxstrap.Config.DisablePlayerShadows,
	    Callback = function(callback)
	        Bloxstrap.UpdateConfig("DisablePlayerShadows", callback)
	        Bloxstrap.ToggleFFlag("FIntRenderShadowIntensity", callback and 0 or shadowIntense)
	    end
	})

	local disableppfx = false
	local DisablePostFX = EngineSettings:AddToggle({
	    Name = "Disable post-processing effects",
	    Description = "",
	    Default = Bloxstrap.Config.DisablePostFX,
	    Callback = function(callback)
	        Bloxstrap.UpdateConfig("DisablePostFX", callback)
	        Bloxstrap.ToggleFFlag("FFlagDisablePostFx", callback and true or disableppfx)
	    end
	})

	local disableterraintex = Bloxstrap.GetFFlag("FIntTerrainArraySliceSize")
	local DisableTerrainTextures = EngineSettings:AddToggle({
	    Name = "Disable terrain textures",
	    Description = "",
	    Default = Bloxstrap.Config.DisableTerrainTextures,
	    Callback = function(callback)
	        Bloxstrap.UpdateConfig("DisableTerrainTextures", callback)
	        Bloxstrap.ToggleFFlag("FIntTerrainArraySliceSize", callback and 0 or disableterraintex)
	    end
	})

	local origValue = Bloxstrap.GetFFlag("DFIntTaskSchedulerTargetFps")
	local FramerateLimit = EngineSettings:AddTextBox({
	    Name = "Framerate limit",
	    Description = "Set to 0 if you want to use Roblox's native framerate unlocker.",
	    Default = Bloxstrap.Config.FPS,
	    Callback = function(fps)
	        if fps == nil then return end;
	        if type(fps) == "string" then fps = tonumber(fps) end;
	        Bloxstrap.UpdateConfig("FPS", fps);
	        Bloxstrap.ToggleFFlag('FFlagTaskSchedulerLimitTargetFpsTo2402', fps and fps >= 70)
	        if fps > 0 then
	            setfpscap(fps);
	            Bloxstrap.ToggleFFlag("DFIntTaskSchedulerTargetFps", fps);
	        else
	            setfpscap(9e9);
	            Bloxstrap.ToggleFFlag("DFIntTaskSchedulerTargetFps", origValue);
	        end;
	    end;
	});
	EngineSettings:AddToggle({
	    Name = 'Display FPS',
	    Default = Bloxstrap.Config.DisplayFPS,
	    Callback = function(call)
	        Bloxstrap.UpdateConfig('DisplayFPS', call)
	        Bloxstrap.ToggleFFlag('FFlagDebugDisplayFPS', call);
	    end
	})

	local function changeLighting(lighting)
	    sethiddenproperty(game.Lighting, "Technology", lighting:find("Voxel") and "Voxel" or lighting:find("Shadow Map") and "ShadowMap" or "Future")
	    if not UserInputService.TouchEnabled then
	        str = lighting:lower()
	        if str:find("voxel") then
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", true)
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", false)
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", false)
	        return
	        elseif str:find("shadow map") then
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", false)
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", true)
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", false)
	        return
	        elseif str:find("future") then
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", false)
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", false)
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", true)
	        return
	        elseif str:find("chosen") then
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", false)
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", false)
	        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", false)
	        return
	        end
	    end
	end

	local PreferredLightingTechnology = EngineSettings:AddDropdown({
	    Name = "Preferred lighting technology",
	    Description = "Chosen one will be force enabled in all games.",
	    Options = {"Chosen by game", "Voxel (Phase 1)", "Shadow Map (Phase 2)", "Future (Phase 3)"},
	    Default = Bloxstrap.Config.LightingTechnology,
	    Callback = function(light)
	        Bloxstrap.UpdateConfig("LightingTechnology", light)
	        pcall(changeLighting, light)
	    end
	})

	local textureQual = 3
	local function changeTextureQuality(level)
	    str = level:lower()
	    if str:find("lowest") then
	        Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
	        Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 0)
	        Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 2)
	        return
	    elseif str:find("low") then
	        Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
	        Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 0)
	        Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
	        return
	    elseif str:find("medium") then
	        Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
	        Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 1)
	        Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
	        return
	    elseif str:find("high") then
	        Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
	        Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 2)
	        Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
	        return
	    elseif str:find("highest") then
	        Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
	        Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 3)
	        Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
	        return
	    end
	    Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", false)
	    Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", textureQual)
	    Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
	    return
	end

	local TextureQuality = EngineSettings:AddDropdown({
	    Name = "Texture quality",
	    Description = "",
	    Options = {"Automatic", "Lowest (Requires rejoin)", "Low", "Medium", "High", "Highest"},
	    Default = Bloxstrap.Config.TextureQuality,
	    Callback = function(level)
	        Bloxstrap.UpdateConfig("TextureQuality", level)
	        changeTextureQuality(level)
	    end
	})

	Bloxstrap.canUpdate = true
	pcall(function()
	local button = Instance.new('TextButton', game:GetService('CoreGui').TopBarApp.UnibarLeftFrame)
	button.BorderSizePixel = 0
	button.BackgroundTransparency = 0.07
	button.Text = ''
	button.BackgroundColor3 = Color3.new()
	button.Size = UDim2.new(0, 44, 0, 44)
	button.Position = UDim2.new(0, 103, 0, 0)

	local imagelabel = Instance.new('ImageLabel', button)
	imagelabel.Size = UDim2.new(0, 22, 0, 22)
	imagelabel.Position = UDim2.new(0.25, 0, 0.25, 0)
	imagelabel.BackgroundTransparency = 1
	imagelabel.Image = getcustomasset('Bloxstrap/icon.png')
	imagelabel.ImageColor3 = Color3.new(1, 1, 1)

	local grad = Instance.new('UIGradient', imagelabel)
	grad.Rotation = 60
	grad.Color = ColorSequence.new({
	    ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
	    ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
	})
	grad.Enabled = game:GetService('CoreGui')["redz Library V5"].Enabled

	Instance.new('UICorner', button).CornerRadius = UDim.new(1, 0)
	Bloxstrap.Visible = function(callback)
	    button.Visible = callback
	end
	button.MouseButton1Click:Connect(function()
	    game:GetService('CoreGui')["redz Library V5"].Enabled = not grad.Enabled
	    grad.Enabled = not grad.Enabled
	end) end)
end
return Bloxstrap
]])

writefile("Bloxstrap/FFlags.json", [[
{"DFIntMaxProcessPacketsJobScaling":"10000","DFIntPlayerNetworkUpdateRate":"60","DFIntNetworkLatencyTolerance":"1","QueryServerLocation":"true","DFIntServerPhysicsUpdateRate":"60","FFlagOptimizeServerTickRate":"true","DFIntServerTickRate":"60","DisablePlayerShadows":"true","TextureQuality":"Highest","DFIntMaxProcessPacketsStepsPerCyclic":"5000","DFIntWaitOnRecvFromLoopEndedMS":"100","FFlagDebugSkyGray":"true","DFIntRaknetBandwidthPingSendEveryXSeconds":"1","DFFlagDebugRenderForceTechnologyVoxel":"false","DFIntMegaReplicatorNetworkQualityProcessorUnit":"10","DFIntRakNetResendRttMultiple":"1","DFFlagDebugRenderForceFutureIsBrightPhase3":"true","DFIntTextureQualityOverride":"2","LightingTechnology":"Future (Phase 3)","FFlagDisablePostFx":"true","DFFlagTextureQualityOverrideEnabled":"true","FIntRakNetResendBufferArrayLength":"128","DFIntCodecMaxOutgoingFrames":"10000","DisableTerrainTextures":"true","DFIntLargePacketQueueSizeCutoffMB":"1000","FFlagOptimizeNetworkTransport":"true","DisablePostFX":"true","FFlagOptimizeNetworkRouting":"true","DFIntTaskSchedulerTargetFps":"120","DFFlagDebugRenderForceFutureIsBrightPhase2":"false","DFIntRaknetBandwidthInfluxHundredthsPercentageV2":"10000","FFlagOptimizeNetwork":"true","GraySky":"true","DFIntPlayerNetworkUpdateQueueSize":"20","DFIntOptimizePingThreshold":"50","FPS":"120","FIntTerrainArraySliceSize":"0","DFIntWaitOnUpdateNetworkLoopEndedMS":"100","FIntRenderShadowIntensity":"0","DFIntMaxProcessPacketsStepsAccumulated":"0","DFIntS2PhysicsSenderRate":"15","DFIntRakNetLoopMs":"1","FIntDebugTextureManagerSkipMips":"0","DFIntNetworkPrediction":"120","DFIntCodecMaxIncomingPackets":"100","AntiAliasingQuality":"4x"}
]])

writefile("Bloxstrap/Main/Configs/Default.json", [[
{"DFIntMaxProcessPacketsJobScaling":"10000","DFIntPlayerNetworkUpdateRate":"60","DFIntNetworkLatencyTolerance":"1","QueryServerLocation":true,"DFIntServerPhysicsUpdateRate":"60","FFlagOptimizeServerTickRate":"true","DFIntServerTickRate":"60","DisablePlayerShadows":"true","TextureQuality":"Highest","DFIntMaxProcessPacketsStepsPerCyclic":"5000","DFIntWaitOnRecvFromLoopEndedMS":"100","FFlagDebugSkyGray":"true","DFIntRaknetBandwidthPingSendEveryXSeconds":"1","DFFlagDebugRenderForceTechnologyVoxel":"false","DFIntMegaReplicatorNetworkQualityProcessorUnit":"10","DFIntRakNetResendRttMultiple":"1","AntiAliasingQuality":"4x","DFIntTextureQualityOverride":"2","FFlagDisablePostFx":"true","LightingTechnology":"Future (Phase 3)","FIntRakNetResendBufferArrayLength":"128","DFIntNetworkPrediction":"120","DFIntCodecMaxOutgoingFrames":"10000","DFIntRakNetLoopMs":"1","DFIntS2PhysicsSenderRate":"15","FFlagOptimizeNetworkTransport":"true","DFIntRaknetBandwidthInfluxHundredthsPercentageV2":"10000","FFlagOptimizeNetworkRouting":"true","DFIntTaskSchedulerTargetFps":"120","DFFlagDebugRenderForceFutureIsBrightPhase2":"false","DisablePostFX":"true","FIntRenderShadowIntensity":"0","DFIntPlayerNetworkUpdateQueueSize":"20","GraySky":"true","DFIntOptimizePingThreshold":"50","FPS":"120","FIntTerrainArraySliceSize":"0","DFIntWaitOnUpdateNetworkLoopEndedMS":"100","FFlagOptimizeNetwork":"true","DFIntMaxProcessPacketsStepsAccumulated":"0","DFIntLargePacketQueueSizeCutoffMB":"1000","DisableTerrainTextures":"true","FIntDebugTextureManagerSkipMips":"0","DFFlagTextureQualityOverrideEnabled":"true","DFIntCodecMaxIncomingPackets":"100","DFFlagDebugRenderForceFutureIsBrightPhase3":"true"}
]])

writefile("Bloxstrap/Main/Configs/PerformanceConfig.json", [[
[]
]])

writefile("Bloxstrap/icon.png", string.char(137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,1,0,0,0,1,8,6,0,0,0,31,21,196,137,0,0,0,4,103,65,77,65,0,0,177,143,11,252,97,5,0,0,0,9,112,72,89,115,0,0,14,195,0,0,14,195,1,199,111,168,100,0,0,0,10,73,68,65,84,8,153,99,96,0,0,0,2,0,1,226,33,156,51,0,0,0,0,73,69,78,68,174,66,96,130))

writefile("Bloxstrap/oofsound.mp3", "")

print("Bloxstrap 离线版安装完成！正在启动...")

local Bloxstrap = loadfile('Bloxstrap/Main/Bloxstrap.lua')()
Bloxstrap.start(true)
Bloxstrap.Visible(true)

print("Bloxstrap 已启动！")