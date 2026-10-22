ImprimaturHUD - Windower 4 addon for retail Final Fantasy XI
=============================================================

INSTALLATION
1. Copy the ImprimaturHUD folder to your Windower4/addons/ folder.
2. In-game, enter: //lua load ImprimaturHUD

DISPLAY
The imprimatur count is shown at the top-center of the FFXI window.
Normal = pale white; capped = red with MAX appended.

The addon detects the cap automatically:
  15 = base cap
  16 = Bronze mattock cordon key item
  18 = Silver mattock cordon key item

COMMANDS
  //imps refresh       Request a new count now.
  //imps cap auto      Return to automatic cap detection (default).
  //imps cap 15        Override cap for this session.
  //imps cap 16        Override cap for this session.
  //imps cap 18        Override cap for this session.

HOW IT WORKS
It reads incoming Currency 2 packet 0x118, requesting an update using
outgoing packet 0x115 upon loading, login, or zoning (and manually
with //imps refresh). No recurring timer or polling is used.
It does not estimate regeneration times, scan memory, or write any files.

NOTES
- The counter reads your current, unspent imprimaturs, not assignments
  held in reserve with Task Delegators.
- Initially displays -- until a Currency 2 response is received.
- If the value stays -- and you see a field warning in chat, your local
  Windower packet definitions may label this currency differently or not
  expose it. In that case, please share the warning so it can be adapted.
- This version has been syntax-checked, but cannot be tested against a
  live retail FFXI client in this environment.
