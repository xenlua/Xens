-- Will be used later for getting flattened globals
local ImportGlobals

-- Object tree structure
local ObjectTree = {
    {1, 2, {"enhanced-ui-library"}, {
        {2, 2, {"init"}},
        {3, 1, {"components"}, {
            {4, 2, {"dialog"}},
            {5, 2, {"element"}},
            {6, 2, {"notif"}},
            {7, 2, {"section"}},
            {8, 2, {"tab"}},
        }},
        {9, 1, {"elements"}, {
            {10, 2, {"init"}},
            {11, 2, {"bind"}},
            {12, 2, {"buttons"}},
            {13, 2, {"colorpicker"}},
            {14, 2, {"dropdown"}},
            {15, 2, {"paragraph"}},
            {16, 2, {"slider"}},
            {17, 2, {"textbox"}},
            {18, 2, {"toggle"}},
        }},
        {19, 2, {"tools"}},
    }}
}

-- Holds direct closure data
local ClosureBindings = {
    [2] = function()local wax,script,require=ImportGlobals(2)local ImportGlobals return (function(...)wait(1)

-- ===== ENHANCED SINGLETON SYSTEM =====
local GLOBAL_LIBRARY_INSTANCE = nil
local CLEANUP_CONNECTIONS = {}

-- Function to cleanup any existing instance
local function CleanupExistingInstance()
    if GLOBAL_LIBRARY_INSTANCE then
        pcall(function()
            GLOBAL_LIBRARY_INSTANCE:Destroy()
        end)
        GLOBAL_LIBRARY_INSTANCE = nil
    end
    
    -- Clear any remaining cleanup connections
    for i = #CLEANUP_CONNECTIONS, 1, -1 do
        local connection = CLEANUP_CONNECTIONS[i]
        if connection and connection.Connected then
            pcall(function()
                connection:Disconnect()
            end)
        end
        CLEANUP_CONNECTIONS[i] = nil
    end
end

-- ===== UTILITY FUNCTIONS =====
function generateRandomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:',.<>?/`~"
    local randomString = ""
    math.randomseed(os.time()) -- Seed the random generator

    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        randomString = randomString .. charset:sub(randomIndex, randomIndex)
    end

    return randomString
end

-- ===== SAFE SHADOW CREATION FUNCTION =====
local function createShadow(parent, offset, radius, transparency)
    -- Safe shadow creation that doesn't use DropShadow
    local shadowFrame = Instance.new("Frame")
    shadowFrame.Name = "ShadowFrame"
    shadowFrame.Size = UDim2.new(1, radius * 2, 1, radius * 2)
    shadowFrame.Position = UDim2.new(0, -radius + offset.X, 0, -radius + offset.Y)
    shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadowFrame.BackgroundTransparency = transparency or 0.7
    shadowFrame.BorderSizePixel = 0
    shadowFrame.ZIndex = (parent.ZIndex or 1) - 1
    shadowFrame.Parent = parent
    
    -- Add corner radius to match parent
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 8)
    shadowCorner.Parent = shadowFrame
    
    return shadowFrame
end

-- ===== SERVICE IMPORTS =====
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ===== MODULE IMPORTS =====
local ElementsTable = require(script.elements.init)
local Tools = require(script.tools)
local Components = script.components

-- ===== TOOL FUNCTIONS =====
local Create = Tools.Create
local AddConnection = Tools.AddConnection
local AddScrollAnim = Tools.AddScrollAnim
local isMobile = Tools.isMobile()
local CurrentThemeProps = Tools.GetPropsCurrentTheme()

-- ===== ENHANCED DRAGGABLE FUNCTIONALITY =====
local function MakeDraggable(DragPoint, Main)
	local Dragging, DragInput, MousePos, FramePos = false
	local dragConnection, moveConnection
	
	local connection1 = AddConnection(DragPoint.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			MousePos = Input.Position
			FramePos = Main.Position

			dragConnection = AddConnection(Input.Changed, function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
					if dragConnection then
						dragConnection:Disconnect()
						dragConnection = nil
					end
					if moveConnection then
						moveConnection:Disconnect()
						moveConnection = nil
					end
				end
			end)
		end
	end)
	
	local connection2 = AddConnection(DragPoint.InputChanged, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = Input
		end
	end)
	
	moveConnection = AddConnection(UserInputService.InputChanged, function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Dragging then
			local Delta = Input.Position - MousePos
			Main.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
		end
	end)
	
	-- Store connections for cleanup
	table.insert(CLEANUP_CONNECTIONS, connection1)
	table.insert(CLEANUP_CONNECTIONS, connection2)
	table.insert(CLEANUP_CONNECTIONS, moveConnection)
end

-- ===== MAIN LIBRARY =====
local Library = {
	Window = nil,
	Flags = {},
	Signals = {},
	ToggleBind = nil,
	Version = "3.0.0", -- Enhanced version
	Author = "Enhanced Team",
	ActiveConnections = {}, -- Track all active connections
	RunningTasks = {}, -- Track all running tasks
	IsDestroyed = false,
}

-- ===== GUI CREATION =====
local GUI = Create("ScreenGui", {
	Name = generateRandomString(16),
	Parent = gethui(),
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

-- Initialize notification system
require(Components.notif):Init(GUI)

-- ===== ENHANCED LIBRARY METHODS =====
function Library:SetTheme(themeName)
	if self.IsDestroyed then return end
	Tools.SetTheme(themeName)
end

function Library:GetTheme()
	if self.IsDestroyed then return end
	return Tools.GetPropsCurrentTheme()
end

function Library:AddTheme(themeName, themeProps)
	if self.IsDestroyed then return end
	Tools.AddTheme(themeName, themeProps)
end

function Library:IsRunning()
	return not self.IsDestroyed and GUI and GUI.Parent == gethui()
end

-- ===== ENHANCED CLEANUP SYSTEM =====
function Library:StopAllTasks()
	-- Stop all running tasks
	for i, task in pairs(self.RunningTasks) do
		if task and typeof(task) == "thread" then
			pcall(function()
				task:Cancel()
			end)
		end
		self.RunningTasks[i] = nil
	end
	
	-- Clear all flags to stop any running loops
	for flagName, flag in pairs(self.Flags) do
		if flag and typeof(flag) == "table" and flag.Value ~= nil then
			if typeof(flag.Value) == "boolean" then
				flag.Value = false
			end
		end
	end
	
	-- Wait a moment for loops to stop
	task.wait(0.1)
end

function Library:Destroy()
	if self.IsDestroyed then 
		return
	end
	
	print("[Enhanced UI] Starting cleanup process...")
	
	-- Mark as destroyed first to prevent any new operations
	self.IsDestroyed = true
	
	-- First stop all running tasks and loops
	self:StopAllTasks()
	
	-- Disconnect all connections from Tools
	for i, Connection in pairs(Tools.Signals) do
		if Connection and Connection.Connected then
			pcall(function()
				Connection:Disconnect()
			end)
		end
	end
	
	-- Disconnect all active connections
	for i, Connection in pairs(self.ActiveConnections) do
		if Connection and Connection.Connected then
			pcall(function()
				Connection:Disconnect()
			end)
		end
	end
	
	-- Disconnect cleanup connections
	for i, Connection in pairs(CLEANUP_CONNECTIONS) do
		if Connection and Connection.Connected then
			pcall(function()
				Connection:Disconnect()
			end)
		end
	end
	
	-- Clear all tables
	pcall(function() table.clear(Tools.Signals) end)
	pcall(function() table.clear(self.ActiveConnections) end)
	pcall(function() table.clear(self.Flags) end)
	pcall(function() table.clear(self.Signals) end)
	pcall(function() table.clear(self.RunningTasks) end)
	pcall(function() table.clear(CLEANUP_CONNECTIONS) end)
	
	-- Destroy GUI
	if GUI then
		pcall(function()
			GUI:Destroy()
		end)
		GUI = nil
	end
	
	-- Clear window reference
	self.Window = nil
	self.LoadedWindow = nil
	
	-- Final cleanup
	pcall(function()
		Tools.Cleanup()
	end)
	
	-- Clear global instance reference
	GLOBAL_LIBRARY_INSTANCE = nil
	
	print("[Enhanced UI] Cleanup completed successfully!")
end

-- Enhanced background cleanup task
task.spawn(function()
	while Library:IsRunning() do
		task.wait(1)
	end
	if not Library.IsDestroyed then
		Library:Destroy()
	end
end)

-- ===== ELEMENTS SYSTEM =====
local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
	return Elements[Key](...)
end

-- Dynamic element registration
for _, ElementComponent in ipairs(ElementsTable) do
	assert(ElementComponent.__type, "ElementComponent missing __type")
	assert(type(ElementComponent.New) == "function", "ElementComponent missing New function")

	Elements["Add" .. ElementComponent.__type] = function(self, Idx, Config)
		if Library.IsDestroyed then return end
		
		ElementComponent.Container = self.Container
		ElementComponent.Type = self.Type
		ElementComponent.ScrollFrame = self.ScrollFrame
		ElementComponent.Library = Library

		return ElementComponent:New(Idx, Config)
	end
end

Library.Elements = Elements

-- ===== ENHANCED CALLBACK SYSTEM =====
function Library:Callback(Callback, ...)
	if self.IsDestroyed then return end
	
	local success, result = pcall(Callback, ...)

	if success then
		return result
	else
		local errorMessage = tostring(result)
		local errorLine = string.match(errorMessage, ":(%d+):")
		local errorInfo = `Enhanced Callback execution failed.\n`
		errorInfo = errorInfo .. `Error: {errorMessage}\n`

		if errorLine then
			errorInfo = errorInfo .. `Occurred on line: {errorLine}\n`
		end

		errorInfo = errorInfo .. `Possible Fix: Please check the function implementation for potential issues such as invalid arguments or logic errors at the indicated line number.`
		warn(errorInfo)
	end
end

-- ===== NOTIFICATION SYSTEM =====
function Library:Notification(titleText, descriptionText, duration)
	if self.IsDestroyed then return end
	require(Components.notif):ShowNotification(titleText, descriptionText, duration or 5)
end

-- ===== DIALOG SYSTEM =====
function Library:Dialog(config)
	if self.IsDestroyed then return end
    return require(Components.dialog):Create(config, self.LoadedWindow)
end

-- ===== ENHANCED MAIN WINDOW CREATION =====
function Library:Load(cfgs)
	-- Cleanup any existing instance first
	CleanupExistingInstance()
	
	cfgs = cfgs or {}
	cfgs.Title = cfgs.Title or "Enhanced UI Library v3.0"
	cfgs.ToggleButton = cfgs.ToggleButton or ""
	cfgs.BindGui = cfgs.BindGui or Enum.KeyCode.RightControl
	cfgs.Size = cfgs.Size or UDim2.new(0, 700, 0, 450) -- Larger default size
	cfgs.Position = cfgs.Position or UDim2.new(0.5, 0, 0.3, 0)

	if Library.Window then
		warn("Cannot create more than one window.")
		return
	end
	
	-- Set this instance as the global one
	GLOBAL_LIBRARY_INSTANCE = Library
	
	Library.Window = GUI

	-- ===== ENHANCED MAIN CANVAS GROUP =====
	local canvas_group = Create("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		Position = cfgs.Position,
		Size = cfgs.Size,
		Parent = GUI,
		Visible = false,
		GroupTransparency = 0,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8), -- Slightly more rounded
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Thickness = 2, -- Thicker border for better visibility
		}),
	})

	-- Add safe shadow instead of DropShadow
	createShadow(canvas_group, Vector2.new(0, 4), 12, 0.3)

	-- Enhanced mobile optimization
	if isMobile then
		canvas_group.Size = UDim2.new(0.95, 0, 0.9, 0)
		canvas_group.Position = UDim2.new(0.5, 0, 0.5, 0)
	end

	-- ===== ENHANCED TOGGLE BUTTON =====
	local togglebtn = Create("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0),
		AutoButtonColor = false,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		Position = UDim2.new(0.5, 8, 0, 0),
		Size = UDim2.new(0, 50, 0, 50), -- Slightly larger
		Parent = GUI,
		Image = cfgs.ToggleButton,
		ImageTransparency = 0.1,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
		}),
	})

	-- Add safe shadow for toggle button
	createShadow(togglebtn, Vector2.new(0, 2), 8, 0.4)

	-- ===== ENHANCED TOGGLE FUNCTIONALITY =====
	local function ToggleVisibility()
		if Library.IsDestroyed then return end
		
		local isVisible = canvas_group.Visible
		local endPosition = isVisible and UDim2.new(0.5, 0, -1, 0) or UDim2.new(0.5, 0, 0.5, 0)
		local endTransparency = isVisible and 1 or 0
	
		local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
	
		canvas_group.Visible = true
		togglebtn.Visible = false
	
		local positionTween = TweenService:Create(canvas_group, tweenInfo, { 
			Position = endPosition,
			GroupTransparency = endTransparency
		})
		
		local buttonTween = TweenService:Create(togglebtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			ImageTransparency = isVisible and 0.1 or 1,
			Size = isVisible and UDim2.new(0, 50, 0, 50) or UDim2.new(0, 45, 0, 45)
		})
	
		positionTween:Play()
		buttonTween:Play()
	
		positionTween.Completed:Connect(function()
			if isVisible then
				canvas_group.Visible = false
				togglebtn.Visible = true
			end
		end)
	end

	-- Initial toggle with animation
	task.wait(0.1)
	ToggleVisibility()

	-- Event connections
	MakeDraggable(togglebtn, togglebtn)
	local toggleConnection = AddConnection(togglebtn.MouseButton1Click, ToggleVisibility)
	local keyConnection = AddConnection(UserInputService.InputBegan, function(value)
		if value.KeyCode == cfgs.BindGui then
			ToggleVisibility()
		end
	end)
	
	table.insert(CLEANUP_CONNECTIONS, toggleConnection)
	table.insert(CLEANUP_CONNECTIONS, keyConnection)

	-- ===== ENHANCED TOP FRAME (TITLE BAR) =====
	local top_frame = Create("Frame", {
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderColor3 = Color3.fromRGB(39, 39, 42),
		Size = UDim2.new(1, 0, 0, 45), -- Taller title bar
		ZIndex = 9,
		Parent = canvas_group,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Thickness = 1,
		}),
		Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 240))
			}),
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.95),
				NumberSequenceKeypoint.new(1, 0.98)
			})
		}),
	})

	-- ===== ENHANCED TITLE LABEL =====
	local title = Create("TextLabel", {
		Font = Enum.Font.GothamBold, -- Bold font for better visibility
		RichText = true,
		Text = cfgs.Title,
		ThemeProps = {
			TextColor3 = "titlecolor",
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		TextSize = 16, -- Larger text
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 0),
		Size = UDim2.new(0, 300, 0, 45),
		ZIndex = 10,
		Parent = top_frame,
	})

	-- ===== ENHANCED WINDOW CONTROLS =====
	local minimizebtn = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 0.9,
		ThemeProps = {
			BackgroundColor3 = "bordercolor",
		},
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -45, 0.5, 0),
		Size = UDim2.new(0, 32, 0, 32),
		ZIndex = 10,
		Parent = top_frame,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Create("ImageLabel", {
			Image = "rbxassetid://15269257100",
			ImageRectOffset = Vector2.new(514, 257),
			ImageRectSize = Vector2.new(256, 256),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -8, 1, -8),
			ThemeProps = {
				ImageColor3 = "titlecolor",
			},
			BorderSizePixel = 0,
			ZIndex = 11,
		}),
	})

	local closebtn = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(220, 53, 69), -- Red close button
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 32, 0, 32),
		ZIndex = 10,
		Parent = top_frame,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Create("ImageLabel", {
			Image = "rbxassetid://15269329696",
			ImageRectOffset = Vector2.new(0, 514),
			ImageRectSize = Vector2.new(256, 256),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -8, 1, -8),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 11,
		}),
	})

	-- Enhanced button hover effects
	local function addHoverEffect(button, hoverColor, normalColor)
		local enterConnection = AddConnection(button.MouseEnter, function()
			if Library.IsDestroyed then return end
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.7,
				BackgroundColor3 = hoverColor or button.BackgroundColor3
			}):Play()
		end)
		
		local leaveConnection = AddConnection(button.MouseLeave, function()
			if Library.IsDestroyed then return end
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.9,
				BackgroundColor3 = normalColor or button.BackgroundColor3
			}):Play()
		end)
		
		table.insert(CLEANUP_CONNECTIONS, enterConnection)
		table.insert(CLEANUP_CONNECTIONS, leaveConnection)
	end

	addHoverEffect(minimizebtn, Color3.fromRGB(100, 100, 100))
	addHoverEffect(closebtn, Color3.fromRGB(255, 69, 69), Color3.fromRGB(220, 53, 69))

	-- Enhanced button event connections
	local minimizeConnection = AddConnection(minimizebtn.MouseButton1Click, ToggleVisibility)
	local closeConnection = AddConnection(closebtn.MouseButton1Click, function()
		if Library.IsDestroyed then return end
		
		-- Enhanced close - direct destruction without dialog
		print("[Enhanced UI] Close button pressed - destroying UI...")
		Library:Destroy()
	end)
	
	table.insert(CLEANUP_CONNECTIONS, minimizeConnection)
	table.insert(CLEANUP_CONNECTIONS, closeConnection)

	-- ===== ENHANCED TAB FRAME (SIDEBAR) =====
	local tab_frame = Create("Frame", {
		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		BorderColor3 = Color3.fromRGB(39, 39, 42),
		Position = UDim2.new(0, 0, 0, 45),
		Size = UDim2.new(0, 150, 1, -45), -- Wider sidebar
		Parent = canvas_group,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Thickness = 1,
		}),
		Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 245, 245))
			}),
			Rotation = 0,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.97),
				NumberSequenceKeypoint.new(1, 0.99)
			})
		}),
	})

	-- ===== ENHANCED TAB HOLDER (SCROLLABLE) =====
	local TabHolder = Create("ScrollingFrame", {
		ThemeProps = {
			ScrollBarImageColor3 = "scrollcolor",
			BackgroundColor3 = "maincolor",
		},
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.8,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = tab_frame,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}),
		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
	})

	-- Auto-resize canvas
	local canvasConnection = AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if Library.IsDestroyed then return end
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 32)
	end)
	table.insert(CLEANUP_CONNECTIONS, canvasConnection)

	AddScrollAnim(TabHolder)

	-- ===== CONTAINER FOLDER =====
	local containerFolder = Create("Folder", {
		Parent = canvas_group,
	})

	-- Make draggable (desktop only)
	if not isMobile then
		MakeDraggable(top_frame, canvas_group)
	end

	Library.LoadedWindow = canvas_group

	-- ===== ENHANCED TAB SYSTEM =====
	local Tabs = {}
	local TabModule = require(Components.tab):Init(containerFolder)
	
	function Tabs:AddTab(title)
		if Library.IsDestroyed then return end
		return TabModule:New(title, TabHolder)
	end
	
	function Tabs:SelectTab(Tab)
		if Library.IsDestroyed then return end
		Tab = Tab or 1
		TabModule:SelectTab(Tab)
	end

	-- ===== ENHANCED METHODS =====
	function Tabs:GetCurrentTab()
		if Library.IsDestroyed then return end
		return TabModule.SelectedTab
	end

	function Tabs:GetTabCount()
		if Library.IsDestroyed then return end
		return TabModule.TabCount
	end

	function Tabs:RemoveTab(tabIndex)
		if Library.IsDestroyed then return end
		if TabModule.Tabs[tabIndex] then
			TabModule:CleanupTab(tabIndex)
		end
	end

	function Tabs:StopAllProcesses()
		if Library.IsDestroyed then return end
		Library:StopAllTasks()
		Library:Notification("System", "All running processes have been stopped.", 3)
	end

	-- Auto-select first tab if available
	if TabModule.TabCount > 0 then
		Tabs:SelectTab(1)
	end

	-- Add system info
	Library:Notification("Enhanced UI", "UI Library v3.0 loaded successfully!", 3)

	return Tabs
end

-- ===== ENHANCED LIBRARY RETURN =====
return Library

end)() end,
    [4] = function()local wax,script,require=ImportGlobals(4)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local ButtonComponent = require(script.Parent.Parent.elements.buttons)

local Create = Tools.Create

-- Safe shadow creation function
local function createShadow(parent, offset, radius, transparency)
    local shadowFrame = Instance.new("Frame")
    shadowFrame.Name = "ShadowFrame"
    shadowFrame.Size = UDim2.new(1, radius * 2, 1, radius * 2)
    shadowFrame.Position = UDim2.new(0, -radius + offset.X, 0, -radius + offset.Y)
    shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadowFrame.BackgroundTransparency = transparency or 0.7
    shadowFrame.BorderSizePixel = 0
    shadowFrame.ZIndex = (parent.ZIndex or 1) - 1
    shadowFrame.Parent = parent
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 8)
    shadowCorner.Parent = shadowFrame
    
    return shadowFrame
end

local DialogModule = {}
local ActiveDialog = nil

function DialogModule:Create(config, parent)
    -- Remove existing dialog if any
    if ActiveDialog then
        pcall(function()
            ActiveDialog:Destroy()
        end)
        ActiveDialog = nil
    end

    local scrolling_frame = Instance.new("ScrollingFrame")
    scrolling_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrolling_frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrolling_frame.ScrollBarImageColor3 = Color3.new(0.109804, 0.109804, 0.117647)
    scrolling_frame.ScrollBarThickness = 4
    scrolling_frame.Active = true
    scrolling_frame.BackgroundColor3 = Color3.new(0, 0, 0)
    scrolling_frame.BackgroundTransparency = 0.2 -- Less transparent for better visibility
    scrolling_frame.BorderColor3 = Color3.new(0, 0, 0)
    scrolling_frame.BorderSizePixel = 0
    scrolling_frame.Size = UDim2.new(1, 0, 1, 0)
    scrolling_frame.Visible = true
    scrolling_frame.ZIndex = 100
    scrolling_frame.Parent = parent

    -- Add a full-frame button to prevent clicks passing through
    local blocker = Instance.new("TextButton")
    blocker.Size = UDim2.new(1, 0, 1, 0)
    blocker.Position = UDim2.new(0, 0, 0, 0)
    blocker.BackgroundTransparency = 1
    blocker.Text = ""
    blocker.AutoButtonColor = false
    blocker.Parent = scrolling_frame

    local uipadding_3 = Instance.new("UIPadding")
    uipadding_3.PaddingBottom = UDim.new(0, 50)
    uipadding_3.PaddingTop = UDim.new(0, 50)
    uipadding_3.Parent = scrolling_frame

    local dialog = Create("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0, 450, 0, 0), -- Wider dialog
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Parent = scrolling_frame,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }), -- More rounded
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Thickness = 2, -- Thicker border
        }),
    })

    -- Add safe shadow instead of DropShadow
    createShadow(dialog, Vector2.new(0, 6), 15, 0.3)

    local uilist_layout = Instance.new("UIListLayout")
    uilist_layout.SortOrder = Enum.SortOrder.LayoutOrder
    uilist_layout.Parent = dialog

    -- Create enhanced top bar with title
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50), -- Taller header
        ThemeProps = { BackgroundColor3 = "maincolor" },
        Parent = dialog,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Thickness = 1,
        }),
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 240))
            }),
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.95),
                NumberSequenceKeypoint.new(1, 0.98)
            })
        }),
        Create("TextLabel", {
            Font = Enum.Font.GothamBold,
            Text = config.Title,
            TextSize = 18, -- Larger title
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 16, 0, 0),
            Size = UDim2.new(1, -32, 1, 0),
            BackgroundTransparency = 1,
            ThemeProps = { TextColor3 = "titlecolor" },
        }),
    })

    -- Create enhanced content container
    local content = Create("TextLabel", {
        Text = config.Content,
        TextSize = 15, -- Slightly larger text
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, -32, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 16, 0, 60),
        RichText = true,
        BackgroundTransparency = 1,
        ThemeProps = { TextColor3 = "descriptioncolor" },
        Parent = dialog,
    })

    local uipadding = Instance.new("UIPadding")
    uipadding.PaddingBottom = UDim.new(0, 12)
    uipadding.PaddingLeft = UDim.new(0, 16)
    uipadding.PaddingRight = UDim.new(0, 16)
    uipadding.PaddingTop = UDim.new(0, 12)
    uipadding.Parent = content

    -- Create enhanced button container
    local buttonContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60), -- Taller button area
        AutomaticSize = Enum.AutomaticSize.Y,
        ThemeProps = { BackgroundColor3 = "maincolor" },
        Parent = dialog,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Thickness = 1,
        }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
        }),
        Create("UIListLayout", {
            Padding = UDim.new(0, 12),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    -- Add enhanced buttons
    for i, buttonConfig in ipairs(config.Buttons) do
        local wrappedCallback = function()
            pcall(buttonConfig.Callback)
            pcall(function()
                scrolling_frame:Destroy()
            end)
            ActiveDialog = nil
        end

        -- Create a new button instance with the container
        local button = setmetatable({
            Container = buttonContainer
        }, ButtonComponent):New({
            Title = buttonConfig.Title,
            Variant = buttonConfig.Variant or (i == 1 and "Primary" or "Ghost"),
            Callback = wrappedCallback,
        })
    end

    ActiveDialog = scrolling_frame
    return dialog
end

return DialogModule

end)() end,
    [5] = function()local wax,script,require=ImportGlobals(5)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local Create = Tools.Create

return function(title, desc, parent)
	local Element = {}
	Element.Frame = Create("TextButton", {
		Font = Enum.Font.SourceSans,
		Text = "",
		Name = "Element",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.519230783, 0),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = parent,
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 8), -- More spacing
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 4),
		}),
	})

	Element.topbox = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Element.Frame,
	})

	local name = Create("TextLabel", {
		Font = Enum.Font.GothamMedium, -- Better font
		LineHeight = 1.3, -- Better line spacing
		RichText = true,
		Text = title,
		ThemeProps = {
			TextColor3 = "titlecolor",
			BackgroundColor3 = "maincolor",
		},
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Element.topbox,
		Name = "Title",
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 40),
			PaddingTop = UDim.new(0, 4),
			Archivable = true,
		}),
	})

	local description = Create("TextLabel", {
		Font = Enum.Font.Gotham,
		RichText = true,
		Name = "Description",
		ThemeProps = {
			TextColor3 = "elementdescription",
			BackgroundColor3 = "maincolor",
		},
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = desc,
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 23),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Element.Frame,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
			PaddingTop = UDim.new(0, 2),
		}),
	})

	function Element:SetTitle(Set)
		name.Text = Set
	end

	function Element:SetDesc(Set)
		if Set == nil then
			Set = ""
		end
		if Set == "" then
			description.Visible = false
		else
			description.Visible = true
		end
		description.Text = Set
	end

	Element:SetDesc(desc)
	Element:SetTitle(title)

	function Element:Destroy()
		pcall(function()
			Element.Frame:Destroy()
		end)
	end

	return Element
end

end)() end,
    [6] = function()local wax,script,require=ImportGlobals(6)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection

-- Safe shadow creation function
local function createShadow(parent, offset, radius, transparency)
    local shadowFrame = Instance.new("Frame")
    shadowFrame.Name = "ShadowFrame"
    shadowFrame.Size = UDim2.new(1, radius * 2, 1, radius * 2)
    shadowFrame.Position = UDim2.new(0, -radius + offset.X, 0, -radius + offset.Y)
    shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadowFrame.BackgroundTransparency = transparency or 0.7
    shadowFrame.BorderSizePixel = 0
    shadowFrame.ZIndex = (parent.ZIndex or 1) - 1
    shadowFrame.Parent = parent
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 8)
    shadowCorner.Parent = shadowFrame
    
    return shadowFrame
end

local Notif = {}

function Notif:Init(Gui)
    self.MainHolder = Create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0,0,0),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(0, 300, 0, 120), -- Larger notification area
        Visible = true,
        Parent = Gui,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 0),
            Archivable = true,
        }),
        Create("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 10),
        })
    })
    
end

function Notif:ShowNotification(titleText, descriptionText, duration)
    local main = Create("CanvasGroup", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(15, 15, 20), -- Darker background
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Size = UDim2.new(0, 320, 0, 0), -- Wider notifications
        Position = UDim2.new(1, -10, 0.5, -150),
        AnchorPoint = Vector2.new(1, 0.5),
        Visible = true,
        Parent = self.MainHolder,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8), -- More rounded
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(40, 40, 50),
            Thickness = 2, -- Thicker border
        }),
    })

    -- Add safe shadow instead of DropShadow
    createShadow(main, Vector2.new(0, 4), 12, 0.4)

    local holderin = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = true,
        Parent = main,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            PaddingTop = UDim.new(0, 15),
        }),
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local topframe = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Visible = true,
        Parent = holderin,
    })

    local user = Create("ImageLabel", {
        Image = "rbxassetid://10723415903",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20), -- Slightly larger icon
        Visible = true,
        Parent = topframe,
    })

    local title = Create("TextLabel", {
        Font = Enum.Font.GothamBold, -- Bold title
        LineHeight = 1.2,
        RichText = true,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16, -- Larger title
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Text = titleText,
        Visible = true,
        Parent = topframe,
    }, {
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 28),
        }),
    })

    local description = Create("TextLabel", {
        Font = Enum.Font.Gotham,
        RichText = true,
        TextColor3 = Color3.fromRGB(200, 200, 200), -- Slightly dimmer description
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Text = descriptionText,
        Visible = true,
        Parent = holderin,
    })

    local progress = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 3), -- Thicker progress bar
        Visible = true,
        Parent = main,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })

    local progressindicator = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(100, 150, 255), -- Blue progress bar
        Size = UDim2.new(1, 0, 0, 3),
        Visible = true,
        Parent = progress,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })

    -- Enhanced fade-in animation
    local fadeInTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local slideInTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Start from the right and slide in
    main.Position = UDim2.new(1, 50, 0.5, -150)
    
    local fadeInTween = TweenService:Create(main, fadeInTweenInfo, {BackgroundTransparency = 0.1})
    local slideInTween = TweenService:Create(main, slideInTweenInfo, {Position = UDim2.new(1, -10, 0.5, -150)})
    
    fadeInTween:Play()
    slideInTween:Play()

    local fadeInTweenTitle = TweenService:Create(title, fadeInTweenInfo, {TextTransparency = 0})
    fadeInTweenTitle:Play()

    local fadeInTweenDescription = TweenService:Create(description, fadeInTweenInfo, {TextTransparency = 0})
    fadeInTweenDescription:Play()

    local fadeInTweenUser = TweenService:Create(user, fadeInTweenInfo, {ImageTransparency = 0})
    fadeInTweenUser:Play()

    -- Enhanced progress animation
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(progressindicator, tweenInfo, {Size = UDim2.new(0, 0, 0, 3)})
    tween:Play()

    -- Enhanced fade-out and removal
    tween.Completed:Connect(function()
        local fadeOutTween = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 50, 0.5, -150)
        })
        fadeOutTween:Play()
        
        fadeOutTween.Completed:Connect(function()
            pcall(function()
                main:Destroy()
            end)
        end)
    end)
end

return Notif

end)() end,
    [7] = function()local wax,script,require=ImportGlobals(7)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)

local Create = Tools.Create
local AddConnection = Tools.AddConnection

return function(cfgs, Parent)
	cfgs = cfgs or {}
	cfgs.Title = cfgs.Title or nil
	cfgs.Description = cfgs.Description or nil
	cfgs.Defualt  = cfgs.Defualt or false
	cfgs.Locked = cfgs.Locked or false
	cfgs.TitleTextSize = cfgs.TitleTextSize or 15 -- Slightly larger default

	local Section = {}

	Section.SectionFrame = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Name = "Section",
		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Parent,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 8),
			Archivable = true,
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor"
			},
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6), -- Rounded sections
		}),
		Create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(248, 248, 248))
			}),
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.98),
				NumberSequenceKeypoint.new(1, 0.99)
			})
		}),
	})

	local topbox = Create("TextButton", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Section.SectionFrame,
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
	})

	local chevronIcon = Create("ImageButton", {
		ThemeProps = {
			ImageColor3 = "titlecolor",
		},
		Image = "rbxassetid://15269180996",
		ImageRectOffset = Vector2.new(0, 257),
		ImageRectSize = Vector2.new(256, 256),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 26, 0, 26), -- Slightly larger
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Rotation = 90,
		Name = "chevron-down",
		ZIndex = 99,
	})
	
	local name = Create("TextLabel", {
		Font = Enum.Font.GothamMedium, -- Better font
		LineHeight = 1.3,
		RichText = true,
		ThemeProps = {
			TextColor3 = "titlecolor",
			BackgroundColor3 = "maincolor",
		},
		TextSize = 15,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false,
		Parent = topbox,
	}, {
		chevronIcon
	})
	
	if cfgs.description ~= nil and cfgs.description ~= "" then
		local description = Create("TextLabel", {
			Font = Enum.Font.Gotham,
			RichText = true,
			ThemeProps = {
				TextColor3 = "descriptioncolor",
				BackgroundColor3 = "maincolor",
			},
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = "",
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 23),
			Size = UDim2.new(1, 0, 0, 16),
			Visible = true,
			Parent = topbox,
		}, {})
		description.Text = cfgs.Description or ""
		description.Visible = cfgs.Description ~= nil
	end

	if cfgs.Title ~= nil and cfgs.Title ~= "" then
		name.Size = UDim2.new(1, 0, 0, 18)
		name.Text = cfgs.Title
		name.TextSize = cfgs.TitleTextSize
		name.Visible = true
	end

	Section.SectionContainer = Create("Frame", {
		Name = "SectionContainer",
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Section.SectionFrame,
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 2),
			PaddingTop = UDim.new(0, 2),
			Archivable = true,
		}),
	})

	local isExpanded = cfgs.Defualt
	if cfgs.Defualt == true then
		chevronIcon.Rotation = 0
	end
	
	local function toggleSection()
		isExpanded = not isExpanded
		local targetRotation = isExpanded and 0 or 90
		
		-- Enhanced animation
		game:GetService("TweenService"):Create(chevronIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Rotation = targetRotation
		}):Play()
		
		local targetSize = isExpanded and UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 20) or UDim2.new(1, 0, 0, 0)
		game:GetService("TweenService"):Create(Section.SectionContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = targetSize
		}):Play()
	end
	
	if cfgs.Locked == false then
		AddConnection(topbox.MouseButton1Click, toggleSection)
		AddConnection(chevronIcon.MouseButton1Click, toggleSection)
	end
	if cfgs.Locked == true then
		topbox:Destroy()
	end
	
	AddConnection(Section.SectionContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if isExpanded then
			Section.SectionContainer.Size = UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 20)
		end
	end)

	return Section
end
end)() end,
    [8] = function()local wax,script,require=ImportGlobals(8)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)

local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local AddScrollAnim = Tools.AddScrollAnim
local CurrentThemeProps = Tools.GetPropsCurrentTheme()

-- Add debug toggle
local SEARCH_DEBUG = false

local function debugLog(...)
	if SEARCH_DEBUG then
		print("[Search]", ...)
	end
end

local TabModule = {
	Window = nil,
	Tabs = {},
	Containers = {},
	SelectedTab = 0,
	TabCount = 0,
	SearchContainers = {},
}

function TabModule:Init(Window)
	TabModule.Window = Window
	return TabModule
end

-- Enhanced cleanup function
function TabModule:CleanupTab(TabIndex)
	if TabModule.SearchContainers[TabIndex] then
		pcall(function()
			TabModule.SearchContainers[TabIndex]:Destroy()
		end)
		TabModule.SearchContainers[TabIndex] = nil
	end
	
	if TabModule.Containers[TabIndex] then
		pcall(function()
			TabModule.Containers[TabIndex]:Destroy()
		end)
		TabModule.Containers[TabIndex] = nil
	end
	
	if TabModule.Tabs[TabIndex] then
		TabModule.Tabs[TabIndex] = nil
	end
end

function TabModule:New(Title, Parent)
	local Library = require(script.Parent.Parent)
	local Window = TabModule.Window
	local Elements = Library.Elements

	TabModule.TabCount = TabModule.TabCount + 1
	local TabIndex = TabModule.TabCount

	local Tab = {
		Selected = false,
		Name = Title,
		Type = "Tab",
	}

	Tab.TabBtn = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 0.95,
		Size = UDim2.new(1, 0, 0, 36), -- Taller tabs
		Parent = Parent,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Create("TextLabel", {
			Name = "Title",
			Font = Enum.Font.GothamMedium, -- Better font
			TextColor3 = Color3.fromRGB(100, 100, 100),
			TextSize = 14,
			ThemeProps = {
				BackgroundColor3 = "maincolor",
			},
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 16, 0.5, 0),
			Size = UDim2.new(0.8, 0, 0.9, 0),
			Text = Title,
		}),
		Create("Frame", {
			Name = "Line",
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			Position = UDim2.new(0, 6, 0, 0),
			Size = UDim2.new(0, 3, 1, 0), -- Thicker line
			BorderSizePixel = 0,
		}, {
			Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
		}),
	})

	-- Enhanced hover effect for tabs
	AddConnection(Tab.TabBtn.MouseEnter, function()
		if not Tab.Selected then
			TweenService:Create(Tab.TabBtn, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.9
			}):Play()
		end
	end)
	
	AddConnection(Tab.TabBtn.MouseLeave, function()
		if not Tab.Selected then
			TweenService:Create(Tab.TabBtn, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.95
			}):Play()
		end
	end)

	-- Enhanced search container
	Tab.SearchContainer = Create("Frame", {
		Name = "SearchContainer_" .. TabIndex,
		Size = UDim2.new(1, 0, 0, 40), -- Taller search
		BackgroundTransparency = 1,
		Parent = Parent,
		LayoutOrder = TabIndex + 100,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		Visible = false,
	})

	local SearchBox = Create("TextBox", {
		Size = UDim2.new(1, -12, 0, 36),
		Position = UDim2.new(0, 6, 0, 2),
		PlaceholderText = "🔍 Search elements...",
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		BackgroundTransparency = 0.95,
		ThemeProps = {
			TextColor3 = "titlecolor",
			PlaceholderColor3 = "descriptioncolor",
			BackgroundColor3 = "maincolor",
		},
		Parent = Tab.SearchContainer,
		ClearTextOnFocus = false,
	}, {
		Create("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Thickness = 1,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
	})

	Tab.Container = Create("ScrollingFrame", {
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ThemeProps = {
			ScrollBarImageColor3 = "scrollocolor",
			BackgroundColor3 = "maincolor",
		},
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.8,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 150, 0, 45), -- Adjusted for new layout
		Size = UDim2.new(1, -150, 1, -45),
		Visible = false,
		Parent = TabModule.Window,
	}, {
		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8), -- More spacing
		}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 12),
		}),
	})

	AddScrollAnim(Tab.Container)

	AddConnection(Tab.Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Tab.Container.CanvasSize = UDim2.new(0, 0, 0, Tab.Container.UIListLayout.AbsoluteContentSize.Y + 32)
	end)

	-- Enhanced search functionality
	local function searchInElement(element, searchText)
		local title = element:FindFirstChild("Title", true)
		local desc = element:FindFirstChild("Description", true)

		if title then
			debugLog("Checking title:", title.Text)
			local cleanTitle = title.Text:gsub("^%s+", "")
			if string.find(string.lower(cleanTitle), searchText) then
				debugLog("Found match in title")
				return true
			end
		end

		if desc then
			debugLog("Checking description:", desc.Text)
			if string.find(string.lower(desc.Text), searchText) then
				debugLog("Found match in description")
				return true
			end
		end

		return false
	end

	local function updateSearch()
		local searchText = string.lower(SearchBox.Text)
		debugLog("Search text:", searchText)

		if not Tab.Container.Visible then
			debugLog("Tab not visible, skipping search")
			return
		end

		for _, child in ipairs(Tab.Container:GetChildren()) do
			if child.Name == "Section" then
				local sectionContainer = child:FindFirstChild("SectionContainer")
				if sectionContainer then
					local visible = false
					debugLog("Checking section:", child.Name)

					for _, element in ipairs(sectionContainer:GetChildren()) do
						if element.Name == "Element" then
							local elementVisible = searchInElement(element, searchText)
							element.Visible = elementVisible or searchText == ""
							if elementVisible then
								visible = true
							end
						end
					end

					child.Visible = visible or searchText == ""
					debugLog("Section visibility:", child.Visible)
				end
			elseif child.Name == "Element" then
				local elementVisible = searchInElement(child, searchText)
				child.Visible = elementVisible or searchText == ""
				debugLog("Standalone element visibility:", child.Visible)
			end
		end
	end

	AddConnection(Tab.Container:GetPropertyChangedSignal("Visible"), function()
		if Tab.Container.Visible then
			updateSearch()
		end
	end)

	AddConnection(SearchBox:GetPropertyChangedSignal("Text"), updateSearch)

	Tab.ContainerFrame = Tab.Container

	AddConnection(Tab.TabBtn.MouseButton1Click, function()
		TabModule:SelectTab(TabIndex)
	end)

	TabModule.Containers[TabIndex] = Tab.ContainerFrame
	TabModule.Tabs[TabIndex] = Tab
	TabModule.SearchContainers[TabIndex] = Tab.SearchContainer

	function Tab:AddSection(cfgs)
		cfgs = cfgs or {}
		cfgs.Title = cfgs.Title or nil
		cfgs.Description = cfgs.Description or nil
		local Section = { Type = "Section" }

		local SectionFrame = require(script.Parent.section)(cfgs, Tab.Container)
		Section.Container = SectionFrame.SectionContainer

		function Section:AddGroupButton()
			local GroupButton = { Type = "Group" }
			GroupButton.GroupContainer = Create("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				Visible = true,
				ThemeProps = {
					BackgroundColor3 = "maincolor",
				},
				BorderSizePixel = 0,
				Parent = SectionFrame.SectionContainer,
			}, {
				Create("UIListLayout", {
					Padding = UDim.new(0, 8),
					Wraps = true,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			})

			GroupButton.Container = GroupButton.GroupContainer

			setmetatable(GroupButton, Elements)
			return GroupButton
		end

		setmetatable(Section, Elements)
		return Section
	end

	function Tab:Destroy()
		TabModule:CleanupTab(TabIndex)
	end

	return Tab
end

function TabModule:SelectTab(Tab)
    TabModule.SelectedTab = Tab

    for i, v in next, TabModule.Tabs do
        -- Enhanced tab selection animation
        TweenService:Create(
            v.TabBtn.Title,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { TextColor3 = CurrentThemeProps.offTextBtn }
        ):Play()
        TweenService:Create(
            v.TabBtn.Line,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { BackgroundColor3 = CurrentThemeProps.offBgLineBtn }
        ):Play()
        TweenService:Create(
            v.TabBtn,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { BackgroundTransparency = 0.95 }
        ):Play()
        v.Selected = false
        
        if TabModule.SearchContainers[i] then
            TabModule.SearchContainers[i].Visible = false
        end
    end

    local selectedTab = TabModule.Tabs[Tab]
    if selectedTab then
        TweenService:Create(
            selectedTab.TabBtn.Title,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { TextColor3 = CurrentThemeProps.onTextBtn }
        ):Play()
        TweenService:Create(
            selectedTab.TabBtn.Line,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { BackgroundColor3 = CurrentThemeProps.onBgLineBtn }
        ):Play()
        TweenService:Create(
            selectedTab.TabBtn,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { BackgroundTransparency = 0.8 }
        ):Play()
        selectedTab.Selected = true

        task.spawn(function()
            for _, Container in pairs(TabModule.Containers) do
                Container.Visible = false
            end

            if TabModule.SearchContainers[Tab] then
                TabModule.SearchContainers[Tab].Visible = true
            end

            if TabModule.Containers[Tab] then
                TabModule.Containers[Tab].Visible = true
            end
        end)
    end
end

return TabModule

end)() end,
    [10] = function()local wax,script,require=ImportGlobals(10)local ImportGlobals return (function(...)local Elements = {}

for _, Theme in next, script.Parent:GetChildren() do
    if Theme.Name ~= "init" then
        table.insert(Elements, require(Theme))
    end
end

return Elements
end)() end,
    [11] = function()local wax,script,require=ImportGlobals(11)local ImportGlobals return (function(...)local UserInputService = game:GetService("UserInputService")

local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local BlacklistedKeys = {
	Enum.KeyCode.Unknown,
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Up,
	Enum.KeyCode.Left,
	Enum.KeyCode.Down,
	Enum.KeyCode.Right,
	Enum.KeyCode.Slash,
	Enum.KeyCode.Tab,
	Enum.KeyCode.Backspace,
	Enum.KeyCode.Escape,
}

local Element = {}
Element.__index = Element
Element.__type = "Bind"

function Element:New(Idx, Config)
	assert(Config.Title, "Bind - Missing Title")
	Config.Description = Config.Description or nil
	Config.Hold = Config.Hold or false
	Config.Callback = Config.Callback or function() end
	Config.ChangeCallback = Config.ChangeCallback or function() end
	local Bind = { Value = nil, Binding = false, Type = "Bind" }
	local Holding = false

	local BindFrame = require(Components.element)(Config.Title, Config.Description, self.Container)

	local value = Create("TextLabel", {
		Font = Enum.Font.GothamMedium,
		RichText = true,
		Text = "",
		ThemeProps = {
			BackgroundColor3 = "bordercolor",
			TextColor3 = "titlecolor",
		},
		TextSize = 13,
		AnchorPoint = Vector2.new(1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 0, 0, 18), -- Taller
		Visible = true,
		Parent = BindFrame.topbox,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 2),
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 5),
			Archivable = true,
		}),
	})

	AddConnection(BindFrame.Frame.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if Bind.Binding then
				return
			end
			Bind.Binding = true
			value.Text = "..."
		end
	end)

	function Bind:Set(Key)
		Bind.Binding = false
		Bind.Value = Key or Bind.Value
		Bind.Value = Bind.Value.Name or Bind.Value
		value.Text = Bind.Value
		Config.ChangeCallback(Bind.Value)
	end

	AddConnection(UserInputService.InputBegan, function(Input)
		if UserInputService:GetFocusedTextBox() then
			return
		end
		if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
			if Config.Hold then
				Holding = true
				Config.Callback(Holding)
			else
				Config.Callback()
			end
		elseif Bind.Binding then
			local Key
			pcall(function()
				if not table.find(BlacklistedKeys, Input.KeyCode) then
					Key = Input.KeyCode
				end
			end)
			Key = Key or Bind.Value
			Bind:Set(Key)
		end
	end)

	AddConnection(UserInputService.InputEnded, function(Input)
		if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
			if Config.Hold and Holding then
				Holding = false
				Config.Callback(Holding)
			end
		end
	end)

	Bind:Set(Config.Default)

	self.Library.Flags[Idx] = Bind
	return Bind
end

return Element

end)() end,
    [12] = function()local wax,script,require=ImportGlobals(12)local ImportGlobals return (function(...)local TweenService = game:GetService("TweenService")

local Tools = require(script.Parent.Parent.tools)

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local CurrentThemeProps = Tools.GetPropsCurrentTheme()

local Element = {}
Element.__index = Element
Element.__type = "Button"

local ButtonStyles = {
	Primary = {
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(59, 130, 246), -- Modern blue
		BackgroundTransparency = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		HoverConfig = {
			BackgroundColor3 = Color3.fromRGB(37, 99, 235),
			BackgroundTransparency = 0,
		},
		FocusConfig = {
			BackgroundColor3 = Color3.fromRGB(29, 78, 216),
			BackgroundTransparency = 0,
		},
	},
	Ghost = {
		TextColor3 = Color3.fromRGB(156, 163, 175),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		HoverConfig = {
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.95,
		},
		FocusConfig = {
			BackgroundTransparency = 0.9,
		},
	},
	Outline = {
		TextColor3 = Color3.fromRGB(156, 163, 175),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 1,
		UIStroke = {
			Color = Color3.fromRGB(75, 85, 99),
			Thickness = 1,
		},
		HoverConfig = {
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.95,
		},
		FocusConfig = {
			BackgroundTransparency = 0.9,
		},
	},
}

local function ApplyTweens(button, config, uiStroke)
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local tweenGoals = {}

	for property, value in pairs(config) do
		if property ~= "UIStroke" then
			tweenGoals[property] = value
		end
	end

	local tween = TweenService:Create(button, tweenInfo, tweenGoals)
	tween:Play()

	if uiStroke and config.UIStroke then
		local strokeTweenGoals = {}
		for property, value in pairs(config.UIStroke) do
			strokeTweenGoals[property] = value
		end
		local strokeTween = TweenService:Create(uiStroke, tweenInfo, strokeTweenGoals)
		strokeTween:Play()
	end
end

local function CreateButton(style, text, parent)
	local config = ButtonStyles[style]
	assert(config, "Invalid button style: " .. style)

	local button = Create("TextButton", {
		Font = Enum.Font.GothamMedium,
		LineHeight = 1.25,
		Text = text,
		TextColor3 = config.TextColor3,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = config.BackgroundColor3,
		BackgroundTransparency = config.BackgroundTransparency,
		BorderColor3 = config.BorderColor3,
		BorderSizePixel = config.BorderSizePixel,
		Visible = true,
		Parent = parent,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
			PaddingTop = UDim.new(0, 10),
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8), -- More rounded
			Archivable = true,
		}),
	})

	if config.UIStroke then
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = config.UIStroke.Color,
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = config.UIStroke.Thickness,
			Archivable = true,
			Parent = button,
		})
	end

	button.MouseEnter:Connect(function()
		if config.HoverConfig then
			ApplyTweens(button, config.HoverConfig)
		end
	end)

	button.MouseLeave:Connect(function()
		ApplyTweens(button, {
			BackgroundColor3 = config.BackgroundColor3,
			TextColor3 = config.TextColor3,
			BackgroundTransparency = config.BackgroundTransparency,
			BorderColor3 = config.BorderColor3,
			BorderSizePixel = config.BorderSizePixel,
			UIStroke = config.UIStroke,
		})
	end)

	button.MouseButton1Down:Connect(function()
		if config.FocusConfig then
			ApplyTweens(button, config.FocusConfig)
		end
	end)

	button.MouseButton1Up:Connect(function()
		if config.HoverConfig then
			ApplyTweens(button, config.HoverConfig)
		else
			ApplyTweens(button, {
				BackgroundColor3 = config.BackgroundColor3,
				TextColor3 = config.TextColor3,
				BackgroundTransparency = config.BackgroundTransparency,
				BorderColor3 = config.BorderColor3,
				BorderSizePixel = config.BorderSizePixel,
				UIStroke = config.UIStroke,
			})
		end
	end)

	return button
end

function Element:New(Config)
	assert(Config.Title, "Button - Missing Title")
	Config.Variant = Config.Variant or "Primary"
	Config.Callback = Config.Callback or function() end
	local Button = {}

	Button.StyledButton = CreateButton(Config.Variant, Config.Title, self.Container)
	Button.StyledButton.MouseButton1Click:Connect(Config.Callback)

	return Button
end

return Element

end)() end,
    [13] = function()local wax,script,require=ImportGlobals(13)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local mouse = LocalPlayer:GetMouse()

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local HueSelectionPosition, RainbowColorValue = 0, 0
local rainbowIncrement, hueIncrement, maxHuePosition = 1 / 255, 1, 127
coroutine.wrap(function()
	while true do
		RainbowColorValue = (RainbowColorValue + rainbowIncrement) % 1
		HueSelectionPosition = (HueSelectionPosition + hueIncrement) % maxHuePosition
		wait(0.06)
	end
end)()

local Element = {}
Element.__index = Element
Element.__type = "Colorpicker"

function Element:New(Idx, Config)
	assert(Config.Title, "Colorpicker - Missing Title")
	Config.Description = Config.Description or nil
	assert(Config.Default, "AddColorPicker: Missing default value.")

    local Colorpicker = {
        Value = Config.Default,
        Transparency = Config.Transparency or 0,
        Type = "Colorpicker",
        Callback = Config.Callback or function(Color) end,
        RainbowColorPicker = false,
        ColorpickerToggle = false,
    }

	local RainbowColorPicker = Colorpicker.RainbowColorPicker

	function Colorpicker:SetHSVFromRGB(Color)
		local H, S, V = Color3.toHSV(Color)
		Colorpicker.Hue = H
		Colorpicker.Sat = S
		Colorpicker.Vib = V
	end
	Colorpicker:SetHSVFromRGB(Colorpicker.Value)

	local ColorpickerFrame = require(Components.element)(Config.Title, Config.Description, self.Container)

	local InputFrame = Create("CanvasGroup", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 35), -- Taller
		Visible = true,
		Parent = ColorpickerFrame.Frame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(40, 40, 50),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
			Archivable = true,
		}),
	})

	local colorBox = Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(3, 255, 150),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 35, 1, 0), -- Larger color box
		Visible = true,
		Parent = InputFrame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(40, 40, 50),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
	})

	local inputHex = Create("TextBox", {
		Font = Enum.Font.GothamMedium,
		LineHeight = 1.2,
		PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		Text = "#03ff96",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Visible = true,
		Parent = InputFrame,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 15),
			PaddingRight = UDim.new(0, 15),
			PaddingTop = UDim.new(0, 0),
			Archivable = true,
		}),
	})

	AddConnection(inputHex.FocusLost, function(Enter)
		if Enter then
			local Success, Result = pcall(Color3.fromHex, inputHex.Text)
			if Success and typeof(Result) == "Color3" then
				Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = Color3.toHSV(Result)
			end
		end
	end)

	-- Enhanced Colorpicker
	local colorpicker_frame = Create("TextButton", {
		AutoButtonColor = false,
		Text = "",
		ZIndex = 20,
		BackgroundColor3 = Color3.fromRGB(20, 20, 25),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(1, 0, 0, 180), -- Taller picker
		Visible = false,
		Parent = ColorpickerFrame.Frame,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(40, 40, 50),
			Thickness = 2,
		}),
	})

	local color = Create("ImageLabel", {
		Image = "rbxassetid://4155801252",
		BackgroundColor3 = Color3.fromRGB(255, 0, 4),
		Size = UDim2.new(1, -15, 0, 140), -- Larger color area
		Visible = true,
		ZIndex = 10,
		Parent = colorpicker_frame,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
			Archivable = true,
		}),
	})

	local color_selection = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 14, 0, 14), -- Larger selector
		Visible = true,
		Parent = color,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Archivable = true,
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Color = Color3.fromRGB(255, 255, 255),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
			Archivable = true,
		}),
	})

	local hue = Create("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 8, 0, 140), -- Wider hue bar
		Visible = true,
		Parent = colorpicker_frame,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Archivable = true,
		}),
		Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
			}),
			Enabled = true,
			Offset = Vector2.new(0, 0),
			Rotation = 270,
			Archivable = true,
		}),
	})

	local hue_selection = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.1, 0),
		Size = UDim2.new(0, 10, 0, 10), -- Larger selector
		Visible = true,
		Parent = hue,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Archivable = true,
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Color = Color3.fromRGB(255, 255, 255),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
			Archivable = true,
		}),
	})

	local rainbowtoggle = Create("TextButton", {
		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 14,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 20), -- Taller toggle
		Visible = true,
		Parent = colorpicker_frame,
	})

	local togglebox = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(250, 250, 250),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 18, 0, 18), -- Larger toggle
		Visible = true,
		Parent = rainbowtoggle,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Archivable = true,
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(100, 100, 120),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
			Archivable = true,
		}),

		Create("ImageLabel", {
			Image = "http://www.roblox.com/asset/?id=6031094667",
			ImageColor3 = Color3.fromRGB(20, 20, 25),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 14, 0, 14),
			Visible = true,
		}),
		Create("TextLabel", {
			Font = Enum.Font.GothamMedium,
			Text = "Rainbow",
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 28, 0, 0),
			Size = UDim2.new(1, 0, 0, 18),
			Visible = true,
		}),
	})

	local function UpdateColorPicker()
        if not (Colorpicker.Hue and Colorpicker.Sat and Colorpicker.Vib) then
            warn("Missing HSV values in UpdateColorPicker")
            return
        end
        
        local newColor = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)
        colorBox.BackgroundColor3 = newColor
        color.BackgroundColor3 = Color3.fromHSV(Colorpicker.Hue, 1, 1)
        color_selection.BackgroundColor3 = newColor
        
        if inputHex then
            inputHex.Text = "#" .. newColor:ToHex()
        end
        
        pcall(Colorpicker.Callback, newColor)
    end
	
	local function UpdateColorPickerPosition()
		local ColorX = math.clamp(mouse.X - color.AbsolutePosition.X, 0, color.AbsoluteSize.X)
		local ColorY = math.clamp(mouse.Y - color.AbsolutePosition.Y, 0, color.AbsoluteSize.Y)
		color_selection.Position = UDim2.new(ColorX / color.AbsoluteSize.X, 0, ColorY / color.AbsoluteSize.Y, 0)
		Colorpicker.Sat = ColorX / color.AbsoluteSize.X
		Colorpicker.Vib = 1 - (ColorY / color.AbsoluteSize.Y)
		UpdateColorPicker()
		inputHex.Text = "#" .. Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib):ToHex()
	end
	
	local function UpdateHuePickerPosition()
		local HueY = math.clamp(mouse.Y - hue.AbsolutePosition.Y, 0, hue.AbsoluteSize.Y)
		hue_selection.Position = UDim2.new(0.5, 0, HueY / hue.AbsoluteSize.Y, 0)
		Colorpicker.Hue = HueY / hue.AbsoluteSize.Y
		UpdateColorPicker()
		inputHex.Text = "#" .. Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib):ToHex()
	end
	
	local ColorInput, HueInput = nil, nil
	
	AddConnection(color.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if RainbowColorPicker then
				return
			end
			if ColorInput then
				ColorInput:Disconnect()
			end
			ColorInput = AddConnection(mouse.Move, UpdateColorPickerPosition)
			UpdateColorPickerPosition()
		end
	end)
	
	AddConnection(color.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if ColorInput then
				ColorInput:Disconnect()
				ColorInput = nil
			end
		end
	end)
	
	AddConnection(hue.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if RainbowColorPicker then
				return
			end
			if HueInput then
				HueInput:Disconnect()
			end
			HueInput = AddConnection(mouse.Move, UpdateHuePickerPosition)
			UpdateHuePickerPosition()
		end
	end)
	
	AddConnection(hue.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if HueInput then
				HueInput:Disconnect()
				HueInput = nil
			end
		end
	end)	

	AddConnection(ColorpickerFrame.Frame.MouseButton1Click, function()
		Colorpicker.ColorpickerToggle = not Colorpicker.ColorpickerToggle
		colorpicker_frame.Visible = Colorpicker.ColorpickerToggle
	end)

	AddConnection(rainbowtoggle.MouseButton1Click, function()
		RainbowColorPicker = not RainbowColorPicker
		Colorpicker.RainbowMode = RainbowColorPicker
		TweenService:Create(
			togglebox,
			TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ BackgroundTransparency = RainbowColorPicker and 0 or 1 }
		):Play()
		if RainbowColorPicker then
			local function UpdateRainbowColor()
				while RainbowColorPicker do
					Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = RainbowColorValue, 1, 1
					hue_selection.Position = UDim2.new(0.5, 0, 0, HueSelectionPosition)
					hue_selection.Position = UDim2.new(1, -10, 0, 0)
					UpdateColorPicker()
					wait()
				end
			end
			coroutine.wrap(UpdateRainbowColor)()
		end
	end)

    function Colorpicker:Set(newColor)
        if typeof(newColor) ~= "Color3" then
            warn("Invalid color value provided to Set")
            return
        end
        
        self:SetHSVFromRGB(newColor)
        
        if color_selection and colorBox and hue_selection then
            color_selection.Position = UDim2.new(self.Sat, 0, 1 - self.Vib, 0)
            colorBox.BackgroundColor3 = newColor
            hue_selection.Position = UDim2.new(0.5, 0, self.Hue, 0)
            UpdateColorPicker()
        end
    end

	self.Library.Flags[Idx] = Colorpicker
	return Colorpicker
end

return Element

end)() end,
    [14] = function()local wax,script,require=ImportGlobals(14)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components
local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local CurrentThemeProps = Tools.GetPropsCurrentTheme()

local Element = {}
Element.__index = Element
Element.__type = "Dropdown"

function Element:New(Idx, Config)
	assert(Config.Title, "Dropdown - Missing Title")
	Config.Description = Config.Description or nil

	Config.Options = Config.Options or {}
	Config.Default = Config.Default or ""
	Config.IgnoreFirst = Config.IgnoreFirst or false
	Config.Multiple = Config.Multiple or false
	Config.MaxOptions = Config.MaxOptions or math.huge
	Config.PlaceHolder = Config.PlaceHolder or ""
	Config.Callback = Config.Callback or function() end

	local Dropdown = {
		Value = Config.Default,
		Options = Config.Options,
		Buttons = {},
		Toggled = false,
		Type = "Dropdown",
		Multiple = Config.Multiple,
		Callback = Config.Callback
	}
	local MaxElements = 5

	local DropdownFrame = require(Components.element)(Config.Title, Config.Description, self.Container)

	local DropdownElement = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		ThemeProps = {
			BackgroundColor3 = "maincolor"
		},
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 35), -- Taller dropdown
		Visible = true,
		Parent = DropdownFrame.Frame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = { Color = "bordercolor" },
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
			Archivable = true,
		}),
		Create("UIListLayout", {
			Wraps = true,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
	})

	local holder = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		ThemeProps = {
			BackgroundColor3 = "maincolor"
		},
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 35),
		Visible = true,
		Parent = DropdownElement,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 6),
			Archivable = true,
		}),
		Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			Wraps = true,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
		Create("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Shrink,
		}, {}),
	})

	local search = Create("TextBox", {
		CursorPosition = -1,
		Font = Enum.Font.GothamMedium,
		PlaceholderText = Config.PlaceHolder,
		Text = "",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeProps = {
			BackgroundColor3 = "maincolor"
		},
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 140, 0, 35),
		Visible = true,
		Parent = DropdownElement,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 15),
			PaddingRight = UDim.new(0, 15),
			PaddingTop = UDim.new(0, 0),
			Archivable = true,
		}),
		Create("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Fill,
		}),
	})

	local dropcont = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		ThemeProps = { BackgroundColor3 = "containeritemsbg" },
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false,
		Parent = DropdownFrame.Frame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = { Color = "bordercolor" },
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2,
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Archivable = true,
		}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 12),
			Archivable = true,
		}),
		Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	AddConnection(search.Focused, function()
		Dropdown.Toggled = true
		dropcont.Visible = true
	end)
	AddConnection(DropdownFrame.Frame.MouseButton1Click, function()
		Dropdown.Toggled = not Dropdown.Toggled
		dropcont.Visible = Dropdown.Toggled
	end)
	
	function SearchOptions()
		local searchText = string.lower(search.Text)
		for _, v in ipairs(dropcont:GetChildren()) do
			if v:IsA("TextButton") then
				local buttonText = string.lower(v.TextLabel.Text)
				if string.find(buttonText, searchText) then
					v.Visible = true
				else
					v.Visible = false
				end
			end
		end
	end

	AddConnection(search.Changed, SearchOptions)

	local function AddOptions(Options)
		for _, Option in pairs(Options) do
			local check = Create("ImageLabel", {
				Image = "rbxassetid://15269180838",
				ThemeProps = { ImageColor3 = "itemcheckmarkcolor", },
				ImageRectOffset = Vector2.new(514, 257),
				ImageRectSize = Vector2.new(256, 256),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16), -- Larger checkmark
				Visible = true,
			})

			local text_label_2 = Create("TextLabel", {
				Font = Enum.Font.GothamMedium,
				Text = Option,
				LineHeight = 0,
				TextColor3 = Color3.fromRGB(180, 180, 180),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Visible = true,
			}, {
				Create("UIPadding", {
					PaddingBottom = UDim.new(0, 0),
					PaddingLeft = UDim.new(0, 16),
					PaddingRight = UDim.new(0, 0),
					PaddingTop = UDim.new(0, 0),
					Archivable = true,
				}),
			})

			local dropbtn = Create("TextButton", {
				Font = Enum.Font.SourceSans,
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 14,
				ThemeProps = { BackgroundColor3 = "itembg" },
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 35), -- Taller options
				Visible = true,
				Parent = dropcont,
			}, {
				Create("UICorner", {
					CornerRadius = UDim.new(0, 6),
					Archivable = true,
				}),
				text_label_2,
				check,
			})

			-- Enhanced hover effect
			AddConnection(dropbtn.MouseEnter, function()
				TweenService:Create(dropbtn, TweenInfo.new(0.2), {
					BackgroundTransparency = 0.9
				}):Play()
			end)
			
			AddConnection(dropbtn.MouseLeave, function()
				TweenService:Create(dropbtn, TweenInfo.new(0.2), {
					BackgroundTransparency = 1
				}):Play()
			end)

			AddConnection(dropbtn.MouseButton1Click, function()
				if Config.Multiple then
					local index = table.find(Dropdown.Value, Option)
					if index then
						table.remove(Dropdown.Value, index)
						Dropdown:Set(Dropdown.Value)
						if #Dropdown.Value == 0 then
							Config.Callback = {}
						end
					else
						Dropdown:Set(Option)
					end
				else
					if Dropdown.Value == Option then
						Dropdown:Set("")
						Config.Callback("") 
					else
						Dropdown:Set(Option)
					end
				end
				
				if not Config.Multiple then
					Dropdown.Toggled = false
					dropcont.Visible = false
				end
			end)

			Dropdown.Buttons[Option] = dropbtn
		end
	end

	function Dropdown:Refresh(Options, Delete)
		if Delete then
			for _, v in pairs(Dropdown.Buttons) do
				pcall(function()
					v:Destroy()
				end)
			end
			Dropdown.Buttons = {}
		end
		Dropdown.Options = Options
		AddOptions(Dropdown.Options)
	end

	function Dropdown:Set(Value, ignore)
		local function updateButtonTransparency(button, isSelected)
			local transparency = isSelected and 0 or 1
			local textTransparency = isSelected and CurrentThemeProps.itemTextOff or CurrentThemeProps.itemTextOn
			TweenService:Create(
				button,
				TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ BackgroundTransparency = transparency }
			):Play()
			TweenService:Create(
				button.ImageLabel,
				TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ ImageTransparency = transparency }
			):Play()
			TweenService:Create(
				button.TextLabel,
				TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ TextColor3 = textTransparency }
			):Play()
		end

		local function clearValueText()
			for _, label in pairs(holder:GetChildren()) do
				if label:IsA("TextButton") then
					pcall(function()
						label:Destroy()
					end)
				end
			end
		end

		local function addValueText(text)
			local tagBtn = Create("TextButton", {
				Font = Enum.Font.SourceSans,
				Text = "",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				AutomaticSize = Enum.AutomaticSize.X,
				ThemeProps = { BackgroundColor3 = "valuebg" },
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 0, 24), -- Taller tags
				Visible = true,
				Parent = holder,
			}, {
				Create("UICorner", {
					CornerRadius = UDim.new(1, 0),
					Archivable = true,
				}),
				Create("UIPadding", {
					PaddingBottom = UDim.new(0, 0),
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
					PaddingTop = UDim.new(0, 0),
					Archivable = true,
				}),
				Create("UIListLayout", {
					Padding = UDim.new(0, 6),
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}, {}),
				Create("TextLabel", {
					Font = Enum.Font.GothamMedium,
					ThemeProps = { TextColor3 = "valuetext" },
					TextSize = 13,
					Text = text,
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 1, 0),
				}, {}),
			})

			local closebtn = Create("TextButton", {
				Font = Enum.Font.SourceSans,
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 14,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 18, 0, 18), -- Larger close button
				Visible = true,
				Parent = tagBtn,
			}, {
				Create("ImageLabel", {
					Image = "rbxassetid://15269329696",
					ImageRectOffset = Vector2.new(0, 514),
					ImageRectSize = Vector2.new(256, 256),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 18, 0, 18),
					Visible = true,
				}, {}),
			})

			AddConnection(tagBtn.MouseButton1Click, function()
				if Config.Multiple then
					local index = table.find(Dropdown.Value, text)
					if index then
						table.remove(Dropdown.Value, index)
						Dropdown:Set(Dropdown.Value)
						if #Dropdown.Value == 0 then
							Config.Callback("")
						end
					end
				else
					Dropdown:Set("")
					Config.Callback("")
				end
			end)
			
			AddConnection(closebtn.MouseButton1Click, function()
				if Config.Multiple then
					local index = table.find(Dropdown.Value, text)
					if index then
						table.remove(Dropdown.Value, index)
						Dropdown:Set(Dropdown.Value)
						if #Dropdown.Value == 0 then
							Config.Callback("")
						end
					end
				else
					Dropdown:Set("")
					Config.Callback("")
				end
			end)
		end

        if Config.Multiple then
            if type(Value) == "table" then
                Dropdown.Value = Value
            elseif Value ~= "" then
                if type(Dropdown.Value) ~= "table" then
                    Dropdown.Value = {}
                end
                local index = table.find(Dropdown.Value, Value)
                if index then
                    table.remove(Dropdown.Value, index)
                else
                    if #Dropdown.Value < (Config.MaxOptions or math.huge) then
                        table.insert(Dropdown.Value, Value)
                    end
                end
            else
                Dropdown.Value = {}
            end
        else
            Dropdown.Value = Value
        end

		local found = Config.Multiple or table.find(Dropdown.Options, Value)
		if Config.Multiple then
			for i = #Dropdown.Value, 1, -1 do
				if not table.find(Dropdown.Options, Dropdown.Value[i]) then
					table.remove(Dropdown.Value, i)
				end
			end
			found = #Dropdown.Value > 0
		end

		clearValueText()

		if not found then
			Dropdown.Value = Config.Multiple and {} or ""
			for _, button in pairs(Dropdown.Buttons) do
				updateButtonTransparency(button, false)
			end
			return
		end

		if Config.Multiple then
			for _, val in ipairs(Dropdown.Value) do
				addValueText(val)
			end
		else
			addValueText(Dropdown.Value)
		end

		for i, button in pairs(Dropdown.Buttons) do
			local isSelected = (Config.Multiple and table.find(Dropdown.Value, i))
				or (not Config.Multiple and i == Value)
			updateButtonTransparency(button, isSelected)
		end

		if not ignore then
			Config.Callback(Dropdown.Value)
		end
	end

	Dropdown:Refresh(Dropdown.Options, false)
	Dropdown:Set(Dropdown.Value, Config.IgnoreFirst)

	self.Library.Flags[Idx] = Dropdown
	return Dropdown
end

return Element

end)() end,
    [15] = function()local wax,script,require=ImportGlobals(15)local ImportGlobals return (function(...)local Components = script.Parent.Parent.components

local Element = {}
Element.__index = Element
Element.__type = "Paragraph"

function Element:New(Config)
	assert(Config.Title, "Paragraph - Missing Title")
	Config.Description = Config.Description or nil

	local paragraph = require(Components.element)(Config.Title, Config.Description, self.Container)

	return paragraph
end

return Element

end)() end,
    [16] = function()local wax,script,require=ImportGlobals(16)local ImportGlobals return (function(...)local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local function Round(Number, Factor)
    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then
        Result = Result + Factor
    end
    return Result
end

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, Config)
    local Library = self.Library
    assert(Config.Title, "Slider - Missing Title")
    Config.Description = Config.Description or nil

    Config.Min = Config.Min or 10
    Config.Max = Config.Max or 20
    Config.Increment = Config.Increment or 1
    Config.Default = Config.Default or 0
    Config.IgnoreFirst = Config.IgnoreFirst or false

    local Slider = {
        Value = Config.Default,
        Min = Config.Min,
        Max = Config.Max,
        Increment = Config.Increment,
        IgnoreFirst = Config.IgnoreFirst,
        Callback = Config.Callback or function(Value) end,
        Type = "Slider",
    }

    local Dragging = false
    local DraggingDot = false

    local SliderFrame = require(Components.element)(Config.Title, Config.Description, self.Container)

    local ValueText = Create("TextLabel", {
        Font = Enum.Font.GothamMedium,
        RichText = true,
        Text = "fix it good pls",
        ThemeProps = {
            TextColor3 = "titlecolor",
        },
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.754537523, 8, 0, 0),
        Size = UDim2.new(0, 100, 0, 18), -- Larger value display
        Visible = true,
        Parent = SliderFrame.topbox,
    })

    local SliderBar = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        ThemeProps = { BackgroundColor3 = "sliderbar" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 30),
        Size = UDim2.new(1, -8, 0, 4), -- Thicker slider bar
        Visible = true,
        Parent = SliderFrame.Frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
            Archivable = true,
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderbarstroke" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
            Archivable = true,
        }),
    })

    local SliderProgress = Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        ThemeProps = { BackgroundColor3 = "sliderprogressbg" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Visible = true,
        Parent = SliderBar,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
            Archivable = true,
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderprogressborder" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
            Archivable = true,
        }),
    })

    local SliderDot = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        ThemeProps = { BackgroundColor3 = "sliderdotbg" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14), -- Larger dot
        Visible = true,
        Parent = SliderBar,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderdotstroke" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 2,
            Archivable = true,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Archivable = true,
        }),
    })

    function Slider:Set(Value, ignore)
        self.Value = math.clamp(Round(Value, Config.Increment), Config.Min, Config.Max)
        ValueText.Text = string.format("%s<font transparency='0.5'>/%s</font>", tostring(self.Value), Config.Max)
        
        local newPosition = (self.Value - Config.Min) / (Config.Max - Config.Min)
        
        if DraggingDot then
            SliderDot.Position = UDim2.new(newPosition, 0, 0.5, 0)
            SliderProgress.Size = UDim2.fromScale(newPosition, 1)
        else
            TweenService:Create(SliderDot, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(newPosition, 0, 0.5, 0)
            }):Play()
            
            TweenService:Create(SliderProgress, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.fromScale(newPosition, 1)
            }):Play()
        end
        
        if not ignore then
            return Config.Callback(self.Value)
        end
    end

    local function updateSliderFromInput(inputPosition)
        if Dragging then
            local barPosition = SliderBar.AbsolutePosition
            local barSize = SliderBar.AbsoluteSize
            local relativeX = (inputPosition.X - barPosition.X) / barSize.X
            local clampedPosition = math.clamp(relativeX, 0, 1)
            local newValue = Config.Min + (Config.Max - Config.Min) * clampedPosition
            Slider:Set(newValue)
        end
    end

    AddConnection(SliderBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            updateSliderFromInput(input.Position)
        end
    end)

    AddConnection(SliderDot.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DraggingDot = true
            updateSliderFromInput(input.Position)
        end
    end)

    AddConnection(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            DraggingDot = false
        end
    end)

    AddConnection(UserInputService.InputChanged, function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSliderFromInput(input.Position)
        end
    end)

    Slider:Set(Config.Default, Config.IgnoreFirst)

    Library.Flags[Idx] = Slider
    return Slider
end

return Element
end)() end,
    [17] = function()local wax,script,require=ImportGlobals(17)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local Element = {}
Element.__index = Element
Element.__type = "Textbox"

function Element:New(Config)
    assert(Config, "Textbox - Missing Config table")
    assert(Config.Title, "Textbox - Missing Title")
    Config.Description = Config.Description or nil
    Config.PlaceHolder = Config.PlaceHolder or ""
    Config.Default = Config.Default or ""
    Config.TextDisappear = Config.TextDisappear or false
    Config.Callback = Config.Callback or function() end

    local Textbox = {
        Value = Config.Default or "",
        Callback = Config.Callback,
        Type = "Textbox",
    }

    local TextboxFrame = require(Components.element)(Config.Title, Config.Description, self.Container)

    local textbox = Create("TextBox", {
        CursorPosition = -1,
        Font = Enum.Font.GothamMedium,
        PlaceholderText = Config.PlaceHolder,
        Text = Textbox.Value,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35), -- Taller textbox
        Visible = true,
        Parent = TextboxFrame.Frame,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 0),
            Archivable = true,
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 2,
            Archivable = true,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Archivable = true,
        }),
    })

    function Textbox:Set(value)
        textbox.Text = value
        Textbox.Value = value
        Config.Callback(value)
    end

    AddConnection(textbox.FocusLost, function()
        Textbox.Value = textbox.Text
        Config.Callback(Textbox.Value)
        if Config.TextDisappear then
            textbox.Text = ""
        end
    end)

    return Textbox
end

return Element

end)() end,
    [18] = function()local wax,script,require=ImportGlobals(18)local ImportGlobals return (function(...)local TweenService = game:GetService("TweenService")
local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local Element = {}
Element.__index = Element
Element.__type = "Toggle"

function Element:New(Idx, Config)
    local Library = self.Library
    assert(Config.Title, "Toggle - Missing Title")
    Config.Description = Config.Description or nil
    Config.Default = Config.Default or false
    Config.IgnoreFirst = Config.IgnoreFirst or false

    local Toggle = {
        Value = Config.Default,
        Callback = Config.Callback or function(Value) end,
        IgnoreFirst = Config.IgnoreFirst,
        Type = "Toggle",
    }

    local ToggleFrame = require(Components.element)("        " .. Config.Title, Config.Description, self.Container)

    local box_frame = Create("Frame", {
        ThemeProps = {
            BackgroundColor3 = "togglebg",
        },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 18, 0, 18), -- Larger toggle
        Visible = true,
        Parent = ToggleFrame.topbox,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Archivable = true,
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "toggleborder",
            },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 2,
            Archivable = true,
        }),
        Create("ImageLabel", {
            Image = "http://www.roblox.com/asset/?id=6031094667",
            ThemeProps = {
                ImageColor3 = "maincolor"
            },
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14), -- Larger checkmark
            Visible = true,
        })
    })

    function Toggle:Set(Value, ignore)
        self.Value = Value
        TweenService:Create(box_frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = self.Value and 0 or 1
        }):Play()
        if not ignore and (not self.IgnoreFirst or not self.FirstUpdate) then
            Library:Callback(Toggle.Callback, self.Value)
        end
        self.FirstUpdate = false
    end

    AddConnection(ToggleFrame.Frame.MouseButton1Click, function()
        Toggle:Set(not Toggle.Value)
    end)

    Toggle:Set(Toggle.Value, Config.IgnoreFirst)

    Library.Flags[Idx] = Toggle
    return Toggle
end

return Element

end)() end,
    [19] = function()local wax,script,require=ImportGlobals(19)local ImportGlobals return (function(...)local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local tools = { Signals = {} }

-- ===== ENHANCED THEME SYSTEM =====
local themes = {
    default = {
        maincolor = Color3.fromRGB(25, 25, 30),
        bordercolor = Color3.fromRGB(60, 60, 70),
        titlecolor = Color3.fromRGB(255, 255, 255),
        descriptioncolor = Color3.fromRGB(180, 180, 180),
        elementdescription = Color3.fromRGB(160, 160, 160),
        scrollcolor = Color3.fromRGB(100, 100, 110),
        togglebg = Color3.fromRGB(100, 150, 255),
        toggleborder = Color3.fromRGB(80, 130, 235),
        sliderbar = Color3.fromRGB(50, 50, 60),
        sliderbarstroke = Color3.fromRGB(70, 70, 80),
        sliderprogressbg = Color3.fromRGB(100, 150, 255),
        sliderprogressborder = Color3.fromRGB(80, 130, 235),
        sliderdotbg = Color3.fromRGB(255, 255, 255),
        sliderdotstroke = Color3.fromRGB(100, 150, 255),
        containeritemsbg = Color3.fromRGB(30, 30, 35),
        itembg = Color3.fromRGB(40, 40, 45),
        itemcheckmarkcolor = Color3.fromRGB(100, 150, 255),
        itemTextOn = Color3.fromRGB(255, 255, 255),
        itemTextOff = Color3.fromRGB(160, 160, 160),
        valuebg = Color3.fromRGB(100, 150, 255),
        valuetext = Color3.fromRGB(255, 255, 255),
        onTextBtn = Color3.fromRGB(255, 255, 255),
        offTextBtn = Color3.fromRGB(160, 160, 160),
        onBgLineBtn = Color3.fromRGB(100, 150, 255),
        offBgLineBtn = Color3.fromRGB(60, 60, 70),
    }
}

local currentTheme = themes.default
local themedObjects = {}

-- Enhanced theme management
function tools.SetTheme(themeName)
	if themes[themeName] then
		currentTheme = themes[themeName]
		for _, item in pairs(themedObjects) do
			local obj = item.object
			local props = item.props
			for propName, themeKey in next, props do
				if currentTheme[themeKey] then
					obj[propName] = currentTheme[themeKey]
				end
			end
		end
		print("Theme changed to:", themeName)
	else
		warn("Theme not found: " .. themeName)
	end
end

function tools.GetPropsCurrentTheme()
	return currentTheme
end

function tools.AddTheme(themeName, themeProps)
	themes[themeName] = themeProps
	print("Theme added:", themeName)
end

-- ===== ENHANCED MOBILE DETECTION =====
function tools.isMobile()
    local isTouchDevice = UserInputService.TouchEnabled
    local hasKeyboard = UserInputService.KeyboardEnabled
    local hasMouse = UserInputService.MouseEnabled
    
    return isTouchDevice and not hasKeyboard and not hasMouse
end

-- ===== ENHANCED CONNECTION MANAGEMENT =====
function tools.AddConnection(Signal, Function)
	local connection = Signal:Connect(Function)
	table.insert(tools.Signals, connection)
	return connection
end

-- Enhanced disconnect with error handling
function tools.Disconnect()
	for key = #tools.Signals, 1, -1 do
		local Connection = table.remove(tools.Signals, key)
		if Connection and Connection.Connected then
			pcall(function()
				Connection:Disconnect()
			end)
		end
	end
end

-- ===== ENHANCED CREATE FUNCTION =====
function tools.Create(Name, Properties, Children)
	local Object = Instance.new(Name)

	-- Enhanced theme property handling
	if Properties.ThemeProps then
		for propName, themeKey in next, Properties.ThemeProps do
			if currentTheme[themeKey] then
				Object[propName] = currentTheme[themeKey]
			end
		end
		table.insert(themedObjects, { object = Object, props = Properties.ThemeProps })
		Properties.ThemeProps = nil
	end

	-- Apply properties with error handling
	for i, v in next, Properties or {} do
		pcall(function()
			Object[i] = v
		end)
	end
	
	-- Apply children with error handling
	for i, v in next, Children or {} do
		pcall(function()
			v.Parent = Object
		end)
	end
	
	return Object
end

-- ===== ENHANCED SCROLL ANIMATION =====
function tools.AddScrollAnim(scrollbar)
	local visibleTween = TweenService:Create(scrollbar, TweenInfo.new(0.3), { ScrollBarImageTransparency = 0 })
	local invisibleTween = TweenService:Create(scrollbar, TweenInfo.new(0.3), { ScrollBarImageTransparency = 0.8 })
	local lastInteraction = tick()
	local delayTime = 0.8

	local function showScrollbar()
		visibleTween:Play()
	end

	local function hideScrollbar()
		if tick() - lastInteraction >= delayTime then
			invisibleTween:Play()
		end
	end

	-- Enhanced event handling
	tools.AddConnection(scrollbar.MouseEnter, function()
		lastInteraction = tick()
		showScrollbar()
	end)

	tools.AddConnection(scrollbar.MouseLeave, function()
		task.wait(delayTime)
		hideScrollbar()
	end)

	tools.AddConnection(scrollbar.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			lastInteraction = tick()
			showScrollbar()
		end
	end)

	tools.AddConnection(scrollbar:GetPropertyChangedSignal("CanvasPosition"), function()
		lastInteraction = tick()
		showScrollbar()
	end)

	tools.AddConnection(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			lastInteraction = tick()
			showScrollbar()
		end
	end)

	-- Use heartbeat for better performance
	tools.AddConnection(RunService.Heartbeat, function()
		if tick() - lastInteraction >= delayTime then
			hideScrollbar()
		end
	end)
end

-- ===== ENHANCED UTILITY FUNCTIONS =====
function tools.GetScreenSize()
	local camera = workspace.CurrentCamera
	return camera.ViewportSize
end

function tools.IsInViewport(object)
	if not object or not object.Parent then return false end
	
	local camera = workspace.CurrentCamera
	local viewportSize = camera.ViewportSize
	local objectPosition = object.AbsolutePosition
	local objectSize = object.AbsoluteSize
	
	return objectPosition.X >= 0 and objectPosition.Y >= 0 and
		   objectPosition.X + objectSize.X <= viewportSize.X and
		   objectPosition.Y + objectSize.Y <= viewportSize.Y
end

-- ===== PERFORMANCE MONITORING =====
function tools.GetPerformanceStats()
	local stats = game:GetService("Stats")
	return {
		FPS = math.floor(1 / stats.FrameTime * 10) / 10,
		Ping = math.floor(stats.PerformanceStats.Ping:GetValue() * 100) / 100,
		Memory = math.floor(stats:GetTotalMemoryUsageMb() * 100) / 100
	}
end

-- ===== ENHANCED ERROR HANDLING =====
function tools.SafeCall(func, ...)
	local success, result = pcall(func, ...)
	if not success then
		warn("SafeCall error:", result)
	end
	return success, result
end

-- ===== ENHANCED CLEANUP FUNCTION =====
function tools.Cleanup()
	tools.Disconnect()
	
	-- Clear themed objects
	for i = #themedObjects, 1, -1 do
		themedObjects[i] = nil
	end
	
	print("Enhanced tools cleanup completed")
end

return tools

end)() end
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    [2] = 8,
    [4] = 651,
    [5] = 804,
    [6] = 930,
    [7] = 1116,
    [8] = 1328,
    [10] = 1657,
    [11] = 1665,
    [12] = 1794,
    [13] = 1974,
    [14] = 2416,
    [15] = 2929,
    [16] = 2947,
    [17] = 3158,
    [18] = 3245,
    [19] = 3335
}

-- Misc AOT variable imports
local WaxVersion = "0.4.1"
local EnvName = "WaxRuntime"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end -- lol

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
-- module path, "@lune/task"
if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

-- If we're not running on the Roblox engine, we won't have a `task` global
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

-- ClassName "IDs"
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {} -- [RefId] = RealObject

local ScriptClosures = {}
local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
local StoredModuleValues = {}
local ScriptsToRun = {}

-- wax.shared __index/__newindex
local SharedEnvironment = {}

-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
-- It's meant to be as lazy as possible
local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

-- Implemented instance methods
local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
            ObjectPointer = ObjectPointer.Parent
        end

        return Path
    end},

    GetChildren = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)
        end

        return ReturnArray
    end},

    GetDescendants = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)

            for _, Descendant in next, Child:GetDescendants() do
                table_insert(ReturnArray, Descendant)
            end
        end

        return ReturnArray
    end},

    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
        local Children = RefChildren[self]

        for Child in next, Children do
            if Child.Name == name then
                return Child
            end
        end

        if recursive then
            for Child in next, Children do
                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
                -- ref first, the engine uses a direct recursive call
                return Child:FindFirstChild(name, true)
            end
        end
    end},

    FindFirstAncestor = { {"string"}, function(self, name)
        local RefPointer = self.Parent
        while RefPointer do
            if RefPointer.Name == name then
                return RefPointer
            end

            RefPointer = RefPointer.Parent
        end
    end},

    -- Just to implement for traversal usage
    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

-- "Proxies" to instance methods, with err checks etc
local InstanceMethodProxies = {}
for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]

    local EvaluatedTypeInfo = {}
    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
    end

    InstanceMethodProxies[MethodName] = function(self, ...)
        if not RefChildren[self] then
            error("Expected ':' not '.' calling member function " .. MethodName, 2)
        end

        local Args = {...}
        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
            local RealArg = Args[ArgIndex]
            local RealArgType = type(RealArg)
            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]

            if RealArg == nil and not IsOptional then
                error("Argument " .. RealArg .. " missing or nil", 3)
            end

            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
            end
        end

        return Method(self, ...)
    end
end

local function CreateRef(className, name, parent)
    -- `name` and `parent` can also be set later by the init script if they're absent

    -- Extras
    local StringValue_Value

    -- Will be set to RefChildren later aswell
    local Children = setmetatable({}, {__mode = "k"})

    -- Err funcs
    local function InvalidMember(member)
        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
    end
    local function ReadOnlyProperty(property)
        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
    end

    local Ref = {}
    local RefMetatable = {}

    RefMetatable.__metatable = false

    RefMetatable.__index = function(_, index)
        if index == "ClassName" then -- First check "properties"
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            return StringValue_Value
        else -- Lastly, check "methods"
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        -- Next we'll look thru child refs
        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        -- At this point, no member was found; this is the same err format as Roblox
        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        -- __newindex is only for props fyi
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            -- We'll just ignore the process if it's trying to set itself
            if value == Ref then
                return
            end

            if parent ~= nil then
                -- Remove this ref from the CURRENT parent
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                -- And NOW we're setting the new parent
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            StringValue_Value = value
        else
            -- Same err as __index when no member is found
            InvalidMember(index)
        end
    end

    RefMetatable.__tostring = function()
        return name
    end

    setmetatable(Ref, RefMetatable)

    RefChildren[Ref] = Children

    if parent ~= nil then
        RefChildren[parent][Ref] = true
    end

    return Ref
end

-- Create real ref DOM from object tree
local function CreateRefFromObject(object, parent)
	local RefId = object[1]
	local ClassNameId = object[2]
	local Properties = object[3] -- Optional
	local Children = object[4] -- Optional

	local ClassName = ClassNameIdBindings and ClassNameIdBindings[ClassNameId]
	if not ClassName then
		warn("⚠️ ClassNameId invalid or not bound: ", ClassNameId)
		return
	end

	local Name = Properties and table.remove(Properties, 1) or ClassName
	local Ref = CreateRef(ClassName, Name, parent)
	RefBindings[RefId] = Ref

	if Properties and type(Properties) == "table" then
		for PropertyName, PropertyValue in next, Properties do
			Ref[PropertyName] = PropertyValue
		end
	end

	if Children and type(Children) == "table" then
		for _, ChildObject in next, Children do
			if type(ChildObject) == "table" then
				CreateRefFromObject(ChildObject, Ref)
			end
		end
	end

	return Ref
end

-- Ensure ObjectTree is valid
local RealObjectRoot = CreateRef("Folder", "[" .. (EnvName or "Unknown") .. "]")
if type(ObjectTree) == "table" then
	for _, Object in next, ObjectTree do
		if type(Object) == "table" then
			CreateRefFromObject(Object, RealObjectRoot)
		else
			warn("⚠️ ObjectTree contains non-table entry, skipped.")
		end
	end
else
	warn("❌ ObjectTree is nil or not a table, skipping CreateRefFromObject")
end

-- Bind closures to references and prepare scripts
if type(ClosureBindings) == "table" and type(RefBindings) == "table" then
	for RefId, Closure in next, ClosureBindings do
		local Ref = RefBindings[RefId]
		if Ref then
			ScriptClosures[Ref] = Closure
			ScriptClosureRefIds[Ref] = RefId

			local ClassName = Ref.ClassName
			if ClassName == "LocalScript" or ClassName == "Script" then
				table.insert(ScriptsToRun, Ref)
			end
		else
			warn("⚠️ RefBinding missing for RefId:", RefId)
		end
	end
else
	warn("❌ ClosureBindings or RefBindings is nil or not a table")
end


local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]
    
    -- CRITICAL FIX: Check if Closure is nil
    if not Closure then
        error("Script closure not found for " .. scriptRef:GetFullName() .. ". This usually means the script was not properly compiled or included in the build.", 2)
    end

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]

        local RealErrorLine = OriginalErrorLine - LineOffset + 1
        if RealErrorLine < 0 then
            RealErrorLine = "?"
        end

        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
    end

    -- If it's a BaseScript, we'll just run it directly!
    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
        local RunSuccess, ErrorMessage = pcall(Closure)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {pcall(Closure)}

        local RunSuccess = table_remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)
            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn
        return unpack(PCallReturn)
    end
end

-- We'll assign the actual func from the top of this output for flattening user globals at runtime
-- Returns (in a tuple order): wax, script, require
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]

    local function RealCall(f, ...)
        local PCallReturn = {pcall(f, ...)}

        local CallSuccess = table_remove(PCallReturn, 1)
        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end

    -- `wax.shared` index
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value)
            SharedEnvironment[index] = value
        end,
        __len = function()
            return #SharedEnvironment
        end,
        __iter = function()
            return next, SharedEnvironment
        end,
    }))

    local Global_wax = table_freeze({
        -- From AOT variable imports
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

        -- "Real" globals instead of the env set ones
        script = script,
        require = require,
    })

    local Global_script = ScriptRef

    local function Global_require(module, ...)
        local ModuleArgType = type(module)

        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
        local ErrorSelfRequire = "Attempted to call require with self"

        if ModuleArgType == "table" and RefChildren[module]  then
            if module.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
            -- The control flow on this SUCKS

            if #module == 0 then
                error("Attempted to call require with empty string", 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == "/" then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == "./" then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch
            for PathMatch in string_gmatch(module, "([^/]*)/?") do
                local RealIndex = PathMatch
                if PathMatch == ".." then
                    RealIndex = "Parent"
                end

                -- Don't advance dir if it's just another "/" either
                if RealIndex ~= "" then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent
                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end

                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
                        error("Virtual script path \"" .. module .. "\" not found", 2)
                    end
                end

                -- For possible checks next cycle
                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    -- Now, return flattened globals ready for direct runtime exec
    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end

-- AoT adjustment: Load init module (MainModule behavior)
return LoadScript(RealObjectRoot:GetChildren()[1])
