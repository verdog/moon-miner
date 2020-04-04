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