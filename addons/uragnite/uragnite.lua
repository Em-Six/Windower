local self = windower.ffxi.get_player()
target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t') or self

math.randomseed(os.time()) -- Needed for changing random numbers
math.random() -- https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
math.random()
math.random()

food_timer = -999.0
while(target.name=="Bight Uragnite")
do
  if os.clock() - food_timer > 1830 then
    t2 = 5 + math.random() + math.random() + math.random()
    windower.send_command("@input /item Maringna <me>")
    food_timer = os.clock()
    coroutine.sleep(t2)
  end
  t1 = 30 + math.random() + math.random() + math.random() + math.random() + math.random() + math.random() + math.random() + math.random() + math.random() + math.random() + math.random() + math.random()

  if self.vitals.hpp <= 80 then
    windower.send_command("@input /ma Provoke <t>")
  else
    windower.send_command("@input /ja Provoke <t>")
  end
  target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('t') or self
  coroutine.sleep(t1)
end