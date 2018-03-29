pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- sport prototype --
-- will brewer --

-- game variables --
actors={}
player={}
scene=0

-- constructors --
------------------
function make_actor(x, y)
	-- player 1 object --
 actor={}
 actor.sprt=4 --sprite index
 
 --physical properties
 actor.x=x --x pos
 actor.y=y --y pos
 actor.dx=0 --x velocity
 actor.dy=0 --y velocity
 actor.fx=0
 actor.fy=0
 actor.grav=0.1 --gravity
 actor.inertia=0.8
 actor.accel=0.1
 actor.t=0
 
 actor.w=0.8 --width
 actor.h=0.8 --height
 
 add(actors, actor)
 return actor
end

-- base engine methods --
-------------------------
function _init()
	cls()
	
	player=make_actor(7.4,7.5)
	
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

-- state machine methods --
---------------------------
function title_update()
	if btnp(5) then
		scene=1
	end
end

function title_draw()
 cls()
	print("press x to restart",25,80)
end

function game_update()
	--parse input
	input()
	
	--calcualte physics
 physics()
 
 --calculate collision
 collision()
end

function game_draw()
 cls()
	map(0,0,0,0)
	
	--calculate animation
	animation()
	
	--draw actors
	for a in all(actors) do
		local sx=(a.x * 8) - 4
		local sy=(a.y * 8) - 4
		spr(a.sprt,sx,sy,2,2,false,false)
	end
end

-- helper methods --
--------------------
function input()
 
	if btn(0) then
		player.fx -= 0.2 
	end
	if btn(1) then
		player.fx += 0.25
	end
	if btn(2) then
		player.fy -= 0.25
	end
	if btn(3) then
		player.fy += 0.25
	end

 if btnp(4) then
 	player.dx = player.fx 
 	player.dy = player.fy 
 end
 
 if btnp(5) then
 	player.x = 7.4
 	player.y = 7.5
 end
end

function physics()
	for a in all(actors) do
 	--apply gravity
 	a.dy *= .96
 	a.fy *= a.inertia
 	 	
 	--apply inertia
 	a.dx *= .96
 	a.fx *= a.inertia
 end
end

function collision()
	for a in all(actors) do
 	--move player x direction
 	if not is_solid(a, a.dx, 0) then
   a.x += a.dx
  else
   a.dx *= -1
  end
 
 	--move player y direciton
 	if not is_solid(a, 0, a.dy) then
   a.y += a.dy
  else
   a.dy *= -1
  end
 end
end

function animation()
	tmr=abs(player.dx) + abs(player.dy)
	player.t += tmr
	
	if player.t >= 1 or player.sprt > 10 then
		player.sprt += 2
		player.t = 0
	end
	
	if player.sprt > 8 then
		player.sprt = 4
	end
	
	if player.dx <= 0.01 and player.dy <= 0.01 then
		player.sprt = 4
	end
end

-- collision functions --
-------------------------
function solid(x, y)
 -- grab the cell value
 val=mget(x, y)
 
 -- check if flag 1 is set (the
 -- orange toggle button in the 
 -- sprite editor)
 return fget(val, 1)
 
end

--checks actors and tile collision
function is_solid(a, dx, dy)
 if solid_area(a.x+dx,a.y+dy,
    a.w,a.h) then
    return true end
 return solid_actor(a, dx, dy) 
end

function solid_area(x,y,w,h)
 return 
  solid(x-w,y-h) or
  solid(x+w,y-h) or
  solid(x-w,y+h) or
  solid(x+w,y+h)
end

function solid_actor(a, dx, dy)
 for a2 in all(actors) do
  if a2 != a then
   local x=(a.x+dx) - a2.x
   local y=(a.y+dy) - a2.y
   if ((abs(x) < (a.w+a2.w)) and
      (abs(y) < (a.h+a2.h)))
   then 
    
    -- moving together?
    -- this allows actors to
    -- overlap initially 
    -- without sticking together    
    if (dx != 0 and abs(x) <
        abs(a.x-a2.x)) then
     v=a.dx + a2.dy
     a.dx = v/2
     a2.dx = v/2
     return true 
    end
    
    if (dy != 0 and abs(y) <
        abs(a.y-a2.y)) then
     v=a.dy + a2.dy
     a.dy=v/2
     a2.dy=v/2
     return true 
    end
    
    --return true
    
   end
  end
 end
 return false
end
__gfx__
00000000444444444444444444444444000007777770000000000777777000000000077777700000000000000000000000000000000000000000000000000000
00000000444444444444444444444444000777777777700000077776667770000007777777777000000000000000000000000000000000000000000000000000
00700700444444444444440000444444007777777777770000777777766677000077777777777700000000000000000000000000000000000000000000000000
00077000444444444444000000004444077777777777777007777777777667700777777777777770000000000000000000000000000000000000000000000000
00077000444444444440000000000444077777777777777007777777777766700777777777777770000000000000000000000000000000000000000000000000
00700700444444444440000000000444777777777777777777777777777776777777777777777777000000000000000000000000000000000000000000000000
00000000444444444400000000000044777777777777777777777777777776677777777777777777000000000000000000000000000000000000000000000000
00000000444444444400000000000044777777777777777777777777777777677677777777777777000000000000000000000000000000000000000000000000
00000000333333334400000000000044777777777777777777777777777777677677777777777777000000000000000000000000000000000000000000000000
00000000333333334400000000000044777777777777777777777777777777777667777777777777000000000000000000000000000000000000000000000000
00000000333333334440000000000444777777777777777777777777777777777767777777777777000000000000000000000000000000000000000000000000
00000000333333334440000000000444077777777777777007777777777777700766777777777770000000000000000000000000000000000000000000000000
00000000333333334444000000004444077777777777777007777777777777700776677777777770000000000000000000000000000000000000000000000000
00000000333333334444440000444444007777777777770000777777777777000077666777777700000000000000000000000000000000000000000000000000
00000000333333334444444444444444000777777777700000077777777770000007776667777000000000000000000000000000000000000000000000000000
00000000333333334444444444444444000007777770000000000777777000000000077777700000000000000000000000000000000000000000000000000000
__gff__
0002020200000000000000000000000000000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
02030101010101010101010101010203262728292a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12111111111111111111111111111113363738393a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111101262728292a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111101363738393a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111101262728292a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111101363738393a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111101262728292a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02111111111111111111111111111103363738393a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12111111111111111111111111111113262728292a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111101363738393a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111101262728292a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111101363738393a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111101262728292a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111101363738393a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02111111111111111111111111111103262728292a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12130101010101010101010101011213363738393a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21222324252627000000000000232425262728292a2b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3132333435363738393a3b3132333435363738393a3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000002425260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000