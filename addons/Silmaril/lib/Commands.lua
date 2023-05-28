function commands(cmd, args)
    if cmd ~= nil and player.name then
        if cmd == "settings" then
            if args[1] and args[2] then
                ip = args[1]
                port = args[2]
                windower.add_to_chat(1, ('\31\200[\31\05Silmaril Addon\31\200]\31\207 '.. "Connection:  IP address: " .. ip .. " / Port number: " .. port))
            end
        elseif cmd == "check" then
            windower.add_to_chat(1, ('\31\200[\31\05Silmaril Addon\31\200]\31\207 '.. "Connection:  IP address: " .. ip .. " / Port number: " .. port))
        elseif cmd == "verify" then
            windower.add_to_chat(8,'Silmaril Addon Loaded')
            send_packet(player.name..";confirmed")
        elseif cmd == "stop" or cmd == "off" or (cmd == "toggle" and enabled) then
            windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Actions: \31\03[OFF]')) -- use \03
            send_packet(player.name..";stop")
            enabled = false
            windower.ffxi.run(false)
            if args[1] and args[1]:lower() == 'all' then
                windower.send_ipc_message('stop')
            end
        elseif cmd == "start" or cmd == "on" or (cmd == "toggle" and not enabled) then
             windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Actions: \31\06[ON]')) -- use \06
             get_player_spells()
             send_packet(player.name..";start")
             enabled = true
             if args[1] and args[1]:lower() == 'all' then
                windower.send_ipc_message('start')
             end
        elseif cmd == "all" then
             if args[1] and (args[1]:lower() == 'on' or args[1]:lower() == 'start') then
                 get_player_spells()
                 send_packet(player.name..";start")
                 enabled = true
                 windower.send_ipc_message('start')
             elseif args[1] and (args[1]:lower() == 'off' or args[1]:lower() == 'stop') then
                send_packet(player.name..";stop")
                enabled = false
                windower.ffxi.run(false)
                windower.send_ipc_message('stop')
             elseif args[1] and args[1]:lower() == 'follow' then
                if following then
                    windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Following: \31\03[OFF]'))
                    send_packet(player.name..";follow_off_all")
                    windower.ffxi.run(false)
                    following = false
                else
                    following = true
                    windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Following: \31\06[ON]'))
                    send_packet(player.name..";follow_on_all")
                    windower.send_ipc_message('follow on')
                end
             end
        elseif cmd == "follow" then
            if args[1] and args[1]:lower() == 'on' then -- single box follow on
                windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Following: \31\06[ON]'))
                send_packet(player.name..";follow_on")
            elseif args[1] and args[1]:lower() == 'off' then -- single box follow off
                following = false
                send_packet(player.name..";follow_off")
                windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Following: \31\03[OFF]'))
            elseif args[1] and args[1]:lower() == 'all' then -- multi-box following command
                if following then
                    windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Following: \31\03[OFF]'))
                    send_packet(player.name..";follow_off_all")
                    windower.send_ipc_message('follow off')
                    windower.ffxi.run(false)
                    following = false
                else
                    windower.add_to_chat(1, ('\31\200[\31\05Silmaril\31\200]\31\207'..' Following: \31\06[ON]'))
                    send_packet(player.name..";follow_on_all")
                    windower.send_ipc_message('follow on')
                end
            end
        elseif cmd == "load" then
            if args[3] then
                send_packet(player.name..";load_"..args[1]:lower().."_"..args[2]:lower().." "..args[3]:lower())
                log(player.name..";load_"..args[1]:lower().."_"..args[2]:lower().." "..args[3]:lower())
            elseif args[2] then
                send_packet(player.name..";load_"..args[1]:lower().."_"..args[2]:lower())
                log(player.name..";load_"..args[1]:lower().."_"..args[2]:lower())
            elseif args[1] then
                send_packet(player.name..";load_"..args[1]:lower())
                log(player.name..";load_"..args[1]:lower())
            else
                send_packet(player.name..";load_")
                log(player.name..";load_")
            end
        elseif cmd == "file" then
            if args[3] then
                send_packet(player.name..";load_"..args[1].."_"..args[2].." "..args[3].."_"..player.main_job.."_"..player.sub_job.."_"..player.name)
                log(player.name..";load_"..args[1].."_"..args[2].." "..args[3].."_"..player.main_job.."_"..player.sub_job.."_"..player.name)
            elseif args[2] then
                send_packet(player.name..";load_"..args[1].."_"..args[2].."_"..player.main_job.."_"..player.sub_job.."_"..player.name)
                log(player.name..";load_"..args[1].."_"..args[2].."_"..player.main_job.."_"..player.sub_job.."_"..player.name)
            elseif args[1] then
                send_packet(player.name..";load_"..args[1].."_"..player.main_job.."_"..player.sub_job.."_"..player.name)
                log(player.name..";load_"..args[1].."_"..player.main_job.."_"..player.sub_job.."_"..player.name)
            else
                send_packet(player.name..";load_"..player.main_job.."_"..player.sub_job.."_"..player.name)
                log(player.name..";load_"..player.main_job.."_"..player.sub_job.."_"..player.name)
            end
        elseif cmd == "send" then
            send_packet(player.name..';echo_Test')
            log(player.name..';echo_Test')
        elseif cmd == 'debug' then
        	if settings.debug == true then
                settings.debug = false
                sm_debug:hide()
			    windower.add_to_chat(80,'------- Debugging [OFF] -------')
		    else
			    settings.debug = true
                sm_debug:show()
			    windower.add_to_chat(80,'------- Debugging [ON]  -------')
		    end
        elseif cmd == 'locale' then
			windower.add_to_chat(80,'------- Locale is '..tostring(os.setlocale ("en"))..' -------')
        elseif cmd == 'info' then
        	if settings.info == true then
                settings.info = false
			    windower.add_to_chat(80,'------- Info [OFF] -------')
		    else
			    settings.info = true
			    windower.add_to_chat(80,'------- Info [ON]  -------')
		    end
        elseif cmd == 'display' then
        	if settings.display == true then
                settings.display = false
                sm_display:hide()
			    windower.add_to_chat(80,'------- Display [OFF] -------')
		    else
			    settings.display = true
                sm_display:show()
			    windower.add_to_chat(80,'------- Display [ON]  -------')
		    end
        elseif cmd == 'save' then
            coroutine.sleep(delay_time)
		    config.save(settings, player.name:lower())
		    windower.add_to_chat(8,'Silmaril Settings Saved')
        elseif cmd == 'player' then
            log(player)
        end
    end
end