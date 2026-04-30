# Changelog

## 0.9.1

- Changed the release builder to output a pure library artifact at `dist/bluesky_ui.lua` by default.
- Removed demo-bundle release flow from the GitHub-ready package.
- Increased default sidebar widths on desktop and touch devices for better tab label readability.

## 0.9.0

- Improved narrow-window responsiveness for the top bar so title/search/control buttons do not overlap.
- Increased and auto-adjusted sidebar width for longer tab labels, with scrollable navigation, tab tooltips, and text truncation.
- Moved dropdown and multi-dropdown option lists to an overlay layer so opening them no longer pushes page layout.
- Added progressive rendering for large dropdown and multi-dropdown option lists.
- Added scoped lifecycle cleanup for notification toast controls.
- Cleaned up temporary drag and resize input listeners after each interaction.
- Added documented toast handle methods: `Close()`, `Destroy()`, `SetTitle()`, `SetContent()`, and `SetProgress()`.
- Added modal keyboard behavior: `Escape` cancels active confirm modal and `Enter` confirms it.
- Added library build script and smoke test source for compile checks.

## 0.8.0

- Added density mode, confirm dialogs, tooltips, input validation, button loading state, searchable dropdowns, richer notifications, and sidebar collapse.

## 0.7.x

- Added scoped cleanup, improved color picker, Theme Editor, window state persistence, mobile polish, fullscreen, resize handle, and stronger config tools.
