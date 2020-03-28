-- ui
function ui_init()
	messq = {}
	messt = 0
end

function message(m)
	add(messq, m)
	messt = 0
end

function ui_update(p)
	messt += 1
	
	if messt%120 == 0 then
		del(messq, messq[1])
	end
end

function ui_draw(p)
	-- message q
	-- bouncy first message
	if #messq > 0 then
		local xo = 8 * abs(sin(t()/2))^2
		for j=-1,1 do
			for k=-1,1 do
				print(messq[1],_global.cam.x+2+j+xo,_global.cam.y+133-6-6+k,7)
			end
		end
		print(messq[1],_global.cam.x+2+xo,_global.cam.y+133-6-6,0)
	end
	
	for i=2,#messq do
		for j=-1,1 do
			for k=-1,1 do
				print(messq[i],_global.cam.x+2+j,_global.cam.y+133-6*i-6+k,7)
			end
		end
		print(messq[i],_global.cam.x+2,_global.cam.y+133-6*i-6,0)
	end

	-- health
	local hx = 8
	local hy = 8
	local hunit = 3
	for i=0,p.hp-1 do
		line(
			_global.cam.x+hx+i*hunit,
			_global.cam.y+hy,
			_global.cam.x+hx+i*hunit+hunit,
			_global.cam.y+hy,
			14
		)
	end

	-- fuel gauge
	local fuelx = 8
	local fuely = 11
	local lineunit = 1
	for i=0,p.fuel-1 do
		line(
			_global.cam.x+fuelx+i*lineunit,
			_global.cam.y+fuely,
			_global.cam.x+fuelx+i*lineunit+lineunit,
			_global.cam.y+fuely,
			12
		)
	end
	
	local pickx
	local picky
	
	-- pickaxe gauge
	if p.weapon == 0 and p.hp > 0 then
		pickx = 58
		picky = 60
	else
		pickx = 8
		picky = 14
	end
	
	local lineunit = 2
	for i=0,p.pickaxe-1 do
		line(
			_global.cam.x+pickx+i*lineunit,
			_global.cam.y+picky,
			_global.cam.x+pickx+i*lineunit+lineunit,
			_global.cam.y+picky,
			9
		)
	end
	
	-- ammo
	local ammox
	local ammoy
	local ammodir = 1
	local lineunit = 1
	
	if p.weapon == 1 then
		ammox = 58
		ammoy = 60
		ammodir = -2
	else
		ammox = 8
		ammoy = 14
		ammodir = 2
	end
	
	if p.ammo == 0 then
		print("empty!",
			_global.cam.x+ammox,
			_global.cam.y+ammoy,
			8)
	end
	
	for i=0,p.ammo-1 do
		line(
			_global.cam.x+ammox+(i*lineunit)%20,
			_global.cam.y+ammoy+flr(i/20)*ammodir,
			_global.cam.x+ammox+(i*lineunit)%20+lineunit,
			_global.cam.y+ammoy+flr(i/20)*ammodir,
			8
		)
	end
	
end

function title_update()
	if btnp(❎) then
		_global.state = "play"
		start_level()
	end
end

function title_draw()
	print("it's the title screen.",0,0)
end