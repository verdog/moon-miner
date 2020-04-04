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
 self.state = "dead"
	message("you're dead.")
end

function _player:add_ammo(n)
	self.ammo += n
end