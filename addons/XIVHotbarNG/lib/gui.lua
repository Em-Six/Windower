-- XIVHotbar NG in-game editor. Windower 4 images/texts only; independent of Ashita.
-- Mouse interactions operate on geometric hitboxes; fields use DIK keyboard events.
local keycodes = require('lib/keycodes')
local model = require('lib/model')
local GUI = {}
GUI.__index = GUI
local WIDTH, HEIGHT = 844, 688
local X, Y = 105, 16
local MAX_RESULT = 7
local type_defs = {
    {id='magic', title='Spells', data='spells', verb='/ma', target='<t>'},
    {id='ability', title='Abilities', data='job_abilities', verb='/ja', target='<me>'},
    {id='ws', title='Weapon Skills', data='weapon_skills', verb='/ws', target='<t>'},
    {id='item', title='Items', data='items', verb='/item', target='<me>'},
    {id='custom', title='Custom', data=nil, verb='', target=''},
}
local function clip(s, max)
    s = tostring(s or '')
    return #s > max and (s:sub(1, max - 2) .. '..') or s
end
local function make_image(images)
    local im = images.new()
    im:draggable(false); im:fit(false); im:alpha(255); im:hide()
    return im
end
local function make_text(texts, size, color)
    local t = texts.new()
    t:bg_visible(false); t:font('Arial'); t:size(size or 11)
    t:color(color[1],color[2],color[3]); t:stroke_width(1)
    t:stroke_color(9,13,23); t:text(''); t:hide()
    return t
end
local function point(rect,x,y)
    return x>=rect.x and y>=rect.y and x<rect.x+rect.w and y<rect.y+rect.h
end
local function sort_resources(raw)
    local found, out = {}, {}
    for id, resource in pairs(raw or {}) do
        if type(resource)=='table' and type(id)=='number' then
            local name = resource.en or resource.english or resource.name
            if type(name)=='string' and #name>0 and #name<90 and not found[name:lower()] then
                found[name:lower()] = true
                out[#out+1] = name
            end
        end
    end
    table.sort(out, function(a,b) return a:lower()<b:lower() end)
    return out
end
local function clean_input(input, limit)
    return tostring(input or ''):sub(1, limit):gsub('[\r\n]', ' ')
end
local function default_draft(record, binds)
    return {
        command = record and record.command or '',
        label = record and record.label or '',
        icon = record and record.icon or '',
        bind = binds and binds:gsub('^%%','') or '',
        search = '',
        palette_name = '',
    }
end

function GUI.new(root, images, texts, resources, handlers)
    local self=setmetatable({root=root:gsub('[\\/]+$','')..'/assets/gui/', images=images, texts=texts,
        resources=resources, handlers=handlers, visible=false, tab='Actions', bar=1, slot=1,
        category=1, result_page=1, images_pool={}, text_pool={}, hits={}, focus=nil,
        shift=false, ctrl=false, alt=false, capture=false, pending_delete=false,
        selected_palette=nil, resource_cache={}, state=nil, job='UNK', draft=default_draft()},GUI)
    return self
end
function GUI:image(x,y,w,h,style)
    self.ii = self.ii + 1
    local im = self.images_pool[self.ii]
    if not im then im=make_image(self.images); self.images_pool[self.ii]=im end
    im:path(self.root..style..'.png')
    im:pos(x,y); im:size(w,h); im:show()
end
function GUI:text(x,y,value,size,accent,maxlen)
    self.ti = self.ti + 1
    local obj=self.text_pool[self.ti]
    if not obj then obj=make_text(self.texts,size or 11, accent and {104,212,252} or {231,237,247}); self.text_pool[self.ti]=obj end
    obj:size(size or 11)
    if accent then obj:color(104,212,252) else obj:color(231,237,247) end
    obj:text(clip(value,maxlen or 110)); obj:pos(x,y); obj:show()
end
function GUI:label(x,y,value) self:text(x,y,value,11,false) end
function GUI:hit(x,y,w,h,callback)
    self.hits[#self.hits+1]={x=x,y=y,w=w,h=h,callback=callback}
end
function GUI:button(x,y,w,h,value,callback,active)
    self:image(x,y,w,h,active and 'button_active' or 'button')
    self:text(x+9,y+math.max(2,math.floor((h-17)/2)),value,11,active,math.max(5,math.floor((w-18)/6.6)))
    self:hit(x,y,w,h,callback)
end
function GUI:field(x,y,w,name,key,maxlen)
    self:text(x,y-18,name,11,true)
    self:image(x,y,w,30,self.focus==key and 'field_focus' or 'field')
    local value=self.draft[key] or ''
    local display_limit=math.max(8,math.floor((w-16)/6.25))
    if self.focus==key and #value>display_limit then
        value='..'..value:sub(-display_limit+2)
    else
        value=clip(value,display_limit)
    end
    self:text(x+8,y+7,value..(self.focus==key and '|' or ''),11,false)
    self:hit(x,y,w,30,function() self.focus=key; self.capture=false; self:render() end)
end
function GUI:resource_results()
    local cat=type_defs[self.category]
    if not cat.data then return {} end
    if not self.resource_cache[cat.data] then
        self.resource_cache[cat.data]=sort_resources(self.resources[cat.data])
    end
    local query=(self.draft.search or ''):lower()
    local filtered={}
    if #query<2 then return {} end
    for _,name in ipairs(self.resource_cache[cat.data]) do
        if name:lower():find(query,1,true) then filtered[#filtered+1]=name end
        if #filtered>=500 then break end
    end
    return filtered
end
function GUI:sync(state,job)
    self.state=state; self.job=job or 'UNK'
    if not state then self:close() return end
    local record=model.get_slot(state,self.bar,self.slot,self.job)
    local bind=state.binds[self.bar] and state.binds[self.bar][self.slot]
    self.draft=default_draft(record,bind)
    self.draft.bar_name=state.bars[self.bar].name
    self.selected_palette=state.active_palette
    self.capture=false; self.focus=nil; self.pending_delete=false
    if self.visible then self:render() end
end
function GUI:select_slot(bar,slot)
    if not self.state then return end
    if type(bar)~='number' or type(slot)~='number' then return end
    self.bar=math.max(1,math.min(10,bar)); self.slot=math.max(1,math.min(12,slot))
    local record=model.get_slot(self.state,self.bar,self.slot,self.job)
    local bind=self.state.binds[self.bar] and self.state.binds[self.bar][self.slot]
    self.draft=default_draft(record,bind)
    self.draft.bar_name=self.state.bars[self.bar].name
    self.focus=nil; self.capture=false; self.result_page=1
    if self.visible then self:render() end
end
function GUI:open(state,job)
    if not state then return end
    self.visible=true
    self.state=state; self.job=job or self.job
    self:select_slot(self.bar,self.slot)
end
function GUI:close()
    self.visible=false; self.focus=nil; self.capture=false
    for _,im in ipairs(self.images_pool) do im:hide() end
    for _,t in ipairs(self.text_pool) do t:hide() end
    self.hits={}
end
function GUI:hide() self:close() end
function GUI:update()
    if self.handlers.changed then self.handlers.changed() end
    self:render()
end
function GUI:save_action()
    local d=self.draft
    local command=clean_input(d.command,512)
    if command=='' then
        self.handlers.notice('Command is empty. Use Clear to remove a slot.')
        return
    end
    if command:sub(1,1)~='/' then
        self.handlers.notice('Commands must start with / (e.g. /ma "Cure" <me>).')
        return
    end
    local icon=clean_input(d.icon,160)
    if icon~='' and not icon:match('^[%w_%-]+%.png$') then
        self.handlers.notice('Icon must be a PNG filename from assets/custom/.')
        return
    end
    local ok=model.set_slot(self.state,self.bar,self.slot,self.job,
        {command=command,label=clean_input(d.label,32),icon=icon})
    if not ok then self.handlers.notice('Could not save this action.') return end
    self:update()
    self.handlers.notice('Saved bar '..self.bar..', slot '..self.slot..'.')
end
function GUI:save_binding()
    local bind=clean_input(self.draft.bind,36)
    if bind~='' and (bind:match('[^%w%^!~%[%]%-]') or #bind>32) then
        self.handlers.notice('Use a Windower key combination, e.g. ^1 or !F1.')
        return
    end
    if self.handlers.binding(self.bar,self.slot,bind=='' and nil or bind)==false then return end
    self.draft.bind=bind
    self:render()
end
function GUI:clear_action()
    model.set_slot(self.state,self.bar,self.slot,self.job,nil)
    self.draft.command='';self.draft.label='';self.draft.icon=''
    self:update()
end
function GUI:choose_resource(name)
    local def=type_defs[self.category]
    self.draft.command=def.verb..' "'..name:gsub('"','')..'" '..def.target
    self.draft.label=name:sub(1,32)
    self.focus=nil
    self:render()
end
function GUI:target(token)
    local command=self.draft.command or ''
    local result,n=command:gsub('<[%w]+>%s*$','')
    self.draft.command=(result:gsub('%s+$','')..' '..token):sub(1,512)
    self:render()
end
function GUI:render()
    if not self.visible or not self.state then return end
    self.ii=0; self.ti=0; self.hits={}
    self:image(X,Y,WIDTH,HEIGHT,'panel')
    self:image(X,Y,WIDTH,42,'title')
    self:text(X+18,Y+11,'XIVHotbar NG  /  In-game editor',17,true)
    self:text(X+565,Y+16,'ESC = unfocus / close',10,false)
    self:button(X+WIDTH-54,Y+8,38,27,'X',function() self.handlers.close() end,false)
    local tabs={'Actions','Bars','Palettes','Keys'}
    for i,tab in ipairs(tabs) do
        self:button(X+17+(i-1)*126,Y+52,116,31,tab,function()
            self.tab=tab; self.focus=nil; self.capture=false; self:render()
        end,self.tab==tab)
    end
    self:text(X+552,Y+60,'Job '..self.job..'  |  '..self.state.active_palette,11,true)
    self:label(X+18,Y+96,'SELECT BAR')
    for i=1,10 do
        local bar=self.state.bars[i]
        self:button(X+19+(i-1)*79,Y+115,71,30,tostring(i)..(bar.visible and '  ON' or '  --'),function()
            self:select_slot(i,self.slot)
        end,i==self.bar)
    end
    self:label(X+18,Y+157,'SELECT SLOT')
    for i=1,12 do
        self:button(X+19+(i-1)*65,Y+177,58,28,tostring(i),function() self:select_slot(self.bar,i) end,i==self.slot)
    end
    self:image(X+18,Y+221,WIDTH-36,2,'divider')
    self:text(X+20,Y+233,('Bar %d / Slot %d    %s scope    Palette: %s'):format(self.bar,self.slot,self.state.bars[self.bar].scope,self.state.active_palette),12,true)
    if self.tab=='Actions' then self:render_actions()
    elseif self.tab=='Bars' then self:render_bars()
    elseif self.tab=='Palettes' then self:render_palettes()
    else self:render_keys() end
    self:image(X+18,Y+HEIGHT-34,WIDTH-36,1,'divider')
    self:text(X+22,Y+HEIGHT-24,'Select a bar and slot above.  Enter = finish text.  Backspace = erase.  Delete = clear field.',10,false)
    for i=self.ii+1,#self.images_pool do self.images_pool[i]:hide() end
    for i=self.ti+1,#self.text_pool do self.text_pool[i]:hide() end
end
function GUI:render_actions()
    local ly=Y+263
    self:label(X+20,ly,'ACTION BROWSER')
    for i,def in ipairs(type_defs) do
        self:button(X+20+(i-1)*103,ly+20,96,29,def.title,function()
            self.category=i; self.result_page=1;self.focus=nil; self:render()
        end,self.category==i)
    end
    if self.category<5 then
        self:field(X+20,ly+89,366,'SEARCH SPELLS / ABILITIES / ITEMS','search',80)
        local results=self:resource_results()
        local page_max=math.max(1,math.ceil(#results/MAX_RESULT))
        self.result_page=math.min(self.result_page,page_max)
        self:text(X+390,ly+98, #self.draft.search<2 and 'Type 2+ letters' or ('Found '..#results),10,false)
        local offset=(self.result_page-1)*MAX_RESULT
        for i=1,math.min(MAX_RESULT,#results-offset) do
            local name=results[offset+i]
            self:button(X+20,ly+128+(i-1)*31,360,28,clip(name,45),function() self:choose_resource(name) end,false)
        end
        self:button(X+20,ly+350,84,28,'< Prev',function()
            self.result_page=math.max(1,self.result_page-1);self:render()
        end,false)
        self:text(X+121,ly+357,('Page %d / %d'):format(self.result_page,page_max),10,false)
        self:button(X+292,ly+350,88,28,'Next >',function()
            self.result_page=math.min(page_max,self.result_page+1);self:render()
        end,false)
    else
        self:text(X+28,ly+85,'Custom mode: type any FFXI or addon command',11,false)
        self:text(X+28,ly+109,'in the Command field. For example: //gs c idle',11,false)
    end
    local rx=X+434
    self:field(rx,ly+40,366,'COMMAND (max 512)','command',512)
    self:label(rx,ly+85,'INSERT / REPLACE TARGET')
    for i,token in ipairs({'<t>','<me>','<stpc>','<stal>','<bt>'}) do
        self:button(rx+(i-1)*73,ly+104,68,25,token,function()self:target(token) end,false)
    end
    self:field(rx,ly+167,366,'LABEL (max 32)','label',32)
    self:field(rx,ly+237,366,'CUSTOM ICON filename.png (optional)','icon',160)
    self:button(rx,ly+292,178,36,'Save action',function()self:save_action()end,true)
    self:button(rx+186,ly+292,180,36,'Clear slot',function()self:clear_action()end,false)
    self:text(rx,ly+341,'Files: assets/custom/*.png  |  Ctrl/Alt/Shift',10,false)
    self:text(rx,ly+356,'Macro lines: use // commands via Windower.',10,false)
end
function GUI:render_bars()
    local cfg=self.state.bars[self.bar]
    local by=Y+273
    self:field(X+24,by+33,355,'BAR NAME','bar_name',24)
    self:label(X+435,by+17,'BAR MODES')
    self:button(X+435,by+39,166,35,cfg.visible and 'Visible: ON' or 'Visible: OFF',function()
        cfg.visible=not cfg.visible; self:update()
    end,cfg.visible)
    self:button(X+610,by+39,178,35,'Scope: '..cfg.scope,function()
        cfg.scope=cfg.scope=='job' and 'global' or 'job';self:update()
    end,cfg.scope=='global')
    self:button(X+435,by+85,353,33,cfg.vertical and 'Orientation: vertical' or 'Orientation: horizontal',function()
        cfg.vertical=not cfg.vertical;self:update()
    end,cfg.vertical)
    local rows={
        {title='Icon size',key='size',step=2,min=22,max=80},
        {title='Slot gap',key='gap',step=1,min=0,max=20},
        {title='Opacity',key='alpha',step=15,min=40,max=255},
        {title='X position',key='x',step=10,min=0,max=10000},
        {title='Y position',key='y',step=10,min=0,max=10000},
    }
    for i,r in ipairs(rows) do
        local yy=by+133+(i-1)*44
        self:label(X+28,yy+6,r.title)
        self:button(X+186,yy,55,33,'-',function()
            cfg[r.key]=math.max(r.min,cfg[r.key]-r.step); self:update()
        end,false)
        self:text(X+267,yy+8,tostring(cfg[r.key]),12,true)
        self:button(X+350,yy,55,33,'+',function()
            cfg[r.key]=math.min(r.max,cfg[r.key]+r.step);self:update()
        end,false)
    end
    self:button(X+433,by+150,355,38,'Apply bar name',function()
        local name=clean_input(self.draft.bar_name,24)
        if name=='' then self.handlers.notice('Enter a bar name first.') return end
        cfg.name=name;self:update()
    end,true)
    self:text(X+440,by+213,'You can move bars by dragging their',11,false)
    self:text(X+440,by+232,'headers using //htbng edit.',11,false)
    self:text(X+440,by+266,'Configuration is shared across palettes.',10,false)
    self:text(X+440,by+283,'Scope controls global vs. job actions.',10,false)
end
function GUI:render_palettes()
    local by=Y+275
    self:field(X+28,by+33,352,'NEW PALETTE NAME (letters / digits / _ / -)','palette_name',24)
    self:button(X+28,by+87,170,35,'Create blank',function()
        local name=self.draft.palette_name
        if not model.create_palette(self.state,name,false) then
            self.handlers.notice('Invalid or duplicate palette name.') return end
        self.selected_palette=name;self:sync(self.state,self.job);self:update()
    end,false)
    self:button(X+208,by+87,174,35,'Copy current',function()
        local name=self.draft.palette_name
        if not model.create_palette(self.state,name,true) then
            self.handlers.notice('Invalid or duplicate palette name.')return end
        self.selected_palette=name;self:sync(self.state,self.job);self:update()
    end,false)
    self:label(X+442,by+1,'AVAILABLE PALETTES')
    local names=model.palette_names(self.state)
    local page=math.max(1,math.ceil(#names/8))
    self.palette_page=math.max(1,math.min(self.palette_page or 1,page))
    local first=(self.palette_page-1)*8
    for i=1,math.min(8,#names-first) do
        local name=names[first+i]
        self:button(X+442,by+25+(i-1)*39,344,35,
            (self.state.active_palette==name and '* ' or '  ')..name,
            function()
                model.select_palette(self.state,name)
                self.selected_palette=name
                self:sync(self.state,self.job)
                self:update()
            end,self.state.active_palette==name)
    end
    self:button(X+442,by+349,88,29,'< Page',function()
        self.palette_page=math.max(1,self.palette_page-1);self:render()
    end,false)
    self:text(X+552,by+356,('%d/%d'):format(self.palette_page,page),11,false)
    self:button(X+693,by+349,92,29,'Page >',function()
        self.palette_page=math.min(page,self.palette_page+1);self:render()
    end,false)
    self:button(X+28,by+169,354,37,self.pending_delete and 'Confirm delete active palette' or 'Delete active palette',function()
        local current=self.state.active_palette
        if current=='default' then self.handlers.notice('The default palette cannot be deleted.') return end
        if not self.pending_delete then self.pending_delete=true;self:render();return end
        model.delete_palette(self.state,current)
        self.pending_delete=false;self:sync(self.state,self.job);self:update()
    end,self.pending_delete)
    self:text(X+28,by+227,'Selecting a palette switches all hotbars.',11,false)
    self:text(X+28,by+250,'Copy current duplicates global and job actions.',11,false)
    self:text(X+28,by+280,'Deleting requires clicking twice.',11,false)
end
function GUI:render_keys()
    local by=Y+279
    local bar,slot=self.bar,self.slot
    self:text(X+28,by,('Binding for Bar %d / Slot %d'):format(bar,slot),15,true)
    self:field(X+28,by+64,380,'WINDOWER KEY COMBINATION (^ = Ctrl, ! = Alt, ~ = Shift)','bind',36)
    self:button(X+422,by+64,363,30,self.capture and 'Press a key now... ESC cancels' or 'Capture keyboard shortcut',function()
        self.capture=true;self.focus=nil;self:render()
    end,self.capture)
    self:button(X+28,by+128,180,38,'Save keybind',function()self:save_binding()end,true)
    self:button(X+220,by+128,180,38,'Remove keybind',function()
        self.draft.bind='';self:save_binding()
    end,false)
    self:text(X+28,by+203,'Example: ^1 = Ctrl+1, !F1 = Alt+F1, ~F2 = Shift+F2.',11,false)
    self:text(X+28,by+233,'A key can only belong to one slot; duplicates are reassigned.',11,false)
    self:text(X+28,by+263,'Hotbar keybinds are suspended while the editor is open.',11,false)
    self:text(X+28,by+293,'The editor does not override binds owned by other addons.',11,false)
    local layout=self.state.settings and self.state.settings.keyboard_layout or 'UK'
    self:button(X+28,by+331,362,31,'Typing layout: '..layout..' (click to switch)',function()
        self.state.settings=self.state.settings or {}
        self.state.settings.keyboard_layout=layout=='UK' and 'US' or 'UK'
        self:update()
    end,false)
end
function GUI:mouse(kind,x,y)
    if not self.visible then return false end
    local inside = point({x=X,y=Y,w=WIDTH,h=HEIGHT},x,y)
    if kind==1 then
        if inside then
            self.pressed=nil
            for i=#self.hits,1,-1 do
                if point(self.hits[i],x,y) then self.pressed=self.hits[i] break end
            end
            return true
        end
        return false
    elseif kind==2 then
        if inside or self.pressed then
            local pressed=self.pressed;self.pressed=nil
            if pressed and point(pressed,x,y) then pressed.callback() end
            return true
        end
    elseif inside and (kind==0 or kind==10 or kind==3 or kind==4 or kind==5 or kind==6 or kind==7 or kind==8 or kind==9) then return true end
    return false
end
function GUI:keyboard(dik,pressed,flags,blocked)
    if not self.visible then return false end
    local modifier=keycodes.modifier[dik]
    if modifier then self[modifier]=pressed end
    if not self.focus and not self.capture then
        if dik==0x01 and pressed then self.handlers.close();return true end
        return false
    end
    if blocked then return false end
    if not pressed then return true end
    if dik==0x01 then
        if self.capture then self.capture=false else self.focus=nil end
        self:render();return true
    end
    if self.capture then
        if modifier then return true end
        local shift=self.shift or (type(flags)=='number' and flags%2==1)
        local alt=self.alt or (type(flags)=='number' and math.floor(flags/2)%2==1)
        local ctrl=self.ctrl or (type(flags)=='number' and math.floor(flags/4)%2==1)
        local binding=keycodes.binding(dik,shift,ctrl,alt)
        if binding then
            self.draft.bind=binding; self.capture=false;self:render()
        end
        return true
    end
    if modifier then return true end
    if dik==0x1C then self.focus=nil;self:render();return true end
    local field=self.focus
    local limit=({command=512,label=32,icon=160,search=80,bar_name=24,palette_name=24,bind=36})[field] or 64
    local str=self.draft[field] or ''
    if dik==0x0E then str=str:sub(1,-2)
    elseif dik==0x53 then str=''
    else
        local shift=self.shift or (type(flags)=='number' and flags%2==1)
        local char=keycodes.character(dik,shift,self.state.settings and self.state.settings.keyboard_layout)
        if char and not self.ctrl and not self.alt and #str<limit then str=str..char end
    end
    self.draft[field]=clean_input(str,limit)
    if field=='search' then self.result_page=1 end
    self:render()
    return true
end
return GUI
