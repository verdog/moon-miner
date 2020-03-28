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