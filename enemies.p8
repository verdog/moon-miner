function enemies_init()
	enemies = {}
end

function enemies_update()
	for e in all(enemies) do
		e:update()
	end
	debug(#enemies)
end

function enemies_draw()
	for e in all(enemies) do
		e:draw()
	end
end