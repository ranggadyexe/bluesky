local Bluesky = {}

Bluesky.Version = "0.9.1"
Bluesky.Icons = {}
Bluesky.DebugWarnings = true
Bluesky.MissingIconWarnings = {}
Bluesky.FallbackIcon = "?"
Bluesky.IconLibraryUrl = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua"
Bluesky.RemoteIconsEnabled = true
Bluesky.SecureMode = false
Bluesky.RayfieldIcons = nil
Bluesky.RayfieldIconsLoaded = false
Bluesky.IconPresets = {
	LucideLite = {
		Meta = {
			Set = "Lucide",
			License = "ISC",
			Website = "https://lucide.dev",
			Notes = "Lightweight text fallback. Full Rayfield Lucide support loads from Rayfield icons.lua when available.",
		},
		Icons = {
			Activity = "A",
			activity = "A",
			Bell = "B",
			bell = "B",
			Calendar = "C",
			calendar = "C",
			ChevronDown = "v",
			["chevron-down"] = "v",
			ChevronRight = ">",
			["chevron-right"] = ">",
			Home = "H",
			home = "H",
			House = "H",
			house = "H",
			Search = "S",
			search = "S",
			Settings = "G",
			settings = "G",
			User = "U",
			user = "U",
			Info = "I",
			info = "I",
			Warning = "!",
			warning = "!",
			["alert-circle"] = "!",
			Check = "OK",
			check = "OK",
			["check-circle"] = "OK",
			Close = "X",
			close = "X",
			x = "X",
			Trash = "T",
			trash = "T",
			["trash-2"] = "T",
			Menu = "=",
			menu = "=",
			Save = "S",
			save = "S",
			Refresh = "R",
			refresh = "R",
			["rotate-cw"] = "R",
			Plus = "+",
			plus = "+",
			Minus = "-",
			minus = "-",
			Maximize = "[]",
			maximize = "[]",
			["maximize-2"] = "[]",
			Minimize = "_",
			minimize = "_",
			["minimize-2"] = "_",
			Palette = "P",
			palette = "P",
			Shield = "#",
			shield = "#",
			Zap = "Z",
			zap = "Z",
		},
	},
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

local DEFAULT_THEME = {
	Background = Color3.fromRGB(15, 18, 24),
	Surface = Color3.fromRGB(22, 27, 36),
	SurfaceAlt = Color3.fromRGB(28, 34, 45),
	Item = Color3.fromRGB(31, 38, 50),
	ItemHover = Color3.fromRGB(38, 47, 62),
	Stroke = Color3.fromRGB(54, 66, 84),
	Text = Color3.fromRGB(238, 244, 250),
	SubText = Color3.fromRGB(154, 168, 186),
	Accent = Color3.fromRGB(63, 166, 255),
	AccentDark = Color3.fromRGB(27, 94, 153),
	Danger = Color3.fromRGB(255, 94, 94),
	Success = Color3.fromRGB(64, 213, 140),
	Shadow = Color3.fromRGB(0, 0, 0),
}

Bluesky.Themes = {
	Bluesky = DEFAULT_THEME,
	Dark = {
		Background = Color3.fromRGB(12, 13, 17),
		Surface = Color3.fromRGB(20, 22, 28),
		SurfaceAlt = Color3.fromRGB(27, 30, 38),
		Item = Color3.fromRGB(30, 34, 43),
		ItemHover = Color3.fromRGB(39, 44, 56),
		Stroke = Color3.fromRGB(55, 61, 74),
		Text = Color3.fromRGB(240, 242, 246),
		SubText = Color3.fromRGB(158, 166, 181),
		Accent = Color3.fromRGB(92, 177, 255),
		AccentDark = Color3.fromRGB(35, 102, 168),
		Danger = Color3.fromRGB(255, 94, 94),
		Success = Color3.fromRGB(64, 213, 140),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Light = {
		Background = Color3.fromRGB(239, 244, 249),
		Surface = Color3.fromRGB(250, 252, 255),
		SurfaceAlt = Color3.fromRGB(229, 236, 244),
		Item = Color3.fromRGB(255, 255, 255),
		ItemHover = Color3.fromRGB(235, 243, 252),
		Stroke = Color3.fromRGB(195, 207, 222),
		Text = Color3.fromRGB(25, 32, 43),
		SubText = Color3.fromRGB(91, 104, 121),
		Accent = Color3.fromRGB(35, 136, 230),
		AccentDark = Color3.fromRGB(22, 104, 185),
		Danger = Color3.fromRGB(220, 62, 62),
		Success = Color3.fromRGB(32, 151, 94),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Midnight = {
		Background = Color3.fromRGB(9, 10, 15),
		Surface = Color3.fromRGB(15, 17, 26),
		SurfaceAlt = Color3.fromRGB(20, 23, 34),
		Item = Color3.fromRGB(24, 28, 41),
		ItemHover = Color3.fromRGB(32, 37, 54),
		Stroke = Color3.fromRGB(45, 52, 75),
		Text = Color3.fromRGB(230, 235, 245),
		SubText = Color3.fromRGB(140, 150, 180),
		Accent = Color3.fromRGB(100, 140, 255),
		AccentDark = Color3.fromRGB(50, 70, 180),
		Danger = Color3.fromRGB(255, 80, 80),
		Success = Color3.fromRGB(80, 255, 150),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Emerald = {
		Background = Color3.fromRGB(10, 15, 12),
		Surface = Color3.fromRGB(16, 24, 20),
		SurfaceAlt = Color3.fromRGB(22, 33, 28),
		Item = Color3.fromRGB(26, 38, 32),
		ItemHover = Color3.fromRGB(35, 51, 43),
		Stroke = Color3.fromRGB(48, 71, 60),
		Text = Color3.fromRGB(230, 245, 235),
		SubText = Color3.fromRGB(140, 180, 160),
		Accent = Color3.fromRGB(46, 213, 115),
		AccentDark = Color3.fromRGB(30, 140, 75),
		Danger = Color3.fromRGB(255, 80, 80),
		Success = Color3.fromRGB(80, 255, 150),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Amethyst = {
		Background = Color3.fromRGB(13, 10, 18),
		Surface = Color3.fromRGB(20, 16, 28),
		SurfaceAlt = Color3.fromRGB(28, 22, 39),
		Item = Color3.fromRGB(33, 26, 46),
		ItemHover = Color3.fromRGB(44, 35, 61),
		Stroke = Color3.fromRGB(61, 48, 84),
		Text = Color3.fromRGB(240, 230, 255),
		SubText = Color3.fromRGB(160, 140, 190),
		Accent = Color3.fromRGB(165, 94, 255),
		AccentDark = Color3.fromRGB(100, 50, 180),
		Danger = Color3.fromRGB(255, 80, 80),
		Success = Color3.fromRGB(80, 255, 150),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Rose = {
		Background = Color3.fromRGB(18, 12, 14),
		Surface = Color3.fromRGB(28, 19, 22),
		SurfaceAlt = Color3.fromRGB(38, 26, 30),
		Item = Color3.fromRGB(45, 30, 35),
		ItemHover = Color3.fromRGB(56, 38, 44),
		Stroke = Color3.fromRGB(84, 57, 66),
		Text = Color3.fromRGB(255, 235, 240),
		SubText = Color3.fromRGB(200, 160, 170),
		Accent = Color3.fromRGB(255, 107, 129),
		AccentDark = Color3.fromRGB(180, 70, 90),
		Danger = Color3.fromRGB(255, 80, 80),
		Success = Color3.fromRGB(80, 255, 150),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Amber = {
		Background = Color3.fromRGB(15, 12, 10),
		Surface = Color3.fromRGB(24, 19, 16),
		SurfaceAlt = Color3.fromRGB(33, 26, 22),
		Item = Color3.fromRGB(38, 30, 26),
		ItemHover = Color3.fromRGB(51, 40, 35),
		Stroke = Color3.fromRGB(71, 56, 48),
		Text = Color3.fromRGB(255, 245, 230),
		SubText = Color3.fromRGB(190, 170, 140),
		Accent = Color3.fromRGB(255, 159, 67),
		AccentDark = Color3.fromRGB(180, 110, 45),
		Danger = Color3.fromRGB(255, 80, 80),
		Success = Color3.fromRGB(80, 255, 150),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
}

local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MEDIUM = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_OPEN = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_PRESS = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local WindowMethods = {}
local HostMethods = {}

local function devWarn(message)
	if Bluesky.DebugWarnings then
		warn("[Bluesky UI] " .. tostring(message))
	end
end

local function ensureType(value, expected, name, fallback)
	if value == nil then
		return fallback
	end

	if typeof(value) ~= expected then
		devWarn(("invalid '%s': expected %s, got %s"):format(name, expected, typeof(value)))
		return fallback
	end

	return value
end

local function canReadFs()
	return type(readfile) == "function"
		and type(isfile) == "function"
end

local function canWriteFs()
	return type(writefile) == "function"
		and type(makefolder) == "function"
end

local function canListFs()
	return type(listfiles) == "function"
end

local function canDeleteFs()
	return type(delfile) == "function" or type(deletefile) == "function"
end

local function ensureFolder(folder)
	if type(folder) ~= "string" or folder == "" or not canWriteFs() then
		return
	end

	if type(isfolder) == "function" then
		local ok, exists = pcall(function()
			return isfolder(folder)
		end)
		if ok and exists then
			return
		end
	end

	pcall(function()
		makefolder(folder)
	end)
end

local function encodeValue(value)
	local valueType = typeof(value)

	if valueType == "EnumItem" then
		return {
			__type = "EnumItem",
			enum = tostring(value.EnumType),
			name = value.Name,
		}
	end

	if valueType == "Color3" then
		return {
			__type = "Color3",
			r = value.R,
			g = value.G,
			b = value.B,
		}
	end

	if valueType == "UDim" then
		return {
			__type = "UDim",
			scale = value.Scale,
			offset = value.Offset,
		}
	end

	if valueType == "UDim2" then
		return {
			__type = "UDim2",
			x = encodeValue(value.X),
			y = encodeValue(value.Y),
		}
	end

	if valueType == "boolean" or valueType == "number" or valueType == "string" then
		return value
	end

	if valueType == "table" then
		local encoded = {}
		for key, item in pairs(value) do
			encoded[key] = encodeValue(item)
		end
		return encoded
	end

	return tostring(value)
end

local function decodeValue(value)
	if type(value) ~= "table" then
		return value
	end

	if value.__type == "EnumItem" and value.enum == "Enum.KeyCode" and type(value.name) == "string" then
		return Enum.KeyCode[value.name] or Enum.KeyCode.Unknown
	end

	if value.__type == "Color3" then
		return Color3.new(tonumber(value.r) or 1, tonumber(value.g) or 1, tonumber(value.b) or 1)
	end

	if value.__type == "UDim" then
		return UDim.new(tonumber(value.scale) or 0, tonumber(value.offset) or 0)
	end

	if value.__type == "UDim2" then
		local x = decodeValue(value.x)
		local y = decodeValue(value.y)
		if typeof(x) ~= "UDim" then
			x = UDim.new()
		end
		if typeof(y) ~= "UDim" then
			y = UDim.new()
		end
		return UDim2.new(x.Scale, x.Offset, y.Scale, y.Offset)
	end

	local decoded = {}
	for key, item in pairs(value) do
		decoded[key] = decodeValue(item)
	end
	return decoded
end

local function cloneValue(value)
	if type(value) ~= "table" then
		return value
	end

	local cloned = {}
	for key, item in pairs(value) do
		cloned[key] = cloneValue(item)
	end
	return cloned
end

local function copyTheme(overrides)
	local theme = {}
	local source = DEFAULT_THEME

	if type(overrides) == "string" then
		source = Bluesky.Themes[overrides] or DEFAULT_THEME
		overrides = nil
	elseif type(overrides) == "table" and type(overrides.Preset) == "string" then
		source = Bluesky.Themes[overrides.Preset] or DEFAULT_THEME
	end

	for key, value in pairs(source) do
		theme[key] = value
	end

	for key, value in pairs(overrides or {}) do
		if key ~= "Preset" then
			theme[key] = value
		end
	end

	return theme
end

local function create(className, props, children)
	local instance = Instance.new(className)

	for key, value in pairs(props or {}) do
		instance[key] = value
	end

	for _, child in ipairs(children or {}) do
		child.Parent = instance
	end

	return instance
end

local function corner(parent, radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius),
		Parent = parent,
	})
end

local function stroke(parent, color, transparency, thickness)
	return create("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function padding(parent, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or left or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or top or 0),
		Parent = parent,
	})
end

local function list(parent, direction, paddingPixels, verticalAlignment, horizontalAlignment)
	local layout = create("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, paddingPixels or 8),
		Parent = parent,
	})

	if verticalAlignment then
		layout.VerticalAlignment = verticalAlignment
	end

	if horizontalAlignment then
		layout.HorizontalAlignment = horizontalAlignment
	end

	return layout
end

local function tween(instance, tweenInfo, props)
	local animation = TweenService:Create(instance, tweenInfo or TWEEN_FAST, props)
	animation:Play()
	return animation
end

local function addScale(parent, value)
	return create("UIScale", {
		Scale = value or 1,
		Parent = parent,
	})
end

local function pressScale(scale)
	if not scale or not scale.Parent then
		return
	end

	tween(scale, TWEEN_PRESS, {
		Scale = 0.97,
	})

	task.delay(0.08, function()
		if scale.Parent then
			tween(scale, TWEEN_OPEN, {
				Scale = 1,
			})
		end
	end)
end

local function safeCall(callback, ...)
	if type(callback) ~= "function" then
		return
	end

	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[Bluesky UI] callback error:", err)
	end
end

local function normalizeOptions(options, defaultName)
	if type(options) == "string" then
		return {
			Name = options,
		}
	end

	options = options or {}
	options.Name = options.Name or options.Title or defaultName
	return options
end

local function searchText(value)
	return string.lower(tostring(value or ""))
end

local function trimLower(value)
	return string.match(string.lower(tostring(value or "")), "^%s*(.-)%s*$")
end

local function readGlobalFlag(name)
	local ok, value = pcall(function()
		if getgenv then
			return getgenv()[name]
		end

		return _G[name]
	end)

	if ok then
		return value
	end

	return nil
end

local function getViewportSize()
	local camera = workspace and workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end

	return Vector2.new(640, 480)
end

local function normalizeDensity(value)
	if type(value) == "string" then
		local normalized = string.lower(value)
		if normalized == "compact" or normalized == "dense" then
			return "Compact"
		end
	end

	return "Comfortable"
end

local function getDensityMetrics(density, isMobile)
	local compact = density == "Compact"
	return {
		ButtonHeight = compact and 38 or 42,
		ToggleHeight = compact and 42 or 46,
		InputHeight = compact and 30 or 34,
		InputBaseHeight = compact and 70 or 78,
		InputDescriptionHeight = compact and 88 or 96,
		DropdownHeight = compact and 40 or 44,
		DropdownOptionHeight = compact and 30 or 32,
		TabHeight = isMobile and 42 or (compact and 34 or 36),
		TabTopHeight = isMobile and 40 or (compact and 32 or 34),
		PagePadding = isMobile and 12 or (compact and 12 or 16),
		SectionPadding = compact and 8 or 10,
	}
end

local function pointInGui(instance, position)
	if not instance or not instance.Parent or not position then
		return false
	end

	local absolutePosition = instance.AbsolutePosition
	local absoluteSize = instance.AbsoluteSize
	return position.X >= absolutePosition.X
		and position.Y >= absolutePosition.Y
		and position.X <= absolutePosition.X + absoluteSize.X
		and position.Y <= absolutePosition.Y + absoluteSize.Y
end

local function getGuiParent()
	local ok, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)

	if ok and coreGui then
		return coreGui
	end

	if LocalPlayer then
		local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if playerGui then
			return playerGui
		end
	end

	return game:GetService("StarterGui")
end

local function getProtectedParent(gui)
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		end
	end)

	local parent = nil
	pcall(function()
		if gethui then
			parent = gethui()
		end
	end)

	return parent
end

local function formatAssetId(source)
	if source == 0 then
		return nil
	end

	if type(source) == "number" then
		return "rbxassetid://" .. tostring(source)
	end

	if type(source) ~= "string" then
		return nil
	end

	if source:match("^rbxassetid://") or source:match("^rbxthumb://") or source:match("^rbxasset://") then
		return source
	end

	if source:match("^%d+$") then
		return "rbxassetid://" .. source
	end

	return nil
end

local function isDetectableAsset(source)
	if type(source) == "number" then
		return true
	end

	if type(source) ~= "string" then
		return false
	end

	return source:match("^%d+$") ~= nil
		or source:match("^rbxassetid://") ~= nil
		or source:match("^rbxthumb://") ~= nil
end

local function isInputStart(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function parseKeyCode(value)
	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		return value
	end

	if type(value) == "string" then
		return Enum.KeyCode[value] or Enum.KeyCode[string.upper(value)] or Enum.KeyCode.Unknown
	end

	return value
end

local function roundToStep(value, step)
	step = tonumber(step) or 1
	if step <= 0 then
		return value
	end

	return math.floor((value / step) + 0.5) * step
end

local function getIcon(name)
	local res = Bluesky:_resolveIcon(name)
	if res and res.Kind == "text" then
		return res.Value
	end

	return "OK"
end

local function makeText(parent, text, size, color, props)
	props = props or {}
	props.BackgroundTransparency = 1
	props.Text = text or ""
	props.TextColor3 = color
	props.TextSize = size
	props.Font = props.Font or Enum.Font.Gotham
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	props.Parent = parent

	return create("TextLabel", props)
end

local function themeValue(window, value)
	if type(value) == "string" and window.Theme[value] ~= nil then
		return window.Theme[value]
	end

	return value
end

local function trackConnection(owner, connection)
	if type(owner) ~= "table" or not connection then
		return connection
	end

	owner._connections = owner._connections or {}
	table.insert(owner._connections, connection)
	return connection
end

local function disconnectConnections(connections)
	if type(connections) ~= "table" then
		return
	end

	for _, connection in ipairs(connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(connections)
end

local function createMaid()
	local maid = {
		_connections = {},
		_tasks = {},
	}

	function maid:Give(taskItem)
		if taskItem == nil then
			return taskItem
		end

		if typeof(taskItem) == "RBXScriptConnection" then
			table.insert(self._connections, taskItem)
		elseif type(taskItem) == "function" then
			table.insert(self._tasks, taskItem)
		elseif typeof(taskItem) == "Instance" then
			table.insert(self._tasks, function()
				if taskItem.Parent then
					taskItem:Destroy()
				end
			end)
		elseif type(taskItem) == "table" and type(taskItem.Destroy) == "function" then
			table.insert(self._tasks, function()
				taskItem:Destroy()
			end)
		elseif type(taskItem) == "table" and type(taskItem.Disconnect) == "function" then
			table.insert(self._tasks, function()
				taskItem:Disconnect()
			end)
		end

		return taskItem
	end

	function maid:Cleanup()
		disconnectConnections(self._connections)
		for _, taskItem in ipairs(self._tasks) do
			pcall(taskItem)
		end
		table.clear(self._tasks)
	end

	return maid
end

local function connectScoped(window, owner, signal, callback)
	local connection = window:_connect(signal, callback)
	return trackConnection(owner, connection)
end

local function setButtonHover(window, button, normalColor, hoverColor, owner)
	connectScoped(window, owner, button.MouseEnter, function()
		tween(button, TWEEN_FAST, {
			BackgroundColor3 = themeValue(window, hoverColor),
		})
	end)

	connectScoped(window, owner, button.MouseLeave, function()
		tween(button, TWEEN_FAST, {
			BackgroundColor3 = themeValue(window, normalColor),
		})
	end)
end

local function setControlDisabledVisual(instance, disabled)
	if not instance then
		return
	end

	pcall(function()
		instance.Active = disabled ~= true
	end)

	local transparency = disabled and 0.45 or 0
	for _, descendant in ipairs(instance:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			descendant.TextTransparency = transparency
		elseif descendant:IsA("ImageLabel") then
			descendant.ImageTransparency = transparency
		end
	end
end

local function attachControlBase(control, instance)
	control.Instance = control.Instance or instance
	control.Disabled = control.Disabled == true
	setControlDisabledVisual(instance, control.Disabled)
	local originalDestroy = control.Destroy
	local originalSetVisible = control.SetVisible
	local originalSetDisabled = control.SetDisabled
	local originalGet = control.Get
	local originalSetCallback = control.SetCallback

	function control:SetVisible(visible)
		if type(originalSetVisible) == "function" then
			return originalSetVisible(self, visible)
		end

		if instance then
			instance.Visible = visible ~= false
		end
		return self
	end

	function control:SetDisabled(disabled)
		if type(originalSetDisabled) == "function" then
			return originalSetDisabled(self, disabled)
		end

		self.Disabled = disabled == true
		setControlDisabledVisual(instance, self.Disabled)
		return self
	end

	function control:Get()
		if type(originalGet) == "function" then
			return originalGet(self)
		end

		return self.Value
	end

	function control:SetCallback(callback)
		if type(originalSetCallback) == "function" then
			return originalSetCallback(self, callback)
		end

		if type(callback) == "function" then
			self.Callback = callback
		else
			self.Callback = nil
		end

		return self
	end

	function control:Destroy()
		disconnectConnections(self._optionConnections)
		disconnectConnections(self._connections)

		if type(originalDestroy) == "function" then
			originalDestroy(self)
		elseif instance then
			instance:Destroy()
		end
	end

	return control
end

local function attachTooltip(window, owner, instance, text)
	if type(text) ~= "string" or text == "" or not window or not instance then
		return
	end

	owner.Tooltip = text

	connectScoped(window, owner, instance.MouseEnter, function()
		if owner.Disabled then
			return
		end

		window:_showTooltip(owner.Tooltip, instance)
	end)

	connectScoped(window, owner, instance.MouseLeave, function()
		window:_hideTooltip()
	end)
end

local function loadSavedKey(fileName)
	if not canReadFs() or not fileName or fileName == "" then
		return nil
	end

	local folder = "BlueskyUI"
	local path = folder .. "/" .. fileName .. ".txt"
	if not isfile(path) then
		return nil
	end

	local ok, content = pcall(function()
		return readfile(path)
	end)
	if ok then
		return tostring(content)
	end

	return nil
end

local function saveKey(fileName, value)
	if not canWriteFs() or not fileName or fileName == "" then
		return
	end

	local folder = "BlueskyUI"
	ensureFolder(folder)
	pcall(function()
		writefile(folder .. "/" .. fileName .. ".txt", tostring(value or ""))
	end)
end

local function promptDiscordInvite(discordConfig)
	if type(discordConfig) ~= "table" or discordConfig.Enabled ~= true then
		return
	end

	local invite = tostring(discordConfig.Invite or "")
	if invite == "" then
		return
	end

	if discordConfig.RememberJoins and canReadFs() then
		local flagPath = "BlueskyUI/discord_" .. invite .. ".txt"
		if isfile(flagPath) then
			return
		end
		if canWriteFs() then
			ensureFolder("BlueskyUI")
			pcall(function()
				writefile(flagPath, "joined")
			end)
		end
	end

	local fullLink = "https://discord.gg/" .. invite
	if type(setclipboard) == "function" then
		pcall(function()
			setclipboard(fullLink)
		end)
	end
end

local function createKeyGate(window, config)
	local keySettings = config.KeySettings or {}
	local acceptedKeys = keySettings.Key or {}
	if type(acceptedKeys) ~= "table" or #acceptedKeys == 0 then
		acceptedKeys = { "Bluesky" }
	end

	local keyFileName = tostring(keySettings.FileName or "bluesky_key")
	local saveEnabled = keySettings.SaveKey ~= false
	local titleText = tostring(keySettings.Title or "Key System")
	local noteText = tostring(keySettings.Note or "Enter access key.")
	local savedKey = saveEnabled and loadSavedKey(keyFileName) or nil

	local overlay = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.28,
		Size = UDim2.fromScale(1, 1),
		Parent = window.Gui,
	})

	local card = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = window.Theme.Surface,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(320, 190),
		Parent = overlay,
	})
	corner(card, 10)
	stroke(card, window.Theme.Stroke, 0.2)
	padding(card, 14, 14, 12, 12)
	list(card, Enum.FillDirection.Vertical, 8)

	makeText(card, titleText, 15, window.Theme.Text, {
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 22),
	})
	makeText(card, noteText, 11, window.Theme.SubText, {
		Size = UDim2.new(1, 0, 0, 18),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	})

	local input = create("TextBox", {
		BackgroundColor3 = window.Theme.SurfaceAlt,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = "Type key...",
		PlaceholderColor3 = window.Theme.SubText,
		Size = UDim2.new(1, 0, 0, 30),
		Text = savedKey or "",
		TextColor3 = window.Theme.Text,
		TextSize = 12,
		Parent = card,
	})
	corner(input, 6)
	padding(input, 8, 8, 0, 0)

	local status = makeText(card, "", 11, window.Theme.Danger, {
		Size = UDim2.new(1, 0, 0, 16),
	})

	local submit = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = window.Theme.AccentDark,
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(1, 0, 0, 30),
		Text = "Unlock",
		TextColor3 = window.Theme.Text,
		TextSize = 12,
		Parent = card,
	})
	corner(submit, 6)

	local function verify()
		local entered = tostring(input.Text or "")
		for _, expected in ipairs(acceptedKeys) do
			if entered == tostring(expected) then
				if saveEnabled then
					saveKey(keyFileName, entered)
				end
				overlay:Destroy()
				window.Main.Visible = true
				return
			end
		end

		status.Text = "Invalid key."
	end

	window.Main.Visible = false
	window:_connect(submit.MouseButton1Click, verify)
	window:_connect(input.FocusLost, function(enterPressed)
		if enterPressed then
			verify()
		end
	end)
end

function Bluesky:RegisterTheme(name, theme)
	if type(name) == "string" and type(theme) == "table" then
		self.Themes[name] = copyTheme(theme)
	end

	return self
end

function Bluesky:SetDebugWarnings(enabled)
	self.DebugWarnings = enabled ~= false
	return self
end

function Bluesky:GetTheme(name)
	return copyTheme(name)
end

function Bluesky:RegisterIcon(name, source)
	if type(name) == "string" and source ~= nil then
		self.Icons[name] = source
	end

	return self
end

function Bluesky:RegisterIcons(iconMap)
	for name, source in pairs(iconMap or {}) do
		self:RegisterIcon(name, source)
	end

	return self
end

function Bluesky:UseIconPreset(name, overwrite)
	local preset = self.IconPresets[name]
	if type(preset) ~= "table" or type(preset.Icons) ~= "table" then
		warn("[Bluesky UI] unknown icon preset:", tostring(name))
		return self
	end

	for iconName, source in pairs(preset.Icons) do
		if overwrite ~= false or self.Icons[iconName] == nil then
			self:RegisterIcon(iconName, source)
		end
	end

	return self
end

function Bluesky:GetIconPresetInfo(name)
	local preset = self.IconPresets[name]
	if type(preset) ~= "table" then
		return nil
	end

	local meta = {}
	for key, value in pairs(preset.Meta or {}) do
		meta[key] = value
	end

	meta.Name = name
	meta.IconCount = 0
	for _ in pairs(preset.Icons or {}) do
		meta.IconCount = meta.IconCount + 1
	end

	return meta
end

function Bluesky:SetSecureMode(enabled)
	self.SecureMode = enabled == true
	return self
end

function Bluesky:SetRemoteIconsEnabled(enabled)
	self.RemoteIconsEnabled = enabled ~= false
	return self
end

function Bluesky:SetIconLibraryUrl(url)
	if type(url) == "string" and url ~= "" then
		self.IconLibraryUrl = url
		self.RayfieldIcons = nil
		self.RayfieldIconsLoaded = false
	end

	return self
end

function Bluesky:GetWindow()
	return self.CurrentWindow
end

function Bluesky:Notify(options)
	if self.CurrentWindow and type(self.CurrentWindow.Notify) == "function" then
		return self.CurrentWindow:Notify(options)
	end

	devWarn("Notify called before CreateWindow.")
	return nil
end

function Bluesky:Confirm(options)
	if self.CurrentWindow and type(self.CurrentWindow.Confirm) == "function" then
		return self.CurrentWindow:Confirm(options)
	end

	devWarn("Confirm called before CreateWindow.")
	return nil
end

function Bluesky:SaveConfiguration(profileName)
	if self.CurrentWindow and type(self.CurrentWindow.SaveConfig) == "function" then
		return self.CurrentWindow:SaveConfig(profileName)
	end

	return false, "window not created"
end

function Bluesky:LoadConfiguration(profileName)
	if self.CurrentWindow and type(self.CurrentWindow.LoadConfig) == "function" then
		return self.CurrentWindow:LoadConfig(profileName)
	end

	return false, "window not created"
end

function Bluesky:_loadRayfieldIcons()
	if self.SecureMode or self.RemoteIconsEnabled == false then
		return nil
	end

	if self.RayfieldIconsLoaded then
		return self.RayfieldIcons
	end

	self.RayfieldIconsLoaded = true

	if type(loadstring) ~= "function" or type(self.IconLibraryUrl) ~= "string" then
		devWarn("Rayfield Lucide icons are unavailable because loadstring is not supported.")
		return nil
	end

	local okFetch, source = pcall(function()
		return game:HttpGet(self.IconLibraryUrl)
	end)
	if not okFetch or type(source) ~= "string" or source == "" then
		devWarn("Rayfield Lucide icons could not be fetched. Falling back to LucideLite text icons.")
		return nil
	end

	local okLoad, loader = pcall(loadstring, source)
	if not okLoad or type(loader) ~= "function" then
		devWarn("Rayfield Lucide icons could not be parsed.")
		return nil
	end

	local okRun, icons = pcall(loader)
	if okRun and type(icons) == "table" then
		self.RayfieldIcons = icons
		return icons
	end

	devWarn("Rayfield Lucide icons returned invalid data.")
	return nil
end

function Bluesky:_resolveRayfieldIcon(icon)
	local icons = self:_loadRayfieldIcons()
	local sizedIcons = type(icons) == "table" and icons["48px"] or nil
	if type(sizedIcons) ~= "table" then
		return nil
	end

	local record = sizedIcons[trimLower(icon)]
	if type(record) ~= "table" then
		return nil
	end

	local rectSize = record[2]
	local rectOffset = record[3]
	if type(record[1]) ~= "number" or type(rectSize) ~= "table" or type(rectOffset) ~= "table" then
		return nil
	end

	return {
		Kind = "atlas",
		Value = "rbxassetid://" .. tostring(record[1]),
		RectSize = Vector2.new(rectSize[1], rectSize[2]),
		RectOffset = Vector2.new(rectOffset[1], rectOffset[2]),
	}
end

function Bluesky:_warnMissingIcon(icon)
	local key = tostring(icon or "")
	if key == "" or self.MissingIconWarnings[key] then
		return
	end

	self.MissingIconWarnings[key] = true
	devWarn("missing icon '" .. key .. "', using fallback text icon.")
end

function Bluesky:_resolveIcon(icon)
	if icon == nil or icon == false or icon == 0 then
		return nil
	end

	if type(icon) == "table" then
		if icon.Image then
			if self.SecureMode and isDetectableAsset(icon.Image) then
				return nil
			end

			return {
				Kind = "image",
				Value = formatAssetId(icon.Image),
				Color = icon.Color,
			}
		end

		if icon.Text then
			return {
				Kind = "text",
				Value = tostring(icon.Text),
				Color = icon.Color,
			}
		end
	end

	local directAsset = formatAssetId(icon)
	if directAsset then
		if self.SecureMode and isDetectableAsset(icon) then
			return nil
		end

		return {
			Kind = "image",
			Value = directAsset,
		}
	end

	if type(icon) == "string" and self.Icons[icon] then
		if self.SecureMode and isDetectableAsset(self.Icons[icon]) then
			self:_warnMissingIcon(icon)
			return {
				Kind = "text",
				Value = self.FallbackIcon,
			}
		end

		local mappedAsset = formatAssetId(self.Icons[icon])
		if mappedAsset then
			return {
				Kind = "image",
				Value = mappedAsset,
			}
		end

		return {
			Kind = "text",
			Value = tostring(self.Icons[icon]),
		}
	end

	if type(icon) == "string" then
		if not self.SecureMode then
			local rayfieldIcon = self:_resolveRayfieldIcon(icon)
			if rayfieldIcon then
				return rayfieldIcon
			end
		end

		local fallbackIcons = self.IconPresets
			and self.IconPresets.LucideLite
			and self.IconPresets.LucideLite.Icons
		local fallbackValue = type(fallbackIcons) == "table" and (fallbackIcons[icon] or fallbackIcons[trimLower(icon)]) or nil
		if fallbackValue ~= nil then
			return {
				Kind = "text",
				Value = tostring(fallbackValue),
			}
		end

		self:_warnMissingIcon(icon)
		return {
			Kind = "text",
			Value = self.FallbackIcon,
		}
	end

	return nil
end

local function mountIcon(library, parent, icon, theme, size, layoutOrder)
	local resolved = library:_resolveIcon(icon)
	if not resolved then
		return nil
	end

	if (resolved.Kind == "image" or resolved.Kind == "atlas") and resolved.Value then
		local image = create("ImageLabel", {
			BackgroundTransparency = 1,
			Image = resolved.Value,
			ImageColor3 = resolved.Color or theme.Text,
			Size = UDim2.fromOffset(size, size),
			LayoutOrder = layoutOrder or 1,
			Parent = parent,
		})

		if resolved.Kind == "atlas" then
			image.ImageRectOffset = resolved.RectOffset
			image.ImageRectSize = resolved.RectSize
		end

		return image
	end

	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = resolved.Value,
		TextColor3 = resolved.Color or theme.Text,
		TextSize = math.max(12, size - 2),
		Font = Enum.Font.GothamBold,
		Size = UDim2.fromOffset(size, size),
		LayoutOrder = layoutOrder or 1,
		Parent = parent,
	})

	return label
end

function WindowMethods:_connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self._connections, connection)
	return connection
end

function WindowMethods:_setTabActive(tab)
	self.ActiveTab = tab

	for _, item in ipairs(self.Tabs) do
		local selected = item == tab
		item._page.Visible = selected

		tween(item._button, TWEEN_FAST, {
			BackgroundColor3 = selected and self.Theme.AccentDark or self.Theme.Surface,
		})

		if selected and self.Animations and item._pageScale then
			item._pageScale.Scale = 0.985
			tween(item._pageScale, TWEEN_MEDIUM, {
				Scale = 1,
			})
		end

		item._title.TextColor3 = selected and self.Theme.Text or self.Theme.SubText

		if item._icon then
			if item._icon:IsA("ImageLabel") then
				item._icon.ImageColor3 = selected and self.Theme.Text or self.Theme.SubText
			else
				item._icon.TextColor3 = selected and self.Theme.Text or self.Theme.SubText
			end
		end
	end
end

function WindowMethods:_makeDraggable(handle, target)
	target = target or self.Main

	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPosition = nil
	local dragMaid = nil

	self:_connect(handle.InputBegan, function(input)
		if not isInputStart(input) then
			return
		end

		if dragMaid then
			dragMaid:Cleanup()
		end

		dragging = true
		dragStart = input.Position
		startPosition = target.Position

		dragMaid = createMaid()
		dragMaid:Give(input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				local shouldSave = dragging
				dragging = false
				if dragMaid then
					dragMaid:Cleanup()
					dragMaid = nil
				end
				if shouldSave and self._queueWindowStateSave then
					self:_queueWindowStateSave()
				end
			end
		end))
	end)

	self:_connect(handle.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragInput = input
		end
	end)

	self:_connect(UserInputService.InputChanged, function(input)
		if input ~= dragInput or not dragging then
			return
		end

		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
end

function WindowMethods:_makeResizable(handle, target)
	target = target or self.Main

	local resizing = false
	local resizeInput = nil
	local resizeStart = nil
	local startSize = nil
	local startPosition = nil
	local resizeMaid = nil

	self:_connect(handle.InputBegan, function(input)
		if not isInputStart(input) then
			return
		end

		if self.Maximized then
			return
		end

		if resizeMaid then
			resizeMaid:Cleanup()
		end

		resizing = true
		resizeStart = input.Position
		startSize = target.AbsoluteSize
		startPosition = target.Position

		resizeMaid = createMaid()
		resizeMaid:Give(input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				local shouldSave = resizing
				resizing = false
				if resizeMaid then
					resizeMaid:Cleanup()
					resizeMaid = nil
				end
				if shouldSave and self._queueWindowStateSave then
					self:_queueWindowStateSave()
				end
			end
		end))
	end)

	self:_connect(handle.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			resizeInput = input
		end
	end)

	self:_connect(UserInputService.InputChanged, function(input)
		if input ~= resizeInput or not resizing then
			return
		end

		local viewport = getViewportSize()
		local delta = input.Position - resizeStart
		local minSize = self.MinWindowSize or Vector2.new(360, 260)
		local maxWidth = math.max(minSize.X, viewport.X - 24)
		local maxHeight = math.max(minSize.Y, viewport.Y - 24)
		local nextWidth = math.clamp(startSize.X + delta.X, minSize.X, maxWidth)
		local nextHeight = math.clamp(startSize.Y + delta.Y, minSize.Y, maxHeight)

		target.Size = UDim2.fromOffset(nextWidth, nextHeight)
		target.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + ((nextWidth - startSize.X) / 2),
			startPosition.Y.Scale,
			startPosition.Y.Offset + ((nextHeight - startSize.Y) / 2)
		)
	end)
end

function WindowMethods:SetVisible(visible)
	self.Visible = visible
	self.Main.Visible = visible and not self.Minimized

	if self.MinimizedButton then
		self.MinimizedButton.Visible = visible and self.Minimized
	end
end

function WindowMethods:SetVisibility(visible)
	self:SetVisible(visible)
	return self
end

function WindowMethods:IsVisible()
	return self.Visible == true
end

function WindowMethods:Toggle()
	self:SetVisible(not self.Visible)
end

function WindowMethods:Maximize()
	if self.Maximized then
		return self
	end

	self.Maximized = true
	self._restoreSize = self.Main.Size
	self._restorePosition = self.Main.Position

	if self.ResizeHandle then
		self.ResizeHandle.Visible = false
	end

	local margin = tonumber(self.FullscreenMargin) or 18
	local targetProps = {
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -(margin * 2), 1, -(margin * 2)),
	}

	if self.Animations then
		tween(self.Main, TWEEN_MEDIUM, targetProps)
	else
		self.Main.Position = targetProps.Position
		self.Main.Size = targetProps.Size
	end

	return self
end

function WindowMethods:RestoreSize()
	if not self.Maximized then
		return self
	end

	self.Maximized = false

	if self.ResizeHandle and self.Resizable then
		self.ResizeHandle.Visible = true
	end

	local targetProps = {
		Position = self._restorePosition or UDim2.fromScale(0.5, 0.5),
		Size = self._restoreSize or UDim2.fromOffset(620, 420),
	}

	if self.Animations then
		tween(self.Main, TWEEN_MEDIUM, targetProps)
	else
		self.Main.Position = targetProps.Position
		self.Main.Size = targetProps.Size
	end

	return self
end

function WindowMethods:ToggleMaximize()
	if self.Maximized then
		return self:RestoreSize()
	end

	return self:Maximize()
end

function WindowMethods:_updateTopbarLayout()
	if not self.Main or not self.TopbarControls or not self.TopbarTitleWrap then
		return
	end

	local width = self.Main.AbsoluteSize.X
	local controlsWidth = self.TopbarControls.AbsoluteSize.X
	if controlsWidth <= 0 then
		controlsWidth = (self.Mobile and 130 or 106)
	end

	local sidePadding = 14
	local rightPadding = controlsWidth + 24
	local minSearchWidth = self.Mobile and 112 or 150
	local preferredTitleWidth = self.TitleWidth or 190
	local searchVisible = self.SearchHolder ~= nil and width >= (preferredTitleWidth + minSearchWidth + rightPadding + 28)
	local titleWidth

	if searchVisible then
		titleWidth = math.clamp(preferredTitleWidth, 118, math.max(118, width - minSearchWidth - rightPadding - 28))
		self.TopbarTitleWrap.Size = UDim2.fromOffset(titleWidth, 48)
		self.SearchHolder.Visible = true
		self.SearchHolder.Position = UDim2.fromOffset(titleWidth + 24, 9)
		self.SearchHolder.Size = UDim2.new(1, -(titleWidth + rightPadding + 34), 0, 30)
	else
		titleWidth = math.max(84, width - rightPadding - sidePadding)
		self.TopbarTitleWrap.Size = UDim2.new(1, -rightPadding, 1, 0)
		if self.SearchHolder then
			self.SearchHolder.Visible = false
		end
	end

	if self.TopbarSubtitleLabel then
		self.TopbarSubtitleLabel.Visible = width >= 360
	end

	if self.TopbarTitleLabel then
		self.TopbarTitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	end
end

function WindowMethods:_applySidebarWidth(width)
	if self.NavigationStyle ~= "Sidebar" or not self.Sidebar or not self.ContentHolder then
		return
	end

	local props = {
		Size = UDim2.new(0, width, 1, 0),
	}
	local contentProps = {
		Position = UDim2.new(0, width, 0, 0),
		Size = UDim2.new(1, -width, 1, 0),
	}

	if self.Animations then
		tween(self.Sidebar, TWEEN_FAST, props)
		tween(self.ContentHolder, TWEEN_FAST, contentProps)
	else
		self.Sidebar.Size = props.Size
		self.ContentHolder.Position = contentProps.Position
		self.ContentHolder.Size = contentProps.Size
	end
end

function WindowMethods:_updateSidebarWidth(suggestedWidth)
	if self.NavigationStyle ~= "Sidebar" or self.SidebarCollapsed then
		return
	end

	self.SidebarWidth = math.max(self.SidebarWidth or 204, suggestedWidth or 0)

	if self.Main and self.Main.AbsoluteSize.X > 0 then
		local maxByWindow = math.max(self.SidebarCollapsedWidth or 58, self.Main.AbsoluteSize.X - (self.MinContentWidth or 230))
		self.SidebarWidth = math.min(self.SidebarWidth, math.min(self.MaxSidebarWidth or 260, maxByWindow))
	end

	self.SidebarWidth = math.max(self.SidebarWidth, self.MinSidebarWidth or 188)
	self:_applySidebarWidth(self.SidebarWidth)
end

function WindowMethods:_refreshResponsiveLayout()
	self:_updateTopbarLayout()
	if self.NavigationStyle == "Sidebar" and not self.SidebarCollapsed then
		self:_updateSidebarWidth(self.SidebarWidth)
	end
end

function WindowMethods:SetSidebarCollapsed(collapsed)
	if self.NavigationStyle ~= "Sidebar" or not self.Sidebar or not self.ContentHolder then
		return self
	end

	self.SidebarCollapsed = collapsed == true
	local width = self.SidebarCollapsed and self.SidebarCollapsedWidth or self.SidebarWidth
	self:_applySidebarWidth(width)

	for _, tab in ipairs(self.Tabs) do
		if tab._title then
			tab._title.Visible = not self.SidebarCollapsed
		end
	end

	return self
end

function WindowMethods:ToggleSidebar()
	return self:SetSidebarCollapsed(not self.SidebarCollapsed)
end

function WindowMethods:Minimize()
	self.Minimized = true
	self.Visible = true

	if self.MinimizedButton then
		self.MinimizedButton.Position = self.MinimizedPosition
		self.MinimizedButton.Visible = true

		if self.Animations and self.MinimizedScale then
			self.MinimizedScale.Scale = 0.72
			tween(self.MinimizedScale, TWEEN_OPEN, {
				Scale = 1,
			})
		end
	end

	if self.Animations and self.MainScale then
		tween(self.MainScale, TWEEN_FAST, {
			Scale = 0.94,
		})

		task.delay(0.1, function()
			if self.Minimized then
				self.Main.Visible = false
				self.MainScale.Scale = 1
			end
		end)
	else
		self.Main.Visible = false
	end
end

function WindowMethods:Restore()
	self.Minimized = false
	self.Visible = true
	self.Main.Visible = true

	if self.Animations and self.MainScale then
		self.MainScale.Scale = 0.94
		tween(self.MainScale, TWEEN_OPEN, {
			Scale = 1,
		})
	end

	if self.MinimizedButton then
		if self.Animations and self.MinimizedScale then
			tween(self.MinimizedScale, TWEEN_FAST, {
				Scale = 0.72,
			})

			task.delay(0.1, function()
				if not self.Minimized and self.MinimizedButton then
					self.MinimizedButton.Visible = false
					self.MinimizedScale.Scale = 1
				end
			end)
		else
			self.MinimizedButton.Visible = false
		end
	end
end

local function swapThemeColor(instance, property, oldTheme, nextTheme)
	local ok, current = pcall(function()
		return instance[property]
	end)

	if not ok or typeof(current) ~= "Color3" then
		return
	end

	for key, oldColor in pairs(oldTheme) do
		if typeof(oldColor) == "Color3" and current == oldColor and nextTheme[key] ~= nil then
			pcall(function()
				instance[property] = nextTheme[key]
			end)
			return
		end
	end
end

function WindowMethods:SetTheme(themeConfig)
	local oldTheme = self.Theme
	local nextTheme = copyTheme(themeConfig)

	if self.Gui then
		for _, instance in ipairs(self.Gui:GetDescendants()) do
			swapThemeColor(instance, "BackgroundColor3", oldTheme, nextTheme)
			swapThemeColor(instance, "TextColor3", oldTheme, nextTheme)
			swapThemeColor(instance, "ImageColor3", oldTheme, nextTheme)
			swapThemeColor(instance, "PlaceholderColor3", oldTheme, nextTheme)
			swapThemeColor(instance, "ScrollBarImageColor3", oldTheme, nextTheme)
			swapThemeColor(instance, "Color", oldTheme, nextTheme)
		end
	end

	self.Theme = nextTheme

	if self.ActiveTab then
		self:_setTabActive(self.ActiveTab)
	end

	return self
end

function WindowMethods:_registerControl(flag, control)
	if type(flag) ~= "string" or flag == "" or type(control) ~= "table" then
		return
	end

	control.Flag = flag
	if control.DefaultValue == nil then
		control.DefaultValue = cloneValue(control.Value)
	end
	self.Controls[flag] = control
	if self.Flags[flag] ~= nil and type(control.Set) == "function" then
		local wasLoading = self._loadingConfig
		self._loadingConfig = true
		control:Set(self.Flags[flag], false)
		self._loadingConfig = wasLoading
	else
		self.Flags[flag] = control.Value
	end
end

function WindowMethods:_setFlag(flag, value)
	if type(flag) == "string" and flag ~= "" then
		local oldValue = self.Flags[flag]
		self.Flags[flag] = value
		local listeners = self.FlagChanged and self.FlagChanged[flag]
		if type(listeners) == "table" then
			for _, callback in ipairs(listeners) do
				safeCall(callback, value, oldValue, flag)
			end
		end
		self:_queueAutoSave()
	end
end

function WindowMethods:OnFlagChanged(flag, callback)
	if type(flag) ~= "string" or flag == "" or type(callback) ~= "function" then
		return {
			Disconnect = function() end,
		}
	end

	self.FlagChanged[flag] = self.FlagChanged[flag] or {}
	local listeners = self.FlagChanged[flag]
	table.insert(listeners, callback)

	local connected = true
	return {
		Disconnect = function()
			if not connected then
				return
			end
			connected = false
			for index, item in ipairs(listeners) do
				if item == callback then
					table.remove(listeners, index)
					break
				end
			end
		end,
	}
end

function WindowMethods:GetFlag(flag)
	return self.Flags[flag]
end

function WindowMethods:GetFlags()
	local snapshot = {}

	for key, value in pairs(self.Flags) do
		snapshot[key] = value
	end

	return snapshot
end

function WindowMethods:SetFlag(flag, value, invoke)
	local control = self.Controls[flag]

	if control and type(control.Set) == "function" then
		control:Set(value, invoke)
	else
		self:_setFlag(flag, value)
	end

	return self
end

function WindowMethods:_resolveProfileName(profileName)
	if type(profileName) == "string" and profileName ~= "" then
		return profileName
	end

	return self.ConfigFileName or "default"
end

function WindowMethods:_queueAutoSave()
	if not self.AutoSaveConfig or self._loadingConfig or self._destroyed then
		return
	end

	self._autoSaveToken = (self._autoSaveToken or 0) + 1
	local token = self._autoSaveToken
	local delaySeconds = tonumber(self.AutoSaveDelay) or 0.8

	task.delay(delaySeconds, function()
		if self._destroyed or token ~= self._autoSaveToken then
			return
		end

		local okSave, err = self:SaveConfig(self.ConfigFileName)
		if not okSave then
			devWarn("AutoSave config failed: " .. tostring(err))
		end
	end)
end

function WindowMethods:_queueWindowStateSave()
	if self.SaveWindowState then
		self:_queueAutoSave()
	end
end

function WindowMethods:_captureWindowState()
	return {
		MainPosition = self.Main and self.Main.Position or nil,
		MainSize = self.Main and self.Main.Size or nil,
		MinimizedPosition = self.MinimizedButton and self.MinimizedButton.Position or nil,
	}
end

function WindowMethods:_applyWindowState(state)
	if type(state) ~= "table" then
		return
	end

	if self.Main then
		if typeof(state.MainPosition) == "UDim2" then
			self.Main.Position = state.MainPosition
		end
		if typeof(state.MainSize) == "UDim2" then
			self.Main.Size = state.MainSize
		end
	end

	if self.MinimizedButton and typeof(state.MinimizedPosition) == "UDim2" then
		self.MinimizedPosition = state.MinimizedPosition
		self.MinimizedButton.Position = state.MinimizedPosition
	end
end

function WindowMethods:GetProfiles()
	if not canListFs() then
		return {}
	end

	local profiles = {}
	local ok, files = pcall(function()
		return listfiles(self.ConfigFolder)
	end)

	if not ok or type(files) ~= "table" then
		return profiles
	end

	for _, filePath in ipairs(files) do
		local profile = tostring(filePath):match("([^\\/]+)%.json$")
		if profile then
			table.insert(profiles, profile)
		end
	end

	table.sort(profiles)
	return profiles
end

function WindowMethods:SaveConfig(profileName)
	if not self.ConfigSavingEnabled then
		return false, "config saving disabled"
	end

	if not canWriteFs() then
		return false, "filesystem unsupported"
	end

	local fileName = self:_resolveProfileName(profileName)
	local payload = {
		Version = Bluesky.Version,
		Flags = {},
	}

	for key, value in pairs(self.Flags) do
		payload.Flags[key] = encodeValue(value)
	end

	if self.SaveWindowState then
		payload.WindowState = encodeValue(self:_captureWindowState())
	end

	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(payload)
	end)
	if not ok then
		return false, "encode failed"
	end

	ensureFolder(self.ConfigFolder)

	local path = self.ConfigFolder .. "/" .. fileName .. ".json"
	local wrote = pcall(function()
		writefile(path, encoded)
	end)

	if not wrote then
		return false, "write failed"
	end

	return true
end

function WindowMethods:LoadConfig(profileName)
	if not self.ConfigSavingEnabled then
		return false, "config saving disabled"
	end

	if not canReadFs() then
		return false, "filesystem unsupported"
	end

	local fileName = self:_resolveProfileName(profileName)
	local path = self.ConfigFolder .. "/" .. fileName .. ".json"
	if not isfile(path) then
		return false, "profile not found"
	end

	local okRead, raw = pcall(function()
		return readfile(path)
	end)
	if not okRead then
		return false, "read failed"
	end

	local okDecode, data = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not okDecode or type(data) ~= "table" or type(data.Flags) ~= "table" then
		return false, "invalid config file"
	end

	local previousLoading = self._loadingConfig
	self._loadingConfig = true
	for flag, encoded in pairs(data.Flags) do
		self:SetFlag(flag, decodeValue(encoded), true)
	end

	if self.SaveWindowState and type(data.WindowState) == "table" then
		self:_applyWindowState(decodeValue(data.WindowState))
	end

	self._loadingConfig = previousLoading

	return true
end

function WindowMethods:DeleteConfig(profileName)
	if not self.ConfigSavingEnabled then
		return false, "config saving disabled"
	end

	if not canReadFs() or not canDeleteFs() then
		return false, "filesystem unsupported"
	end

	local fileName = self:_resolveProfileName(profileName)
	local path = self.ConfigFolder .. "/" .. fileName .. ".json"
	if not isfile(path) then
		return false, "profile not found"
	end

	local deleteFn = delfile or deletefile
	local okDelete = pcall(function()
		deleteFn(path)
	end)
	if not okDelete then
		return false, "delete failed"
	end

	return true
end

function WindowMethods:ResetConfig(invoke)
	local previousLoading = self._loadingConfig
	self._loadingConfig = true

	for flag, control in pairs(self.Controls) do
		local defaultValue = cloneValue(control.DefaultValue)
		if type(control.Set) == "function" then
			control:Set(defaultValue, invoke)
		else
			self.Flags[flag] = defaultValue
		end
	end

	self._loadingConfig = previousLoading
	if self.AutoSaveConfig then
		self:_queueAutoSave()
	end

	return true
end

function WindowMethods:_registerSearchItem(name, instance, sectionInfo)
	if not self.SearchEnabled or not instance then
		return
	end

	local item = {
		Name = searchText(name),
		Instance = instance,
		Section = sectionInfo,
	}

	table.insert(self.SearchItems, item)

	if sectionInfo then
		table.insert(sectionInfo.Items, item)
	end

	if self.SearchQuery and self.SearchQuery ~= "" then
		self:_applySearch(self.SearchQuery)
	end
end

function WindowMethods:_applySearch(query)
	if not self.SearchEnabled then
		return
	end

	query = searchText(query)
	self.SearchQuery = query

	local hasQuery = query ~= ""

	for _, item in ipairs(self.SearchItems) do
		if item.Instance and item.Instance.Parent then
			item.Instance.Visible = (not hasQuery) or string.find(item.Name, query, 1, true) ~= nil
		end
	end

	for _, sectionInfo in ipairs(self.SearchSections) do
		local sectionMatches = hasQuery and string.find(sectionInfo.Name, query, 1, true) ~= nil
		local hasVisibleChild = false

		for _, item in ipairs(sectionInfo.Items) do
			if item.Instance and item.Instance.Parent then
				if sectionMatches then
					item.Instance.Visible = true
				end

				if item.Instance.Visible then
					hasVisibleChild = true
				end
			end
		end

		if sectionInfo.Frame and sectionInfo.Frame.Parent then
			sectionInfo.Frame.Visible = (not hasQuery) or sectionMatches or hasVisibleChild
		end
	end
end

function WindowMethods:_showTooltip(text, anchor)
	if type(text) ~= "string" or text == "" or not self.Gui then
		return
	end
	self.TooltipText = text

	if not self.TooltipFrame or not self.TooltipFrame.Parent then
		local frame = create("Frame", {
			BackgroundColor3 = self.Theme.Surface,
			BackgroundTransparency = 0.02,
			BorderSizePixel = 0,
			ZIndex = 220,
			Parent = self.Gui,
		})
		corner(frame, 6)
		stroke(frame, self.Theme.Stroke, 0.25, nil)
		padding(frame, 8, 8, 6, 6)

		local label = makeText(frame, "", 12, self.Theme.Text, {
			Name = "TooltipLabel",
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 221,
		})

		self.TooltipFrame = frame
		self.TooltipLabel = label
	end

	local label = self.TooltipLabel
	local frame = self.TooltipFrame
	local maxWidth = tonumber(self.TooltipMaxWidth) or 220
	local measured = TextService:GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(maxWidth, math.huge))
	local width = math.clamp(measured.X + 18, 80, maxWidth + 18)
	local height = math.clamp(measured.Y + 14, 28, 120)
	local viewport = getViewportSize()
	local position = UserInputService:GetMouseLocation() + Vector2.new(14, 12)

	if anchor and anchor.Parent and position.X <= 0 then
		position = anchor.AbsolutePosition + Vector2.new(0, anchor.AbsoluteSize.Y + 6)
	end

	local x = math.clamp(position.X, 8, math.max(8, viewport.X - width - 8))
	local y = math.clamp(position.Y, 8, math.max(8, viewport.Y - height - 8))

	label.Text = text
	frame.Size = UDim2.fromOffset(width, height)
	frame.Position = UDim2.fromOffset(x, y)
	frame.Visible = true
end

function WindowMethods:_hideTooltip()
	if self.TooltipFrame then
		self.TooltipFrame.Visible = false
	end
	self.TooltipText = nil
end

function WindowMethods:_trackDropdownOpen(control, open)
	self.OpenDropdowns = self.OpenDropdowns or {}

	if open then
		self.OpenDropdowns[control] = true
	else
		self.OpenDropdowns[control] = nil
	end
end

function WindowMethods:_closeDropdownsExcept(exceptControl)
	if type(self.OpenDropdowns) ~= "table" then
		return
	end

	for control in pairs(self.OpenDropdowns) do
		if control ~= exceptControl and type(control.Close) == "function" then
			control:Close()
		end
	end
end

function WindowMethods:_closeDropdownsAt(input)
	if type(self.OpenDropdowns) ~= "table" or not isInputStart(input) then
		return
	end

	local position = input.Position
	for control in pairs(self.OpenDropdowns) do
		local insideControl = control.Instance and pointInGui(control.Instance, position)
		local insidePopup = control.Popup and pointInGui(control.Popup, position)
		if not insideControl and not insidePopup and type(control.Close) == "function" then
			control:Close()
		end
	end
end

function WindowMethods:Confirm(options)
	options = normalizeOptions(options, "Confirm")
	local theme = self.Theme
	local overlay = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.42,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 180,
		Parent = self.Gui,
	})

	local card = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Surface,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(330, 150),
		ZIndex = 181,
		Parent = overlay,
	})
	corner(card, 10)
	stroke(card, theme.Stroke, 0.18, nil)
	padding(card, 14, 14, 12, 12)
	list(card, Enum.FillDirection.Vertical, 10)

	makeText(card, options.Name or options.Title or "Confirm", 15, theme.Text, {
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 22),
		ZIndex = 182,
	})

	makeText(card, tostring(options.Content or options.Text or "Are you sure?"), 12, theme.SubText, {
		Size = UDim2.new(1, 0, 0, 40),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 182,
	})

	local buttons = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
		ZIndex = 182,
		Parent = card,
	})
	list(buttons, Enum.FillDirection.Horizontal, 8).HorizontalAlignment = Enum.HorizontalAlignment.Right

	local function makeModalButton(text, color)
		local button = create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = color,
			Font = Enum.Font.GothamMedium,
			Text = text,
			TextColor3 = theme.Text,
			TextSize = 12,
			Size = UDim2.fromOffset(96, 30),
			ZIndex = 183,
			Parent = buttons,
		})
		corner(button, 7)
		return button
	end

	local cancel = makeModalButton(tostring(options.CancelText or "Cancel"), theme.Item)
	local confirm = makeModalButton(tostring(options.ConfirmText or "Confirm"), options.Color or theme.AccentDark)
	local closed = false
	local modal = {}

	function modal:Destroy()
		if closed then
			return
		end
		closed = true
		disconnectConnections(self._connections)
		if self._window and self._window.ActiveModal == self then
			self._window.ActiveModal = nil
		end
		if overlay.Parent then
			overlay:Destroy()
		end
	end

	function modal:Cancel()
		safeCall(options.OnCancel)
		self:Destroy()
		return self
	end

	function modal:Confirm()
		safeCall(options.OnConfirm)
		self:Destroy()
		return self
	end

	modal._window = self
	self.ActiveModal = modal

	trackConnection(modal, self:_connect(cancel.MouseButton1Click, function()
		modal:Cancel()
	end))

	trackConnection(modal, self:_connect(confirm.MouseButton1Click, function()
		modal:Confirm()
	end))

	return modal
end

function WindowMethods:Notify(options)
	options = normalizeOptions(options, "Notification")

	local theme = self.Theme
	local notifyType = string.lower(tostring(options.Type or options.Kind or ""))
	local presets = {
		success = { Color = theme.Success, Icon = "check" },
		warning = { Color = Color3.fromRGB(255, 185, 84), Icon = "alert-circle" },
		error = { Color = theme.Danger, Icon = "alert-circle" },
		danger = { Color = theme.Danger, Icon = "alert-circle" },
		info = { Color = theme.Accent, Icon = "info" },
	}
	local preset = presets[notifyType]
	if preset then
		options.Color = options.Color or preset.Color
		options.Icon = options.Icon or options.Image or preset.Icon
	end

	local duration = math.max(0.1, tonumber(options.Duration) or 2.5)
	local hasContent = options.Content ~= nil and tostring(options.Content) ~= ""
	local actions = type(options.Actions) == "table" and options.Actions or nil
	local actionCount = 0
	if actions then
		for _ in pairs(actions) do
			actionCount = actionCount + 1
		end
	end
	actionCount = math.clamp(actionCount, 0, 2)
	local hasActions = actionCount > 0
	local height = hasContent and 54 or 42
	if hasActions then
		height = height + 36
	end

	local toast = createMaid()
	local slot = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height),
		Parent = self.NotificationHolder,
	})

	local card = create("Frame", {
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(18, 0),
		Size = UDim2.fromScale(1, 1),
		Parent = slot,
	})
	corner(card, 7)
	local cardStroke = stroke(card, theme.Stroke, 1)

	local accent = create("Frame", {
		BackgroundColor3 = options.Color or theme.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.new(0, 3, 1, -18),
		Parent = card,
	})
	corner(accent, 2)

	local closeButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		AutoButtonColor = false,
		BackgroundColor3 = theme.Item,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Position = UDim2.new(1, -8, 0, 7),
		Size = UDim2.fromOffset(22, 22),
		Text = "x",
		TextColor3 = theme.SubText,
		TextSize = 12,
		Parent = card,
	})
	corner(closeButton, 6)

	local notifyIcon = mountIcon(Bluesky, card, options.Icon or options.Image, theme, 17, nil)
	local textX = notifyIcon and 44 or 20
	if notifyIcon then
		notifyIcon.Position = UDim2.fromOffset(20, hasContent and 13 or math.max(11, math.floor((height - 19) / 2)))
		if notifyIcon:IsA("ImageLabel") then
			notifyIcon.ImageTransparency = 1
		else
			notifyIcon.TextTransparency = 1
		end
	end

	local title = makeText(card, options.Name, 14, theme.Text, {
		Font = Enum.Font.GothamMedium,
		Position = hasContent and UDim2.fromOffset(textX, 8) or UDim2.fromOffset(textX, 0),
		Size = hasContent and UDim2.new(1, -(textX + 42), 0, 17) or UDim2.new(1, -(textX + 42), 1, -3),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local content
	if hasContent then
		content = makeText(card, tostring(options.Content), 12, theme.SubText, {
			Position = UDim2.fromOffset(textX, 27),
			Size = UDim2.new(1, -(textX + 22), 0, 17),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
	end

	local progressFill
	if options.Progress ~= false then
		local progress = create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = theme.Item,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 2),
			Parent = card,
		})
		progressFill = create("Frame", {
			BackgroundColor3 = options.Color or theme.Accent,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Parent = progress,
		})
	end

	local dismissed = false
	local handle = {
		Instance = card,
	}

	local function removeSlot()
		for index, item in ipairs(self._notificationSlots or {}) do
			if item == handle then
				table.remove(self._notificationSlots, index)
				break
			end
		end
	end

	local function dismiss()
		if dismissed or not slot.Parent then
			return
		end
		dismissed = true
		removeSlot()
		toast:Cleanup()

		tween(card, TWEEN_MEDIUM, {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(18, 0),
		})
		tween(cardStroke, TWEEN_MEDIUM, {
			Transparency = 1,
		})
		tween(accent, TWEEN_MEDIUM, {
			BackgroundTransparency = 1,
		})
		tween(title, TWEEN_MEDIUM, {
			TextTransparency = 1,
		})
		tween(closeButton, TWEEN_MEDIUM, {
			TextTransparency = 1,
			BackgroundTransparency = 1,
		})
		if progressFill then
			tween(progressFill, TWEEN_MEDIUM, {
				BackgroundTransparency = 1,
			})
		end
		if notifyIcon then
			if notifyIcon:IsA("ImageLabel") then
				tween(notifyIcon, TWEEN_MEDIUM, {
					ImageTransparency = 1,
				})
			else
				tween(notifyIcon, TWEEN_MEDIUM, {
					TextTransparency = 1,
				})
			end
		end
		if content then
			tween(content, TWEEN_MEDIUM, {
				TextTransparency = 1,
			})
		end

		task.delay(0.2, function()
			if slot.Parent then
				slot:Destroy()
			end
		end)
	end

	function handle:Close()
		dismiss()
		return self
	end

	function handle:Destroy()
		return self:Close()
	end

	function handle:SetTitle(text)
		title.Text = tostring(text or "")
		return self
	end

	function handle:SetContent(text)
		if content then
			content.Text = tostring(text or "")
		end
		return self
	end

	function handle:SetProgress(ratio)
		if progressFill then
			progressFill.Size = UDim2.fromScale(math.clamp(tonumber(ratio) or 0, 0, 1), 1)
		end
		return self
	end

	self._notificationSlots = self._notificationSlots or {}
	table.insert(self._notificationSlots, handle)

	local maxNotifications = math.max(1, tonumber(options.MaxNotifications) or tonumber(self.MaxNotifications) or 4)
	while #self._notificationSlots > maxNotifications do
		local oldHandle = table.remove(self._notificationSlots, 1)
		if oldHandle and type(oldHandle.Close) == "function" then
			oldHandle:Close()
		end
	end

	if hasActions then
		local actionHolder = create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(20, hasContent and 47 or 24),
			Size = UDim2.new(1, -28, 0, 26),
			Parent = card,
		})
		list(actionHolder, Enum.FillDirection.Horizontal, 6).HorizontalAlignment = Enum.HorizontalAlignment.Right

		local made = 0
		for name, callback in pairs(actions) do
			if made >= 2 then
				break
			end
			made = made + 1

			local actionButton = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = theme.Item,
				Font = Enum.Font.GothamMedium,
				Text = tostring(name),
				TextColor3 = theme.Text,
				TextSize = 12,
				Size = UDim2.fromOffset(72, 24),
				Parent = actionHolder,
			})
			corner(actionButton, 6)
			setButtonHover(self, actionButton, "Item", "ItemHover", toast)

			toast:Give(self:_connect(actionButton.MouseButton1Click, function()
				safeCall(callback)
				dismiss()
			end))
		end
	end

	setButtonHover(self, closeButton, "Item", "ItemHover", toast)
	toast:Give(self:_connect(closeButton.MouseButton1Click, dismiss))

	title.TextTransparency = 1
	closeButton.TextTransparency = 1
	if content then
		content.TextTransparency = 1
	end

	tween(card, TWEEN_MEDIUM, {
		BackgroundTransparency = 0.04,
		Position = UDim2.fromOffset(0, 0),
	})
	tween(cardStroke, TWEEN_MEDIUM, {
		Transparency = 0.45,
	})
	tween(accent, TWEEN_MEDIUM, {
		BackgroundTransparency = 0,
	})
	tween(title, TWEEN_MEDIUM, {
		TextTransparency = 0,
	})
	tween(closeButton, TWEEN_MEDIUM, {
		TextTransparency = 0,
	})
	if notifyIcon then
		if notifyIcon:IsA("ImageLabel") then
			tween(notifyIcon, TWEEN_MEDIUM, {
				ImageTransparency = 0,
			})
		else
			tween(notifyIcon, TWEEN_MEDIUM, {
				TextTransparency = 0,
			})
		end
	end
	if content then
		tween(content, TWEEN_MEDIUM, {
			TextTransparency = 0,
		})
	end
	if progressFill then
		tween(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(0, 1),
		})
	end

	task.delay(duration, dismiss)

	return handle
end

function WindowMethods:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for _, connection in ipairs(self._connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	if self.Gui then
		self.Gui:Destroy()
	end
end

function WindowMethods:CreateTab(options, icon)
	if type(options) == "string" then
		options = {
			Name = options,
			Icon = icon,
		}
	else
		options = normalizeOptions(options, "Tab")
		if options.Icon == nil and icon ~= nil then
			options.Icon = icon
		end
	end

	local theme = self.Theme
	local isTopNavigation = self.NavigationStyle == "Top"
	local tabWidth = tonumber(options.Width) or math.clamp((string.len(tostring(options.Name)) * 8) + (options.Icon and 46 or 28), 90, 160)
	local tabHeight = self.TabHeight or (self.Mobile and 42 or 36)
	local pagePadding = self.PagePadding or (self.Mobile and 12 or 16)

	local tabButton = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.Surface,
		Text = "",
		Size = isTopNavigation and UDim2.fromOffset(tabWidth, self.TabTopHeight or (self.Mobile and 40 or 34)) or UDim2.new(1, 0, 0, tabHeight),
		Parent = self.TabList,
	}, self, { BackgroundColor3 = "Surface" })
	corner(tabButton, 8)
	local tabScale = addScale(tabButton, 1)

	local row = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = tabButton,
	})
	padding(row, 10, 10, 0, 0)
	list(row, Enum.FillDirection.Horizontal, 8).VerticalAlignment = Enum.VerticalAlignment.Center

	local icon = mountIcon(Bluesky, row, options.Icon, theme, 16, 1)

	local title = makeText(row, options.Name, 13, theme.SubText, {
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(1, icon and -24 or 0, 1, 0),
		LayoutOrder = 2,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, self, "SubText")
	title.Visible = not self.SidebarCollapsed

	local page = create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollBarThickness = self.Mobile and 5 or 3,
		ScrollBarImageColor3 = theme.Stroke,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = self.ContentHolder,
	})
	local pageScale = addScale(page, 1)
	padding(page, pagePadding, pagePadding, isTopNavigation and 14 or pagePadding, pagePadding)

	local layout = list(page, Enum.FillDirection.Vertical, 10)
	local layoutConnection = self:_connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 32)
	end)

	local tab = setmetatable({
		Name = options.Name,
		_window = self,
		_container = page,
		_page = page,
		_pageScale = pageScale,
		_button = tabButton,
		_title = title,
		_icon = icon,
	}, {
		__index = HostMethods,
	})

	table.insert(self.Tabs, tab)
	trackConnection(tab, layoutConnection)
	attachTooltip(self, tab, tabButton, tostring(options.Name or "Tab"))

	if self.NavigationStyle == "Sidebar" and self.SidebarAutoWidth ~= false then
		local desiredWidth = math.clamp(58 + (#tostring(options.Name or "") * 7), self.MinSidebarWidth or 188, self.MaxSidebarWidth or 260)
		self:_updateSidebarWidth(desiredWidth)
	end

	connectScoped(self, tab, tabButton.MouseButton1Click, function()
		if self.Animations then
			pressScale(tabScale)
		end

		self:_setTabActive(tab)
	end)

	if not self.ActiveTab then
		self:_setTabActive(tab)
	end

	return tab
end

local function createWindowGui(config, theme)
	local isMobile = config._Mobile == true
	local density = normalizeDensity(config.Density)
	local metrics = getDensityMetrics(density, isMobile)
	local topbarButtonSize = isMobile and 38 or 30
	local controlsWidth = (topbarButtonSize * 3) + 16
	local resizeHitSize = isMobile and 38 or 30

	local gui = create("ScreenGui", {
		Name = config.Name and (config.Name:gsub("%s+", "") .. "Gui") or "BlueskyGui",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	gui.Parent = config.Parent or getProtectedParent(gui) or getGuiParent()

	local main = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Background,
		Position = config.Position or UDim2.fromScale(0.5, 0.5),
		Size = config.Size or UDim2.fromOffset(620, 420),
		Parent = gui,
	})
	corner(main, 10)
	stroke(main, theme.Stroke, 0.1, nil)

	local topbar = create("Frame", {
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 48),
		Parent = main,
	})
	corner(topbar, 10)

	create("Frame", {
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -10),
		Size = UDim2.new(1, 0, 0, 10),
		Parent = topbar,
	})

	local searchEnabled = config.Search ~= false
	local titleWidth = searchEnabled and (config.TitleWidth or 190) or nil
	local searchHolder = nil

	local titleWrap = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0),
		Size = searchEnabled and UDim2.fromOffset(titleWidth, 48) or UDim2.new(1, -110, 1, 0),
		Parent = topbar,
	})
	list(titleWrap, Enum.FillDirection.Horizontal, 8).VerticalAlignment = Enum.VerticalAlignment.Center

	mountIcon(Bluesky, titleWrap, config.Icon, theme, 20, 1)

	local titleStack = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, config.Icon and -30 or 0, 1, 0),
		LayoutOrder = 2,
		Parent = titleWrap,
	})

	local titleLabel = makeText(titleStack, config.Name or "Bluesky UI", 15, theme.Text, {
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(0, config.Subtitle and 6 or 0),
		Size = UDim2.new(1, 0, 0, config.Subtitle and 20 or 48),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local subtitleLabel = nil
	if config.Subtitle then
		subtitleLabel = makeText(titleStack, config.Subtitle, 11, theme.SubText, {
			Position = UDim2.fromOffset(0, 25),
			Size = UDim2.new(1, 0, 0, 16),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
	end

	local searchBox = nil
	if searchEnabled then
		searchHolder = create("Frame", {
			BackgroundColor3 = theme.Item,
			Position = UDim2.fromOffset(titleWidth + 24, 9),
			Size = UDim2.new(1, -(titleWidth + controlsWidth + 60), 0, 30),
			Parent = topbar,
		})
		corner(searchHolder, 8)
		stroke(searchHolder, theme.Stroke, 0.55, nil)
		padding(searchHolder, 10, 10, 0, 0)

		searchBox = create("TextBox", {
			BackgroundTransparency = 1,
			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			PlaceholderText = config.SearchPlaceholder or "Type keywords...",
			PlaceholderColor3 = theme.SubText,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			TextColor3 = theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = searchHolder,
		})
	end

	local controls = create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(controlsWidth, topbarButtonSize),
		Parent = topbar,
	})
	list(controls, Enum.FillDirection.Horizontal, 8).HorizontalAlignment = Enum.HorizontalAlignment.Right

	local minimize = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.Item,
		Text = "-",
		TextColor3 = theme.SubText,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		Size = UDim2.fromOffset(topbarButtonSize, topbarButtonSize),
		Parent = controls,
	})
	corner(minimize, 8)

	local maximize = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.Item,
		Text = "[]",
		TextColor3 = theme.SubText,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		Size = UDim2.fromOffset(topbarButtonSize, topbarButtonSize),
		Parent = controls,
	})
	corner(maximize, 8)

	local close = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.Item,
		Text = "x",
		TextColor3 = theme.SubText,
		TextSize = 15,
		Font = Enum.Font.GothamBold,
		Size = UDim2.fromOffset(topbarButtonSize, topbarButtonSize),
		Parent = controls,
	})
	corner(close, 8)

	local resizeHandle = create("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Active = true,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -2, 1, -2),
		Size = UDim2.fromOffset(resizeHitSize, resizeHitSize),
		Text = "",
		Visible = config.Resizable ~= false,
		ZIndex = 60,
		Parent = main,
	})

	local gripSize = isMobile and 22 or 18
	local dotSize = isMobile and 4 or 3
	local grip = create("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -7, 1, -7),
		Size = UDim2.fromOffset(gripSize, gripSize),
		ZIndex = 61,
		Parent = resizeHandle,
	})

	local dotGap = isMobile and 7 or 6
	local gripDots = {
		{ 2 + (dotGap * 2), 2, 0.38 },
		{ 2 + dotGap, 2 + dotGap, 0.46 },
		{ 2 + (dotGap * 2), 2 + dotGap, 0.18 },
		{ 2, 2 + (dotGap * 2), 0.62 },
		{ 2 + dotGap, 2 + (dotGap * 2), 0.24 },
		{ 2 + (dotGap * 2), 2 + (dotGap * 2), 0.08 },
	}

	for _, dot in ipairs(gripDots) do
		local gripDot = create("Frame", {
			Name = "ResizeGripDot",
			BackgroundColor3 = theme.SubText,
			BackgroundTransparency = dot[3],
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(dot[1], dot[2]),
			Size = UDim2.fromOffset(dotSize, dotSize),
			ZIndex = 61,
			Parent = grip,
		})
		gripDot:SetAttribute("DefaultTransparency", dot[3])
		corner(gripDot, math.ceil(dotSize / 2))
	end

	local minimizedButton = create("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = theme.Surface,
		Position = config.MinimizedPosition or UDim2.new(0, 34, 0.5, 0),
		Size = UDim2.fromOffset(config.MinimizedSize or 48, config.MinimizedSize or 48),
		Text = "",
		Visible = false,
		Parent = gui,
	})
	corner(minimizedButton, 12)
	stroke(minimizedButton, theme.Stroke, 0.1, nil)

	local minimizedIcon = config.MinimizedIcon or config.Icon or {
		Text = string.sub(tostring(config.Name or "B"), 1, 1),
	}
	local minimizedIconHolder = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(22, 22),
		Parent = minimizedButton,
	})
	mountIcon(Bluesky, minimizedIconHolder, minimizedIcon, theme, 22, 1)

	local body = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 48),
		Size = UDim2.new(1, 0, 1, -48),
		Parent = main,
	})

	local navigationStyle = config.Navigation or config.NavigationStyle or "Sidebar"
	if type(navigationStyle) == "string" and navigationStyle:lower() == "top" then
		navigationStyle = "Top"
	else
		navigationStyle = "Sidebar"
	end

	local tabList
	local contentHolder
	local sidebar = nil

	if navigationStyle == "Top" then
		local tabBar = create("Frame", {
			BackgroundColor3 = theme.Surface,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 50),
			Parent = body,
		})
		padding(tabBar, 12, 12, 8, 8)

		tabList = create("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.fromOffset(0, 0),
			ScrollBarImageColor3 = theme.Stroke,
			ScrollBarThickness = isMobile and 4 or 2,
			ScrollingDirection = Enum.ScrollingDirection.X,
			Size = UDim2.fromScale(1, 1),
			Parent = tabBar,
		})
		local tabLayout = list(tabList, Enum.FillDirection.Horizontal, 8)
		tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

		create("Frame", {
			BackgroundColor3 = theme.Stroke,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -1),
			Size = UDim2.new(1, 0, 0, 1),
			Parent = tabBar,
		})

		contentHolder = create("Frame", {
			BackgroundColor3 = theme.Background,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 50),
			Size = UDim2.new(1, 0, 1, -50),
			Parent = body,
		})
	else
		sidebar = create("Frame", {
			BackgroundColor3 = theme.Surface,
			BorderSizePixel = 0,
			Size = UDim2.new(0, config.SidebarWidth or 204, 1, 0),
			Parent = body,
		})
		padding(sidebar, metrics.SectionPadding, metrics.SectionPadding, 12, 12)

		tabList = create("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.fromOffset(0, 0),
			ScrollBarImageColor3 = theme.Stroke,
			ScrollBarThickness = isMobile and 5 or 3,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Size = UDim2.fromScale(1, 1),
			Parent = sidebar,
		})
		list(tabList, Enum.FillDirection.Vertical, 8)

		contentHolder = create("Frame", {
			BackgroundColor3 = theme.Background,
			BorderSizePixel = 0,
			Position = UDim2.new(0, config.SidebarWidth or 204, 0, 0),
			Size = UDim2.new(1, -(config.SidebarWidth or 204), 1, 0),
			Parent = body,
		})
	end

	local notifications = create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -14, 1, -14),
		Size = UDim2.fromOffset(config.NotificationWidth or 260, config.NotificationHeight or 180),
		Parent = gui,
	})
	local notificationLayout = list(notifications, Enum.FillDirection.Vertical, 6)
	notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	local responsive = {
		TitleWrap = titleWrap,
		TitleLabel = titleLabel,
		SubtitleLabel = subtitleLabel,
		SearchHolder = searchHolder,
		Controls = controls,
		TitleWidth = titleWidth,
	}

	return gui, main, topbar, body, tabList, contentHolder, notifications, minimize, maximize, close, minimizedButton, resizeHandle, navigationStyle, searchBox, sidebar, responsive
end

function Bluesky:CreateWindow(config)
	if self ~= Bluesky and config == nil then
		config = self
	end

	config = config or {}
	local guiName = config.Name and (config.Name:gsub("%s+", "") .. "Gui") or "BlueskyGui"
	local parent = config.Parent or getProtectedParent() or getGuiParent()
	local oldGui = parent:FindFirstChild(guiName)
	if oldGui then
		oldGui:Destroy()
	end

	if config.ToggleUIKeybind ~= nil and config.ToggleKey == nil then
		config.ToggleKey = config.ToggleUIKeybind
	end
	config.ToggleKey = parseKeyCode(config.ToggleKey)
	if config.Title ~= nil and config.Name == nil then
		config.Name = config.Title
	end
	if config.LoadingTitle ~= nil and config.Name == nil then
		config.Name = config.LoadingTitle
	end
	if config.LoadingSubtitle ~= nil and config.Subtitle == nil then
		config.Subtitle = config.LoadingSubtitle
	end
	if config.Icon == nil and config.WindowIcon ~= nil then
		config.Icon = config.WindowIcon
	end
	config.Density = normalizeDensity(config.Density)
	config.Name = ensureType(config.Name, "string", "CreateWindow.Name", config.Name)
	config.Subtitle = ensureType(config.Subtitle, "string", "CreateWindow.Subtitle", config.Subtitle)
	config.Size = ensureType(config.Size, "UDim2", "CreateWindow.Size", config.Size)
	config.Position = ensureType(config.Position, "UDim2", "CreateWindow.Position", config.Position)
	config.Animations = ensureType(config.Animations, "boolean", "CreateWindow.Animations", config.Animations)
	config.Search = ensureType(config.Search, "boolean", "CreateWindow.Search", config.Search)
	config.ConfigurationSaving = ensureType(config.ConfigurationSaving, "table", "CreateWindow.ConfigurationSaving", config.ConfigurationSaving)
	config.Discord = ensureType(config.Discord, "table", "CreateWindow.Discord", config.Discord)
	config.KeySettings = ensureType(config.KeySettings, "table", "CreateWindow.KeySettings", config.KeySettings)
	local secureGlobal = readGlobalFlag("BLUESKY_SECURE") == true
	local assetMode = type(config.AssetMode) == "string" and string.lower(config.AssetMode) or ""
	local hasSecureConfig = config.SecureMode ~= nil or config.Secure ~= nil or assetMode ~= ""
	local requestedSecure = secureGlobal or config.SecureMode == true or assetMode == "secure" or config.Secure == true
	if hasSecureConfig then
		Bluesky.SecureMode = requestedSecure
	else
		Bluesky.SecureMode = Bluesky.SecureMode == true or secureGlobal
	end
	if config.RemoteIcons ~= nil or config.DisableRemoteIcons ~= nil then
		Bluesky.RemoteIconsEnabled = config.RemoteIcons ~= false and config.DisableRemoteIcons ~= true
	end
	if Bluesky.SecureMode then
		Bluesky.RemoteIconsEnabled = false
	end

	local isMobile = config.Mobile ~= false and UserInputService.TouchEnabled == true
	if isMobile then
		local viewport = getViewportSize()
		if config.Size == nil then
			local mobileWidth = math.min(math.clamp(viewport.X * 0.72, 340, 560), math.max(300, viewport.X - 20))
			local mobileHeight = math.min(math.clamp(viewport.Y * 0.72, 280, 380), math.max(260, viewport.Y - 40))
			config.Size = UDim2.fromOffset(mobileWidth, mobileHeight)
		end
		if config.SidebarWidth == nil then
			config.SidebarWidth = 156
		end
		if config.NotificationWidth == nil then
			config.NotificationWidth = 220
		end
		if config.MinimizedSize == nil then
			config.MinimizedSize = 46
		end
	end
	if not isMobile and config.SidebarWidth == nil then
		config.SidebarWidth = 204
	end
	config._Mobile = isMobile
	config._Density = config.Density
	local metrics = getDensityMetrics(config.Density, isMobile)

	local theme = copyTheme(config.Theme)

	local window = setmetatable({
		Theme = theme,
		Flags = {},
		Controls = {},
		FlagChanged = {},
		_connections = {},
	}, {
		__index = WindowMethods,
	})

	local gui, main, topbar, body, tabList, contentHolder, notifications, minimize, maximize, close, minimizedButton, resizeHandle, navigationStyle, searchBox, sidebar, responsive = createWindowGui(config, theme)
	local animations = config.Animations ~= false
	local mainScale = addScale(main, animations and 0.96 or 1)
	local minimizeScale = addScale(minimize, 1)
	local maximizeScale = addScale(maximize, 1)
	local closeScale = addScale(close, 1)
	local minimizedScale = addScale(minimizedButton, 1)

	window.Name = config.Name or "Bluesky UI"
	window.Gui = gui
	window.Main = main
	window.Topbar = topbar
	window.Body = body
	window.Sidebar = sidebar
	window.TabList = tabList
	window.ContentHolder = contentHolder
	window.NotificationHolder = notifications
	window.MinimizedButton = minimizedButton
	window.ResizeHandle = resizeHandle
	window.MinimizedPosition = config.MinimizedPosition or UDim2.new(0, 34, 0.5, 0)
	window.MinWindowSize = config.MinWindowSize or config.MinimumSize or Vector2.new(isMobile and 300 or 420, isMobile and 240 or 280)
	window.FullscreenMargin = config.FullscreenMargin or (isMobile and 10 or 18)
	window.Resizable = config.Resizable ~= false
	window.SearchBox = searchBox
	window.SearchEnabled = config.Search ~= false
	window.SearchQuery = ""
	window.SearchItems = {}
	window.SearchSections = {}
	window.MainScale = mainScale
	window.MinimizedScale = minimizedScale
	window.NavigationStyle = navigationStyle
	window.Density = config.Density
	window.ButtonHeight = metrics.ButtonHeight
	window.ToggleHeight = metrics.ToggleHeight
	window.InputHeight = metrics.InputHeight
	window.InputBaseHeight = metrics.InputBaseHeight
	window.InputDescriptionHeight = metrics.InputDescriptionHeight
	window.DropdownHeight = metrics.DropdownHeight
	window.DropdownOptionHeight = metrics.DropdownOptionHeight
	window.TabHeight = metrics.TabHeight
	window.TabTopHeight = metrics.TabTopHeight
	window.PagePadding = metrics.PagePadding
	window.SectionPadding = metrics.SectionPadding
	window.SidebarWidth = config.SidebarWidth or (isMobile and 156 or 204)
	if config.SidebarWidth == nil and not isMobile then
		window.SidebarWidth = 204
	end
	window.MinSidebarWidth = config.MinSidebarWidth or (isMobile and 144 or 188)
	window.MaxSidebarWidth = config.MaxSidebarWidth or (isMobile and 180 or 260)
	window.MinContentWidth = config.MinContentWidth or (isMobile and 176 or 190)
	window.SidebarAutoWidth = config.SidebarAutoWidth ~= false
	window.SidebarCollapsedWidth = config.SidebarCollapsedWidth or 58
	window.SidebarCollapsed = false
	window.TopbarTitleWrap = responsive and responsive.TitleWrap
	window.TopbarTitleLabel = responsive and responsive.TitleLabel
	window.TopbarSubtitleLabel = responsive and responsive.SubtitleLabel
	window.SearchHolder = responsive and responsive.SearchHolder
	window.TopbarControls = responsive and responsive.Controls
	window.TitleWidth = responsive and responsive.TitleWidth
	window.Animations = animations
	window.Tabs = {}
	window.ActiveTab = nil
	window.ConfigSavingEnabled = (config.ConfigurationSaving and config.ConfigurationSaving.Enabled) == true
	window.ConfigFolder = ((config.ConfigurationSaving and config.ConfigurationSaving.FolderName) or "BlueskyUI")
	window.ConfigFileName = ((config.ConfigurationSaving and config.ConfigurationSaving.FileName) or "default")
	window.AutoSaveConfig = window.ConfigSavingEnabled and (config.ConfigurationSaving and config.ConfigurationSaving.AutoSave) == true
	window.AutoSaveDelay = (config.ConfigurationSaving and config.ConfigurationSaving.AutoSaveDelay) or 0.8
	window.SaveWindowState = window.ConfigSavingEnabled and (config.ConfigurationSaving and config.ConfigurationSaving.SaveWindowState) == true
	window.Mobile = isMobile
	window.ShowText = tostring(config.ShowText or config.Name or "Bluesky")
	window.Visible = true
	window.Minimized = false
	window.Maximized = false
	window.OpenDropdowns = {}
	window.MaxNotifications = tonumber(config.MaxNotifications) or 4

	window:_refreshResponsiveLayout()
	window:_connect(main:GetPropertyChangedSignal("AbsoluteSize"), function()
		window:_refreshResponsiveLayout()
	end)

	if config.SidebarCollapsed == true or (isMobile and config.MobileCollapsedSidebar == true) then
		window:SetSidebarCollapsed(true)
	end

	window:_makeDraggable(topbar, main)
	window:_makeDraggable(minimizedButton, minimizedButton)
	if window.Resizable then
		window:_makeResizable(resizeHandle, main)
	end

	if animations then
		tween(mainScale, TWEEN_OPEN, {
			Scale = 1,
		})
	end

	window:_connect(minimize.MouseButton1Click, function()
		if window.Animations then
			pressScale(minimizeScale)
		end

		window:Minimize()
	end)

	window:_connect(maximize.MouseButton1Click, function()
		if window.Animations then
			pressScale(maximizeScale)
		end

		window:ToggleMaximize()
	end)

	local miniPressPosition = nil
	local miniWasDragged = false

	window:_connect(minimizedButton.InputBegan, function(input)
		if not isInputStart(input) then
			return
		end

		miniPressPosition = input.Position
		miniWasDragged = false
	end)

	window:_connect(UserInputService.InputChanged, function(input)
		if not miniPressPosition then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			miniWasDragged = (input.Position - miniPressPosition).Magnitude > 6
		end
	end)

	window:_connect(minimizedButton.InputEnded, function(input)
		if not isInputStart(input) then
			return
		end

		if not miniWasDragged then
			if window.Animations then
				pressScale(minimizedScale)
			end

			window:Restore()
		end

		miniPressPosition = nil
		miniWasDragged = false
	end)

	window:_connect(close.MouseButton1Click, function()
		if window.Animations then
			pressScale(closeScale)
		end

		if config.ConfirmClose == true then
			window:Confirm({
				Name = "Close Window",
				Content = "Close this UI window?",
				ConfirmText = "Close",
				CancelText = "Cancel",
				Color = window.Theme.Danger,
				OnConfirm = function()
					window:Destroy()
				end,
			})
		else
			window:Destroy()
		end
	end)

	setButtonHover(window, minimize, "Item", "ItemHover")
	setButtonHover(window, maximize, "Item", "ItemHover")
	setButtonHover(window, close, "Item", "Danger")
	setButtonHover(window, minimizedButton, "Surface", "ItemHover")

	local function tintResizeGrip(color, focused)
		for _, descendant in ipairs(resizeHandle:GetDescendants()) do
			if descendant.Name == "ResizeGripDot" then
				tween(descendant, TWEEN_FAST, {
					BackgroundColor3 = color,
					BackgroundTransparency = focused and 0.04 or (descendant:GetAttribute("DefaultTransparency") or 0.24),
				})
			end
		end
	end

	window:_connect(resizeHandle.MouseEnter, function()
		tintResizeGrip(window.Theme.Accent, true)
	end)

	window:_connect(resizeHandle.MouseLeave, function()
		tintResizeGrip(window.Theme.SubText, false)
	end)

	window:_connect(UserInputService.InputBegan, function(input)
		window:_closeDropdownsAt(input)
		if input.UserInputType == Enum.UserInputType.Keyboard and not UserInputService:GetFocusedTextBox() then
			if input.KeyCode == Enum.KeyCode.Escape then
				if window.ActiveModal and type(window.ActiveModal.Cancel) == "function" then
					window.ActiveModal:Cancel()
				else
					window:_closeDropdownsExcept(nil)
				end
			elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
				if window.ActiveModal and type(window.ActiveModal.Confirm) == "function" then
					window.ActiveModal:Confirm()
				end
			end
		end
	end)

	window:_connect(UserInputService.InputChanged, function(input)
		if window.TooltipText
			and window.TooltipFrame
			and window.TooltipFrame.Visible
			and input.UserInputType == Enum.UserInputType.MouseMovement
		then
			window:_showTooltip(window.TooltipText)
		end
	end)

	if searchBox then
		local searchScale = addScale(searchBox.Parent, 1)

		window:_connect(searchBox:GetPropertyChangedSignal("Text"), function()
			window:_applySearch(searchBox.Text)
		end)

		window:_connect(searchBox.Focused, function()
			if window.Animations then
				tween(searchScale, TWEEN_FAST, {
					Scale = 1.01,
				})
			end

			tween(searchBox.Parent, TWEEN_FAST, {
				BackgroundColor3 = window.Theme.ItemHover,
			})
		end)

		window:_connect(searchBox.FocusLost, function()
			if window.Animations then
				tween(searchScale, TWEEN_FAST, {
					Scale = 1,
				})
			end

			tween(searchBox.Parent, TWEEN_FAST, {
				BackgroundColor3 = window.Theme.Item,
			})
		end)
	end

	if config.ToggleKey then
		window:_connect(UserInputService.InputBegan, function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == config.ToggleKey then
				window:Toggle()
			end
		end)
	end

	if window.ConfigSavingEnabled and (config.ConfigurationSaving and config.ConfigurationSaving.AutoLoad) == true then
		local okLoad, err = window:LoadConfig(window.ConfigFileName)
		if not okLoad then
			devWarn("AutoLoad config failed: " .. tostring(err))
		end
	end

	if config.KeySystem == true then
		createKeyGate(window, config)
	end

	promptDiscordInvite(config.Discord)

	Bluesky.CurrentWindow = window
	return window
end

local function createContainer(parent, theme, height)
	local item = create("Frame", {
		BackgroundColor3 = theme.Item,
		Size = UDim2.new(1, 0, 0, height),
		Parent = parent,
	})
	corner(item, 8)
	stroke(item, theme.Stroke, 0.35)
	return item
end

function HostMethods:CreateSection(options, icon)
	if type(options) == "string" then
		options = {
			Name = options,
			Icon = icon,
		}
	else
		options = normalizeOptions(options, "Section")
		if options.Icon == nil and icon ~= nil then
			options.Icon = icon
		end
	end
	local theme = self._window.Theme
	local collapsible = options.Collapsible == true or options.Collapsed ~= nil

	local section = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Surface,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = self._container,
	})
	corner(section, 8)
	stroke(section, theme.Stroke, 0.25)
	local sectionPadding = self._window.SectionPadding or 10
	padding(section, sectionPadding, sectionPadding, sectionPadding, sectionPadding)

	local sectionLayout = list(section, Enum.FillDirection.Vertical, 8)

	local header = create("Frame", {
		Active = collapsible,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		LayoutOrder = 1,
		Parent = section,
	})
	list(header, Enum.FillDirection.Horizontal, 6, Enum.VerticalAlignment.Center)

	if options.Icon then
		mountIcon(Bluesky, header, options.Icon, theme, 16, 1)
	end

	local title = makeText(header, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamBold,
		LayoutOrder = 2,
		Size = UDim2.new(1, options.Icon and (collapsible and -48 or -24) or (collapsible and -24 or 0), 1, 0),
	})

	local collapseArrow = nil
	if collapsible then
		collapseArrow = makeText(header, "v", 12, theme.SubText, {
			Font = Enum.Font.GothamBold,
			LayoutOrder = 3,
			Rotation = options.Collapsed and -90 or 0,
			Size = UDim2.fromOffset(18, 18),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end

	local content = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = 2,
		Visible = options.Collapsed ~= true,
		Parent = section,
	})

	if options.Columns and options.Columns > 1 then
		local grid = create("UIGridLayout", {
			CellPadding = UDim2.fromOffset(8, 8),
			CellSize = UDim2.new(1 / options.Columns, -(((options.Columns - 1) * 8) / options.Columns), 0, 38), -- Optimized for small controls
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = content,
		})
		-- Auto-adjust height for non-fixed components could be complex, 
		-- but for Phase 3 we'll support fixed-height small controls in grid.
	else
		list(content, Enum.FillDirection.Vertical, 8)
	end

	local sectionInfo = {
		Name = searchText(options.Name),
		Frame = section,
		Items = {},
	}
	table.insert(self._window.SearchSections, sectionInfo)

	local sectionHost = setmetatable({
		Name = options.Name,
		_window = self._window,
		_container = content,
		_section = section,
		_sectionInfo = sectionInfo,
		_title = title,
		_content = content,
		_collapseArrow = collapseArrow,
		Collapsed = options.Collapsed == true,
		_layout = sectionLayout,
	}, {
		__index = HostMethods,
	})

	if collapsible then
		connectScoped(self._window, sectionHost, header.InputBegan, function(input)
			if isInputStart(input) then
				sectionHost:ToggleCollapse()
			end
		end)
	end

	return sectionHost
end

function HostMethods:Set(name)
	if self._title then
		self.Name = tostring(name or "")
		self._title.Text = self.Name
	end

	return self
end

function HostMethods:SetVisible(visible)
	local target = self._section or self.Instance
	if target then
		target.Visible = visible ~= false
	end

	return self
end

function HostMethods:Collapse(collapsed)
	if not self._content then
		return self
	end

	self.Collapsed = collapsed ~= false
	self._content.Visible = not self.Collapsed

	if self._collapseArrow then
		if self._window and self._window.Animations then
			tween(self._collapseArrow, TWEEN_FAST, {
				Rotation = self.Collapsed and -90 or 0,
			})
		else
			self._collapseArrow.Rotation = self.Collapsed and -90 or 0
		end
	end

	return self
end

function HostMethods:Expand()
	return self:Collapse(false)
end

function HostMethods:ToggleCollapse()
	return self:Collapse(not self.Collapsed)
end

function HostMethods:Destroy()
	disconnectConnections(self._connections)

	if self._button and self._page and self._window then
		local wasActive = self._window.ActiveTab == self

		for index, tab in ipairs(self._window.Tabs) do
			if tab == self then
				table.remove(self._window.Tabs, index)
				break
			end
		end

		if self._button then
			self._button:Destroy()
		end
		if self._page then
			self._page:Destroy()
		end

		if wasActive then
			self._window.ActiveTab = nil
			if self._window.Tabs[1] then
				self._window:_setTabActive(self._window.Tabs[1])
			end
		end

		return
	end

	if self._section then
		self._section:Destroy()
	end
end

function HostMethods:CreateDivider(options)
	options = normalizeOptions(options, "Divider")
	local window = self._window
	local theme = window.Theme

	local wrap = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Parent = self._container,
	})

	create("Frame", {
		BackgroundColor3 = theme.Stroke,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = wrap,
	})

	if options.Name and options.Name ~= "Divider" then
		local pill = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = theme.Surface,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.fromOffset(math.clamp((#tostring(options.Name) * 7) + 16, 36, 180), 18),
			Parent = wrap,
		})
		corner(pill, 9)

		makeText(pill, options.Name, 11, theme.SubText, {
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end

	local control = {
		Instance = wrap,
	}

	function control:Set(visible)
		wrap.Visible = visible ~= false
	end

	function control:Destroy()
		wrap:Destroy()
	end

	return attachControlBase(control, wrap)
end

function HostMethods:CreateLabel(options)
	options = normalizeOptions(options, "Label")
	local window = self._window
	local theme = window.Theme
	local description = options.Content or options.Text or options.Description
	local hasDescription = description ~= nil and tostring(description) ~= ""
	local height = hasDescription and (tonumber(options.Height) or 56) or (tonumber(options.Height) or 34)

	local item = createContainer(self._container, theme, height)
	padding(item, 12, 12, hasDescription and 8 or 0, hasDescription and 8 or 0)

	local row = create("Frame", {
		BackgroundTransparency = 1,
		Size = hasDescription and UDim2.new(1, 0, 0, 20) or UDim2.fromScale(1, 1),
		Parent = item,
	})
	list(row, Enum.FillDirection.Horizontal, 8, Enum.VerticalAlignment.Center)

	local icon = mountIcon(Bluesky, row, options.Icon, theme, 16, 1)
	local label = makeText(row, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamMedium,
		LayoutOrder = 2,
		Size = UDim2.new(1, icon and -24 or 0, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local subLabel = nil
	if hasDescription then
		subLabel = makeText(item, tostring(description), 11, theme.SubText, {
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, 0, 0, 18),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
	end

	local control = {
		Instance = item,
		Value = options.Name,
	}

	function control:Set(text)
		self.Value = tostring(text or "")
		label.Text = self.Value
		return self
	end

	function control:SetContent(text)
		if subLabel then
			subLabel.Text = tostring(text or "")
		end
		return self
	end

	function control:Destroy()
		item:Destroy()
	end

	window:_registerSearchItem(options.Name, item, self._sectionInfo)
	attachTooltip(window, control, item, options.Tooltip)
	return attachControlBase(control, item)
end

function HostMethods:CreateImage(options)
	options = normalizeOptions(options, "Image")
	local window = self._window
	local theme = window.Theme
	local source = options.Image or options.Asset or options.Source
	local height = tonumber(options.Height) or 118

	local item = create("Frame", {
		BackgroundColor3 = theme.Item,
		Size = UDim2.new(1, 0, 0, height),
		Parent = self._container,
	})
	corner(item, 8)
	stroke(item, theme.Stroke, 0.35, nil)
	padding(item, 10, 10, 10, 10)

	local image = create("ImageLabel", {
		BackgroundColor3 = theme.SurfaceAlt,
		Image = "",
		ScaleType = options.ScaleType or Enum.ScaleType.Crop,
		Size = UDim2.fromScale(1, 1),
		Parent = item,
	})
	corner(image, 7)

	local control = {
		Instance = item,
		Value = source,
		Image = image,
	}

	function control:SetImage(nextSource)
		self.Value = nextSource
		if Bluesky.SecureMode and isDetectableAsset(nextSource) then
			image.Image = ""
			return self
		end

		image.Image = formatAssetId(nextSource) or tostring(nextSource or "")
		return self
	end

	function control:Set(nextSource)
		return self:SetImage(nextSource)
	end

	function control:Destroy()
		item:Destroy()
	end

	control:SetImage(source)
	window:_registerSearchItem(options.Name, item, self._sectionInfo)
	return attachControlBase(control, item)
end

function HostMethods:CreateCard(options)
	options = normalizeOptions(options, "Card")
	local window = self._window
	local theme = window.Theme

	local item = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Item,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = self._container,
	})
	corner(item, 8)
	stroke(item, theme.Stroke, 0.35, nil)
	padding(item, 12, 12, 10, 10)
	list(item, Enum.FillDirection.Vertical, 6)

	local header = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Parent = item,
	})
	list(header, Enum.FillDirection.Horizontal, 8, Enum.VerticalAlignment.Center)

	local icon = mountIcon(Bluesky, header, options.Icon, theme, 16, 1)
	local title = makeText(header, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamBold,
		LayoutOrder = 2,
		Size = UDim2.new(1, icon and -24 or 0, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local content = makeText(item, options.Content or options.Text or "", 12, theme.SubText, {
		AutomaticSize = Enum.AutomaticSize.Y,
		RichText = true,
		Size = UDim2.new(1, 0, 0, 0),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	})

	local control = {
		Instance = item,
		Value = options.Content or options.Text or "",
	}

	function control:SetTitle(text)
		title.Text = tostring(text or "")
		return self
	end

	function control:SetContent(text)
		self.Value = tostring(text or "")
		content.Text = self.Value
		return self
	end

	function control:Set(nextValue)
		if type(nextValue) == "table" then
			if nextValue.Title or nextValue.Name then
				self:SetTitle(nextValue.Title or nextValue.Name)
			end
			if nextValue.Content or nextValue.Text then
				self:SetContent(nextValue.Content or nextValue.Text)
			end
		else
			self:SetContent(nextValue)
		end
		return self
	end

	function control:Destroy()
		item:Destroy()
	end

	window:_registerSearchItem(options.Name, item, self._sectionInfo)
	return attachControlBase(control, item)
end

function HostMethods:CreateColorPicker(options)
	options = normalizeOptions(options, "Color")
	options.Callback = ensureType(options.Callback, "function", "CreateColorPicker.Callback", options.Callback)
	local window = self._window
	local theme = window.Theme

	local initial = options.Color or options.CurrentValue or options.Default or Color3.fromRGB(255, 255, 255)
	if typeof(initial) ~= "Color3" then
		initial = Color3.fromRGB(255, 255, 255)
	end
	local fireOnDrag = options.FireOnDrag ~= false
	local hue, saturation, value = initial:ToHSV()

	local item = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Item,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = self._container,
	})
	corner(item, 8)
	stroke(item, theme.Stroke, 0.35, nil)
	padding(item, 0, 0, 0, 8)
	list(item, Enum.FillDirection.Vertical, 0)

	local header = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, 0, 0, 44),
		Parent = item,
	})
	padding(header, 12, 12, 0, 0)

	makeText(header, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(1, -64, 1, 0),
	})

	local preview = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = initial,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(36, 20),
		Parent = header,
	})
	corner(preview, 6)
	stroke(preview, theme.Stroke, 0.2, nil)

	local panel = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 168),
		Visible = false,
		Parent = item,
	})
	padding(panel, 10, 10, 2, 0)
	list(panel, Enum.FillDirection.Vertical, 6)

	local pickerRow = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 116),
		Parent = panel,
	})

	local colorSquare = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
		Text = "",
		Size = UDim2.new(1, -28, 1, 0),
		Parent = pickerRow,
	})
	corner(colorSquare, 6)
	stroke(colorSquare, theme.Stroke, 0.35, nil)

	local whiteOverlay = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = colorSquare,
	})
	corner(whiteOverlay, 6)
	create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = whiteOverlay,
	})

	local blackOverlay = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = colorSquare,
	})
	corner(blackOverlay, 6)
	create("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = blackOverlay,
	})

	local squareSelector = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(saturation, 1 - value),
		Size = UDim2.fromOffset(12, 12),
		Parent = colorSquare,
	})
	corner(squareSelector, 6)
	stroke(squareSelector, Color3.fromRGB(255, 255, 255), 0, 2)

	local hueSlider = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(18, 116),
		Text = "",
		Parent = pickerRow,
	})
	corner(hueSlider, 6)
	stroke(hueSlider, theme.Stroke, 0.35, nil)
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Rotation = 90,
		Parent = hueSlider,
	})

	local hueMarker = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Text,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, hue, 0),
		Size = UDim2.new(1, 6, 0, 3),
		Parent = hueSlider,
	})
	corner(hueMarker, 2)

	local channelRow = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 28),
		Parent = panel,
	})
	list(channelRow, Enum.FillDirection.Horizontal, 6)

	local function channelInput(labelText, valueText)
		local box = create("TextBox", {
			BackgroundColor3 = theme.SurfaceAlt,
			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			PlaceholderText = labelText,
			PlaceholderColor3 = theme.SubText,
			Text = valueText,
			TextColor3 = theme.Text,
			TextSize = 11,
			Size = UDim2.new(1 / 3, -4, 1, 0),
			Parent = channelRow,
		})
		corner(box, 5)
		stroke(box, theme.Stroke, 0.45, nil)
		padding(box, 6, 6, 0, 0)
		return box
	end

	local red = channelInput("R", "R " .. tostring(math.floor(initial.R * 255 + 0.5)))
	local green = channelInput("G", "G " .. tostring(math.floor(initial.G * 255 + 0.5)))
	local blue = channelInput("B", "B " .. tostring(math.floor(initial.B * 255 + 0.5)))

	local open = false
	local draggingSquare = false
	local draggingHue = false
	local control = {
		Instance = item,
		Value = initial,
		Disabled = options.Disabled == true,
		Callback = options.Callback,
	}

	local function channelText(prefix, amount)
		return prefix .. " " .. tostring(math.floor(amount * 255 + 0.5))
	end

	local function syncVisuals(color)
		local nextHue, nextSaturation, nextValue = color:ToHSV()
		hue = nextHue
		saturation = nextSaturation
		value = nextValue

		preview.BackgroundColor3 = color
		colorSquare.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		squareSelector.Position = UDim2.fromScale(saturation, 1 - value)
		hueMarker.Position = UDim2.new(0.5, 0, hue, 0)
		red.Text = channelText("R", color.R)
		green.Text = channelText("G", color.G)
		blue.Text = channelText("B", color.B)
	end

	local function setFromHueSaturationValue(invoke)
		control:Set(Color3.fromHSV(hue, saturation, value), invoke)
	end

	function control:Set(color, invoke)
		if typeof(color) ~= "Color3" then
			return self
		end

		self.Value = color
		syncVisuals(color)
		window:_setFlag(options.Flag, color)

		if invoke ~= false then
			safeCall(self.Callback, color)
		end

		return self
	end

	function control:Destroy()
		item:Destroy()
	end

	local function numberFromBox(box)
		return tonumber(tostring(box.Text or ""):match("%d+")) or 0
	end

	local function applyRgb()
		if control.Disabled then
			return
		end

		local r = math.clamp(numberFromBox(red), 0, 255)
		local g = math.clamp(numberFromBox(green), 0, 255)
		local b = math.clamp(numberFromBox(blue), 0, 255)
		control:Set(Color3.fromRGB(r, g, b))
	end

	local function setSquareFromInput(input)
		local relativeX = math.clamp((input.Position.X - colorSquare.AbsolutePosition.X) / colorSquare.AbsoluteSize.X, 0, 1)
		local relativeY = math.clamp((input.Position.Y - colorSquare.AbsolutePosition.Y) / colorSquare.AbsoluteSize.Y, 0, 1)
		saturation = relativeX
		value = 1 - relativeY
		setFromHueSaturationValue(fireOnDrag)
	end

	local function setHueFromInput(input)
		hue = math.clamp((input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
		setFromHueSaturationValue(fireOnDrag)
	end

	connectScoped(window, control, header.MouseButton1Click, function()
		if control.Disabled then
			return
		end

		open = not open
		panel.Visible = open
	end)

	connectScoped(window, control, colorSquare.InputBegan, function(input)
		if control.Disabled or not isInputStart(input) then
			return
		end

		draggingSquare = true
		setSquareFromInput(input)
	end)

	connectScoped(window, control, hueSlider.InputBegan, function(input)
		if control.Disabled or not isInputStart(input) then
			return
		end

		draggingHue = true
		setHueFromInput(input)
	end)

	connectScoped(window, control, UserInputService.InputChanged, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		if draggingSquare then
			setSquareFromInput(input)
		elseif draggingHue then
			setHueFromInput(input)
		end
	end)

	connectScoped(window, control, UserInputService.InputEnded, function(input)
		if isInputStart(input) then
			local wasDragging = draggingSquare or draggingHue
			draggingSquare = false
			draggingHue = false
			if wasDragging and not fireOnDrag then
				control:Set(control.Value)
			end
		end
	end)

	connectScoped(window, control, red.FocusLost, applyRgb)
	connectScoped(window, control, green.FocusLost, applyRgb)
	connectScoped(window, control, blue.FocusLost, applyRgb)

	syncVisuals(initial)
	window:_registerControl(options.Flag, control)
	window:_registerSearchItem(options.Name, item, self._sectionInfo)
	attachTooltip(window, control, item, options.Tooltip)
	return attachControlBase(control, item)
end

function HostMethods:CreateButton(options)
	options = normalizeOptions(options, "Button")
	options.Callback = ensureType(options.Callback, "function", "CreateButton.Callback", options.Callback)
	local window = self._window
	local theme = window.Theme

	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.Item,
		Text = "",
		Size = UDim2.new(1, 0, 0, window.ButtonHeight or 42),
		Parent = self._container,
	})
	corner(button, 8)
	stroke(button, theme.Stroke, 0.35, nil)
	local buttonScale = addScale(button, 1)

	local row = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = button,
	})
	padding(row, 12, 12, 0, 0)
	list(row, Enum.FillDirection.Horizontal, 9).VerticalAlignment = Enum.VerticalAlignment.Center

	local icon = mountIcon(Bluesky, row, options.Icon, theme, 17, 1)

	local label = makeText(row, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(1, icon and -26 or 0, 1, 0),
		LayoutOrder = 2,
	})

	local control = {
		Disabled = options.Disabled == true,
		Loading = false,
		Callback = options.Callback,
	}
	local defaultText = tostring(options.Name)

	setButtonHover(window, button, "Item", "ItemHover", control)

	connectScoped(window, control, button.MouseButton1Click, function()
		if control.Disabled or control.Loading then
			return
		end

		if window.Animations then
			pressScale(buttonScale)
		end

		tween(button, TWEEN_FAST, {
			BackgroundColor3 = window.Theme.AccentDark,
		})
		task.delay(0.08, function()
			if button.Parent then
				tween(button, TWEEN_FAST, {
					BackgroundColor3 = window.Theme.Item,
				})
			end
		end)

		safeCall(control.Callback)
	end)

	function control:SetText(text)
		defaultText = tostring(text)
		label.Text = tostring(text)
		return self
	end

	function control:Set(text)
		return self:SetText(text)
	end

	function control:SetLoading(loading, text)
		self.Loading = loading == true
		if self.Loading then
			label.Text = tostring(text or "Loading...")
			self:SetDisabled(true)
		else
			label.Text = defaultText
			self:SetDisabled(options.Disabled == true)
		end
		return self
	end

	function control:Destroy()
		button:Destroy()
	end

	control.Instance = button
	window:_registerSearchItem(options.Name, button, self._sectionInfo)
	attachTooltip(window, control, button, options.Tooltip)
	return attachControlBase(control, button)
end

function HostMethods:CreateToggle(options)
	options = normalizeOptions(options, "Toggle")
	options.Callback = ensureType(options.Callback, "function", "CreateToggle.Callback", options.Callback)
	local window = self._window
	local theme = window.Theme
	local state = options.CurrentValue
	if state == nil then
		state = options.Default or false
	end
	state = state == true

	local row = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.Item,
		Text = "",
		Size = UDim2.new(1, 0, 0, window.ToggleHeight or 46),
		Parent = self._container,
	})
	corner(row, 8)
	stroke(row, theme.Stroke, 0.35, nil)
	padding(row, 12, 12, 0, 0)
	local rowScale = addScale(row, 1)

	local label = makeText(row, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(1, -58, 1, 0),
	})

	local switch = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = state and theme.Accent or theme.SurfaceAlt,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(42, 22),
		Parent = row,
	})
	corner(switch, 12)

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = theme.Text,
		Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		Parent = switch,
	})
	corner(knob, 9)

	local control = {
		Instance = row,
		Value = state,
		Disabled = options.Disabled == true,
		Callback = options.Callback,
	}

	function control:Set(value, invoke)
		value = value == true
		if self.Value == value then
			return
		end

		self.Value = value
		window:_setFlag(options.Flag, value)

		tween(switch, TWEEN_FAST, {
			BackgroundColor3 = value and window.Theme.Accent or window.Theme.SurfaceAlt,
		})
		tween(knob, TWEEN_FAST, {
			Position = value and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		})

		if invoke ~= false then
			safeCall(self.Callback, value)
		end
	end

	function control:Destroy()
		row:Destroy()
	end

	window:_registerControl(options.Flag, control)
	window:_registerSearchItem(options.Name, row, self._sectionInfo)
	setButtonHover(window, row, "Item", "ItemHover", control)
	attachTooltip(window, control, row, options.Tooltip)

	connectScoped(window, control, row.MouseButton1Click, function()
		if control.Disabled then
			return
		end

		if window.Animations then
			pressScale(rowScale)
		end

		control:Set(not control.Value)
	end)

	return attachControlBase(control, row)
end

function HostMethods:CreateSlider(options)
	options = normalizeOptions(options, "Slider")
	options.Callback = ensureType(options.Callback, "function", "CreateSlider.Callback", options.Callback)
	local window = self._window
	local theme = window.Theme

	local range = type(options.Range) == "table" and options.Range or nil
	local min = tonumber(options.Min) or tonumber(options.Minimum) or (range and tonumber(range[1])) or 0
	local max = tonumber(options.Max) or tonumber(options.Maximum) or (range and tonumber(range[2])) or 100
	local step = tonumber(options.Increment) or tonumber(options.Step) or 1
	local value = tonumber(options.CurrentValue) or tonumber(options.Default) or min
	local suffix = options.Suffix ~= nil and tostring(options.Suffix) or ""

	if max < min then
		min, max = max, min
		devWarn("CreateSlider: Max is smaller than Min, values were swapped automatically.")
	end

	if step <= 0 then
		devWarn("CreateSlider: Step must be > 0, fallback to 1.")
		step = 1
	end

	value = math.clamp(roundToStep(value, step), min, max)

	local function formatSliderValue(nextValue)
		if suffix ~= "" then
			return tostring(nextValue) .. " " .. suffix
		end

		return tostring(nextValue)
	end

	local item = createContainer(self._container, theme, 70)
	padding(item, 12, 12, 8, 10)

	local label = makeText(item, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(1, -74, 0, 20),
	})

	local valueLabel = makeText(item, formatSliderValue(value), 12, theme.SubText, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 1),
		Size = UDim2.fromOffset(70, 18),
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	local bar = create("Frame", {
		BackgroundColor3 = theme.SurfaceAlt,
		Position = UDim2.new(0, 0, 1, -18),
		Size = UDim2.new(1, 0, 0, 8),
		Parent = item,
	})
	corner(bar, 6)

	local initialRatio = 0
	if max ~= min then
		initialRatio = math.clamp((value - min) / (max - min), 0, 1)
	end

	local fill = create("Frame", {
		BackgroundColor3 = theme.Accent,
		Size = UDim2.fromScale(initialRatio, 1),
		Parent = bar,
	})
	corner(fill, 6)

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Text,
		Position = UDim2.new(initialRatio, 0, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		Parent = bar,
	})
	corner(knob, 8)
	stroke(knob, theme.Accent, 0, nil)
	local knobScale = addScale(knob, 1)

	local dragging = false

	local control = {
		Instance = item,
		Value = value,
		Minimum = min,
		Maximum = max,
		Step = step,
		Disabled = options.Disabled == true,
		Callback = options.Callback,
	}

	local function ratioFromValue(nextValue)
		if max == min then
			return 0
		end

		return math.clamp((nextValue - min) / (max - min), 0, 1)
	end

	function control:Set(nextValue, invoke)
		nextValue = tonumber(nextValue) or min
		nextValue = math.clamp(roundToStep(nextValue, step), min, max)

		if self.Value == nextValue then
			return
		end

		self.Value = nextValue
		window:_setFlag(options.Flag, nextValue)

		local ratio = ratioFromValue(nextValue)
		valueLabel.Text = formatSliderValue(nextValue)
		tween(fill, TWEEN_FAST, {
			Size = UDim2.fromScale(ratio, 1),
		})
		tween(knob, TWEEN_FAST, {
			Position = UDim2.new(ratio, 0, 0.5, 0),
		})

		if invoke ~= false then
			safeCall(self.Callback, nextValue)
		end
	end

	function control:Destroy()
		item:Destroy()
	end

	window:_registerControl(options.Flag, control)
	window:_registerSearchItem(options.Name, item, self._sectionInfo)
	attachTooltip(window, control, item, options.Tooltip)

	local function setFromPosition(x)
		local relative = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		control:Set(min + ((max - min) * relative))
	end

	connectScoped(window, control, bar.InputBegan, function(input)
		if control.Disabled or not isInputStart(input) then
			return
		end

		dragging = true
		if window.Animations then
			tween(knobScale, TWEEN_FAST, {
				Scale = 1.14,
			})
		end
		setFromPosition(input.Position.X)
	end)

	connectScoped(window, control, knob.InputBegan, function(input)
		if not control.Disabled and isInputStart(input) then
			dragging = true
			if window.Animations then
				tween(knobScale, TWEEN_FAST, {
					Scale = 1.14,
				})
			end
		end
	end)

	connectScoped(window, control, UserInputService.InputEnded, function(input)
		if isInputStart(input) then
			dragging = false
			if window.Animations then
				tween(knobScale, TWEEN_FAST, {
					Scale = 1,
				})
			end
		end
	end)

	connectScoped(window, control, UserInputService.InputChanged, function(input)
		if control.Disabled or not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			setFromPosition(input.Position.X)
		end
	end)

	return attachControlBase(control, item)
end

function HostMethods:CreateInput(options)
	options = normalizeOptions(options, "Input")
	options.Callback = ensureType(options.Callback, "function", "CreateInput.Callback", options.Callback)
	local window = self._window
	local theme = window.Theme
	local helperText = options.HelperText or options.Description or options.Info
	local hasHelper = helperText ~= nil and tostring(helperText) ~= ""
		or type(options.Validate) == "function"
		or options.ErrorText ~= nil
		or options.SuccessText ~= nil
	local inputHeight = window.InputHeight or 34
	local itemHeight = hasHelper and (window.InputDescriptionHeight or 96) or (window.InputBaseHeight or 78)

	local item = createContainer(self._container, theme, itemHeight)
	padding(item, 12, 12, 10, 12)

	makeText(item, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamMedium,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 20),
	})

	local helperLabel
	if hasHelper then
		helperLabel = makeText(item, tostring(helperText or ""), 11, theme.SubText, {
			Position = UDim2.fromOffset(0, 20),
			Size = UDim2.new(1, 0, 0, 16),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
	end

	local box = create("TextBox", {
		BackgroundColor3 = theme.SurfaceAlt,
		ClearTextOnFocus = options.ClearTextOnFocus == true,
		Font = Enum.Font.Gotham,
		PlaceholderText = options.PlaceholderText or options.Placeholder or "",
		PlaceholderColor3 = theme.SubText,
		Position = UDim2.fromOffset(0, hasHelper and 42 or 28),
		Size = UDim2.new(1, 0, 0, inputHeight),
		Text = tostring(options.CurrentValue or options.Default or ""),
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = item,
	})
	corner(box, 7)
	local boxStroke = stroke(box, theme.Stroke, 0.38, nil)
	padding(box, 10, 10, 0, 0)
	local boxScale = addScale(box, 1)

	local control = {
		Instance = item,
		TextBox = box,
		Value = box.Text,
		Disabled = options.Disabled == true,
		Callback = options.Callback,
		Valid = true,
	}

	local function setStatus(text, color, strokeColor)
		if helperLabel then
			helperLabel.Text = tostring(text or helperText or "")
			helperLabel.TextColor3 = color or window.Theme.SubText
		end

		tween(boxStroke, TWEEN_FAST, {
			Color = strokeColor or window.Theme.Stroke,
			Transparency = strokeColor and 0.1 or 0.38,
		})
	end

	local function validateText(text)
		if type(options.Validate) ~= "function" then
			control.Valid = true
			return true
		end

		local ok, valid, message = pcall(options.Validate, text)
		if not ok then
			control.Valid = false
			setStatus("Validation error.", window.Theme.Danger, window.Theme.Danger)
			warn("Bluesky: Input validation error: " .. tostring(valid))
			return false
		end

		if valid == false then
			control.Valid = false
			setStatus(message or options.ErrorText or "Invalid value.", window.Theme.Danger, window.Theme.Danger)
			return false
		end

		control.Valid = true
		if message ~= nil and tostring(message) ~= "" then
			setStatus(message, window.Theme.Success, window.Theme.Success)
		elseif options.SuccessText then
			setStatus(options.SuccessText, window.Theme.Success, window.Theme.Success)
		else
			setStatus(helperText, window.Theme.SubText, nil)
		end
		return true
	end

	function control:Set(text, invoke)
		text = tostring(text or "")
		if options.Filter and type(options.Filter) == "function" then
			local ok, result = pcall(options.Filter, text)
			if ok and result ~= nil then
				text = tostring(result)
			elseif not ok then
				warn("Bluesky: Input filter error: " .. tostring(result))
			end
		end

		box.Text = text
		if not validateText(text) then
			return self
		end

		self.Value = text
		box.Text = self.Value
		window:_setFlag(options.Flag, self.Value)

		if invoke ~= false then
			safeCall(self.Callback, self.Value)
		end

		return self
	end

	function control:SetError(text)
		self.Valid = false
		setStatus(text or options.ErrorText or "Invalid value.", window.Theme.Danger, window.Theme.Danger)
		return self
	end

	function control:SetSuccess(text)
		self.Valid = true
		setStatus(text or options.SuccessText or helperText, window.Theme.Success, window.Theme.Success)
		return self
	end

	function control:SetHelperText(text)
		helperText = text
		if helperLabel then
			helperLabel.Text = tostring(text or "")
			helperLabel.TextColor3 = window.Theme.SubText
		end
		return self
	end

	function control:Validate()
		return validateText(box.Text)
	end

	function control:Destroy()
		item:Destroy()
	end

	window:_registerControl(options.Flag, control)
	window:_registerSearchItem(options.Name, item, self._sectionInfo)
	attachTooltip(window, control, item, options.Tooltip)

	connectScoped(window, control, box.Focused, function()
		if control.Disabled then
			pcall(function()
				box:ReleaseFocus()
			end)
			return
		end

		if window.Animations then
			tween(boxScale, TWEEN_FAST, {
				Scale = 1.01,
			})
		end

		tween(box, TWEEN_FAST, {
			BackgroundColor3 = window.Theme.ItemHover,
		})
		tween(boxStroke, TWEEN_FAST, {
			Color = window.Theme.Accent,
			Transparency = 0.12,
		})
	end)

	connectScoped(window, control, box.FocusLost, function(enterPressed)
		if window.Animations then
			tween(boxScale, TWEEN_FAST, {
				Scale = 1,
			})
		end

		tween(box, TWEEN_FAST, {
			BackgroundColor3 = window.Theme.SurfaceAlt,
		})
		tween(boxStroke, TWEEN_FAST, {
			Color = window.Theme.Stroke,
			Transparency = 0.38,
		})

		if control.Disabled then
			return
		end

		if options.FireOnEnter and not enterPressed then
			if validateText(box.Text) then
				control.Value = box.Text
				window:_setFlag(options.Flag, box.Text)
			end
			return
		end

		control:Set(box.Text)
		if options.RemoveTextAfterFocusLost == true then
			box.Text = ""
		end
	end)

	return attachControlBase(control, item)
end

function HostMethods:CreateDropdown(options)
	options = normalizeOptions(options, "Dropdown")
	options.Callback = ensureType(options.Callback, "function", "CreateDropdown.Callback", options.Callback)
	local window = self._window
	local theme = window.Theme
	local values = options.Options or options.Values or {}
	if type(values) ~= "table" then
		devWarn("CreateDropdown: Options/Values should be a table. Using empty table.")
		values = {}
	end
	local maxVisibleOptions = math.max(3, tonumber(options.MaxVisibleOptions) or 6)
	local searchEnabled = options.Search == true or options.Searchable == true
	local optionRowHeight = window.DropdownOptionHeight or 32
	local headerHeight = window.DropdownHeight or 44
	local renderLimitStep = math.max(20, tonumber(options.RenderLimit) or tonumber(options.MaxRenderedOptions) or 80)
	local renderLimit = renderLimitStep
	local lazyRender = options.LazyRender
	if lazyRender == nil then
		lazyRender = #values > 20
	end
	local selected = options.CurrentOption or options.Default or options.CurrentValue
	if selected == "" and not options.Placeholder then
		selected = "None"
	elseif selected == "" and options.Placeholder then
		selected = options.Placeholder
	end
	if type(selected) == "table" then
		selected = selected[1]
	end
	if selected == nil and values[1] ~= nil then
		selected = values[1]
	end

	local item = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Item,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = self._container,
	})
	corner(item, 8)
	stroke(item, theme.Stroke, 0.35, nil)
	padding(item, 0, 0, 0, 0)
	list(item, Enum.FillDirection.Vertical, 0)

	local header = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, 0, 0, headerHeight),
		Parent = item,
	})
	padding(header, 12, 12, 0, 0)
	local headerScale = addScale(header, 1)

	makeText(header, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(0.48, 0, 1, 0),
	})

	local selectedLabel = makeText(header, tostring(selected or "Select"), 12, theme.SubText, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -22, 0, 0),
		Size = UDim2.new(0.48, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local arrow = makeText(header, "v", 12, theme.SubText, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 18),
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local optionsHeight = (maxVisibleOptions * optionRowHeight) + ((maxVisibleOptions - 1) * 6) + 8
	if searchEnabled then
		optionsHeight = optionsHeight + 34
	end
	local optionsFrame = create("ScrollingFrame", {
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Item,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollBarImageColor3 = theme.Stroke,
		ScrollBarThickness = 3,
		Size = UDim2.new(1, 0, 0, optionsHeight),
		Visible = false,
		ZIndex = 145,
		Parent = window.Gui,
	})
	corner(optionsFrame, 8)
	stroke(optionsFrame, theme.Stroke, 0.35, nil)
	padding(optionsFrame, 8, 8, 0, 8)

	local searchInput
	if searchEnabled then
		searchInput = create("TextBox", {
			BackgroundColor3 = theme.SurfaceAlt,
			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			PlaceholderText = options.SearchPlaceholder or "Search options...",
			PlaceholderColor3 = theme.SubText,
			Size = UDim2.new(1, 0, 0, 28),
			Text = "",
			TextColor3 = theme.Text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Visible = true,
			ZIndex = 146,
			Parent = optionsFrame,
		})
		corner(searchInput, 6)
		padding(searchInput, 8, 8, 0, 0)
	end

	local optionsLayout = list(optionsFrame, Enum.FillDirection.Vertical, 6)
	local optionsScale = addScale(optionsFrame, 1)

	local open = false
	local openToken = 0
	local optionsDirty = true
	local searchToken = 0
	local control = {
		Instance = item,
		Value = selected,
		Options = values,
		Disabled = options.Disabled == true,
		Callback = options.Callback,
		Popup = optionsFrame,
		_optionConnections = {},
	}

	local function connectOption(signal, callback)
		local connection = window:_connect(signal, callback)
		table.insert(control._optionConnections, connection)
		return connection
	end

	local function updateOptionsHeight()
		local baseHeight = optionsHeight
		if window.Main and item.Parent then
			local bottom = window.Main.AbsolutePosition.Y + window.Main.AbsoluteSize.Y - 12
			local available = bottom - (item.AbsolutePosition.Y + header.AbsoluteSize.Y)
			baseHeight = math.min(baseHeight, math.max(96, available))
		end

		optionsFrame.Position = UDim2.fromOffset(item.AbsolutePosition.X, header.AbsolutePosition.Y + header.AbsoluteSize.Y + 4)
		optionsFrame.Size = UDim2.fromOffset(item.AbsoluteSize.X, baseHeight)
	end
	local ensureOptionsBuilt

	local function setOpen(nextOpen)
		open = nextOpen == true
		openToken = openToken + 1
		local token = openToken

		if open then
			window:_closeDropdownsExcept(control)
			window:_trackDropdownOpen(control, true)
			updateOptionsHeight()
			optionsFrame.Visible = true
			if window.Animations then
				optionsScale.Scale = 0.96
				tween(optionsScale, TWEEN_MEDIUM, {
					Scale = 1,
				})
				tween(arrow, TWEEN_FAST, {
					Rotation = 180,
				})
			else
				arrow.Rotation = 180
			end
		else
			window:_trackDropdownOpen(control, false)
			if window.Animations then
				tween(optionsScale, TWEEN_FAST, {
					Scale = 0.96,
				})
				tween(arrow, TWEEN_FAST, {
					Rotation = 0,
				})

				task.delay(0.12, function()
					if token == openToken and not open then
						optionsFrame.Visible = false
						optionsScale.Scale = 1
					end
				end)
			else
				arrow.Rotation = 0
				optionsFrame.Visible = false
			end
		end
	end

	function control:Set(value, invoke)
		self.Value = value
		window:_setFlag(options.Flag, value)
		selectedLabel.Text = tostring(value or "Select")
		optionsDirty = true
		setOpen(false)

		if invoke ~= false then
			safeCall(self.Callback, value)
		end
	end

	function control:Open()
		ensureOptionsBuilt()
		setOpen(true)
		return self
	end

	function control:Close()
		setOpen(false)
		return self
	end

	local function clearOptions()
		disconnectConnections(control._optionConnections)
		for _, child in ipairs(optionsFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
	end

	local function rebuildOptions(filter)
		local currentTheme = window.Theme
		clearOptions()
		filter = filter and tostring(filter):lower() or ""
		local matchedCount = 0
		for _, valueOption in ipairs(control.Options) do
			if filter ~= "" and not tostring(valueOption):lower():find(filter, 1, true) then
				continue
			end

			matchedCount = matchedCount + 1
			if matchedCount > renderLimit then
				continue
			end

			local isSelected = valueOption == control.Value
			local optionButton = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = isSelected and currentTheme.AccentDark or currentTheme.SurfaceAlt,
				Font = isSelected and Enum.Font.GothamMedium or Enum.Font.Gotham,
				Text = tostring(valueOption),
				TextColor3 = currentTheme.Text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, optionRowHeight),
				ZIndex = 146,
				Parent = optionsFrame,
			})
			corner(optionButton, 6)
			padding(optionButton, 10, 10, 0, 0)
			local optionStroke = stroke(optionButton, isSelected and currentTheme.Accent or currentTheme.Stroke, isSelected and 0.08 or 0.65, nil)
			local optionScale = addScale(optionButton, 1)
			connectOption(optionButton.MouseEnter, function()
				if optionButton ~= nil and optionButton.Parent and not (valueOption == control.Value) then
					tween(optionButton, TWEEN_FAST, {
						BackgroundColor3 = window.Theme.ItemHover,
					})
				end
			end)
			connectOption(optionButton.MouseLeave, function()
				if optionButton ~= nil and optionButton.Parent then
					local selectedNow = valueOption == control.Value
					tween(optionButton, TWEEN_FAST, {
						BackgroundColor3 = selectedNow and window.Theme.AccentDark or window.Theme.SurfaceAlt,
					})
					tween(optionStroke, TWEEN_FAST, {
						Color = selectedNow and window.Theme.Accent or window.Theme.Stroke,
						Transparency = selectedNow and 0.08 or 0.65,
					})
				end
			end)

			connectOption(optionButton.MouseButton1Click, function()
				if control.Disabled then
					return
				end

				if window.Animations then
					pressScale(optionScale)
				end

				control:Set(valueOption)
			end)
		end

		if matchedCount > renderLimit then
			local remaining = matchedCount - renderLimit
			local showMore = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = currentTheme.SurfaceAlt,
				Font = Enum.Font.GothamMedium,
				Text = "Show more (" .. tostring(remaining) .. " left)",
				TextColor3 = currentTheme.SubText,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.new(1, 0, 0, optionRowHeight),
				ZIndex = 146,
				Parent = optionsFrame,
			})
			corner(showMore, 6)
			local showMoreScale = addScale(showMore, 1)
			connectOption(showMore.MouseButton1Click, function()
				if control.Disabled then
					return
				end

				if window.Animations then
					pressScale(showMoreScale)
				end
				renderLimit = renderLimit + renderLimitStep
				rebuildOptions(filter)
			end)
		end

		optionsDirty = false
	end

	local function scheduleSearchRebuild()
		searchToken = searchToken + 1
		local token = searchToken

		task.delay(0.08, function()
			if token == searchToken and open and item.Parent then
				renderLimit = renderLimitStep
				rebuildOptions(searchInput and searchInput.Text or "")
			end
		end)
	end

	function ensureOptionsBuilt()
		if optionsDirty then
			rebuildOptions()
		end
	end

	function control:Refresh(newOptions, keepValue)
		self.Options = newOptions or {}
		renderLimit = renderLimitStep
		optionsDirty = true

		if open or not lazyRender then
			ensureOptionsBuilt()
		end

		if not keepValue then
			self:Set(self.Options[1], false)
		end

		return self
	end

	function control:AddOption(valueOption)
		table.insert(self.Options, valueOption)
		optionsDirty = true

		if open or not lazyRender then
			ensureOptionsBuilt()
		end

		if self.Value == nil then
			self:Set(valueOption, false)
		end

		return self
	end

	function control:RemoveOption(valueOption)
		for index, itemValue in ipairs(self.Options) do
			if itemValue == valueOption then
				table.remove(self.Options, index)
				break
			end
		end

		optionsDirty = true
		if open or not lazyRender then
			ensureOptionsBuilt()
		end

		if self.Value == valueOption then
			self:Set(self.Options[1], false)
		end

		return self
	end

	function control:ClearOptions()
		self.Options = {}
		renderLimit = renderLimitStep
		clearOptions()
		optionsDirty = false
		self:Set(nil, false)
		return self
	end

	function control:SetLoading(loading, text)
		self.Loading = loading == true
		self:SetDisabled(self.Loading)
		selectedLabel.Text = self.Loading and tostring(text or "Loading...") or tostring(self.Value or "Select")
		return self
	end

	function control:Destroy()
		window:_trackDropdownOpen(control, false)
		if optionsFrame and optionsFrame.Parent then
			optionsFrame:Destroy()
		end
		item:Destroy()
	end

	window:_registerControl(options.Flag, control)
	window:_registerSearchItem(options.Name, item, self._sectionInfo)
	attachTooltip(window, control, item, options.Tooltip)

	if not lazyRender then
		ensureOptionsBuilt()
	end
	setButtonHover(window, header, "Item", "ItemHover", control)
	if searchInput then
		connectScoped(window, control, searchInput:GetPropertyChangedSignal("Text"), scheduleSearchRebuild)
	end
	connectScoped(window, control, optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		optionsFrame.CanvasSize = UDim2.fromOffset(0, optionsLayout.AbsoluteContentSize.Y + 8)
		if open then
			updateOptionsHeight()
		end
	end)

	connectScoped(window, control, header.MouseButton1Click, function()
		if control.Disabled then
			return
		end

		if window.Animations then
			pressScale(headerScale)
		end

		if not open then
			ensureOptionsBuilt()
		end
		setOpen(not open)
	end)

	return attachControlBase(control, item)
end

function HostMethods:CreateParagraph(options)
	options = normalizeOptions(options, "Paragraph")
	local theme = self._window.Theme

	local item = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Item,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = self._container,
	})
	corner(item, 8)
	stroke(item, theme.Stroke, 0.35)
	padding(item, 12, 12, 10, 10)
	list(item, Enum.FillDirection.Vertical, 4)

	local title = makeText(item, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(1, 0, 0, 18),
	})

	local content = makeText(item, options.Content or options.Text or "", 12, theme.SubText, {
		AutomaticSize = Enum.AutomaticSize.Y,
		RichText = true,
		Size = UDim2.new(1, 0, 0, 0),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	})

	local control = { Instance = item }

	function control:SetTitle(text)
		title.Text = tostring(text)
	end

	function control:SetContent(text)
		content.Text = tostring(text)
	end

	function control:Set(nextValue)
		if type(nextValue) == "table" then
			if nextValue.Title or nextValue.Name then
				self:SetTitle(nextValue.Title or nextValue.Name)
			end
			if nextValue.Content or nextValue.Text then
				self:SetContent(nextValue.Content or nextValue.Text)
			end
		elseif nextValue ~= nil then
			self:SetContent(nextValue)
		end
	end

	function control:Destroy()
		item:Destroy()
	end

	self._window:_registerSearchItem(options.Name, item, self._sectionInfo)
	return attachControlBase(control, item)
end

function HostMethods:CreateMultiDropdown(options)
	options = normalizeOptions(options, "Multi-Dropdown")
	options.Callback = ensureType(options.Callback, "function", "CreateMultiDropdown.Callback", options.Callback)
	local window = self._window
	local theme = window.Theme
	local values = options.Options or options.Values or {}
	local headerHeight = window.DropdownHeight or 44
	local optionRowHeight = math.max(30, (window.DropdownOptionHeight or 32) - 2)
	local maxVisibleOptions = math.max(3, tonumber(options.MaxVisibleOptions) or 5)
	local renderLimitStep = math.max(20, tonumber(options.RenderLimit) or tonumber(options.MaxRenderedOptions) or 80)
	local renderLimit = renderLimitStep
	local selected = options.Default or options.CurrentValue or options.CurrentOption or {}
	if type(selected) ~= "table" then selected = {selected} end
	
	-- Clean up empty strings or invalid defaults
	local cleanedSelected = {}
	for _, v in ipairs(selected) do
		if v ~= "" and v ~= nil then
			table.insert(cleanedSelected, v)
		end
	end
	selected = cleanedSelected

	local item = create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Item,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = self._container,
	})
	corner(item, 8)
	stroke(item, theme.Stroke, 0.35)
	padding(item, 0, 0, 0, 8)
	list(item, Enum.FillDirection.Vertical, 0)

	local header = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.Item,
		Size = UDim2.new(1, 0, 0, headerHeight),
		Text = "",
		Parent = item,
	})
	corner(header, 8)
	padding(header, 12, 12, 0, 0)
	local headerScale = addScale(header, 1)

	makeText(header, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(0.48, 0, 1, 0),
	})

	local selectedLabel = makeText(header, "None", 12, theme.SubText, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0.96, -18, 0, 0),
		Size = UDim2.new(0.48, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local arrow = makeText(header, "v", 12, theme.SubText, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 18),
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local optionsFrame = create("ScrollingFrame", {
		BackgroundColor3 = theme.Item,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = theme.Accent,
		Size = UDim2.new(1, 0, 0, (maxVisibleOptions * optionRowHeight) + 42),
		Visible = false,
		ZIndex = 145,
		Parent = window.Gui,
	})
	corner(optionsFrame, 8)
	stroke(optionsFrame, theme.Stroke, 0.35, nil)
	padding(optionsFrame, 8, 8, 4, 4)
	local searchInput = create("TextBox", {
		BackgroundColor3 = theme.SurfaceAlt,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = "Search options...",
		PlaceholderColor3 = theme.SubText,
		Size = UDim2.new(1, 0, 0, 28),
		Text = "",
		TextColor3 = theme.Text,
		TextSize = 12,
		Visible = false,
		ZIndex = 146,
		Parent = optionsFrame,
	})
	corner(searchInput, 6)
	padding(searchInput, 8, 8, 0, 0)

	local optionsLayout = list(optionsFrame, Enum.FillDirection.Vertical, 6)
	local optionsScale = addScale(optionsFrame, 1)

	local open = false
	local optionsDirty = true
	local searchToken = 0
	local control = {
		Instance = item,
		Value = selected,
		Options = values,
		Disabled = options.Disabled == true,
		Callback = options.Callback,
		Popup = optionsFrame,
		_optionConnections = {},
	}

	local function connectOption(signal, callback)
		local connection = window:_connect(signal, callback)
		table.insert(control._optionConnections, connection)
		return connection
	end

	local function updateLabel()
		local text = ""
		local count = 0
		for _, v in pairs(control.Value) do
			count = count + 1
			if count > 1 then text = text .. ", " end
			text = text .. tostring(v)
		end
		selectedLabel.Text = count > 0 and text or "None"
	end

	function control:Set(newTable, invoke)
		self.Value = type(newTable) == "table" and newTable or {}
		window:_setFlag(options.Flag, self.Value)
		updateLabel()
		optionsDirty = true
		if invoke ~= false then safeCall(self.Callback, self.Value) end
	end

	local function updateOptionsHeight()
		local baseHeight = (maxVisibleOptions * optionRowHeight) + 42
		if window.Main and item.Parent then
			local bottom = window.Main.AbsolutePosition.Y + window.Main.AbsoluteSize.Y - 12
			local available = bottom - (item.AbsolutePosition.Y + header.AbsoluteSize.Y)
			baseHeight = math.min(baseHeight, math.max(104, available))
		end

		optionsFrame.Position = UDim2.fromOffset(item.AbsolutePosition.X, header.AbsolutePosition.Y + header.AbsoluteSize.Y + 4)
		optionsFrame.Size = UDim2.fromOffset(item.AbsoluteSize.X, baseHeight)
	end
	local rebuildOptions

	local function setOpen(nextOpen)
		open = nextOpen == true
		if open then
			window:_closeDropdownsExcept(control)
			window:_trackDropdownOpen(control, true)
			updateOptionsHeight()
			optionsFrame.Visible = true
			searchInput.Visible = #control.Options > 8
			if optionsDirty then
				rebuildOptions(searchInput.Text)
			end
		else
			window:_trackDropdownOpen(control, false)
			optionsFrame.Visible = false
		end
		tween(arrow, TWEEN_FAST, { Rotation = open and 180 or 0 })
	end

	function control:Open()
		setOpen(true)
		return self
	end

	function control:Close()
		setOpen(false)
		return self
	end

	function rebuildOptions(filter)
		local currentTheme = window.Theme
		disconnectConnections(control._optionConnections)
		for _, child in ipairs(optionsFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end

		filter = filter and tostring(filter):lower() or ""
		local matchedCount = 0

		for _, val in ipairs(control.Options) do
			if filter ~= "" and not tostring(val):lower():find(filter, 1, true) then
				continue
			end

			matchedCount = matchedCount + 1
			if matchedCount > renderLimit then
				continue
			end

			local isSelected = false
			for _, s in pairs(control.Value) do
				if s == val then isSelected = true break end
			end

			local opt = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = isSelected and currentTheme.AccentDark or currentTheme.SurfaceAlt,
				Size = UDim2.new(1, 0, 0, optionRowHeight),
				Text = "",
				ZIndex = 146,
				Parent = optionsFrame,
			})
			corner(opt, 6)
			padding(opt, 8, 8, 0, 0)
			local optStroke = stroke(opt, isSelected and currentTheme.Accent or currentTheme.Stroke, isSelected and 0.08 or 0.55)
			local optLabel = makeText(opt, tostring(val), 12, currentTheme.Text, {
				Font = isSelected and Enum.Font.GothamMedium or Enum.Font.Gotham,
				Size = UDim2.new(1, 0, 1, 0),
			})

			local selectedState = isSelected
			local function applySelectedStyle(nextSelected, animate)
				selectedState = nextSelected == true
				local background = selectedState and window.Theme.AccentDark or window.Theme.SurfaceAlt
				local border = selectedState and window.Theme.Accent or window.Theme.Stroke
				local strokeTransparency = selectedState and 0.08 or 0.55

				optLabel.Font = selectedState and Enum.Font.GothamMedium or Enum.Font.Gotham

				if animate and window.Animations then
					tween(opt, TWEEN_FAST, {
						BackgroundColor3 = background,
					})
					tween(optStroke, TWEEN_FAST, {
						Color = border,
						Transparency = strokeTransparency,
					})
				else
					opt.BackgroundColor3 = background
					optStroke.Color = border
					optStroke.Transparency = strokeTransparency
				end
			end

			connectOption(opt.MouseEnter, function()
				if not selectedState then
					tween(opt, TWEEN_FAST, {
						BackgroundColor3 = window.Theme.ItemHover,
					})
				end
			end)

			connectOption(opt.MouseLeave, function()
				if not selectedState then
					tween(opt, TWEEN_FAST, {
						BackgroundColor3 = window.Theme.SurfaceAlt,
					})
				end
			end)

			connectOption(opt.MouseButton1Click, function()
				if control.Disabled then
					return
				end

				local found = false
				for i, s in ipairs(control.Value) do
					if s == val then
						table.remove(control.Value, i)
						found = true
						break
					end
				end
				if not found then table.insert(control.Value, val) end

				applySelectedStyle(not found, true)
				control:Set(control.Value)
			end)
		end

		if matchedCount > renderLimit then
			local remaining = matchedCount - renderLimit
			local showMore = create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = currentTheme.SurfaceAlt,
				Font = Enum.Font.GothamMedium,
				Text = "Show more (" .. tostring(remaining) .. " left)",
				TextColor3 = currentTheme.SubText,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.new(1, 0, 0, optionRowHeight),
				ZIndex = 146,
				Parent = optionsFrame,
			})
			corner(showMore, 6)
			local showMoreScale = addScale(showMore, 1)
			connectOption(showMore.MouseButton1Click, function()
				if control.Disabled then
					return
				end

				if window.Animations then
					pressScale(showMoreScale)
				end
				renderLimit = renderLimit + renderLimitStep
				rebuildOptions(filter)
			end)
		end
		optionsDirty = false
	end

	local function scheduleSearchRebuild()
		searchToken = searchToken + 1
		local token = searchToken

		task.delay(0.08, function()
			if token == searchToken and open and item.Parent then
				renderLimit = renderLimitStep
				rebuildOptions(searchInput.Text)
			end
		end)
	end

	connectScoped(window, control, searchInput:GetPropertyChangedSignal("Text"), function()
		scheduleSearchRebuild()
	end)

	connectScoped(window, control, header.MouseButton1Click, function()
		if control.Disabled then
			return
		end

		if window.Animations then
			pressScale(headerScale)
		end

		setOpen(not open)
	end)

	connectScoped(window, control, optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		optionsFrame.CanvasSize = UDim2.fromOffset(0, optionsLayout.AbsoluteContentSize.Y + 8)
		if open then
			updateOptionsHeight()
		end
	end)

	function control:Refresh(newOptions, keepValue)
		self.Options = newOptions or {}
		renderLimit = renderLimitStep
		optionsDirty = true
		if not keepValue then
			self:Set({}, false)
		end
		if open then
			rebuildOptions(searchInput.Text)
		end
		return self
	end

	function control:AddOption(valueOption)
		table.insert(self.Options, valueOption)
		optionsDirty = true
		if open then
			rebuildOptions(searchInput.Text)
		end
		return self
	end

	function control:RemoveOption(valueOption)
		for index, itemValue in ipairs(self.Options) do
			if itemValue == valueOption then
				table.remove(self.Options, index)
				break
			end
		end

		for index = #self.Value, 1, -1 do
			if self.Value[index] == valueOption then
				table.remove(self.Value, index)
			end
		end

		updateLabel()
		window:_setFlag(options.Flag, self.Value)
		optionsDirty = true
		if open then
			rebuildOptions(searchInput.Text)
		end
		return self
	end

	function control:ClearOptions()
		self.Options = {}
		renderLimit = renderLimitStep
		self:Set({}, false)
		disconnectConnections(self._optionConnections)
		for _, child in ipairs(optionsFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		optionsDirty = false
		return self
	end

	function control:Destroy()
		window:_trackDropdownOpen(control, false)
		disconnectConnections(self._optionConnections)
		if optionsFrame and optionsFrame.Parent then
			optionsFrame:Destroy()
		end
		item:Destroy()
	end

	function control:SetLoading(loading, text)
		self.Loading = loading == true
		self:SetDisabled(self.Loading)
		if self.Loading then
			selectedLabel.Text = tostring(text or "Loading...")
		else
			updateLabel()
		end
		return self
	end

	updateLabel()
	setButtonHover(window, header, "Item", "ItemHover", control)
	window:_registerControl(options.Flag, control)
	window:_registerSearchItem(options.Name, item, self._sectionInfo)
	attachTooltip(window, control, item, options.Tooltip)
	return attachControlBase(control, item)
end

function HostMethods:CreateConfigManager(options)
	options = normalizeOptions(options, "Configuration")
	local window = self._window
	local host = options.Inline == true and self or self:CreateSection({
		Name = options.Name,
		Icon = options.Icon or "save",
	})

	local selectedProfile = window.ConfigFileName or "default"
	local profiles = window:GetProfiles()
	if #profiles == 0 then
		profiles = { selectedProfile }
	end

	local dropdown = host:CreateDropdown({
		Name = options.ProfileLabel or "Profile",
		Options = profiles,
		CurrentOption = selectedProfile,
		Callback = function(value)
			if value ~= nil and tostring(value) ~= "" then
				selectedProfile = tostring(value)
			end
		end,
	})

	local input = host:CreateInput({
		Name = options.NameLabel or "New Profile",
		PlaceholderText = options.PlaceholderText or "profile-name",
		Callback = function(value)
			if value ~= nil and tostring(value) ~= "" then
				selectedProfile = tostring(value)
			end
		end,
	})

	local generatedControls = { dropdown, input }

	local control = {
		Instance = host._section or host._container,
		Dropdown = dropdown,
		Input = input,
		Value = selectedProfile,
	}

	function control:GetProfile()
		local inputValue = input and ((input.TextBox and input.TextBox.Text) or input.Value) or ""
		if inputValue ~= nil and tostring(inputValue) ~= "" then
			return tostring(inputValue)
		end

		return tostring(selectedProfile or window.ConfigFileName or "default")
	end

	function control:Refresh()
		local nextProfiles = window:GetProfiles()
		if #nextProfiles == 0 then
			nextProfiles = { self:GetProfile() }
		end

		if dropdown and dropdown.Refresh then
			dropdown:Refresh(nextProfiles, true)
		end
	end

	function control:Save()
		local profile = self:GetProfile()
		local okSave, err = window:SaveConfig(profile)
		if okSave then
			selectedProfile = profile
			window.ConfigFileName = profile
			self.Value = profile
			self:Refresh()
			window:Notify({
				Name = "Config Saved",
				Content = profile,
				Icon = "save",
			})
		else
			window:Notify({
				Name = "Config Save Failed",
				Content = tostring(err),
				Icon = "alert-circle",
				Color = window.Theme.Danger,
			})
		end

		return okSave, err
	end

	function control:Load()
		local profile = self:GetProfile()
		local okLoad, err = window:LoadConfig(profile)
		if okLoad then
			selectedProfile = profile
			window.ConfigFileName = profile
			self.Value = profile
			window:Notify({
				Name = "Config Loaded",
				Content = profile,
				Icon = "check",
			})
		else
			window:Notify({
				Name = "Config Load Failed",
				Content = tostring(err),
				Icon = "alert-circle",
				Color = window.Theme.Danger,
			})
		end

		return okLoad, err
	end

	table.insert(generatedControls, host:CreateButton({
		Name = options.SaveLabel or "Save Profile",
		Icon = "save",
		Callback = function()
			control:Save()
		end,
	}))

	table.insert(generatedControls, host:CreateButton({
		Name = options.LoadLabel or "Load Profile",
		Icon = "refresh",
		Callback = function()
			control:Load()
		end,
	}))

	table.insert(generatedControls, host:CreateButton({
		Name = options.RefreshLabel or "Refresh Profiles",
		Icon = "rotate-cw",
		Callback = function()
			control:Refresh()
		end,
	}))

	function control:Destroy()
		for _, childControl in ipairs(generatedControls) do
			if childControl and type(childControl.Destroy) == "function" then
				childControl:Destroy()
			end
		end

		if options.Inline ~= true and host and type(host.Destroy) == "function" then
			host:Destroy()
		elseif self.Instance then
			self.Instance:Destroy()
		end
	end

	return attachControlBase(control, control.Instance)
end

function HostMethods:CreateThemeEditor(options)
	options = normalizeOptions(options, "Theme Editor")
	local window = self._window
	local fields = options.Fields or {
		"Background",
		"Surface",
		"Item",
		"Text",
		"SubText",
		"Accent",
		"Stroke",
	}
	local autoApply = options.AutoApply ~= false
	local host = options.Inline == true and self or self:CreateSection({
		Name = options.Name,
		Icon = options.Icon or "palette",
		Collapsible = options.Collapsible,
	})

	local presets = {}
	local preferredPresets = { "Bluesky", "Dark", "Light", "Midnight", "Emerald", "Amethyst", "Rose", "Amber" }
	local seenPresets = {}
	for _, presetName in ipairs(preferredPresets) do
		if Bluesky.Themes[presetName] then
			table.insert(presets, presetName)
			seenPresets[presetName] = true
		end
	end
	for presetName in pairs(Bluesky.Themes) do
		if not seenPresets[presetName] then
			table.insert(presets, presetName)
		end
	end
	table.sort(presets, function(a, b)
		local aSeen = seenPresets[a] == true
		local bSeen = seenPresets[b] == true
		if aSeen ~= bSeen then
			return aSeen
		end
		return a < b
	end)

	local activeTheme = copyTheme(options.Theme or options.Preset or window.Theme)
	local pickerControls = {}
	local generatedControls = {}

	local control = {
		Instance = host._section or host._container,
		Value = activeTheme,
	}

	local function applyToPickers(invoke)
		for _, field in ipairs(fields) do
			local picker = pickerControls[field]
			if picker and typeof(activeTheme[field]) == "Color3" then
				picker:Set(activeTheme[field], invoke)
			end
		end
	end

	local function applyTheme()
		if autoApply then
			window:SetTheme(activeTheme)
		end
	end

	local presetDropdown = host:CreateDropdown({
		Name = options.PresetLabel or "Preset",
		Options = presets,
		CurrentOption = options.Preset or "Bluesky",
		Callback = function(value)
			if type(value) == "string" and Bluesky.Themes[value] then
				activeTheme = copyTheme(value)
				control.Value = activeTheme
				applyToPickers(false)
				window:SetTheme(activeTheme)
			end
		end,
	})
	table.insert(generatedControls, presetDropdown)

	for _, field in ipairs(fields) do
		if typeof(activeTheme[field]) == "Color3" then
			local picker = host:CreateColorPicker({
				Name = field,
				CurrentValue = activeTheme[field],
				FireOnDrag = false,
				Callback = function(color)
					activeTheme[field] = color
					control.Value = activeTheme
					applyTheme()
				end,
			})
			pickerControls[field] = picker
			table.insert(generatedControls, picker)
		end
	end

	table.insert(generatedControls, host:CreateButton({
		Name = options.ApplyLabel or "Apply Theme",
		Icon = "check",
		Callback = function()
			window:SetTheme(activeTheme)
		end,
	}))

	table.insert(generatedControls, host:CreateButton({
		Name = options.ResetLabel or "Reset Theme",
		Icon = "rotate-cw",
		Callback = function()
			control:Reset()
		end,
	}))

	function control:GetTheme()
		return copyTheme(activeTheme)
	end

	function control:SetTheme(themeConfig)
		activeTheme = copyTheme(themeConfig)
		self.Value = activeTheme
		applyToPickers(false)
		window:SetTheme(activeTheme)
		return self
	end

	function control:Reset()
		return self:SetTheme(options.ResetTheme or options.Preset or "Bluesky")
	end

	function control:SetDisabled(disabled)
		self.Disabled = disabled == true
		for _, childControl in ipairs(generatedControls) do
			if childControl and type(childControl.SetDisabled) == "function" then
				childControl:SetDisabled(self.Disabled)
			end
		end
		setControlDisabledVisual(self.Instance, self.Disabled)
		return self
	end

	function control:Destroy()
		for _, childControl in ipairs(generatedControls) do
			if childControl and type(childControl.Destroy) == "function" then
				childControl:Destroy()
			end
		end

		if options.Inline ~= true and host and type(host.Destroy) == "function" then
			host:Destroy()
		elseif self.Instance then
			self.Instance:Destroy()
		end
	end

	return attachControlBase(control, control.Instance)
end

function HostMethods:CreateKeybind(options)
	options = normalizeOptions(options, "Keybind")
	options.Callback = ensureType(options.Callback, "function", "CreateKeybind.Callback", options.Callback)
	options.Pressed = ensureType(options.Pressed, "function", "CreateKeybind.Pressed", options.Pressed)
	local window = self._window
	local theme = window.Theme
	local defaultKey = parseKeyCode(options.CurrentKeybind or options.CurrentValue or options.Default or Enum.KeyCode.Unknown)

	if typeof(defaultKey) ~= "EnumItem" or defaultKey.EnumType ~= Enum.KeyCode then
		defaultKey = Enum.KeyCode.Unknown
	end

	local item = createContainer(self._container, theme, 46)
	padding(item, 12, 12, 0, 0)
	local itemScale = addScale(item, 1)

	makeText(item, options.Name, 13, theme.Text, {
		Font = Enum.Font.GothamMedium,
		Size = UDim2.new(1, -112, 1, 0),
	})

	local bindButton = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = theme.SurfaceAlt,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(102, 28),
		Text = "",
		Parent = item,
	})
	corner(bindButton, 6)
	stroke(bindButton, theme.Stroke, 0.35, nil)
	local bindScale = addScale(bindButton, 1)

	local bindLabel = makeText(bindButton, "", 12, theme.SubText, {
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local listening = false
	local control = {
		Instance = item,
		Value = defaultKey,
		Disabled = options.Disabled == true,
		Callback = options.Callback,
		Pressed = options.Pressed,
	}

	local function keyToText(keyCode)
		if keyCode == Enum.KeyCode.Unknown then
			return "NONE"
		end

		return tostring(keyCode.Name):upper()
	end

	local function updateLabel()
		bindLabel.Text = listening and "PRESS KEY..." or keyToText(control.Value)
		bindLabel.TextColor3 = listening and window.Theme.Text or window.Theme.SubText
	end

	function control:Set(keyCode, invoke)
		keyCode = parseKeyCode(keyCode)
		if typeof(keyCode) ~= "EnumItem" or keyCode.EnumType ~= Enum.KeyCode then
			keyCode = Enum.KeyCode.Unknown
		end

		self.Value = keyCode
		window:_setFlag(options.Flag, keyCode)
		updateLabel()

		if invoke ~= false then
			safeCall(self.Callback, keyCode)
		end
	end

	function control:SetPressed(callback)
		if type(callback) == "function" then
			self.Pressed = callback
		else
			self.Pressed = nil
		end

		return self
	end

	function control:Destroy()
		item:Destroy()
	end

	window:_registerControl(options.Flag, control)
	window:_registerSearchItem(options.Name, item, self._sectionInfo)
	setButtonHover(window, item, "Item", "ItemHover")
	attachTooltip(window, control, item, options.Tooltip)
	updateLabel()

	connectScoped(window, control, bindButton.MouseButton1Click, function()
		if control.Disabled then
			return
		end

		listening = true
		updateLabel()

		if window.Animations then
			pressScale(bindScale)
		end
	end)

	connectScoped(window, control, item.InputBegan, function(input)
		if control.Disabled or not isInputStart(input) then
			return
		end

		if window.Animations then
			pressScale(itemScale)
		end
	end)

	connectScoped(window, control, UserInputService.InputBegan, function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if listening then
			if control.Disabled then
				listening = false
				updateLabel()
				return
			end

			if input.KeyCode ~= Enum.KeyCode.Unknown then
				control:Set(input.KeyCode)
			end
			listening = false
			updateLabel()
			return
		end

		if control.Value ~= Enum.KeyCode.Unknown and input.KeyCode == control.Value then
			safeCall(control.Pressed, input.KeyCode)
		end
	end)

	return attachControlBase(control, item)
end

return Bluesky

