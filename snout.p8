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
	message(_global.goal - _global.killed.." to go.")
	
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