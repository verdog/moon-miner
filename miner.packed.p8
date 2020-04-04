pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- main loops and debug
function _init()
 debug_init()

	player = _player:new()
end

function start_level()
	vfx_init()
	enemies_init()
	proj_init()
 
 _global.map_target_feats = 12
	_global.map_spread = 36
 map_init() -- generates enemies and crystal too
	
	player.x = 0
	player.y = 0
 
 _global.killed = 0
	
	ui_init()
	
	message("find the crystal!")
end

function _update()
	debug(_global.goal)
	debug(_global.killed)
	if _global.state == "play" or _global.state == "dead" then
		map_update()
		proj_update()
		if _global.state != "dead" then
			player:update()
  end
		enemies_update()
  _global.crystal:update()
		vfx_update()
	end
	
	if _global.state == "play" or _global.state == "dead" then
		camera(player.x-64+shake.x,player.y-64+shake.y)
		_global.cam.x = peek2(0x5f28)
		_global.cam.y = peek2(0x5f2a)
	end
		
	if _global.state == "title" then
		title_update()
	end
	
	if _global.state == "play" or _global.state == "dead" then
		ui_update(player)
	end
end

function _draw()
	cls()
	if _global.state == "play" or _global.state == "dead" then
		map_draw(player.x,player.y)
		proj_draw()
		vfx_draw(-1)
		if _global.state != "dead" then
			player:draw()
		end
  enemies_draw()
  _global.crystal:draw()
		vfx_draw(1)
		ui_draw(player)
	end
	
	if _global.state == "title" then
		title_draw()
	end
	
	debug_draw()
	debug_clear()
end

-- debug system
function debug_init()
	debug_table = {}
	_debug = true
	menuitem(1,"toggle debug", function() _debug=not _debug end)
end

function debug(str, key)
	key = key or ""
	if key == "" then
		add(debug_table, str)
	else
		add(debug_table, key..": "..str)
	end
end

function debug_draw()
	local cam = _global.cam
	if _debug == true then
		for i=1,#debug_table do
			print(debug_table[i],cam.x,cam.y+6*i-6,7)
		end
	end
end

function debug_clear()
	debug_table = {}
	debug(stat(1), "∧")
	debug(stat(0), "░")
end-- main loops and debug
function _init()
 debug_init()

	player = _player:new()
end

function start_level()
	vfx_init()
	enemies_init()
	proj_init()
 
 _global.map_target_feats = 12
	_global.map_spread = 36
 map_init() -- generates enemies and crystal too
	
	player.x = 0
	player.y = 0
 
 _global.killed = 0
	
	ui_init()
	
	message("find the crystal!")
end

function _update()
	debug(_global.goal)
	debug(_global.killed)
	if _global.state == "play" or _global.state == "dead" then
		map_update()
		proj_update()
		if _global.state != "dead" then
			player:update()
  end
		enemies_update()
  _global.crystal:update()
		vfx_update()
	end
	
	if _global.state == "play" or _global.state == "dead" then
		camera(player.x-64+shake.x,player.y-64+shake.y)
		_global.cam.x = peek2(0x5f28)
		_global.cam.y = peek2(0x5f2a)
	end
		
	if _global.state == "title" then
		title_update()
	end
	
	if _global.state == "play" or _global.state == "dead" then
		ui_update(player)
	end
end

function _draw()
	cls()
	if _global.state == "play" or _global.state == "dead" then
		map_draw(player.x,player.y)
		proj_draw()
		vfx_draw(-1)
		if _global.state != "dead" then
			player:draw()
		end
  enemies_draw()
  _global.crystal:draw()
		vfx_draw(1)
		ui_draw(player)
	end
	
	if _global.state == "title" then
		title_draw()
	end
	
	debug_draw()
	debug_clear()
end

-- debug system
function debug_init()
	debug_table = {}
	_debug = true
	menuitem(1,"toggle debug", function() _debug=not _debug end)
end

function debug(str, key)
	key = key or ""
	if key == "" then
		add(debug_table, str)
	else
		add(debug_table, key..": "..str)
	end
end

function debug_draw()
	local cam = _global.cam
	if _debug == true then
		for i=1,#debug_table do
			print(debug_table[i],cam.x,cam.y+6*i-6,7)
		end
	end
end

function debug_clear()
	debug_table = {}
	debug(stat(1), "∧")
	debug(stat(0), "░")
end
_global = {
	gravity = 0.2,
	cam = {x=0,y=0},
	state = "title"
}
_actor = {
	-- physics
	x=0,
	y=0,
	xvel=0,
	yvel=0,
	xacc=0,
	yacc=0,
	xmaxvel=5,
	ymaxvel=4,
	friction=0.95,
	grounded=false,
	
	-- actions
	xinp = 0,
	yinp = 0,
	
	-- status
	hp = 100,
	
	-- sprite/mask
	sprite=0,
	flipx=false,
	width=8,
	height=8,
	
	-- meta
	name="unnamed"
}

function _actor:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function _actor:update()
	self:env_physics()
	self:move(self.xvel, self.yvel)
end

function _actor:env_physics()
	if self.gravity == nil then
		self.yvel += _global.gravity
	else
		self.yvel += self.gravity
	end
	
	self.xvel *= self.friction
	self.yvel *= self.friction
	
	if self.grounded and self.xinp == 0 then
		self.xvel *= self.friction^2
	end
	
	self.xvel = mid(-self.xmaxvel,self.xvel,self.xmaxvel)
	self.yvel = mid(-self.ymaxvel,self.yvel,self.ymaxvel)
	
	-- y collsion
	if self:hard_collision(0,self.yvel) then
		local dy = 0
		while (not self:hard_collision(0,dy)) do
			dy += sgn(self.yvel)
		end
		self.y = self.y + dy - sgn(self.yvel)
		self.yvel = 0
	end
	if self:hard_collision(0,1) then
		self.grounded = true
	else
		self.grounded = false
	end
	
	-- x collsion
	if self:hard_collision(self.xvel,0) then
		local dx = 0
		while (not self:hard_collision(dx,0)) do
			dx += sgn(self.xvel)
		end
		self.x = self.x + dx - sgn(self.xvel)
		self.xvel = 0
	end
end

function _actor:draw()
	spr(self.sprite, self.x, self.y, flr(self.width/8), flr(self.height/8))
end

function _actor:move(dx,dy)
	self.x += dx
	self.y += dy
end

function _actor:set_impulse(x,y)
	self.xvel = x
	self.yvel = y
end

function _actor:impulse(dx,dy)
	self.xvel += dx
	self.yvel += dy
end

function _actor:map_collision(x,y)
	x = x or 0
	y = y or 0
	nw = map_get((self.x+x)/16, (self.y+y)/16)
	ne = map_get((self.x+self.width-1+x)/16, (self.y+y)/16)
	sw = map_get((self.x+x)/16, (self.y+self.height-1+y)/16)
	se = map_get((self.x+self.width-1+x)/16, (self.y+self.height-1+y)/16)
	if not map_empty(nw)
	 or not map_empty(ne)
	 or not map_empty(sw)
	 or not map_empty(se)
	then
		return true
	else
		return false
	end
end

function _actor:hard_collision(x,y)
	return self:map_collision(x,y)
end

function _actor:collides(a)
	if not ( 
		self.x > a.x+a.width-1 or
		self.x+self.width-1 < a.x or
		self.y > a.y+a.height-1 or
		self.y+self.height-1 < a.y
	) then
		return a
	else 
		return nil
	end
end

function _actor:has_los(a,dx,dy)
	local mytilex = flr((self.x+self.width/2)/16)
	local mytiley = flr((self.y+self.height/2)/16)
	local ottilex = flr((a.x+a.width/2)/16)
	local ottiley = flr((a.y+a.height/2)/16)

	if dx > 0 then
		for i=mytilex,mytilex+dx do
			if i==ottilex and mytiley == ottiley then
				return true
			end
			if not map_empty(map_get(i,mytiley)) then
				return false
			end
		end
	else
		for i=mytilex,mytilex+dx,-1 do
			if i==ottilex and mytiley == ottiley then
				return true
			end
			if not map_empty(map_get(i,mytiley)) then
				return false
			end
		end
	end
	
	if dy > 0 then
		for i=mytiley,mytiley+dy do
			if i==ottiley and mytilex == ottilex then
				return true
			end
			if not map_empty(map_get(mytilex,i)) then
				return false
			end
		end
	else
		for i=mytiley,mytiley+dy,-1 do
			if i==ottiley and mytilex == ottilex then
				return true
			end
			if not map_empty(map_get(mytilex,i)) then
				return false
			end
		end
	end

	return false
end

function _actor:state()
 if self.states != nil then
  return self.states[#self.states]
 else
  return nil
 end
end

function _actor:pops()
	local s = self.states[#self.states]
	self.states[#self.states] = nil
	return s
end
_player = _actor:new({
	sprite=1,
	name="player",
	xinpacc = .2,
	yinpacc = .22,
	yjump = 2.5,
	curs = {x=0,y=0},
	fuelmax = 20,
	fuel = 0,
	weapon = 0,
	maxhp = 10,
	hp = 10,
	pickaxe=10,
	pickmax=10,
	pickprice=1,
	pickaxecharge = 0,
	invuln = true,
	invulnt = 60,
	ammo=16,
	maxammo=64
})

function _player:update()
	self:control()
	
	if self.hp <= 0 then
		self:die()
		return
	end
	
	if self.invuln then
		self.invulnt -= 1
	end
	
	if self.invulnt <= 0 then
		self.invuln = false
	end
	
	if self:b() then
		self.weapon = (self.weapon + 1)%2
	end

	if self:a() and self.weapon == 1 and self.ammo > 0 then
  vfx_shake(1)
  if _global.crystal.state != "follow" then
   self.ammo -= 1
  end
  
		local vx = 8
		if not self.flipx then
			add(projectiles, _proj:new({
				x=self.x+12,
				y=self.y,
				xvel=vx}
			))
			vfx_p_block(self.x+12,self.y+4,1,1,6,2)
		else
			add(projectiles, _proj:new({
				x=self.x-12,
				y=self.y,
				xvel=-vx}
			))
			vfx_p_block(self.x-12,self.y+4,1,1,6,2)
		end
	elseif self:a() and self.weapon == 1 and self.ammo == 0 then
		-- no ammo
		if not self.flipx then
			vfx_p_smoke2(self.x+13,self.y+4,1,10,6)
		else
			vfx_p_smoke2(self.x-5,self.y+4,1,10,6)
		end
 end
 
 if self:a() and _global.crystal.state == "follow" then
  if flr(self.x/16) == 0 and flr(self.y/16) == 0 then
   start_level()
  end
 end
	
	self.pickaxecharge += 1
	if self.pickaxecharge%2 == 0 and self.pickaxecharge > 20 then
		self.pickaxe = min(self.pickaxe+1,self.pickmax)
	end
	
	self:actor_physics()
	self:env_physics()
	self:move(self.xvel,self.yvel)
	
	-- fx
	if self.grounded and abs(self.xvel) > 2 then
		vfx_p_circfill(
			self.x+4, self.y+7,
			.4,10,6)
	end
end

function _player:control()
	self.xinp = 0
	self.yinp = 0
	if btn(⬆️) then
	 self.yinp -= 1
	end
	if btn(⬇️) then
	 self.yinp += 1
	end
	if btn(➡️) then
		self.xinp += 1
	end
	if btn(⬅️) then
	 self.xinp -= 1
	end
	
	if abs(self.xinp) > 0 then
		self:impulse(self.xinpacc * sgn(self.xinp),0)
		self.flipx = self.xinp < 0 and true or false
	end
	
	if self.grounded then
		self.fuel = self.fuelmax
	end
	
	if self.yinp < 0 then
	 if not self.grounded and self.fuel > 0 then
	 	self:impulse(0,-self.yinpacc)
	 	vfx_p_smoke(
	 		self.x+4, self.y+4,
	 		.4,10,6)
	 	self.fuel -= 1
	 elseif self.grounded then
	 	self:impulse(0,-self.yjump)
	 end
	end
	
	debug(self.x..":"..self.y, "xy")
	
	self.curs.x=4+flr((4+self.x+14*self.xinp)/16)*16
	self.curs.y=4+flr((4+self.y+14*self.yinp)/16)*16
end

function _player:draw()
	local dsprite = self.sprite
	local weapony = self.y
	local ws = 0
	
	if self.invuln == true then
		dsprite = 17 + 2*flr(4*t()%2)
	end
	
	local weaponx = self.x+4
	if self.flipx == false then
		weaponx += 2
	else
		weaponx -= 10
	end
	
	if abs(self.xvel) > 0.2 then
		dsprite = dsprite + 16*t()%2
		if self.grounded then
			weapony -= 16*t()%2
		else
			dsprite = self.sprite + 1
		end
	end

	spr(dsprite,
		self.x,self.y,1,1,
		self.flipx)
		
	if (self.weapon == 0) ws = 3
	if (self.weapon == 1) ws = 4
		
	spr(ws,weaponx,weapony,1,1,self.flipx)
		
	if self.weapon == 0 then
		spr(0,self.curs.x,self.curs.y)
	end
end

function _player:a()
	if self.weapon == 0 then
		-- pickaxe
		return btn(❎)
	else
		-- gun
	 return btnp(❎)
	end
end

function _player:b()
	return btnp(🅾️)
end

function _player:actor_physics()
	for e in all(enemies) do
		local e = self:collides(e)
		if e and not self.invuln then
			self:hit_enemy(e)
		end
	end
end

function _player:hit_enemy(e)
 if _global.crystal.state == "float" then
  -- player not protected by crystal
  self.hp -= e.damage
  vfx_p_blood(self.x+4,self.y+4,.5+rnd(1),15+rnd(12),8,6)
 else
  -- player protected by crystal
  _global.crystal.state = "float"
  _global.crystal.xvel = self.xvel
  _global.crystal.yvel = self.yvel

  _global.crystal:reset()

  message("get it back!")
 end
 self:impulse(-5*sgn(e.x-self.x),-6)
 self:inv(30)
 vfx_shake(4)
end

function _player:hit_proj(p)
	self.hp -= p.damage
	vfx_p_blood(self.x+4,self.y+4,.5+rnd(1),15+rnd(12),8,6)
	vfx_shake(4)
end

function _player:inv(t)
	self.invuln = true
	self.invulnt = t
end

function _player:die()
	vfx_p_death(self.x+4,self.y+4,.5+rnd(1),15+rnd(12),8,6)
	_global.state = "dead"
	message("you're dead.")
end

function _player:add_ammo(n)
	self.ammo += n
end
-- map

-- tile to spr table
map_t2s = {}
map_t2s[32] = 66
map_t2s[33] = 96
map_t2s[34] = 96
map_t2s[35] = 96
map_t2s[36] = 96
map_t2s[48] = 104

-- feature table
map_features = {
	{x=0,y=0,w=2,h=2}
}

function map_init()
	chunks={}
	csize = 4
	dim = 2^14
	
	-- starting cave
 map_make_feature(-1,-1,1)
 
 -- place stone
 map_place(-1, 1, 104)
 map_place(0, 1, 104)

 -- place door
 map_place(0,0,72)
 
	-- generate features
 map_gend_feats = 0
 local bigx = 0
 local bigy = 0
	while map_gend_feats < _global.map_target_feats do
		x=rnd(_global.map_spread)-_global.map_spread/2
  y=rnd(_global.map_spread/2)-_global.map_spread/4
		x += sgn(x)*2
  y += sgn(y)*2
		if map_make_feature(x,y) == true then
   map_gend_feats += 1

   -- check if its far
   if abs(x) > abs(bigx) then
    bigx = x
    bigy = y
   end
		end
 end

 -- generate last feature with crystal
 -- spawn crystal if u want
 local tilex = flr(bigx+4)
 local tiley = flr(bigy+4)
 map_place(tilex,tiley,96)
 map_grow_from(tilex,tiley)
 place_crystal(tilex*16+4, tiley*16+4)
 
 -- reset crystal
 _global.crystal.state = "float"
end

function map_place(x,y,val)
	x = flr(x)
	y = flr(y)
	local hash = map_chunk_hash(x,y)
	local chunk = chunks[hash]
	if chunk == nil then
		-- create a new chunk
		chunks[hash] = {}
	end
	
	local loc_x = x%csize
	local loc_y = y%csize
	
	chunks[hash][loc_y*csize+x] = val
end

function map_get(x,y)
	x = flr(x)
	y = flr(y)
	local hash = map_chunk_hash(x,y)
	local chunk = chunks[hash]
	if chunk == nil then
		return 0
	end
	
	local loc_x = x%csize
	local loc_y = y%csize
	local tile = chunk[loc_y*csize+x]
	
	if tile == nil then
		return 0
	else
		return tile
	end
end

function map_chunk_hash(x,y)
	return (x%dim) + (y%dim)/dim
end

function map_grow_from(x,y)
	for x=x-1,x+1 do
		for y=y-1,y+1 do
			if map_get(x,y) == 0 then
				map_place(x,y,map_genblock())
			end
		end
	end
end

function map_genblock()
	dice = rnd(100)
	if dice < 5 then
		return 100
 elseif dice < 10 then
  return 104
 else
		return 66
	end
end

function map_attempt_dig(x, y, _shake)
 local tx = flr(x/16)
 local ty = flr(y/16)
 local shake

 if (_shake == nil) shake = true

 tile = map_get(tx,ty)
 -- check if its dirt or ore
 if tile == 66 or tile == 100 then
  map_place(tx,ty,64)
  vfx_p_block(tx*16+8,ty*16+8,1,10,2,3)

  if shake == true then
   vfx_shake(2)
  end
  
  if tile == 100 then
   -- ammo drop
   q = 4+flr(rnd(3))
   for i=1,q do
    ammo = _ammo:new({
     x=tx*16+2,y=ty*16+2,
     xvel=2*cos(rnd()),yvel=2*sin(rnd()),
     flipx = rnd(1) < .5
    })
    add(ammos,ammo)
   end
  end
			
  -- generate new blocks
  map_grow_from(tx,ty)

  return true
 end

 return false
end

function map_update()
	if player:a() and player.weapon == 0 and player.pickaxe > 0 then
  result = map_attempt_dig(player.curs.x, player.curs.y)
  
  if result == true then
			player.pickaxe -= player.pickprice
			player.pickaxecharge = 0
		end
	end
	
	debug(map_gend_feats, "f")
end

function map_draw(px,py)
-- maybe this could use some
-- optimization, but it works
-- fine for now :) 
	for x=flr(px/16)-5,flr(px/16)+4 do
		for y=flr(py/16)-5,flr(py/16)+4 do
			local tile = map_get(x,y)
			local fx = band(x*0xbeef%11,1)
			local fy = band(y*0xcafe%17,1)
			if tile != 0 then
				spr(tile,x*16,y*16,2,2,bxor(fx,fy)==1)
			else
				spr(98,x*16,y*16,2,2,bxor(fx,fy)!=1)
			end
			
			-- shadows
			if map_empty(tile) == true and map_empty(map_get(x,y-1)) == false then
				rectfill(x*16,y*16,x*16+15,y*16+4,0)
			end
		end
	end
end

function map_make_feature(x,y,fi)
	mw = 64
	mh = 32
	if fi != nil then
		f = map_features[fi]
	else
		f = {}
		f.x = flr(rnd(mw))
		f.y = flr(rnd(mh))
		f.w = 3+flr(rnd(10))
		f.h = 3+flr(rnd(10))
 end
	
	x = flr(x)
	y = flr(y)
	
	-- make sure location is empty
	for i = x,x+f.w-1 do
		for j = y,y+f.h-1 do
			there = map_get(i,j)
			if (there != 0) return false
		end
	end
	
	-- place feature
	for i = f.x,f.x+f.w-1 do
		for j = f.y,f.y+f.h-1 do
			tile = mget(i%mw,j%mh)
			
			-- spawn things
			if tile == 34 then
				-- snout	
				add(enemies,
					_snout:new({
						x=(x-f.x+i)*16,
						y=(y-f.y+j)*16
					}) 
				)
			end
			
			if tile == 35 then
				-- scorp
				add(enemies,
					_scorp:new({
						x=(x-f.x+i)*16,
						y=(y-f.y+j)*16
					}) 
				)
   end
   
   if tile == 36 then
    -- swoop
    add(enemies,
     _swoop:new({
      x=(x-f.x+i)*16+2,
      y=(y-f.y+j)*16
     })
    )
   end
			
			map_place(x-f.x+i,y-f.y+j,map_t2s[tile])	
		end
 end
	
	-- encase
	for i = f.x,f.x+f.w-1 do
		for j = f.y,f.y+f.h-1 do
			tile = mget(i%mw,j%mh)
			if tile == 33 or tile == 34 or tile == 35 then
				-- air block
				map_grow_from(x-f.x+i,y-f.y+j)
			end
		end
	end
	
	return true
end

function map_empty(t)
	return t == 64 or t == 96 or t == 72
end
-- ui
function ui_init()
	messq = {}
	messt = 0
end

function message(m)
	add(messq, m)
	messt = 0
end

function ui_update(p)
	messt += 1
	
	if messt%120 == 0 then
		del(messq, messq[1])
	end
end

function ui_draw(p)
	-- message q
	-- bouncy first message
	if #messq > 0 then
		local xo = 8 * abs(sin(t()/2))^2
		for j=-1,1 do
			for k=-1,1 do
				print(messq[1],_global.cam.x+2+j+xo,_global.cam.y+133-6-6+k,7)
			end
		end
		print(messq[1],_global.cam.x+2+xo,_global.cam.y+133-6-6,0)
	end
	
	for i=2,#messq do
		for j=-1,1 do
			for k=-1,1 do
				print(messq[i],_global.cam.x+2+j,_global.cam.y+133-6*i-6+k,7)
			end
		end
		print(messq[i],_global.cam.x+2,_global.cam.y+133-6*i-6,0)
	end

	-- health
	local hx = 8
	local hy = 8
	local hunit = 3
	for i=0,p.hp-1 do
		line(
			_global.cam.x+hx+i*hunit,
			_global.cam.y+hy,
			_global.cam.x+hx+i*hunit+hunit,
			_global.cam.y+hy,
			14
		)
	end

	-- fuel gauge
	local fuelx = 8
	local fuely = 11
	local lineunit = 1
	for i=0,p.fuel-1 do
		line(
			_global.cam.x+fuelx+i*lineunit,
			_global.cam.y+fuely,
			_global.cam.x+fuelx+i*lineunit+lineunit,
			_global.cam.y+fuely,
			12
		)
	end
	
	local pickx
	local picky
	
	-- pickaxe gauge
	if p.weapon == 0 and p.hp > 0 then
		pickx = 58
		picky = 60
	else
		pickx = 8
		picky = 14
	end
	
	local lineunit = 2
	for i=0,p.pickaxe-1 do
		line(
			_global.cam.x+pickx+i*lineunit,
			_global.cam.y+picky,
			_global.cam.x+pickx+i*lineunit+lineunit,
			_global.cam.y+picky,
			9
		)
	end
	
	-- ammo
	local ammox
	local ammoy
	local ammodir = 1
	local lineunit = 1
	
	if p.weapon == 1 then
		ammox = 58
		ammoy = 60
		ammodir = -2
	else
		ammox = 8
		ammoy = 14
		ammodir = 2
	end
	
	if p.ammo == 0 then
		print("empty!",
			_global.cam.x+ammox,
			_global.cam.y+ammoy,
			8)
	end
	
	for i=0,p.ammo-1 do
		line(
			_global.cam.x+ammox+(i*lineunit)%20,
			_global.cam.y+ammoy+flr(i/20)*ammodir,
			_global.cam.x+ammox+(i*lineunit)%20+lineunit,
			_global.cam.y+ammoy+flr(i/20)*ammodir,
			8
		)
	end
	
end

function title_update()
	if btnp(❎) then
		_global.state = "play"
		start_level()
	end
end

function title_draw()
	print("it's the title screen.",0,0)
end
-- fx

function vfx_shake(m)
	shake.m = m
end

function vfx_init()
	particles = {}
	shake = {x=0,y=0,m=0}
end

function vfx_update()
	shake.m = max(shake.m-.5)
	shake.x = shake.m*cos(rnd())
	shake.y = shake.m*sin(rnd())

	for p in all(particles) do
		p.life -= 1
		if p.life >= 0 then
			p.x += p.xv
			p.y += p.yv
		else
			del(particles, p)
		end
	end
end

function vfx_draw(layer)
	for p in all(particles) do
		if p.layer == layer then
			if p.kind == "circfill" then
				circfill(p.x, p.y, 1, p.color)
			elseif p.kind == "smoke" then
				circ(p.x,p.y,2,p.color)
			elseif p.kind == "smoke2" then
				circfill(p.x,p.y,1,p.color)
			elseif p.kind == "block1" then
				circ(p.x,p.y,8,6)
			elseif p.kind == "block2" then
				circfill(p.x, p.y, 4, p.color)
			elseif p.kind == "blood" then
				circfill(p.x,p.y,3+rnd(5),p.color)
			elseif p.kind == "blood2" then
				circfill(p.x,p.y,1+rnd(2),p.color)
			elseif p.kind == "health" then
				circfill(p.x,p.y,1+rnd(2),p.color)
			elseif p.kind == "ammo" then
				circ(p.x,p.y,5,p.color)
			end
		end
	end
end

function vfx_p_circfill(x,y,m,l,c)
	angle = rnd()
	add(particles, {
		kind="circfill",
		x=x, y=y,
		xv=m*cos(angle),
		yv=m*sin(angle),
		color=c,life=l,layer=1
	})
end

function vfx_p_smoke(x,y,m,l,c)
	angle = rnd()
	add(particles, {
		kind="smoke",
		x=x, y=y,
		xv=m*cos(angle),
		yv=m*sin(angle),
		color=c,life=l,layer=-1
	})
end

function vfx_p_smoke2(x,y,m,l,c)
	angle = rnd()
	add(particles, {
		kind="smoke2",
		x=x, y=y,
		xv=m*cos(angle),
		yv=m*sin(angle),
		color=c,life=l,layer=-1
	})
end

function vfx_p_block(x,y,m,l,c,count)
 count = count or 1
 add(particles, {
			kind="block1",
			x=x, y=y,
			xv=0,
			yv=0,
			color=c,life=1,layer=1
		})
for _=1,count do
	angle = rnd()
		add(particles, {
			kind="block2",
			x=x, y=y,
			xv=m*cos(angle),
			yv=m*sin(angle),
			color=c,life=l,layer=1
		})
end
end

function vfx_p_blood(x,y,m,l,c,count)
	for _=1,count do
		angle = rnd()
			add(particles, {
				kind="blood2",
				x=x, y=y,
				xv=m*cos(angle),
				yv=m*sin(angle),
				color=c,life=l,layer=1
			})
	end
end

function vfx_p_death(x,y,m,l,c,count)
count = count or 1
add(particles, {
			kind="block1",
			x=x, y=y,
			xv=0,
			yv=0,
			color=c,life=1,layer=1
		})
for _=1,count do
	angle = rnd()
		add(particles, {
			kind="blood",
			x=x, y=y,
			xv=m*cos(angle),
			yv=m*sin(angle),
			color=c,life=l,layer=1
		})
end
end

function vfx_p_health(x,y,count)
	for _=1,count do
		angle = rnd()
			add(particles, {
				kind="health",
				x=x, y=y,
				xv=1*cos(angle),
				yv=1*sin(angle),
				color=14,life=10,layer=1
			})
	end
end

function vfx_p_ammo(x,y)
	angle = rnd()
	add(particles, {
		kind="ammo",
		x=x, y=y,
		xv=0,
		yv=0,
		color=6,life=6,layer=1
	})
end
_snout = _actor:new({
	sprite=12,
	name="snout",
	xinpacc = .02,
	yinpacc = 3.4,
	yjump = 2.5,
	width = 16,
	height = 16,
	statet=-1,
	damage=4
})

function _snout:take_damage(d)
	self.hp -= d
	vfx_p_blood(self.x+4,self.y+4,.5+rnd(1),15+rnd(12),8,3)

	if self:state() == "movel" then
		add(self.states, "mover")
	elseif self:state() == "mover" then
		add (self.states, "movel")
	end
end

function _snout:die()
	vfx_p_death(self.x+8,self.y+8,.5+rnd(1),15+rnd(12),8,6)
	vfx_shake(8)
	message("killed a snout.")
	_global.killed += 1
	
	if rnd(3) < 1 then
		add(healths, _health:new({
			x=self.x+8,y=self.y+8,
			xvel=rnd(2)-1,yvel=-2
		}))
	end
	
	del(enemies, self)
end

function _snout:update()
	self.statet -= 1
		
	if self.hp <= 0 then
		self:die()
		return
	end
	
	if self.statet == 0 then
		self:pops()
	end

	if self.states == nil 
	or self.states[1] == nil then
		self.states = {[1]="mover"}
	end
	
	local state = self:state()
	
	if state == "mover" then
		self.xinp = 1
		self:impulse(self.xinpacc,0)
	elseif state == "movel" then
		self.xinp = -1
		self:impulse(-self.xinpacc,0)
	elseif state == "runr" then
		self.xinp = 1
		self:impulse(self.xinpacc*8,0)
	elseif state == "runl" then
		self.ximp = -1
		self:impulse(self.xinpacc*-8,0)	
	elseif state == "jump" then
		if self.grounded then
			self.yinp = -1
			self:impulse(0,-self.yinpacc)
			self:pops()
		end
	end
	
	if state == "runr" or state == "runl" then
		if self.grounded then
			self.yinp = -1
			self:impulse(0,-self.yinpacc/4)
		end
	end
	
	self:env_physics()
	self:move(self.xvel, self.yvel)
	
	if self.xvel == 0 and self.grounded then
		if state == "mover" then
			if not self:hard_collision(0,-16)
			and not self:hard_collision(16,-16) then
			 add(self.states,"jump")
			else
				self:pops()
				add(self.states,"movel")
			end
		elseif state == "movel" then
			if not self:hard_collision(0,-16)
			and not self:hard_collision(-16,-16) then
			 add(self.states,"jump")
			else
				self:pops()
				add(self.states,"mover")
			end
		end
	elseif flr(self.y/16) == flr(player.y/16) 
	and self:has_los(player,4*sgn(self.xinp),0)
	and sgn(player.x-self.x) == sgn(self.xinp)
	then
		if state == "movel" then
			add(self.states, "runl")
			self.statet = 30
		elseif state == "mover" then
			add (self.states, "runr")
			self.statet = 30
		end
	end
end

function _snout:draw()
	local dsprite = self.sprite
	local flipx = self.xinp > 0
	local sspeed = 2
	
	if self:state() == "runr" or self:state() == "runl" then
		sspeed = 8
	end
	
	dsprite += 2*flr(sspeed*t()%2)
	
	spr(dsprite, self.x, self.y,2,2,flipx)
end
_scorp = _actor:new({
	sprite=44,
	name="scorp",
	xinpacc=.016,
	yinpacc=5.6,
	yjump=2.5,
	width=16,
	height=16,
	statet=-1,
	damage=3,
	hp=66
})

function _scorp:take_damage(d)
	self.hp -= d
 vfx_p_blood(self.x+4,self.y+4,.5+rnd(1),15+rnd(12),8,3)
 
 if self:state() != "shoot" 
 and self:state() != "yump" then
  -- yump
  add(self.states,"yump")
  self.statet = 45
 end
end

function _scorp:die()
	vfx_p_death(self.x+8,self.y+8,.5+rnd(1),15+rnd(12),8,6)
	vfx_shake(8)
	message("killed a scorp.")
	_global.killed += 1
	
	if rnd(3) < 1 then
		add(healths, _health:new({
			x=self.x+8,y=self.y+8,
			xvel=rnd(2)-1,yvel=-2
		}))
	end
	
	del(enemies, self)
end

function _scorp:update()
	self.statet -= 1
 
	if self.hp <= 0 then
		self:die()
		return
	end
	
	if self.statet == 0 then
		self:pops()
	end
	
	if self.states == nil 
	or self.states[1] == nil then
		self.states = {[1]="mover"}
	end
	
	local state = self.states[#self.states]
 local str = ""
 for s in all(self.states) do
  str = str..s.." "
 end
 
	if state == "mover" or state == "movel" then
		if flr((self.y+8)/16) == flr((player.y+4)/16) 
		and (self:has_los(player,3,0) or self:has_los(player,-3,0))
		and player.hp > 0
		then
			add(self.states, "shoot")
			self.statet = 30
		end
	end
	
	if state == "mover" then
		self.xinp = 1
		self:impulse(self.xinpacc,0)
	elseif state == "movel" then
		self.xinp = -1
		self:impulse(-self.xinpacc,0)
	elseif state == "yump" 
	and self.grounded == true
	then
		self.yinp = -1
		self:impulse(0,-self.yinpacc)
	elseif state == "shoot" then
		if self.statet%11 == 0 then
			add(acids, _acid:new({
				x=self.x+8, y=self.y+2,
				xvel = sgn(player.x-self.x)*2
			}))
			self.xinp = sgn(player.x-self.x)
		end
	end
	
	self:env_physics()
	self:move(self.xvel, self.yvel)
	
	if  self.xvel == 0 
	and self.grounded 
	and (state == "mover" or state == "movel")
	then
  if state == "mover" then
   -- small chance to dig
   if rnd(8) < 1 then
    -- diggy
    map_attempt_dig(self.x+16,self.y,false)
   else
    self:pops()
    add(self.states,"movel")
   end
  elseif state == "movel" then
   -- small chance to dig
   if rnd(8) < 1 then
    map_attempt_dig(self.x-16,self.y,false)
   else
    self:pops()
    add(self.states,"mover")
   end
  end
	elseif player.y < self.y
	and flr((4+player.x)/16) == flr((8+self.x)/16)
	and state != "yump"
	and self:has_los(player,0,-3)
	then
  -- yump
		add(self.states,"yump")
		self.statet = 45
	end	
end

function _scorp:draw()
	local dsprite = self.sprite
	local flipx = self.xinp > 0
	local sspeed = 5
	
	dsprite += 2*flr(sspeed*t()%2)
	
	spr(dsprite, self.x, self.y,2,2,flipx)
end
_swoop = _actor:new({
 sprite=38,
 sspeed=0,
	name="swoop",
	width=12,
	height=12,
	statet=-1,
 damage=2,
 gravity=0,
 friction=1,
 flyspeed=.06,
 hp=40
})

function _swoop:take_damage(d)
 local state = self.states[#self.states]

 -- can't take damage unless attacking
 if state == "swoop" then
  self.hp -= d
  self.xvel *= 0.6
  self.yvel *= 0.6
  vfx_p_blood(self.x+4,self.y+4,.5+rnd(1),15+rnd(12),8,3)
 end

end

function _swoop:die()
	vfx_p_death(self.x+8,self.y+8,.5+rnd(1),15+rnd(12),8,6)
	vfx_shake(4)
	message("killed a swoop.")
	_global.killed += 1
	
	if rnd(5) < 1 then
		add(healths, _health:new({
			x=self.x+8,y=self.y+8,
			xvel=rnd(2)-1,yvel=-2
		}))
	end
	
	del(enemies, self)
end

function _swoop:update()
	self.statet -= 1
		
	if self.hp <= 0 then
		self:die()
		return
	end
	
	if self.statet == 0 then
		self:pops()
 end
 
 if self.states == nil
 or self.states[1] == nil then
  self.states = {[1]="hang out"}
 end

 local state = self.states[#self.states]

 if state == "hang out" then
  -- swoop when player is in sight
  -- or perch is broken
  if self:has_los(player, 0, 6) 
  or not self:hard_collision(0, -1)
  then
   self:swoop()
  end
 elseif state == "swoop" then
  -- fly towards player
  local xdif = player.x - self.x
  local ydif = player.y - self.y

  local dist = sqrt(xdif^2 + ydif^2)

  self.xvel += xdif/dist * self.flyspeed
  self.yvel += ydif/dist * self.flyspeed
 end

	self:env_physics()
	self:move(self.xvel, self.yvel)
	
end

function _swoop:swoop()
 add(self.states, "swoop")
 self.sspeed = 8
 self.sprite = 40
end

function _swoop:draw()
	local dsprite = self.sprite
 local flipx = self.xinp > 0
	
	dsprite += 2*flr(self.sspeed*t()%2)
	
 spr(dsprite, self.x-2, self.y-2,2,2,flipx)
end
function enemies_init()
 enemies = {}
end

function enemies_update()
	for e in all(enemies) do
		e:update()
	end
	debug(#enemies)
end

function enemies_draw()
	for e in all(enemies) do
		e:draw()
	end
end
-- projectiles/pickups

_proj = _actor:new({
	sprite=5,
	name="bullet",
	statet=10,
	gravity = 0,
	friction = 1,
	damage = 9,
	xmaxvel=8
})

_health = _actor:new({
	sprite = 6,
	name="health",
	gravity=_global.gravity/3,
	friction = 0.99,
	damage = -2
})

_ammo = _actor:new({
	sprite = 8,
	name="ammo",
	gravity=_global.gravity*1.3,
	friction = 0.90,
})

_acid = _actor:new({
	sprite=9,
	name="acid",
	statet=45,
	gravity = _global.gravity*.3,
	friction = .98,
	damage = 1,
	xmaxvel=8
})

function _proj:die()
	vfx_p_block(self.x+4,self.y+4,1,2,6,3)
	del(projectiles, self)
end

function _proj:actor_physics()
	for e in all(enemies) do
		local a = self:collides(e)
		if a then
			e:take_damage(self.damage)
			vfx_shake(2)
			self:die()
		end
	end
end

function _proj:update()
	self.statet -= 1
	
	if self.xvel == 0 then
		self.statet = 0
	end
	
	if self.statet == 0 then
		self:die()
		return
	end

	vfx_p_smoke2(self.x,self.y+4,.5,6,6)

	self:actor_physics()
	self:env_physics()
	self:move(self.xvel, self.yvel)
end

function _proj:draw()
	local flipx = false
	
	if self.xvel < 0 then
		flipx = true
	end
	
	spr(self.sprite,self.x,self.y,1,1,flipx)
end

function _ammo:update()
	self:actor_physics()
	self:env_physics()
	self:move(self.xvel, self.yvel)
end

function _health:update()
	if flr(rnd(20)) == 0 then
		vfx_p_health(self.x+4,self.y+4,2)
	end
	self:actor_physics()
	self:env_physics()
	self:move(self.xvel, self.yvel)
end

function _health:draw()
	spr(self.sprite+5*t()%2,self.x,self.y,1,1)
end

function _health:actor_physics()
	if self:collides(player) then
		player.hp = min(player.maxhp, player.hp - self.damage)
  message("health!")
  self:die()
	end
end

function _ammo:actor_physics()
	if self:collides(player) then
		player.ammo += 1
		self:die()
	end
end

function _ammo:die()
	vfx_p_ammo(self.x+4,self.y+4)
	del(ammos,self)
end

function _ammo:draw()
	spr(self.sprite,self.x,self.y,1,1,self.flipx)
end

function _health:die()
	vfx_p_health(self.x+4,self.y+4,8)
	del(healths, self)
end

function _acid:die()
	del(acids, self)
end

function _acid:update()
	self.statet -= 1
	
	if self.xvel == 0 then
		self.statet = 0
	end
	
	if self.statet == 0 then
		self:die()
		return
	end

	vfx_p_smoke2(self.x,self.y+4,.5,6,6)

	self:actor_physics()
	self:env_physics()
	self:move(self.xvel, self.yvel)
end

function _acid:actor_physics()
	if self:collides(player) and player.hp > 0 then
		player:hit_proj(self)
		self:die()
	end
end

function proj_init()
	projectiles = {}
	healths = {}
	ammos={}
	acids={}
end

function proj_update()
	for p in all(projectiles) do
		p:update()
	end
	for h in all(healths) do
		h:update()
	end
	for a in all(ammos) do
		a:update()
	end
	for a in all(acids) do
		a:update()
	end
end

function proj_draw()
	for p in all(projectiles) do
		p:draw()
	end
	for h in all(healths) do
		h:draw()
	end
	for a in all(ammos) do
		a:draw()
	end
	for a in all(acids) do
		a:draw()
	end
end
_crystal = _actor:new({
 sprite = 102,
 name = "crystal",
 width=8,
 height=8,
 friction=.99,
 gravity=0,
 state="float",
 posbufmax=24,
 posbuffer={},
 posp=0,
 fxchance=3
})

getoutms = {
 "now get out!",
 "now scram!",
 "now evacuate!",
 "now you'd better leave!"
}

function place_crystal(x, y)
 if _global.crystal == nil then
  _global.crystal = _crystal:new()
 end

 _global.crystal:reset()
 _global.crystal.x = x
 _global.crystal.y = y
end

function _crystal:reset()
 for i=1,#self.posbuffer do
  self.posbuffer[i] = nil
  self.posp = 0
 end
end

function _crystal:update()
 if self.state == "float" then
  self.fxchance = 2
  if not player.invuln and self:collides(player) then
   self.state = "follow"
   player.ammo += 1
   message(getoutms[flr(rnd(#getoutms) + 1)])
  end
 elseif self.state == "follow" then
  -- follow player
  if #self.posbuffer >= self.posbufmax then
   self.x = self.posbuffer[self.posp+1].x
   self.y = self.posbuffer[self.posp+1].y
  end

  -- update position buffer
  self.posbuffer[self.posp+1] = {
   x=player.x,
   y=player.y
  }
  self.posp = (self.posp + 1) % self.posbufmax

  -- fxchance
  self.fxchance = 12
 end

 -- emit blood
 -- blood crystal.
 if rnd(100) < self.fxchance then
  vfx_p_blood(self.x+4, self.y+4, .5, 30, 8, 2)
 end

 debug(self.x)
 debug(self.y)

 self:env_physics()
	self:move(self.xvel, self.yvel)
end

function _crystal:draw()
 spr(self.sprite, self.x-4, self.y-4 + 4*sin(t()), 2, 2, flipx)

 if self.state == "follow" then
  -- show button indicator above door
  if t()*4 % 1 < .5 then
   print("❎", 4, -4, 6)
  end
 end
end
_crystal = _actor:new({
 sprite = 102,
 name = "crystal",
 width=8,
 height=8,
 friction=.99,
 gravity=0,
 state="float",
 posbufmax=24,
 posbuffer={},
 posp=0,
 fxchance=3
})

getoutms = {
 "now get out!",
 "now scram!",
 "now evacuate!",
 "now you'd better leave!"
}

function place_crystal(x, y)
 if _global.crystal == nil then
  _global.crystal = _crystal:new()
 end

 _global.crystal:reset()
 _global.crystal.x = x
 _global.crystal.y = y
end

function _crystal:reset()
 for i=1,#self.posbuffer do
  self.posbuffer[i] = nil
  self.posp = 0
 end
end

function _crystal:update()
 if self.state == "float" then
  self.fxchance = 2
  if not player.invuln and self:collides(player) then
   self.state = "follow"
   player.ammo += 1
   message(getoutms[flr(rnd(#getoutms) + 1)])
  end
 elseif self.state == "follow" then
  -- follow player
  if #self.posbuffer >= self.posbufmax then
   self.x = self.posbuffer[self.posp+1].x
   self.y = self.posbuffer[self.posp+1].y
  end

  -- update position buffer
  self.posbuffer[self.posp+1] = {
   x=player.x,
   y=player.y
  }
  self.posp = (self.posp + 1) % self.posbufmax

  -- fxchance
  self.fxchance = 12
 end

 -- emit blood
 -- blood crystal.
 if rnd(100) < self.fxchance then
  vfx_p_blood(self.x+4, self.y+4, .5, 30, 8, 2)
 end

 debug(self.x)
 debug(self.y)

 self:env_physics()
	self:move(self.xvel, self.yvel)
end

function _crystal:draw()
 spr(self.sprite, self.x-4, self.y-4 + 4*sin(t()), 2, 2, flipx)

 if self.state == "follow" then
  -- show button indicator above door
  if t()*4 % 1 < .5 then
   print("❎", 4, -4, 6)
  end
 end
end


__gfx__
00000000000000000088880000000000000000000000000000000000008080000000000000000000000000000000000000000000000000000000000007000000
00000000008888000081cc8006666000000000000000000000808000008800000000000000000230000000000000000000000000070000000000070007000700
000007000081cc80668c11800000850000000000888888000088000008eee8000000220000037000000000000000000000000700070007000000060006600660
00070000668c11806688888000080500888000600222226008eee80008eee6e00002260000333000000000000000000000000600066006600000066006660660
00007000668888808822220000800500668886600222226008eee60008eeeee00028280002333200000000000000000000000660066606600000066633333330
00700000882222000022220008000500066000008888880008eee800008ee8800088880002332200000000000000000000000666333333300000066333333330
000000000022220002000020800000006600000000000000008ee800008888000028200000222000000000000000000000000663333333300000003333333333
00000000002002000000000000000000000000000000000000888800008880000088000000000000000000000000000000000033333333332000003333333333
066666000000000000cccc0000000000001111000000000000000000000000000000000000000000000000000000000020000033333333333333331333223333
6600006000cccc0000ccccc000111100001111100000000000000000000000000000000000000000000000000000000033333313332233330606033333222333
6600006000ccccc0ccccccc000111110111111100000000000000000000000000000000000000000000000000000000006262333332223330602222333222333
00006600ccccccc0ccccccc011111110111111100000000000000000000000000000000000000000000000000000000000000223332223330220000222000222
00060000ccccccc0cccccc0011111110111111000000000000000000000000000000000000000000000000000000000000000002220002220000000022000022
00000000cccccc0000cccc0011111100001111000000000000000000000000000000000000000000000000000000000000000000200000020000000002000002
0006600000cccc000c0000c000111100010000100000000000000000000000000000000000000000000000000000000000000033000000020000000003000033
0000000000c00c000000000000100100000000000000000000000000000000000000000000000000000000000000000000000000000003330000000033000000
44444444111111110000000000000222000000000000000000000002020000000000000000000000000000000000000000000000000003300000000000000000
44224444111111110000000000000002000000000000000000000002200000000000000000000000333000000000033300000000000332230000000000000000
42224444110111000000606600300022000000000000000000000003000000000000000000000000222300000000322200000000000220020000000000000330
42424444100110011000033300330020033333300000000000000003300000000000000000000000022230000003222000000000006000020000000000033222
24424442010010113333333300033320330330330000000000000033330000000000000000000000002230000003220000000000000000030000000000022002
44442222111001110000333333333300300000030000000000000033330000000000003003000000002323000032320000000000000000030000000000600003
44442244111101110000300303330330000000000000000000000033330000000000003333000000003222000022230000000000000000320000000000000003
44444444111111110000300300300030000000000000000000000333322000000000331331330000030222300322203000000000000003320000000000000032
66666666000000000000000000000000000000000000000000000333222000000003227227223000000002333320000000002202033333200000000002000332
66666666000000000000000000000000000000000000000000000332222000000332200000022330000002133120000000222223333332200000000003333320
65566665000000000000000000000000000000000000000000000322220000003223000000003223000000722700000002222233333322020002200333333200
56656655000000000000000000000000000000000000000000000322220000003200000000000023000000022000000006002313333220000222223622232220
56656656000000000000000000000000000000000000000000000213310000000300000000000030000000000000000000060336222222002222231322222002
56665566000000000000000000000000000000000000000000000033330000000000000000000000000000000000000000000000222202006002262222222000
66666666000000000000000000000000000000000000000000000030030000000000000000000000000000000000000000000622222000200060002222200200
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022220000000000000000000200
00000000000000004224444444442422888888888888888900000000000000000000000000000000000000000000000000000000000000000000000000000000
00011000000000004422244444442444888888888899899900000000000000000001100000000000000000000000000000000000000000000000000000000000
00111100000110002442444444442444888888899988988900000000000000000011177666711000000000000000000000000000000000000000000000000000
01111110001111002442444424422444888988988888888900000000000000000111700000071100000000000000000000000000000000000000000000000000
01111110011111102424242244444244898899888888888900000000000000000116000000006110000000000000000000000000000000000000000000000000
00111100011111102444424444444424988888888888888900000110000000000016000000006110000000000000000000000000000000000000000000000000
00011000001111002444424444444422888888888888888900000100010000000070000000000700000000000000000000000000000000000000000000000000
00000000000110002444442444444424888888888899889800000001100000000070000000000700000000000000000000000000000000000000000000000000
00011000000000004444244242244442888888888988998900000001100000000070000000000700000000000000000000000000000000000000000000000000
00111100000110002222442444444422889999999888888900000010001000000061010101010700000000000000000000000000000000000000000000000000
01111110001111002424444244442242899888888888888900000000011000000160000000000700000000000000000000000000000000000000000000000000
01111110011111102244424222424424988888888888888900000000000000000161111111111610000000000000000000000000000000000000000000000000
00111100011111102242242244424242888888888888888900000000000000000060000000000610000000000000000000000000000000000000000000000000
00011000001111002424442424242422888888888888888900000000000000000071111111111600000000000000000000000000000000000000000000000000
00000000000110002222224224424222888899999888889800000000000000000070000000000600000000000000000000000000000000000000000000000000
00000000000000002222222222222222999988888999998800000000000000000071111111111700000000000000000000000000000000000000000000000000
000000000000000021122222222212114244244444222422000000002000000055ddddddddddd555000000000000000000000000000000000000000000000000
00111100000000002211122222221222424424444244424400000002280000005dddddddddddddd5000000000000000000000000000000000000000000000000
0100001000000000122122222222122242242424424442440000000222000000dddddddddddddddd000000000000000000000000000000000000000000000000
01000010000000001221222212211222444226442244242400000028a8200000dddd5dd5d5dddddd000000000000000000000000000000000000000000000000
0011110000111100121212112222212224422242442444420000002277800000dd55d5ddddd5d5dd000000000000000000000000000000000000000000000000
00000000010000101222212222222212422282244442442400000822778200005ddd5dddd55d55dd000000000000000000000000000000000000000000000000
00000000010000101222212222222211448888844422644200000222aa22000055555d5d5d5dd5d5000000000000000000000000000000000000000000000000
000000000011110012222212222222124448884244222442000022288a2800005dd55555d5d55555000000000000000000000000000000000000000000000000
00111100000000002222122121122221244888444228224200002288228800005ddddd55555dddd5000000000000000000000000000000000000000000000000
0100001000000000111122122222221124448444288888420000288228800000dddd5dddddd5dddd000000000000000000000000000000000000000000000000
0100001000000000121222212222112142248442448884220000282288800000ddd5d5dddddddddd000000000000000000000000000000000000000000000000
001111000011110011222121112122122244244244888442000002a888000000dddddddddddd5ddd000000000000000000000000000000000000000000000000
000000000100001011211211222121214242422442484222000002aa880000005ddddddddd5dddd5000000000000000000000000000000000000000000000000
00000000010000101212221212121211222422424248424200000088800000005d5d5d5d5d5d5d55000000000000000000000000000000000000000000000000
000000000011110011111121122121112242242424442222000000888000000055d5d5555d55ddd5000000000000000000000000000000000000000000000000
00000000000000001111111111111111222222222222222200000008000000005555555555555555000000000000000000000000000000000000000000000000
__label__
24444001111000000000000000000001111002444422424424444444424424224444224444224244244442444422424424444444424424224444224444224244
42222010000100000000000000000010000102244444442442222222244244444442222444444424422222244444442442222222244244444442222444444424
44242010000100000000000000000010000102422444424444242242444424444224224224444244442422422444424444242242444424444224224224444244
44422001111000011110000111100001111004244242224244422224442422242442442442422242444224244242224244422224442422242442442442422242
22422000000000100001001000010000000002424244422422422224224224442424224242444224224222424244422422422224224224442424224242444224
44242000000000100001001000010000000002242424242444242242444242424242222424242424442422242424242444242242444242424242222424242424
22222000000000011110000111100000000002224244224222222222222422442422222242442242222222224244224222222222222422442422222242442242
22222000000000000000000000000000000002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
44224000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee42444444444224000000000000000022424444444442242242444444444224000000000000000000000000000
22244001111000000000000000000001111004442444444422244000000000000000044424444444222444442444444422244000000000000000000000000000
42442010000100000000000000000033000104442444444442442000000000000000044424444444424424442444444442442000000000000000000000000000
42442010ccccccccccccccccccccc322200104442244244442442000000000000000044422442444424424442244244442442000000000000000000000000000
24242001111000011110000111102201211004424444422424242000000000000000044244444224242424424444422424242000000000000000000000000000
44442000000000100001001000060000300004244444444244442000000000100001042444444442444424244444444244442000000000100001001000010000
44442000999999999999999999999000300002244444444244442000000000100001022444444442444422244444444244442000000000100001001000010000
44442000000000011110000111100003200004244444442444442000000000011110042444444424444424244444442444442000000000011110000111100000
24444001111000000000000000200033211002444422424424444001111000000000024444224244244442444422424424444001111000000000000000000001
42222010000100000000000000333332000102244444442442222010000100000000022444444424422222244444442442222010000100000000000000000010
44242010000100000000220033333320000102422444424444242010000100000000024224444244442422422444424444242010000100000000000000000010
44422001111000011122222362223222111004244242224244422001111000011110042442422242444224244242224244422001111000011110000111100001
22422000000000100222223132222200200002424244422422422000000000100001024242444224224222424244422422422000000000100001001000010000
44242000000000100601226222222200000002242424242444242000000000100001022424242424442422242424242444242000000000100001001000010000
22222000000000011116000222220020000002224244224222222000000000011110022242442242222222224244224222222000000000011110000111100000
22222000000000000000000000000020000002222222222222222000000000000000022222222222222222222222222222222000000000000000000000000000
42422224244444444422442244444444424224224444444442422224244444444422442244444444424224224444444442422000000000000000000000000000
42444444244444442224444222444444424444422244444442444444244444442224444222444444424444422244444442444000000000011110000111100000
42444444244444444244224424444444424442442444444442444444244444444244224424444444424442442444444442444000000000100001001000010000
22444444224424444244224424444244224442442444424422444444224424444244224424444244224442442444424422444000000000100001001000010000
44244442444442242424224242422444442442424242244444244442444442242424224242422444442442424242244444244001111000011110000111100001
44424424444444424444224444244444444242444424444444424424444444424444224444244444444242444424444444424010000100000000000000000010
44422224444444424444224444244444444222444424444444422224444444424444224444244444444222444424444444422010000100000000000000000010
44424424444444244444224444424444444242444442444444424424444444244444224444424444444242444442444444424001111000000000000000000001
44442244442242442444444442442422444424444244242244442244442242442444444442442422444424444244242244442000000000011110000111100000
44422224444444244222222224424444444222222442444444422224444444244222222224424444444222222442444444422000000000100001001000010000
42242242244442444424224244442444422422424444244442242242244442444424224244442444422422424444244442242000000000100001001000010000
24424424424222424442222444242224244242244424222424424424424222424442222444242224244242244424222424424001111000011110000111100001
24242242424442242242222422422444242422242242244424242242424442242242222422422444242422242242244424242010000100000000000000000010
42422224242424244424224244424242424222424442424242422224242424244424224244424242424222424442424242422010000100000000000000000010
24222222424422422222222222242244242222222224224424222222424422422222222222242244242222222224224424222001111000000000000000000001
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222000000000000000000000000000
22112211222222222121111212222222221124224444444442422000000000000000000000000000000004224444444442422000000000000000000000000000
11122221112222222122222212222222111224422244444442444000000000000000000000000000000004422244444442444000000000011110000111100000
21221122122222222122222212222222212212442444444442444000000000000000000000000000000002442444444442444000000000100001001000010000
21221122122221221122222211221222212212442444424422444000000000000000000000000000000002442444424422444000000000100001001000010000
12121121212112222212222122222112121212424242244444244000000000000000000000000000000002424242244444244001111000011110000111100001
22221122221222222221221222222221222212444424444444424010000100000000000000000010000102444424444444424010000100000000000000000010
22221122221222222221111222222221222212444424444444422010000100000000000000000010000102444424444444422010000100000000000000000010
22221122222122222221221222222212222212444442444444424001111000000000000000000001111002444442444444424001111000000000000000000001
12222222212212112222112222112122122224444244242244442000000000011110000111100000000004444244242244442000000000011110000111100000
21111111122122222221111222222212211112222442444444422000000000100001001000010000000002222442444444422000000000100001001000010000
22121121222212222112112112222122221212424444244442242000000000100001001000010000000002424444244442242000000000100001001000010000
22211112221211121221221221211121222112244424222424424001111000011110000111100001111002244424222424424001111000011110000111100001
11211112112112221212112121222112112112242242244424242010000100000000000000000010000102242242244424242010000100000000000000000010
22121121222121212121111212121212221212424442424242422010000100000000000000000010000102424442424242422010000100000000000000000010
11111111111211221211111121221121111112222224224424222001111000000000000000000001111002222224224424222001111000000000000000000001
11111111111111111111111111111111111112222222222222222000000000000000000000000000000002222222222222222000000000000000000000000000
22112211222222222121111212222222221124224444444442422000000000000000000000000000000004224444444442422224244444444422442244444444
11122221112222222122222212222222111224422244444442444000000000011110000111100000000004422244444442444444244444442224444222444444
21221122122222222122222212222222212212442444444442444000000000100001001000010000000002442444444442444444244444444244224424444444
21221122122221221122222211221222212212442444424422444000000000100001001000010000000002442444424422444444224424444244224424444244
12121121212112222212222122222112121212424242244444244001118888888888888888800001111002424242244444244442444442242424224242422444
22221122221222222221221222222221222212444424444444424010000100000000000000000010000102444424444444424424444444424444224444244444
22221122221222222221111222222221222212444424444444422010000100000000000000000010000102444424444444422224444444424444224444244444
22221122222122222221221222222212222212444442444444424001111000000000000000000001111002444442444444424424444444244444224444424444
12222222212212112222112222112122122224444244242244442000000000011110000111100000000004444244242244442244442242442444444442442422
21111111122122222221111222222212211112222442444444422000000000100088881000010000000002222442444444422224444444244222222224424444
22121121222212222112112112222122221212424444244442242000000000100081cc8000010000000002424444244442242242244442444424224244442444
2221111222121112122122122121112122211224442422242442400111100001668c118881106001111002244424222424424424424222424442222444242224
11211112112112221212112121222112112112242242244424242010000100006688886688866010000102242242244424242242424442242242222422422444
22121121222121212121111212121212221212424442424242422010000100008822220660000010000102424442424242422224242424244424224244424242
11111111111211221211111121221121111112222224224424222001111000000022226600000001111002222224224424222222424422422222222222242244
11111111111111111111111111111111111112222222222222222000000000000020020000000000000002222222222222222222222222222222222222222222
21211112122222222211221122222222212112242444444444224422444444444242222424444444442242242444444444224000000000000000000000000000
21222222122222221112222111222222212224442444444422244442224444444244444424444444222444442444444422244000000000000000000000000000
21222222122222222122112212222222212224442444444442442244244444444244444424444444424424442444444442442000000000000000000000000000
11222222112212222122112212222122112224442244244442442244244442442244444422442444424424442244244442442000000000000000000000000000
22122221222221121212112121211222221224424444422424242242424224444424444244444224242424424444422424242000000000000000000000000000
22212212222222212222112222122222222124244444444244442244442444444442442444444442444424244444444244442000000000100001001000010000
22211112222222212222112222122222222112244444444244442244442444444442222444444442444422244444444244442000000000100001001000010000
22212212222222122222112222212222222124244444442444442244444244444442442444444424444424244444442444442000000000011110000111100000
22221122221121221222222221221211222212444422424424444444424424224444224444224244244442444422424424444001111000000000000000000001
22211112222222122111111112212222222112244444442442222222244244444442222444444424422222244444442442222010000100000000000000000010
21121121122221222212112122221222211212422444424444242242444424444224224224444244442422422444424444242010000100000000000000000010
12212212212111212221111222121112122124244242224244422224442422242442442442422242444224244242224244422001111000011110000111100001
12121121212221121121111211211222121212424244422422422224224224442424224242444224224222424244422422422000000000100001001000010000
21211112121212122212112122212121212112242424242444242242444242424242222424242424442422242424242444242000000000100001001000010000
12111111212211211111111111121122121112224244224222222222222422442422222242442242222222224244224222222000000000011110000111100000
11111111111111111111111111111111111112222222222222222222222222222222222222222222222222222222222222222000000000000000000000000000
21211112122222222211221122222222212112112222222221211112122222222211221122222222212112242444444444224000000000000000000000000000
21222222122222221112222111222222212222211122222221222222122222221112222111222222212224442444444422244001111000000000000000000001
21222222122222222122112212222222212221221222222221222222122222222122112212222222212224442444444442442010000100000000000000000010
11222222112212222122112212222122112221221222212211222222112212222122112212222122112224442244244442442010000100000000000000000010
22122221222221121212112121211222221221212121122222122221222221121212112121211222221224424444422424242001111000011110000111100001
22212212222222212222112222122222222121222212222222212212222222212222112222122222222124244444444244442000000000100001001000010000
22211112222222212222112222122222222111222212222222211112222222212222112222122222222112244444444244442000000000100001001000010000
22212212222222122222112222212222222121222221222222212212222222122222112222212222222124244444442444442000000000011110000111100000
22221122221121221222222221221211222212222122121122221122221121221222222221221211222212444422424424444001111000000000000000000001
22211112222222122111111112212222222111111221222222211112222222122111111112212222222112244444442442222010000100000000000000000010
21121121122221222212112122221222211211212222122221121121122221222212112122221222211212422444424444242010000100000000000000000010
12212212212111212221111222121112122121122212111212212212212111212221111222121112122124244242224244422001111000011110000111100001
12121121212221121121111211211222121211121121122212121121212221121121111211211222121212424244422422422000000000100001001000010000
21211112121212122212112122212121212111212221212121211112121212122212112122212121212112242424242444242000000000100001001000010000
12111111212211211111111111121122121111111112112212111111212211211111111111121122121112224244224222222000000000011110000111100000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111112222222222222222000000000000000000000000000
22112211222222222121111212222222221121121222222222112211222222222121111212222222221124224444444442422000000000000000000000000000
11122221112222222122222212222222111222221222222211122221112222222122222212222222111224422244444442444000000000011110000111100000
21221122122222222122222212222222212212221222222221221122122222222122222212222222212212442444444442444000000000100001001000010000
21221122122221221122222211221222212212221122122221221122122221221122222211221222212212442444424422444000000000100001001000010000
12121121212112222212222122222112121212212222211212121121212112222212222122222112121212424242244444244001111000011110000111100001
22221122221222222221221222222221222212122222222122221122221222222221221222222221222212444424444444424010000100000000000000000010
22221122221222222221111222222221222211122222222122221122221222222221111222222221222212444424444444422010000100000000000000000010
22221122222122222221221222222212222212122222221222221122222122222221221222222212222212444442444444424001111000000000000000000001
12222222212212112222112222112122122221222211212212222222212212112222112222112122122224444244242244442000000000011110000111100000
21111111122122222221111222222212211111122222221221111111122122222221111222222212211112222442444444422000000000100001001000010000
22121121222212222112112112222122221211211222212222121121222212222112112112222122221212424444244442242000000000100001001000010000
22211112221211121221221221211121222112122121112122211112221211121221221221211121222112244424222424424001111000011110000111100001
11211112112112221212112121222112112111212122211211211112112112221212112121222112112112242242244424242010000100000000000000000010
22121121222121212121111212121212221211121212121222121121222121212121111212121212221212424442424242422010000100000000000000000010
11111111111211221211111121221121111111112122112111111111111211221211111121221121111112222224224424222001111000000000000000000001
11111111111111111111111111111111111111111111111111111111111111111111111111111111111112222222222222222000000000000000000000000000
47777777777747774422477777444777777777777777777777777777722222222121111212222222221124224444444442422224244444444422442244444444
47070700070747072224470707444700070007000770070007700770712222222122222212222222111224422244444442444444244444442224444222444444
47070770770747074244270707444707070777070707777077077770722222222122222212222222212212442444444442444444244444444244224424444444
27007770770727074244270007444700770077000700077077000770722221221122222211221222212212442444424422444444224424444244224424444244
47070770770777077724277707422707070777070777077077770777712112222212222122222112121212424242244444244442444442242424224242422444
47070700070007000744224707244700070007070700777077007770721222222221221222222221222212444424444444424424444444424444224444244444
47777777777777777744224777244777777777777777747777777177721222222221111222222221222212444424444444422224444444424444224444244444
44424424444444244444224444424444444242444442444444424122222122222221221222222212222212444442444444424424444444244444224444424444

__map__
2121212021212121212121212021242121202121212121212020202021212121242121212121212121212121212020202020212121202020202121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212021212122212121212021212121202121212121212021212021212121212121212121212121212121212121212120212121212121202121212120202100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121202020202020212121212021212121202121212121212021212021202121202020202121212121212121212121212121212121212121202121212120202100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202021212020212121212021212121202020212320202021212021202121212121202121212121212221212121212121212121212121202020202121242100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2124212121212020202020202021212121202121202021212121212021202121212121202020202020202020202021212121212121212121202121212021212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212021212021212021212020202021212021212121212022202121212121202121212121212121212021212120212121202021202122212021212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212021212021212021212121212021212021212121212020202020212020202121212120212121212021212120212120202121212020202021212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212021212221212021212122212021202121212121212021212121212121202321212020212121212021222120212320202121212121212021212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202020202020202020202020202021202121212121212021212120212121202020202021212121212020202020202021202121212121212021212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212021212421212121212021212021212121212021212121212021212120212321202121212121212121212121212120212121202021212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212021212121212121212021212021212121212021212121232021212120202020202120202021202020202021212120212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212021212020202020202021212020202121212020202020202021212124212121212120212121202020212021212120212121212121212020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212021212021212121212121212121202121212121212120212121212121212121212120212121212121212021212120212121232120202021212121242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212021212021212321212121212121202121212121212121212120212121212121212120212221202020232021212120212020202020212221212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212020202020202020202021212121212121212121212120212121212120202020202020202020202021212020202020202020202020202121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212120212121212021212121212221212121212120212121212121202120212121202421212121212121212121212124212121202121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2120202020202021212120212121212121212121202020202121212120202020212121202121212121202121212121212021212121212121212120202121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2120212121242021212120212221212121212121202020202121212120212121212121202121212121202121212020202021212121212121212120212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2120222121212021202020202020202020202020202020202121212020212121212121202121212121202121212120202122212121212121212120212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2120202020202021202121212121212021212124212121212121212021212121212121212121212121202121212120202020202021212121212120212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121202221212121212121212121212121212120202021212121202020212121212121202021212121212121212021212121212120212123212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121202020212121212121212121212121212121212022212121202020212121212121212020202020202021212021212121212120202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212020202121202020212121212121212121212121212121212020202020202020202020212121212121212121212121212021212121212120212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121202121202020212121202021212121212020202021212120212121242121212120212120202121212121212121212020202020202020212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121202121212121212121212121212021212021212120212121212121212120212121202121212121212121212121212421212120212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202121212121202121212121212121212121212022212021212120212121212121212120202021202020202020202020202021212121212120212122212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021242121212121202121212020202020202020202020212021212120212121212121212121212021212121212121212124212020212121212120202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212121212120202121212121212121212124212121212021212121212121212121212121212021212121212121212121212120212121232120202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212021212121212121212122212121212121212121212021212121212020212320202020202020212121212121212121212020212120202020212124212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212021212121212121202020202020212121212121212020202121212020202020212121212120202121212121212121212021212121212120212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212021212121212020202020202020202021212121212021202123212021212121212221212120202122212121212121212021212121212120212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202021202020202020202020202020202020202020202020202020202021212121212120212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000010000300005000070000a0000b0000e000100001300016000190001c0001f000210002500027000020000a000120001a000040000700013000180001c0001f0002200006000150001b0002200028000
