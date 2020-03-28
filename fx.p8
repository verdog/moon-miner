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