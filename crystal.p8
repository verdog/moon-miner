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
