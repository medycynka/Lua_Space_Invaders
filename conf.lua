function love.conf(t)
	t.modules.joystick = false
	t.modules.audio = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.image = true
	t.modules.graphics = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = true
	t.modules.thread = false
	t.modules.physics = false
	
	t.title = "Asteroid"
	t.author = "Szymon Peszek"
end