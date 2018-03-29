pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- sport prototype --
-- will brewer --

-- game variables --
actors={}
player={}
scene=0
jump_power=0.8
camx=0
camy=0

g_on=false
near_secret=false
can_tport=false
charge_tport=false

-- teleport points --
tport={}

-- base engine methods --
-------------------------
function _init()
	cls()
	
	player=make_actor(7.5,25,1)
	
	scene=1
end

function _update()
	if scene==0 then
		title_update()
	elseif scene==1 then
		game_update()
	end
end

function _draw()
	if scene==0 then
		title_draw()
	elseif scene==1 then
		game_draw()
	end
end

-- scene methods --
---------------------------
function title_update()

end

function title_draw()
 
end

function game_update()
	collisions()
	foreach(actors,move_actor)
end

function game_draw()
	-- reset screen
 cls()
	map(0,0,0,0)
	
	-- camera
	cam_x = mid(0,player.x*8-64,1024-128)
 cam_y = mid(0,player.y*6-40,128)
	camera (cam_x,cam_y)
	
	-- map	
	mapdraw (0,0,0,0,128,64,1)
	
	-- actors
	foreach(actors,draw_actor)

	print(player.frame,cam_x,cam_y)
 -- screen effects
 glitch()
end
-->8
-------------
-- classes --
-------------

-----------------
-- actor class --
-----------------
function make_actor(x,y,d)
	local a = {}
	a.kind = 1
	a.life = 1
	a.x=x a.y=y a.dx=0 a.dy=0
	a.ddy = 0.06 -- gravity
 a.w=0.3 a.h=0.5 -- half-width
 a.d=d a.bounce=0.8
 a.frame = 1  a.f0 = 0
 a.t=0
 a.standing = false
 a.t_charge=0
  
 add(actors, a)
 
	return a
end

function move_actor(pl)
	if(pl.kind == 1) then
		move_player(pl)
	end
	
	pl.standing=false
 
 -- x movement 
 x1 = pl.x + pl.dx +
      sgn(pl.dx) * 0.3

 if(not solid(x1,pl.y-0.5)) then
		pl.x = pl.x + pl.dx  
	else -- hit wall
	 -- search for contact point
	 while (not solid(pl.x + sgn(pl.dx)*0.3, pl.y-0.5)) do
	  pl.x = pl.x + sgn(pl.dx) * 0.1
	 end
  -- bounce	
  pl.dx = pl.dx * -0.5
	end
	
 if (pl.dy < 0) then
  -- going up
  if (solid(pl.x-0.2, pl.y+pl.dy-1) or
   solid(pl.x+0.2, pl.y+pl.dy-1))
  then
   pl.dy=0
 
   -- search up for collision point
   while ( not (
   solid(pl.x-0.2, pl.y-1) or
   solid(pl.x+0.2, pl.y-1)))
   do
    pl.y = pl.y - 0.01
   end
   
  else
   pl.y = pl.y + pl.dy
  end

	else
  -- going down
  if (solid(pl.x-0.2, pl.y+pl.dy) or
   solid(pl.x+0.2, pl.y+pl.dy)) then

   pl.standing=true
   pl.dy = 0
    
   --snap down
   while (not (
     solid(pl.x-0.2,pl.y) or
     solid(pl.x+0.2,pl.y)
     ))
    do pl.y = pl.y + 0.05 end
  
   --pop up even if bouncing
   while(solid(pl.x-0.2,pl.y-0.1)) do
    pl.y = pl.y - 0.05 end
   while(solid(pl.x+0.2,pl.y-0.1)) do
    pl.y = pl.y - 0.05 end
    
  else
   pl.y = pl.y + pl.dy  
  end
 end

 -- gravity and friction
	pl.dy = pl.dy + pl.ddy
 pl.dy = pl.dy * 0.95

 -- x friction
 if (pl.standing) then
 	pl.dx = pl.dx * 0.8
	else
 	pl.dx = pl.dx * 0.9
	end

 -- counters
 pl.t = pl.t + 1
end

function draw_actor(pl)
	spr(pl.frame, 
  pl.x*8-4, pl.y*8-8, 
  1, 1, pl.d < 0)
end

------------------
-- player class --
------------------
function move_player(pl)
	accel = 0.05
	
	if (not pl.standing) then
		accel = accel / 2
	end
	
	--player control
	if(btn(0,0)) then
		pl.dx = pl.dx - accel; pl.d=-1 end
	if(btn(1,0)) then
		pl.dx = pl.dx + accel; pl.d=1 end
	if((btn(4,0)) and pl.standing) then
		pl.dy = -0.7 end
	if(btn(5,0) and can_tport and pl.standing) then
		charge_tport=true
		if(pl.t_charge > 30) then
			teleport()
			pl.t_charge=0
		else
			pl.t_charge+=1
		end
	else
		charge_tport=false
		pl.t_charge=0
	end
	
	--animation
	if (pl.standing) then --on ground
	 pl.f0 = (pl.f0+abs(pl.dx)*2+4) % 4
 else --in air
	 pl.f0 = (pl.f0+abs(pl.dx)/2+4) % 4 
 end
 
 --running animation
 if (abs(pl.dx) < 0.1) then	
  pl.frame=1 pl.f0=0
 else
	 pl.frame = 2+flr(pl.f0)
	end
end

-- actions --
function teleport()
	if(can_tport==true) then
		if(player.y<20) then
			player.x=22
			player.y=23
		else
			player.x=18
			player.y=13
		end
	end
end

-- monster class --
-------------------
function move_monster(m)
 m.dx = m.dx + m.d * 0.02

	m.f0 = (m.f0+abs(m.dx)*3+4) % 4
 m.frame = 112 + flr(m.f0)

 if (false and m.standing and rnd(100) < 1)
 then
  m.dy = -1
 end
end
-->8
---------------
-- collision --
---------------
function solid (x, y)
	--check screen boundries
	if (x < 0 or x >= 128 ) then
		return true end
	
	--check for ground flag			
	val = mget(x, y)
	return fget(val, 1)
end

function collide(a1, a2)
 if (a1==a2) then return end
 local dx = a1.x - a2.x
 local dy = a1.y - a2.y
 if (abs(dx) < a1.w+a2.w) then
  if (abs(dy) < a1.h+a2.h) then
   collide_event(a1, a2)
  end
 end
end

function collisions()
	--actor on actor
 for a1 in all(actor) do
  collide(player,a1)
 end
 
 --secret spot collision
 tile=mget(player.x,player.y-1)
 if(fget(tile,5)) then --warm
 	g_on=true
 	glit.vert_space=5
 	glit.intensity=5
 elseif(fget(tile,6)) then --warmer
 	g_on=true
 	glit.vert_space=2
 	glit.horiz_space=1
 	glit.intensity=10
 elseif(fget(tile,7)) then --can tport
 	g_on=true
 	can_tport=true
 	glit.vert_space=1
 	glit.horiz_space=1
 	glit.intensity=15
 else
 	g_on=false
 	can_tport=false
 end
end

function collide_event(a1, a2)
 if(a1.kind==1) then --player
  if(a2.kind==2) then
  end
 
  if(a2.kind==3) then -- monster 
  end   
 end
end
-->8
--------------------
-- screen effects --
--------------------
glit={}
glit.t=0
glit.height=128 -- set the width of area the screen glitch will appear
glit.width=128 -- set the width
glit.vert_space=4 --spacing between lines
glit.horiz_space=2
glit.intensity=5
	
function glitch()
	if g_on == true then -- on boolean is mangaged by the timer
  local t={7,2,5} -- create array of three colors
  local c=rnd(3) -- generate a random number between 1 and 3, we'll use this in a bit
  c=flr(c) -- make sure our random number is an integer and not a float
  for i=0, glit.intensity, glit.vert_space do -- the outer loop generates the vertical glitch dots
   local gl_height = rnd(glit.height)
   for h=0, 100, glit.horiz_space do -- the inner loop creates longer horizontal lines
   	pset(cam_x+rnd(glit.width),cam_y+gl_height, t[c]) -- write the random pixels to the screen and randomize the colors from the previously generated random number against out color array
   end
  end
 end
 
 -- animation timeline that turns the static on and off
 if glit.t>30 and glit.t < 50 then
  g_on=true
 elseif glit.t>70 and glit.t < 80 then
  g_on=true
 elseif glit.t>120 then
  glit.t = 0
 else 
  g_on=false
 end
 glit.t+=1
end

function player_glitch()
 -- animation timeline that turns the static on and off
 if glit.t>30 and glit.t < 50 then
  g_on=true
 elseif glit.t>70 and glit.t < 80 then
  g_on=true
 elseif glit.t>120 then
  glit.t = 0
 else 
  g_on=false
 end
 glit.t+=1
end
__gfx__
00000000000000000000000004444440044444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000044444400444444004fffff004fffff00444444000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070004fffff004fffff00f1fff100f1fff1004fffff000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000f1fff100f1fff100ffffff00ffffff00f1fff1000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000ffffff00ffffff000333000003330000ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700003330000033300000bbbf000fbbb0000033300000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000bbb00000bbbf000f00000000000f000fbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000f0f00000f0000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33b333b33b3333b3333b333b66666666eeeeeeee5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333366666666eeeeeeee5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555335555555555553366666666eeeeeeee5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444334444444444443366666666eeeeeeee5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444466666666eeeeeeee5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444466666666eeeeeeee5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444466666666eeeeeeee5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444466666666eeeeeeee5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00577500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020220408000000000000000000000020202000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e0e1d1b1b1b1b1b1b1b1b1b1b1b1b2b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b00001c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e1d1b1b1b1b1b1b1b1b1b1b1b1b2b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b00001c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e1d1b1b1b1b1b1b1b1b1b1b1b1b2b1b1b1b1b1b1b1b1b1b1b1b1b1b1b00001b1b1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cecfcccdcecfcccdcecfcccdcecfcccdcecfcccdcecfcccdcecf000000000000000000001b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dedfdcdddedfdcdddedfdcdddedfdcdddedfdcdddedfdcdddedf000000000000001b1b1b1b1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeefecedeeefecedeeefecedeeefecedeeefecedeeefecedeeef1b1b1b1b1b1b1b1b1b1b0000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000fefffcfdfefffcfdfefffcfdfefffcfdfefffc505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cfcc0000000000000000000000cccdcecfcccdcecfcc505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505050505050505050505050505050505050505050505050dedf1b1b1b1b1b1b1b1b1b1b1b1b1b1b50505050001b1b1b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505050505050505050505050505050505050505050505050eeef1b1b1b1b1b1b1b1b1b1b1b1b1b1b505050501b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50fffcfdfefffcfdfefffcfdfe4343434343434343435050feff1b1b1b1b1b1b1b1b1b1b1b1b1b1b505050501b1b1b1b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50cfcccdcecfcccdcecfcccdce4343444444444443435050cecf1b1b1b1b1b1b1b1b1b1b1b1b1b1b505050501b1b1b1b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50dfdcdddedfdcdddedfdcddde4343444444444443435050dedf1b1b1b1b1b1b1b1b0c0d1b1b1b1b505050501b1b1b1b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50404040404040404042ecedee4343444545444443435050eeef1b1b1b1b0c0b0b0b0e1d1b1b1b1b505050501b1b1b1b1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505050505050505050504040404040404040404040405050feff000b0b0b0e0e0e0e0e1d1b1b1b1b50505050cecfcccdcecfcccdcecf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050505050505050505050505050505050505050505000000000000000430e0e0e0e0b0b0b0b5050505050dfdcdddedfdcdddedf5050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050500000000000000000000000000000000000000e0e0e0e000000000043430e0e0e0e0e0e0e0e5050505050efecedeeefecedeeef5050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505050000000000000000000000000001b1b1b1b1b0e0e0e0e1b1b1b1b4343430e0e00000000000e5050505050fffcfdfefffcfdfeff5050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505000000000000000000000000000001b1b1b1b1b1b001b0000004343434341404040404040405050505050cfcccdcecfcccdcecf5050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050501b1b1b1b1b1b1b1b1b1b1b1b1b0000004344444444444444434343434150505050505050505050505050dfdcdddedfdcdddedf5050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050501b1b1b1b1b1b1b1b1b1b1b1b1b0000434344444444444444434343415050505050505050505050505050efecedeeefecedeeef5050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505050000000000000000000000000434343434344444444444444434341505050505050505050505050505050fffcfdfefffcfdfeff5050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505050000000000000000000000000434343434344444545444444434150505050505050505050505050505050cfcccdcecfcccdcecf5050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505050000000000000000000000000434343434140404040404040405050505050505050505050505050505050dfdcdddedfdcdddedf0000000000000000000000000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050500000000000000000000000004343434150505050505050505050505050505050505050505050505050eeefecedeeefecedeeef0000000000000000000000000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050504040404040404040404040404040405050505050505050505050505050505050505050505050505050fefffcfdfefffcfdfeff0000000000000000000000000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050cfcccdcecfcccdcecf5050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505050505050505050505050505050505050505050505050505050505050505050505050505050505050dcdddedfdcdddedfdcdddedf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000ecedeeefecedeeefecedeeefecedeeefecedeeefecedeeef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000fcfdfefffcfdfefffcfdfefffcfdfefffcfdfefffcfdfeff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100093e4503e4503e4503e4503e4503e4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503f4503e4503e4503e4503e4503e450
010f0000245440050400504285542b55400504285540050429554245542d55424504305543c52400504005042b5541f504265342b52426544005042454400504235440c50421544235441f544005041c5441c524
000f0000240450000000000280552b05500000280550000029052240562d05524005307553c52500000000002b0551f006260352b02626042000002404500000230450c20521045230461f045000001c0421c025
010f0000235440050400504265542d5540050427554005042b554235542a55424504305543c62400504005042b5541f504255342b52426544005042454400504235440c50421544285441f544005041c54403524
001000010161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610016100161001610
__music__
00 01424344
