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
	message(_global.goal - _global.killed.." to go.")
	
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

 rect(self.x,self.y,self.x+self.width-1,self.y+self.height-1,9)
end