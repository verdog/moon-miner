-- main loops and debug
function _init()
 debug_init()

	player = _player:new()
end

function start_level()
	vfx_init()
	enemies_init()
	proj_init()
 
 _global.map_target_feats = 12
	_global.map_spread = 36
 map_init() -- generates enemies and crystal too
	
	player.x = 0
	player.y = 0
 
 _global.killed = 0
	
	ui_init()
	
	message("find the crystal!")
end

function _update()
	debug(_global.goal)
	debug(_global.killed)
	if _global.state == "play" or _global.state == "dead" then
		map_update()
		proj_update()
		if _global.state != "dead" then
			player:update()
  end
		enemies_update()
  _global.crystal:update()
		vfx_update()
	end
	
	if _global.state == "play" or _global.state == "dead" then
		camera(player.x-64+shake.x,player.y-64+shake.y)
		_global.cam.x = peek2(0x5f28)
		_global.cam.y = peek2(0x5f2a)
	end
		
	if _global.state == "title" then
		title_update()
	end
	
	if _global.state == "play" or _global.state == "dead" then
		ui_update(player)
	end
end

function _draw()
	cls()
	if _global.state == "play" or _global.state == "dead" then
		map_draw(player.x,player.y)
		proj_draw()
		vfx_draw(-1)
		if _global.state != "dead" then
			player:draw()
		end
  enemies_draw()
  _global.crystal:draw()
		vfx_draw(1)
		ui_draw(player)
	end
	
	if _global.state == "title" then
		title_draw()
	end
	
	debug_draw()
	debug_clear()
end

-- debug system
function debug_init()
	debug_table = {}
	_debug = true
	menuitem(1,"toggle debug", function() _debug=not _debug end)
end

function debug(str, key)
	key = key or ""
	if key == "" then
		add(debug_table, str)
	else
		add(debug_table, key..": "..str)
	end
end

function debug_draw()
	local cam = _global.cam
	if _debug == true then
		for i=1,#debug_table do
			print(debug_table[i],cam.x,cam.y+6*i-6,7)
		end
	end
end

function debug_clear()
	debug_table = {}
	debug(stat(1), "∧")
	debug(stat(0), "░")
end