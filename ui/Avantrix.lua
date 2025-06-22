-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    function()local wax,script,require=ImportGlobals(1)local ImportGlobals return (function(...)wait(1)

-- Enhanced random string generator with better entropy
function generateRandomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:',.<>?/`~"
    local randomString = ""
    
    -- Better seed using multiple sources
    local seed = os.time() + (tick() * 1000) % 1000000
    math.randomseed(seed)

    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        randomString = randomString .. charset:sub(randomIndex, randomIndex)
    end

    return randomString
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ElementsTable = require(script.elements)
local Tools = require(script.tools)
local Components = script.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local AddScrollAnim = Tools.AddScrollAnim
local isMobile = Tools.isMobile()
local CurrentThemeProps = Tools.GetPropsCurrentTheme()

-- Enhanced draggable function with better mobile support
local function MakeDraggable(DragPoint, Main)
    local Dragging, DragInput, MousePos, FramePos = false
    local lastInputTime = 0
    local dragThreshold = 5 -- Minimum distance to start dragging
    local startPos
    
    AddConnection(DragPoint.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false -- Don't start dragging immediately
            MousePos = Input.Position
            startPos = Input.Position
            FramePos = Main.Position
            lastInputTime = tick()

            AddConnection(Input.Changed, function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
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
        if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            if MousePos and FramePos then
                local currentPos = Input.Position
                local distance = (currentPos - startPos).Magnitude
                
                -- Only start dragging if we've moved far enough
                if distance > dragThreshold then
                    Dragging = true
                end
                
                if Dragging then
                    local Delta = currentPos - MousePos
                    Main.Position = UDim2.new(
                        FramePos.X.Scale, 
                        FramePos.X.Offset + Delta.X, 
                        FramePos.Y.Scale, 
                        FramePos.Y.Offset + Delta.Y
                    )
                end
            end
        end
    end)
end

local Library = {
    Window = nil,
    Flags = {},
    Signals = {},
    ToggleBind = nil,
    _initialized = false,
    _destroyed = false,
}

-- Enhanced GUI creation with better error handling
local function createGUI()
    local success, gui = pcall(function()
        return Create("ScreenGui", {
            Name = generateRandomString(16),
            Parent = gethui(),
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 100, -- Ensure it's on top
        })
    end)
    
    if not success then
        warn("Failed to create GUI: " .. tostring(gui))
        return nil
    end
    
    return gui
end

local GUI = createGUI()
if not GUI then
    error("Failed to initialize GUI")
end

-- Initialize notification system with error handling
local notifSuccess, notifError = pcall(function()
    require(Components.notif):Init(GUI)
end)

if not notifSuccess then
    warn("Failed to initialize notifications: " .. tostring(notifError))
end

-- Enhanced theme functions with validation
function Library:SetTheme(themeName)
    if type(themeName) ~= "string" then
        warn("SetTheme expects a string, got " .. type(themeName))
        return false
    end
    
    local success, error = pcall(function()
        Tools.SetTheme(themeName)
    end)
    
    if not success then
        warn("Failed to set theme '" .. themeName .. "': " .. tostring(error))
        return false
    end
    
    return true
end

function Library:GetTheme()
    return Tools.GetPropsCurrentTheme()
end

function Library:AddTheme(themeName, themeProps)
    if type(themeName) ~= "string" then
        warn("AddTheme expects themeName to be a string")
        return false
    end
    
    if type(themeProps) ~= "table" then
        warn("AddTheme expects themeProps to be a table")
        return false
    end
    
    local success, error = pcall(function()
        Tools.AddTheme(themeName, themeProps)
    end)
    
    if not success then
        warn("Failed to add theme '" .. themeName .. "': " .. tostring(error))
        return false
    end
    
    return true
end

function Library:IsRunning()
    return GUI and GUI.Parent == gethui() and not self._destroyed
end

-- Enhanced cleanup system
function Library:Destroy()
    if self._destroyed then
        return
    end
    
    self._destroyed = true
    
    -- Disconnect all connections
    for i, Connection in pairs(Tools.Signals) do
        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end
    
    -- Clear flags
    for k, v in pairs(self.Flags) do
        self.Flags[k] = nil
    end
    
    -- Destroy GUI
    if GUI then
        GUI:Destroy()
    end
    
    -- Clear references
    self.Window = nil
    self.Signals = {}
end

-- Background cleanup task with better error handling
task.spawn(function()
    while Library:IsRunning() do
        task.wait(1) -- Check less frequently
    end
    
    -- Cleanup when library is no longer running
    pcall(function()
        for i, Connection in pairs(Tools.Signals) do
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end
    end)
end)

local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
    return Elements[Key](...)
end

-- Enhanced element loading with error handling
for _, ElementComponent in ipairs(ElementsTable) do
    if not ElementComponent.__type then
        warn("ElementComponent missing __type")
        continue
    end
    
    if type(ElementComponent.New) ~= "function" then
        warn("ElementComponent missing New function for type: " .. tostring(ElementComponent.__type))
        continue
    end

    Elements["Add" .. ElementComponent.__type] = function(self, Idx, Config)
        if not self.Container then
            warn("Container not found for element: " .. ElementComponent.__type)
            return nil
        end
        
        ElementComponent.Container = self.Container
        ElementComponent.Type = self.Type
        ElementComponent.ScrollFrame = self.ScrollFrame
        ElementComponent.Library = Library

        local success, result = pcall(function()
            return ElementComponent:New(Idx, Config)
        end)
        
        if not success then
            warn("Failed to create element " .. ElementComponent.__type .. ": " .. tostring(result))
            return nil
        end
        
        return result
    end
end

Library.Elements = Elements

-- Enhanced callback system with better error handling
function Library:Callback(Callback, ...)
    if type(Callback) ~= "function" then
        warn("Callback is not a function, got: " .. type(Callback))
        return nil
    end
    
    local success, result = pcall(Callback, ...)

    if success then
        return result
    else
        local errorMessage = tostring(result)
        local errorLine = string.match(errorMessage, ":(%d+):")
        local errorInfo = "Callback execution failed.\n"
        errorInfo = errorInfo .. "Error: " .. errorMessage .. "\n"

        if errorLine then
            errorInfo = errorInfo .. "Occurred on line: " .. errorLine .. "\n"
        end

        errorInfo = errorInfo .. "Possible Fix: Please check the function implementation for potential issues such as invalid arguments or logic errors at the indicated line number."
        warn(errorInfo)
        return nil
    end
end

-- Enhanced notification system
function Library:Notification(titleText, descriptionText, duration)
    if not titleText or type(titleText) ~= "string" then
        warn("Notification title must be a string")
        return false
    end
    
    descriptionText = descriptionText or ""
    duration = duration or 5
    
    if type(duration) ~= "number" or duration <= 0 then
        duration = 5
    end
    
    local success, error = pcall(function()
        require(Components.notif):ShowNotification(titleText, descriptionText, duration)
    end)
    
    if not success then
        warn("Failed to show notification: " .. tostring(error))
        return false
    end
    
    return true
end

-- Enhanced dialog system
function Library:Dialog(config)
    if type(config) ~= "table" then
        warn("Dialog config must be a table")
        return nil
    end
    
    if not self.LoadedWindow then
        warn("No window loaded for dialog")
        return nil
    end
    
    local success, result = pcall(function()
        return require(Components.dialog):Create(config, self.LoadedWindow)
    end)
    
    if not success then
        warn("Failed to create dialog: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Enhanced window loading with comprehensive validation
function Library:Load(cfgs)
    if self._destroyed then
        warn("Cannot load window on destroyed library")
        return nil
    end
    
    if self.Window then
        warn("Cannot create more than one window.")
        if GUI then
            GUI:Destroy()
        end
        return nil
    end
    
    -- Enhanced config validation
    cfgs = cfgs or {}
    cfgs.Title = tostring(cfgs.Title or "Window")
    cfgs.ToggleButton = tostring(cfgs.ToggleButton or "")
    cfgs.BindGui = cfgs.BindGui or Enum.KeyCode.RightControl
    
    -- Validate BindGui
    if typeof(cfgs.BindGui) ~= "EnumItem" then
        warn("BindGui must be a KeyCode enum, defaulting to RightControl")
        cfgs.BindGui = Enum.KeyCode.RightControl
    end
    
    Library.Window = GUI
    self._initialized = true

    -- Enhanced canvas group creation with better mobile support
    local canvas_group = Create("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Position = UDim2.new(0.5, 0, 0.3, 0),
        Size = isMobile and UDim2.new(0.9, 0, 0.85, 0) or UDim2.new(0, 650, 0, 400),
        Parent = GUI,
        Visible = false,
        ClipsDescendants = true,
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

    -- Enhanced toggle button with better positioning
    local togglebtn = Create("ImageButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        AutoButtonColor = false,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Position = UDim2.new(0.5, 8, 0, 0),
        Size = UDim2.new(0, 45, 0, 45),
        Parent = GUI,
        Image = cfgs.ToggleButton,
        ImageTransparency = cfgs.ToggleButton == "" and 1 or 0,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
    })

    -- Enhanced toggle visibility function with better animations
    local function ToggleVisibility()
        local isVisible = canvas_group.Visible
        local endPosition = isVisible and UDim2.new(0.5, 0, -1, 0) or UDim2.new(0.5, 0, 0.5, 0)
        
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
        local positionTween = TweenService:Create(canvas_group, tweenInfo, { Position = endPosition })
        
        canvas_group.Visible = true
        togglebtn.Visible = false
        
        positionTween:Play()
        
        positionTween.Completed:Connect(function()
            if isVisible then
                canvas_group.Visible = false
                togglebtn.Visible = true
            end
        end)
    end

    -- Initial setup
    ToggleVisibility()

    -- Enhanced dragging with mobile support
    if not isMobile then
        MakeDraggable(togglebtn, togglebtn)
    end
    
    AddConnection(togglebtn.MouseButton1Click, ToggleVisibility)
    AddConnection(UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == cfgs.BindGui then
            ToggleVisibility()
        end
    end)

    -- Enhanced top frame with better styling
    local top_frame = Create("Frame", {
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        BorderColor3 = Color3.fromRGB(39, 39, 42),
        Size = UDim2.new(1, 0, 0, 40),
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
    })

    -- Enhanced title with text scaling
    local title = Create("TextLabel", {
        Font = Enum.Font.GothamMedium,
        RichText = true,
        Text = cfgs.Title,
        ThemeProps = {
            TextColor3 = "titlecolor",
            BackgroundColor3 = "maincolor",
        },
        BorderSizePixel = 0,
        TextSize = isMobile and 14 or 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextScaled = isMobile,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0, 200, 0, 40),
        ZIndex = 10,
        Parent = top_frame,
    })

    -- Enhanced minimize button
    local minimizebtn = Create("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -36, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 10,
        Parent = top_frame,
    }, {
        Create("ImageLabel", {
            Image = "rbxassetid://15269257100",
            ImageRectOffset = Vector2.new(514, 257),
            ImageRectSize = Vector2.new(256, 256),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -10, 1, -10),
            ThemeProps = {
                ImageColor3 = "titlecolor",
            },
            BorderSizePixel = 0,
            ZIndex = 11,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })

    -- Enhanced close button
    local closebtn = Create("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = 10,
        Parent = top_frame,
    }, {
        Create("ImageLabel", {
            Image = "rbxassetid://15269329696",
            ImageRectOffset = Vector2.new(0, 514),
            ImageRectSize = Vector2.new(256, 256),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -10, 1, -10),
            ThemeProps = {
                ImageColor3 = "titlecolor",
            },
            BorderSizePixel = 0,
            ZIndex = 11,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })

    -- Enhanced button connections with hover effects
    local function addHoverEffect(button)
        AddConnection(button.MouseEnter, function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.9
            }):Play()
        end)
        
        AddConnection(button.MouseLeave, function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
        end)
    end
    
    addHoverEffect(minimizebtn)
    addHoverEffect(closebtn)

    AddConnection(minimizebtn.MouseButton1Click, ToggleVisibility)
    AddConnection(closebtn.MouseButton1Click, function()
        Library:Destroy()
    end)

    -- Enhanced tab frame with better mobile support
    local tab_frame = Create("Frame", {
        BackgroundTransparency = 1,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = isMobile and UDim2.new(0, 120, 1, -40) or UDim2.new(0, 140, 1, -40),
        Parent = canvas_group,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
    })

    -- Enhanced tab holder with better scrolling
    local TabHolder = Create("ScrollingFrame", {
        ThemeProps = {
            ScrollBarImageColor3 = "scrollcolor",
            BackgroundColor3 = "maincolor",
        },
        ScrollBarThickness = isMobile and 4 or 2,
        ScrollBarImageTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = tab_frame,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 0),
        }),
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        }),
    })

    -- Enhanced canvas size updating
    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 28)
    end)

    AddScrollAnim(TabHolder)

    local containerFolder = Create("Folder", {
        Parent = canvas_group,
    })

    -- Enhanced dragging for top frame
    if not isMobile then
        MakeDraggable(top_frame, canvas_group)
    end

    Library.LoadedWindow = canvas_group

    local Tabs = {}

    -- Enhanced tab module initialization
    local TabModule = require(Components.tab):Init(containerFolder)
    
    function Tabs:AddTab(title)
        if type(title) ~= "string" or title == "" then
            warn("Tab title must be a non-empty string")
            return nil
        end
        
        local success, result = pcall(function()
            return TabModule:New(title, TabHolder)
        end)
        
        if not success then
            warn("Failed to create tab '" .. title .. "': " .. tostring(result))
            return nil
        end
        
        return result
    end
    
    function Tabs:SelectTab(Tab)
        Tab = Tab or 1
        
        local success, error = pcall(function()
            TabModule:SelectTab(Tab)
        end)
        
        if not success then
            warn("Failed to select tab: " .. tostring(error))
        end
    end

    return Tabs
end

return Library

end)() end,
    [3] = function()local wax,script,require=ImportGlobals(3)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local ButtonComponent = require(script.Parent.Parent.elements.buttons)

local Create = Tools.Create

local DialogModule = {}
local ActiveDialog = nil

function DialogModule:Create(config, parent)
    -- Enhanced validation
    if type(config) ~= "table" then
        warn("Dialog config must be a table")
        return nil
    end
    
    if not parent then
        warn("Dialog parent is required")
        return nil
    end
    
    -- Set defaults
    config.Title = config.Title or "Dialog"
    config.Content = config.Content or ""
    config.Buttons = config.Buttons or {{Title = "OK", Callback = function() end}}
    
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
    scrolling_frame.BackgroundTransparency = 0.1
    scrolling_frame.BorderColor3 = Color3.new(0, 0, 0)
    scrolling_frame.BorderSizePixel = 0
    scrolling_frame.Size = UDim2.new(1, 0, 1, 0)
    scrolling_frame.Visible = true
    scrolling_frame.ZIndex = 100
    scrolling_frame.Parent = parent

    -- Enhanced blocker with better event handling
    local blocker = Instance.new("TextButton")
    blocker.Size = UDim2.new(1, 0, 1, 0)
    blocker.Position = UDim2.new(0, 0, 0, 0)
    blocker.BackgroundTransparency = 1
    blocker.Text = ""
    blocker.AutoButtonColor = false
    blocker.Modal = true -- Prevent clicks from passing through
    blocker.Parent = scrolling_frame

    local uipadding_3 = Instance.new("UIPadding")
    uipadding_3.PaddingBottom = UDim.new(0, 45)
    uipadding_3.PaddingTop = UDim.new(0, 45)
    uipadding_3.Parent = scrolling_frame

    local dialog = Create("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0, math.min(400, parent.AbsoluteSize.X * 0.9), 0, 0),
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

    -- Enhanced top bar with title
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
            TextTruncate = Enum.TextTruncate.AtEnd,
        }),
    })

    -- Enhanced content container with better text handling
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

    -- Enhanced button container
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

    -- Enhanced button creation with better error handling
    for i, buttonConfig in ipairs(config.Buttons) do
        if type(buttonConfig) ~= "table" then
            warn("Button config must be a table")
            continue
        end
        
        buttonConfig.Title = buttonConfig.Title or "Button " .. i
        buttonConfig.Callback = buttonConfig.Callback or function() end
        
        local wrappedCallback = function()
            local success, error = pcall(buttonConfig.Callback)
            if not success then
                warn("Dialog button callback error: " .. tostring(error))
            end
            
            -- Always close dialog after callback
            pcall(function()
                scrolling_frame:Destroy()
            end)
            ActiveDialog = nil
        end

        local success, button = pcall(function()
            return setmetatable({
                Container = buttonContainer
            }, ButtonComponent):New({
                Title = buttonConfig.Title,
                Variant = buttonConfig.Variant or (i == 1 and "Primary" or "Ghost"),
                Callback = wrappedCallback,
            })
        end)
        
        if not success then
            warn("Failed to create dialog button: " .. tostring(button))
        end
    end

    ActiveDialog = scrolling_frame
    return dialog
end

return DialogModule

end)() end,
    [4] = function()local wax,script,require=ImportGlobals(4)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local Create = Tools.Create

return function(title, desc, parent)
    -- Enhanced validation
    if not parent then
        warn("Element parent is required")
        return nil
    end
    
    title = tostring(title or "Element")
    desc = desc and tostring(desc) or nil
    
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
        AutoButtonColor = false,
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
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
        Font = Enum.Font.Gotham,
        LineHeight = 1.2,
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
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 36),
            PaddingTop = UDim.new(0, 2),
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
        Text = desc or "",
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 23),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = desc ~= nil and desc ~= "",
        Parent = Element.Frame,
    })

    -- Enhanced setter functions with validation
    function Element:SetTitle(newTitle)
        if newTitle == nil then
            newTitle = ""
        end
        name.Text = tostring(newTitle)
    end

    function Element:SetDesc(newDesc)
        if newDesc == nil then
            newDesc = ""
        end
        
        newDesc = tostring(newDesc)
        
        if newDesc == "" then
            description.Visible = false
        else
            description.Visible = true
        end
        description.Text = newDesc
    end

    -- Initialize with provided values
    Element:SetDesc(desc)
    Element:SetTitle(title)

    function Element:Destroy()
        if Element.Frame then
            Element.Frame:Destroy()
        end
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
    if not Gui then
        warn("Notification GUI parent is required")
        return false
    end
    
    local success, error = pcall(function()
        self.MainHolder = Create("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0,0,0),
            BorderSizePixel = 0,
            Position = UDim2.new(1, 0, 1, 0),
            Size = UDim2.new(0, 262, 0, 100),
            Visible = true,
            Parent = Gui,
            ZIndex = 1000,
        }, {
            Create("UIPadding", {
                PaddingBottom = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 0),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 0),
            }),
            Create("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 8),
            })
        })
    end)
    
    if not success then
        warn("Failed to initialize notifications: " .. tostring(error))
        return false
    end
    
    return true
end

function Notif:ShowNotification(titleText, descriptionText, duration)
    -- Enhanced validation
    if not self.MainHolder then
        warn("Notification system not initialized")
        return false
    end
    
    titleText = tostring(titleText or "Notification")
    descriptionText = tostring(descriptionText or "")
    duration = tonumber(duration) or 5
    
    if duration <= 0 then
        duration = 5
    end
    
    local success, error = pcall(function()
        local main = Create("CanvasGroup", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(9, 9, 9),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Size = UDim2.new(0, 300, 0, 0),
            Position = UDim2.new(1, -10, 0.5, -150),
            AnchorPoint = Vector2.new(1, 0.5),
            Visible = true,
            Parent = self.MainHolder,
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),
            Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.fromRGB(23, 23, 23),
                Thickness = 1,
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
                PaddingBottom = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 14),
                PaddingRight = UDim.new(0, 14),
                PaddingTop = UDim.new(0, 12),
            }),
            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
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
            Size = UDim2.new(0, 18, 0, 18),
            Visible = true,
            Parent = topframe,
            ImageTransparency = 1, -- Start invisible for fade in
        })

        local title = Create("TextLabel", {
            Font = Enum.Font.GothamMedium,
            LineHeight = 1.2,
            RichText = true,
            TextColor3 = Color3.fromRGB(225, 225, 225),
            TextSize = 18,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundTransparency = 1,
            Text = titleText,
            Visible = true,
            Parent = topframe,
            TextTransparency = 1, -- Start invisible for fade in
        }, {
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 24),
            }),
        })

        local description = Create("TextLabel", {
            Font = Enum.Font.Gotham,
            RichText = true,
            TextColor3 = Color3.fromRGB(225, 225, 225),
            TextSize = 16,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.XY,
            LayoutOrder = 1,
            BackgroundTransparency = 1,
            Text = descriptionText,
            Visible = descriptionText ~= "",
            Parent = holderin,
            TextTransparency = 1, -- Start invisible for fade in
        })

        local progress = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 2),
            Visible = true,
            Parent = main,
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
            }),
        })

        local progressindicator = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(1, 0, 0, 2),
            Visible = true,
            Parent = progress,
        }, {
            Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
            }),
        })

        -- Enhanced fade in animation
        local fadeInTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        local fadeInTween = TweenService:Create(main, fadeInTweenInfo, {BackgroundTransparency = 0.4})
        local fadeInTweenTitle = TweenService:Create(title, fadeInTweenInfo, {TextTransparency = 0})
        local fadeInTweenDescription = TweenService:Create(description, fadeInTweenInfo, {TextTransparency = 0})
        local fadeInTweenUser = TweenService:Create(user, fadeInTweenInfo, {ImageTransparency = 0})

        fadeInTween:Play()
        fadeInTweenTitle:Play()
        fadeInTweenDescription:Play()
        fadeInTweenUser:Play()

        -- Enhanced progress animation
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(progressindicator, tweenInfo, {Size = UDim2.new(0, 0, 0, 2)})
        tween:Play()

        -- Enhanced cleanup with fade out
        tween.Completed:Connect(function()
            local fadeOutTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            local fadeOutTween = TweenService:Create(main, fadeOutTweenInfo, {
                BackgroundTransparency = 1,
                Position = UDim2.new(1.2, 0, main.Position.Y.Scale, main.Position.Y.Offset)
            })
            
            fadeOutTween:Play()
            fadeOutTween.Completed:Connect(function()
                main:Destroy()
            end)
        end)

        -- Add click to dismiss functionality
        local dismissButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = main,
            ZIndex = 10,
        })
        
        AddConnection(dismissButton.MouseButton1Click, function()
            tween:Cancel()
            local fadeOutTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            local fadeOutTween = TweenService:Create(main, fadeOutTweenInfo, {
                BackgroundTransparency = 1,
                Position = UDim2.new(1.2, 0, main.Position.Y.Scale, main.Position.Y.Offset)
            })
            
            fadeOutTween:Play()
            fadeOutTween.Completed:Connect(function()
                main:Destroy()
            end)
        end)
    end)
    
    if not success then
        warn("Failed to show notification: " .. tostring(error))
        return false
    end
    
    return true
end

return Notif

end)() end,
    [6] = function()local wax,script,require=ImportGlobals(6)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection

return function(cfgs, Parent)
    -- Enhanced validation
    if not Parent then
        warn("Section parent is required")
        return nil
    end
    
    cfgs = cfgs or {}
    cfgs.Title = cfgs.Title and tostring(cfgs.Title) or nil
    cfgs.Description = cfgs.Description and tostring(cfgs.Description) or nil
    cfgs.Default = cfgs.Default ~= nil and cfgs.Default or false
    cfgs.Locked = cfgs.Locked ~= nil and cfgs.Locked or false
    cfgs.TitleTextSize = tonumber(cfgs.TitleTextSize) or 14

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
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 6),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor"
            },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
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
        AutoButtonColor = false,
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
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
        Size = UDim2.new(0, 24, 0, 24),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Rotation = 90,
        Name = "chevron-down",
        ZIndex = 99,
        AutoButtonColor = false,
    })
    
    local name = Create("TextLabel", {
        Font = Enum.Font.Gotham,
        LineHeight = 1.2,
        RichText = true,
        ThemeProps = {
            TextColor3 = "titlecolor",
            BackgroundColor3 = "maincolor",
        },
        TextSize = cfgs.TitleTextSize,
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

    -- Enhanced description handling
    local description = nil
    if cfgs.Description and cfgs.Description ~= "" then
        description = Create("TextLabel", {
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
            Text = cfgs.Description,
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 23),
            Size = UDim2.new(1, 0, 0, 16),
            Visible = true,
            Parent = topbox,
        })
    end

    -- Enhanced title handling
    if cfgs.Title and cfgs.Title ~= "" then
        name.Size = UDim2.new(1, 0, 0, 16)
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
        }),
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 1),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 1),
            PaddingTop = UDim.new(0, 1),
        }),
    })

    local isExpanded = cfgs.Default
    if cfgs.Default == true then
        chevronIcon.Rotation = 0
    end

    -- Enhanced toggle function with better animations
    local function toggleSection()
        isExpanded = not isExpanded
        local targetRotation = isExpanded and 0 or 90
        
        -- Enhanced chevron rotation animation
        local rotationTween = TweenService:Create(chevronIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Rotation = targetRotation
        })
        rotationTween:Play()
        
        -- Enhanced section container animation
        local targetSize = isExpanded and UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 18) or UDim2.new(1, 0, 0, 0)
        local sizeTween = TweenService:Create(Section.SectionContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = targetSize
        })
        sizeTween:Play()
    end

    -- Enhanced event handling
    if not cfgs.Locked then
        AddConnection(topbox.MouseButton1Click, toggleSection)
        AddConnection(chevronIcon.MouseButton1Click, function(input)
            input:Stop() -- Prevent event bubbling
            toggleSection()
        end)
        
        -- Add hover effects for better UX
        AddConnection(topbox.MouseEnter, function()
            TweenService:Create(topbox, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.95
            }):Play()
        end)
        
        AddConnection(topbox.MouseLeave, function()
            TweenService:Create(topbox, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
        end)
    else
        topbox:Destroy()
        chevronIcon:Destroy()
    end
    
    -- Enhanced content size monitoring
    AddConnection(Section.SectionContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if isExpanded then
            local newSize = UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 18)
            Section.SectionContainer.Size = newSize
        end
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

-- Enhanced debug system
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
    _initialized = false,
}

function TabModule:Init(Window)
    if not Window then
        warn("TabModule requires a window parameter")
        return nil
    end
    
    TabModule.Window = Window
    TabModule._initialized = true
    return TabModule
end

-- Enhanced cleanup function
function TabModule:CleanupTab(TabIndex)
    if not TabIndex or type(TabIndex) ~= "number" then
        warn("Invalid TabIndex for cleanup")
        return
    end
    
    -- Remove search container if it exists
    if TabModule.SearchContainers[TabIndex] then
        pcall(function()
            TabModule.SearchContainers[TabIndex]:Destroy()
        end)
        TabModule.SearchContainers[TabIndex] = nil
    end
    
    -- Remove other references
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
    if not self._initialized then
        warn("TabModule not initialized")
        return nil
    end
    
    if not Title or type(Title) ~= "string" or Title == "" then
        warn("Tab title must be a non-empty string")
        return nil
    end
    
    if not Parent then
        warn("Tab parent is required")
        return nil
    end
    
    local Library = require(script.Parent.Parent)
    local Window = TabModule.Window
    local Elements = Library.Elements

    TabModule.TabCount = TabModule.TabCount + 1
    local TabIndex = TabModule.TabCount

    local Tab = {
        Selected = false,
        Name = Title,
        Type = "Tab",
        Index = TabIndex,
    }

    -- Enhanced tab button with better styling
    Tab.TabBtn = Create("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Parent = Parent,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = TabIndex,
    }, {
        Create("TextLabel", {
            Name = "Title",
            Font = Enum.Font.Gotham,
            TextColor3 = Color3.fromRGB(63, 63, 63),
            TextSize = 14,
            ThemeProps = {
                BackgroundColor3 = "maincolor",
            },
            BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0.5, 0),
            Size = UDim2.new(0.8, 0, 0.9, 0),
            Text = Title,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }),
        Create("Frame", {
            Name = "Line",
            BackgroundColor3 = Color3.fromRGB(29, 29, 29),
            Position = UDim2.new(0, 4, 0, 0),
            Size = UDim2.new(0, 2, 1, 0),
            BorderSizePixel = 0,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })

    -- Enhanced search container with better positioning
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

    Tab.SearchContainer = Create("Frame", {
        Name = "SearchContainer_" .. TabIndex,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = Parent,
        LayoutOrder = TabIndex + 100,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Visible = false,
    })

    -- Enhanced search box with better styling
    local SearchBox = Create("TextBox", {
        Size = UDim2.new(1, -8, 0, 32),
        Position = UDim2.new(0, 4, 0, 2),
        PlaceholderText = "Search elements...",
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BackgroundTransparency = 1,
        ThemeProps = {
            TextColor3 = "titlecolor",
            PlaceholderColor3 = "descriptioncolor",
        },
        Parent = Tab.SearchContainer,
        ClearTextOnFocus = false,
    }, {
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "bordercolor",
            },
            Thickness = 1,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })

    -- Enhanced container with better scrolling
    Tab.Container = Create("ScrollingFrame", {
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ThemeProps = {
            ScrollBarImageColor3 = "scrollcolor",
            BackgroundColor3 = "maincolor",
        },
        ScrollBarThickness = 2,
        ScrollBarImageTransparency = 1,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 140, 0, 40),
        Size = UDim2.new(1, -140, 1, -40),
        Visible = false,
        Parent = TabModule.Window,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
        }),
    })

    AddScrollAnim(Tab.Container)

    -- Enhanced canvas size updating
    AddConnection(Tab.Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        Tab.Container.CanvasSize = UDim2.new(0, 0, 0, Tab.Container.UIListLayout.AbsoluteContentSize.Y + 28)
    end)

    -- Enhanced search functionality
    local function searchInElement(element, searchText)
        if not element or not searchText then
            return false
        end
        
        local title = element:FindFirstChild("Title", true)
        local desc = element:FindFirstChild("Description", true)

        if title and title.Text then
            debugLog("Checking title:", title.Text)
            local cleanTitle = title.Text:gsub("^%s+", "")
            if string.find(string.lower(cleanTitle), searchText) then
                debugLog("Found match in title")
                return true
            end
        end

        if desc and desc.Text then
            debugLog("Checking description:", desc.Text)
            if string.find(string.lower(desc.Text), searchText) then
                debugLog("Found match in description")
                return true
            end
        end

        return false
    end

    local function updateSearch()
        local searchText = string.lower(SearchBox.Text or "")
        debugLog("Search text:", searchText)

        if not Tab.Container.Visible then
            debugLog("Tab not visible, skipping search")
            return
        end

        -- Enhanced search through all children
        for _, child in ipairs(Tab.Container:GetChildren()) do
            if child:IsA("GuiObject") then
                if child.Name == "Section" then
                    -- Handle section elements
                    local sectionContainer = child:FindFirstChild("SectionContainer")
                    if sectionContainer then
                        local visible = false
                        debugLog("Checking section:", child.Name)

                        -- Search through elements in section
                        for _, element in ipairs(sectionContainer:GetChildren()) do
                            if element:IsA("GuiObject") and element.Name == "Element" then
                                local elementVisible = searchInElement(element, searchText)
                                element.Visible = elementVisible or searchText == ""
                                if elementVisible then
                                    visible = true
                                end
                            end
                        end

                        -- Show section if any elements match or search is empty
                        child.Visible = visible or searchText == ""
                        debugLog("Section visibility:", child.Visible)
                    end
                elseif child.Name == "Element" then
                    -- Handle standalone elements
                    local elementVisible = searchInElement(child, searchText)
                    child.Visible = elementVisible or searchText == ""
                    debugLog("Standalone element visibility:", child.Visible)
                end
            end
        end
    end

    -- Enhanced search event handling
    AddConnection(Tab.Container:GetPropertyChangedSignal("Visible"), function()
        if Tab.Container.Visible then
            updateSearch()
        end
    end)

    AddConnection(SearchBox:GetPropertyChangedSignal("Text"), updateSearch)

    Tab.ContainerFrame = Tab.Container

    -- Enhanced tab selection with hover effects
    AddConnection(Tab.TabBtn.MouseEnter, function()
        if not Tab.Selected then
            TweenService:Create(Tab.TabBtn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.95
            }):Play()
        end
    end)
    
    AddConnection(Tab.TabBtn.MouseLeave, function()
        if not Tab.Selected then
            TweenService:Create(Tab.TabBtn, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
        end
    end)

    AddConnection(Tab.TabBtn.MouseButton1Click, function()
        TabModule:SelectTab(TabIndex)
    end)

    TabModule.Containers[TabIndex] = Tab.ContainerFrame
    TabModule.Tabs[TabIndex] = Tab
    TabModule.SearchContainers[TabIndex] = Tab.SearchContainer

    -- Enhanced section creation
    function Tab:AddSection(cfgs)
        cfgs = cfgs or {}
        cfgs.Title = cfgs.Title and tostring(cfgs.Title) or nil
        cfgs.Description = cfgs.Description and tostring(cfgs.Description) or nil
        
        local Section = { Type = "Section" }

        local success, SectionFrame = pcall(function()
            return require(script.Parent.section)(cfgs, Tab.Container)
        end)
        
        if not success then
            warn("Failed to create section: " .. tostring(SectionFrame))
            return nil
        end
        
        Section.Container = SectionFrame.SectionContainer

        -- Enhanced group button functionality
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
                    Padding = UDim.new(0, 6),
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

    -- Enhanced cleanup when tab is destroyed
    function Tab:Destroy()
        TabModule:CleanupTab(TabIndex)
    end

    return Tab
end

-- Enhanced tab selection with better animations
function TabModule:SelectTab(Tab)
    if not Tab or type(Tab) ~= "number" then
        warn("Invalid tab index for selection")
        return
    end
    
    TabModule.SelectedTab = Tab

    -- Enhanced tab styling updates
    for i, v in next, TabModule.Tabs do
        if v and v.TabBtn then
            v.Selected = false
            
            -- Enhanced deselection animation
            TweenService:Create(
                v.TabBtn.Title,
                TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { TextColor3 = CurrentThemeProps.offTextBtn }
            ):Play()
            TweenService:Create(
                v.TabBtn.Line,
                TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundColor3 = CurrentThemeProps.offBgLineBtn }
            ):Play()
            TweenService:Create(
                v.TabBtn,
                TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 1 }
            ):Play()
            
            -- Hide search container for non-selected tabs
            if TabModule.SearchContainers[i] then
                TabModule.SearchContainers[i].Visible = false
            end
        end
    end

    local selectedTab = TabModule.Tabs[Tab]
    if selectedTab and selectedTab.TabBtn then
        selectedTab.Selected = true
        
        -- Enhanced selection animation
        TweenService:Create(
            selectedTab.TabBtn.Title,
            TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { TextColor3 = CurrentThemeProps.onTextBtn }
        ):Play()
        TweenService:Create(
            selectedTab.TabBtn.Line,
            TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { BackgroundColor3 = CurrentThemeProps.onBgLineBtn }
        ):Play()
        TweenService:Create(
            selectedTab.TabBtn,
            TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { BackgroundTransparency = 0.95 }
        ):Play()

        task.spawn(function()
            -- Hide all containers first
            for _, Container in pairs(TabModule.Containers) do
                if Container then
                    Container.Visible = false
                end
            end

            -- Show search container for selected tab only
            if TabModule.SearchContainers[Tab] then
                TabModule.SearchContainers[Tab].Visible = true
            end

            -- Show selected container
            if TabModule.Containers[Tab] then
                TabModule.Containers[Tab].Visible = true
            end
        end)
    end
end

return TabModule

end)() end,
    [8] = function()local wax,script,require=ImportGlobals(8)local ImportGlobals return (function(...)local Elements = {}

-- Enhanced element loading with error handling
for _, Theme in next, script:GetChildren() do
    local success, element = pcall(require, Theme)
    if success and element then
        table.insert(Elements, element)
    else
        warn("Failed to load element: " .. Theme.Name .. " - " .. tostring(element))
    end
end

return Elements

end)() end,
    [9] = function()local wax,script,require=ImportGlobals(9)local ImportGlobals return (function(...)local UserInputService = game:GetService("UserInputService")

local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection

-- Enhanced blacklisted keys with better mobile support
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
    Enum.KeyCode.Return, -- Enter key
    Enum.KeyCode.Space, -- Space key (often used for jumping)
}

local Element = {}
Element.__index = Element
Element.__type = "Bind"

function Element:New(Idx, Config)
    -- Enhanced validation
    if not Config or type(Config) ~= "table" then
        warn("Bind config must be a table")
        return nil
    end
    
    if not Config.Title or type(Config.Title) ~= "string" then
        warn("Bind - Missing or invalid Title")
        return nil
    end
    
    Config.Description = Config.Description and tostring(Config.Description) or nil
    Config.Hold = Config.Hold ~= nil and Config.Hold or false
    Config.Callback = type(Config.Callback) == "function" and Config.Callback or function() end
    Config.ChangeCallback = type(Config.ChangeCallback) == "function" and Config.ChangeCallback or function() end
    Config.Default = Config.Default or Enum.KeyCode.F
    
    local Bind = { 
        Value = nil, 
        Binding = false, 
        Type = "Bind",
        Hold = Config.Hold,
    }
    local Holding = false

    local BindFrame = require(Components.element)(Config.Title, Config.Description, self.Container)
    if not BindFrame then
        warn("Failed to create bind frame")
        return nil
    end

    -- Enhanced value display with better styling
    local value = Create("TextLabel", {
        Font = Enum.Font.Gotham,
        RichText = true,
        Text = "",
        ThemeProps = {
            BackgroundColor3 = "bordercolor",
            TextColor3 = "titlecolor",
        },
        TextSize = 14,
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 16),
        Visible = true,
        Parent = BindFrame.topbox,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 0),
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })

    -- Enhanced input handling with better mobile support
    AddConnection(BindFrame.Frame.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if Bind.Binding then
                return
            end
            Bind.Binding = true
            value.Text = "..."
            value.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow while binding
        end
    end)

    -- Enhanced set function with validation
    function Bind:Set(Key)
        Bind.Binding = false
        
        if Key then
            Bind.Value = Key
        end
        
        if Bind.Value then
            local keyName = ""
            if typeof(Bind.Value) == "EnumItem" then
                keyName = Bind.Value.Name
            else
                keyName = tostring(Bind.Value)
            end
            
            value.Text = keyName
            value.TextColor3 = Tools.GetPropsCurrentTheme().titlecolor
            
            local success, error = pcall(Config.ChangeCallback, keyName)
            if not success then
                warn("Bind ChangeCallback error: " .. tostring(error))
            end
        end
    end

    -- Enhanced input detection with better error handling
    AddConnection(UserInputService.InputBegan, function(Input, gameProcessed)
        if gameProcessed then return end
        
        if UserInputService:GetFocusedTextBox() then
            return
        end
        
        local inputKey = Input.KeyCode ~= Enum.KeyCode.Unknown and Input.KeyCode or Input.UserInputType
        local bindKey = Bind.Value
        
        if typeof(bindKey) == "EnumItem" then
            bindKey = bindKey.Name
        else
            bindKey = tostring(bindKey)
        end
        
        local inputKeyName = ""
        if typeof(inputKey) == "EnumItem" then
            inputKeyName = inputKey.Name
        else
            inputKeyName = tostring(inputKey)
        end
        
        if inputKeyName == bindKey and not Bind.Binding then
            if Config.Hold then
                Holding = true
                local success, error = pcall(Config.Callback, Holding)
                if not success then
                    warn("Bind Callback error: " .. tostring(error))
                end
            else
                local success, error = pcall(Config.Callback)
                if not success then
                    warn("Bind Callback error: " .. tostring(error))
                end
            end
        elseif Bind.Binding then
            local Key = nil
            
            -- Enhanced key validation
            if Input.KeyCode ~= Enum.KeyCode.Unknown and not table.find(BlacklistedKeys, Input.KeyCode) then
                Key = Input.KeyCode
            elseif Input.UserInputType ~= Enum.UserInputType.Keyboard and Input.UserInputType ~= Enum.UserInputType.None then
                Key = Input.UserInputType
            end
            
            if Key then
                Bind:Set(Key)
            else
                -- Keep current value if invalid key
                Bind:Set(Bind.Value)
            end
        end
    end)

    -- Enhanced input end handling
    AddConnection(UserInputService.InputEnded, function(Input, gameProcessed)
        if gameProcessed then return end
        
        local inputKey = Input.KeyCode ~= Enum.KeyCode.Unknown and Input.KeyCode or Input.UserInputType
        local bindKey = Bind.Value
        
        if typeof(bindKey) == "EnumItem" then
            bindKey = bindKey.Name
        else
            bindKey = tostring(bindKey)
        end
        
        local inputKeyName = ""
        if typeof(inputKey) == "EnumItem" then
            inputKeyName = inputKey.Name
        else
            inputKeyName = tostring(inputKey)
        end
        
        if inputKeyName == bindKey then
            if Config.Hold and Holding then
                Holding = false
                local success, error = pcall(Config.Callback, Holding)
                if not success then
                    warn("Bind Callback error: " .. tostring(error))
                end
            end
        end
    end)

    -- Initialize with default value
    Bind:Set(Config.Default)

    if self.Library and self.Library.Flags then
        self.Library.Flags[Idx] = Bind
    end
    
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

-- Enhanced button styles with better theming
local ButtonStyles = {
    Primary = {
        TextColor3 = Color3.fromRGB(9, 9, 9),
        BackgroundColor3 = CurrentThemeProps.primarycolor,
        BackgroundTransparency = 0,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        HoverConfig = {
            BackgroundTransparency = 0.1,
        },
        FocusConfig = {
            BackgroundTransparency = 0.2,
        },
    },
    Ghost = {
        TextColor3 = Color3.fromRGB(244, 244, 244),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        HoverConfig = {
            BackgroundTransparency = 0.98,
        },
        FocusConfig = {
            BackgroundTransparency = 0.94,
        },
    },
    Outline = {
        TextColor3 = Color3.fromRGB(244, 244, 244),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 1,
        UIStroke = {
            Color = Color3.fromRGB(39, 39, 42),
            Thickness = 1,
        },
        HoverConfig = {
            BackgroundTransparency = 0.94,
        },
        FocusConfig = {
            BackgroundTransparency = 0.98,
        },
    },
    Destructive = {
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(239, 68, 68),
        BackgroundTransparency = 0,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        HoverConfig = {
            BackgroundColor3 = Color3.fromRGB(220, 38, 38),
        },
        FocusConfig = {
            BackgroundColor3 = Color3.fromRGB(185, 28, 28),
        },
    },
}

-- Enhanced tween application with better error handling
local function ApplyTweens(button, config, uiStroke)
    if not button or not config then
        warn("Invalid button or config for tween")
        return
    end
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tweenGoals = {}

    for property, value in pairs(config) do
        if property ~= "UIStroke" then
            tweenGoals[property] = value
        end
    end

    if next(tweenGoals) then
        local success, error = pcall(function()
            local tween = TweenService:Create(button, tweenInfo, tweenGoals)
            tween:Play()
        end)
        
        if not success then
            warn("Button tween error: " .. tostring(error))
        end
    end

    if uiStroke and config.UIStroke then
        local strokeTweenGoals = {}
        for property, value in pairs(config.UIStroke) do
            strokeTweenGoals[property] = value
        end
        
        if next(strokeTweenGoals) then
            local success, error = pcall(function()
                local strokeTween = TweenService:Create(uiStroke, tweenInfo, strokeTweenGoals)
                strokeTween:Play()
            end)
            
            if not success then
                warn("Button stroke tween error: " .. tostring(error))
            end
        end
    end
end

-- Enhanced button creation with better validation
local function CreateButton(style, text, parent)
    if not style or not ButtonStyles[style] then
        warn("Invalid button style: " .. tostring(style))
        return nil
    end
    
    if not text or type(text) ~= "string" then
        warn("Button text must be a string")
        return nil
    end
    
    if not parent then
        warn("Button parent is required")
        return nil
    end
    
    local config = ButtonStyles[style]

    local button = Create("TextButton", {
        Font = Enum.Font.Gotham,
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
        AutoButtonColor = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            PaddingTop = UDim.new(0, 8),
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
    })

    -- Add stroke if specified
    local uiStroke = nil
    if config.UIStroke then
        uiStroke = Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = config.UIStroke.Color,
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = config.UIStroke.Thickness,
            Parent = button,
        })
    end

    -- Enhanced hover effects with better error handling
    AddConnection(button.MouseEnter, function()
        if config.HoverConfig then
            ApplyTweens(button, config.HoverConfig, uiStroke)
        end
    end)

    AddConnection(button.MouseLeave, function()
        ApplyTweens(button, {
            BackgroundColor3 = config.BackgroundColor3,
            TextColor3 = config.TextColor3,
            BackgroundTransparency = config.BackgroundTransparency,
            BorderColor3 = config.BorderColor3,
            BorderSizePixel = config.BorderSizePixel,
            UIStroke = config.UIStroke,
        }, uiStroke)
    end)

    AddConnection(button.MouseButton1Down, function()
        if config.FocusConfig then
            ApplyTweens(button, config.FocusConfig, uiStroke)
        end
    end)

    AddConnection(button.MouseButton1Up, function()
        if config.HoverConfig then
            ApplyTweens(button, config.HoverConfig, uiStroke)
        else
            ApplyTweens(button, {
                BackgroundColor3 = config.BackgroundColor3,
                TextColor3 = config.TextColor3,
                BackgroundTransparency = config.BackgroundTransparency,
                BorderColor3 = config.BorderColor3,
                BorderSizePixel = config.BorderSizePixel,
                UIStroke = config.UIStroke,
            }, uiStroke)
        end
    end)

    return button
end

function Element:New(Config)
    -- Enhanced validation
    if not Config or type(Config) ~= "table" then
        warn("Button config must be a table")
        return nil
    end
    
    if not Config.Title or type(Config.Title) ~= "string" then
        warn("Button - Missing or invalid Title")
        return nil
    end
    
    Config.Variant = Config.Variant or "Primary"
    Config.Callback = type(Config.Callback) == "function" and Config.Callback or function() end
    
    if not self.Container then
        warn("Button container not found")
        return nil
    end
    
    local Button = {}

    local success, styledButton = pcall(function()
        return CreateButton(Config.Variant, Config.Title, self.Container)
    end)
    
    if not success or not styledButton then
        warn("Failed to create button: " .. tostring(styledButton))
        return nil
    end
    
    Button.StyledButton = styledButton
    
    -- Enhanced callback with error handling
    AddConnection(Button.StyledButton.MouseButton1Click, function()
        local success, error = pcall(Config.Callback)
        if not success then
            warn("Button callback error: " .. tostring(error))
        end
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

-- Enhanced color picker variables with better management
local HueSelectionPosition, RainbowColorValue = 0, 0
local rainbowIncrement, hueIncrement, maxHuePosition = 1 / 255, 1, 127

-- Enhanced rainbow animation with better performance
coroutine.wrap(function()
    while true do
        RainbowColorValue = (RainbowColorValue + rainbowIncrement) % 1
        HueSelectionPosition = (HueSelectionPosition + hueIncrement) % maxHuePosition
        task.wait(0.06)
    end
end)()

local Element = {}
Element.__index = Element
Element.__type = "Colorpicker"

function Element:New(Idx, Config)
    -- Enhanced validation
    if not Config or type(Config) ~= "table" then
        warn("Colorpicker config must be a table")
        return nil
    end
    
    if not Config.Title or type(Config.Title) ~= "string" then
        warn("Colorpicker - Missing or invalid Title")
        return nil
    end
    
    Config.Description = Config.Description and tostring(Config.Description) or nil
    
    if not Config.Default or typeof(Config.Default) ~= "Color3" then
        warn("Colorpicker: Missing or invalid default Color3 value")
        Config.Default = Color3.fromRGB(255, 255, 255)
    end

    local Colorpicker = {
        Value = Config.Default,
        Transparency = tonumber(Config.Transparency) or 0,
        Type = "Colorpicker",
        Callback = type(Config.Callback) == "function" and Config.Callback or function(Color) end,
        RainbowColorPicker = false,
        ColorpickerToggle = false,
    }

    -- Enhanced HSV conversion with validation
    function Colorpicker:SetHSVFromRGB(Color)
        if typeof(Color) ~= "Color3" then
            warn("Invalid Color3 value provided to SetHSVFromRGB")
            return
        end
        
        local H, S, V = Color3.toHSV(Color)
        Colorpicker.Hue = H
        Colorpicker.Sat = S
        Colorpicker.Vib = V
    end
    
    Colorpicker:SetHSVFromRGB(Colorpicker.Value)

    local ColorpickerFrame = require(Components.element)(Config.Title, Config.Description, self.Container)
    if not ColorpickerFrame then
        warn("Failed to create colorpicker frame")
        return nil
    end

    -- Enhanced input frame with better styling
    local InputFrame = Create("CanvasGroup", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Visible = true,
        Parent = ColorpickerFrame.Frame,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(24, 24, 26),
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })

    local colorBox = Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Config.Default,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 30, 1, 0),
        Visible = true,
        Parent = InputFrame,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(24, 24, 26),
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })

    -- Enhanced hex input with better validation
    local inputHex = Create("TextBox", {
        Font = Enum.Font.GothamMedium,
        LineHeight = 1.2,
        PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
        Text = "#" .. Config.Default:ToHex(),
        TextColor3 = Color3.fromRGB(178, 178, 178),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Visible = true,
        Parent = InputFrame,
        PlaceholderText = "#FFFFFF",
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 0),
        }),
    })

    -- Enhanced hex input handling
    AddConnection(inputHex.FocusLost, function(Enter)
        if Enter then
            local hexText = inputHex.Text
            if not hexText:match("^#") then
                hexText = "#" .. hexText
            end
            
            local Success, Result = pcall(Color3.fromHex, hexText)
            if Success and typeof(Result) == "Color3" then
                Colorpicker:SetHSVFromRGB(Result)
                Colorpicker.Value = Result
                UpdateColorPicker()
            else
                -- Reset to current color if invalid
                inputHex.Text = "#" .. Colorpicker.Value:ToHex()
            end
        end
    end)

    -- Enhanced colorpicker frame with better layout
    local colorpicker_frame = Create("TextButton", {
        AutoButtonColor = false,
        Text = "",
        ZIndex = 20,
        BackgroundColor3 = Color3.fromRGB(9, 9, 11),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(1, 0, 0, 166),
        Visible = false,
        Parent = ColorpickerFrame.Frame,
        ClipsDescendants = true,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
    })

    -- Enhanced color selection area
    local color = Create("ImageLabel", {
        Image = "rbxassetid://4155801252",
        BackgroundColor3 = Color3.fromRGB(255, 0, 4),
        Size = UDim2.new(1, -10, 0, 127),
        Visible = true,
        ZIndex = 10,
        Parent = colorpicker_frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
        }),
    })

    local color_selection = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 12, 0, 12),
        Visible = true,
        Parent = color,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = Color3.fromRGB(255, 255, 255),
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1.2,
        }),
    })

    -- Enhanced hue selector
    local hue = Create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 6, 0, 127),
        Visible = true,
        Parent = colorpicker_frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 9),
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
        }),
    })

    local hue_selection = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.1, 0),
        Size = UDim2.new(0, 8, 0, 8),
        Visible = true,
        Parent = hue,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = Color3.fromRGB(255, 255, 255),
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1.2,
        }),
    })

    -- Enhanced rainbow toggle
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
        Size = UDim2.new(1, 0, 0, 16),
        Visible = true,
        Parent = colorpicker_frame,
        AutoButtonColor = false,
    })

    local togglebox = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(250, 250, 250),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 16, 0, 16),
        Visible = true,
        Parent = rainbowtoggle,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 5),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(250, 250, 250),
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
        Create("ImageLabel", {
            Image = "http://www.roblox.com/asset/?id=6031094667",
            ImageColor3 = Color3.fromRGB(9, 9, 11),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            Visible = true,
        }),
        Create("TextLabel", {
            Font = Enum.Font.Gotham,
            Text = "Rainbow",
            TextColor3 = Color3.fromRGB(234, 234, 234),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 26, 0, 0),
            Size = UDim2.new(1, 0, 0, 16),
            Visible = true,
        }),
    })

    -- Enhanced update function with better error handling
    local function UpdateColorPicker()
        if not (Colorpicker.Hue and Colorpicker.Sat and Colorpicker.Vib) then
            warn("Missing HSV values in UpdateColorPicker")
            return
        end
        
        local success, error = pcall(function()
            local newColor = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)
            Colorpicker.Value = newColor
            
            colorBox.BackgroundColor3 = newColor
            color.BackgroundColor3 = Color3.fromHSV(Colorpicker.Hue, 1, 1)
            color_selection.BackgroundColor3 = newColor
            
            if inputHex then
                inputHex.Text = "#" .. newColor:ToHex()
            end
            
            Colorpicker.Callback(newColor)
        end)
        
        if not success then
            warn("UpdateColorPicker error: " .. tostring(error))
        end
    end
    
    -- Enhanced position update functions
    local function UpdateColorPickerPosition()
        if not color or not color.Parent then return end
        
        local ColorX = math.clamp(mouse.X - color.AbsolutePosition.X, 0, color.AbsoluteSize.X)
        local ColorY = math.clamp(mouse.Y - color.AbsolutePosition.Y, 0, color.AbsoluteSize.Y)
        color_selection.Position = UDim2.new(ColorX / color.AbsoluteSize.X, 0, ColorY / color.AbsoluteSize.Y, 0)
        Colorpicker.Sat = ColorX / color.AbsoluteSize.X
        Colorpicker.Vib = 1 - (ColorY / color.AbsoluteSize.Y)
        UpdateColorPicker()
    end
    
    local function UpdateHuePickerPosition()
        if not hue or not hue.Parent then return end
        
        local HueY = math.clamp(mouse.Y - hue.AbsolutePosition.Y, 0, hue.AbsoluteSize.Y)
        hue_selection.Position = UDim2.new(0.5, 0, HueY / hue.AbsoluteSize.Y, 0)
        Colorpicker.Hue = HueY / hue.AbsoluteSize.Y
        UpdateColorPicker()
    end
    
    local ColorInput, HueInput = nil, nil
    
    -- Enhanced input handling with better mobile support
    AddConnection(color.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Colorpicker.RainbowColorPicker then
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
            if Colorpicker.RainbowColorPicker then
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

    -- Enhanced toggle functionality
    AddConnection(ColorpickerFrame.Frame.MouseButton1Click, function()
        Colorpicker.ColorpickerToggle = not Colorpicker.ColorpickerToggle
        
        local targetSize = Colorpicker.ColorpickerToggle and UDim2.new(1, 0, 0, 166) or UDim2.new(1, 0, 0, 0)
        local tween = TweenService:Create(colorpicker_frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = targetSize
        })
        tween:Play()
        
        colorpicker_frame.Visible = Colorpicker.ColorpickerToggle
    end)

    -- Enhanced rainbow toggle functionality
    AddConnection(rainbowtoggle.MouseButton1Click, function()
        Colorpicker.RainbowColorPicker = not Colorpicker.RainbowColorPicker
        
        TweenService:Create(
            togglebox,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency = Colorpicker.RainbowColorPicker and 0 or 1 }
        ):Play()
        
        if Colorpicker.RainbowColorPicker then
            local function UpdateRainbowColor()
                while Colorpicker.RainbowColorPicker do
                    Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = RainbowColorValue, 1, 1
                    hue_selection.Position = UDim2.new(0.5, 0, RainbowColorValue, 0)
                    color_selection.Position = UDim2.new(1, 0, 0, 0)
                    UpdateColorPicker()
                    task.wait()
                end
            end
            coroutine.wrap(UpdateRainbowColor)()
        end
    end)

    -- Enhanced set function with validation
    function Colorpicker:Set(newColor)
        if typeof(newColor) ~= "Color3" then
            warn("Invalid color value provided to Set")
            return
        end
        
        self.Value = newColor
        self:SetHSVFromRGB(newColor)
        
        if color_selection and colorBox and hue_selection then
            color_selection.Position = UDim2.new(self.Sat, 0, 1 - self.Vib, 0)
            colorBox.BackgroundColor3 = newColor
            hue_selection.Position = UDim2.new(0.5, 0, self.Hue, 0)
            
            if inputHex then
                inputHex.Text = "#" .. newColor:ToHex()
            end
            
            UpdateColorPicker()
        end
    end

    -- Initialize with default color
    Colorpicker:Set(Config.Default)

    if self.Library and self.Library.Flags then
        self.Library.Flags[Idx] = Colorpicker
    end
    
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
    -- Enhanced validation
    if not Config or type(Config) ~= "table" then
        warn("Dropdown config must be a table")
        return nil
    end
    
    if not Config.Title or type(Config.Title) ~= "string" then
        warn("Dropdown - Missing or invalid Title")
        return nil
    end
    
    Config.Description = Config.Description and tostring(Config.Description) or nil
    Config.Options = Config.Options or {}
    Config.Default = Config.Default or ""
    Config.IgnoreFirst = Config.IgnoreFirst ~= nil and Config.IgnoreFirst or false
    Config.Multiple = Config.Multiple ~= nil and Config.Multiple or false
    Config.MaxOptions = tonumber(Config.MaxOptions) or math.huge
    Config.PlaceHolder = Config.PlaceHolder or "Select an option..."
    Config.Callback = type(Config.Callback) == "function" and Config.Callback or function() end

    -- Validate options
    if type(Config.Options) ~= "table" then
        warn("Dropdown options must be a table")
        Config.Options = {}
    end

    local Dropdown = {
        Value = Config.Multiple and {} or Config.Default,
        Options = Config.Options,
        Buttons = {},
        Toggled = false,
        Type = "Dropdown",
        Multiple = Config.Multiple,
        Callback = Config.Callback,
        MaxOptions = Config.MaxOptions,
    }
    
    local MaxElements = 5

    local DropdownFrame = require(Components.element)(Config.Title, Config.Description, self.Container)
    if not DropdownFrame then
        warn("Failed to create dropdown frame")
        return nil
    end

    -- Enhanced dropdown element with better styling
    local DropdownElement = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        ThemeProps = {
            BackgroundColor3 = "maincolor"
        },
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Visible = true,
        Parent = DropdownFrame.Frame,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
        Create("UIListLayout", {
            Wraps = true,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    -- Enhanced holder with better layout
    local holder = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        ThemeProps = {
            BackgroundColor3 = "maincolor"
        },
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, 30),
        Visible = true,
        Parent = DropdownElement,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 4),
        }),
        Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            Wraps = true,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        Create("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Shrink,
        }),
    })

    -- Enhanced search box with better styling
    local search = Create("TextBox", {
        CursorPosition = -1,
        Font = Enum.Font.Gotham,
        PlaceholderText = Config.PlaceHolder,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ThemeProps = {
            BackgroundColor3 = "maincolor",
            TextColor3 = "titlecolor",
            PlaceholderColor3 = "descriptioncolor",
        },
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 120, 0, 30),
        Visible = true,
        Parent = DropdownElement,
        ClearTextOnFocus = false,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 0),
        }),
        Create("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Fill,
        }),
    })

    -- Enhanced dropdown container with better animations
    local dropcont = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        ThemeProps = { BackgroundColor3 = "containeritemsbg" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = DropdownFrame.Frame,
        ClipsDescendants = true,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
        }),
        Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    -- Enhanced dropdown toggle functionality
    local function toggleDropdown(state)
        if state ~= nil then
            Dropdown.Toggled = state
        else
            Dropdown.Toggled = not Dropdown.Toggled
        end
        
        if Dropdown.Toggled then
            dropcont.Visible = true
            local targetSize = UDim2.new(1, 0, 0, math.min(dropcont.UIListLayout.AbsoluteContentSize.Y + 20, MaxElements * 34 + 20))
            TweenService:Create(dropcont, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Size = targetSize
            }):Play()
        else
            TweenService:Create(dropcont, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            
            task.wait(0.3)
            if not Dropdown.Toggled then
                dropcont.Visible = false
            end
        end
    end

    AddConnection(search.Focused, function()
        toggleDropdown(true)
    end)
    
    AddConnection(DropdownFrame.Frame.MouseButton1Click, function()
        toggleDropdown()
    end)

    -- Enhanced search functionality
    local function SearchOptions()
        local searchText = string.lower(search.Text or "")
        local visibleCount = 0
        
        for _, v in ipairs(dropcont:GetChildren()) do
            if v:IsA("TextButton") and v.TextLabel then
                local buttonText = string.lower(v.TextLabel.Text or "")
                local isVisible = searchText == "" or string.find(buttonText, searchText, 1, true)
                v.Visible = isVisible
                if isVisible then
                    visibleCount = visibleCount + 1
                end
            end
        end
        
        -- Update dropdown size based on visible items
        if Dropdown.Toggled then
            local targetHeight = math.min(visibleCount * 34 + 20, MaxElements * 34 + 20)
            TweenService:Create(dropcont, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                Size = UDim2.new(1, 0, 0, targetHeight)
            }):Play()
        end
    end

    AddConnection(search:GetPropertyChangedSignal("Text"), SearchOptions)

    -- Enhanced option creation
    local function AddOptions(Options)
        -- Clear existing options
        for _, child in ipairs(dropcont:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        Dropdown.Buttons = {}
        
        for _, Option in pairs(Options) do
            if type(Option) ~= "string" then
                Option = tostring(Option)
            end
            
            local check = Create("ImageLabel", {
                Image = "rbxassetid://15269180838",
                ThemeProps = { ImageColor3 = "itemcheckmarkcolor" },
                ImageRectOffset = Vector2.new(514, 257),
                ImageRectSize = Vector2.new(256, 256),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -9, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14),
                Visible = true,
                ImageTransparency = 1,
            })

            local text_label_2 = Create("TextLabel", {
                Font = Enum.Font.Gotham,
                Text = Option,
                LineHeight = 0,
                TextColor3 = Color3.fromRGB(154, 154, 154),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Visible = true,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, {
                Create("UIPadding", {
                    PaddingBottom = UDim.new(0, 0),
                    PaddingLeft = UDim.new(0, 14),
                    PaddingRight = UDim.new(0, 0),
                    PaddingTop = UDim.new(0, 0),
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
                Size = UDim2.new(1, 0, 0, 30),
                Visible = true,
                Parent = dropcont,
                AutoButtonColor = false,
            }, {
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                }),
                text_label_2,
                check,
            })

            -- Enhanced hover effects
            AddConnection(dropbtn.MouseEnter, function()
                TweenService:Create(dropbtn, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.9
                }):Play()
            end)
            
            AddConnection(dropbtn.MouseLeave, function()
                local isSelected = Config.Multiple and table.find(Dropdown.Value, Option) or Dropdown.Value == Option
                TweenService:Create(dropbtn, TweenInfo.new(0.2), {
                    BackgroundTransparency = isSelected and 0 or 1
                }):Play()
            end)

            -- Enhanced click handling
            AddConnection(dropbtn.MouseButton1Click, function()
                if Config.Multiple then
                    local index = table.find(Dropdown.Value, Option)
                    if index then
                        table.remove(Dropdown.Value, index)
                    else
                        if #Dropdown.Value < Config.MaxOptions then
                            table.insert(Dropdown.Value, Option)
                        end
                    end
                    Dropdown:Set(Dropdown.Value)
                else
                    if Dropdown.Value == Option then
                        Dropdown:Set("")
                    else
                        Dropdown:Set(Option)
                        toggleDropdown(false)
                    end
                end
            end)

            Dropdown.Buttons[Option] = dropbtn
        end
    end

    -- Enhanced refresh function
    function Dropdown:Refresh(Options, Delete)
        if Delete then
            for _, v in pairs(Dropdown.Buttons) do
                if v then
                    v:Destroy()
                end
            end
            Dropdown.Buttons = {}
        end
        
        if type(Options) == "table" then
            Dropdown.Options = Options
            AddOptions(Dropdown.Options)
        end
    end

    -- Enhanced set function with better validation
    function Dropdown:Set(Value, ignore)
        local function updateButtonTransparency(button, isSelected)
            if not button then return end
            
            local transparency = isSelected and 0 or 1
            local imageTransparency = isSelected and 0 or 1
            local textColor = isSelected and CurrentThemeProps.itemTextOn or CurrentThemeProps.itemTextOff
            
            TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = transparency
            }):Play()
            
            if button:FindFirstChild("ImageLabel") then
                TweenService:Create(button.ImageLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    ImageTransparency = imageTransparency
                }):Play()
            end
            
            if button:FindFirstChild("TextLabel") then
                TweenService:Create(button.TextLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextColor3 = textColor
                }):Play()
            end
        end

        local function clearValueText()
            for _, label in pairs(holder:GetChildren()) do
                if label:IsA("TextButton") then
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
                Size = UDim2.new(0, 0, 0, 22),
                Visible = true,
                Parent = holder,
                AutoButtonColor = false,
            }, {
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
                Create("UIPadding", {
                    PaddingBottom = UDim.new(0, 0),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, 0),
                }),
                Create("UIListLayout", {
                    Padding = UDim.new(0, 4),
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),
                Create("TextLabel", {
                    Font = Enum.Font.Gotham,
                    ThemeProps = { TextColor3 = "valuetext" },
                    TextSize = 14,
                    Text = text,
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 1, 0),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                }),
                Create("TextButton", {
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 16, 0, 16),
                    Visible = true,
                    AutoButtonColor = false,
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
                        ThemeProps = { ImageColor3 = "valuetext" },
                    }),
                }),
            })

            -- Enhanced remove functionality
            local removeBtn = tagBtn:FindFirstChild("TextButton")
            if removeBtn then
                AddConnection(removeBtn.MouseButton1Click, function()
                    if Config.Multiple then
                        local index = table.find(Dropdown.Value, text)
                        if index then
                            table.remove(Dropdown.Value, index)
                            Dropdown:Set(Dropdown.Value)
                        end
                    else
                        Dropdown:Set("")
                    end
                end)
            end
        end

        -- Enhanced value handling
        if Config.Multiple then
            if type(Value) == "table" then
                Dropdown.Value = {}
                for _, v in ipairs(Value) do
                    if table.find(Dropdown.Options, v) and #Dropdown.Value < Config.MaxOptions then
                        table.insert(Dropdown.Value, v)
                    end
                end
            elseif Value ~= "" and type(Value) == "string" then
                if type(Dropdown.Value) ~= "table" then
                    Dropdown.Value = {}
                end
                local index = table.find(Dropdown.Value, Value)
                if index then
                    table.remove(Dropdown.Value, index)
                else
                    if #Dropdown.Value < Config.MaxOptions and table.find(Dropdown.Options, Value) then
                        table.insert(Dropdown.Value, Value)
                    end
                end
            else
                Dropdown.Value = {}
            end
        else
            Dropdown.Value = Value or ""
        end

        clearValueText()

        -- Update UI based on current value
        if Config.Multiple then
            if #Dropdown.Value > 0 then
                for _, val in ipairs(Dropdown.Value) do
                    addValueText(val)
                end
            end
        else
            if Dropdown.Value ~= "" then
                addValueText(Dropdown.Value)
            end
        end

        -- Update button states
        for optionName, button in pairs(Dropdown.Buttons) do
            local isSelected = Config.Multiple and table.find(Dropdown.Value, optionName) or Dropdown.Value == optionName
            updateButtonTransparency(button, isSelected)
        end

        -- Call callback
        if not ignore then
            local success, error = pcall(Config.Callback, Dropdown.Value)
            if not success then
                warn("Dropdown callback error: " .. tostring(error))
            end
        end
    end

    -- Initialize dropdown
    Dropdown:Refresh(Dropdown.Options, false)
    Dropdown:Set(Config.Multiple and {} or Config.Default, Config.IgnoreFirst)

    if self.Library and self.Library.Flags then
        self.Library.Flags[Idx] = Dropdown
    end
    
    return Dropdown
end

return Element

end)() end,
    [13] = function()local wax,script,require=ImportGlobals(13)local ImportGlobals return (function(...)local Components = script.Parent.Parent.components

local Element = {}
Element.__index = Element
Element.__type = "Paragraph"

function Element:New(Config)
    -- Enhanced validation
    if not Config or type(Config) ~= "table" then
        warn("Paragraph config must be a table")
        return nil
    end
    
    if not Config.Title or type(Config.Title) ~= "string" then
        warn("Paragraph - Missing or invalid Title")
        return nil
    end
    
    Config.Description = Config.Description and tostring(Config.Description) or nil

    if not self.Container then
        warn("Paragraph container not found")
        return nil
    end

    local success, paragraph = pcall(function()
        return require(Components.element)(Config.Title, Config.Description, self.Container)
    end)
    
    if not success then
        warn("Failed to create paragraph: " .. tostring(paragraph))
        return nil
    end

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

-- Enhanced rounding function
local function Round(Number, Factor)
    if not Number or not Factor then return 0 end
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
    -- Enhanced validation
    if not Config or type(Config) ~= "table" then
        warn("Slider config must be a table")
        return nil
    end
    
    if not Config.Title or type(Config.Title) ~= "string" then
        warn("Slider - Missing or invalid Title")
        return nil
    end
    
    local Library = self.Library
    Config.Description = Config.Description and tostring(Config.Description) or nil
    Config.Min = tonumber(Config.Min) or 0
    Config.Max = tonumber(Config.Max) or 100
    Config.Increment = tonumber(Config.Increment) or 1
    Config.Default = tonumber(Config.Default) or Config.Min
    Config.IgnoreFirst = Config.IgnoreFirst ~= nil and Config.IgnoreFirst or false
    Config.Suffix = Config.Suffix or ""
    
    -- Validate ranges
    if Config.Min >= Config.Max then
        warn("Slider Min value must be less than Max value")
        Config.Max = Config.Min + 100
    end
    
    if Config.Increment <= 0 then
        warn("Slider Increment must be greater than 0")
        Config.Increment = 1
    end
    
    Config.Default = math.clamp(Config.Default, Config.Min, Config.Max)

    local Slider = {
        Value = Config.Default,
        Min = Config.Min,
        Max = Config.Max,
        Increment = Config.Increment,
        IgnoreFirst = Config.IgnoreFirst,
        Callback = type(Config.Callback) == "function" and Config.Callback or function(Value) end,
        Type = "Slider",
        Suffix = Config.Suffix,
    }

    local Dragging = false
    local DraggingDot = false

    local SliderFrame = require(Components.element)(Config.Title, Config.Description, self.Container)
    if not SliderFrame then
        warn("Failed to create slider frame")
        return nil
    end

    -- Enhanced value text with better formatting
    local ValueText = Create("TextLabel", {
        Font = Enum.Font.Gotham,
        RichText = true,
        Text = tostring(Config.Default) .. (Config.Suffix ~= "" and " " .. Config.Suffix or ""),
        ThemeProps = {
            TextColor3 = "titlecolor",
        },
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.754537523, 8, 0, 0),
        Size = UDim2.new(0, 90, 0, 16),
        Visible = true,
        Parent = SliderFrame.topbox,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    -- Enhanced slider bar with better styling
    local SliderBar = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        ThemeProps = { BackgroundColor3 = "sliderbar" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 26),
        Size = UDim2.new(1, -6, 0, 4),
        Visible = true,
        Parent = SliderFrame.Frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderbarstroke" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
    })

    -- Enhanced progress bar
    local SliderProgress = Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        ThemeProps = { BackgroundColor3 = "sliderprogressbg" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 1, 0),
        Visible = true,
        Parent = SliderBar,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderprogressborder" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
    })

    -- Enhanced slider dot with better size and styling
    local SliderDot = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        ThemeProps = { BackgroundColor3 = "sliderdotbg" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        Visible = true,
        Parent = SliderBar,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderdotstroke" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })

    -- Enhanced set function with better validation and formatting
    function Slider:Set(Value, ignore)
        if not Value or type(Value) ~= "number" then
            warn("Slider value must be a number")
            return
        end
        
        self.Value = math.clamp(Round(Value, Config.Increment), Config.Min, Config.Max)
        
        -- Enhanced text formatting
        local displayText = tostring(self.Value)
        if Config.Suffix ~= "" then
            displayText = displayText .. " " .. Config.Suffix
        end
        ValueText.Text = displayText
        
        local newPosition = (self.Value - Config.Min) / (Config.Max - Config.Min)
        
        if DraggingDot then
            -- Instant update when dragging dot
            SliderDot.Position = UDim2.new(newPosition, 0, 0.5, 0)
            SliderProgress.Size = UDim2.fromScale(newPosition, 1)
        else
            -- Smooth tween when not dragging
            TweenService:Create(SliderDot, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(newPosition, 0, 0.5, 0)
            }):Play()
            
            TweenService:Create(SliderProgress, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromScale(newPosition, 1)
            }):Play()
        end
        
        if not ignore then
            local success, error = pcall(Config.Callback, self.Value)
            if not success then
                warn("Slider callback error: " .. tostring(error))
            end
        end
    end

    -- Enhanced input handling with better mobile support
    local function updateSliderFromInput(inputPosition)
        if Dragging and SliderBar then
            local barPosition = SliderBar.AbsolutePosition
            local barSize = SliderBar.AbsoluteSize
            
            if barSize.X > 0 then
                local relativeX = (inputPosition.X - barPosition.X) / barSize.X
                local clampedPosition = math.clamp(relativeX, 0, 1)
                local newValue = Config.Min + (Config.Max - Config.Min) * clampedPosition
                Slider:Set(newValue)
            end
        end
    end

    -- Enhanced input event handling
    AddConnection(SliderBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            updateSliderFromInput(input.Position)
            
            -- Visual feedback
            TweenService:Create(SliderDot, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 16, 0, 16)
            }):Play()
        end
    end)

    AddConnection(SliderDot.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DraggingDot = true
            updateSliderFromInput(input.Position)
            
            -- Enhanced visual feedback for dot
            TweenService:Create(SliderDot, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 16, 0, 16)
            }):Play()
        end
    end)

    AddConnection(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Dragging then
                Dragging = false
                DraggingDot = false
                
                -- Reset visual feedback
                TweenService:Create(SliderDot, TweenInfo.new(0.1), {
                    Size = UDim2.new(0, 12, 0, 12)
                }):Play()
            end
        end
    end)

    AddConnection(UserInputService.InputChanged, function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSliderFromInput(input.Position)
        end
    end)

    -- Enhanced hover effects
    AddConnection(SliderBar.MouseEnter, function()
        TweenService:Create(SliderBar, TweenInfo.new(0.2), {
            Size = UDim2.new(1, -6, 0, 6)
        }):Play()
    end)
    
    AddConnection(SliderBar.MouseLeave, function()
        if not Dragging then
            TweenService:Create(SliderBar, TweenInfo.new(0.2), {
                Size = UDim2.new(1, -6, 0, 4)
            }):Play()
        end
    end)

    -- Initialize slider
    Slider:Set(Config.Default, Config.IgnoreFirst)

    if Library and Library.Flags then
        Library.Flags[Idx] = Slider
    end
    
    return Slider
end

return Element

end)() end,
    [15] = function()local wax,script,require=ImportGlobals(15)local ImportGlobals return (function(...)local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection

local Element = {}
Element.__index = Element
Element.__type = "Textbox"

function Element:New(Config)
    -- Enhanced validation
    if not Config or type(Config) ~= "table" then
        warn("Textbox config must be a table")
        return nil
    end
    
    if not Config.Title or type(Config.Title) ~= "string" then
        warn("Textbox - Missing or invalid Title")
        return nil
    end
    
    Config.Description = Config.Description and tostring(Config.Description) or nil
    Config.PlaceHolder = Config.PlaceHolder or "Enter text..."
    Config.Default = Config.Default and tostring(Config.Default) or ""
    Config.TextDisappear = Config.TextDisappear ~= nil and Config.TextDisappear or false
    Config.Callback = type(Config.Callback) == "function" and Config.Callback or function() end
    Config.Multiline = Config.Multiline ~= nil and Config.Multiline or false
    Config.MaxLength = tonumber(Config.MaxLength) or math.huge

    local Textbox = {
        Value = Config.Default,
        Callback = Config.Callback,
        Type = "Textbox",
        MaxLength = Config.MaxLength,
    }

    if not self.Container then
        warn("Textbox container not found")
        return nil
    end

    local TextboxFrame = require(Components.element)(Config.Title, Config.Description, self.Container)
    if not TextboxFrame then
        warn("Failed to create textbox frame")
        return nil
    end

    -- Enhanced textbox with better styling and features
    local textbox = Create("TextBox", {
        CursorPosition = -1,
        Font = Enum.Font.Gotham,
        PlaceholderText = Config.PlaceHolder,
        Text = Textbox.Value,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Config.Multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, Config.Multiline and 60 or 30),
        Visible = true,
        Parent = TextboxFrame.Frame,
        ClearTextOnFocus = false,
        MultiLine = Config.Multiline,
        TextWrapped = Config.Multiline,
        ThemeProps = {
            TextColor3 = "titlecolor",
            PlaceholderColor3 = "descriptioncolor",
        },
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, Config.Multiline and 8 or 0),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, Config.Multiline and 8 or 0),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })

    -- Enhanced character counter for max length
    local characterCounter = nil
    if Config.MaxLength < math.huge then
        characterCounter = Create("TextLabel", {
            Font = Enum.Font.Gotham,
            Text = string.format("%d/%d", #Textbox.Value, Config.MaxLength),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -12, 1, -16),
            Size = UDim2.new(0, 60, 0, 16),
            Parent = TextboxFrame.Frame,
            ThemeProps = {
                TextColor3 = "descriptioncolor",
            },
        })
    end

    -- Enhanced set function with validation
    function Textbox:Set(value)
        if value == nil then
            value = ""
        end
        
        value = tostring(value)
        
        -- Apply max length limit
        if #value > Config.MaxLength then
            value = string.sub(value, 1, Config.MaxLength)
        end
        
        textbox.Text = value
        Textbox.Value = value
        
        -- Update character counter
        if characterCounter then
            characterCounter.Text = string.format("%d/%d", #value, Config.MaxLength)
            
            -- Color coding for character limit
            if #value >= Config.MaxLength * 0.9 then
                characterCounter.TextColor3 = Color3.fromRGB(239, 68, 68) -- Red
            elseif #value >= Config.MaxLength * 0.7 then
                characterCounter.TextColor3 = Color3.fromRGB(245, 158, 11) -- Yellow
            else
                characterCounter.TextColor3 = Tools.GetPropsCurrentTheme().descriptioncolor
            end
        end
        
        local success, error = pcall(Config.Callback, value)
        if not success then
            warn("Textbox callback error: " .. tostring(error))
        end
    end

    -- Enhanced input validation
    local function validateInput(text)
        -- Apply max length limit
        if #text > Config.MaxLength then
            text = string.sub(text, 1, Config.MaxLength)
            textbox.Text = text
        end
        
        return text
    end

    -- Enhanced focus handling
    AddConnection(textbox.FocusLost, function(enterPressed)
        local validatedText = validateInput(textbox.Text)
        Textbox.Value = validatedText
        
        local success, error = pcall(Config.Callback, Textbox.Value)
        if not success then
            warn("Textbox callback error: " .. tostring(error))
        end
        
        if Config.TextDisappear then
            textbox.Text = ""
            if characterCounter then
                characterCounter.Text = string.format("0/%d", Config.MaxLength)
                characterCounter.TextColor3 = Tools.GetPropsCurrentTheme().descriptioncolor
            end
        end
    end)

    -- Enhanced text change handling for real-time validation
    AddConnection(textbox:GetPropertyChangedSignal("Text"), function()
        local validatedText = validateInput(textbox.Text)
        
        -- Update character counter in real-time
        if characterCounter then
            characterCounter.Text = string.format("%d/%d", #validatedText, Config.MaxLength)
            
            -- Color coding for character limit
            if #validatedText >= Config.MaxLength * 0.9 then
                characterCounter.TextColor3 = Color3.fromRGB(239, 68, 68) -- Red
            elseif #validatedText >= Config.MaxLength * 0.7 then
                characterCounter.TextColor3 = Color3.fromRGB(245, 158, 11) -- Yellow
            else
                characterCounter.TextColor3 = Tools.GetPropsCurrentTheme().descriptioncolor
            end
        end
    end)

    -- Enhanced focus visual feedback
    AddConnection(textbox.Focused, function()
        local stroke = textbox:FindFirstChild("UIStroke")
        if stroke then
            stroke.Color = Tools.GetPropsCurrentTheme().primarycolor or Color3.fromRGB(59, 130, 246)
            stroke.Thickness = 2
        end
    end)

    AddConnection(textbox.FocusLost, function()
        local stroke = textbox:FindFirstChild("UIStroke")
        if stroke then
            stroke.Color = Tools.GetPropsCurrentTheme().bordercolor
            stroke.Thickness = 1
        end
    end)

    -- Initialize with default value
    Textbox:Set(Config.Default)

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
    -- Enhanced validation
    if not Config or type(Config) ~= "table" then
        warn("Toggle config must be a table")
        return nil
    end
    
    if not Config.Title or type(Config.Title) ~= "string" then
        warn("Toggle - Missing or invalid Title")
        return nil
    end
    
    local Library = self.Library
    Config.Description = Config.Description and tostring(Config.Description) or nil
    Config.Default = Config.Default ~= nil and Config.Default or false
    Config.IgnoreFirst = Config.IgnoreFirst ~= nil and Config.IgnoreFirst or false

    local Toggle = {
        Value = Config.Default,
        Callback = type(Config.Callback) == "function" and Config.Callback or function(Value) end,
        IgnoreFirst = Config.IgnoreFirst,
        Type = "Toggle",
        FirstUpdate = true,
    }

    if not self.Container then
        warn("Toggle container not found")
        return nil
    end

    local ToggleFrame = require(Components.element)("        " .. Config.Title, Config.Description, self.Container)
    if not ToggleFrame then
        warn("Failed to create toggle frame")
        return nil
    end

    -- Enhanced toggle box with better styling
    local box_frame = Create("Frame", {
        ThemeProps = {
            BackgroundColor3 = "togglebg",
        },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 16, 0, 16),
        Visible = true,
        Parent = ToggleFrame.topbox,
        BackgroundTransparency = 1,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 5),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "toggleborder",
            },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
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
            Size = UDim2.new(0, 12, 0, 12),
            Visible = true,
            ImageTransparency = Config.Default and 0 or 1,
        })
    })

    -- Enhanced set function with better animations
    function Toggle:Set(Value, ignore)
        if type(Value) ~= "boolean" then
            warn("Toggle value must be a boolean")
            return
        end
        
        self.Value = Value
        
        -- Enhanced animation with multiple properties
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        -- Background animation
        TweenService:Create(box_frame, tweenInfo, {
            BackgroundTransparency = self.Value and 0 or 1
        }):Play()
        
        -- Checkmark animation
        local checkmark = box_frame:FindFirstChild("ImageLabel")
        if checkmark then
            TweenService:Create(checkmark, tweenInfo, {
                ImageTransparency = self.Value and 0 or 1
            }):Play()
        end
        
        -- Border color animation
        local stroke = box_frame:FindFirstChild("UIStroke")
        if stroke then
            local borderColor = self.Value and Tools.GetPropsCurrentTheme().primarycolor or Tools.GetPropsCurrentTheme().toggleborder
            TweenService:Create(stroke, tweenInfo, {
                Color = borderColor
            }):Play()
        end
        
        -- Scale animation for feedback
        TweenService:Create(box_frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 18, 0, 18)
        }):Play()
        
        TweenService:Create(box_frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 16, 0, 16)
        }, 0.1):Play()
        
        -- Call callback with error handling
        if not ignore and (not self.IgnoreFirst or not self.FirstUpdate) then
            local success, error = pcall(function()
                return Library:Callback(Toggle.Callback, self.Value)
            end)
            
            if not success then
                warn("Toggle callback error: " .. tostring(error))
            end
        end
        
        self.FirstUpdate = false
    end

    -- Enhanced click handling with hover effects
    AddConnection(ToggleFrame.Frame.MouseEnter, function()
        TweenService:Create(box_frame, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 17, 0, 17)
        }):Play()
    end)
    
    AddConnection(ToggleFrame.Frame.MouseLeave, function()
        TweenService:Create(box_frame, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 16, 0, 16)
        }):Play()
    end)

    AddConnection(ToggleFrame.Frame.MouseButton1Click, function()
        Toggle:Set(not Toggle.Value)
    end)

    -- Initialize toggle
    Toggle:Set(Toggle.Value, Config.IgnoreFirst)

    if Library and Library.Flags then
        Library.Flags[Idx] = Toggle
    end
    
    return Toggle
end

return Element

end)() end,
    [17] = function()local wax,script,require=ImportGlobals(17)local ImportGlobals return (function(...)local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local tools = { Signals = {} }

-- Enhanced theme loading with error handling
local themes = {}
local success, themeResult = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Just3itx/3itx-UI-LIB/refs/heads/main/themes"))()
end)

if success and themeResult then
    themes = themeResult
else
    warn("Failed to load themes, using fallback: " .. tostring(themeResult))
    -- Fallback theme
    themes = {
        default = {
            maincolor = Color3.fromRGB(9, 9, 11),
            titlecolor = Color3.fromRGB(234, 234, 234),
            bordercolor = Color3.fromRGB(39, 39, 42),
            descriptioncolor = Color3.fromRGB(168, 168, 168),
            primarycolor = Color3.fromRGB(59, 130, 246),
        }
    }
end

local currentTheme = themes.default or themes[next(themes)]
local themedObjects = {}

-- Enhanced theme functions with validation
function tools.SetTheme(themeName)
    if not themeName or type(themeName) ~= "string" then
        warn("Theme name must be a string")
        return false
    end
    
    if themes[themeName] then
        currentTheme = themes[themeName]
        
        -- Update all themed objects
        for _, item in pairs(themedObjects) do
            if item.object and item.object.Parent then
                local obj = item.object
                local props = item.props
                for propName, themeKey in next, props do
                    if currentTheme[themeKey] then
                        local success, error = pcall(function()
                            obj[propName] = currentTheme[themeKey]
                        end)
                        if not success then
                            warn("Failed to apply theme property " .. propName .. ": " .. tostring(error))
                        end
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
    if not themeName or type(themeName) ~= "string" then
        warn("Theme name must be a string")
        return false
    end
    
    if not themeProps or type(themeProps) ~= "table" then
        warn("Theme properties must be a table")
        return false
    end
    
    themes[themeName] = themeProps
    return true
end

-- Enhanced mobile detection
function tools.isMobile()
    local success, result = pcall(function()
        return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
    end)
    
    if not success then
        warn("Failed to detect mobile: " .. tostring(result))
        return false
    end
    
    return result
end

-- Enhanced connection management
function tools.AddConnection(Signal, Function)
    if not Signal or type(Signal.Connect) ~= "function" then
        warn("Invalid signal provided to AddConnection")
        return nil
    end
    
    if not Function or type(Function) ~= "function" then
        warn("Invalid function provided to AddConnection")
        return nil
    end
    
    local success, connection = pcall(function()
        return Signal:Connect(Function)
    end)
    
    if success and connection then
        table.insert(tools.Signals, connection)
        return connection
    else
        warn("Failed to create connection: " .. tostring(connection))
        return nil
    end
end

-- Enhanced disconnect function
function tools.Disconnect()
    local disconnected = 0
    for key = #tools.Signals, 1, -1 do
        local Connection = table.remove(tools.Signals, key)
        if Connection and Connection.Connected then
            local success = pcall(function()
                Connection:Disconnect()
            end)
            if success then
                disconnected = disconnected + 1
            end
        end
    end
    return disconnected
end

-- Enhanced create function with better error handling
function tools.Create(Name, Properties, Children)
    if not Name or type(Name) ~= "string" then
        warn("Create requires a valid instance name")
        return nil
    end
    
    local success, Object = pcall(function()
        return Instance.new(Name)
    end)
    
    if not success then
        warn("Failed to create instance " .. Name .. ": " .. tostring(Object))
        return nil
    end

    -- Handle theme properties first
    if Properties and Properties.ThemeProps then
        for propName, themeKey in next, Properties.ThemeProps do
            if currentTheme[themeKey] then
                local propSuccess, propError = pcall(function()
                    Object[propName] = currentTheme[themeKey]
                end)
                if not propSuccess then
                    warn("Failed to set theme property " .. propName .. ": " .. tostring(propError))
                end
            end
        end
        table.insert(themedObjects, { object = Object, props = Properties.ThemeProps })
        Properties.ThemeProps = nil
    end

    -- Apply other properties
    if Properties then
        for i, v in next, Properties do
            local success, error = pcall(function()
                Object[i] = v
            end)
            if not success then
                warn("Failed to set property " .. tostring(i) .. ": " .. tostring(error))
            end
        end
    end
    
    -- Add children
    if Children then
        for i, v in next, Children do
            if v and typeof(v) == "Instance" then
                local success, error = pcall(function()
                    v.Parent = Object
                end)
                if not success then
                    warn("Failed to parent child: " .. tostring(error))
                end
            end
        end
    end
    
    return Object
end

-- Enhanced scroll animation with better performance
function tools.AddScrollAnim(scrollbar)
    if not scrollbar or not scrollbar:IsA("ScrollingFrame") then
        warn("AddScrollAnim requires a ScrollingFrame")
        return
    end
    
    local visibleTween = TweenService:Create(scrollbar, TweenInfo.new(0.25), { ScrollBarImageTransparency = 0 })
    local invisibleTween = TweenService:Create(scrollbar, TweenInfo.new(0.25), { ScrollBarImageTransparency = 1 })
    local lastInteraction = tick()
    local delayTime = 0.6
    local isVisible = false

    local function showScrollbar()
        if not isVisible then
            isVisible = true
            visibleTween:Play()
        end
    end

    local function hideScrollbar()
        if tick() - lastInteraction >= delayTime and isVisible then
            isVisible = false
            invisibleTween:Play()
        end
    end

    -- Enhanced event handling with error protection
    local connections = {}
    
    local function addConnection(signal, callback)
        local success, connection = pcall(function()
            return signal:Connect(callback)
        end)
        if success then
            table.insert(connections, connection)
            table.insert(tools.Signals, connection)
        end
    end

    addConnection(scrollbar.MouseEnter, function()
        lastInteraction = tick()
        showScrollbar()
    end)

    addConnection(scrollbar.MouseLeave, function()
        task.wait(delayTime)
        hideScrollbar()
    end)

    addConnection(scrollbar.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            lastInteraction = tick()
            showScrollbar()
        end
    end)

    addConnection(scrollbar:GetPropertyChangedSignal("CanvasPosition"), function()
        lastInteraction = tick()
        showScrollbar()
    end)

    addConnection(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            lastInteraction = tick()
            showScrollbar()
        end
    end)

    -- Enhanced render stepped with performance optimization
    local lastCheck = 0
    addConnection(RunService.RenderStepped, function()
        local now = tick()
        if now - lastCheck >= 0.1 then -- Check every 0.1 seconds instead of every frame
            lastCheck = now
            if now - lastInteraction >= delayTime then
                hideScrollbar()
            end
        end
    end)
    
    return connections
end

-- Enhanced cleanup function
function tools.Cleanup()
    local cleaned = 0
    
    -- Clean up themed objects
    for i = #themedObjects, 1, -1 do
        local item = themedObjects[i]
        if not item.object or not item.object.Parent then
            table.remove(themedObjects, i)
            cleaned = cleaned + 1
        end
    end
    
    -- Disconnect signals
    cleaned = cleaned + tools.Disconnect()
    
    return cleaned
end

return tools

end)() end
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
