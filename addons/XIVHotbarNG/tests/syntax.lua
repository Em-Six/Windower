local files = {'xivhotbarng.lua', 'lib/model.lua', 'lib/storage.lua', 'lib/actions.lua', 'lib/view.lua', 'lib/gui.lua', 'lib/keycodes.lua'}
for _, f in ipairs(files) do
  local fn, err = loadfile(f)
  assert(fn, f .. ': ' .. tostring(err))
  print('SYNTAX OK ' .. f)
end
