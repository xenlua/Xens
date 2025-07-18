-- Enhanced Roblox GUI Library with Improved Themes and Error Handling
-- Version: 2.1.0 - Enhanced Edition

local ImportGlobals

-- Enhanced theme system with local themes
local themes = {
	default = {
		maincolor = Color3.fromRGB(9, 9, 9),
		bordercolor = Color3.fromRGB(39, 39, 42),
		scrollocolor = Color3.fromRGB(28, 28, 30),

		titlecolor = Color3.fromRGB(245, 245, 245),
		descriptioncolor = Color3.fromRGB(168, 168, 168),
		elementdescription = Color3.fromRGB(168, 168, 168),

		primarycolor = Color3.fromRGB(78, 34, 197),

		-- Tabs Themes
		offTextBtn = Color3.fromRGB(63, 63, 63),
		offBgLineBtn = Color3.fromRGB(29, 29, 29),
		onTextBtn = Color3.fromRGB(129, 83, 255),
		onBgLineBtn = Color3.fromRGB(129, 83, 255),

		-- Toggle
		toggleborder = Color3.fromRGB(135, 80, 236),
		togglebg = Color3.fromRGB(98, 0, 255),

		-- Slider
		sliderbar = Color3.fromRGB(21,21,21),
		sliderbarstroke = Color3.fromRGB(29, 29, 29),
		sliderprogressbg = Color3.fromRGB(41, 11, 123),
		sliderprogressborder = Color3.fromRGB(59, 6, 184),
		sliderdotbg = Color3.fromRGB(120, 16, 206),
		sliderdotstroke = Color3.fromRGB(9, 9, 9),

		-- Dropdown
		containeritemsbg = Color3.fromRGB(28, 25, 23),
		itembg = Color3.fromRGB(39, 39, 42),
		itemcheckmarkcolor = Color3.fromRGB(154, 154, 154),
		itemTextOn = Color3.fromHex("#e9e9e9"),
		itemTextOff = Color3.fromHex("#9a9a9a"),

		valuetext = Color3.fromRGB(255, 255, 255),
		valuebg = Color3.fromRGB(39, 39, 42),
	},
	
	dark = {
		maincolor = Color3.fromRGB(15, 15, 15),
		bordercolor = Color3.fromRGB(45, 45, 48),
		scrollocolor = Color3.fromRGB(35, 35, 38),

		titlecolor = Color3.fromRGB(255, 255, 255),
		descriptioncolor = Color3.fromRGB(180, 180, 180),
		elementdescription = Color3.fromRGB(180, 180, 180),

		primarycolor = Color3.fromRGB(0, 122, 255),

		-- Tabs Themes
		offTextBtn = Color3.fromRGB(70, 70, 70),
		offBgLineBtn = Color3.fromRGB(35, 35, 35),
		onTextBtn = Color3.fromRGB(0, 122, 255),
		onBgLineBtn = Color3.fromRGB(0, 122, 255),

		-- Toggle
		toggleborder = Color3.fromRGB(0, 122, 255),
		togglebg = Color3.fromRGB(0, 122, 255),

		-- Slider
		sliderbar = Color3.fromRGB(25,25,25),
		sliderbarstroke = Color3.fromRGB(35, 35, 35),
		sliderprogressbg = Color3.fromRGB(0, 122, 255),
		sliderprogressborder = Color3.fromRGB(0, 100, 200),
		sliderdotbg = Color3.fromRGB(0, 122, 255),
		sliderdotstroke = Color3.fromRGB(15, 15, 15),

		-- Dropdown
		containeritemsbg = Color3.fromRGB(25, 25, 25),
		itembg = Color3.fromRGB(45, 45, 48),
		itemcheckmarkcolor = Color3.fromRGB(180, 180, 180),
		itemTextOn = Color3.fromHex("#ffffff"),
		itemTextOff = Color3.fromHex("#b4b4b4"),

		valuetext = Color3.fromRGB(255, 255, 255),
		valuebg = Color3.fromRGB(45, 45, 48),
	},
	
	light = {
		maincolor = Color3.fromRGB(255, 255, 255),
		bordercolor = Color3.fromRGB(200, 200, 200),
		scrollocolor = Color3.fromRGB(220, 220, 220),

		titlecolor = Color3.fromRGB(0, 0, 0),
		descriptioncolor = Color3.fromRGB(100, 100, 100),
		elementdescription = Color3.fromRGB(100, 100, 100),

		primarycolor = Color3.fromRGB(0, 122, 255),

		-- Tabs Themes
		offTextBtn = Color3.fromRGB(120, 120, 120),
		offBgLineBtn = Color3.fromRGB(200, 200, 200),
		onTextBtn = Color3.fromRGB(0, 122, 255),
		onBgLineBtn = Color3.fromRGB(0, 122, 255),

		-- Toggle
		toggleborder = Color3.fromRGB(0, 122, 255),
		togglebg = Color3.fromRGB(0, 122, 255),

		-- Slider
		sliderbar = Color3.fromRGB(240, 240, 240),
		sliderbarstroke = Color3.fromRGB(200, 200, 200),
		sliderprogressbg = Color3.fromRGB(0, 122, 255),
		sliderprogressborder = Color3.fromRGB(0, 100, 200),
		sliderdotbg = Color3.fromRGB(0, 122, 255),
		sliderdotstroke = Color3.fromRGB(255, 255, 255),

		-- Dropdown
		containeritemsbg = Color3.fromRGB(250, 250, 250),
		itembg = Color3.fromRGB(240, 240, 240),
		itemcheckmarkcolor = Color3.fromRGB(100, 100, 100),
		itemTextOn = Color3.fromHex("#000000"),
		itemTextOff = Color3.fromHex("#666666"),

		valuetext = Color3.fromRGB(0, 0, 0),
		valuebg = Color3.fromRGB(240, 240, 240),
	}
}

local ClosureBindings = {
    function()local wax,script,require=ImportGlobals(1)local ImportGlobals return (function(...)
-- Enhanced Main Library Module
task.wait(0.5) -- Reduced wait time for better performance

-- ===== UTILITY FUNCTIONS =====
local function generateRandomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local randomString = ""
    local seed = tick() * 1000
    math.randomseed(seed)

    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        randomString = randomString .. charset:sub(randomIndex, randomIndex)
    end

    return randomString
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("SafeCall Error: " .. tostring(result))
    end
    return success, result
end

-- ===== SERVICE IMPORTS =====
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- ===== MODULE IMPORTS =====
local ElementsTable = require(script.elements)
local Tools = require(script.tools)
local Components = script.components

-- ===== ENHANCED TOOL FUNCTIONS =====
local Create = Tools.Create
local AddConnection = Tools.AddConnection
local AddScrollAnim = Tools.AddScrollAnim
local isMobile = Tools.isMobile()
local CurrentThemeProps = Tools.GetPropsCurrentTheme()

-- ===== ENHANCED DRAGGABLE FUNCTIONALITY =====
local function MakeDraggable(DragPoint, Main)
    local Dragging = false
    local DragStart = nil
    local StartPos = nil
    
    local function updateDrag(input)
        if Dragging then
            local delta = input.Position - DragStart
            local newPos = UDim2.new(
                StartPos.X.Scale,
                StartPos.X.Offset + delta.X,
                StartPos.Y.Scale,
                StartPos.Y.Offset + delta.Y
            )
            
            -- Smooth position update
            TweenService:Create(Main, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Position = newPos
            }):Play()
        end
    end
    
    AddConnection(DragPoint.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = Main.Position
            
            AddConnection(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    AddConnection(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateDrag(input)
        end
    end)
end

-- ===== ENHANCED MAIN LIBRARY =====
local Library = {
    Window = nil,
    Flags = {},
    Signals = {},
    ToggleBind = nil,
    Version = "2.1.0",
    Author = "Enhanced Xenon Team",
    CurrentTheme = "default",
    ThemeSystem = themes,
}

-- ===== ENHANCED GUI CREATION =====
local function getGUIParent()
    local success, result = pcall(function()
        return gethui()
    end)
    if success then
        return result
    end
    return CoreGui
end

local GUI = Create("ScreenGui", {
    Name = generateRandomString(16),
    Parent = getGUIParent(),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
})

-- Initialize notification system
safeCall(function()
    require(Components.notif):Init(GUI)
end)

-- ===== ENHANCED LIBRARY METHODS =====
function Library:SetTheme(themeName)
    if themes[themeName] then
        self.CurrentTheme = themeName
        Tools.SetTheme(themeName)
        return true
    else
        warn("Theme '" .. themeName .. "' not found. Available themes: " .. table.concat(self:GetAvailableThemes(), ", "))
        return false
    end
end

function Library:GetTheme()
    return self.CurrentTheme
end

function Library:GetAvailableThemes()
    local themeNames = {}
    for name, _ in pairs(themes) do
        table.insert(themeNames, name)
    end
    return themeNames
end

function Library:AddTheme(themeName, themeProps)
    if type(themeName) == "string" and type(themeProps) == "table" then
        themes[themeName] = themeProps
        Tools.AddTheme(themeName, themeProps)
        return true
    end
    return false
end

function Library:IsRunning()
    return GUI and GUI.Parent ~= nil
end

-- Enhanced cleanup with better error handling
function Library:Destroy()
    safeCall(function()
        if GUI then
            GUI:Destroy()
            GUI = nil
        end
    end)
    
    safeCall(function()
        for _, connection in pairs(Tools.Signals or {}) do
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end
    end)
    
    safeCall(function()
        table.clear(self.Flags)
        table.clear(self.Signals)
    end)
end

-- ===== ENHANCED ELEMENTS SYSTEM =====
local Elements = {}
Elements.__index = Elements

for _, ElementComponent in ipairs(ElementsTable) do
    if ElementComponent.__type and ElementComponent.New then
        Elements["Add" .. ElementComponent.__type] = function(self, Idx, Config)
            Config = Config or {}
            ElementComponent.Container = self.Container
            ElementComponent.Type = self.Type
            ElementComponent.ScrollFrame = self.ScrollFrame
            ElementComponent.Library = Library

            return ElementComponent:New(Idx, Config)
        end
    end
end

Library.Elements = Elements

-- ===== ENHANCED CALLBACK SYSTEM =====
function Library:Callback(callback, ...)
    if not callback then
        return
    end
    
    if type(callback) ~= "function" then
        warn("Callback is not a function, got: " .. type(callback))
        return
    end

    local success, result = pcall(callback, ...)
    if not success then
        warn("Callback execution failed: " .. tostring(result))
    end
    return result
end

-- ===== ENHANCED NOTIFICATION SYSTEM =====
function Library:Notification(titleText, descriptionText, duration)
    safeCall(function()
        require(Components.notif):ShowNotification(titleText, descriptionText, duration or 5)
    end)
end

-- ===== ENHANCED DIALOG SYSTEM =====
function Library:Dialog(config)
    local success, result = pcall(function()
        return require(Components.dialog):Create(config, self.LoadedWindow)
    end)
    if success then
        return result
    else
        warn("Dialog creation failed: " .. tostring(result))
        return nil
    end
end

-- ===== ENHANCED MAIN WINDOW CREATION =====
function Library:Load(configs)
    configs = configs or {}
    configs.Title = configs.Title or "Enhanced Xentix UI Library"
    configs.ToggleButton = configs.ToggleButton or ""
    configs.BindGui = configs.BindGui or Enum.KeyCode.RightControl
    configs.Size = configs.Size or UDim2.new(0, 680, 0, 420)
    configs.Position = configs.Position or UDim2.new(0.5, 0, 0.5, 0)
    configs.Theme = configs.Theme or "default"

    if Library.Window then
        warn("Cannot create more than one window.")
        return
    end
    
    -- Set initial theme
    Library:SetTheme(configs.Theme)
    
    Library.Window = GUI

    -- ===== ENHANCED MAIN CANVAS GROUP =====
    local canvas_group = Create("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Position = configs.Position,
        Size = configs.Size,
        Parent = GUI,
        Visible = false,
        GroupColor3 = Color3.fromRGB(0, 0, 0),
        GroupTransparency = 0.05,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 12),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
        Create("DropShadow", {
            Size = UDim2.new(1, 20, 1, 20),
            Position = UDim2.new(0, -10, 0, -10),
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.7,
            ZIndex = -1,
        }),
    })

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
        Position = UDim2.new(0.5, 0, 0, 10),
        Size = UDim2.new(0, 50, 0, 50),
        Parent = GUI,
        Image = configs.ToggleButton,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 12),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
        Create("DropShadow", {
            Size = UDim2.new(1, 10, 1, 10),
            Position = UDim2.new(0, -5, 0, -5),
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.8,
            ZIndex = -1,
        }),
    })

    -- ===== ENHANCED TOGGLE FUNCTIONALITY =====
    local isVisible = false
    local function ToggleVisibility()
        isVisible = not isVisible
        
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        if isVisible then
            canvas_group.Visible = true
            togglebtn.Visible = false
            
            local positionTween = TweenService:Create(canvas_group, tweenInfo, {
                Position = configs.Position,
                Size = configs.Size,
            })
            positionTween:Play()
        else
            local positionTween = TweenService:Create(canvas_group, tweenInfo, {
                Position = UDim2.new(0.5, 0, -0.5, 0),
                Size = UDim2.new(0, 50, 0, 50),
            })
            positionTween:Play()
            
            positionTween.Completed:Connect(function()
                canvas_group.Visible = false
                togglebtn.Visible = true
            end)
        end
    end

    -- Initial state
    ToggleVisibility()

    -- Enhanced button hover effects
    local function addHoverEffect(button, hoverScale, hoverTransparency)
        hoverScale = hoverScale or 1.05
        hoverTransparency = hoverTransparency or 0.8
        
        AddConnection(button.MouseEnter, function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                Size = UDim2.new(button.Size.X.Scale * hoverScale, 0, button.Size.Y.Scale * hoverScale, 0),
                ImageTransparency = hoverTransparency,
            }):Play()
        end)
        
        AddConnection(button.MouseLeave, function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 50, 0, 50),
                ImageTransparency = 0,
            }):Play()
        end)
    end

    addHoverEffect(togglebtn)

    -- Event connections
    if not isMobile then
        MakeDraggable(togglebtn, togglebtn)
    end
    
    AddConnection(togglebtn.MouseButton1Click, ToggleVisibility)
    AddConnection(UserInputService.InputBegan, function(input)
        if input.KeyCode == configs.BindGui then
            ToggleVisibility()
        end
    end)

    -- ===== ENHANCED TOP FRAME =====
    local top_frame = Create("Frame", {
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Size = UDim2.new(1, 0, 0, 45),
        ZIndex = 10,
        Parent = canvas_group,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 12),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
    })

    -- ===== ENHANCED TITLE LABEL =====
    local title = Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        RichText = true,
        Text = configs.Title,
        ThemeProps = {
            TextColor3 = "titlecolor",
        },
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0),
        Size = UDim2.new(0, 300, 0, 45),
        ZIndex = 11,
        Parent = top_frame,
    })

    -- ===== ENHANCED WINDOW CONTROLS =====
    local minimizebtn = Create("ImageButton", {
        Image = "rbxassetid://15269257100",
        ImageRectOffset = Vector2.new(514, 257),
        ImageRectSize = Vector2.new(256, 256),
        ThemeProps = {
            ImageColor3 = "titlecolor",
        },
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -45, 0.5, 0),
        Size = UDim2.new(0, 32, 0, 32),
        ZIndex = 11,
        Parent = top_frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
    })

    local closebtn = Create("ImageButton", {
        Image = "rbxassetid://15269329696",
        ImageRectOffset = Vector2.new(0, 514),
        ImageRectSize = Vector2.new(256, 256),
        ThemeProps = {
            ImageColor3 = "titlecolor",
        },
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 32, 0, 32),
        ZIndex = 11,
        Parent = top_frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
    })

    -- Enhanced button hover effects
    local function addControlButtonHover(button)
        AddConnection(button.MouseEnter, function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                ImageTransparency = 0.3,
                BackgroundTransparency = 0.9,
            }):Play()
        end)
        
        AddConnection(button.MouseLeave, function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                ImageTransparency = 0,
                BackgroundTransparency = 1,
            }):Play()
        end)
    end

    addControlButtonHover(minimizebtn)
    addControlButtonHover(closebtn)

    -- Button connections
    AddConnection(minimizebtn.MouseButton1Click, ToggleVisibility)
    AddConnection(closebtn.MouseButton1Click, function()
        Library:Destroy()
    end)

    -- ===== ENHANCED TAB FRAME =====
    local tab_frame = Create("Frame", {
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(0, 150, 1, -45),
        Parent = canvas_group,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 12),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
    })

    -- ===== ENHANCED TAB HOLDER =====
    local TabHolder = Create("ScrollingFrame", {
        ThemeProps = {
            ScrollBarImageColor3 = "scrollocolor",
            BackgroundColor3 = "maincolor",
        },
        ScrollBarThickness = 3,
        ScrollBarImageTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = tab_frame,
    }, {
        Create("UIPadding", {
            PaddingAll = UDim.new(0, 8),
        }),
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        }),
    })

    -- Auto-resize canvas with animation
    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        local targetSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
        TweenService:Create(TabHolder, TweenInfo.new(0.2), {
            CanvasSize = targetSize
        }):Play()
    end)

    AddScrollAnim(TabHolder)

    -- ===== CONTAINER FOLDER =====
    local containerFolder = Create("Folder", {
        Parent = canvas_group,
    })

    -- Enhanced draggable for desktop
    if not isMobile then
        MakeDraggable(top_frame, canvas_group)
    end

    Library.LoadedWindow = canvas_group

    -- ===== ENHANCED TAB SYSTEM =====
    local Tabs = {}
    local TabModule = require(Components.tab):Init(containerFolder)
    
    function Tabs:AddTab(title, icon)
        return TabModule:New(title, TabHolder, icon)
    end
    
    function Tabs:SelectTab(tab)
        TabModule:SelectTab(tab or 1)
    end

    function Tabs:GetCurrentTab()
        return TabModule.SelectedTab
    end

    function Tabs:GetTabCount()
        return TabModule.TabCount
    end

    -- Auto-select first tab
    task.defer(function()
        if TabModule.TabCount > 0 then
            Tabs:SelectTab(1)
        end
    end)

    return Tabs
end

-- ===== ENHANCED BACKGROUND CLEANUP =====
local cleanupConnection
cleanupConnection = AddConnection(RunService.Heartbeat, function()
    if not Library:IsRunning() then
        Library:Destroy()
        if cleanupConnection then
            cleanupConnection:Disconnect()
        end
    end
end)

return Library

end)() end,
    [3] = function()local wax,script,require=ImportGlobals(3)local ImportGlobals return (function(...)-- Enhanced Dialog Module
local Tools = require(script.Parent.Parent.tools)
local ButtonComponent = require(script.Parent.Parent.elements.buttons)
local TweenService = game:GetService("TweenService")

local Create = Tools.Create

local DialogModule = {}
local ActiveDialog = nil

function DialogModule:Create(config, parent)
    config = config or {}
    config.Title = config.Title or "Dialog"
    config.Content = config.Content or "Dialog content"
    config.Buttons = config.Buttons or {{Title = "OK", Callback = function() end}}
    
    -- Remove existing dialog if any
    if ActiveDialog then
        ActiveDialog:Destroy()
        ActiveDialog = nil
    end

    -- Create backdrop
    local backdrop = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 100,
        Parent = parent,
    })

    -- Fade in backdrop
    backdrop.BackgroundTransparency = 1
    TweenService:Create(backdrop, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.5
    }):Play()

    -- Create dialog container
    local dialogContainer = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 101,
        Parent = backdrop,
    })

    -- Create dialog
    local dialog = Create("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 400, 0, 200),
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Parent = dialogContainer,
        GroupTransparency = 0.05,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Thickness = 1,
        }),
        Create("DropShadow", {
            Size = UDim2.new(1, 20, 1, 20),
            Position = UDim2.new(0, -10, 0, -10),
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.3,
            ZIndex = -1,
        }),
    })

    -- Animate dialog appearance
    dialog.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(dialog, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 400, 0, 200)
    }):Play()

    -- Create title bar
    local titleBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        ThemeProps = { BackgroundColor3 = "maincolor" },
        Parent = dialog,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Thickness = 1,
        }),
        Create("TextLabel", {
            Font = Enum.Font.GothamBold,
            Text = config.Title,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 16, 0, 0),
            Size = UDim2.new(1, -32, 1, 0),
            BackgroundTransparency = 1,
            ThemeProps = { TextColor3 = "titlecolor" },
        }),
    })

    -- Create content
    local content = Create("TextLabel", {
        Text = config.Content,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.new(0, 16, 0, 60),
        Size = UDim2.new(1, -32, 0, 80),
        BackgroundTransparency = 1,
        ThemeProps = { TextColor3 = "descriptioncolor" },
        RichText = true,
        Parent = dialog,
    })

    -- Create button container
    local buttonContainer = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -16),
        Size = UDim2.new(1, -32, 0, 40),
        BackgroundTransparency = 1,
        Parent = dialog,
    }, {
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
            -- Animate dialog disappearance
            local disappearTween = TweenService:Create(dialog, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            
            local backdropTween = TweenService:Create(backdrop, TweenInfo.new(0.3), {
                BackgroundTransparency = 1
            })
            
            disappearTween:Play()
            backdropTween:Play()
            
            disappearTween.Completed:Connect(function()
                if buttonConfig.Callback and type(buttonConfig.Callback) == "function" then
                    buttonConfig.Callback()
                end
                backdrop:Destroy()
                ActiveDialog = nil
            end)
        end

        local button = setmetatable({
            Container = buttonContainer
        }, ButtonComponent):New({
            Title = buttonConfig.Title,
            Variant = buttonConfig.Variant or (i == 1 and "Primary" or "Ghost"),
            Callback = wrappedCallback,
        })
    end

    -- Close on backdrop click
    local backdropButton = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 99,
        Parent = backdrop,
    })

    backdropButton.MouseButton1Click:Connect(function()
        if config.CloseOnBackdrop ~= false then
            local disappearTween = TweenService:Create(dialog, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            })
            
            local backdropTween = TweenService:Create(backdrop, TweenInfo.new(0.3), {
                BackgroundTransparency = 1
            })
            
            disappearTween:Play()
            backdropTween:Play()
            
            disappearTween.Completed:Connect(function()
                backdrop:Destroy()
                ActiveDialog = nil
            end)
        end
    end)

    ActiveDialog = backdrop
    return dialog
end

return DialogModule
end)() end,
    [4] = function()local wax,script,require=ImportGlobals(4)local ImportGlobals return (function(...)-- Enhanced Element Component
local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")
local Create = Tools.Create

return function(title, desc, parent)
    local Element = {}
    
    Element.Frame = Create("Frame", {
        Name = "Element",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Size = UDim2.new(1, 0, 0, 0),
        Parent = parent,
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        Create("UIPadding", {
            PaddingAll = UDim.new(0, 4),
        }),
    })

    Element.topbox = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Size = UDim2.new(1, 0, 0, 0),
        Parent = Element.Frame,
    })

    -- Enhanced title with better styling
    local titleLabel = Create("TextLabel", {
        Font = Enum.Font.GothamSemibold,
        LineHeight = 1.2,
        RichText = true,
        Text = title,
        ThemeProps = {
            TextColor3 = "titlecolor",
        },
        TextSize = 15,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 0),
        Parent = Element.topbox,
        Name = "Title",
    }, {
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 8),
        }),
    })

    -- Enhanced description with better styling
    local descriptionLabel = Create("TextLabel", {
        Font = Enum.Font.Gotham,
        RichText = true,
        Name = "Description",
        ThemeProps = {
            TextColor3 = "elementdescription",
        },
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = desc or "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 0),
        Parent = Element.Frame,
        TextTransparency = 0.1,
    })

    -- Enhanced hover effect for interactive elements
    local function addHoverEffect()
        local hoverTween = TweenService:Create(Element.Frame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.95,
        })
        
        local normalTween = TweenService:Create(Element.Frame, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
        })
        
        Element.Frame.MouseEnter:Connect(function()
            hoverTween:Play()
        end)
        
        Element.Frame.MouseLeave:Connect(function()
            normalTween:Play()
        end)
    end

    function Element:SetTitle(text)
        titleLabel.Text = text or ""
        
        -- Add a subtle animation when title changes
        TweenService:Create(titleLabel, TweenInfo.new(0.3), {
            TextTransparency = 0.5,
        }):Play()
        
        wait(0.15)
        
        TweenService:Create(titleLabel, TweenInfo.new(0.3), {
            TextTransparency = 0,
        }):Play()
    end

    function Element:SetDesc(text)
        descriptionLabel.Text = text or ""
        descriptionLabel.Visible = text ~= nil and text ~= ""
        
        if text and text ~= "" then
            -- Fade in description
            descriptionLabel.TextTransparency = 1
            TweenService:Create(descriptionLabel, TweenInfo.new(0.3), {
                TextTransparency = 0.1,
            }):Play()
        end
    end

    function Element:SetInteractive(isInteractive)
        if isInteractive then
            addHoverEffect()
        end
    end

    -- Initialize
    Element:SetTitle(title)
    Element:SetDesc(desc)

    function Element:Destroy()
        if Element.Frame then
            Element.Frame:Destroy()
        end
    end

    return Element
end
end)() end,
    [5] = function()local wax,script,require=ImportGlobals(5)local ImportGlobals return (function(...)-- Enhanced Notification System
local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")
local Create = Tools.Create

local NotificationModule = {}
local notificationQueue = {}
local maxNotifications = 5

function NotificationModule:Init(parent)
    self.MainHolder = Create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 320, 0, 400),
        Parent = parent,
        ZIndex = 1000,
    }, {
        Create("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 8),
        }),
    })
end

function NotificationModule:ShowNotification(titleText, descriptionText, duration, notificationType)
    duration = duration or 5
    notificationType = notificationType or "info"
    
    -- Queue system to prevent spam
    if #notificationQueue >= maxNotifications then
        local oldest = table.remove(notificationQueue, 1)
        if oldest and oldest.Parent then
            oldest:Destroy()
        end
    end
    
    -- Create notification
    local notification = Create("CanvasGroup", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        Size = UDim2.new(0, 300, 0, 0),
        Position = UDim2.new(1, 50, 0, 0),
        GroupTransparency = 0.05,
        Parent = self.MainHolder,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 12),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = self:getNotificationColor(notificationType),
            Thickness = 1,
        }),
        Create("DropShadow", {
            Size = UDim2.new(1, 10, 1, 10),
            Position = UDim2.new(0, -5, 0, -5),
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.7,
            ZIndex = -1,
        }),
    })
    
    -- Content container
    local contentContainer = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = notification,
    }, {
        Create("UIPadding", {
            PaddingAll = UDim.new(0, 16),
        }),
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    
    -- Header with icon and title
    local header = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = contentContainer,
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })
    
    -- Notification icon
    local icon = Create("ImageLabel", {
        Image = self:getNotificationIcon(notificationType),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        ImageColor3 = self:getNotificationColor(notificationType),
        Parent = header,
    })
    
    -- Title
    local title = Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = titleText,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 20),
        Parent = header,
    })
    
    -- Description
    local description = Create("TextLabel", {
        Font = Enum.Font.Gotham,
        Text = descriptionText,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = contentContainer,
    })
    
    -- Progress bar
    local progressBar = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 3),
        Parent = notification,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })
    
    local progressFill = Create("Frame", {
        BackgroundColor3 = self:getNotificationColor(notificationType),
        Size = UDim2.new(1, 0, 1, 0),
        Parent = progressBar,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })
    
    -- Close button
    local closeButton = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 8),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Color3.fromRGB(160, 160, 160),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = notification,
    })
    
    -- Animations
    local slideIn = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, 0, 0, 0),
    })
    
    local progressTween = TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0),
    })
    
    -- Start animations
    slideIn:Play()
    progressTween:Play()
    
    -- Close functionality
    local function closeNotification()
        local slideOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 50, 0, 0),
            Size = UDim2.new(0, 0, 0, 0),
        })
        
        slideOut:Play()
        slideOut.Completed:Connect(function()
            notification:Destroy()
            -- Remove from queue
            for i, notif in ipairs(notificationQueue) do
                if notif == notification then
                    table.remove(notificationQueue, i)
                    break
                end
            end
        end)
    end
    
    -- Close events
    closeButton.MouseButton1Click:Connect(closeNotification)
    progressTween.Completed:Connect(closeNotification)
    
    -- Hover effects
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.9,
        }):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {
            TextColor3 = Color3.fromRGB(160, 160, 160),
            BackgroundTransparency = 1,
        }):Play()
    end)
    
    -- Add to queue
    table.insert(notificationQueue, notification)
    
    return notification
end

function NotificationModule:getNotificationColor(notificationType)
    local colors = {
        info = Color3.fromRGB(0, 122, 255),
        success = Color3.fromRGB(52, 199, 89),
        warning = Color3.fromRGB(255, 149, 0),
        error = Color3.fromRGB(255, 59, 48),
    }
    return colors[notificationType] or colors.info
end

function NotificationModule:getNotificationIcon(notificationType)
    local icons = {
        info = "rbxassetid://10723415903",
        success = "rbxassetid://10723415903",
        warning = "rbxassetid://10723415903",
        error = "rbxassetid://10723415903",
    }
    return icons[notificationType] or icons.info
end

return NotificationModule
end)() end,
    [6] = function()local wax,script,require=ImportGlobals(6)local ImportGlobals return (function(...)-- Enhanced Section Component
local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection

return function(configs, parent)
    configs = configs or {}
    configs.Title = configs.Title or ""
    configs.Description = configs.Description or ""
    configs.Default = configs.Default or false
    configs.Locked = configs.Locked or false
    configs.TitleTextSize = configs.TitleTextSize or 15
    configs.Icon = configs.Icon or nil

    local Section = {}
    local isExpanded = configs.Default

    Section.SectionFrame = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        Name = "Section",
        BackgroundTransparency = 1,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Size = UDim2.new(1, 0, 0, 0),
        Parent = parent,
    }, {
        Create("UIPadding", {
            PaddingAll = UDim.new(0, 12),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor"
            },
            Thickness = 1,
        }),
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 10),
        }),
    })

    -- Enhanced header
    local topbox = Create("TextButton", {
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = "",
        BackgroundTransparency = 1,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Size = UDim2.new(1, 0, 0, 0),
        Parent = Section.SectionFrame,
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    -- Enhanced chevron with rotation animation
    local chevronIcon = Create("ImageButton", {
        ThemeProps = {
            ImageColor3 = "titlecolor",
        },
        Image = "rbxassetid://15269180996",
        ImageRectOffset = Vector2.new(0, 257),
        ImageRectSize = Vector2.new(256, 256),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Rotation = isExpanded and 0 or 90,
        ZIndex = 99,
    })

    -- Enhanced title with icon support
    local titleContainer = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = topbox,
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })

    -- Section icon (optional)
    local sectionIcon = nil
    if configs.Icon then
        sectionIcon = Create("ImageLabel", {
            Image = configs.Icon,
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = 1,
            ThemeProps = {
                ImageColor3 = "titlecolor",
            },
            Parent = titleContainer,
        })
    end

    local titleLabel = Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        LineHeight = 1.2,
        RichText = true,
        ThemeProps = {
            TextColor3 = "titlecolor",
        },
        TextSize = configs.TitleTextSize,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = configs.Title,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0),
        Parent = titleContainer,
    }, {
        chevronIcon
    })

    -- Enhanced description
    local descriptionLabel = nil
    if configs.Description and configs.Description ~= "" then
        descriptionLabel = Create("TextLabel", {
            Font = Enum.Font.Gotham,
            RichText = true,
            ThemeProps = {
                TextColor3 = "descriptioncolor",
            },
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = configs.Description,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = topbox,
            TextTransparency = 0.2,
        })
    end

    -- Enhanced container with better animations
    Section.SectionContainer = Create("Frame", {
        Name = "SectionContainer",
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Size = UDim2.new(1, 0, 0, 0),
        Parent = Section.SectionFrame,
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        Create("UIPadding", {
            PaddingAll = UDim.new(0, 4),
        }),
    })

    -- Enhanced toggle functionality with smooth animations
    local function toggleSection()
        if configs.Locked then return end
        
        isExpanded = not isExpanded
        
        -- Animate chevron with smooth rotation
        TweenService:Create(chevronIcon, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Rotation = isExpanded and 0 or 90,
            ImageTransparency = isExpanded and 0 or 0.3,
        }):Play()
        
        -- Animate section container with elastic effect
        local targetSize = isExpanded and 
            UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 16) or 
            UDim2.new(1, 0, 0, 0)
            
        TweenService:Create(Section.SectionContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
        
        -- Animate title color change
        TweenService:Create(titleLabel, TweenInfo.new(0.3), {
            TextTransparency = isExpanded and 0 or 0.3,
        }):Play()
    end

    -- Enhanced hover effects
    local function addHoverEffects()
        if configs.Locked then return end
        
        local hoverTween = TweenService:Create(Section.SectionFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.95,
        })
        
        local normalTween = TweenService:Create(Section.SectionFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
        })
        
        topbox.MouseEnter:Connect(function()
            hoverTween:Play()
            TweenService:Create(chevronIcon, TweenInfo.new(0.2), {
                ImageTransparency = 0,
            }):Play()
        end)
        
        topbox.MouseLeave:Connect(function()
            normalTween:Play()
            TweenService:Create(chevronIcon, TweenInfo.new(0.2), {
                ImageTransparency = isExpanded and 0 or 0.3,
            }):Play()
        end)
    end

    -- Event connections
    if not configs.Locked then
        AddConnection(topbox.MouseButton1Click, toggleSection)
        AddConnection(chevronIcon.MouseButton1Click, toggleSection)
        addHoverEffects()
    else
        -- Hide chevron for locked sections
        chevronIcon.Visible = false
        topbox:Destroy()
    end

    -- Auto-resize when content changes
    AddConnection(Section.SectionContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if isExpanded then
            Section.SectionContainer.Size = UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 16)
        end
    end)

    -- Set initial state
    if isExpanded then
        task.defer(toggleSection)
    end

    return Section
end
end)() end,
    [7] = function()local wax,script,require=ImportGlobals(7)local ImportGlobals return (function(...)-- Enhanced Tab Module
local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local AddScrollAnim = Tools.AddScrollAnim
local CurrentThemeProps = Tools.GetPropsCurrentTheme()

local TabModule = {
    Window = nil,
    Tabs = {},
    Containers = {},
    SelectedTab = 0,
    TabCount = 0,
    SearchContainers = {},
    AnimationSpeed = 0.3,
}

function TabModule:Init(window)
    TabModule.Window = window
    return TabModule
end

function TabModule:New(title, parent, icon)
    local Library = require(script.Parent.Parent)
    local Window = TabModule.Window
    local Elements = Library.Elements

    TabModule.TabCount = TabModule.TabCount + 1
    local TabIndex = TabModule.TabCount

    local Tab = {
        Selected = false,
        Name = title,
        Icon = icon,
        Type = "Tab",
        Index = TabIndex,
    }

    -- Enhanced tab button with icon support
    Tab.TabBtn = Create("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = parent,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 0,
        }),
    })

    -- Enhanced tab content with icon
    local tabContent = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = Tab.TabBtn,
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
        }),
    })

    -- Tab icon (optional)
    local tabIcon = nil
    if icon then
        tabIcon = Create("ImageLabel", {
            Image = icon,
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(120, 120, 120),
            Parent = tabContent,
        })
    end

    -- Enhanced tab title
    local tabTitle = Create("TextLabel", {
        Name = "Title",
        Font = Enum.Font.GothamSemibold,
        TextColor3 = Color3.fromRGB(120, 120, 120),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = title,
        Parent = tabContent,
    })

    -- Enhanced active indicator
    local activeIndicator = Create("Frame", {
        Name = "ActiveIndicator",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0.6, 0),
        ThemeProps = {
            BackgroundColor3 = "primarycolor",
        },
        Parent = Tab.TabBtn,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
        }),
    })

    -- Enhanced search container
    Tab.SearchContainer = Create("Frame", {
        Name = "SearchContainer_" .. TabIndex,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = parent,
        LayoutOrder = TabIndex + 100,
        Visible = false,
    })

    local searchBox = Create("TextBox", {
        Size = UDim2.new(1, -8, 0, 32),
        Position = UDim2.new(0, 4, 0, 4),
        PlaceholderText = "🔍 Search elements...",
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        BackgroundTransparency = 1,
        ThemeProps = {
            TextColor3 = "titlecolor",
            PlaceholderColor3 = "descriptioncolor",
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
            CornerRadius = UDim.new(0, 8),
        }),
    })

    -- Enhanced container with better scrolling
    Tab.Container = Create("ScrollingFrame", {
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ThemeProps = {
            ScrollBarImageColor3 = "scrollocolor",
            BackgroundColor3 = "maincolor",
        },
        ScrollBarThickness = 3,
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
            Padding = UDim.new(0, 8),
        }),
        Create("UIPadding", {
            PaddingAll = UDim.new(0, 12),
        }),
    })

    AddScrollAnim(Tab.Container)

    -- Enhanced canvas size management
    AddConnection(Tab.Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        local targetSize = UDim2.new(0, 0, 0, Tab.Container.UIListLayout.AbsoluteContentSize.Y + 24)
        TweenService:Create(Tab.Container, TweenInfo.new(0.2), {
            CanvasSize = targetSize
        }):Play()
    end)

    -- Enhanced search functionality
    local function searchInElement(element, searchText)
        local title = element:FindFirstChild("Title", true)
        local desc = element:FindFirstChild("Description", true)
        
        local found = false
        if title and string.find(string.lower(title.Text), searchText) then
            found = true
        end
        if desc and string.find(string.lower(desc.Text), searchText) then
            found = true
        end
        
        return found
    end

    local function updateSearch()
        local searchText = string.lower(searchBox.Text)
        
        if not Tab.Container.Visible then return end
        
        for _, child in ipairs(Tab.Container:GetChildren()) do
            if child:IsA("Frame") and child.Name == "Section" then
                local sectionContainer = child:FindFirstChild("SectionContainer")
                if sectionContainer then
                    local hasVisibleElements = false
                    
                    for _, element in ipairs(sectionContainer:GetChildren()) do
                        if element:IsA("Frame") and element.Name == "Element" then
                            local shouldShow = searchText == "" or searchInElement(element, searchText)
                            element.Visible = shouldShow
                            if shouldShow then
                                hasVisibleElements = true
                            end
                        end
                    end
                    
                    child.Visible = hasVisibleElements or searchText == ""
                end
            elseif child:IsA("Frame") and child.Name == "Element" then
                local shouldShow = searchText == "" or searchInElement(child, searchText)
                child.Visible = shouldShow
            end
        end
    end

    -- Enhanced search event handling
    AddConnection(searchBox:GetPropertyChangedSignal("Text"), updateSearch)
    AddConnection(Tab.Container:GetPropertyChangedSignal("Visible"), function()
        if Tab.Container.Visible then
            updateSearch()
        end
    end)

    -- Enhanced hover effects for tab
    local function addTabHoverEffects()
        local hoverTween = TweenService:Create(Tab.TabBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.95,
        })
        
        local normalTween = TweenService:Create(Tab.TabBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
        })
        
        Tab.TabBtn.MouseEnter:Connect(function()
            if not Tab.Selected then
                hoverTween:Play()
            end
        end)
        
        Tab.TabBtn.MouseLeave:Connect(function()
            if not Tab.Selected then
                normalTween:Play()
            end
        end)
    end

    addTabHoverEffects()

    -- Enhanced tab click handling
    AddConnection(Tab.TabBtn.MouseButton1Click, function()
        TabModule:SelectTab(TabIndex)
    end)

    -- Store references
    TabModule.Containers[TabIndex] = Tab.Container
    TabModule.Tabs[TabIndex] = Tab
    TabModule.SearchContainers[TabIndex] = Tab.SearchContainer

    -- Enhanced section creation
    function Tab:AddSection(configs)
        configs = configs or {}
        local Section = { Type = "Section" }
        
        local SectionFrame = require(script.Parent.section)(configs, Tab.Container)
        Section.Container = SectionFrame.SectionContainer
        Section.Frame = SectionFrame.SectionFrame

        -- Enhanced group button functionality
        function Section:AddGroupButton()
            local GroupButton = { Type = "Group" }
            GroupButton.GroupContainer = Create("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                ThemeProps = {
                    BackgroundColor3 = "maincolor",
                },
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

    -- Enhanced tab properties
    Tab.TabBtn.Title = tabTitle
    Tab.TabBtn.Icon = tabIcon
    Tab.TabBtn.ActiveIndicator = activeIndicator
    Tab.ContainerFrame = Tab.Container

    return Tab
end

-- Enhanced tab selection with smooth animations
function TabModule:SelectTab(tabIndex)
    if TabModule.SelectedTab == tabIndex then return end
    
    TabModule.SelectedTab = tabIndex
    local currentTheme = Tools.GetPropsCurrentTheme()

    -- Animate all tabs
    for i, tab in pairs(TabModule.Tabs) do
        local isSelected = (i == tabIndex)
        local tweenInfo = TweenInfo.new(TabModule.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        -- Animate title color
        TweenService:Create(tab.TabBtn.Title, tweenInfo, {
            TextColor3 = isSelected and currentTheme.onTextBtn or currentTheme.offTextBtn,
        }):Play()
        
        -- Animate icon color (if exists)
        if tab.TabBtn.Icon then
            TweenService:Create(tab.TabBtn.Icon, tweenInfo, {
                ImageColor3 = isSelected and currentTheme.onTextBtn or currentTheme.offTextBtn,
            }):Play()
        end
        
        -- Animate active indicator
        TweenService:Create(tab.TabBtn.ActiveIndicator, tweenInfo, {
            Size = isSelected and UDim2.new(0, 3, 0.6, 0) or UDim2.new(0, 0, 0.6, 0),
        }):Play()
        
        -- Animate background
        TweenService:Create(tab.TabBtn, tweenInfo, {
            BackgroundTransparency = isSelected and 0.95 or 1,
        }):Play()
        
        -- Update selection state
        tab.Selected = isSelected
        
        -- Show/hide search containers
        if TabModule.SearchContainers[i] then
            TabModule.SearchContainers[i].Visible = isSelected
        end
    end

    -- Animate container visibility
    task.spawn(function()
        for i, container in pairs(TabModule.Containers) do
            if i == tabIndex then
                container.Visible = true
                -- Fade in animation
                container.GroupTransparency = 1
                TweenService:Create(container, TweenInfo.new(TabModule.AnimationSpeed), {
                    GroupTransparency = 0,
                }):Play()
            else
                -- Fade out animation
                TweenService:Create(container, TweenInfo.new(TabModule.AnimationSpeed * 0.5), {
                    GroupTransparency = 1,
                }):Play()
                
                task.wait(TabModule.AnimationSpeed * 0.5)
                container.Visible = false
            end
        end
    end)
end

-- Enhanced cleanup
function TabModule:CleanupTab(tabIndex)
    if TabModule.SearchContainers[tabIndex] then
        TabModule.SearchContainers[tabIndex]:Destroy()
        TabModule.SearchContainers[tabIndex] = nil
    end
    
    if TabModule.Containers[tabIndex] then
        TabModule.Containers[tabIndex]:Destroy()
        TabModule.Containers[tabIndex] = nil
    end
    
    if TabModule.Tabs[tabIndex] then
        TabModule.Tabs[tabIndex] = nil
    end
end

return TabModule
end)() end,
    [8] = function()local wax,script,require=ImportGlobals(8)local ImportGlobals return (function(...)-- Enhanced Elements Collection
local Elements = {}

-- Load all element modules
for _, elementModule in pairs(script:GetChildren()) do
    if elementModule:IsA("ModuleScript") then
        local success, element = pcall(require, elementModule)
        if success and element.__type then
            table.insert(Elements, element)
        else
            warn("Failed to load element: " .. elementModule.Name)
        end
    end
end

-- Sort elements by type for consistent loading
table.sort(Elements, function(a, b)
    return a.__type < b.__type
end)

return Elements
end)() end,
    [9] = function()local wax,script,require=ImportGlobals(9)local ImportGlobals return (function(...)-- Enhanced Bind Element
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local BlacklistedKeys = {
    Enum.KeyCode.Unknown,
    Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
    Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right,
    Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape,
    Enum.KeyCode.Return, Enum.KeyCode.Space,
}

local Element = {}
Element.__index = Element
Element.__type = "Bind"

function Element:New(idx, config)
    assert(config.Title, "Bind - Missing Title")
    config.Description = config.Description or ""
    config.Hold = config.Hold or false
    config.Default = config.Default or Enum.KeyCode.F
    config.Callback = config.Callback or function() end
    config.ChangeCallback = config.ChangeCallback or function() end
    
    local Bind = {
        Value = config.Default,
        Binding = false,
        Holding = false,
        Type = "Bind",
        Callback = config.Callback,
        ChangeCallback = config.ChangeCallback,
    }

    local BindFrame = require(Components.element)(config.Title, config.Description, self.Container)
    BindFrame:SetInteractive(true)

    -- Enhanced bind display
    local bindDisplay = Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 80, 0, 24),
        ThemeProps = {
            BackgroundColor3 = "bordercolor",
        },
        Parent = BindFrame.topbox,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "primarycolor",
            },
            Thickness = 0,
        }),
    })

    local bindText = Create("TextLabel", {
        Font = Enum.Font.GothamSemibold,
        Text = config.Default.Name,
        ThemeProps = {
            TextColor3 = "titlecolor",
        },
        TextSize = 12,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = bindDisplay,
    })

    -- Enhanced visual feedback
    local function updateBindDisplay(isBinding)
        local targetColor = isBinding and "primarycolor" or "bordercolor"
        local targetStroke = isBinding and 1 or 0
        
        TweenService:Create(bindDisplay, TweenInfo.new(0.2), {
            ThemeProps = { BackgroundColor3 = targetColor }
        }):Play()
        
        TweenService:Create(bindDisplay.UIStroke, TweenInfo.new(0.2), {
            Thickness = targetStroke
        }):Play()
        
        bindText.Text = isBinding and "..." or (Bind.Value and Bind.Value.Name or "None")
    end

    -- Enhanced click handling
    AddConnection(BindFrame.Frame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Bind.Binding then return end
            
            Bind.Binding = true
            updateBindDisplay(true)
        end
    end)

    -- Enhanced key binding
    function Bind:Set(key)
        if key and not table.find(BlacklistedKeys, key) then
            self.Value = key
            self.Binding = false
            updateBindDisplay(false)
            
            if self.ChangeCallback then
                self.ChangeCallback(key)
            end
        end
    end

    -- Enhanced input handling
    AddConnection(UserInputService.InputBegan, function(input)
        if UserInputService:GetFocusedTextBox() then return end
        
        if Bind.Binding then
            local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
            Bind:Set(key)
        elseif Bind.Value and (input.KeyCode == Bind.Value or input.UserInputType == Bind.Value) then
            if config.Hold then
                Bind.Holding = true
                if Bind.Callback then
                    Bind.Callback(true)
                end
            else
                if Bind.Callback then
                    Bind.Callback()
                end
            end
        end
    end)

    AddConnection(UserInputService.InputEnded, function(input)
        if config.Hold and Bind.Holding and (input.KeyCode == Bind.Value or input.UserInputType == Bind.Value) then
            Bind.Holding = false
            if Bind.Callback then
                Bind.Callback(false)
            end
        end
    end)

    -- Initialize
    Bind:Set(config.Default)
    
    self.Library.Flags[idx] = Bind
    return Bind
end

return Element
end)() end,
    [10] = function()local wax,script,require=ImportGlobals(10)local ImportGlobals return (function(...)-- Enhanced Button Element
local TweenService = game:GetService("TweenService")
local Tools = require(script.Parent.Parent.tools)

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local Element = {}
Element.__index = Element
Element.__type = "Button"

-- Enhanced button styles with better theming
local ButtonStyles = {
    Primary = {
        font = Enum.Font.GothamSemibold,
        textSize = 14,
        cornerRadius = 8,
        padding = {12, 8},
        animations = {
            hover = { scale = 1.02, duration = 0.2 },
            press = { scale = 0.98, duration = 0.1 },
        }
    },
    Secondary = {
        font = Enum.Font.GothamSemibold,
        textSize = 14,
        cornerRadius = 8,
        padding = {12, 8},
        animations = {
            hover = { scale = 1.02, duration = 0.2 },
            press = { scale = 0.98, duration = 0.1 },
        }
    },
    Ghost = {
        font = Enum.Font.Gotham,
        textSize = 14,
        cornerRadius = 8,
        padding = {12, 8},
        animations = {
            hover = { scale = 1.02, duration = 0.2 },
            press = { scale = 0.98, duration = 0.1 },
        }
    },
    Outline = {
        font = Enum.Font.Gotham,
        textSize = 14,
        cornerRadius = 8,
        padding = {12, 8},
        animations = {
            hover = { scale = 1.02, duration = 0.2 },
            press = { scale = 0.98, duration = 0.1 },
        }
    },
}

-- Enhanced button color schemes
local function getButtonColors(variant, theme)
    local colors = {
        Primary = {
            background = theme.primarycolor,
            text = Color3.fromRGB(255, 255, 255),
            border = theme.primarycolor,
            hover = {
                background = Color3.fromRGB(
                    math.min(255, theme.primarycolor.R * 255 + 20),
                    math.min(255, theme.primarycolor.G * 255 + 20),
                    math.min(255, theme.primarycolor.B * 255 + 20)
                ),
            },
            press = {
                background = Color3.fromRGB(
                    math.max(0, theme.primarycolor.R * 255 - 20),
                    math.max(0, theme.primarycolor.G * 255 - 20),
                    math.max(0, theme.primarycolor.B * 255 - 20)
                ),
            },
        },
        Secondary = {
            background = theme.bordercolor,
            text = theme.titlecolor,
            border = theme.bordercolor,
            hover = {
                background = Color3.fromRGB(60, 60, 65),
            },
            press = {
                background = Color3.fromRGB(30, 30, 35),
            },
        },
        Ghost = {
            background = Color3.fromRGB(0, 0, 0),
            backgroundTransparency = 1,
            text = theme.titlecolor,
            border = Color3.fromRGB(0, 0, 0),
            hover = {
                background = theme.bordercolor,
                backgroundTransparency = 0.9,
            },
            press = {
                background = theme.bordercolor,
                backgroundTransparency = 0.8,
            },
        },
        Outline = {
            background = Color3.fromRGB(0, 0, 0),
            backgroundTransparency = 1,
            text = theme.titlecolor,
            border = theme.bordercolor,
            hover = {
                background = theme.bordercolor,
                backgroundTransparency = 0.95,
            },
            press = {
                background = theme.bordercolor,
                backgroundTransparency = 0.9,
            },
        },
    }
    
    return colors[variant] or colors.Primary
end

function Element:New(config)
    assert(config.Title, "Button - Missing Title")
    config.Variant = config.Variant or "Primary"
    config.Icon = config.Icon or nil
    config.Callback = config.Callback or function() end
    config.Disabled = config.Disabled or false
    
    local Button = {
        Disabled = config.Disabled,
        Callback = config.Callback,
    }
    
    local theme = Tools.GetPropsCurrentTheme()
    local style = ButtonStyles[config.Variant]
    local colors = getButtonColors(config.Variant, theme)
    
    -- Create button container
    local buttonContainer = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = self.Container,
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })
    
    -- Create the actual button
    Button.Element = Create("TextButton", {
        Font = style.font,
        Text = config.Title,
        TextSize = style.textSize,
        TextColor3 = colors.text,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = colors.background,
        BackgroundTransparency = colors.backgroundTransparency or 0,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, 32),
        Parent = buttonContainer,
        AutoButtonColor = false,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, style.cornerRadius),
        }),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, style.padding[1]),
            PaddingRight = UDim.new(0, style.padding[1]),
            PaddingTop = UDim.new(0, style.padding[2]),
            PaddingBottom = UDim.new(0, style.padding[2]),
        }),
    })
    
    -- Add border for outline variant
    if config.Variant == "Outline" then
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = colors.border,
            Thickness = 1,
            Parent = Button.Element,
        })
    end
    
    -- Add icon if specified
    if config.Icon then
        local iconContainer = Create("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = 1,
            Parent = Button.Element,
        }, {
            Create("ImageLabel", {
                Image = config.Icon,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ImageColor3 = colors.text,
            }),
        })
        
        -- Adjust button layout for icon
        local buttonLayout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = Button.Element,
        })
        
        Button.Element.Text = ""
        
        local textLabel = Create("TextLabel", {
            Font = style.font,
            Text = config.Title,
            TextSize = style.textSize,
            TextColor3 = colors.text,
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 18),
            Parent = Button.Element,
        })
    end
    
    -- Enhanced animation system
    local originalSize = Button.Element.Size
    local isHovering = false
    local isPressed = false
    
    local function updateButtonState()
        local targetScale = 1
        local targetColors = colors
        
        if Button.Disabled then
            targetColors = {
                background = Color3.fromRGB(60, 60, 60),
                text = Color3.fromRGB(120, 120, 120),
            }
        elseif isPressed then
            targetScale = style.animations.press.scale
            targetColors = colors.press or colors
        elseif isHovering then
            targetScale = style.animations.hover.scale
            targetColors = colors.hover or colors
        end
        
        -- Scale animation
        TweenService:Create(Button.Element, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(
                originalSize.X.Scale * targetScale,
                originalSize.X.Offset * targetScale,
                originalSize.Y.Scale * targetScale,
                originalSize.Y.Offset * targetScale
            ),
        }):Play()
        
        -- Color animations
        TweenService:Create(Button.Element, TweenInfo.new(0.2), {
            BackgroundColor3 = targetColors.background or colors.background,
            BackgroundTransparency = targetColors.backgroundTransparency or colors.backgroundTransparency or 0,
            TextColor3 = targetColors.text or colors.text,
        }):Play()
    end
    
    -- Enhanced event handling
    AddConnection(Button.Element.MouseEnter, function()
        if not Button.Disabled then
            isHovering = true
            updateButtonState()
        end
    end)
    
    AddConnection(Button.Element.MouseLeave, function()
        isHovering = false
        isPressed = false
        updateButtonState()
    end)
    
    AddConnection(Button.Element.MouseButton1Down, function()
        if not Button.Disabled then
            isPressed = true
            updateButtonState()
        end
    end)
    
    AddConnection(Button.Element.MouseButton1Up, function()
        if not Button.Disabled then
            isPressed = false
            updateButtonState()
        end
    end)
    
    AddConnection(Button.Element.MouseButton1Click, function()
        if not Button.Disabled and Button.Callback then
            -- Visual feedback
            local feedbackTween = TweenService:Create(Button.Element, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.5,
            })
            feedbackTween:Play()
            
            feedbackTween.Completed:Connect(function()
                TweenService:Create(Button.Element, TweenInfo.new(0.1), {
                    BackgroundTransparency = colors.backgroundTransparency or 0,
                }):Play()
            end)
            
            Button.Callback()
        end
    end)
    
    -- Button methods
    function Button:SetDisabled(disabled)
        self.Disabled = disabled
        updateButtonState()
    end
    
    function Button:SetText(text)
        self.Element.Text = text
    end
    
    function Button:SetCallback(callback)
        self.Callback = callback
    end
    
    return Button
end

return Element
end)() end,
    [11] = function()local wax,script,require=ImportGlobals(11)local ImportGlobals return (function(...)-- Enhanced Colorpicker Element
local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- Enhanced rainbow color system
local RainbowColorValue = 0
local rainbowIncrement = 1 / 255

task.spawn(function()
    while true do
        RainbowColorValue = (RainbowColorValue + rainbowIncrement) % 1
        task.wait(0.1)
    end
end)

local Element = {}
Element.__index = Element
Element.__type = "Colorpicker"

function Element:New(idx, config)
    assert(config.Title, "Colorpicker - Missing Title")
    config.Description = config.Description or ""
    config.Default = config.Default or Color3.fromRGB(255, 255, 255)
    config.Transparency = config.Transparency or 0
    config.Callback = config.Callback or function() end
    
    local Colorpicker = {
        Value = config.Default,
        Transparency = config.Transparency,
        Type = "Colorpicker",
        Callback = config.Callback,
        RainbowMode = false,
        Open = false,
        Hue = 0,
        Sat = 1,
        Val = 1,
    }
    
    -- Initialize HSV values
    Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Val = Color3.toHSV(config.Default)
    
    local ColorpickerFrame = require(Components.element)(config.Title, config.Description, self.Container)
    ColorpickerFrame:SetInteractive(true)
    
    -- Enhanced color preview
    local colorPreview = Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 80, 0, 24),
        BackgroundColor3 = config.Default,
        Parent = ColorpickerFrame.topbox,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
    })
    
    -- Enhanced hex input
    local hexInput = Create("TextBox", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -90, 0, 0),
        Size = UDim2.new(0, 70, 0, 24),
        Font = Enum.Font.GothamMono,
        TextSize = 12,
        Text = "#" .. config.Default:ToHex(),
        ThemeProps = {
            TextColor3 = "titlecolor",
            BackgroundColor3 = "maincolor",
        },
        BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = ColorpickerFrame.topbox,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
    })
    
    -- Enhanced colorpicker panel
    local colorpickerPanel = Create("Frame", {
        Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(1, 0, 0, 200),
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Visible = false,
        Parent = ColorpickerFrame.Frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
        Create("UIPadding", {
            PaddingAll = UDim.new(0, 12),
        }),
    })
    
    -- Enhanced color gradient
    local colorGradient = Create("ImageLabel", {
        Image = "rbxassetid://4155801252",
        Size = UDim2.new(1, -20, 0, 140),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        Parent = colorpickerPanel,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
    })
    
    -- Enhanced color selector
    local colorSelector = Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = colorGradient,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
        Create("UIStroke", {
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 2,
        }),
    })
    
    -- Enhanced hue bar
    local hueBar = Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 12, 0, 140),
        Parent = colorpickerPanel,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
            }),
            Rotation = 270,
        }),
    })
    
    -- Enhanced hue selector
    local hueSelector = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0, 16, 0, 6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = hueBar,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 3),
        }),
        Create("UIStroke", {
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 1,
        }),
    })
    
    -- Enhanced rainbow toggle
    local rainbowToggle = Create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = colorpickerPanel,
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
        }),
    })
    
    local rainbowCheckbox = Create("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Text = "",
        ThemeProps = {
            BackgroundColor3 = "bordercolor",
        },
        Parent = rainbowToggle,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "primarycolor",
            },
            Thickness = 1,
        }),
        Create("ImageLabel", {
            Image = "rbxassetid://6031094667",
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ThemeProps = {
                ImageColor3 = "maincolor",
            },
            ImageTransparency = 1,
        }),
    })
    
    local rainbowLabel = Create("TextLabel", {
        Font = Enum.Font.Gotham,
        Text = "Rainbow",
        TextSize = 12,
        ThemeProps = {
            TextColor3 = "titlecolor",
        },
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = rainbowToggle,
    })
    
    -- Enhanced update function
    local function updateColorpicker()
        local newColor = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Val)
        
        -- Update preview
        colorPreview.BackgroundColor3 = newColor
        
        -- Update hex input
        hexInput.Text = "#" .. newColor:ToHex()
        
        -- Update gradient background
        colorGradient.BackgroundColor3 = Color3.fromHSV(Colorpicker.Hue, 1, 1)
        
        -- Update selector
        colorSelector.BackgroundColor3 = newColor
        
        -- Store value
        Colorpicker.Value = newColor
        
        -- Call callback
        if Colorpicker.Callback then
            Colorpicker.Callback(newColor)
        end
    end
    
    -- Enhanced interaction handlers
    local function updateColorFromPosition()
        local colorX = math.clamp(mouse.X - colorGradient.AbsolutePosition.X, 0, colorGradient.AbsoluteSize.X)
        local colorY = math.clamp(mouse.Y - colorGradient.AbsolutePosition.Y, 0, colorGradient.AbsoluteSize.Y)
        
        colorSelector.Position = UDim2.new(colorX / colorGradient.AbsoluteSize.X, 0, colorY / colorGradient.AbsoluteSize.Y, 0)
        
        Colorpicker.Sat = colorX / colorGradient.AbsoluteSize.X
        Colorpicker.Val = 1 - (colorY / colorGradient.AbsoluteSize.Y)
        
        updateColorpicker()
    end
    
    local function updateHueFromPosition()
        local hueY = math.clamp(mouse.Y - hueBar.AbsolutePosition.Y, 0, hueBar.AbsoluteSize.Y)
        
        hueSelector.Position = UDim2.new(0.5, 0, hueY / hueBar.AbsoluteSize.Y, 0)
        
        Colorpicker.Hue = hueY / hueBar.AbsoluteSize.Y
        
        updateColorpicker()
    end
    
    -- Enhanced event connections
    local colorConnection, hueConnection
    
    AddConnection(colorGradient.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not Colorpicker.RainbowMode then
            if colorConnection then colorConnection:Disconnect() end
            colorConnection = AddConnection(mouse.Move, updateColorFromPosition)
            updateColorFromPosition()
        end
    end)
    
    AddConnection(colorGradient.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and colorConnection then
            colorConnection:Disconnect()
            colorConnection = nil
        end
    end)
    
    AddConnection(hueBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not Colorpicker.RainbowMode then
            if hueConnection then hueConnection:Disconnect() end
            hueConnection = AddConnection(mouse.Move, updateHueFromPosition)
            updateHueFromPosition()
        end
    end)
    
    AddConnection(hueBar.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and hueConnection then
            hueConnection:Disconnect()
            hueConnection = nil
        end
    end)
    
    -- Enhanced toggle functionality
    AddConnection(ColorpickerFrame.Frame.MouseButton1Click, function()
        Colorpicker.Open = not Colorpicker.Open
        
        -- Animate panel
        if Colorpicker.Open then
            colorpickerPanel.Visible = true
            colorpickerPanel.Size = UDim2.new(1, 0, 0, 0)
            TweenService:Create(colorpickerPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Size = UDim2.new(1, 0, 0, 200)
            }):Play()
        else
            TweenService:Create(colorpickerPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            
            task.wait(0.3)
            colorpickerPanel.Visible = false
        end
    end)
    
    -- Enhanced rainbow functionality
    AddConnection(rainbowCheckbox.MouseButton1Click, function()
        Colorpicker.RainbowMode = not Colorpicker.RainbowMode
        
        -- Animate checkbox
        TweenService:Create(rainbowCheckbox, TweenInfo.new(0.2), {
            BackgroundTransparency = Colorpicker.RainbowMode and 0 or 1
        }):Play()
        
        TweenService:Create(rainbowCheckbox.ImageLabel, TweenInfo.new(0.2), {
            ImageTransparency = Colorpicker.RainbowMode and 0 or 1
        }):Play()
        
        if Colorpicker.RainbowMode then
            task.spawn(function()
                while Colorpicker.RainbowMode do
                    Colorpicker.Hue = RainbowColorValue
                    hueSelector.Position = UDim2.new(0.5, 0, RainbowColorValue, 0)
                    updateColorpicker()
                    task.wait(0.1)
                end
            end)
        end
    end)
    
    -- Enhanced hex input handling
    AddConnection(hexInput.FocusLost, function(enterPressed)
        if enterPressed then
            local success, color = pcall(Color3.fromHex, hexInput.Text)
            if success then
                Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Val = Color3.toHSV(color)
                updateColorpicker()
            end
        end
    end)
    
    -- Enhanced set function
    function Colorpicker:Set(color)
        self.Value = color
        self.Hue, self.Sat, self.Val = Color3.toHSV(color)
        
        -- Update selectors
        colorSelector.Position = UDim2.new(self.Sat, 0, 1 - self.Val, 0)
        hueSelector.Position = UDim2.new(0.5, 0, self.Hue, 0)
        
        updateColorpicker()
    end
    
    -- Initialize
    updateColorpicker()
    
    self.Library.Flags[idx] = Colorpicker
    return Colorpicker
end

return Element
end)() end,
    [12] = function()local wax,script,require=ImportGlobals(12)local ImportGlobals return (function(...)-- Enhanced Dropdown Element
local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local Element = {}
Element.__index = Element
Element.__type = "Dropdown"

function Element:New(idx, config)
    assert(config.Title, "Dropdown - Missing Title")
    config.Description = config.Description or ""
    config.Options = config.Options or {}
    config.Default = config.Default or ""
    config.Multiple = config.Multiple or false
    config.MaxOptions = config.MaxOptions or 5
    config.Placeholder = config.Placeholder or "Select an option..."
    config.Search = config.Search ~= false
    config.Callback = config.Callback or function() end
    
    local Dropdown = {
        Value = config.Multiple and {} or config.Default,
        Options = config.Options,
        Open = false,
        Multiple = config.Multiple,
        MaxOptions = config.MaxOptions,
        Callback = config.Callback,
        Type = "Dropdown",
        OptionButtons = {},
    }
    
    local DropdownFrame = require(Components.element)(config.Title, config.Description, self.Container)
    DropdownFrame:SetInteractive(true)
    
    -- Enhanced dropdown container
    local dropdownContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Parent = DropdownFrame.Frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
    })
    
    -- Enhanced dropdown button
    local dropdownButton = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        BackgroundTransparency = 1,
        Parent = dropdownContainer,
    })
    
    -- Enhanced dropdown content
    local dropdownContent = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = dropdownContainer,
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
        }),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
    })
    
    -- Enhanced selected values container
    local selectedContainer = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = dropdownContent,
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 4),
        }),
    })
    
    -- Enhanced dropdown arrow
    local dropdownArrow = Create("ImageLabel", {
        Image = "rbxassetid://15269180996",
        ImageRectOffset = Vector2.new(0, 257),
        ImageRectSize = Vector2.new(256, 256),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundTransparency = 1,
        ThemeProps = {
            ImageColor3 = "titlecolor",
        },
        Rotation = 90,
        Parent = dropdownContent,
    })
    
    -- Enhanced placeholder text
    local placeholderText = Create("TextLabel", {
        Font = Enum.Font.Gotham,
        Text = config.Placeholder,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ThemeProps = {
            TextColor3 = "descriptioncolor",
        },
        Size = UDim2.new(1, 0, 1, 0),
        Parent = dropdownContent,
    })
    
    -- Enhanced dropdown menu
    local dropdownMenu = Create("Frame", {
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 0),
        ThemeProps = {
            BackgroundColor3 = "containeritemsbg",
        },
        BorderSizePixel = 0,
        Visible = false,
        Parent = DropdownFrame.Frame,
        ZIndex = 10,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
        Create("DropShadow", {
            Size = UDim2.new(1, 10, 1, 10),
            Position = UDim2.new(0, -5, 0, -5),
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.8,
            ZIndex = -1,
        }),
    })
    
    -- Enhanced search box
    local searchBox = nil
    if config.Search then
        searchBox = Create("TextBox", {
            Size = UDim2.new(1, -16, 0, 32),
            Position = UDim2.new(0, 8, 0, 8),
            PlaceholderText = "Search options...",
            Text = "",
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ThemeProps = {
                TextColor3 = "titlecolor",
                PlaceholderColor3 = "descriptioncolor",
            },
            Parent = dropdownMenu,
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),
            Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                ThemeProps = {
                    Color = "bordercolor",
                },
                Thickness = 1,
            }),
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }),
        })
    end
    
    -- Enhanced options container
    local optionsContainer = Create("ScrollingFrame", {
        Position = UDim2.new(0, 8, 0, config.Search and 48 or 8),
        Size = UDim2.new(1, -16, 1, -(config.Search and 56 or 16)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ThemeProps = {
            ScrollBarImageColor3 = "scrollocolor",
        },
        ScrollBarImageTransparency = 0.5,
        Parent = dropdownMenu,
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        }),
    })
    
    -- Enhanced option creation
    local function createOption(option, index)
        local optionButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            Text = "",
            BackgroundTransparency = 1,
            ThemeProps = {
                BackgroundColor3 = "itembg",
            },
            Parent = optionsContainer,
            LayoutOrder = index,
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),
        })
        
        local optionContent = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = optionButton,
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8),
            }),
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }),
        })
        
        local optionCheck = Create("ImageLabel", {
            Image = "rbxassetid://15269180838",
            ImageRectOffset = Vector2.new(514, 257),
            ImageRectSize = Vector2.new(256, 256),
            Size = UDim2.new(0, 14, 0, 14),
            BackgroundTransparency = 1,
            ThemeProps = {
                ImageColor3 = "itemcheckmarkcolor",
            },
            ImageTransparency = 1,
            Parent = optionContent,
        })
        
        local optionLabel = Create("TextLabel", {
            Font = Enum.Font.Gotham,
            Text = option,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ThemeProps = {
                TextColor3 = "itemTextOff",
            },
            Size = UDim2.new(1, 0, 1, 0),
            Parent = optionContent,
        })
        
        -- Enhanced option interactions
        local function updateOptionState(selected)
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart)
            
            TweenService:Create(optionButton, tweenInfo, {
                BackgroundTransparency = selected and 0.9 or 1,
            }):Play()
            
            TweenService:Create(optionCheck, tweenInfo, {
                ImageTransparency = selected and 0 or 1,
            }):Play()
            
            TweenService:Create(optionLabel, tweenInfo, {
                TextColor3 = selected and Tools.GetPropsCurrentTheme().itemTextOn or Tools.GetPropsCurrentTheme().itemTextOff,
            }):Play()
        end
        
        -- Enhanced hover effects
        AddConnection(optionButton.MouseEnter, function()
            TweenService:Create(optionButton, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.95,
            }):Play()
        end)
        
        AddConnection(optionButton.MouseLeave, function()
            local isSelected = config.Multiple and 
                table.find(Dropdown.Value, option) or 
                Dropdown.Value == option
            updateOptionState(isSelected)
        end)
        
        AddConnection(optionButton.MouseButton1Click, function()
            if config.Multiple then
                local index = table.find(Dropdown.Value, option)
                if index then
                    table.remove(Dropdown.Value, index)
                else
                    if #Dropdown.Value < config.MaxOptions then
                        table.insert(Dropdown.Value, option)
                    end
                end
            else
                Dropdown.Value = Dropdown.Value == option and "" or option
                Dropdown:Close()
            end
            
            Dropdown:UpdateDisplay()
            if Dropdown.Callback then
                Dropdown.Callback(Dropdown.Value)
            end
        end)
        
        Dropdown.OptionButtons[option] = {
            button = optionButton,
            updateState = updateOptionState,
        }
        
        return optionButton
    end
    
    -- Enhanced value display
    local function createValueChip(value)
        local chip = Create("Frame", {
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 0, 20),
            ThemeProps = {
                BackgroundColor3 = "valuebg",
            },
            Parent = selectedContainer,
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 10),
            }),
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }),
        })
        
        local chipContent = Create("Frame", {
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = chip,
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 4),
            }),
        })
        
        local chipText = Create("TextLabel", {
            Font = Enum.Font.Gotham,
            Text = value,
            TextSize = 11,
            ThemeProps = {
                TextColor3 = "valuetext",
            },
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = chipContent,
        })
        
        local chipClose = Create("TextButton", {
            Size = UDim2.new(0, 12, 0, 12),
            Text = "×",
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            ThemeProps = {
                TextColor3 = "valuetext",
            },
            BackgroundTransparency = 1,
            Parent = chipContent,
        })
        
        AddConnection(chipClose.MouseButton1Click, function()
            if config.Multiple then
                local index = table.find(Dropdown.Value, value)
                if index then
                    table.remove(Dropdown.Value, index)
                    Dropdown:UpdateDisplay()
                    if Dropdown.Callback then
                        Dropdown.Callback(Dropdown.Value)
                    end
                end
            end
        end)
        
        return chip
    end
    
    -- Enhanced dropdown functions
    function Dropdown:UpdateDisplay()
        -- Clear existing chips
        for _, child in pairs(selectedContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Update placeholder visibility
        local hasValue = false
        
        if self.Multiple then
            hasValue = #self.Value > 0
            for _, value in pairs(self.Value) do
                createValueChip(value)
            end
        else
            hasValue = self.Value ~= ""
            if hasValue then
                createValueChip(self.Value)
            end
        end
        
        placeholderText.Visible = not hasValue
        
        -- Update option states
        for option, optionData in pairs(self.OptionButtons) do
            local isSelected = self.Multiple and 
                table.find(self.Value, option) or 
                self.Value == option
            optionData.updateState(isSelected)
        end
    end
    
    function Dropdown:Open()
        if self.Open then return end
        
        self.Open = true
        dropdownMenu.Visible = true
        
        -- Calculate menu height
        local optionCount = math.min(#self.Options, 6)
        local menuHeight = (config.Search and 48 or 8) + (optionCount * 30) + 8
        
        -- Animate arrow
        TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {
            Rotation = 180,
        }):Play()
        
        -- Animate menu
        dropdownMenu.Size = UDim2.new(1, 0, 0, 0)
        TweenService:Create(dropdownMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(1, 0, 0, menuHeight),
        }):Play()
        
        -- Focus search box
        if searchBox then
            searchBox:CaptureFocus()
        end
    end
    
    function Dropdown:Close()
        if not self.Open then return end
        
        self.Open = false
        
        -- Animate arrow
        TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {
            Rotation = 90,
        }):Play()
        
        -- Animate menu
        TweenService:Create(dropdownMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(1, 0, 0, 0),
        }):Play()
        
        task.wait(0.3)
        dropdownMenu.Visible = false
        
        -- Clear search
        if searchBox then
            searchBox.Text = ""
            searchBox:ReleaseFocus()
        end
    end
    
    function Dropdown:Set(value)
        self.Value = value
        self:UpdateDisplay()
    end
    
    function Dropdown:SetOptions(options)
        self.Options = options
        self.OptionButtons = {}
        
        -- Clear existing options
        for _, child in pairs(optionsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Create new options
        for i, option in pairs(options) do
            createOption(option, i)
        end
        
        -- Update canvas size
        optionsContainer.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
    end
    
    -- Enhanced search functionality
    if searchBox then
        AddConnection(searchBox:GetPropertyChangedSignal("Text"), function()
            local searchText = string.lower(searchBox.Text)
            
            for option, optionData in pairs(Dropdown.OptionButtons) do
                local visible = searchText == "" or string.find(string.lower(option), searchText)
                optionData.button.Visible = visible
            end
        end)
    end
    
    -- Enhanced event handling
    AddConnection(dropdownButton.MouseButton1Click, function()
        if Dropdown.Open then
            Dropdown:Close()
        else
            Dropdown:Open()
        end
    end)
    
    -- Close on click outside
    AddConnection(UserInputService.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local inDropdown = false
            
            -- Check if click is inside dropdown
            if dropdownMenu.Visible then
                local menuPos = dropdownMenu.AbsolutePosition
                local menuSize = dropdownMenu.AbsoluteSize
                
                if mousePos.X >= menuPos.X and mousePos.X <= menuPos.X + menuSize.X and
                   mousePos.Y >= menuPos.Y and mousePos.Y <= menuPos.Y + menuSize.Y then
                    inDropdown = true
                end
            end
            
            if not inDropdown and Dropdown.Open then
                Dropdown:Close()
            end
        end
    end)
    
    -- Initialize
    Dropdown:SetOptions(config.Options)
    Dropdown:Set(config.Default)
    
    self.Library.Flags[idx] = Dropdown
    return Dropdown
end

return Element
end)() end,
    [13] = function()local wax,script,require=ImportGlobals(13)local ImportGlobals return (function(...)-- Enhanced Paragraph Element
local Components = script.Parent.Parent.components
local TweenService = game:GetService("TweenService")
local Tools = require(script.Parent.Parent.tools)

local Element = {}
Element.__index = Element
Element.__type = "Paragraph"

function Element:New(config)
    assert(config.Title, "Paragraph - Missing Title")
    config.Description = config.Description or ""
    config.Icon = config.Icon or nil
    config.TextSize = config.TextSize or 14
    config.Animated = config.Animated ~= false
    
    local paragraph = require(Components.element)(config.Title, config.Description, self.Container)
    
    -- Enhanced paragraph with icon support
    if config.Icon then
        local iconContainer = paragraph.topbox:FindFirstChild("Title")
        if iconContainer then
            local icon = Tools.Create("ImageLabel", {
                Image = config.Icon,
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                ThemeProps = {
                    ImageColor3 = "titlecolor",
                },
                Parent = iconContainer,
            })
            
            -- Adjust text position for icon
            local textPadding = Tools.Create("UIPadding", {
                PaddingLeft = UDim.new(0, 24),
                Parent = iconContainer,
            })
        end
    end
    
    -- Enhanced animations
    if config.Animated then
        -- Fade in animation
        local titleLabel = paragraph.topbox:FindFirstChild("Title")
        local descLabel = paragraph.Frame:FindFirstChild("Description")
        
        if titleLabel then
            titleLabel.TextTransparency = 1
            TweenService:Create(titleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                TextTransparency = 0,
            }):Play()
        end
        
        if descLabel then
            descLabel.TextTransparency = 1
            TweenService:Create(descLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                TextTransparency = 0.1,
            }):Play()
        end
    end
    
    -- Enhanced methods
    function paragraph:UpdateContent(title, description)
        self:SetTitle(title)
        self:SetDesc(description)
        
        if config.Animated then
            -- Animate content change
            local titleLabel = self.topbox:FindFirstChild("Title")
            local descLabel = self.Frame:FindFirstChild("Description")
            
            if titleLabel then
                TweenService:Create(titleLabel, TweenInfo.new(0.3), {
                    TextTransparency = 0.5,
                }):Play()
                
                task.wait(0.15)
                
                TweenService:Create(titleLabel, TweenInfo.new(0.3), {
                    TextTransparency = 0,
                }):Play()
            end
            
            if descLabel then
                TweenService:Create(descLabel, TweenInfo.new(0.3), {
                    TextTransparency = 0.5,
                }):Play()
                
                task.wait(0.15)
                
                TweenService:Create(descLabel, TweenInfo.new(0.3), {
                    TextTransparency = 0.1,
                }):Play()
            end
        end
    end
    
    function paragraph:SetIcon(iconId)
        local iconContainer = self.topbox:FindFirstChild("Title")
        if iconContainer then
            local existingIcon = iconContainer:FindFirstChild("ImageLabel")
            if existingIcon then
                existingIcon.Image = iconId
            else
                local newIcon = Tools.Create("ImageLabel", {
                    Image = iconId,
                    Size = UDim2.new(0, 16, 0, 16),
                    BackgroundTransparency = 1,
                    ThemeProps = {
                        ImageColor3 = "titlecolor",
                    },
                    Parent = iconContainer,
                })
                
                Tools.Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 24),
                    Parent = iconContainer,
                })
            end
        end
    end

    return paragraph
end

return Element
end)() end,
    [14] = function()local wax,script,require=ImportGlobals(14)local ImportGlobals return (function(...)-- Enhanced Slider Element
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local function round(number, factor)
    local result = math.floor(number / factor + 0.5) * factor
    return result
end

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(idx, config)
    assert(config.Title, "Slider - Missing Title")
    config.Description = config.Description or ""
    config.Min = config.Min or 0
    config.Max = config.Max or 100
    config.Increment = config.Increment or 1
    config.Default = config.Default or config.Min
    config.Suffix = config.Suffix or ""
    config.Callback = config.Callback or function() end
    
    local Slider = {
        Value = config.Default,
        Min = config.Min,
        Max = config.Max,
        Increment = config.Increment,
        Suffix = config.Suffix,
        Callback = config.Callback,
        Type = "Slider",
        Dragging = false,
    }
    
    local SliderFrame = require(Components.element)(config.Title, config.Description, self.Container)
    SliderFrame:SetInteractive(true)
    
    -- Enhanced value display
    local valueDisplay = Create("TextLabel", {
        Font = Enum.Font.GothamSemibold,
        Text = tostring(config.Default) .. config.Suffix,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        ThemeProps = {
            TextColor3 = "titlecolor",
        },
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 80, 0, 20),
        Parent = SliderFrame.topbox,
    })
    
    -- Enhanced slider container
    local sliderContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = SliderFrame.Frame,
    })
    
    -- Enhanced slider track
    local sliderTrack = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -12, 0, 6),
        ThemeProps = {
            BackgroundColor3 = "sliderbar",
        },
        Parent = sliderContainer,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 3),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "sliderbarstroke",
            },
            Thickness = 1,
        }),
    })
    
    -- Enhanced slider fill
    local sliderFill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        ThemeProps = {
            BackgroundColor3 = "sliderprogressbg",
        },
        Parent = sliderTrack,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 3),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "sliderprogressborder",
            },
            Thickness = 1,
        }),
    })
    
    -- Enhanced slider handle
    local sliderHandle = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        ThemeProps = {
            BackgroundColor3 = "sliderdotbg",
        },
        Parent = sliderTrack,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "sliderdotstroke",
            },
            Thickness = 2,
        }),
    })
    
    -- Enhanced slider input area
    local sliderInput = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = sliderContainer,
    })
    
    -- Enhanced update function
    local function updateSlider(value, animate)
        value = math.clamp(round(value, config.Increment), config.Min, config.Max)
        Slider.Value = value
        
        local percentage = (value - config.Min) / (config.Max - config.Min)
        local targetFillSize = UDim2.new(percentage, 0, 1, 0)
        local targetHandlePos = UDim2.new(percentage, 0, 0.5, 0)
        
        -- Update value display
        valueDisplay.Text = tostring(value) .. config.Suffix
        
        if animate and not Slider.Dragging then
            -- Smooth animation when not dragging
            TweenService:Create(sliderFill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                Size = targetFillSize,
            }):Play()
            
            TweenService:Create(sliderHandle, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                Position = targetHandlePos,
            }):Play()
        else
            -- Instant update when dragging
            sliderFill.Size = targetFillSize
            sliderHandle.Position = targetHandlePos
        end
        
        -- Call callback
        if Slider.Callback then
            Slider.Callback(value)
        end
    end
    
    -- Enhanced drag functionality
    local function updateFromMouse()
        if not Slider.Dragging then return end
        
        local mouseX = UserInputService:GetMouseLocation().X
        local trackX = sliderTrack.AbsolutePosition.X
        local trackWidth = sliderTrack.AbsoluteSize.X
        
        local percentage = math.clamp((mouseX - trackX) / trackWidth, 0, 1)
        local value = config.Min + (config.Max - config.Min) * percentage
        
        updateSlider(value, false)
    end
    
    -- Enhanced event handling
    AddConnection(sliderInput.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Slider.Dragging = true
            
            -- Handle hover effect
            TweenService:Create(sliderHandle, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 18, 0, 18),
            }):Play()
            
            updateFromMouse()
        end
    end)
    
    AddConnection(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateFromMouse()
        end
    end)
    
    AddConnection(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Slider.Dragging = false
            
            -- Remove hover effect
            TweenService:Create(sliderHandle, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 16, 0, 16),
            }):Play()
        end
    end)
    
    -- Enhanced hover effects
    AddConnection(sliderInput.MouseEnter, function()
        if not Slider.Dragging then
            TweenService:Create(sliderHandle, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 18, 0, 18),
            }):Play()
        end
    end)
    
    AddConnection(sliderInput.MouseLeave, function()
        if not Slider.Dragging then
            TweenService:Create(sliderHandle, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 16, 0, 16),
            }):Play()
        end
    end)
    
    -- Enhanced slider methods
    function Slider:Set(value)
        updateSlider(value, true)
    end
    
    function Slider:SetMin(min)
        self.Min = min
        updateSlider(self.Value, true)
    end
    
    function Slider:SetMax(max)
        self.Max = max
        updateSlider(self.Value, true)
    end
    
    function Slider:SetRange(min, max)
        self.Min = min
        self.Max = max
        updateSlider(self.Value, true)
    end
    
    -- Initialize
    updateSlider(config.Default, false)
    
    self.Library.Flags[idx] = Slider
    return Slider
end

return Element
end)() end,
    [15] = function()local wax,script,require=ImportGlobals(15)local ImportGlobals return (function(...)-- Enhanced Textbox Element
local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local Element = {}
Element.__index = Element
Element.__type = "Textbox"

function Element:New(idx, config)
    assert(config.Title, "Textbox - Missing Title")
    config.Description = config.Description or ""
    config.Placeholder = config.Placeholder or "Enter text..."
    config.Default = config.Default or ""
    config.ClearTextOnFocus = config.ClearTextOnFocus or false
    config.Multiline = config.Multiline or false
    config.CharacterLimit = config.CharacterLimit or nil
    config.Callback = config.Callback or function() end
    
    local Textbox = {
        Value = config.Default,
        Callback = config.Callback,
        Type = "Textbox",
        Focused = false,
    }
    
    local TextboxFrame = require(Components.element)(config.Title, config.Description, self.Container)
    TextboxFrame:SetInteractive(true)
    
    -- Enhanced textbox container
    local textboxContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, config.Multiline and 80 or 36),
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Parent = TextboxFrame.Frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
    })
    
    -- Enhanced textbox input
    local textboxInput = Create("TextBox", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        PlaceholderText = config.Placeholder,
        Text = config.Default,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = config.Multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        ThemeProps = {
            TextColor3 = "titlecolor",
            PlaceholderColor3 = "descriptioncolor",
        },
        ClearTextOnFocus = config.ClearTextOnFocus,
        MultiLine = config.Multiline,
        TextWrapped = config.Multiline,
        Parent = textboxContainer,
    }, {
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, config.CharacterLimit and 40 or 12),
            PaddingTop = UDim.new(0, config.Multiline and 8 or 0),
            PaddingBottom = UDim.new(0, config.Multiline and 8 or 0),
        }),
    })
    
    -- Enhanced character counter
    local characterCounter = nil
    if config.CharacterLimit then
        characterCounter = Create("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.new(0, 30, 0, 16),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "0/" .. config.CharacterLimit,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
            ThemeProps = {
                TextColor3 = "descriptioncolor",
            },
            Parent = textboxContainer,
        })
    end
    
    -- Enhanced focus indicator
    local focusIndicator = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(0, 0, 0, 2),
        ThemeProps = {
            BackgroundColor3 = "primarycolor",
        },
        Parent = textboxContainer,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 1),
        }),
    })
    
    -- Enhanced update function
    local function updateTextbox()
        local text = textboxInput.Text
        
        -- Handle character limit
        if config.CharacterLimit and #text > config.CharacterLimit then
            text = string.sub(text, 1, config.CharacterLimit)
            textboxInput.Text = text
        end
        
        -- Update character counter
        if characterCounter then
            local remaining = config.CharacterLimit - #text
            characterCounter.Text = #text .. "/" .. config.CharacterLimit
            
            -- Color based on remaining characters
            if remaining <= 5 then
                characterCounter.TextColor3 = Color3.fromRGB(255, 59, 48)
            elseif remaining <= 15 then
                characterCounter.TextColor3 = Color3.fromRGB(255, 149, 0)
            else
                characterCounter.TextColor3 = Tools.GetPropsCurrentTheme().descriptioncolor
            end
        end
        
        -- Update value
        Textbox.Value = text
        
        -- Call callback
        if Textbox.Callback then
            Textbox.Callback(text)
        end
    end
    
    -- Enhanced focus animations
    local function animateFocus(focused)
        Textbox.Focused = focused
        
        local targetStrokeColor = focused and "primarycolor" or "bordercolor"
        local targetIndicatorSize = focused and UDim2.new(1, 0, 0, 2) or UDim2.new(0, 0, 0, 2)
        
        TweenService:Create(textboxContainer.UIStroke, TweenInfo.new(0.2), {
            ThemeProps = { Color = targetStrokeColor }
        }):Play()
        
        TweenService:Create(focusIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = targetIndicatorSize,
        }):Play()
    end
    
    -- Enhanced event handling
    AddConnection(textboxInput.Focused, function()
        animateFocus(true)
    end)
    
    AddConnection(textboxInput.FocusLost, function(enterPressed)
        animateFocus(false)
        updateTextbox()
    end)
    
    AddConnection(textboxInput:GetPropertyChangedSignal("Text"), function()
        updateTextbox()
    end)
    
    -- Enhanced hover effects
    AddConnection(textboxContainer.MouseEnter, function()
        if not Textbox.Focused then
            TweenService:Create(textboxContainer.UIStroke, TweenInfo.new(0.2), {
                Thickness = 2,
            }):Play()
        end
    end)
    
    AddConnection(textboxContainer.MouseLeave, function()
        if not Textbox.Focused then
            TweenService:Create(textboxContainer.UIStroke, TweenInfo.new(0.2), {
                Thickness = 1,
            }):Play()
        end
    end)
    
    -- Enhanced textbox methods
    function Textbox:Set(text)
        textboxInput.Text = text
        updateTextbox()
    end
    
    function Textbox:Clear()
        textboxInput.Text = ""
        updateTextbox()
    end
    
    function Textbox:Focus()
        textboxInput:CaptureFocus()
    end
    
    function Textbox:Blur()
        textboxInput:ReleaseFocus()
    end
    
    function Textbox:SetPlaceholder(placeholder)
        textboxInput.PlaceholderText = placeholder
    end
    
    -- Initialize
    updateTextbox()
    
    self.Library.Flags[idx] = Textbox
    return Textbox
end

return Element
end)() end,
    [16] = function()local wax,script,require=ImportGlobals(16)local ImportGlobals return (function(...)-- Enhanced Toggle Element
local TweenService = game:GetService("TweenService")
local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local Element = {}
Element.__index = Element
Element.__type = "Toggle"

function Element:New(idx, config)
    assert(config.Title, "Toggle - Missing Title")
    config.Description = config.Description or ""
    config.Default = config.Default or false
    config.Icon = config.Icon or nil
    config.Risky = config.Risky or false
    config.Callback = config.Callback or function() end
    
    local Toggle = {
        Value = config.Default,
        Callback = config.Callback,
        Type = "Toggle",
        Risky = config.Risky,
    }
    
    local ToggleFrame = require(Components.element)("      " .. config.Title, config.Description, self.Container)
    ToggleFrame:SetInteractive(true)
    
    -- Enhanced toggle container
    local toggleContainer = Create("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = ToggleFrame.topbox,
    })
    
    -- Enhanced toggle background
    local toggleBackground = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        ThemeProps = {
            BackgroundColor3 = "togglebg",
        },
        BackgroundTransparency = config.Default and 0 or 1,
        Parent = toggleContainer,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = config.Risky and "error" or "toggleborder",
            },
            Thickness = 1,
        }),
    })
    
    -- Enhanced toggle icon
    local toggleIcon = Create("ImageLabel", {
        Image = config.Icon or "rbxassetid://6031094667",
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ThemeProps = {
            ImageColor3 = "maincolor",
        },
        ImageTransparency = config.Default and 0 or 1,
        Parent = toggleBackground,
    })
    
    -- Enhanced toggle button
    local toggleButton = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = toggleContainer,
    })
    
    -- Enhanced ripple effect
    local rippleFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = toggleContainer,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
    })
    
    -- Enhanced animation system
    local function updateToggle(value, animate)
        Toggle.Value = value
        
        local tweenInfo = TweenInfo.new(animate and 0.25 or 0, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        -- Background animation
        TweenService:Create(toggleBackground, tweenInfo, {
            BackgroundTransparency = value and 0 or 1,
        }):Play()
        
        -- Icon animation
        TweenService:Create(toggleIcon, tweenInfo, {
            ImageTransparency = value and 0 or 1,
        }):Play()
        
        -- Scale animation for feedback
        if animate then
            local scaleTween = TweenService:Create(toggleContainer, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 18, 0, 18),
            })
            scaleTween:Play()
            
            scaleTween.Completed:Connect(function()
                TweenService:Create(toggleContainer, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 20, 0, 20),
                }):Play()
            end)
        end
        
        -- Ripple effect
        if animate then
            local ripple = Create("Frame", {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Tools.GetPropsCurrentTheme().primarycolor,
                BackgroundTransparency = 0.7,
                Parent = rippleFrame,
            }, {
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            })
            
            local rippleTween = TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 40, 0, 40),
                BackgroundTransparency = 1,
            })
            rippleTween:Play()
            
            rippleTween.Completed:Connect(function()
                ripple:Destroy()
            end)
        end
        
        -- Call callback
        if Toggle.Callback then
            Toggle.Callback(value)
        end
    end
    
    -- Enhanced hover effects
    AddConnection(toggleButton.MouseEnter, function()
        TweenService:Create(toggleContainer, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 22, 0, 22),
        }):Play()
        
        TweenService:Create(toggleBackground.UIStroke, TweenInfo.new(0.2), {
            Thickness = 2,
        }):Play()
    end)
    
    AddConnection(toggleButton.MouseLeave, function()
        TweenService:Create(toggleContainer, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 20, 0, 20),
        }):Play()
        
        TweenService:Create(toggleBackground.UIStroke, TweenInfo.new(0.2), {
            Thickness = 1,
        }):Play()
    end)
    
    -- Enhanced click handling
    AddConnection(toggleButton.MouseButton1Click, function()
        updateToggle(not Toggle.Value, true)
    end)
    
    -- Enhanced toggle methods
    function Toggle:Set(value)
        updateToggle(value, false)
    end
    
    function Toggle:Get()
        return self.Value
    end
    
    function Toggle:SetIcon(iconId)
        toggleIcon.Image = iconId
    end
    
    function Toggle:SetRisky(risky)
        self.Risky = risky
        toggleBackground.UIStroke.Color = risky and Color3.fromRGB(255, 59, 48) or Tools.GetPropsCurrentTheme().toggleborder
    end
    
    -- Initialize
    updateToggle(config.Default, false)
    
    self.Library.Flags[idx] = Toggle
    return Toggle
end

return Element
end)() end,
    [17] = function()local wax,script,require=ImportGlobals(17)local ImportGlobals return (function(...)-- Enhanced Tools Module
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local tools = {
    Signals = {},
    ThemeObjects = {},
    CurrentTheme = "default",
}

-- Enhanced theme system with local themes
local themes = {
    default = {
        maincolor = Color3.fromRGB(9, 9, 9),
        bordercolor = Color3.fromRGB(39, 39, 42),
        scrollocolor = Color3.fromRGB(28, 28, 30),
        titlecolor = Color3.fromRGB(245, 245, 245),
        descriptioncolor = Color3.fromRGB(168, 168, 168),
        elementdescription = Color3.fromRGB(168, 168, 168),
        primarycolor = Color3.fromRGB(78, 34, 197),
        offTextBtn = Color3.fromRGB(63, 63, 63),
        offBgLineBtn = Color3.fromRGB(29, 29, 29),
        onTextBtn = Color3.fromRGB(129, 83, 255),
        onBgLineBtn = Color3.fromRGB(129, 83, 255),
        toggleborder = Color3.fromRGB(135, 80, 236),
        togglebg = Color3.fromRGB(98, 0, 255),
        sliderbar = Color3.fromRGB(21,21,21),
        sliderbarstroke = Color3.fromRGB(29, 29, 29),
        sliderprogressbg = Color3.fromRGB(41, 11, 123),
        sliderprogressborder = Color3.fromRGB(59, 6, 184),
        sliderdotbg = Color3.fromRGB(120, 16, 206),
        sliderdotstroke = Color3.fromRGB(9, 9, 9),
        containeritemsbg = Color3.fromRGB(28, 25, 23),
        itembg = Color3.fromRGB(39, 39, 42),
        itemcheckmarkcolor = Color3.fromRGB(154, 154, 154),
        itemTextOn = Color3.fromHex("#e9e9e9"),
        itemTextOff = Color3.fromHex("#9a9a9a"),
        valuetext = Color3.fromRGB(255, 255, 255),
        valuebg = Color3.fromRGB(39, 39, 42),
    },
    dark = {
        maincolor = Color3.fromRGB(15, 15, 15),
        bordercolor = Color3.fromRGB(45, 45, 48),
        scrollocolor = Color3.fromRGB(35, 35, 38),
        titlecolor = Color3.fromRGB(255, 255, 255),
        descriptioncolor = Color3.fromRGB(180, 180, 180),
        elementdescription = Color3.fromRGB(180, 180, 180),
        primarycolor = Color3.fromRGB(0, 122, 255),
        offTextBtn = Color3.fromRGB(70, 70, 70),
        offBgLineBtn = Color3.fromRGB(35, 35, 35),
        onTextBtn = Color3.fromRGB(0, 122, 255),
        onBgLineBtn = Color3.fromRGB(0, 122, 255),
        toggleborder = Color3.fromRGB(0, 122, 255),
        togglebg = Color3.fromRGB(0, 122, 255),
        sliderbar = Color3.fromRGB(25,25,25),
        sliderbarstroke = Color3.fromRGB(35, 35, 35),
        sliderprogressbg = Color3.fromRGB(0, 122, 255),
        sliderprogressborder = Color3.fromRGB(0, 100, 200),
        sliderdotbg = Color3.fromRGB(0, 122, 255),
        sliderdotstroke = Color3.fromRGB(15, 15, 15),
        containeritemsbg = Color3.fromRGB(25, 25, 25),
        itembg = Color3.fromRGB(45, 45, 48),
        itemcheckmarkcolor = Color3.fromRGB(180, 180, 180),
        itemTextOn = Color3.fromHex("#ffffff"),
        itemTextOff = Color3.fromHex("#b4b4b4"),
        valuetext = Color3.fromRGB(255, 255, 255),
        valuebg = Color3.fromRGB(45, 45, 48),
    },
    light = {
        maincolor = Color3.fromRGB(255, 255, 255),
        bordercolor = Color3.fromRGB(200, 200, 200),
        scrollocolor = Color3.fromRGB(220, 220, 220),
        titlecolor = Color3.fromRGB(0, 0, 0),
        descriptioncolor = Color3.fromRGB(100, 100, 100),
        elementdescription = Color3.fromRGB(100, 100, 100),
        primarycolor = Color3.fromRGB(0, 122, 255),
        offTextBtn = Color3.fromRGB(120, 120, 120),
        offBgLineBtn = Color3.fromRGB(200, 200, 200),
        onTextBtn = Color3.fromRGB(0, 122, 255),
        onBgLineBtn = Color3.fromRGB(0, 122, 255),
        toggleborder = Color3.fromRGB(0, 122, 255),
        togglebg = Color3.fromRGB(0, 122, 255),
        sliderbar = Color3.fromRGB(240, 240, 240),
        sliderbarstroke = Color3.fromRGB(200, 200, 200),
        sliderprogressbg = Color3.fromRGB(0, 122, 255),
        sliderprogressborder = Color3.fromRGB(0, 100, 200),
        sliderdotbg = Color3.fromRGB(0, 122, 255),
        sliderdotstroke = Color3.fromRGB(255, 255, 255),
        containeritemsbg = Color3.fromRGB(250, 250, 250),
        itembg = Color3.fromRGB(240, 240, 240),
        itemcheckmarkcolor = Color3.fromRGB(100, 100, 100),
        itemTextOn = Color3.fromHex("#000000"),
        itemTextOff = Color3.fromHex("#666666"),
        valuetext = Color3.fromRGB(0, 0, 0),
        valuebg = Color3.fromRGB(240, 240, 240),
    }
}

local currentTheme = themes.default

-- Enhanced theme management
function tools.SetTheme(themeName)
    if themes[themeName] then
        currentTheme = themes[themeName]
        tools.CurrentTheme = themeName
        
        -- Update all themed objects
        for _, themeObject in pairs(tools.ThemeObjects) do
            if themeObject.object and themeObject.object.Parent then
                for propertyName, themeKey in pairs(themeObject.props) do
                    if currentTheme[themeKey] then
                        themeObject.object[propertyName] = currentTheme[themeKey]
                    end
                end
            end
        end
        
        return true
    else
        warn("Theme not found: " .. themeName)
        return false
    end
end

function tools.GetPropsCurrentTheme()
    return currentTheme
end

function tools.AddTheme(themeName, themeProps)
    if type(themeName) == "string" and type(themeProps) == "table" then
        themes[themeName] = themeProps
        return true
    end
    return false
end

function tools.GetAvailableThemes()
    local themeNames = {}
    for name, _ in pairs(themes) do
        table.insert(themeNames, name)
    end
    return themeNames
end

-- Enhanced mobile detection
function tools.isMobile()
    local touchEnabled = UserInputService.TouchEnabled
    local keyboardEnabled = UserInputService.KeyboardEnabled
    local mouseEnabled = UserInputService.MouseEnabled
    
    return touchEnabled and not keyboardEnabled and not mouseEnabled
end

-- Enhanced connection management
function tools.AddConnection(signal, callback)
    if not signal or not callback then
        warn("AddConnection: Invalid signal or callback")
        return nil
    end
    
    local success, connection = pcall(function()
        return signal:Connect(callback)
    end)
    
    if success and connection then
        table.insert(tools.Signals, connection)
        return connection
    else
        warn("AddConnection: Failed to create connection")
        return nil
    end
end

function tools.Disconnect()
    for i = #tools.Signals, 1, -1 do
        local connection = tools.Signals[i]
        if connection and connection.Connected then
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.remove(tools.Signals, i)
    end
end

-- Enhanced create function with better theme support
function tools.Create(className, properties, children)
    local success, object = pcall(function()
        return Instance.new(className)
    end)
    
    if not success then
        warn("Create: Failed to create " .. className)
        return nil
    end
    
    -- Handle theme properties
    if properties and properties.ThemeProps then
        local themeProps = properties.ThemeProps
        properties.ThemeProps = nil
        
        -- Store theme object for future updates
        table.insert(tools.ThemeObjects, {
            object = object,
            props = themeProps,
        })
        
        -- Apply current theme
        for propertyName, themeKey in pairs(themeProps) do
            if currentTheme[themeKey] then
                object[propertyName] = currentTheme[themeKey]
            end
        end
    end
    
    -- Apply regular properties
    for propertyName, value in pairs(properties or {}) do
        local success, error = pcall(function()
            object[propertyName] = value
        end)
        
        if not success then
            warn("Create: Failed to set " .. propertyName .. " - " .. error)
        end
    end
    
    -- Apply children
    for _, child in pairs(children or {}) do
        if typeof(child) == "Instance" then
            child.Parent = object
        end
    end
    
    return object
end

-- Enhanced scroll animation
function tools.AddScrollAnim(scrollFrame)
    if not scrollFrame then
        warn("AddScrollAnim: Invalid scroll frame")
        return
    end
    
    local showTween = TweenService:Create(scrollFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        ScrollBarImageTransparency = 0.3,
    })
    
    local hideTween = TweenService:Create(scrollFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        ScrollBarImageTransparency = 1,
    })
    
    local lastActivity = tick()
    local hideDelay = 1.5
    
    local function showScrollbar()
        lastActivity = tick()
        showTween:Play()
    end
    
    local function hideScrollbar()
        if tick() - lastActivity >= hideDelay then
            hideTween:Play()
        end
    end
    
    -- Enhanced event handling
    tools.AddConnection(scrollFrame.MouseEnter, showScrollbar)
    tools.AddConnection(scrollFrame.MouseLeave, function()
        task.wait(hideDelay)
        hideScrollbar()
    end)
    
    tools.AddConnection(scrollFrame:GetPropertyChangedSignal("CanvasPosition"), showScrollbar)
    tools.AddConnection(scrollFrame.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            showScrollbar()
        end
    end)
    
    -- Background hide check
    tools.AddConnection(RunService.Heartbeat, function()
        if tick() - lastActivity >= hideDelay then
            hideScrollbar()
        end
    end)
end

-- Enhanced utility functions
function tools.GetScreenSize()
    return workspace.CurrentCamera.ViewportSize
end

function tools.IsInViewport(object)
    if not object or not object.Parent then
        return false
    end
    
    local camera = workspace.CurrentCamera
    local viewportSize = camera.ViewportSize
    local objectPos = object.AbsolutePosition
    local objectSize = object.AbsoluteSize
    
    return objectPos.X >= 0 and objectPos.Y >= 0 and
           objectPos.X + objectSize.X <= viewportSize.X and
           objectPos.Y + objectSize.Y <= viewportSize.Y
end

-- Enhanced interpolation functions
function tools.Lerp(start, finish, alpha)
    return start + (finish - start) * alpha
end

function tools.LerpColor3(start, finish, alpha)
    return Color3.new(
        tools.Lerp(start.R, finish.R, alpha),
        tools.Lerp(start.G, finish.G, alpha),
        tools.Lerp(start.B, finish.B, alpha)
    )
end

-- Enhanced easing functions
function tools.EaseInOut(t)
    return t * t * (3 - 2 * t)
end

function tools.EaseOutBack(t)
    local c1 = 1.70158
    local c3 = c1 + 1
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
end

-- Enhanced safe call function
function tools.SafeCall(func, ...)
    if type(func) ~= "function" then
        warn("SafeCall: Not a function")
        return false, "Not a function"
    end
    
    local success, result = pcall(func, ...)
    if not success then
        warn("SafeCall error: " .. tostring(result))
    end
    return success, result
end

-- Enhanced debounce function
function tools.Debounce(func, delay)
    local lastCall = 0
    return function(...)
        local now = tick()
        if now - lastCall >= delay then
            lastCall = now
            return func(...)
        end
    end
end

-- Enhanced performance monitoring
function tools.GetPerformanceStats()
    local stats = game:GetService("Stats")
    return {
        FPS = math.floor(workspace:GetRealPhysicsFPS()),
        Memory = math.floor(stats:GetTotalMemoryUsageMb()),
        Ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue()),
    }
end

-- Enhanced cleanup function
function tools.Cleanup()
    tools.Disconnect()
    
    -- Clear theme objects
    for i = #tools.ThemeObjects, 1, -1 do
        tools.ThemeObjects[i] = nil
    end
    
    -- Clear signals
    for i = #tools.Signals, 1, -1 do
        tools.Signals[i] = nil
    end
end

-- Enhanced initialization
function tools.Initialize()
    -- Set up global error handling
    local function handleError(message)
        warn("Tools Error: " .. tostring(message))
    end
    
    -- Initialize with default theme
    tools.SetTheme("default")
    
    -- Set up cleanup on game close
    game:BindToClose(function()
        tools.Cleanup()
    end)
end

-- Auto-initialize
tools.Initialize()

return tools
end)() end
}

-- Create object tree structure
local ObjectTree = {
    {
        1, 2, { "MainModule" },
        {
            {
                2, 1, { "components" },
                {
                    { 6, 2, { "section" } },
                    { 3, 2, { "dialog" } },
                    { 5, 2, { "notif" } },
                    { 4, 2, { "element" } },
                    { 7, 2, { "tab" } }
                }
            },
            {
                8, 2, { "elements" },
                {
                    { 12, 2, { "dropdown" } },
                    { 10, 2, { "buttons" } },
                    { 16, 2, { "toggle" } },
                    { 11, 2, { "colorpicker" } },
                    { 9, 2, { "bind" } },
                    { 14, 2, { "slider" } },
                    { 13, 2, { "paragraph" } },
                    { 15, 2, { "textbox" } }
                }
            },
            { 17, 2, { "tools" } }
        }
    }
}

-- Class name bindings
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
}

-- Enhanced reference system
local RefBindings = {}
local ScriptClosures = {}
local StoredModuleValues = {}

-- Enhanced GUI creation
local function getGUIParent()
    local success, result = pcall(function()
        return gethui()
    end)
    return success and result or game:GetService("CoreGui")
end

-- Enhanced module loader
local function LoadScript(scriptRef)
    local StoredValue = StoredModuleValues[scriptRef]
    if StoredValue then
        return unpack(StoredValue)
    end
    
    local Closure = ScriptClosures[scriptRef]
    if not Closure then
        error("No closure found for script: " .. scriptRef.Name)
    end
    
    local Success, Result = pcall(Closure)
    if not Success then
        error("Script execution failed: " .. tostring(Result))
    end
    
    StoredModuleValues[scriptRef] = { Result }
    return Result
end

-- Enhanced globals system
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]
    
    local Global_wax = {
        version = "2.1.0",
        envname = "Enhanced_WaxRuntime",
        shared = {},
    }
    
    local Global_script = ScriptRef
    local Global_require = require
    
    return Global_wax, Global_script, Global_require
end

-- Enhanced reference creation
local function CreateRef(className, name, parent)
    local Ref = {
        ClassName = className,
        Name = name,
        Parent = parent,
    }
    
    local Children = {}
    
    function Ref:GetChildren()
        local result = {}
        for child in pairs(Children) do
            table.insert(result, child)
        end
        return result
    end
    
    function Ref:FindFirstChild(name)
        for child in pairs(Children) do
            if child.Name == name then
                return child
            end
        end
        return nil
    end
    
    -- Add to parent's children
    if parent then
        local parentChildren = getmetatable(parent).__children
        if parentChildren then
            parentChildren[Ref] = true
        end
    end
    
    -- Store children reference
    setmetatable(Ref, {
        __children = Children,
        __index = function(self, key)
            return rawget(self, key) or self:FindFirstChild(key)
        end,
    })
    
    return Ref
end

-- Enhanced object tree creation
local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3]
    local Children = object[4]
    
    local ClassName = ClassNameIdBindings[ClassNameId]
    local Name = Properties and Properties[1] or ClassName
    
    local Ref = CreateRef(ClassName, Name, parent)
    RefBindings[RefId] = Ref
    
    -- Apply properties
    if Properties then
        for i = 2, #Properties do
            local prop = Properties[i]
            if type(prop) == "table" then
                for key, value in pairs(prop) do
                    Ref[key] = value
                end
            end
        end
    end
    
    -- Create children
    if Children then
        for _, childObject in pairs(Children) do
            CreateRefFromObject(childObject, Ref)
        end
    end
    
    return Ref
end

-- Create root and object tree
local RootRef = CreateRef("Folder", "Enhanced_Library_Root")
for _, object in pairs(ObjectTree) do
    CreateRefFromObject(object, RootRef)
end

-- Bind closures to script references
for RefId, Closure in pairs(ClosureBindings) do
    local Ref = RefBindings[RefId]
    if Ref then
        ScriptClosures[Ref] = Closure
    end
end

-- Load and return the main module
local MainModule = RootRef:FindFirstChild("MainModule")
if MainModule then
    return LoadScript(MainModule)
else
    error("Main module not found")
end
