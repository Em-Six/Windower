-- Code purpose:
-- Parse different chat modes for player name and messages.
-- If message matches spell listed in table (exactly matches)
--   then cast corresponding spell on the player that sent the message.
-- If the spell is self-target only, cast spell on self.
-- This accepts inputs from blacklisted players, even if their chat doesn't
--   show up on the chat log in game.
-- Accepts two-word messages for Corsair rolls 'rolls samurai', 'rolls drk'

_addon.author = 'Kastra.Asura'
_addon.name = 'altcast'
_addon.version = '1.2.0'      -- 1.0.0 First working version
                              -- 1.0.2 Added additional spells/aliases
                              -- 1.1.0 Added abilities
                              -- 1.1.4 Accepts rolls as two-word commands
                              --   'roll stp', 'roll attack', 'rolls matk'
                              -- 1.2.0 Moved spell list to different file to
                              --   reduce clutter

require('altcast_spell_list') -- Read spell tables from altcast_spell_list.lua

windower.register_event('chat message',

  function (message, player, mode, isGM)

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

    if mode==0 or mode==4 then  -- Only accept inputs from /say and /party

      -- split message into two strings for two-word aliases like 'rolls sam'
      dictionary,alias = string.match(message, "(.*) (.*)")

      if dictionary == 'rolls' or dictionary == 'roll' then
        if mode==4 then
          dictionary = rolls -- use the aliases in the 'rolls' table
          if dictionary[alias] then -- if requested alias exists in the table
            spell = dictionary[alias]
            windower.send_command('input /ja "'..spell..'" <me>')
          end
        end

      -- if message is a single word alias like 'para' or 'pro5'
      elseif others_spells[message] then
        -- if alias is in table holding spells cast on other players
        spell = others_spells[message]
        windower.send_command('input /ma "'..spell..'" '..player)
      elseif self_spells[message] then
        -- if alias is in table holding spells cast on self (protectra, etc)
        spell = self_spells[message]
        windower.send_command('input /ma "'..spell..'" <me>')
      elseif others_abilities[message] then
        -- if alias is in table holding abilities cast on others (devotion)
        spell = others_abilities[message]
        windower.send_command('input /ja "'..spell..'" '..player)
      elseif self_abilities[message] then
        -- if alias is in table holding abilities cast on self (benediction)
        spell = self_abilities[message]
        windower.send_command('input /ja "'..spell..'" <me>')
      end
    end
  end
)
