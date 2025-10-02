-- Services
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Get LocalPlayer
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

-- Proximity threshold (default set to 10 studs)
local proximityThreshold = 10
local isFreezingEnabled = true
local isTouchFlingEnabled = false
local isPartFlingEnabled = false
local updateInterval = 0.05
local lastUpdateTime = 0

-- Part Fling Variables
local partFlingIntensity = 100
local partFlingConnections = {}
local activeFlingParts = {}

-- Table to store original states of BaseParts (including CanCollide)
local partStates = {}

-- Cache for RopeConstraints and their Touched connections
local ropeConstraints = {}
local touchConnections = {}

-- GUI State
local isMinimized = false

-- Function to reset physics properties of a part
local function resetPhysics(part)
	if part:IsA("BasePart") then
		part.Velocity = Vector3.new(0, 0, 0)
		part.RotVelocity = Vector3.new(0, 0, 0)
	end
end

-- Fling variables
local hiddenfling = false
local flingThread = nil

-- Function to perform fling (velocity manipulation)
local function performFling()
	local lp = Players.LocalPlayer
	local c, hrp, vel, movel = nil, nil, nil, 0.1

	while hiddenfling do
		RunService.Heartbeat:Wait()
		c = lp.Character
		hrp = c and c:FindFirstChild("HumanoidRootPart")

		if hrp then
			vel = hrp.Velocity
			hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
			RunService.RenderStepped:Wait()
			hrp.Velocity = vel
			RunService.Stepped:Wait()
			hrp.Velocity = vel + Vector3.new(0, movel, 0)
			movel = -movel
		end
	end
end

-- Function to start fling
local function startFling()
	if not hiddenfling then
		hiddenfling = true
		flingThread = coroutine.create(performFling)
		coroutine.resume(flingThread)
		warn("Fling started")
	end
end

-- Function to stop fling
local function stopFling()
	if hiddenfling then
		hiddenfling = false
		warn("Fling stopped")
	end
end

-- Function to check if a BasePart is excluded (in "Ziplines" with specific names or named "Slider")
local function isExcludedPart(part)
	local parent = part
	while parent and parent ~= Workspace do
		if parent.Name == "Ziplines" then
			local excludedNames = {"Start", "Finish", "StartModel", "FinishModel"}
			for _, name in ipairs(excludedNames) do
				if part.Name == name then
					return true
				end
			end
		end
		parent = parent.Parent
	end
	return part.Name == "Slider"
end

-- Enhanced function to apply fling force to parts based on distance only - no character proximity required
local function applyPartFling(part)
	if not part or not part:IsA("BasePart") or isExcludedPart(part) or (localPlayer.Character and part:IsDescendantOf(localPlayer.Character)) then
		return
	end

	if part.Anchored then
		return
	end

	-- Check if already flinging
	for _, flingData in pairs(partFlingConnections) do
		if flingData.part == part then
			return
		end
	end

	-- Save original states
	if not partStates[part] then
		partStates[part] = {
			Anchored = part.Anchored,
			CanCollide = part.CanCollide
		}
	end

	-- Disable collision immediately
	part.CanCollide = false

	-- Create BodyVelocity for fling force
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

	local initialFling = Vector3.new(
		(math.random() - 0.5) * partFlingIntensity * 2,
		math.abs(math.random() - 0.2) * partFlingIntensity * 1.5,
		(math.random() - 0.5) * partFlingIntensity * 2
	)
	bodyVelocity.Velocity = initialFling
	bodyVelocity.Parent = part

	-- Create BodyAngularVelocity for spinning
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

	local initialSpin = Vector3.new(
		(math.random() - 0.5) * 25,
		(math.random() - 0.5) * 25,
		(math.random() - 0.5) * 25
	)
	bodyAngularVelocity.AngularVelocity = initialSpin
	bodyAngularVelocity.Parent = part

	local flingConnection
	local startTime = tick()
	flingConnection = RunService.Heartbeat:Connect(function()
		if bodyVelocity and bodyVelocity.Parent and bodyAngularVelocity and bodyAngularVelocity.Parent then
			local currentTime = tick()
			local elapsed = currentTime - startTime

			local fastTime = elapsed * 12

			-- Random velocity component
			local randomFling = Vector3.new(
				(math.random() - 0.5) * partFlingIntensity * 4,
				math.abs(math.random() - 0.2) * partFlingIntensity * 3,
				(math.random() - 0.5) * partFlingIntensity * 4
			)

			-- Chaotic oscillation
			local chaosFling = Vector3.new(
				math.sin(fastTime * 5.7) * partFlingIntensity * 2,
				math.cos(fastTime * 4.3) * partFlingIntensity * 1.8,
				math.sin(fastTime * 6.1) * partFlingIntensity * 2
			)

			-- Additional wave motion
			local oscillation = Vector3.new(
				math.cos(fastTime * 3.2) * partFlingIntensity * 1.2,
				math.sin(fastTime * 7.8) * partFlingIntensity * 1.5,
				math.cos(fastTime * 4.9) * partFlingIntensity * 1.2
			)

			-- Combine all forces
			local finalVelocity = randomFling + chaosFling + oscillation
			bodyVelocity.Velocity = finalVelocity

			-- Dynamic spin intensity
			local spinIntensity = 35 + math.sin(fastTime * 2) * 15
			bodyAngularVelocity.AngularVelocity = Vector3.new(
				(math.random() - 0.5) * spinIntensity,
				(math.random() - 0.5) * spinIntensity,
				(math.random() - 0.5) * spinIntensity
			)
		else
			flingConnection:Disconnect()
			for i = #partFlingConnections, 1, -1 do
				local flingData = partFlingConnections[i]
				if flingData and flingData.part == part then
					table.remove(partFlingConnections, i)
					break
				end
			end
		end
	end)

	table.insert(partFlingConnections, {
		bodyVelocity = bodyVelocity,
		bodyAngularVelocity = bodyAngularVelocity,
		connection = flingConnection,
		part = part,
		startTime = startTime
	})

	activeFlingParts[part] = true

	warn(string.format("Applied automatic fling to part: %s (CanCollide: false)", part:GetFullName()))
end

-- Enhanced function to remove part fling from parts and restore CanCollide
local function removePartFling(part)
	if not part then return end

	for i = #partFlingConnections, 1, -1 do
		local flingData = partFlingConnections[i]
		if flingData and flingData.part == part then
			if flingData.bodyVelocity and flingData.bodyVelocity.Parent then
				flingData.bodyVelocity:Destroy()
			end
			if flingData.bodyAngularVelocity and flingData.bodyAngularVelocity.Parent then
				flingData.bodyAngularVelocity:Destroy()
			end
			if flingData.connection then
				flingData.connection:Disconnect()
			end
			table.remove(partFlingConnections, i)
		end
	end

	activeFlingParts[part] = nil

	if partStates[part] then
		part.CanCollide = partStates[part].CanCollide
	else
		part.CanCollide = true
	end

	resetPhysics(part)

	warn(string.format("Removed fling from part: %s (CanCollide restored)", part:GetFullName()))
end

-- Enhanced function to clear all part flings and restore CanCollide
local function clearAllPartFlings()
	for _, flingData in pairs(partFlingConnections) do
		if flingData then
			if flingData.bodyVelocity and flingData.bodyVelocity.Parent then
				flingData.bodyVelocity:Destroy()
			end
			if flingData.bodyAngularVelocity and flingData.bodyAngularVelocity.Parent then
				flingData.bodyAngularVelocity:Destroy()
			end
			if flingData.connection then
				flingData.connection:Disconnect()
			end
			if flingData.part then
				resetPhysics(flingData.part)
				if partStates[flingData.part] then
					flingData.part.CanCollide = partStates[flingData.part].CanCollide
				else
					flingData.part.CanCollide = true
				end
			end
		end
	end
	partFlingConnections = {}
	activeFlingParts = {}
	warn("Cleared all part flings, reset physics, and restored CanCollide states")
end

-- Function to apply fling to ALL rope parts automatically (no distance check)
local function applyFlingToNearbyParts()
	if not isPartFlingEnabled then
		return
	end

	local appliedCount = 0
	for _, rope in ipairs(ropeConstraints) do
		local att0 = rope.Attachment0
		local att1 = rope.Attachment1
		if att0 and att1 and att0.Parent and att1.Parent then
			local part0 = att0.Parent
			local part1 = att1.Parent

			-- Apply fling to all rope parts without distance check
			if part0:IsA("BasePart") and not part0:IsDescendantOf(localPlayer.Character) and not isExcludedPart(part0) and not part0.Anchored then
				if not activeFlingParts[part0] then
					applyPartFling(part0)
					appliedCount = appliedCount + 1
				end
			end

			if part1:IsA("BasePart") and not part1:IsDescendantOf(localPlayer.Character) and not isExcludedPart(part1) and not part1.Anchored then
				if not activeFlingParts[part1] then
					applyPartFling(part1)
					appliedCount = appliedCount + 1
				end
			end
		end
	end

	if appliedCount > 0 then
		warn(string.format("Applied fling to %d parts automatically (no distance check)", appliedCount))
	end
end

-- Function to apply effects to ALL rope parts automatically
local function updatePartState(rope)
	if not rope:IsA("RopeConstraint") then
		return
	end

	local att0 = rope.Attachment0
	local att1 = rope.Attachment1

	if not (att0 and att1 and att0.Parent and att1.Parent) then
		return
	end

	local part0 = att0.Parent
	local part1 = att1.Parent

	-- Apply freeze effect if enabled (to all rope parts)
	if isFreezingEnabled and not isPartFlingEnabled then
		if part0:IsA("BasePart") and not part0:IsDescendantOf(localPlayer.Character) then
			if not isExcludedPart(part0) then
				if not partStates[part0] then
					partStates[part0] = {
						Anchored = part0.Anchored,
						CanCollide = part0.CanCollide
					}
				end
				part0.Anchored = true
				resetPhysics(part0)
			end
		end

		if part1:IsA("BasePart") and not part1:IsDescendantOf(localPlayer.Character) then
			if not isExcludedPart(part1) then
				if not partStates[part1] then
					partStates[part1] = {
						Anchored = part1.Anchored,
						CanCollide = part1.CanCollide
					}
				end
				part1.Anchored = true
				resetPhysics(part1)
			end
		end
	end

	-- Apply part fling effect if enabled (to all rope parts automatically)
	if isPartFlingEnabled and not isFreezingEnabled then
		if part0:IsA("BasePart") and not part0:IsDescendantOf(localPlayer.Character) then
			if not isExcludedPart(part0) and not part0.Anchored and not activeFlingParts[part0] then
				applyPartFling(part0)
			end
		end

		if part1:IsA("BasePart") and not part1:IsDescendantOf(localPlayer.Character) then
			if not isExcludedPart(part1) and not part1.Anchored and not activeFlingParts[part1] then
				applyPartFling(part1)
			end
		end
	end
end

-- Function to setup touch detection for a part
local function setupTouchDetection(part)
	if not part:IsA("BasePart") or isExcludedPart(part) then
		return
	end

	part.CanCollide = true
	local connection = part.Touched:Connect(function(hit)
		if isTouchFlingEnabled then
			if hit.Name == "HumanoidRootPart" and hit.Parent == localPlayer.Character then
				warn(string.format("HumanoidRootPart touched %s", part:GetFullName()))
				startFling()
			end
		end
	end)
	table.insert(touchConnections, connection)
end

-- Function to cache RopeConstraints and setup touch detection
local function cacheRopeConstraints()
	for _, connection in pairs(touchConnections) do
		connection:Disconnect()
	end
	touchConnections = {}
	ropeConstraints = {}

	for _, rope in ipairs(Workspace:GetDescendants()) do
		if rope:IsA("RopeConstraint") then
			table.insert(ropeConstraints, rope)
			local att0 = rope.Attachment0
			local att1 = rope.Attachment1
			if att0 and att1 and att0.Parent and att1.Parent then
				local part0 = att0.Parent
				local part1 = att1.Parent

				setupTouchDetection(part0)
				setupTouchDetection(part1)
			else
				warn(string.format("Skipping RopeConstraint %s due to invalid attachments", rope:GetFullName()))
			end
		end
	end

	Workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("RopeConstraint") then
			table.insert(ropeConstraints, descendant)
			local att0 = descendant.Attachment0
			local att1 = descendant.Attachment1
			if att0 and att1 and att0.Parent and att1.Parent then
				local part0 = att0.Parent
				local part1 = att1.Parent

				setupTouchDetection(part0)
				setupTouchDetection(part1)
			else
				warn(string.format("Skipping new RopeConstraint %s due to invalid attachments", descendant:GetFullName()))
			end
		end
	end)

	Workspace.DescendantRemoving:Connect(function(descendant)
		if descendant:IsA("RopeConstraint") then
			for i, rope in ipairs(ropeConstraints) do
				if rope == descendant then
					table.remove(ropeConstraints, i)
					break
				end
			end
		end
	end)

	warn(string.format("Cached %d RopeConstraints", #ropeConstraints))
end

-- Update all RopeConstraints automatically (no distance check)
local function updateRopeConstraints()
	if not localPlayer.Character or localPlayer.Character ~= character then
		character = localPlayer.Character
		humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	end

	local currentTime = tick()
	if currentTime - lastUpdateTime < updateInterval then
		return
	end
	lastUpdateTime = currentTime

	-- Process ALL ropes automatically, no distance check
	for _, rope in ipairs(ropeConstraints) do
		updatePartState(rope)
	end
end

-- Create Enhanced GUI with Mobile Support and Minimize Feature
local function createGui()
	if localPlayer.PlayerGui:FindFirstChild("RopeConstraintGui") then
		localPlayer.PlayerGui.RopeConstraintGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RopeConstraintGui"
	screenGui.Parent = localPlayer.PlayerGui
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Main Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 280, 0, 420)
	mainFrame.Position = UDim2.new(0, 20, 0.5, -210)
	mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = mainFrame

	-- Shadow effect
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 30, 1, 30)
	shadow.Position = UDim2.new(0, -15, 0, -15)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxasset://textures/ui/Controls/shadow.png"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.ZIndex = 0
	shadow.Parent = mainFrame

	-- Header Frame
	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "Header"
	headerFrame.Size = UDim2.new(1, 0, 0, 45)
	headerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	headerFrame.BorderSizePixel = 0
	headerFrame.Parent = mainFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = headerFrame

	-- Fix header corner at bottom
	local headerBottom = Instance.new("Frame")
	headerBottom.Size = UDim2.new(1, 0, 0, 12)
	headerBottom.Position = UDim2.new(0, 0, 1, -12)
	headerBottom.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	headerBottom.BorderSizePixel = 0
	headerBottom.Parent = headerFrame

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Position = UDim2.new(0, 15, 0, 0)
	titleLabel.Text = "Rope Controller"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = headerFrame

	-- Version label
	local versionLabel = Instance.new("TextLabel")
	versionLabel.Size = UDim2.new(0, 80, 0, 18)
	versionLabel.Position = UDim2.new(0, 15, 0, 24)
	versionLabel.Text = "v2.2 AUTO"
	versionLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
	versionLabel.BackgroundTransparency = 1
	versionLabel.Font = Enum.Font.Gotham
	versionLabel.TextSize = 11
	versionLabel.TextXAlignment = Enum.TextXAlignment.Left
	versionLabel.Parent = headerFrame

	-- Minimize Button
	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.Size = UDim2.new(0, 35, 0, 35)
	minimizeButton.Position = UDim2.new(1, -42, 0, 5)
	minimizeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	minimizeButton.Text = "−"
	minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeButton.Font = Enum.Font.GothamBold
	minimizeButton.TextSize = 24
	minimizeButton.Parent = headerFrame

	local minimizeCorner = Instance.new("UICorner")
	minimizeCorner.CornerRadius = UDim.new(0, 8)
	minimizeCorner.Parent = minimizeButton

	-- Content Frame (scrollable)
	local contentFrame = Instance.new("ScrollingFrame")
	contentFrame.Name = "Content"
	contentFrame.Size = UDim2.new(1, -20, 1, -60)
	contentFrame.Position = UDim2.new(0, 10, 0, 50)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ScrollBarThickness = 4
	contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	contentFrame.BorderSizePixel = 0
	contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentFrame.Parent = mainFrame

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 10)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = contentFrame

	-- Function to create styled button
	local function createStyledButton(name, text, layoutOrder, color)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = UDim2.new(1, 0, 0, 40)
		button.BackgroundColor3 = color
		button.Text = ""
		button.LayoutOrder = layoutOrder
		button.Parent = contentFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -15, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Font = Enum.Font.GothamSemibold
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = button

		return button, label
	end

	-- Function to create input field
	local function createInputField(name, labelText, defaultValue, layoutOrder)
		local container = Instance.new("Frame")
		container.Name = name .. "Container"
		container.Size = UDim2.new(1, 0, 0, 70)
		container.BackgroundTransparency = 1
		container.LayoutOrder = layoutOrder
		container.Parent = contentFrame

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 0, 20)
		label.BackgroundTransparency = 1
		label.Text = labelText
		label.TextColor3 = Color3.fromRGB(200, 200, 220)
		label.Font = Enum.Font.Gotham
		label.TextSize = 13
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = container

		local inputFrame = Instance.new("Frame")
		inputFrame.Size = UDim2.new(1, 0, 0, 40)
		inputFrame.Position = UDim2.new(0, 0, 0, 25)
		inputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
		inputFrame.BorderSizePixel = 0
		inputFrame.Parent = container

		local inputCorner = Instance.new("UICorner")
		inputCorner.CornerRadius = UDim.new(0, 8)
		inputCorner.Parent = inputFrame

		local textBox = Instance.new("TextBox")
		textBox.Name = name
		textBox.Size = UDim2.new(1, -20, 1, 0)
		textBox.Position = UDim2.new(0, 10, 0, 0)
		textBox.BackgroundTransparency = 1
		textBox.Text = tostring(defaultValue)
		textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		textBox.Font = Enum.Font.Gotham
		textBox.TextSize = 14
		textBox.TextXAlignment = Enum.TextXAlignment.Left
		textBox.ClearTextOnFocus = false
		textBox.Parent = inputFrame

		return textBox
	end

	-- Create Buttons
	local freezeButton, freezeLabel = createStyledButton(
		"FreezeButton",
		"Freeze: Enabled",
		1,
		Color3.fromRGB(40, 180, 80)
	)

	local touchFlingButton, touchFlingLabel = createStyledButton(
		"TouchFlingButton",
		"Touch Fling: OFF",
		2,
		Color3.fromRGB(60, 60, 75)
	)

	local partFlingButton, partFlingLabel = createStyledButton(
		"PartFlingButton",
		"Part Fling: OFF",
		3,
		Color3.fromRGB(60, 60, 75)
	)

	local forceApplyButton, forceApplyLabel = createStyledButton(
		"ForceApplyButton",
		"Force Apply Fling Now",
		4,
		Color3.fromRGB(255, 140, 0)
	)

	-- Create Input Fields
	local flingIntensityInput = createInputField(
		"FlingIntensityInput",
		"Fling Intensity (10-1000)",
		partFlingIntensity,
		5
	)

	local distanceInput = createInputField(
		"DistanceInput",
		"Detection Distance (5-5000)",
		proximityThreshold,
		6
	)

	-- Status Label
	local statusContainer = Instance.new("Frame")
	statusContainer.Size = UDim2.new(1, 0, 0, 50)
	statusContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	statusContainer.BorderSizePixel = 0
	statusContainer.LayoutOrder = 7
	statusContainer.Parent = contentFrame

	local statusCorner = Instance.new("UICorner")
	statusCorner.CornerRadius = UDim.new(0, 8)
	statusCorner.Parent = statusContainer

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -20, 1, 0)
	statusLabel.Position = UDim2.new(0, 10, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Active Flings: 0"
	statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 14
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = statusContainer

	-- Update status label periodically
	spawn(function()
		while statusLabel and statusLabel.Parent do
			wait(0.5)
			if statusLabel then
				statusLabel.Text = string.format("Active Flings: %d | Ropes: %d", #partFlingConnections, #ropeConstraints)
			end
		end
	end)

	-- Minimize functionality with animation
	local function toggleMinimize()
		isMinimized = not isMinimized

		local targetSize = isMinimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 420)
		local targetText = isMinimized and "+" or "−"

		local tween = TweenService:Create(
			mainFrame,
			TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{Size = targetSize}
		)
		tween:Play()

		minimizeButton.Text = targetText
		contentFrame.Visible = not isMinimized
	end

	minimizeButton.MouseButton1Click:Connect(toggleMinimize)

	-- Drag functionality (Mobile + PC Support)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	local function updateDrag(input)
		if dragging then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end

	headerFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)

	headerFrame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateDrag(input)
		end
	end)

	-- Button hover effects
	local function addHoverEffect(button)
		button.MouseEnter:Connect(function()
			local tween = TweenService:Create(
				button,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundColor3 = Color3.fromRGB(
					math.min(button.BackgroundColor3.R * 255 + 20, 255),
					math.min(button.BackgroundColor3.G * 255 + 20, 255),
					math.min(button.BackgroundColor3.B * 255 + 20, 255)
				)}
			)
			tween:Play()
		end)

		button.MouseLeave:Connect(function()
			local originalColor = button.BackgroundColor3
			local tween = TweenService:Create(
				button,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundColor3 = originalColor}
			)
			tween:Play()
		end)
	end

	addHoverEffect(freezeButton)
	addHoverEffect(touchFlingButton)
	addHoverEffect(partFlingButton)
	addHoverEffect(forceApplyButton)
	addHoverEffect(minimizeButton)

	-- Freeze toggle functionality
	freezeButton.MouseButton1Click:Connect(function()
		isFreezingEnabled = not isFreezingEnabled
		freezeLabel.Text = isFreezingEnabled and "Freeze: Enabled" or "Freeze: Disabled"
		freezeButton.BackgroundColor3 = isFreezingEnabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)

		if isFreezingEnabled and isPartFlingEnabled then
			isPartFlingEnabled = false
			partFlingLabel.Text = "Part Fling: OFF"
			partFlingButton.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
			clearAllPartFlings()
		end

		if not isFreezingEnabled then
			for part, state in pairs(partStates) do
				if part:IsA("BasePart") and not part:IsDescendantOf(localPlayer.Character) then
					part.Anchored = state.Anchored
					if not activeFlingParts[part] then
						part.CanCollide = state.CanCollide
						partStates[part] = nil
					end
				end
			end
		end
	end)

	-- Touch fling toggle functionality
	touchFlingButton.MouseButton1Click:Connect(function()
		isTouchFlingEnabled = not isTouchFlingEnabled
		touchFlingLabel.Text = isTouchFlingEnabled and "Touch Fling: ON" or "Touch Fling: OFF"
		touchFlingButton.BackgroundColor3 = isTouchFlingEnabled and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(60, 60, 75)
		warn("Touch Fling toggled to: " .. tostring(isTouchFlingEnabled))

		if not isTouchFlingEnabled then
			stopFling()
		end

		cacheRopeConstraints()
	end)

	-- Part Fling toggle functionality
	partFlingButton.MouseButton1Click:Connect(function()
		isPartFlingEnabled = not isPartFlingEnabled
		partFlingLabel.Text = isPartFlingEnabled and "Part Fling: ON" or "Part Fling: OFF"
		partFlingButton.BackgroundColor3 = isPartFlingEnabled and Color3.fromRGB(255, 100, 50) or Color3.fromRGB(60, 60, 75)

		if isPartFlingEnabled and isFreezingEnabled then
			isFreezingEnabled = false
			freezeLabel.Text = "Freeze: Disabled"
			freezeButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
			for part, state in pairs(partStates) do
				if part:IsA("BasePart") and not part:IsDescendantOf(localPlayer.Character) then
					part.Anchored = state.Anchored
					part.CanCollide = state.CanCollide
					partStates[part] = nil
				end
			end
		end

		warn("Part Fling toggled to: " .. tostring(isPartFlingEnabled) .. " (Automatic activation on ALL rope parts)")

		if isPartFlingEnabled then
			task.spawn(function()
				wait(0.1)
				applyFlingToNearbyParts()
			end)
		else
			clearAllPartFlings()
		end
	end)

	-- Force Apply Button functionality
	forceApplyButton.MouseButton1Click:Connect(function()
		if isPartFlingEnabled then
			clearAllPartFlings()
			wait(0.1)
			applyFlingToNearbyParts()
			warn("Force applied fling to ALL rope parts automatically")
		else
			warn("Part Fling is disabled - enable it first")
		end
	end)

	-- Fling intensity input functionality
	flingIntensityInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local input = tonumber(flingIntensityInput.Text)
			if input then
				partFlingIntensity = math.clamp(math.floor(input), 10, 1000)
				flingIntensityInput.Text = tostring(partFlingIntensity)
				warn("Fling intensity updated to: " .. partFlingIntensity)
			else
				flingIntensityInput.Text = tostring(partFlingIntensity)
			end
		end
	end)

	-- Distance input functionality
	distanceInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			local input = tonumber(distanceInput.Text)
			if input then
				proximityThreshold = math.clamp(math.floor(input), 5, 5000)
				distanceInput.Text = tostring(proximityThreshold)
				warn("Distance threshold updated to: " .. proximityThreshold)
			else
				distanceInput.Text = tostring(proximityThreshold)
			end
		end
	end)
end

-- Initial setup
if humanoidRootPart then
	cacheRopeConstraints()
	createGui()
	updateRopeConstraints()
end

-- Enhanced continuous update using RenderStepped with better performance
local connection
connection = RunService.RenderStepped:Connect(function()
	updateRopeConstraints()
end)

-- Handle character respawn
localPlayer.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")

	stopFling()
	clearAllPartFlings()

	cacheRopeConstraints()
	createGui()
	if connection then
		connection:Disconnect()
	end
	connection = RunService.RenderStepped:Connect(function()
		updateRopeConstraints()
	end)

	warn("Character respawned - Rope Controller reinitialized with automatic fling system")
end)
