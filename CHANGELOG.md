# Changelog

## 0.9.2

- Renamed the public release file from `bluesky_ui.lua` to `Bluesky.lua`.
- Simplified the GitHub package to only include the library, README, changelog, and gitignore.
- Removed `dist`, smoke test, and build script files from the public package.
- Rewrote README wording for a cleaner public release and credited Wade as creator.

## 0.9.1

- Prepared Bluesky UI for a cleaner GitHub release package.
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
- Added internal compile coverage for the library API.

## 0.8.0

- Added density mode, confirm dialogs, tooltips, input validation, button loading state, searchable dropdowns, richer notifications, and sidebar collapse.

## 0.7.x

- Added scoped cleanup, improved color picker, Theme Editor, window state persistence, mobile polish, fullscreen, resize handle, and stronger config tools.
