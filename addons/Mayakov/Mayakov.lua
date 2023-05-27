windower.register_event('outgoing text',function(original,modified)
  function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

tablestring = string.split(original, " ")
mode = tablestring[1]
if mode == "/tell" or mode == "/t" then
  msg = table.concat(tablestring," ",3)
  mode = tablestring[1].." "..tablestring[2]
else
  msg = table.concat(tablestring," ",2)
end


modified0 = string.gsub(msg, "sce", "the")
modified1 = string.gsub(modified0, "ss", "th")

modified2 = string.gsub(modified1, "s", "th")
modified3 = string.gsub(modified2, "ci", "thi")
modified4 = string.gsub(modified3, "ce", "the")
modified5 = string.gsub(modified4, "cy", "thy")
modified6 = string.gsub(modified5, "cc", "th")


final = mode.." "..modified6
return final
end)