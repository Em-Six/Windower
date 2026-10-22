# DomainFarm — Retail FFXI / Windower 4

**Version:** 0.4.0-test. Six-character Escha Beads HUD and 90-second Silmaril startup delay; **not validated in-game**. Use at your own risk; automation may contravene the game's terms of service.

DomainFarm is a *per-client* state machine for Zi'Tah → Ru'Aun → Reisenjima Domain Invasion. It uses Superwarp for HP teleports and NPC interaction, GearSwap for rings, `windower.ffxi.run(angle)` for movement, Silmaril for combat, and Windower IPC to pause other loaded instances if one fails. Silmaril starts **90 seconds after confirmed DI entry** and is explicitly stopped with `//sm stop` as soon as the addon detects DI completion (including timeout fallback).

## Changes in v0.4

- **90-second Silmaril delay:** Each instance waits 90 seconds after confirmed Domain Invasion entry before sending `sm start`, instead of 60. The countdown is per client; it is not a synchronized six-character barrier. `//df status` shows the time remaining.
- **Top-centre Escha Beads HUD:** Each client requests its real bead balance from the server using the game's Currencies 2 request (`0x115`), decodes the corresponding server packet (`0x118`, `Escha Beads`), and shares the number over Windower IPC. The HUD displays the six automatically discovered character names and totals on **every** running instance.
- **Regular updates:** Balances refresh approximately every 45 seconds when logged in, including when farming is stopped or paused. The HUD displays `--` for unknown, disconnected or stale values rather than inventing a total; it shows how many clients have a current reading. Names appear as clients load the addon and announce themselves.
- **HUD controls:** `//df beads hide`, `//df beads show`, or `//df beads refresh` (force a currency request). These affect the local client's HUD; to hide it everywhere, issue `hide` on each client. The addon starts with the HUD shown.
- **Existing behaviour retained:** Navigation, routes, Dem zone ID **108**, Silmaril stopping when DI ends, retry handling and group controls are unchanged.

**Upgrading:** Replace `DomainFarm.lua` and `README.md` in your existing `addons/DomainFarm` folder and type `//lua reload DomainFarm` on all six instances. **Keep your `routes.tsv` file.** The zip intentionally does not contain routes, so it cannot overwrite saved coordinates. The display does not require any recorded routes and runs even when DomainFarm isn't farming.

## Dependencies

- Windower 4, latest **AkadenTK Superwarp**, GearSwap, Silmaril with `//sm start` command.
- On **each** character: ring2 GearSwap command must work for `Warp Ring` and `Dim. Ring (Dem)`.
- Home Point destination for Warp Ring must be near an NPC/home point that Superwarp can use to warp to the next area. **Test manually** `//sw hp Qufim Island` and `//sw hp Misareaux Coast` after using Warp Ring.
- You must have unlocked the home points/entry portals, and initial Escha access.
- FFXI in English for automatic reward-chat parsing. Battle completion can also be inferred when a previously seen boss disappears; this is a heuristic.

## Install

Copy the entire `DomainFarm` directory into `Windower4/addons/`, then `//lua load DomainFarm` on each character. Place all six clients on the same Windower installation if you want the same `routes.tsv` file. The addon does **not** start until commanded.

## Coordinate recording — required once

**No routes are pre-populated**, because hard-coding unverified coordinates would risk stuck characters. You only need to record each path once on one character; all clients can load the saved TSV from the addon folder.

Record these six paths, starting at the **normal arrival location** and ending *within interaction range* of the entrance or DI NPC:

| Name | Begin | End |
|---|---|---|
| `qufim` | Arrival from `//sw hp Qufim Island` | Undulating Confluence in Qufim |
| `zitah` | Arrival in Escha - Zi'Tah | Affi (F-10) |
| `misareaux` | Arrival from `//sw hp Misareaux Coast` | Dimensional Portal in Misareaux |
| `ruaun` | Arrival in Escha - Ru'Aun | Dremi (H-11) |
| `dem` | Arrival from Dim. Ring (Dem), Tahrongi Canyon (zone ID 108) | Dimensional Portal at the Crag |
| `reisenjima` | Arrival in Reisenjima | Shiftrix (F-12) |

Example for the first route:

1. Use `//sw hp Qufim Island` manually and stand at the arrival spot.
2. Type `//df record qufim`.
3. Walk normally to the Undulating Confluence, following a clear/usable path.
4. Stop within interaction range and type `//df record stop`.
5. Repeat for the remaining routes. New route recordings sample every 2 yalms (from per-frame positions), preserving corners more accurately. Route movement still does **not** calculate collision or navmesh.
6. On each other character, type `//df reload` (or restart the addon). You can inspect counts with `//df routes`. Existing `routes.tsv` files still work with v0.2; re-record only if a route cuts a corner or ends in the wrong location.

Do **not** manually add positions while farming is active. Only one character should record a route at a time (the file is shared).

## Running

- `//df start zitah` — start this client assuming Zi'Tah is the active area.
- `//df start ruaun`, `//df start reisenjima` — manual active-area override.
- `//df start` — infer a starting zone *only if presently in one of the six known zones*. It does not query the server's current active Domain Invasion zone when elsewhere. `Whereisdi` is a separate addon; no API integration is assumed.
- `//df start all zitah` — send START to all Windower instances that have DomainFarm loaded, and also start this one.
- `//df status` — show state, target, retry/route progress and the remaining Silmaril countdown.
- `//df beads refresh` — immediately request an updated balance for this character. The value automatically reaches the other running clients.
- `//df beads hide` / `//df beads show` — toggle the six-character top-centre display for this game window.
- `//df pause all`, `//df resume all`, `//df stop all` — coordinated control. `//df stop` affects only this client.
- `//df set reisenjima` — force target on this client if rotation was missed. Use caution; `set` resets travel.
- `//df done` — manually declare completion **only while in FIGHT state**.

Each character independently controls its own walking, teleports and Silmaril. It does not wait for all six to catch up normally. **After an exhausted movement/teleport retry or battle timeout, it broadcasts a PAUSE and stops movement on every loaded client.** Resuming will recalculate a route, but you may need to manually recover a displaced character first.

## Beads HUD notes

The six running clients discover one another by Windower IPC; **you do not need to enter six character names**. The names are sorted alphabetically for a consistent display, arranged in two columns of three. Until six clients are detected, unused slots read `Waiting...`. You must load this updated addon on **all six Windower instances** to get all six totals.

A sample layout (values are illustrative only):

```text
           ESCHA BEADS (6/6 reporting)
Arayala       12,500       Merako        31,750
Kateye        18,000       Sensarity     22,450
Luicia        30,100       Ysara         49,900
```

Balances are queried from the server rather than extrapolated from battle chat. Requests are automatically sent around once every 45 seconds, so a bead gain may take up to that long to appear. The HUD is recreated at each reload. A value disappears to `--` if the reading is more than three minutes old or its character has not been heard from for 90 seconds. A running instance must receive a response to the `0x115` request; if the number remains `--`, use `//df beads refresh` and confirm that Windower's packets library is up to date. Other addons using Windower IPC normally coexist, since DomainFarm uses a distinct `DOMAINFARM|BEADS|` message prefix.

**Important:** Extra Windower clients running DomainFarm beyond your intended six may appear in the automatically sorted first six. Keep the addon loaded on only the intended six if you require exactly their figures.

## Caveats to test before a six-box run

1. **GearSwap ring command:** Check the exact string from the user's GearSwap profile. Inventory/equipment cooldowns and ring availability are not directly inspected; action timeout and retries are used.
2. **Superwarp home point requirement:** Superwarp usually needs a reachable home point; landing from Warp Ring at a distant bind spot will prevent the HP teleport. The current implementation retries then pauses, not teleport by magic.
3. **Starting in an unrelated zone:** Supply the zone manually. A global active DI event cannot be inferred solely from your character's current location.
4. **NPC readiness:** `sw ew domain` is retried while waiting for the next spawn, capped at 25 minutes. Boss events can be long or skipped in congested areas.
5. **Fight end:** Reward chat is the preferred confirmation. On detected completion the addon immediately issues `sm stop`, then waits before advancing. Enemy disappearance is fallible when entities unload; after 75 minutes without confirmation it also sends `sm stop` and advances as an **unverified timeout fallback**. This should be monitored, especially for Mireu.
6. **Movement routes:** v0.2 checks waypoints every render frame (not once per second), uses the angle overload of `windower.ffxi.run`, detects already-passed intermediate waypoints and immediately stops within ~1.8 yalms of the recorded final point. Movement is still not navmesh or collision-aware; re-record near sharp corners if needed.
7. **IPC:** IPC messages are sent to **every local Windower instance with DomainFarm loaded**, not restricted to a hard-coded character list. This is intentional for the six clients but a concern if you run extra clients.
8. **Zoning:** The addon stops its movement when the game reports zoning. It does not need to stop Silmaril on zoning, but now explicitly sends `sm stop` when DI completion is detected before travelling.

## Transition sequence

`Zi'Tah / Affi → Domain → 90s delay → Silmaril → sm stop → reward delay → Warp Ring → Superwarp HP Misareaux → walk portal → sw ew enter → Ru'Aun / Dremi → Domain → 90s delay → Silmaril → sm stop → reward delay → Dim. Ring (Dem) → walk Crag portal → sw ew enter → Reisenjima / Shiftrix → Domain → 90s delay → Silmaril → sm stop → reward delay → Warp Ring → Superwarp HP Qufim → ...`

### Source references used for implementation

- Superwarp: https://github.com/AkadenTK/superwarp
- Silmaril: https://github.com/furiex-ffxi/windower-addons/tree/main/Silmaril
- SE's DI explanation: https://forum.square-enix.com/ffxi/threads/56243
- Windower packet fields (`0x118`, Escha Beads): https://github.com/Windower/Lua/blob/dev/addons/libs/packets/fields.lua
- Ivaar Currencies addon for currency request (`0x115`): https://gist.github.com/Ivaar/a95d9e565bd9a0e2036179c0c8cdee58
- Windower `texts` library: https://github.com/Windower/Lua/blob/dev/addons/libs/texts.lua
- FFXI `run(x,y)` interface: https://github-wiki-see.page/m/Windower/Lua/wiki/FFXI-Functions
