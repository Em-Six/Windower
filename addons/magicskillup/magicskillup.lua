local self = windower.ffxi.get_player()
local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t') or self



spells = {"Shock", "Rasp", "Choke", "Frost", "Burn", "Drown",}
      math.randomseed(os.time()) -- Needed for changing random numbers
      math.random() -- https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
      math.random()
      math.random()
      t = 1 + math.random() + math.random() + math.random()

counter = 1
while(target.name=="Bight Uragnite")
do
   counter = counter + 1
   if counter > 6 then
     counter = 1
   end
   windower.send_command("@input /ma \""..spells[counter].."\" <t>")
   t = 5 + math.random()
	coroutine.sleep(t)
end