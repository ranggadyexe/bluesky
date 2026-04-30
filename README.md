# Bluesky UI Documentation

Bluesky UI is a lightweight Roblox/Luau UI library with a Rayfield-friendly API surface.

## Quick Start

```lua
local Bluesky = loadstring(game:HttpGet("https://your-raw-url/bluesky_ui.lua"))()

local Window = Bluesky:CreateWindow({
	Name = "Bluesky UI",
	Subtitle = "v" .. Bluesky.Version,
	Icon = "house",
	Theme = "Bluesky",
	Density = "Comfortable", -- or "Compact"
	ToggleUIKeybind = Enum.KeyCode.RightControl,
	Resizable = true,
	FullscreenMargin = 12,
	MaxNotifications = 4,
	ConfirmClose = true,
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "BlueskyUI",
		FileName = "default",
		AutoLoad = true,
		AutoSave = true,
		SaveWindowState = true,
	},
})
```

## Rayfield-Compatible Calls

```lua
local Main = Window:CreateTab("Main", "home")
local Section = Main:CreateSection({
	Name = "Automation",
	Icon = "zap",
	Collapsible = true,
})

Section:CreateSlider({
	Name = "Walk Speed",
	Range = { 16, 120 },
	Increment = 1,
	Suffix = "studs",
	CurrentValue = 32,
	Flag = "walk_speed",
})

Section:CreateInput({
	Name = "Target",
	PlaceholderText = "username",
	HelperText = "Minimum 3 characters.",
	ErrorText = "Username is too short.",
	SuccessText = "Looks valid.",
	Validate = function(value)
		return #tostring(value) >= 3
	end,
	RemoveTextAfterFocusLost = false,
	Flag = "target",
})

Section:CreateLabel({
	Name = "Status: Ready",
	Icon = "info",
})
```

Global helpers are available after `CreateWindow`:

```lua
Bluesky:Notify({ Title = "Ready", Content = "Window created.", Image = "check" })
Bluesky:Confirm({ Title = "Confirm", Content = "Continue?", OnConfirm = function() end })
Bluesky:SaveConfiguration("pvp")
Bluesky:LoadConfiguration("pvp")
```

## Phase 8 Polish

Professional polish APIs added in Phase 8:

- `Density = "Compact" | "Comfortable"` controls default spacing and control heights.
- `Window:Confirm(options)` creates a small confirmation modal for destructive actions.
- `Tooltip = "text"` works on common controls.
- `CreateInput` supports `HelperText`, `ErrorText`, `SuccessText`, and `Validate`.
- `CreateButton` supports `SetLoading(true, "Working...")`.
- `Window:Notify` supports `Type = "Success" | "Info" | "Warning" | "Error"`, close button, progress bar, and `MaxNotifications`.
- `CreateDropdown({ Search = true })` enables built-in option search, selected-state styling, loading state, and outside-click close.
- `Window:ToggleSidebar()` collapses sidebar navigation into icon-only mode.

Phase 9 polish:

- Topbar responds to narrow window sizes by hiding search before it overlaps title/buttons.
- Sidebar auto-widens for longer tab names, scrolls when tab count exceeds available space, truncates cleanly, and exposes tab tooltips.
- Dropdown and multi-dropdown popups render in an overlay layer so they no longer push content downward.
- Large dropdown lists render options progressively with a `Show more` row; tune with `RenderLimit` or `MaxRenderedOptions`.
- Confirm modals support `Escape` to cancel and `Enter` to confirm.
- Toasts clean up scoped connections and return a handle with `Close()`, `Destroy()`, `SetTitle()`, `SetContent()`, and `SetProgress()`.
- Drag and resize interactions clean up temporary input connections after each interaction.
- `build_bundle.ps1` builds a pure library release in `dist/bluesky_ui.lua`.
- Desktop and mobile sidebar defaults are wider for professional navigation readability.

Examples:

```lua
Window:Notify({
	Title = "Saved",
	Content = "Profile updated.",
	Type = "Success",
})

Window:Confirm({
	Title = "Delete Profile",
	Content = "This cannot be undone.",
	ConfirmText = "Delete",
	Color = Window.Theme.Danger,
	OnConfirm = function()
		Window:DeleteConfig("pvp")
	end,
})

local Button = Section:CreateButton({
	Name = "Fetch Data",
	Tooltip = "Shows loading state.",
	Callback = function()
		Button:SetLoading(true)
		task.delay(1, function()
			Button:SetLoading(false)
		end)
	end,
})
```

Toast handle example:

```lua
local Toast = Window:Notify({
	Title = "Working",
	Content = "Starting...",
	Progress = false,
})

Toast:SetContent("Halfway")
Toast:Close()
```

## Icons

Bluesky tries to load the same Rayfield Lucide icon library from:

```lua
Bluesky.IconLibraryUrl
```

Use Lucide names directly:

```lua
Window:CreateTab("Home", "house")
Window:Notify({ Title = "Saved", Content = "Profile saved.", Image = "save" })
```

If remote icon loading is unavailable, Bluesky falls back to an expanded LucideLite text preset. Unknown icon names render a generic fallback icon and warn once.

## Secure Asset Mode

Secure mode avoids remote Lucide loading and skips detectable Roblox asset id icons.

```lua
local Window = Bluesky:CreateWindow({
	Name = "Secure Hub",
	SecureMode = true,
	RemoteIcons = false,
})
```

You can also set:

```lua
getgenv().BLUESKY_SECURE = true
```

## Config Saving

```lua
local ok, err = Window:SaveConfig("pvp")
local okLoad, loadErr = Window:LoadConfig("pvp")
local okDelete, deleteErr = Window:DeleteConfig("pvp")
Window:ResetConfig()
local profiles = Window:GetProfiles()
```

`AutoSave = true` saves after flag changes with a short debounce.
`SaveWindowState = true` also saves window position, window size, and minimized icon position.

You can also react to flag changes:

```lua
Window:OnFlagChanged("walk_speed", function(value, oldValue, flag)
	print(flag, oldValue, value)
end)
```

## Profile Manager

```lua
local Settings = Window:CreateTab("Settings", "settings")

Settings:CreateConfigManager({
	Name = "Profiles",
	Icon = "save",
})
```

This creates profile dropdown, profile input, save, load, and refresh controls.

## Theme Editor

```lua
Settings:CreateThemeEditor({
	Name = "Theme Editor",
	Icon = "palette",
	Collapsible = true,
})
```

The editor includes preset selection, color previews, color pickers for core theme fields, apply, and reset. It returns `GetTheme()`, `SetTheme(theme)`, `Reset()`, `Destroy()`, `SetVisible()`, and `SetDisabled()`.

`CreateColorPicker` uses a visual saturation/value picker plus hue slider, with RGB fields kept for precise numeric edits. Set `FireOnDrag = false` when the callback is expensive; Theme Editor uses this so full theme repaint runs after drag release.

## Window Controls

- Top bar minimize, close, and maximize/fullscreen buttons.
- `Window:ToggleMaximize()`, `Window:Maximize()`, and `Window:RestoreSize()`.
- Bottom-right resize handle when `Resizable ~= false`.
- Responsive topbar avoids overlap when the window is resized smaller.
- Sidebar supports auto width, truncation, tooltips, and `Window:ToggleSidebar()`.
- Mobile/emulator sizing uses a medium default window instead of filling most of the screen.
- Touch devices use a compact sidebar, larger tab rows, thicker scrollbars, and a larger resize hitbox.

## Control State

Returned controls support common helpers:

```lua
local Toggle = Section:CreateToggle({ Name = "Auto Farm", Flag = "auto_farm" })
Toggle:SetDisabled(true)
Toggle:SetVisible(false)
Toggle:Destroy()
```

Dropdowns also support runtime option edits:

```lua
local Dropdown = Section:CreateDropdown({ Name = "Mode", Options = { "A", "B" }, Search = true })
Dropdown:AddOption("C")
Dropdown:RemoveOption("A")
Dropdown:ClearOptions()
Dropdown:SetLoading(true)
```

## Components

- `CreateLabel`
- `CreateImage`
- `CreateCard`
- `CreateButton`
- `CreateToggle`
- `CreateSlider`
- `CreateDropdown`
- `CreateMultiDropdown`
- `CreateInput`
- `CreateColorPicker`
- `CreateKeybind`
- `CreateThemeEditor`
- `CreateParagraph`
- `CreateDivider`
- `CreateConfigManager`
- `window:Notify`
- `window:Confirm`

## Notes

- `ToggleKey` and `ToggleUIKeybind` are both supported.
- `Title` works as an alias for `Name` in most places.
- `Image` works as an alias for notification icon.
- Common controls support `Get`, `SetVisible`, `SetDisabled`, `SetCallback`, and `Destroy` where applicable.
- Config saving requires executor filesystem functions.
- Rayfield Lucide icons require `game:HttpGet` and `loadstring`; otherwise fallback icons are used.

## Build And Smoke Check

Default release output is pure library only:

```powershell
.\build_bundle.ps1
```

If you keep a local `check-luau.cmd` beside the repository, compile-check the release files with:

```powershell
.\check-luau.cmd .\bluesky_ui.lua .\dist\bluesky_ui.lua .\bluesky_smoke.lua
```

If PowerShell script execution is blocked on the machine, run the builder with:

```powershell
PowerShell -ExecutionPolicy Bypass -File .\build_bundle.ps1
```
