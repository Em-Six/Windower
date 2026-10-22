# XIVHotbar NG changelog

## 0.2.0 — Experimental GUI editor

- Added a native Windower 4 graphical editor opened by `//htbng gui` or right-clicking a hotbar slot/header.
- Added action browsing for spells, job abilities, weapon skills and items, with search and target insertion.
- Added in-game fields for commands, labels and custom PNG icons.
- Added palette creation, selection, copying and guarded deletion from the GUI.
- Added hotbar appearance controls, visibility, scope, orientation, size, spacing, opacity and positioning.
- Added graphical keybind capture and assignment, plus UK/US keyboard typing layouts.
- Suspends this addon's hotbar binds while the GUI is open; restores them on close.
- Preserves 0.1.x character profiles; keeps original XIVHotbar installation untouched.
- Added GUI behaviour and addon integration mock tests.

Known limitations: GUI is fixed size; keyboard input is basic with no clipboard/selection; resource browser is not filtered to unlocked actions; no full multi-line macro library, recast system or controller crossbar yet. In-game validation is still needed.

## 0.1.0 — First experimental Windower hotbar foundation

- Multiple bars and slots, per-job/global contexts, named palettes, custom binds and basic rendering.
