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

function place_crystal(x, y)
 if _global.crystal == nil then
  _global.crystal = _crystal:new()
 end

 _global.crystal.x = x
 _global.crystal.y = y
end

function _crystal:update()

 if self.state == "float" then
  self.fxchance = 2
  if not player.invuln and self:collides(player) then
   self.state = "follow"
   message("now get out!")
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

  debug(#self.posbuffer)
  debug(self.posp)
 end

 -- emit blood
 -- blood crystal.
 if rnd(100) < self.fxchance then
  vfx_p_blood(self.x+4, self.y+4, .5, 30, 8, 2)
 end

 self:env_physics()
	self:move(self.xvel, self.yvel)
end

function _crystal:draw()
 spr(self.sprite, self.x-4, self.y-4 + 4*sin(t()), 2, 2, flipx)
end
