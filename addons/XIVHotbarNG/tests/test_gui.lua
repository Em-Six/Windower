-- GUI interaction tests with mocked Windower image/text objects, not an FFXI client.
package.path='./?.lua;./?/init.lua;'..package.path
local GUI=require('lib/gui')
local model=require('lib/model')
local K=require('lib/keycodes')
assert(K.character(0x03,true,'UK')=='\"')
assert(K.character(0x03,true,'US')=='@')
local resources={
    spells={[1]={en='Cure'},[2]={en='Cure IV'},[3]={en='Fire'},[4]={en='Curaga'}},
    job_abilities={[1]={en='Provoke'},[2]={en='Convert'}},
    weapon_skills={[1]={en='Savage Blade'}},
    items={[1]={en='Echo Drops'}},
}
local objects={}
local function primitive()
    local obj={}
    objects[#objects+1]=obj
    return setmetatable(obj,{__index=function(t,k)
        return function(self,...)
            if select('#',...) == 0 then return rawget(self,'_'..k) end
            rawset(self,'_'..k,{...})
        end
    end})
end
local image={new=primitive};local text={new=primitive}
local state=model.new()
local saved,binds,notifications=0,{},{}
local gui; gui=GUI.new('.',image,text,resources,{
    changed=function() saved=saved+1 end,
    binding=function(b,s,key) binds[#binds+1]={b,s,key} end,
    notice=function(m)notifications[#notifications+1]=m end,
    close=function()gui:close()end,
})
local function click(x,y)
    assert(gui:mouse(1,x,y))
    assert(gui:mouse(2,x,y))
end
local function type_string(s)
    local code_lookup={}
    for k,v in pairs(K.normal) do code_lookup[v]=k end
    for i=1,#s do
        local ch=s:sub(i,i)
        local dik=code_lookup[ch]
        assert(dik,'No DIK mapping for '..ch)
        assert(gui:keyboard(dik,true,0,false))
        assert(gui:keyboard(dik,false,0,false))
    end
end
gui:open(state,'WAR')
assert(gui.visible and #gui.hits>30)
gui:select_slot(2,3)
assert(gui.bar==2 and gui.slot==3)
-- Search browser for Cure IV, then assign to 2:3 (job only).
click(140,379) -- search field
-- keyboard search text
assert(gui.focus=='search')
type_string('cure iv')
local results=gui:resource_results()
assert(#results==1 and results[1]=='Cure IV',table.concat(results,','))
click(155,421) -- first result
assert(gui.draft.command=='/ma "Cure IV" <t>')
-- click target <me>, replaces the old <t>
click(621,393)
assert(gui.draft.command=='/ma "Cure IV" <me>',gui.draft.command)
click(580,584) -- Save Action
assert(model.get_slot(state,2,3,'WAR').command=='/ma "Cure IV" <me>')
assert(model.get_slot(state,2,3,'RDM') == nil)
assert(saved>=1)
-- Bars GUI tab, toggles orientation + adjusts size.
click(260,83) -- Bars tab
assert(gui.tab=='Bars')
click(660,394) -- orientation
assert(state.bars[2].vertical)
local prev=state.bars[2].size
click(483,440) -- plus size
assert(state.bars[2].size==prev+2)
-- Palettes GUI: create copy of current.
click(390,83) -- Palettes tab
assert(gui.tab=='Palettes')
click(170,352) -- palette input
assert(gui.focus=='palette_name')
type_string('raid')
click(365,394) -- copy current
assert(state.active_palette=='raid')
assert(model.get_slot(state,2,3,'WAR').command=='/ma "Cure IV" <me>')
-- Keys GUI: key capture with Ctrl+F1 and save.
click(508,83)
assert(gui.tab=='Keys')
click(720,372) -- capture
assert(gui.capture)
assert(gui:keyboard(0x1D,true,4,false)) -- ctrl down
assert(gui:keyboard(0x3B,true,4,false)) -- F1 down
assert(gui.draft.bind=='^F1',gui.draft.bind)
gui:keyboard(0x1D,false,0,false)
click(160,435) -- Save keybind
assert(#binds==1 and binds[1][1]==2 and binds[1][2]==3 and binds[1][3]=='^F1')
-- Editor keyboard input consumes typing, and closes with escape when no field.
assert(gui:keyboard(0x01,true,0,false))
assert(not gui.visible)
print('GUI TESTS PASSED: search, slot edit, target, save, bars, palettes, key capture, close')
