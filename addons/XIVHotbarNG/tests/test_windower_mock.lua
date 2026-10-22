-- Integration harness: Windower mocks, NOT actual FFXI client.
package.path = './?.lua;./?/init.lua;' .. package.path
local m = {events={}, chat_commands={}, console_commands={}, messages={}}
local player = {name='Testchar', main_job='WAR', main_job_id=1}
local function register_event(...)
    local args = {...}
    local fn = args[#args]
    for i=1,#args-1 do
        m.events[args[i]] = m.events[args[i]] or {}
        table.insert(m.events[args[i]], fn)
    end
end
local function fire(name, ...)
    for _, fn in ipairs(m.events[name] or {}) do fn(...) end
end
local function primitive()
    local obj = {}
    return setmetatable(obj, {__index = function(t,k)
        return function(self, ...)
            if select('#', ...) == 0 then return rawget(self, '_'..k) end
            rawset(self, '_'..k, {...})
        end
    end})
end
package.preload['images'] = function() return {new=primitive} end
package.preload['texts'] = function() return {new=primitive} end
package.preload['resources'] = function() return {jobs={[1]={ens='WAR'},[2]={ens='RDM'}}} end
windower = {
    addon_path = '.',
    ffxi = {
        get_player = function() return player end,
        get_info = function() return {server=88} end,
    },
    register_event = register_event,
    add_to_chat = function(_,line) m.messages[#m.messages+1] = line end,
    chat = {input = function(line) m.chat_commands[#m.chat_commands+1] = line end},
    send_command = function(line) m.console_commands[#m.console_commands+1] = line end,
}
_addon={}
assert(loadfile('xivhotbarng.lua'))()
assert(_addon.name == 'XIVHotbarNG')
local save_path = 'data/server88_Testchar.lua'
assert(io.open(save_path,'rb'))
local function cmd(...) fire('addon command', ...) end
cmd('set','1','1','/ma','"Cure IV"','<me>')
cmd('set','2','1','/ja','"Provoke"','<t>')
cmd('execute','1','1')
assert(m.chat_commands[#m.chat_commands] == '/ma "Cure IV" <me>')
cmd('palette','new','farm','copy')
cmd('palette','select','default')
cmd('bar','2','vertical','on')
cmd('bar','2','size','50')
cmd('bar','1','scope','global')
cmd('bind','1','1','^1')
assert(m.console_commands[#m.console_commands]=='bind %^1 htbng execute 1 1')
cmd('status')
local blob = assert(loadfile(save_path))()
assert(blob.bars[2].vertical and blob.bars[2].size==50)
assert(blob.actions.global.default[1][1].command == '/ma "Cure IV" <me>')
assert(blob.actions.jobs.WAR.default[2][1].command == '/ja "Provoke" <t>')
player = {name='Testchar', main_job='RDM', main_job_id=2}
fire('job change')
cmd('set','2','1','/ja','"Convert"','<me>')
blob = assert(loadfile(save_path))()
assert(blob.actions.jobs.RDM.default[2][1].command == '/ja "Convert" <me>')
assert(blob.actions.jobs.WAR.default[2][1].command == '/ja "Provoke" <t>')
cmd('edit')
-- Click + drag header, then release, ensure position saved
fire('mouse',1,80,245,0,false)
fire('mouse',0,160,255,0,false)
fire('mouse',2,160,255,0,false)
blob = assert(loadfile(save_path))()
assert(blob.bars[1].x == 145 and blob.bars[1].y == 250)
cmd('edit')
cmd('execute','2','1')
assert(m.chat_commands[#m.chat_commands] == '/ja "Convert" <me>')
-- Clicking a populated slot while not in edit mode dispatches exactly once.
local previous = #m.chat_commands
fire('mouse',1,150,272,0,false)
fire('mouse',2,150,272,0,false)
assert(#m.chat_commands == previous + 1)
assert(m.chat_commands[#m.chat_commands] == '/ma "Cure IV" <me>')
fire('unload')
assert(m.console_commands[#m.console_commands]=='unbind %^1')
for _, suffix in ipairs({'', '.bak', '.tmp'}) do os.remove(save_path .. suffix) end
print('MOCK INTEGRATION PASSED: addon loads, commands, job scopes, bind, mouse drag, save, unload')
