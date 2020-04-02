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