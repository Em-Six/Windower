-- End-to-end mock: actual addon events -> GUI -> character save.
package.path='./?.lua;./?/init.lua;'..package.path
local events, commands, messages = {}, {}, {}
local p={name='GuiTest',main_job='WAR',main_job_id=1}
local function primitive()
 local t={}
 return setmetatable(t,{__index=function(self,k)
  return function(self,...)
   if select('#',...)>0 then rawset(self,'_'..k,{...}) end
  end
 end})
end
package.preload.images=function()return {new=primitive}end
package.preload.texts=function()return {new=primitive}end
package.preload.resources=function()
 return {jobs={[1]={ens='WAR'}},spells={[1]={en='Cure IV'}},job_abilities={},weapon_skills={},items={}}
end
windower={addon_path='.',ffxi={get_player=function()return p end,get_info=function()return {server=99} end},
 register_event=function(...)
  local a={...};local fn=a[#a]
  for i=1,#a-1 do local name=a[i];events[name]=events[name] or {};events[name][#events[name]+1]=fn end
 end,
 add_to_chat=function(_,msg)messages[#messages+1]=msg end,
 send_command=function(cmd)commands[#commands+1]=cmd end,
 chat={input=function(cmd)commands[#commands+1]='CHAT '..cmd end}}
_addon={}
assert(loadfile('xivhotbarng.lua'))()
local function fire(name,...)
 local blocked=false
 for _,fn in ipairs(events[name] or {}) do if fn(...)==true then blocked=true end end
 return blocked
end
local function click(x,y)
 assert(fire('mouse',1,x,y,0,false))
 assert(fire('mouse',2,x,y,0,false))
end
local function key(code,flags)
 assert(fire('keyboard',code,true,flags or 0,false))
 assert(fire('keyboard',code,false,flags or 0,false))
end
local fname='data/server99_GuiTest.lua'
-- Install a bound skill before launching the GUI; verify binds are suspended.
fire('addon command','set','1','1','/ma','"Cure IV"','<me>')
fire('addon command','bind','1','1','^1')
assert(commands[#commands]=='bind %^1 htbng execute 1 1')
fire('addon command','gui')
assert(commands[#commands]=='unbind %^1')
-- Clicking visible part of a hotbar with editor open selects, not casts.
local before=#commands
assert(fire('mouse',1,81,272,0,false))
assert(fire('mouse',2,81,272,0,false))
assert(#commands==before)
-- Use editor to select second bar/slot three; type/search spell name.
click(210,144) -- bar2
click(265,202) -- slot3
click(140,379) -- search
key(0x2E); key(0x16) -- "cu"
click(150,421) -- Cure IV search result
click(575,581) -- save action
local blob=assert(loadfile(fname))()
assert(blob.actions.jobs.WAR.default[2][3].command=='/ma "Cure IV" <t>')
-- Key assignment through GUI; old shortcut stays suspended until closing.
click(509,83) -- Keys
click(724,370) -- Capture
assert(fire('keyboard',0x3C,true,0,false)) -- F2
click(158,440) -- Save
blob=assert(loadfile(fname))()
assert(blob.binds[2][3]=='%F2')
assert(commands[#commands]~='bind %F2 htbng execute 2 3')
-- Close with Esc, restore both shortcuts.
assert(fire('keyboard',0x01,true,0,false))
assert(commands[#commands]=='bind %F2 htbng execute 2 3')
-- Right-click a slot opens the GUI without executing its action.
local old_count=#commands
assert(fire('mouse',4,81,272,0,false))
assert(#commands>old_count and commands[#commands]=='unbind %F2')
fire('addon command','gui')
assert(commands[#commands]=='bind %F2 htbng execute 2 3')
fire('unload')
assert(commands[#commands]=='unbind %F2')
for _,suffix in ipairs({'','.bak','.tmp'}) do os.remove(fname..suffix) end
print('GUI ADDON INTEGRATION PASSED: GUI toggles, suspends binds, saves actions, captures shortcuts, right-click opens')
