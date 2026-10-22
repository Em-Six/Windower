-- Windower-specific primitives renderer. Deliberately separate from the pure model.
local View = {}
View.__index = View
local SLOT_COUNT = 12
local BAR_COUNT = 10
local HEADER_HEIGHT = 20

local function make_image(images, path)
    local item = images.new()
    item:draggable(false)
    item:fit(false)
    item:path(path)
    item:alpha(255)
    item:hide()
    return item
end

local function make_text(texts, font_size, rgb)
    local item = texts.new()
    item:bg_visible(false)
    item:font('Arial')
    item:size(font_size)
    item:color(rgb[1], rgb[2], rgb[3])
    item:stroke_width(1)
    item:stroke_color(7, 10, 20)
    item:text('')
    item:hide()
    return item
end

function View.new(addon_path, images, texts, actions)
    local self = setmetatable({bars = {}, model = nil, job = 'UNK',
        root = addon_path:gsub('[\\/]+$', '') .. '/assets/', actions = actions}, View)
    for i = 1, BAR_COUNT do
        local ui = {
            header = make_image(images, self.root .. 'header.png'),
            title = make_text(texts, 11, {231, 236, 251}),
            backgrounds = {},
            icons = {},
            labels = {},
            keys = {},
        }
        for j = 1, SLOT_COUNT do
            ui.backgrounds[j] = make_image(images, self.root .. 'slot.png')
            ui.icons[j] = make_image(images, self.root .. 'command.png')
            ui.labels[j] = make_text(texts, 9, {255, 255, 255})
            ui.keys[j] = make_text(texts, 8, {146, 210, 255})
        end
        self.bars[i] = ui
    end
    return self
end

function View:set_data(state, job)
    self.model = state
    self.job = job or 'UNK'
    self:redraw()
end

function View:hide()
    for _, ui in ipairs(self.bars) do
        ui.header:hide()
        ui.title:hide()
        for j = 1, SLOT_COUNT do
            ui.backgrounds[j]:hide()
            ui.icons[j]:hide()
            ui.labels[j]:hide()
            ui.keys[j]:hide()
        end
    end
end

function View:slot_xy(bar, slot)
    local step = bar.size + bar.gap
    local x = bar.x + (bar.vertical and 0 or ((slot - 1) * step))
    local y = bar.y + HEADER_HEIGHT + (bar.vertical and ((slot - 1) * step) or 0)
    return x, y
end

function View:bar_width(bar)
    if bar.vertical then return math.max(112, bar.size) end
    return bar.size * SLOT_COUNT + bar.gap * (SLOT_COUNT - 1)
end

function View:redraw()
    if not self.model then self:hide() return end
    local state = self.model
    local palette = state.active_palette
    local model = require('lib/model')
    for i = 1, BAR_COUNT do
        local cfg = state.bars[i]
        local ui = self.bars[i]
        if not cfg.visible then
            ui.header:hide()
            ui.title:hide()
            for j = 1, SLOT_COUNT do
                ui.backgrounds[j]:hide()
                ui.icons[j]:hide()
                ui.labels[j]:hide()
                ui.keys[j]:hide()
            end
        else
            ui.header:pos(cfg.x, cfg.y)
            ui.header:size(self:bar_width(cfg), HEADER_HEIGHT)
            ui.header:alpha(cfg.alpha)
            ui.header:show()
            ui.title:text(cfg.name .. '  [' .. (cfg.scope == 'global' and 'ALL' or self.job)
                .. ']  ' .. palette)
            ui.title:pos(cfg.x + 5, cfg.y + 2)
            ui.title:show()
            for j = 1, SLOT_COUNT do
                local x, y = self:slot_xy(cfg, j)
                local record = model.get_slot(state, i, j, self.job)
                local bg = ui.backgrounds[j]
                bg:pos(x, y)
                bg:size(cfg.size, cfg.size)
                bg:alpha(cfg.alpha)
                bg:show()
                local icon = ui.icons[j]
                local label = ui.labels[j]
                local key = ui.keys[j]
                if record then
                    local icon_name = self.actions.kind(record.command)
                    local icon_path = self.root .. icon_name .. '.png'
                    if record.icon ~= '' and record.icon:match('^[%w_%-]+%.png$') then
                        icon_path = self.root .. 'custom/' .. record.icon
                    end
                    icon:path(icon_path)
                    icon:pos(x + 3, y + 3)
                    icon:size(cfg.size - 6, cfg.size - 6)
                    icon:alpha(cfg.alpha)
                    icon:show()
                    label:text((record.label ~= '' and record.label
                        or self.actions.label(record.command)):sub(1, 11))
                    label:pos(x + 2, y + cfg.size - 15)
                    label:show()
                else
                    icon:hide()
                    label:hide()
                end
                local binding = state.binds[i] and state.binds[i][j]
                if binding then
                    key:text(binding:gsub('%%', ''):sub(1, 10))
                    key:pos(x + 2, y + 1)
                    key:show()
                else
                    key:hide()
                end
            end
        end
    end
end

-- Used by mouse handler to identify a click; no Windower dependency.
function View:hit_test(x, y)
    if not self.model then return nil end
    for i = BAR_COUNT, 1, -1 do
        local cfg = self.model.bars[i]
        if cfg.visible then
            for j = SLOT_COUNT, 1, -1 do
                local sx, sy = self:slot_xy(cfg, j)
                if x >= sx and x < sx + cfg.size and y >= sy and y < sy + cfg.size then
                    return {kind = 'slot', bar = i, slot = j}
                end
            end
            local width = self:bar_width(cfg)
            if x >= cfg.x and x < cfg.x + width
                and y >= cfg.y and y < cfg.y + HEADER_HEIGHT then
                return {kind = 'header', bar = i}
            end
        end
    end
    return nil
end

return View
