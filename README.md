# Bluesky UI

Bluesky UI is a lightweight Roblox/Luau UI library created by **Wade**. It provides a clean, Rayfield-friendly API for building executor UI windows, tabs, controls, themes, notifications, and configuration tools.

## Installation

Use the main library file directly:

```lua
local Bluesky = loadstring(game:HttpGet("https://raw.githubusercontent.com/ranggadyexe/bluesky/main/Bluesky.lua"))()
```

## Quick Start

```lua
local Window = Bluesky:CreateWindow({
	Name = "My Script",
	Subtitle = "Bluesky UI v" .. Bluesky.Version,
	Icon = "house",
	Theme = "Bluesky",
	Resizable = true,
	ToggleUIKeybind = Enum.KeyCode.RightControl,
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "BlueskyUI",
		FileName = "default",
		AutoLoad = true,
		AutoSave = true,
		SaveWindowState = true,
	},
})

local Main = Window:CreateTab("Main", "home")
local Section = Main:CreateSection({
	Name = "Automation",
	Icon = "zap",
	Collapsible = true,
})

Section:CreateToggle({
	Name = "Auto Farm",
	Flag = "auto_farm",
	CurrentValue = false,
	Callback = function(enabled)
		print("Auto Farm:", enabled)
	end,
})

Section:CreateSlider({
	Name = "Walk Speed",
	Flag = "walk_speed",
	Range = { 16, 120 },
	Increment = 1,
	Suffix = "studs",
	CurrentValue = 32,
})

Window:Notify({
	Title = "Ready",
	Content = "Bluesky UI loaded.",
	Type = "Success",
})
```

## Features

- Rayfield-friendly API surface.
- Resizable window with minimize, fullscreen, responsive topbar, and wider readable sidebar.
- Tabs, sections, collapsible groups, and searchable controls.
- Themes with built-in presets and a small Theme Editor component.
- Buttons, toggles, sliders, inputs, dropdowns, multi-dropdowns, color picker, keybinds, labels, cards, images, paragraphs, and dividers.
- Toast notifications with close/progress support.
- Confirmation modal with `Escape` cancel and `Enter` confirm.
- Config saving/loading with flags and optional window position persistence.
- Lucide/Rayfield icon loading with local text fallback.
- Scoped cleanup for controls, dropdowns, notifications, sections, tabs, and windows.

## Components

```lua
Tab:CreateSection(options)
Section:CreateButton(options)
Section:CreateToggle(options)
Section:CreateSlider(options)
Section:CreateInput(options)
Section:CreateDropdown(options)
Section:CreateMultiDropdown(options)
Section:CreateColorPicker(options)
Section:CreateKeybind(options)
Section:CreateLabel(options)
Section:CreateCard(options)
Section:CreateImage(options)
Section:CreateParagraph(options)
Section:CreateDivider(options)
Section:CreateThemeEditor(options)
Section:CreateConfigManager(options)
```

## Window API

```lua
Window:CreateTab(nameOrOptions, icon)
Window:Notify(options)
Window:Confirm(options)
Window:SetTheme(theme)
Window:Toggle()
Window:Minimize()
Window:Restore()
Window:ToggleMaximize()
Window:ToggleSidebar()
Window:SaveConfig(profileName)
Window:LoadConfig(profileName)
Window:DeleteConfig(profileName)
Window:ResetConfig()
Window:SetFlag(flag, value, invoke)
Window:GetFlag(flag)
Window:OnFlagChanged(flag, callback)
Window:Destroy()
```

Global helpers are available after `CreateWindow`:

```lua
Bluesky:Notify(options)
Bluesky:Confirm(options)
Bluesky:SaveConfiguration(profileName)
Bluesky:LoadConfiguration(profileName)
```

## Repository Files

- `Bluesky.lua` - the library file you load from scripts.
- `README.md` - usage documentation.
- `CHANGELOG.md` - release notes.
- `.gitignore` - ignores local runtime/config noise.

There is no demo bundle, `dist` folder, smoke test, or build script in the release package. The repository is intentionally kept simple so it looks clean when published to GitHub.

## Notes

- Config saving requires executor filesystem functions such as `readfile`, `writefile`, `isfile`, and `makefolder`.
- Remote Lucide icons require `game:HttpGet` and `loadstring`. If unavailable, Bluesky uses fallback text icons.
- `ToggleKey` and `ToggleUIKeybind` are both supported.
- `Title` works as an alias for `Name` in most component options.
- Common returned controls support `SetVisible`, `SetDisabled`, `Destroy`, and usually `Get`/`Set`.
