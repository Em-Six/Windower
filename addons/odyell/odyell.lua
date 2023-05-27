require('logger')

windower.register_event('chat message',
  function (message, player, mode, isGM)
    message = string.lower(message)
    if isGM then
      -- If GM message, then don't do anything
      return
    end

    --[[
        List of chat modes to accept
        (from /Windower/res/chat.lua file)
         0 = say
         1 = shout
         3 = tell
         4 = party
         5 = linkshell
         8 = emote
        26 = yell
        27 = linkshell2
        33 = unity
        ]]

    modes = {'say', 'shout', 'tell', 'party', 'linkshell', 'yell', 'linkshell2', 'unity'}

    catch = {'ody c.*dd','sheol c.*dd','odyssey c.*dd','c seg.*dd','ody c.*war','sheol c.*war','odyssey c.*war','c seg.*war'}
    catch2 = {'ody c.*cor','sheol c.*cor','odyssey c.*cor','c seg.*cor'}
    catch3 = {'1443'}

    for k,v in pairs(catch) do         -- k = index, v = value.
      if string.match(string.lower(message),v) then  -- if value in message
        if mode == 26 then
          windower.send_command('input /tell '..player..' SB/Club/PA WAR or COR' )
        end
      end
    end    
	for k,v in pairs(catch2) do         -- k = index, v = value.
      if string.match(string.lower(message),v) then  -- if value in message
        if mode == 26 then
          windower.send_command('input /tell '..player..' COR or SB/Club/PA WAR' )
        end
      end
    end
    --for k,v in pairs(catch3) do         -- k = index, v = value.
    --  if string.match(string.lower(message),v) then  -- if value in message
    --   if mode == 26 then
    --      windower.send_command('input /tell '..player..' Bumba RP please inv' )
    --    end
    --  end
    --end
end)




-- print(player..": "..message)   -- print player name and message to console
-- windower.send_command('input /echo '..player..": "..message)   -- print player name and message to in game echo