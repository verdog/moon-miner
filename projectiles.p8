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