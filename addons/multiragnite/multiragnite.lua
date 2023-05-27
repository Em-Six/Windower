local self = windower.ffxi.get_player()
local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t') or self



songs = {"Barfire", "Cure", "Barthunder", "Cure"}
      math.randomseed(os.time()) -- Needed for changing random numbers
      math.random() -- https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
      math.random()
      math.random()
      t = 1 + math.random() + math.random() + math.random()

counter = 1
while(target.name=="Bight Uragnite")
do
   counter = counter + 1
   if counter > 4 then
     counter = 1
   end
   windower.send_command("@input /ma '"..songs[counter].."'" <me>)
    t = 5 + math.random() + math.random() + math.random() + math.random()
    coroutine.sleep(t)
end