local function loadBluesky()
	if type(readfile) == "function" and type(loadstring) == "function" then
		local ok, library = pcall(function()
			return loadstring(readfile("bluesky_ui.lua"))()
		end)

		if ok and library then
			return library
		end
	end

	return Bluesky
end

local Library = loadBluesky()

local Window = Library:CreateWindow({
	Name = "Bluesky Smoke",
	Subtitle = "API coverage",
	Theme = "Bluesky",
	Density = "Compact",
	Search = true,
	Resizable = true,
	ConfigurationSaving = {
		Enabled = false,
	},
})

local Main = Window:CreateTab("Main Controls With Long Text", "home")
local Section = Main:CreateSection({
	Name = "Smoke Section",
	Icon = "settings",
	Collapsible = true,
})

local Button = Section:CreateButton({
	Name = "Loading Button",
	Tooltip = "Button tooltip",
	Callback = function() end,
})
Button:SetLoading(false)

Section:CreateToggle({ Name = "Toggle", Flag = "toggle_smoke" })
Section:CreateSlider({ Name = "Slider", Flag = "slider_smoke", Range = { 0, 100 }, CurrentValue = 25 })
Section:CreateInput({
	Name = "Validated Input",
	Flag = "input_smoke",
	HelperText = "Type at least 2 characters.",
	Validate = function(value)
		return #tostring(value) >= 2
	end,
})
Section:CreateDropdown({
	Name = "Searchable Dropdown",
	Flag = "dropdown_smoke",
	Options = { "Alpha", "Bravo", "Charlie" },
	Search = true,
})
Section:CreateMultiDropdown({
	Name = "Multi Dropdown",
	Flag = "multi_smoke",
	Options = { "One", "Two", "Three" },
})
Section:CreateColorPicker({ Name = "Color", Flag = "color_smoke" })
Section:CreateKeybind({ Name = "Keybind", Flag = "keybind_smoke" })
Section:CreateThemeEditor({ Name = "Theme Editor", Inline = true })

Window:Notify({ Title = "Smoke", Content = "Ready", Type = "Success" })
Window:Confirm({ Title = "Smoke Confirm", Content = "Confirm modal." })
