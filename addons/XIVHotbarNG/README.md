# XIVHotbar NG — v0.2.0 (Windower 4, experimental)

A **separate** Windower addon prototype inspired by the XIVHotbar and XIUI hotbar systems. No Ashita XIUI code or assets have been copied. This is a **prototype with an in-game GUI editor**; it has not been tested against a running Final Fantasy XI client.

## Install

1. Back up your Windower folders before experimenting. **Do not overwrite the original `xivhotbar` addon.**
2. Extract the `XIVHotbarNG` folder directly into `Windower4/addons/`, so that `Windower4/addons/XIVHotbarNG/xivhotbarng.lua` exists.
3. In FFXI, unload your **existing** XIVHotbar while testing, to avoid overlapping hotbars and conflicting binds: `//lua unload xivhotbar`.
4. Load the prototype: `//lua load xivhotbarng`.
5. **Right-click a visible hotbar slot** or enter `//htbng gui` to open the graphical editor. Two bars appear by default; most slots start empty.
6. To restore your regular setup, use `//lua unload xivhotbarng` and `//lua load xivhotbar`.

This addon does not edit or import original XIVHotbar job files yet. Saved layouts and assignments are written independently to `XIVHotbarNG/data/serverID_Character.lua`. A `.bak` backup is kept when an existing save is replaced.

## What's new in v0.2.0 — graphical editor

**The editor runs inside Windower 4, using image and text primitives.** It does not require Ashita, XIUI, ImGui or an additional DLL.

**Open:** `//htbng gui` or right-click a hotbar slot (right-click a bar header to open its settings). **Close:** X at the top right, Escape if a text field is not focused, or `//htbng gui` again.

1. Choose **Bar 1–10** and **Slot 1–12** using the top two rows. You can also click a hotbar slot outside the GUI to select it; hotbar actions do **not execute** while the editor is open.
2. **Actions:** Pick a type (Spells / Abilities / Weapon Skills / Items / Custom), type at least two characters in Search, and click a matching entry. The Command field will be populated. Choose a target button such as `<t>`, `<me>`, or `<stpc>`, edit the label or custom PNG name, then click **Save action**. The **Clear slot** button removes the action.
3. **Bars:** Change visibility, global/job scope, orientation, icon size, gap, alpha and XY position; rename a bar and click **Apply bar name**. `//htbng edit` can still move hotbar headers by dragging when the editor is closed.
4. **Palettes:** Create a blank palette, duplicate the current one under a new name, switch palettes, or delete a non-default palette (double click confirmation). All hotbars switch together.
5. **Keys:** Select a slot, click **Capture keyboard shortcut**, press a combination (for example Ctrl+F1), then click **Save keybind**. There is also a manual keybind field. Changing the same key to another slot removes it from the old one.

All changes are saved to your own server/character profile. **Existing v0.1 save files are compatible.** Always back up `XIVHotbarNG/data/` before upgrading. Shortcuts belonging to XIVHotbar NG are temporarily unbound while the GUI is open and restored when it closes, to avoid firing abilities as you type. Other addons' keybinds cannot be suspended by this addon.

**Typing limitations (experimental):** text is inserted at the end; Backspace removes the last character and Delete clears the field. Text selection, clipboard paste and IME entry are not implemented yet. The Keys tab offers **UK / US keyboard-layout mapping** for punctuation when entering text; UK is the default. Use the browser wherever possible for spells with spaces/quotation marks. For actions whose name is missing in the browser, select Custom and type a command manually. This isn't yet XIUI's fully featured macro library/editor.

**Screen size:** the editor is designed for at least a 1280 × 720 display. It currently has a fixed window position and size; smaller resolutions may clip the editor.

## Quick start

Commands (enter directly in game chat, starting with `//`):

```text
//htbng set 1 1 /ma "Cure IV" <stpc>
//htbng set 2 1 /ja "Provoke" <t>
//htbng set 2 2 /ws "Savage Blade" <t>
//htbng label 1 1 Cure IV
//htbng clear 2 2
//htbng bars 3
//htbng edit
```

**Important:** XIVHotbar NG sends exactly the command you assign. Confirm that quoted action names and target placeholders survive your Windower chat input; if Windower strips quotes from `//htbng set`, you can manually edit the saved `.lua` file and use `//htbng reload`. The command handler accepts `/ma`, `/ja`, `/ws`, `/item`, `//gs`, and other FFXI/Windower commands in the same slot format.

**Actions:** Left-click an assigned icon to execute it. `//htbng edit` enters editing mode; drag a bar's title to reposition it, or drag a slot onto another to swap their contents. Enter `//htbng edit` again to leave editing mode. Changes save automatically.

### Global and job-specific bars

Each bar has an independent **scope**. A global bar uses the same assigned actions on every job; a job-specific bar has a separate assignment per **main job**. Defaults: bar 1 global, bar 2 job-specific, remaining bars job-specific.

```text
//htbng bar 1 scope global
//htbng bar 2 scope job
//htbng bar 2 vertical on
//htbng bar 2 size 46
//htbng bar 2 gap 5
//htbng bar 2 position 400 700
//htbng bar 2 alpha 230
//htbng bar 2 name Job Abilities
//htbng bar 2 visible off
```

The `bars NUMBER` command sets visibility for the first N bars; use `bar N visible on` if you want a nonconsecutive arrangement. Bars are limited to 10, with 12 slots each.

### Palettes

All bars share one active palette name. Global and job-specific action pages are separate for each palette. Switching palettes does not change bar layout, scope, or keybinds.

```text
//htbng palette new solo
//htbng set 1 1 /ma "Cure IV" <me>
//htbng palette new party copy
//htbng palette select solo
//htbng palette next
//htbng palette list
//htbng palette delete party
```

`new NAME` creates an **empty** palette and switches to it. `new NAME copy` copies the currently selected palette's action assignments across global bars and every existing job profile. Palette names may contain letters, numbers, `_` and `-` (maximum 24 characters). `default` cannot be deleted.

### Keybinds

No keybinds are installed by default. Keys are assigned per bar+slot, not per palette:

```text
//htbng bind 1 1 ^1
//htbng bind 1 2 !2
//htbng bind 2 1 ~F1
//htbng unbind 1 1
```

`^` = Ctrl, `!` = Alt, `~` = Shift. The addon adds `%` automatically to prevent execution while FFXI chat input is open, unbinds its configured keys when unloaded, and rebinds after a reload. **Windower binds are global; assigning a key already used by another addon or the game can conflict.** Avoid the same key on multiple slots. For safety, use an unassigned key combination first.

### Icons and labels

Icons use built-in category images (magic/ability/weapon/item/equipment/command) for this first release. To use a custom icon:

1. Place a PNG in `XIVHotbarNG/assets/custom/`, e.g. `CureIV.png`.
2. Execute `//htbng icon 1 1 CureIV.png`.
3. To restore the default icon, use `//htbng icon 1 1`.

`//htbng label 1 1 ShortName` changes the slot caption. `//htbng status` displays the current character, job, palette and save path. `//htbng reload` reloads the saved profile after editing it.

## Features in this build

| Capability | Status |
|---|---|
| Standalone Windower 4 addon | Implemented (game validation pending) |
| 10 independently positioned bars / 12 slots each | Implemented |
| Adjustable size, gap, opacity, orientation, names, visibility | Implemented |
| Global or main-job-specific bars | Implemented |
| Named palettes, create/select/copy/delete/next | Implemented |
| Command-based action setup + in-game GUI action browser/editor | Implemented (experimental) |
| Clickable icons | Implemented (game validation pending) |
| Drag bars and swap slots | Implemented (game validation pending) |
| Per-slot keybinds | Implemented (game validation pending) |
| Server/character-specific persistence | Implemented |
| Existing XIVHotbar Lua job-file importer | **Not yet** |
| Actual spell/ability artwork | **Not yet** (category icons only) |
| Recast timers/availability/TP/MP costs | **Not yet** |
| In-game GUI for actions, palettes, bars and keybinds | **Implemented (experimental)** |
| Reusable multiline macro library, tooltips and drop UI | **Not yet** |
| Controller crossbars | **Not yet** |
| XIUI visual parity | **Not yet** |

## Important limitations

- This is deliberately **not** a finished XIUI hotbar port. It is a small first playable milestone intended to validate Windower rendering, interactions and persistence.
- Global/job-specific is controlled per **bar**, not per individual slot.
- Job-scoped bars distinguish **main jobs**, not subjob/pet/stance contexts (these are future milestones).
- Actions are not validated against FFXI availability/recasts; a slot merely dispatches its configured command.
- No automatic import of XIVHotbar files yet; retain those files unchanged.
- The GUI editor is an initial release: it is **not yet** a full XIUI-like macro library, with drag-from-browser placement or rich tooltips.
- This addon requires Windower 4 and its included `images`, `texts` and `resources` libraries.
- Most code has been checked statically, but loading and mouse/keybind event behaviour require an actual Windower+FFXI test.

## Project attribution

- [XIVHotbar by Akirane, after SirEdeonX](https://github.com/Akirane/XIVHotbar): Windower action and overlay concepts.
- [XIUI by tirem](https://github.com/tirem/XIUI): reference for feature requirements and palette design, **not** copied code/assets.

The code supplied in this archive is independently authored and distributed under the MIT licence in `LICENSE`. Third-party projects retain their own licences. This release is a prototype, not an endorsed derivative or official release from either maintainer.
