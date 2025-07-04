-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    function()local wax,script,require=ImportGlobals(1)local ImportGlobals return (function(...)wait(1)

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

-- ===== SERVICE IMPORTS =====
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ===== MODULE IMPORTS =====
local ElementsTable = require(script.elements)
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
	
	AddConnection(DragPoint.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			MousePos = Input.Position
			FramePos = Main.Position

			-- Enhanced drag animation
			TweenService:Create(Main, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Size = Main.Size - UDim2.new(0, 2, 0, 2)
			}):Play()

			AddConnection(Input.Changed, function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
					-- Reset size with smooth animation
					TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Main.Size + UDim2.new(0, 2, 0, 2)
					}):Play()
				end
			end)
		end
	end)
	
	AddConnection(DragPoint.InputChanged, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = Input
		end
	end)
	
	AddConnection(UserInputService.InputChanged, function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and Dragging then
			local Delta = Input.Position - MousePos
			local newPosition = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			
			-- Smooth dragging animation
			TweenService:Create(Main, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
				Position = newPosition
			}):Play()
		end
	end)
end

-- ===== MAIN LIBRARY =====
local Library = {
	Window = nil,
	Flags = {},
	Signals = {},
	ToggleBind = nil,
	Version = "2.1.0", -- Updated version
	Author = "Enhanced Xenon Team",
	_isRunning = true,
	_connections = {},
	_threads = {},
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
	Tools.SetTheme(themeName)
	-- Trigger visual refresh
	self:_refreshTheme()
end

function Library:_refreshTheme()
	-- Enhanced theme refresh with smooth transitions
	for _, connection in pairs(Tools.themedObjects or {}) do
		if connection.object and connection.object.Parent then
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(connection.object, tweenInfo, {}):Play()
		end
	end
end

function Library:GetTheme()
	return Tools.GetPropsCurrentTheme()
end

function Library:AddTheme(themeName, themeProps)
	Tools.AddTheme(themeName, themeProps)
end

function Library:IsRunning()
	return self._isRunning and GUI.Parent == gethui()
end

-- ===== ENHANCED CLEANUP SYSTEM =====
function Library:Destroy()
	print("🔄 Starting enhanced cleanup...")
	
	-- Stop all running state
	self._isRunning = false
	
	-- Disconnect all custom connections
	for i, connection in pairs(self._connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
		self._connections[i] = nil
	end
	
	-- Stop all running threads/coroutines
	for i, thread in pairs(self._threads) do
		if thread and coroutine.status(thread) ~= "dead" then
			-- Force stop thread (this is a conceptual approach - Lua doesn't have direct thread killing)
			pcall(function() coroutine.close(thread) end)
		end
		self._threads[i] = nil
	end
	
	-- Enhanced GUI cleanup with fade animation
	if GUI then
		local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local fadeTween = TweenService:Create(GUI, fadeInfo, {
			Enabled = false
		})
		
		fadeTween:Play()
		fadeTween.Completed:Connect(function()
			GUI:Destroy()
		end)
	end
	
	-- Cleanup tools and connections
	for i, Connection in pairs(Tools.Signals or {}) do
		if Connection and Connection.Connected then
			Connection:Disconnect()
		end
		Tools.Signals[i] = nil
	end
	
	-- Clear all references
	table.clear(self.Flags)
	table.clear(self.Signals)
	
	-- Force garbage collection
	collectgarbage("collect")
	
	print("✅ Enhanced cleanup completed - All scripts and connections stopped")
end

-- Enhanced background cleanup task with better monitoring
task.spawn(function()
	while Library:IsRunning() do
		task.wait(1)
		
		-- Monitor performance and cleanup if needed
		local memoryUsage = collectgarbage("count")
		if memoryUsage > 100000 then -- 100MB threshold
			collectgarbage("collect")
		end
	end
	Library:Destroy()
end)

-- ===== ELEMENTS SYSTEM =====
local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
	return Elements[Key](...)
end

-- Dynamic element registration with enhanced features
for _, ElementComponent in ipairs(ElementsTable) do
	assert(ElementComponent.__type, "ElementComponent missing __type")
	assert(type(ElementComponent.New) == "function", "ElementComponent missing New function")

	Elements["Add" .. ElementComponent.__type] = function(self, Idx, Config)
		ElementComponent.Container = self.Container
		ElementComponent.Type = self.Type
		ElementComponent.ScrollFrame = self.ScrollFrame
		ElementComponent.Library = Library

		local element = ElementComponent:New(Idx, Config)
		
		-- Add enhanced entrance animation
		if element and element.Frame then
			element.Frame.Position = element.Frame.Position + UDim2.new(0, 50, 0, 0)
			element.Frame.BackgroundTransparency = 1
			
			TweenService:Create(element.Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = element.Frame.Position - UDim2.new(0, 50, 0, 0),
				BackgroundTransparency = 0
			}):Play()
		end
		
		return element
	end
end

Library.Elements = Elements

-- ===== ENHANCED CALLBACK SYSTEM =====
function Library:Callback(Callback, ...)
	local success, result = pcall(Callback, ...)

	if success then
		return result
	else
		local errorMessage = tostring(result)
		local errorLine = string.match(errorMessage, ":(%d+):")
		local errorInfo = `✨ Enhanced Callback Error ✨\n`
		errorInfo = errorInfo .. `🔍 Error: {errorMessage}\n`

		if errorLine then
			errorInfo = errorInfo .. `📍 Line: {errorLine}\n`
		end

		errorInfo = errorInfo .. `💡 Tip: Check function implementation for potential issues`
		warn(errorInfo)
	end
end

-- ===== ENHANCED NOTIFICATION SYSTEM =====
function Library:Notification(titleText, descriptionText, duration)
	require(Components.notif):ShowNotification(titleText, descriptionText, duration or 5)
end

-- ===== DIALOG SYSTEM (PRESERVED) =====
function Library:Dialog(config)
    return require(Components.dialog):Create(config, self.LoadedWindow)
end

-- ===== MAIN WINDOW CREATION =====
function Library:Load(cfgs)
	cfgs = cfgs or {}
	cfgs.Title = cfgs.Title or "✨ Enhanced Xentix UI Library"
	cfgs.ToggleButton = cfgs.ToggleButton or ""
	cfgs.BindGui = cfgs.BindGui or Enum.KeyCode.RightControl
	cfgs.Size = cfgs.Size or UDim2.new(0, 680, 0, 420) -- Slightly larger for better visuals
	cfgs.Position = cfgs.Position or UDim2.new(0.5, 0, 0.3, 0)

	if Library.Window then
		warn("❌ Cannot create more than one window.")
		return
	end
	
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
		Visible = false
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 12), -- More rounded corners
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Thickness = 2, -- Thicker border
		}),
		-- Enhanced shadow effect
		Create("ImageLabel", {
			Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
			ImageColor3 = Color3.new(0, 0, 0),
			ImageTransparency = 0.7,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 3, 0.5, 3),
			Size = UDim2.new(1, 6, 1, 6),
			ZIndex = -1,
		}),
	})

	-- Mobile optimization with better scaling
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
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 12),
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
		-- Glow effect
		Create("ImageLabel", {
			Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
			ImageColor3 = CurrentThemeProps.primarycolor or Color3.new(0.2, 0.6, 1),
			ImageTransparency = 0.8,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 10, 1, 10),
			ZIndex = -1,
		}),
	})

	-- ===== ENHANCED TOGGLE FUNCTIONALITY =====
	local function ToggleVisibility()
		local isVisible = canvas_group.Visible
		local endPosition = isVisible and UDim2.new(0.5, 0, -1, 0) or UDim2.new(0.5, 0, 0.5, 0)
		local toggleEndPosition = isVisible and UDim2.new(0.5, 8, 0, 0) or UDim2.new(0.5, 8, 0, 0)
	
		-- Enhanced animation with bounce effect
		local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local toggleTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
		local positionTween = TweenService:Create(canvas_group, tweenInfo, { Position = endPosition })
		local toggleRotation = TweenService:Create(togglebtn, toggleTweenInfo, { Rotation = isVisible and 0 or 180 })
	
		canvas_group.Visible = true
		togglebtn.Visible = false
	
		positionTween:Play()
		toggleRotation:Play()
	
		positionTween.Completed:Connect(function()
			if isVisible then
				canvas_group.Visible = false
				togglebtn.Visible = true
			end
		end)
	end

	-- Initial toggle with delay for smooth appearance
	task.wait(0.5)
	ToggleVisibility()

	-- Event connections
	MakeDraggable(togglebtn, togglebtn)
	AddConnection(togglebtn.MouseButton1Click, ToggleVisibility)
	AddConnection(UserInputService.InputBegan, function(value)
		if value.KeyCode == cfgs.BindGui then
			ToggleVisibility()
		end
	end)

	-- ===== ENHANCED TOP FRAME (TITLE BAR) =====
	local top_frame = Create("Frame", {
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderColor3 = Color3.fromRGB(39, 39, 42),
		Size = UDim2.new(1, 0, 0, 45), -- Taller for better proportions
		ZIndex = 9,
		Parent = canvas_group,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Thickness = 2,
		}),
		-- Gradient overlay for title bar
		Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0.9, 0.9, 0.95))
			}),
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.98),
				NumberSequenceKeypoint.new(1, 0.95)
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
		Position = UDim2.new(0, 18, 0, 0),
		Size = UDim2.new(0, 250, 0, 45),
		ZIndex = 10,
		Parent = top_frame,
	})

	-- ===== ENHANCED WINDOW CONTROLS =====
	local minimizebtn = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 0.9,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -42, 0.5, 0),
		Size = UDim2.new(0, 32, 0, 32),
		ZIndex = 10,
		Parent = top_frame,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		Create("ImageLabel", {
			Image = "rbxassetid://15269257100",
			ImageRectOffset = Vector2.new(514, 257),
			ImageRectSize = Vector2.new(256, 256),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -12, 1, -12),
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
		BackgroundColor3 = Color3.new(0.8, 0.2, 0.2), -- Red tint for close button
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 32, 0, 32),
		ZIndex = 10,
		Parent = top_frame,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		Create("ImageLabel", {
			Image = "rbxassetid://15269329696",
			ImageRectOffset = Vector2.new(0, 514),
			ImageRectSize = Vector2.new(256, 256),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -12, 1, -12),
			ImageColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 11,
		}),
	})

	-- Enhanced button animations
	local function setupButtonAnimations(button, hoverColor)
		AddConnection(button.MouseEnter, function()
			TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 0.7,
				BackgroundColor3 = hoverColor or CurrentThemeProps.primarycolor or Color3.new(0.3, 0.3, 0.3)
			}):Play()
		end)
		
		AddConnection(button.MouseLeave, function()
			TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 0.9,
				BackgroundColor3 = button == closebtn and Color3.new(0.8, 0.2, 0.2) or CurrentThemeProps.maincolor
			}):Play()
		end)
	end
	
	setupButtonAnimations(minimizebtn)
	setupButtonAnimations(closebtn, Color3.new(0.9, 0.3, 0.3))

	-- Button event connections with enhanced feedback
	AddConnection(minimizebtn.MouseButton1Click, function()
		-- Scale animation for feedback
		TweenService:Create(minimizebtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 28, 0, 28)
		}):Play()
		task.wait(0.1)
		TweenService:Create(minimizebtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 32, 0, 32)
		}):Play()
		ToggleVisibility()
	end)
	
	AddConnection(closebtn.MouseButton1Click, function()
		-- Enhanced close animation with scale and fade
		TweenService:Create(closebtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 28, 0, 28),
			BackgroundColor3 = Color3.new(1, 0.4, 0.4)
		}):Play()
		task.wait(0.1)
		Library:Destroy() -- Use enhanced destroy method
	end)

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
			Thickness = 2,
		}),
		-- Subtle gradient for sidebar
		Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0.95, 0.95, 1))
			}),
			Rotation = 0,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.99),
				NumberSequenceKeypoint.new(1, 0.97)
			})
		}),
	})

	-- ===== ENHANCED TAB HOLDER (SCROLLABLE) =====
	local TabHolder = Create("ScrollingFrame", {
		ThemeProps = {
			ScrollBarImageColor3 = "scrollcolor",
			BackgroundColor3 = "maincolor",
		},
		ScrollBarThickness = 3, -- Thicker scrollbar
		ScrollBarImageTransparency = 1,
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
			Padding = UDim.new(0, 4), -- Better spacing
		}),
	})

	-- Auto-resize canvas with smooth updates
	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		local newSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 32)
		TweenService:Create(TabHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			CanvasSize = newSize
		}):Play()
	end)

	AddScrollAnim(TabHolder)

	-- ===== CONTAINER FOLDER =====
	local containerFolder = Create("Folder", {
		Parent = canvas_group,
	})

	-- Make draggable (desktop only) with enhanced feedback
	if not isMobile then
		MakeDraggable(top_frame, canvas_group)
	end

	Library.LoadedWindow = canvas_group

	-- ===== ENHANCED TAB SYSTEM =====
	local Tabs = {}
	local TabModule = require(Components.tab):Init(containerFolder)
	
	function Tabs:AddTab(title)
		local tab = TabModule:New(title, TabHolder)
		
		-- Add entrance animation for new tabs
		if tab and tab.TabBtn then
			tab.TabBtn.Position = tab.TabBtn.Position + UDim2.new(0, -50, 0, 0)
			tab.TabBtn.BackgroundTransparency = 1
			
			TweenService:Create(tab.TabBtn, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = tab.TabBtn.Position - UDim2.new(0, -50, 0, 0),
				BackgroundTransparency = 0
			}):Play()
		end
		
		return tab
	end
	
	function Tabs:SelectTab(Tab)
		Tab = Tab or 1
		TabModule:SelectTab(Tab)
	end

	-- ===== ENHANCED METHODS =====
	function Tabs:GetCurrentTab()
		return TabModule.SelectedTab
	end

	function Tabs:GetTabCount()
		return TabModule.TabCount
	end

	function Tabs:RemoveTab(tabIndex)
		if TabModule.Tabs[tabIndex] then
			-- Add fade out animation before removal
			local tab = TabModule.Tabs[tabIndex]
			if tab and tab.TabBtn then
				TweenService:Create(tab.TabBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1
				}):Play()
				
				task.wait(0.3)
			end
			
			TabModule:CleanupTab(tabIndex)
		end
	end

	-- Auto-select first tab if available with delay
	task.spawn(function()
		task.wait(0.5)
		if TabModule.TabCount > 0 then
			Tabs:SelectTab(1)
		end
	end)

	-- Add welcome animation
	task.spawn(function()
		task.wait(0.2)
		local welcomeInfo = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		TweenService:Create(canvas_group, welcomeInfo, {
			Rotation = 0
		}):Play()
	end)

	return Tabs
end

-- ===== LIBRARY RETURN =====
return Library

end)() end,
    [3] = function()local wax,script,require=ImportGlobals(3)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local ButtonComponent = require(script.Parent.Parent.elements.buttons)

local Create = Tools.Create

local DialogModule = {}
local ActiveDialog = nil

function DialogModule:Create(config, parent)
    -- Remove existing dialog if any
    if ActiveDialog then
        ActiveDialog:Destroy()
    end

    local scrolling_frame = Instance.new("ScrollingFrame")
    scrolling_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrolling_frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrolling_frame.ScrollBarImageColor3 = Color3.new(0.109804, 0.109804, 0.117647)
    scrolling_frame.ScrollBarThickness = 4
    scrolling_frame.Active = true
    scrolling_frame.BackgroundColor3 = Color3.new(0, 0, 0)
    scrolling_frame.BackgroundTransparency = 0.1
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
    blocker.BackgroundTransparency = 1 -- Fully transparent
    blocker.Text = "" -- No text
    blocker.AutoButtonColor = false -- Prevents hover effects
    blocker.Parent = scrolling_frame

    local uipadding_3 = Instance.new("UIPadding")
    uipadding_3.PaddingBottom = UDim.new(0, 45)
    uipadding_3.PaddingTop = UDim.new(0, 45)
    uipadding_3.Parent = scrolling_frame

    local dialog = Create("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0, 400, 0, 0),
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Parent = scrolling_frame,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Thickness = 1,
        }),
    })

    local uilist_layout = Instance.new("UIListLayout")
    uilist_layout.SortOrder = Enum.SortOrder.LayoutOrder
    uilist_layout.Parent = dialog

    -- Create top bar with title
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        ThemeProps = { BackgroundColor3 = "maincolor" },
        Parent = dialog,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Thickness = 1,
        }),
        Create("TextLabel", {
            Font = Enum.Font.GothamMedium,
            Text = config.Title,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            BackgroundTransparency = 1,
            ThemeProps = { TextColor3 = "titlecolor" },
        }),
    })

    -- Create content container
    local content = Create("TextLabel", {
        Text = config.Content,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, -24, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 12, 0, 50),
        RichText = true,
        BackgroundTransparency = 1,
        ThemeProps = { TextColor3 = "descriptioncolor" },
        Parent = dialog,
    })

    local uipadding = Instance.new("UIPadding")
    uipadding.PaddingBottom = UDim.new(0, 8)
    uipadding.PaddingLeft = UDim.new(0, 12)
    uipadding.PaddingRight = UDim.new(0, 12)
    uipadding.PaddingTop = UDim.new(0, 8)
    uipadding.Parent = content

    -- Create button container
    local buttonContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
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
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    -- Add buttons
    for i, buttonConfig in ipairs(config.Buttons) do
        local wrappedCallback = function()
            buttonConfig.Callback()
            scrolling_frame:Destroy()
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
    [4] = function()local wax,script,require=ImportGlobals(4)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")
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
			Padding = UDim.new(0, 8), -- Better spacing
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
		-- Enhanced padding for elements
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
		Font = Enum.Font.GothamSemibold, -- Better font weight
		LineHeight = 1.3, -- Better line height
		RichText = true,
		Text = title,
		ThemeProps = {
			TextColor3 = "titlecolor",
			BackgroundColor3 = "maincolor",
		},
		TextSize = 15, -- Slightly larger
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
		TextSize = 13, -- Slightly smaller for hierarchy
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
			PaddingTop = UDim.new(0, 0),
		}),
	})

	-- Enhanced hover effects
	Element.Frame.MouseEnter:Connect(function()
		TweenService:Create(Element.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0.98
		}):Play()
	end)

	Element.Frame.MouseLeave:Connect(function()
		TweenService:Create(Element.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()
	end)

	function Element:SetTitle(Set)
		name.Text = Set
		-- Add subtle animation for title changes
		TweenService:Create(name, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			TextTransparency = 0
		}):Play()
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
		
		-- Add subtle animation for description changes
		if description.Visible then
			TweenService:Create(description, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				TextTransparency = 0
			}):Play()
		end
	end

	Element:SetDesc(desc)
	Element:SetTitle(title)

	function Element:Destroy()
		-- Enhanced destroy with fade animation
		TweenService:Create(Element.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		
		task.wait(0.3)
		Element.Frame:Destroy()
	end

	return Element
end

end)() end,
    [5] = function()local wax,script,require=ImportGlobals(5)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local Notif = {}

function Notif:Init(Gui)
    self.MainHolder = Create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0,0,0),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(0, 280, 0, 120), -- Slightly larger for better visuals
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
            Padding = UDim.new(0, 10), -- Better spacing between notifications
        })
    })
    
end

function Notif:ShowNotification(titleText, descriptionText, duration)
    local main = Create("CanvasGroup", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(15, 15, 18), -- Slightly lighter for better visibility
        BackgroundTransparency = 1, -- Start transparent for animation
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
            Color = Color3.fromRGB(35, 35, 38), -- Better border color
            Thickness = 1.5, -- Thicker border
        }),
        -- Enhanced shadow effect
        Create("ImageLabel", {
            Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.6,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 2, 0.5, 2),
            Size = UDim2.new(1, 4, 1, 4),
            ZIndex = -1,
        }),
    })

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
        ImageColor3 = Color3.fromRGB(100, 200, 255), -- Enhanced icon color
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20), -- Slightly larger icon
        Visible = true,
        Parent = topframe,
    })

    local title = Create("TextLabel", {
        Font = Enum.Font.GothamBold, -- Bold for better hierarchy
        LineHeight = 1.2,
        RichText = true,
        TextColor3 = Color3.fromRGB(240, 240, 245), -- Better contrast
        TextSize = 16,
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
        TextColor3 = Color3.fromRGB(200, 200, 210), -- Better description color
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
        BackgroundColor3 = Color3.fromRGB(100, 200, 255), -- Better progress color
        Size = UDim2.new(1, 0, 0, 3),
        Visible = true,
        Parent = progress,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
        -- Subtle glow effect for progress
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 220, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 180, 255))
            }),
            Rotation = 0,
        }),
    })

    -- Enhanced entrance animation with slide and scale
    main.Position = main.Position + UDim2.new(0, 100, 0, 0)
    main.Size = UDim2.new(0, 300, 0, 0)
    
    -- Slide in animation
    local slideInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local slideIn = TweenService:Create(main, slideInfo, {
        Position = main.Position - UDim2.new(0, 100, 0, 0),
        BackgroundTransparency = 0.1
    })
    slideIn:Play()

    -- Content fade in with stagger
    task.wait(0.2)
    local fadeInTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local fadeInTweenTitle = TweenService:Create(title, fadeInTweenInfo, {TextTransparency = 0})
    fadeInTweenTitle:Play()

    task.wait(0.1)
    local fadeInTweenDescription = TweenService:Create(description, fadeInTweenInfo, {TextTransparency = 0})
    fadeInTweenDescription:Play()

    task.wait(0.1)
    local fadeInTweenUser = TweenService:Create(user, fadeInTweenInfo, {ImageTransparency = 0})
    fadeInTweenUser:Play()

    -- Enhanced progress animation with easing
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(progressindicator, tweenInfo, {Size = UDim2.new(0, 0, 0, 3)})
    tween:Play()

    -- Enhanced exit animation
    tween.Completed:Connect(function()
        local exitInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local exitTween = TweenService:Create(main, exitInfo, {
            Position = main.Position + UDim2.new(0, 50, 0, -20),
            Size = UDim2.new(0, 280, 0, 0),
            BackgroundTransparency = 1
        })
        exitTween:Play()
        
        exitTween.Completed:Connect(function()
            main:Destroy()
        end)
    end)

    -- Add click to dismiss functionality
    local dismissButton = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = main,
        ZIndex = 5,
    })
    
    dismissButton.MouseButton1Click:Connect(function()
        local quickExit = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = main.Position + UDim2.new(0, 100, 0, 0),
            BackgroundTransparency = 1
        })
        quickExit:Play()
        quickExit.Completed:Connect(function()
            main:Destroy()
        end)
    end)
end

return Notif

end)() end,
    [6] = function()local wax,script,require=ImportGlobals(6)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection

return function(cfgs, Parent)
	cfgs = cfgs or {}
	cfgs.Title = cfgs.Title or nil
	cfgs.Description = cfgs.Description or nil
	cfgs.Defualt  = cfgs.Defualt or false
	cfgs.Locked = cfgs.Locked or false
	cfgs.TitleTextSize = cfgs.TitleTextSize or 14

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
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
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
			Thickness = 1.5, -- Thicker border
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8), -- More rounded
		}),
		-- ===== AUTOMATIC BEAUTIFUL GRADIENT =====
		Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245, 250, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 245, 255))
			}),
			Rotation = 45, -- Diagonal gradient
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.98),
				NumberSequenceKeypoint.new(0.5, 0.96),
				NumberSequenceKeypoint.new(1, 0.99)
			})
		}),
		Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
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
			Padding = UDim.new(0, 4), -- Better spacing
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
	})

	-- Enhanced chevron with better styling
	local chevronIcon = Create("ImageButton", {
		ThemeProps = {
			ImageColor3 = "titlecolor",
		},
		Image = "rbxassetid://15269180996",
		ImageRectOffset = Vector2.new(0, 257),
		ImageRectSize = Vector2.new(256, 256),
		BackgroundTransparency = 0.95,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 28, 0, 28), -- Larger click area
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Rotation = 90,
		Name = "chevron-down",
		ZIndex = 99,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
	})
	
	local name = Create("TextLabel", {
		Font = Enum.Font.GothamBold, -- Bold for section titles
		LineHeight = 1.2,
		RichText = true,
		ThemeProps = {
			TextColor3 = "titlecolor",
			BackgroundColor3 = "maincolor",
		},
		TextSize = 15, -- Slightly larger
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
		chevronIcon,
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 36),
			PaddingTop = UDim.new(0, 4),
		}),
	})
	
	if cfgs.description ~= nil and cfgs.description ~= "" then
		local description = Create("TextLabel", {
			Font = Enum.Font.Gotham,
			RichText = true,
			ThemeProps = {
				TextColor3 = "descriptioncolor",
				BackgroundColor3 = "maincolor",
			},
			TextSize = 13, -- Slightly smaller for hierarchy
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
		}, {
			Create("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
			}),
		})
		description.Text = cfgs.Description or ""
		description.Visible = cfgs.Description ~= nil
	end

	if cfgs.Title ~= nil and cfgs.Title ~= "" then
		name.Size = UDim2.new(1, 0, 0, 20) -- Taller for better proportions
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
			Padding = UDim.new(0, 8), -- Better spacing between elements
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 4),
			Archivable = true,
		}),
	})

	local isExpanded = cfgs.Defualt
	if cfgs.Defualt == true then
		chevronIcon.Rotation = 0
	end
	
	-- Enhanced toggle function with better animations
	local function toggleSection()
		isExpanded = not isExpanded
		local targetRotation = isExpanded and 0 or 90
		
		-- Enhanced chevron animation with bounce
		TweenService:Create(chevronIcon, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Rotation = targetRotation
		}):Play()
		
		-- Enhanced hover effect during animation
		TweenService:Create(chevronIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = isExpanded and 0.9 or 0.95
		}):Play()
		
		-- Enhanced container animation with smooth easing
		local targetSize = isExpanded and UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 20) or UDim2.new(1, 0, 0, 0)
		TweenService:Create(Section.SectionContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = targetSize
		}):Play()
	end
	
	-- Enhanced hover effects for chevron
	chevronIcon.MouseEnter:Connect(function()
		TweenService:Create(chevronIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0.85,
			Size = UDim2.new(0, 30, 0, 30)
		}):Play()
	end)
	
	chevronIcon.MouseLeave:Connect(function()
		TweenService:Create(chevronIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0.95,
			Size = UDim2.new(0, 28, 0, 28)
		}):Play()
	end)
	
	if cfgs.Locked == false then
		AddConnection(topbox.MouseButton1Click, toggleSection)
		AddConnection(chevronIcon.MouseButton1Click, toggleSection)
	end
	
	if cfgs.Locked == true then
		topbox:Destroy()
		-- When locked, show the section expanded by default
		Section.SectionContainer.Size = UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 20)
	end
	
	-- Enhanced content size monitoring with smooth updates
	AddConnection(Section.SectionContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if isExpanded then
			local newSize = UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 20)
			TweenService:Create(Section.SectionContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = newSize
			}):Play()
		end
	end)

	-- Add entrance animation for the section
	Section.SectionFrame.Size = UDim2.new(1, 0, 0, 0)
	Section.SectionFrame.BackgroundTransparency = 1
	
	task.spawn(function()
		task.wait(math.random() * 0.1) -- Slight delay for staggered effect
		TweenService:Create(Section.SectionFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
	end)

	return Section
end
end)() end,
    [7] = function()local wax,script,require=ImportGlobals(7)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)

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
	SearchContainers = {}, -- Track search containers separately
}

function TabModule:Init(Window)
	TabModule.Window = Window
	return TabModule
end

-- Add cleanup function to properly remove search containers
function TabModule:CleanupTab(TabIndex)
	-- Remove search container if it exists
	if TabModule.SearchContainers[TabIndex] then
		TabModule.SearchContainers[TabIndex]:Destroy()
		TabModule.SearchContainers[TabIndex] = nil
	end
	
	-- Remove other references
	if TabModule.Containers[TabIndex] then
		TabModule.Containers[TabIndex]:Destroy()
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
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36), -- Taller tabs
		Parent = Parent,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8), -- Rounded tabs
		}),
		Create("TextLabel", {
			Name = "Title",
			Font = Enum.Font.GothamSemibold, -- Better font weight
			TextColor3 = Color3.fromRGB(63, 63, 63),
			TextSize = 14,
			ThemeProps = {
				BackgroundColor3 = "maincolor",
			},
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 18, 0.5, 0), -- Better spacing
			Size = UDim2.new(0.8, 0, 0.9, 0),
			Text = Title,
		}),
		Create("Frame", {
			Name = "Line",
			BackgroundColor3 = Color3.fromRGB(29, 29, 29),
			Position = UDim2.new(0, 6, 0, 0), -- Better positioning
			Size = UDim2.new(0, 3, 1, 0), -- Thicker line
			BorderSizePixel = 0,
		}, {
			Create("UICorner", {
				CornerRadius = UDim.new(1, 0), -- Rounded line
			}),
		}),
	})

	-- Enhanced tab hover effects
	Tab.TabBtn.MouseEnter:Connect(function()
		if not Tab.Selected then
			TweenService:Create(Tab.TabBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 0.95
			}):Play()
		end
	end)

	Tab.TabBtn.MouseLeave:Connect(function()
		if not Tab.Selected then
			TweenService:Create(Tab.TabBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 1
			}):Play()
		end
	end)

	-- Check if search container already exists for this position and remove it
	local existingSearchContainer = nil
	for _, child in ipairs(Parent:GetChildren()) do
		if child.Name == "SearchContainer_" .. TabIndex then
			existingSearchContainer = child
			break
		end
	end
	
	if existingSearchContainer then
		existingSearchContainer:Destroy()
	end

	-- Enhanced search container with better styling
	Tab.SearchContainer = Create("Frame", {
		Name = "SearchContainer_" .. TabIndex,
		Size = UDim2.new(1, 0, 0, 40), -- Taller for better proportions
		BackgroundTransparency = 1,
		Parent = Parent,
		LayoutOrder = TabIndex + 100, -- Ensure it appears after the tab button
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		Visible = false, -- Initially hidden
	})

	local SearchBox = Create("TextBox", {
		Size = UDim2.new(1, -12, 0, 36),
		Position = UDim2.new(0, 6, 0, 2),
		PlaceholderText = "🔍 Search elements...",
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
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
			Thickness = 1.5,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})

	-- Enhanced search box animations
	SearchBox.Focused:Connect(function()
		TweenService:Create(SearchBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0.9
		}):Play()
	end)

	SearchBox.FocusLost:Connect(function()
		TweenService:Create(SearchBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0.95
		}):Play()
	end)

	Tab.Container = Create("ScrollingFrame", {
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ThemeProps = {
			ScrollBarImageColor3 = "scrollocolor",
			BackgroundColor3 = "maincolor",
		},
		ScrollBarThickness = 3, -- Thicker scrollbar
		ScrollBarImageTransparency = 1,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 150, 0, 45),
		Size = UDim2.new(1, -150, 1, -45),
		Visible = false,
		Parent = TabModule.Window,
	}, {
		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8), -- Better spacing between sections
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
		local newSize = UDim2.new(0, 0, 0, Tab.Container.UIListLayout.AbsoluteContentSize.Y + 32)
		TweenService:Create(Tab.Container, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			CanvasSize = newSize
		}):Play()
	end)

	-- Function to filter elements based on search text with enhanced logic
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

		-- Enhanced search with smooth animations
		for _, child in ipairs(Tab.Container:GetChildren()) do
			if child.Name == "Section" then
				local sectionContainer = child:FindFirstChild("SectionContainer")
				if sectionContainer then
					local visible = false
					debugLog("Checking section:", child.Name)

					for _, element in ipairs(sectionContainer:GetChildren()) do
						if element.Name == "Element" then
							local elementVisible = searchInElement(element, searchText)
							
							-- Smooth visibility transitions
							if elementVisible or searchText == "" then
								element.Visible = true
								TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
									Size = element.Size,
									BackgroundTransparency = element.BackgroundTransparency
								}):Play()
							else
								TweenService:Create(element, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
									Size = UDim2.new(1, 0, 0, 0),
									BackgroundTransparency = 1
								}):Play()
								
								task.wait(0.2)
								element.Visible = false
							end
							
							if elementVisible then
								visible = true
							end
						end
					end

					-- Smooth section visibility
					if visible or searchText == "" then
						child.Visible = true
					else
						child.Visible = false
					end
					debugLog("Section visibility:", child.Visible)
				end
			elseif child.Name == "Element" then
				local elementVisible = searchInElement(child, searchText)
				child.Visible = elementVisible or searchText == ""
				debugLog("Standalone element visibility:", child.Visible)
			end
		end
	end

	-- Update search when tab is selected
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
					Padding = UDim.new(0, 8), -- Better spacing
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

	-- Add cleanup when tab is destroyed
	function Tab:Destroy()
		TabModule:CleanupTab(TabIndex)
	end

	return Tab
end

function TabModule:SelectTab(Tab)
    TabModule.SelectedTab = Tab

    for i, v in next, TabModule.Tabs do
        -- Enhanced tab deselection animation
        TweenService:Create(
            v.TabBtn.Title,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            { TextColor3 = CurrentThemeProps.offTextBtn }
        ):Play()
        TweenService:Create(
            v.TabBtn.Line,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            { BackgroundColor3 = CurrentThemeProps.offBgLineBtn }
        ):Play()
        TweenService:Create(
            v.TabBtn,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            { BackgroundTransparency = 1 }
        ):Play()
        
        v.Selected = false
        
        -- Hide search container for non-selected tabs
        if TabModule.SearchContainers[i] then
            TabModule.SearchContainers[i].Visible = false
        end
    end

    local selectedTab = TabModule.Tabs[Tab]
    if selectedTab then
        -- Enhanced tab selection animation
        TweenService:Create(
            selectedTab.TabBtn.Title,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { TextColor3 = CurrentThemeProps.onTextBtn }
        ):Play()
        TweenService:Create(
            selectedTab.TabBtn.Line,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { BackgroundColor3 = CurrentThemeProps.onBgLineBtn }
        ):Play()
        TweenService:Create(
            selectedTab.TabBtn,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency = 0.92 }
        ):Play()

        selectedTab.Selected = true

        task.spawn(function()
            for _, Container in pairs(TabModule.Containers) do
                Container.Visible = false
            end

            -- Show search container for selected tab only
            if TabModule.SearchContainers[Tab] then
                TabModule.SearchContainers[Tab].Visible = true
                
                -- Animate search container appearance
                local searchContainer = TabModule.SearchContainers[Tab]
                searchContainer.Position = UDim2.new(0, -50, 0, 0)
                TweenService:Create(searchContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 0, 0)
                }):Play()
            end

            if TabModule.Containers[Tab] then
                TabModule.Containers[Tab].Visible = true
                
                -- Animate container appearance
                local container = TabModule.Containers[Tab]
                container.Position = container.Position + UDim2.new(0, 30, 0, 0)
                container.Size = container.Size * 0.95
                
                TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = container.Position - UDim2.new(0, 30, 0, 0),
                    Size = container.Size / 0.95
                }):Play()
            end
        end)
    end
end

return TabModule

end)() end,
    [8] = function()local wax,script,require=ImportGlobals(8)local ImportGlobals return (function(...)local Elements = {}

for _, Theme in next, script:GetChildren() do
	table.insert(Elements, require(Theme))
end

return Elements
end)() end,
    [9] = function()local wax,script,require=ImportGlobals(9)local ImportGlobals return (function(...)local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
		Font = Enum.Font.GothamSemibold, -- Better font weight
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
		Size = UDim2.new(0, 0, 0, 18), -- Taller for better proportions
		Visible = true,
		Parent = BindFrame.topbox,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 2),
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6), -- More rounded
			Archivable = true,
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Thickness = 1,
		}),
	})

	-- Enhanced visual feedback for binding state
	AddConnection(BindFrame.Frame.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if Bind.Binding then
				return
			end
			Bind.Binding = true
			value.Text = "⏱️ Listening..."
			
			-- Enhanced binding animation
			TweenService:Create(value, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0, 0, 0, 20),
				BackgroundTransparency = 0.5
			}):Play()
		end
	end)

	function Bind:Set(Key)
		Bind.Binding = false
		Bind.Value = Key or Bind.Value
		Bind.Value = Bind.Value.Name or Bind.Value
		value.Text = "🎯 " .. Bind.Value
		
		-- Enhanced set animation
		TweenService:Create(value, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 0, 18),
			BackgroundTransparency = 0
		}):Play()
		
		Config.ChangeCallback(Bind.Value)
	end

	AddConnection(UserInputService.InputBegan, function(Input)
		if UserInputService:GetFocusedTextBox() then
			return
		end
		if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
			if Config.Hold then
				Holding = true
				-- Visual feedback for hold
				TweenService:Create(value, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 0.3
				}):Play()
				Config.Callback(Holding)
			else
				-- Visual feedback for tap
				TweenService:Create(value, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
					Size = UDim2.new(0, 0, 0, 20)
				}):Play()
				task.wait(0.1)
				TweenService:Create(value, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
					Size = UDim2.new(0, 0, 0, 18)
				}):Play()
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
				-- Reset visual feedback
				TweenService:Create(value, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 0
				}):Play()
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
    [10] = function()local wax,script,require=ImportGlobals(10)local ImportGlobals return (function(...)local TweenService = game:GetService("TweenService")

local Tools = require(script.Parent.Parent.tools)

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local CurrentThemeProps = Tools.GetPropsCurrentTheme()

local Element = {}
Element.__index = Element
Element.__type = "Button"

local ButtonStyles = {
	Primary = {
		TextColor3 = Color3.fromRGB(9, 9, 9),
		BackgroundColor3 = CurrentThemeProps.primarycolor,
		BackgroundTransparency = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		HoverConfig = {
			BackgroundTransparency = 0.1,
			Size = UDim2.new(1, 2, 1, 2), -- Slight scale on hover
		},
		FocusConfig = {
			BackgroundTransparency = 0.2,
			Size = UDim2.new(1, -2, 1, -2), -- Scale down on press
		},
	},
	Ghost = {
		TextColor3 = Color3.fromRGB(244, 244, 244),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		HoverConfig = {
			BackgroundTransparency = 0.95,
			Size = UDim2.new(1, 2, 1, 2),
		},
		FocusConfig = {
			BackgroundTransparency = 0.9,
			Size = UDim2.new(1, -1, 1, -1),
		},
	},
	Outline = {
		TextColor3 = Color3.fromRGB(244, 244, 244),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 1,
		UIStroke = {
			Color = Color3.fromRGB(60, 60, 65), -- Better border color
			Thickness = 1.5,
		},
		HoverConfig = {
			BackgroundTransparency = 0.92,
			Size = UDim2.new(1, 2, 1, 2),
		},
		FocusConfig = {
			BackgroundTransparency = 0.85,
			Size = UDim2.new(1, -1, 1, -1),
		},
	},
}

local function ApplyTweens(button, config, uiStroke, originalSize)
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out) -- Enhanced easing
	local tweenGoals = {}

	for property, value in pairs(config) do
		if property ~= "UIStroke" and property ~= "Size" then
			tweenGoals[property] = value
		end
	end

	local tween = TweenService:Create(button, tweenInfo, tweenGoals)
	tween:Play()

	-- Handle size animation separately with original size reference
	if config.Size then
		local sizeTween = TweenService:Create(button, tweenInfo, {
			Size = originalSize and (originalSize + (config.Size - UDim2.new(1, 0, 1, 0))) or config.Size
		})
		sizeTween:Play()
	end

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
		Font = Enum.Font.GothamSemibold, -- Better font weight
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
			PaddingBottom = UDim.new(0, 10), -- Better padding
			PaddingLeft = UDim.new(0, 18),
			PaddingRight = UDim.new(0, 18),
			PaddingTop = UDim.new(0, 10),
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8), -- More rounded
			Archivable = true,
		}),
	})

	local originalSize = button.Size

	if config.UIStroke then
		local uiStroke = Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = config.UIStroke.Color,
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = config.UIStroke.Thickness,
			Archivable = true,
			Parent = button,
		})
		
		button.MouseEnter:Connect(function()
			if config.HoverConfig then
				ApplyTweens(button, config.HoverConfig, uiStroke, originalSize)
			end
		end)

		button.MouseLeave:Connect(function()
			ApplyTweens(button, {
				BackgroundColor3 = config.BackgroundColor3,
				TextColor3 = config.TextColor3,
				BackgroundTransparency = config.BackgroundTransparency,
				BorderColor3 = config.BorderColor3,
				BorderSizePixel = config.BorderSizePixel,
				Size = UDim2.new(1, 0, 1, 0),
				UIStroke = config.UIStroke,
			}, uiStroke, originalSize)
		end)

		button.MouseButton1Down:Connect(function()
			if config.FocusConfig then
				ApplyTweens(button, config.FocusConfig, uiStroke, originalSize)
			end
		end)

		button.MouseButton1Up:Connect(function()
			if config.HoverConfig then
				ApplyTweens(button, config.HoverConfig, uiStroke, originalSize)
			else
				ApplyTweens(button, {
					BackgroundColor3 = config.BackgroundColor3,
					TextColor3 = config.TextColor3,
					BackgroundTransparency = config.BackgroundTransparency,
					BorderColor3 = config.BorderColor3,
					BorderSizePixel = config.BorderSizePixel,
					Size = UDim2.new(1, 0, 1, 0),
					UIStroke = config.UIStroke,
				}, uiStroke, originalSize)
			end
		end)
	else
		button.MouseEnter:Connect(function()
			if config.HoverConfig then
				ApplyTweens(button, config.HoverConfig, nil, originalSize)
			end
		end)

		button.MouseLeave:Connect(function()
			ApplyTweens(button, {
				BackgroundColor3 = config.BackgroundColor3,
				TextColor3 = config.TextColor3,
				BackgroundTransparency = config.BackgroundTransparency,
				BorderColor3 = config.BorderColor3,
				BorderSizePixel = config.BorderSizePixel,
				Size = UDim2.new(1, 0, 1, 0),
			}, nil, originalSize)
		end)

		button.MouseButton1Down:Connect(function()
			if config.FocusConfig then
				ApplyTweens(button, config.FocusConfig, nil, originalSize)
			end
		end)

		button.MouseButton1Up:Connect(function()
			if config.HoverConfig then
				ApplyTweens(button, config.HoverConfig, nil, originalSize)
			else
				ApplyTweens(button, {
					BackgroundColor3 = config.BackgroundColor3,
					TextColor3 = config.TextColor3,
					BackgroundTransparency = config.BackgroundTransparency,
					BorderColor3 = config.BorderColor3,
					BorderSizePixel = config.BorderSizePixel,
					Size = UDim2.new(1, 0, 1, 0),
				}, nil, originalSize)
			end
		end)
	end

	-- Add entrance animation
	button.Position = button.Position + UDim2.new(0, 20, 0, 0)
	button.BackgroundTransparency = 1
	button.TextTransparency = 1
	
	task.spawn(function()
		TweenService:Create(button, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = button.Position - UDim2.new(0, 20, 0, 0),
			BackgroundTransparency = config.BackgroundTransparency,
			TextTransparency = 0
		}):Play()
	end)

	return button
end

function Element:New(Config)
	assert(Config.Title, "Button - Missing Title")
	Config.Variant = Config.Variant or "Primary"
	Config.Callback = Config.Callback or function() end
	local Button = {}

	Button.StyledButton = CreateButton(Config.Variant, Config.Title, self.Container)
	Button.StyledButton.MouseButton1Click:Connect(function()
		-- Enhanced click feedback
		local clickFeedback = TweenService:Create(Button.StyledButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			TextSize = 13
		})
		clickFeedback:Play()
		
		clickFeedback.Completed:Connect(function()
			TweenService:Create(Button.StyledButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				TextSize = 14
			}):Play()
		end)
		
		Config.Callback()
	end)

	return Button
end

return Element

end)() end,
    [11] = function()local wax,script,require=ImportGlobals(11)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
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
		Size = UDim2.new(1, 0, 0, 34), -- Taller for better proportions
		Visible = true,
		Parent = ColorpickerFrame.Frame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(35, 35, 38), -- Better border color
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1.5,
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8), -- More rounded
			Archivable = true,
		}),
	})

	local colorBox = Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(3, 255, 150),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 34, 1, 0),
		Visible = true,
		Parent = InputFrame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(45, 45, 48),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1.5,
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
	})

	local inputHex = Create("TextBox", {
		Font = Enum.Font.GothamSemibold,
		LineHeight = 1.2,
		PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
		Text = "#03ff96",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, -34, 1, 0),
		Visible = true,
		Parent = InputFrame,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 0),
			Archivable = true,
		}),
	})

	-- Enhanced input animations
	inputHex.Focused:Connect(function()
		TweenService:Create(InputFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0.95
		}):Play()
	end)

	inputHex.FocusLost:Connect(function(Enter)
		TweenService:Create(InputFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()
		
		if Enter then
			local Success, Result = pcall(Color3.fromHex, inputHex.Text)
			if Success and typeof(Result) == "Color3" then
				Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = Color3.toHSV(Result)
			end
		end
	end)

	-- Enhanced Colorpicker with better styling
	local colorpicker_frame = Create("TextButton", {
		AutoButtonColor = false,
		Text = "",
		ZIndex = 20,
		BackgroundColor3 = Color3.fromRGB(15, 15, 18),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(1, 0, 0, 180), -- Taller for better proportions
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
			CornerRadius = UDim.new(0, 10),
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(45, 45, 48),
			Thickness = 1.5,
		}),
	})

	local color = Create("ImageLabel", {
		Image = "rbxassetid://4155801252",
		BackgroundColor3 = Color3.fromRGB(255, 0, 4),
		Size = UDim2.new(1, -12, 0, 140), -- Taller color picker
		Visible = true,
		ZIndex = 10,
		Parent = colorpicker_frame,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Archivable = true,
		}),
	})

	local color_selection = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 14, 0, 14), -- Larger selection indicator
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
			Thickness = 2, -- Thicker border
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
			CornerRadius = UDim.new(0, 8),
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
		Size = UDim2.new(0, 10, 0, 10), -- Larger hue selection
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
		Size = UDim2.new(1, 0, 0, 20), -- Taller toggle area
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
			CornerRadius = UDim.new(0, 6), -- More rounded
			Archivable = true,
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(200, 200, 200),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1.5,
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
			Size = UDim2.new(0, 14, 0, 14),
			Visible = true,
		}),
		Create("TextLabel", {
			Font = Enum.Font.GothamSemibold,
			Text = "🌈 Rainbow",
			TextColor3 = Color3.fromRGB(220, 220, 220),
			TextSize = 13,
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
        
        -- Enhanced color updates with animations
        TweenService:Create(colorBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = newColor
        }):Play()
        
        TweenService:Create(color, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromHSV(Colorpicker.Hue, 1, 1)
        }):Play()
        
        TweenService:Create(color_selection, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = newColor
        }):Play()
        
        if inputHex then
            inputHex.Text = "#" .. newColor:ToHex()
        end
        
        pcall(Colorpicker.Callback, newColor)
    end
	
	local function UpdateColorPickerPosition()
		local ColorX = math.clamp(mouse.X - color.AbsolutePosition.X, 0, color.AbsoluteSize.X)
		local ColorY = math.clamp(mouse.Y - color.AbsolutePosition.Y, 0, color.AbsoluteSize.Y)
		
		-- Smooth position updates
		TweenService:Create(color_selection, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Position = UDim2.new(ColorX / color.AbsoluteSize.X, 0, ColorY / color.AbsoluteSize.Y, 0)
		}):Play()
		
		Colorpicker.Sat = ColorX / color.AbsoluteSize.X
		Colorpicker.Vib = 1 - (ColorY / color.AbsoluteSize.Y)
		UpdateColorPicker()
		inputHex.Text = "#" .. Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib):ToHex()
	end
	
	local function UpdateHuePickerPosition()
		local HueY = math.clamp(mouse.Y - hue.AbsolutePosition.Y, 0, hue.AbsoluteSize.Y)
		
		-- Smooth hue position updates
		TweenService:Create(hue_selection, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0.5, 0, HueY / hue.AbsoluteSize.Y, 0)
		}):Play()
		
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
		
		-- Enhanced toggle animation
		if Colorpicker.ColorpickerToggle then
			colorpicker_frame.Visible = true
			colorpicker_frame.Size = UDim2.new(1, 0, 0, 0)
			TweenService:Create(colorpicker_frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0, 180)
			}):Play()
		else
			TweenService:Create(colorpicker_frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(1, 0, 0, 0)
			}):Play()
			
			task.wait(0.3)
			colorpicker_frame.Visible = false
		end
	end)

	AddConnection(rainbowtoggle.MouseButton1Click, function()
		RainbowColorPicker = not RainbowColorPicker
		Colorpicker.RainbowMode = RainbowColorPicker
		
		-- Enhanced rainbow toggle animation
		TweenService:Create(
			togglebox,
			TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
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
            TweenService:Create(color_selection, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(self.Sat, 0, 1 - self.Vib, 0)
            }):Play()
            
            TweenService:Create(colorBox, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundColor3 = newColor
            }):Play()
            
            TweenService:Create(hue_selection, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, 0, self.Hue, 0)
            }):Play()
            
            UpdateColorPicker()
        end
    end

	self.Library.Flags[Idx] = Colorpicker
	return Colorpicker
end

return Element

end)() end,
    [12] = function()local wax,script,require=ImportGlobals(12)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
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
		Size = UDim2.new(1, 0, 0, 34), -- Taller for better proportions
		Visible = true,
		Parent = DropdownFrame.Frame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = { Color = "bordercolor" },
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1.5, -- Thicker border
			Archivable = true,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8), -- More rounded
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
		Size = UDim2.new(0, 0, 0, 34),
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
			Padding = UDim.new(0, 6), -- Better spacing
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
		Font = Enum.Font.GothamSemibold, -- Better font
		PlaceholderText = Config.PlaceHolder,
		Text = "",
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeProps = {
			BackgroundColor3 = "maincolor"
		},
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 140, 0, 34),
		Visible = true,
		Parent = DropdownElement,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
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
			Thickness = 1.5,
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
			Padding = UDim.new(0, 6), -- Better spacing
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	-- Enhanced dropdown animations
	AddConnection(search.Focused, function()
		Dropdown.Toggled = true
		dropcont.Visible = true
		
		-- Smooth dropdown opening animation
		dropcont.Size = UDim2.new(1, 0, 0, 0)
		TweenService:Create(dropcont, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, dropcont.UIListLayout.AbsoluteContentSize.Y + 24)
		}):Play()
		
		TweenService:Create(DropdownElement, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0.95
		}):Play()
	end)
	
	AddConnection(DropdownFrame.Frame.MouseButton1Click, function()
		Dropdown.Toggled = not Dropdown.Toggled
		
		if Dropdown.Toggled then
			dropcont.Visible = true
			dropcont.Size = UDim2.new(1, 0, 0, 0)
			TweenService:Create(dropcont, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0, dropcont.UIListLayout.AbsoluteContentSize.Y + 24)
			}):Play()
		else
			TweenService:Create(dropcont, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(1, 0, 0, 0)
			}):Play()
			
			task.wait(0.3)
			dropcont.Visible = false
		end
		
		TweenService:Create(DropdownElement, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = Dropdown.Toggled and 0.95 or 1
		}):Play()
	end)
	
	function SearchOptions()
		local searchText = string.lower(search.Text)
		for _, v in ipairs(dropcont:GetChildren()) do
			if v:IsA("TextButton") then
				local buttonText = string.lower(v.TextLabel.Text)
				local isVisible = string.find(buttonText, searchText) ~= nil
				
				-- Smooth search results animation
				if isVisible then
					v.Visible = true
					TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Size = UDim2.new(1, 0, 0, 34),
						BackgroundTransparency = v.BackgroundTransparency
					}):Play()
				else
					TweenService:Create(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1
					}):Play()
					
					task.wait(0.2)
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
				Font = Enum.Font.GothamSemibold,
				Text = Option,
				LineHeight = 0,
				TextColor3 = Color3.fromRGB(180, 180, 180),
				TextSize = 13,
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
				Size = UDim2.new(1, 0, 0, 34), -- Taller options
				Visible = true,
				Parent = dropcont,
			}, {
				Create("UICorner", {
					CornerRadius = UDim.new(0, 8),
					Archivable = true,
				}),
				text_label_2,
				check,
			})

			-- Enhanced hover effects for dropdown options
			dropbtn.MouseEnter:Connect(function()
				TweenService:Create(dropbtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 0.9
				}):Play()
				TweenService:Create(text_label_2, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					TextColor3 = Color3.fromRGB(220, 220, 220)
				}):Play()
			end)

			dropbtn.MouseLeave:Connect(function()
				if not (Config.Multiple and table.find(Dropdown.Value, Option)) and not (not Config.Multiple and Dropdown.Value == Option) then
					TweenService:Create(dropbtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						BackgroundTransparency = 1
					}):Play()
					TweenService:Create(text_label_2, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						TextColor3 = Color3.fromRGB(180, 180, 180)
					}):Play()
				end
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
					TweenService:Create(dropcont, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Size = UDim2.new(1, 0, 0, 0)
					}):Play()
					
					task.wait(0.3)
					dropcont.Visible = false
				end
			end)

			Dropdown.Buttons[Option] = dropbtn
		end
	end

	function Dropdown:Refresh(Options, Delete)
		if Delete then
			for _, v in pairs(Dropdown.Buttons) do
				v:Destroy()
			end
			Dropdown.Buttons = {}
		end
		Dropdown.Options = Options
		AddOptions(Dropdown.Options)
	end

	function Dropdown:Set(Value, ignore)
		local function updateButtonTransparency(button, isSelected)
			local transparency = isSelected and 0.1 or 1
			local textTransparency = isSelected and CurrentThemeProps.itemTextOff or CurrentThemeProps.itemTextOn
			local imageTransparency = isSelected and 0 or 1
			
			TweenService:Create(
				button,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = transparency }
			):Play()
			TweenService:Create(
				button.ImageLabel,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ ImageTransparency = imageTransparency }
			):Play()
			TweenService:Create(
				button.TextLabel,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TextColor3 = textTransparency }
			):Play()
		end

		local function clearValueText()
			for _, label in pairs(holder:GetChildren()) do
				if label:IsA("TextButton") then
					-- Animate removal
					TweenService:Create(label, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Size = UDim2.new(0, 0, 0, 0),
						BackgroundTransparency = 1
					}):Play()
					
					task.wait(0.2)
					label:Destroy()
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
					Padding = UDim.new(0, 6), -- Better spacing
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}, {}),
				Create("TextLabel", {
					Font = Enum.Font.GothamSemibold,
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
					Size = UDim2.new(0, 16, 0, 16),
					Visible = true,
				}, {}),
			})

			-- Enhanced tag animations
			tagBtn.Size = UDim2.new(0, 0, 0, 0)
			tagBtn.BackgroundTransparency = 1
			
			TweenService:Create(tagBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 0, 0, 24),
				BackgroundTransparency = 0
			}):Play()

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
    [13] = function()local wax,script,require=ImportGlobals(13)local ImportGlobals return (function(...)local Components = script.Parent.Parent.components

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
    [14] = function()local wax,script,require=ImportGlobals(14)local ImportGlobals return (function(...)local UserInputService = game:GetService("UserInputService")
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
        Font = Enum.Font.GothamBold, -- Bold for better visibility
        RichText = true,
        Text = "fix it good pls",
        ThemeProps = {
            TextColor3 = "titlecolor",
        },
        TextSize = 15, -- Slightly larger
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.754537523, 8, 0, 0),
        Size = UDim2.new(0, 100, 0, 18), -- Wider and taller
        Visible = true,
        Parent = SliderFrame.topbox,
    })

    local SliderBar = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        ThemeProps = { BackgroundColor3 = "sliderbar" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 30), -- Better spacing
        Size = UDim2.new(1, -8, 0, 4), -- Thicker bar
        Visible = true,
        Parent = SliderFrame.Frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4), -- More rounded
            Archivable = true,
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderbarstroke" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1.5, -- Thicker stroke
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
            CornerRadius = UDim.new(0, 4),
            Archivable = true,
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderprogressborder" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1.5,
            Archivable = true,
        }),
        -- Enhanced gradient for progress
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 200, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 180, 255))
            }),
            Rotation = 0,
        }),
    })

    local SliderDot = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        ThemeProps = { BackgroundColor3 = "sliderdotbg" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16), -- Larger dot
        Visible = true,
        Parent = SliderBar,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderdotstroke" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 2, -- Thicker stroke
            Archivable = true,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Archivable = true,
        }),
        -- Glow effect for the dot
        Create("ImageLabel", {
            Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
            ImageColor3 = Color3.fromRGB(100, 200, 255),
            ImageTransparency = 0.7,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 6, 1, 6),
            ZIndex = -1,
        }),
    })

    function Slider:Set(Value, ignore)
        self.Value = math.clamp(Round(Value, Config.Increment), Config.Min, Config.Max)
        
        -- Enhanced value display with units/formatting
        local displayValue = tostring(self.Value)
        if Config.Unit then
            displayValue = displayValue .. " " .. Config.Unit
        end
        ValueText.Text = string.format("%s<font transparency='0.4'>/%s</font>", displayValue, Config.Max)
        
        local newPosition = (self.Value - Config.Min) / (Config.Max - Config.Min)
        
        if DraggingDot then
            -- Instant update when dragging dot for responsiveness
            SliderDot.Position = UDim2.new(newPosition, 0, 0.5, 0)
            SliderProgress.Size = UDim2.fromScale(newPosition, 1)
        else
            -- Smooth animations when not dragging
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            TweenService:Create(SliderDot, tweenInfo, {
                Position = UDim2.new(newPosition, 0, 0.5, 0)
            }):Play()
            
            TweenService:Create(SliderProgress, tweenInfo, {
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

    -- Enhanced hover effects
    SliderBar.MouseEnter:Connect(function()
        TweenService:Create(SliderDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 18, 0, 18)
        }):Play()
    end)

    SliderBar.MouseLeave:Connect(function()
        if not Dragging then
            TweenService:Create(SliderDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 16, 0, 16)
            }):Play()
        end
    end)

    AddConnection(SliderBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            
            -- Enhanced drag start animation
            TweenService:Create(SliderDot, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 20, 0, 20)
            }):Play()
            
            updateSliderFromInput(input.Position)
        end
    end)

    AddConnection(SliderDot.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DraggingDot = true
            
            -- Enhanced dot drag animation
            TweenService:Create(SliderDot, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 22, 0, 22)
            }):Play()
            
            updateSliderFromInput(input.Position)
        end
    end)

    AddConnection(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Dragging then
                Dragging = false
                DraggingDot = false
                
                -- Enhanced drag end animation
                TweenService:Create(SliderDot, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 16, 0, 16)
                }):Play()
            end
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
    [15] = function()local wax,script,require=ImportGlobals(15)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components
local TweenService = game:GetService("TweenService")

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
        Font = Enum.Font.GothamSemibold, -- Better font
        PlaceholderText = Config.PlaceHolder,
        Text = Textbox.Value,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34), -- Taller for better proportions
        Visible = true,
        Parent = TextboxFrame.Frame,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 14), -- Better padding
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 0),
            Archivable = true,
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1.5, -- Thicker border
            Archivable = true,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8), -- More rounded
            Archivable = true,
        }),
    })

    -- Enhanced focus animations
    textbox.Focused:Connect(function()
        TweenService:Create(textbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.95,
            Size = UDim2.new(1, 0, 0, 36)
        }):Play()
        
        TweenService:Create(textbox.UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Thickness = 2
        }):Play()
    end)

    textbox.FocusLost:Connect(function()
        TweenService:Create(textbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34)
        }):Play()
        
        TweenService:Create(textbox.UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Thickness = 1.5
        }):Play()
        
        Textbox.Value = textbox.Text
        Config.Callback(Textbox.Value)
        
        if Config.TextDisappear then
            -- Smooth text disappear animation
            TweenService:Create(textbox, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                TextTransparency = 1
            }):Play()
            
            task.wait(0.3)
            textbox.Text = ""
            textbox.TextTransparency = 0
        end
    end)

    -- Enhanced typing animations
    textbox:GetPropertyChangedSignal("Text"):Connect(function()
        if textbox:IsFocused() then
            -- Subtle typing feedback
            TweenService:Create(textbox, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                TextSize = 14
            }):Play()
            
            task.wait(0.05)
            TweenService:Create(textbox, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                TextSize = 13
            }):Play()
        end
    end)

    function Textbox:Set(value)
        -- Enhanced set with animation
        local oldText = textbox.Text
        textbox.Text = value
        Textbox.Value = value
        
        if oldText ~= value then
            TweenService:Create(textbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                TextTransparency = 0
            }):Play()
        end
        
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
    [16] = function()local wax,script,require=ImportGlobals(16)local ImportGlobals return (function(...)local TweenService = game:GetService("TweenService")
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
            CornerRadius = UDim.new(0, 6), -- More rounded
            Archivable = true,
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "toggleborder",
            },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1.5, -- Thicker border
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

    -- Enhanced hover effects
    ToggleFrame.Frame.MouseEnter:Connect(function()
        TweenService:Create(box_frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 20, 0, 20)
        }):Play()
        
        if not Toggle.Value then
            TweenService:Create(box_frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 0.95
            }):Play()
        end
    end)

    ToggleFrame.Frame.MouseLeave:Connect(function()
        TweenService:Create(box_frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 18, 0, 18)
        }):Play()
        
        if not Toggle.Value then
            TweenService:Create(box_frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 1
            }):Play()
        end
    end)

    function Toggle:Set(Value, ignore)
        self.Value = Value
        
        -- Enhanced toggle animation with bounce
        if self.Value then
            TweenService:Create(box_frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 20, 0, 20)
            }):Play()
            
            task.wait(0.1)
            TweenService:Create(box_frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 18, 0, 18)
            }):Play()
        else
            TweenService:Create(box_frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
        end
        
        -- Enhanced checkmark animation
        local checkmark = box_frame.ImageLabel
        if self.Value then
            checkmark.ImageTransparency = 1
            checkmark.Size = UDim2.new(0, 10, 0, 10)
            
            TweenService:Create(checkmark, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                ImageTransparency = 0,
                Size = UDim2.new(0, 14, 0, 14)
            }):Play()
        else
            TweenService:Create(checkmark, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                ImageTransparency = 1,
                Size = UDim2.new(0, 10, 0, 10)
            }):Play()
        end
        
        if not ignore and (not self.IgnoreFirst or not self.FirstUpdate) then
            Library:Callback(Toggle.Callback, self.Value)
        end
        self.FirstUpdate = false
    end

    AddConnection(ToggleFrame.Frame.MouseButton1Click, function()
        -- Enhanced click feedback
        TweenService:Create(box_frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 16, 0, 16)
        }):Play()
        
        task.wait(0.1)
        Toggle:Set(not Toggle.Value)
    end)

    Toggle:Set(Toggle.Value, Config.IgnoreFirst)

    Library.Flags[Idx] = Toggle
    return Toggle
end

return Element

end)() end,
    [17] = function()local wax,script,require=ImportGlobals(17)local ImportGlobals return (function(...)local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local tools = { Signals = {}, themedObjects = {} }

-- ===== ENHANCED THEME SYSTEM =====
local themes = {
    -- Enhanced default theme with better colors
    default = {
        maincolor = Color3.fromRGB(12, 12, 15),
        titlecolor = Color3.fromRGB(240, 240, 245),
        descriptioncolor = Color3.fromRGB(180, 180, 190),
        elementdescription = Color3.fromRGB(160, 160, 170),
        bordercolor = Color3.fromRGB(35, 35, 40),
        scrollcolor = Color3.fromRGB(80, 80, 90),
        
        -- Enhanced primary colors
        primarycolor = Color3.fromRGB(100, 200, 255),
        secondarycolor = Color3.fromRGB(255, 100, 150),
        
        -- Tab colors
        onTextBtn = Color3.fromRGB(255, 255, 255),
        offTextBtn = Color3.fromRGB(120, 120, 130),
        onBgLineBtn = Color3.fromRGB(100, 200, 255),
        offBgLineBtn = Color3.fromRGB(50, 50, 55),
        
        -- Slider colors
        sliderbar = Color3.fromRGB(40, 40, 45),
        sliderbarstroke = Color3.fromRGB(60, 60, 65),
        sliderprogressbg = Color3.fromRGB(100, 200, 255),
        sliderprogressborder = Color3.fromRGB(80, 180, 235),
        sliderdotbg = Color3.fromRGB(255, 255, 255),
        sliderdotstroke = Color3.fromRGB(100, 200, 255),
        
        -- Toggle colors
        togglebg = Color3.fromRGB(100, 200, 255),
        toggleborder = Color3.fromRGB(80, 180, 235),
        
        -- Dropdown colors
        containeritemsbg = Color3.fromRGB(18, 18, 22),
        itembg = Color3.fromRGB(25, 25, 30),
        itemcheckmarkcolor = Color3.fromRGB(100, 200, 255),
        itemTextOn = Color3.fromRGB(220, 220, 225),
        itemTextOff = Color3.fromRGB(160, 160, 170),
        valuebg = Color3.fromRGB(60, 60, 70),
        valuetext = Color3.fromRGB(240, 240, 245),
    },
    
    -- Dark blue theme
    darkblue = {
        maincolor = Color3.fromRGB(8, 12, 20),
        titlecolor = Color3.fromRGB(230, 240, 255),
        descriptioncolor = Color3.fromRGB(160, 180, 210),
        elementdescription = Color3.fromRGB(140, 160, 190),
        bordercolor = Color3.fromRGB(25, 35, 50),
        scrollcolor = Color3.fromRGB(60, 80, 120),
        
        primarycolor = Color3.fromRGB(80, 150, 255),
        secondarycolor = Color3.fromRGB(120, 80, 255),
        
        onTextBtn = Color3.fromRGB(255, 255, 255),
        offTextBtn = Color3.fromRGB(100, 120, 160),
        onBgLineBtn = Color3.fromRGB(80, 150, 255),
        offBgLineBtn = Color3.fromRGB(30, 40, 60),
        
        sliderbar = Color3.fromRGB(20, 30, 45),
        sliderbarstroke = Color3.fromRGB(40, 60, 90),
        sliderprogressbg = Color3.fromRGB(80, 150, 255),
        sliderprogressborder = Color3.fromRGB(60, 130, 235),
        sliderdotbg = Color3.fromRGB(255, 255, 255),
        sliderdotstroke = Color3.fromRGB(80, 150, 255),
        
        togglebg = Color3.fromRGB(80, 150, 255),
        toggleborder = Color3.fromRGB(60, 130, 235),
        
        containeritemsbg = Color3.fromRGB(12, 18, 28),
        itembg = Color3.fromRGB(18, 25, 38),
        itemcheckmarkcolor = Color3.fromRGB(80, 150, 255),
        itemTextOn = Color3.fromRGB(200, 220, 240),
        itemTextOff = Color3.fromRGB(140, 160, 190),
        valuebg = Color3.fromRGB(40, 60, 90),
        valuetext = Color3.fromRGB(230, 240, 255),
    },
    
    -- Purple theme
    purple = {
        maincolor = Color3.fromRGB(15, 10, 20),
        titlecolor = Color3.fromRGB(245, 230, 255),
        descriptioncolor = Color3.fromRGB(190, 160, 210),
        elementdescription = Color3.fromRGB(170, 140, 190),
        bordercolor = Color3.fromRGB(40, 25, 50),
        scrollcolor = Color3.fromRGB(100, 60, 120),
        
        primarycolor = Color3.fromRGB(180, 100, 255),
        secondarycolor = Color3.fromRGB(255, 100, 200),
        
        onTextBtn = Color3.fromRGB(255, 255, 255),
        offTextBtn = Color3.fromRGB(140, 100, 160),
        onBgLineBtn = Color3.fromRGB(180, 100, 255),
        offBgLineBtn = Color3.fromRGB(50, 30, 60),
        
        sliderbar = Color3.fromRGB(30, 20, 45),
        sliderbarstroke = Color3.fromRGB(60, 40, 90),
        sliderprogressbg = Color3.fromRGB(180, 100, 255),
        sliderprogressborder = Color3.fromRGB(160, 80, 235),
        sliderdotbg = Color3.fromRGB(255, 255, 255),
        sliderdotstroke = Color3.fromRGB(180, 100, 255),
        
        togglebg = Color3.fromRGB(180, 100, 255),
        toggleborder = Color3.fromRGB(160, 80, 235),
        
        containeritemsbg = Color3.fromRGB(20, 15, 28),
        itembg = Color3.fromRGB(28, 20, 38),
        itemcheckmarkcolor = Color3.fromRGB(180, 100, 255),
        itemTextOn = Color3.fromRGB(225, 200, 240),
        itemTextOff = Color3.fromRGB(170, 140, 190),
        valuebg = Color3.fromRGB(70, 40, 90),
        valuetext = Color3.fromRGB(245, 230, 255),
    }
}

local currentTheme = themes.default

-- Enhanced theme management with smooth transitions
function tools.SetTheme(themeName)
	if themes[themeName] then
		local oldTheme = currentTheme
		currentTheme = themes[themeName]
		
		-- Smooth theme transition
		for _, item in pairs(tools.themedObjects) do
			local obj = item.object
			local props = item.props
			
			if obj and obj.Parent then
				for propName, themeKey in next, props do
					if currentTheme[themeKey] then
						-- Smooth color transitions
						local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
						TweenService:Create(obj, tweenInfo, {
							[propName] = currentTheme[themeKey]
						}):Play()
					end
				end
			end
		end
		print("✨ Theme smoothly changed to:", themeName)
	else
		warn("❌ Theme not found: " .. themeName)
	end
end

function tools.GetPropsCurrentTheme()
	return currentTheme
end

function tools.AddTheme(themeName, themeProps)
	themes[themeName] = themeProps
	print("🎨 Theme added:", themeName)
end

-- ===== ENHANCED MOBILE DETECTION =====
function tools.isMobile()
    local isTouchDevice = UserInputService.TouchEnabled
    local hasKeyboard = UserInputService.KeyboardEnabled
    local hasMouse = UserInputService.MouseEnabled
    local screenSize = workspace.CurrentCamera.ViewportSize
    
    -- More sophisticated mobile detection
    local isMobileScreen = screenSize.X < 1024 or screenSize.Y < 768
    return (isTouchDevice and not hasKeyboard) or isMobileScreen
end

-- ===== ENHANCED CONNECTION MANAGEMENT =====
function tools.AddConnection(Signal, Function)
	local success, connection = pcall(function()
		return Signal:Connect(Function)
	end)
	
	if success and connection then
		table.insert(tools.Signals, connection)
		return connection
	else
		warn("⚠️ Failed to create connection:", connection)
		return nil
	end
end

-- Enhanced disconnect with better error handling and logging
function tools.Disconnect()
	local disconnectedCount = 0
	for key = #tools.Signals, 1, -1 do
		local Connection = table.remove(tools.Signals, key)
		if Connection and Connection.Connected then
			pcall(function()
				Connection:Disconnect()
				disconnectedCount = disconnectedCount + 1
			end)
		end
	end
	print("🔌 Disconnected", disconnectedCount, "connections")
end

-- ===== ENHANCED CREATE FUNCTION =====
function tools.Create(Name, Properties, Children)
	local success, Object = pcall(function()
		return Instance.new(Name)
	end)
	
	if not success then
		warn("❌ Failed to create instance:", Name)
		return nil
	end

	-- Enhanced theme property handling with registration
	if Properties and Properties.ThemeProps then
		for propName, themeKey in next, Properties.ThemeProps do
			if currentTheme[themeKey] then
				Object[propName] = currentTheme[themeKey]
			end
		end
		table.insert(tools.themedObjects, { object = Object, props = Properties.ThemeProps })
		Properties.ThemeProps = nil
	end

	-- Apply properties with enhanced error handling
	if Properties then
		for i, v in next, Properties do
			local success, err = pcall(function()
				Object[i] = v
			end)
			if not success then
				warn("⚠️ Failed to set property", i, "on", Name, ":", err)
			end
		end
	end
	
	-- Apply children with enhanced error handling
	if Children then
		for i, v in next, Children do
			local success, err = pcall(function()
				v.Parent = Object
			end)
			if not success then
				warn("⚠️ Failed to parent child", i, "to", Name, ":", err)
			end
		end
	end
	
	return Object
end

-- ===== ENHANCED SCROLL ANIMATION =====
function tools.AddScrollAnim(scrollbar)
	local visibleTween = TweenService:Create(scrollbar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ScrollBarImageTransparency = 0 })
	local invisibleTween = TweenService:Create(scrollbar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ScrollBarImageTransparency = 1 })
	local lastInteraction = tick()
	local delayTime = 1.2 -- Longer delay for better UX

	local function showScrollbar()
		visibleTween:Play()
	end

	local function hideScrollbar()
		if tick() - lastInteraction >= delayTime then
			invisibleTween:Play()
		end
	end

	-- Enhanced event handling with better performance
	tools.AddConnection(scrollbar.MouseEnter, function()
		lastInteraction = tick()
		showScrollbar()
	end)

	tools.AddConnection(scrollbar.MouseLeave, function()
		task.spawn(function()
			task.wait(delayTime)
			hideScrollbar()
		end)
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

	-- Throttled wheel detection for better performance
	local lastWheelTime = 0
	tools.AddConnection(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local currentTime = tick()
			if currentTime - lastWheelTime > 0.1 then -- Throttle to 10fps
				lastInteraction = currentTime
				lastWheelTime = currentTime
				showScrollbar()
			end
		end
	end)

	-- Optimized heartbeat with better performance
	local lastHeartbeat = 0
	tools.AddConnection(RunService.Heartbeat, function()
		local currentTime = tick()
		if currentTime - lastHeartbeat > 0.5 then -- Check every 0.5 seconds
			lastHeartbeat = currentTime
			if currentTime - lastInteraction >= delayTime then
				hideScrollbar()
			end
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

-- ===== ENHANCED PERFORMANCE MONITORING =====
function tools.GetPerformanceStats()
	local stats = game:GetService("Stats")
	local frameTime = stats.FrameTime
	local fps = frameTime > 0 and (1 / frameTime) or 0
	
	return {
		FPS = math.floor(fps * 10) / 10,
		FrameTime = math.floor(frameTime * 1000 * 100) / 100, -- ms
		Memory = math.floor(stats:GetTotalMemoryUsageMb() * 100) / 100,
		ThemeObjects = #tools.themedObjects,
		Connections = #tools.Signals
	}
end

-- ===== ENHANCED ERROR HANDLING =====
function tools.SafeCall(func, ...)
	local args = {...}
	local success, result = pcall(function()
		return func(unpack(args))
	end)
	
	if not success then
		warn("🔥 SafeCall error:", result)
		-- Log additional context
		local info = debug.getinfo(func, "S")
		if info then
			warn("🔍 Function source:", info.source, "line:", info.linedefined)
		end
	end
	
	return success, result
end

-- ===== ANIMATION HELPERS =====
function tools.CreateSmoothTween(object, targetProperties, duration, easingStyle, easingDirection)
	duration = duration or 0.3
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.Out
	
	local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
	local tween = TweenService:Create(object, tweenInfo, targetProperties)
	
	tween:Play()
	return tween
end

function tools.CreateBounceAnimation(object, scale, duration)
	scale = scale or 1.1
	duration = duration or 0.2
	
	local originalSize = object.Size
	local bounceSize = originalSize * scale
	
	local bounceUp = tools.CreateSmoothTween(object, {Size = bounceSize}, duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	bounceUp.Completed:Connect(function()
		tools.CreateSmoothTween(object, {Size = originalSize}, duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
	
	return bounceUp
end

-- ===== ENHANCED CLEANUP FUNCTION =====
function tools.Cleanup()
	print("🧹 Starting enhanced cleanup...")
	
	-- Disconnect all connections
	tools.Disconnect()
	
	-- Clear themed objects with fade animation
	for i = #tools.themedObjects, 1, -1 do
		local item = tools.themedObjects[i]
		if item and item.object and item.object.Parent then
			-- Fade out before removing
			tools.CreateSmoothTween(item.object, {
				BackgroundTransparency = 1,
				TextTransparency = 1,
				ImageTransparency = 1
			}, 0.2)
		end
		tools.themedObjects[i] = nil
	end
	
	-- Force garbage collection
	collectgarbage("collect")
	
	print("✅ Enhanced tools cleanup completed")
	print("📊 Final stats:", tools.GetPerformanceStats())
end

-- ===== AUTO-CLEANUP ON GAME SHUTDOWN =====
game:BindToClose(function()
	tools.Cleanup()
end)

return tools

end)() end
}

-- Holds the actual DOM data
local ObjectTree = {
    {
        1,
        2,
        {
            "MainModule"
        },
        {
            {
                2,
                1,
                {
                    "components"
                },
                {
                    {
                        6,
                        2,
                        {
                            "section"
                        }
                    },
                    {
                        3,
                        2,
                        {
                            "dialog"
                        }
                    },
                    {
                        5,
                        2,
                        {
                            "notif"
                        }
                    },
                    {
                        4,
                        2,
                        {
                            "element"
                        }
                    },
                    {
                        7,
                        2,
                        {
                            "tab"
                        }
                    }
                }
            },
            {
                8,
                2,
                {
                    "elements"
                },
                {
                    {
                        12,
                        2,
                        {
                            "dropdown"
                        }
                    },
                    {
                        10,
                        2,
                        {
                            "buttons"
                        }
                    },
                    {
                        16,
                        2,
                        {
                            "toggle"
                        }
                    },
                    {
                        11,
                        2,
                        {
                            "colorpicker"
                        }
                    },
                    {
                        9,
                        2,
                        {
                            "bind"
                        }
                    },
                    {
                        14,
                        2,
                        {
                            "slider"
                        }
                    },
                    {
                        13,
                        2,
                        {
                            "paragraph"
                        }
                    },
                    {
                        15,
                        2,
                        {
                            "textbox"
                        }
                    }
                }
            },
            {
                17,
                2,
                {
                    "tools"
                }
            }
        }
    }
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    8,
    [3] = 454,
    [4] = 607,
    [5] = 733,
    [6] = 919,
    [7] = 1131,
    [8] = 1460,
    [9] = 1468,
    [10] = 1597,
    [11] = 1777,
    [12] = 2219,
    [13] = 2732,
    [14] = 2750,
    [15] = 2961,
    [16] = 3048,
    [17] = 3138
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

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
    RefBindings[RefId] = Ref

    if Properties then
        for PropertyName, PropertyValue in next, Properties do
            Ref[PropertyName] = PropertyValue
        end
    end

    if Children then
        for _, ChildObject in next, Children do
            CreateRefFromObject(ChildObject, Ref)
        end
    end

    return Ref
end

local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end

-- Now we'll set script closure refs and check if they should be ran as a BaseScript
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName
    if ClassName == "LocalScript" or ClassName == "Script" then
        table_insert(ScriptsToRun, Ref)
    end
end

local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string.match(originalErrorMessage, "[^:]+:(%d+): (.+)")

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

    -- Cegah eksekusi Script di client (karena bisa error, misalnya karena BindToClose)
    if ScriptClassName == "Script" and not RunService:IsServer() then
        warn("[LoadScript] ⚠️ Tidak menjalankan Script di client:", scriptRef:GetFullName())
        return
    end

    -- Jika LocalScript atau Script (di server), jalankan Closure secara langsung
    if ScriptClassName == "LocalScript" or (ScriptClassName == "Script" and RunService:IsServer()) then
        local RunSuccess, ErrorMessage = pcall(Closure)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        -- ModuleScript, jalankan Closure dan simpan hasilnya
        local PCallReturn = { pcall(Closure) }

        local RunSuccess = table.remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table.remove(PCallReturn, 1)
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
