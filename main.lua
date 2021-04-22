love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setNewFont(64)

enemies_controller = { }
enemies_controller.enemies = { }
enemies_controller.image = love.graphics.newImage("img/enemy.png")
 
function checkCollisions(enemies, player)
	for i,e in ipairs(enemies) do
		if e.y + e.height >= player.y and e.x + e.width >= player.x and e.x <= player.x + 12 then
			love.audio.play(player.death_sound)
			game_over = true
		end

		for ib,b in pairs(player.bullets) do
			if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
				love.audio.play(enemy_death_sound)
				table.remove(enemies, i)
				table.remove(player.bullets, ib)
			end
		end
	end
end

function love.load()
	game_over = false
	game_win = false
	
	background_image = love.graphics.newImage('img/background.png')
	background_sound = love.audio.newSource('sounds/loopmusic.mp3', 'stream')
	love.audio.play(background_sound)
	
	player = { }
	player.x = 0
	player.y = 110
	player.speed = 50
	player.image = love.graphics.newImage('img/player.png')
	player.fire_sound = love.audio.newSource("sounds/laser_shoot.wav", 'static')
	player.death_sound = love.audio.newSource("sounds/player_dead.wav", 'static')
	enemy_death_sound = love.audio.newSource("sounds/enemy_dead.wav", 'static')
	player.bullets = {}
	player.cooldown = 0
	player.fire = function()
		if player.cooldown <= 0 then
			love.audio.play(player.fire_sound)
			player.cooldown = 0.4
			bullet = { }
			bullet.x = player.x + 3
			bullet.y = player.y - 1
			table.insert(player.bullets, bullet)
		end
	end
	
	wave = 0
	nextWave()
end

function restart()
	game_over = false
	game_win = false
	enemies_controller.enemies = { }
	player.bullets = {}
	player.x = 0
	player.y = 110
	wave = 0
	nextWave()
end

function nextWave()
	wave = wave + 1
	
	local se = enemies_controller
	
	if wave == 1 then
		for i = 1, 8 do
			se:spawnEnemy((i-1)*20+5, 0)
		end
	elseif wave == 2 then
		for i = 1, 6 do
			se:spawnEnemy((i-1)*28+5, 0 - 30)
		end
		for i = 1, 5 do
			se:spawnEnemy((i-1)*28+5+28/2, 20 - 30)
		end
	elseif wave == 3 then
		for i = 1, 13 do
			if i <= 7 then
				se:spawnEnemy((i-1)*12+4, i*5 - 50)
			else
				se:spawnEnemy((i-1)*12+4, 35-(i-7)*5 - 50)
			end
		end
	else
		game_win = true
	end
end

function enemies_controller:spawnEnemy(x, y)
	enemy = {}
	enemy.x = x
	enemy.y = y
	enemy.width = 12
	enemy.height = 10
	enemy.bullets = { }
	enemy.cooldown = 20
	enemy.speed = 6
	enemy.fire = function()
		if self.cooldown <= 0 then
			self.cooldown = 1
			bullet = { }
			bullet.x = self.x + 7
			bullet.y = self.y
			table.insert(self.bullets, bullet)
		end
	end
	table.insert(self.enemies, enemy)
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(background_image, 0, 0, 0, 5)
	
	if game_over then
		love.graphics.setColor(20, 20, 20)
		love.graphics.printf("You Lose!", 0, 600/2-80, 800, "center")
		love.graphics.printf("press r to restart", 0, 600/2, 800/0.5, "center", 0, 0.5)
	elseif game_win then
		love.graphics.setColor(20, 20, 20)
		love.graphics.printf("You Win!", 0, 600/2-80, 800, "center")
		love.graphics.printf("press r to restart", 0, 600/2, 800/0.5, "center", 0, 0.5)
	end
	
	if not game_over and not game_win then
		love.graphics.scale(5)
		love.graphics.setColor(11, 31, 255)
		love.graphics.draw(player.image, player.x, player.y, 0, 1)
		love.graphics.setColor(255, 255, 255)
		for _,e in pairs(enemies_controller.enemies) do
			love.graphics.draw(enemies_controller.image, e.x, e.y, 0, 1)
		end

		love.graphics.setColor(255, 255, 255)
		for _,b in pairs(player.bullets) do 
			love.graphics.rectangle("fill", b.x, b.y, 3 , 3)
		end
	end
end

function love.update(dt)
	if not game_over then	
		player.cooldown = player.cooldown - dt
		if love.keyboard.isDown("right") then
			player.x = player.x + player.speed * dt
		elseif love.keyboard.isDown("left") then
			player.x = player.x - player.speed * dt
		end

		if player.x >= 150 then
			player.x = 150
		end
		if player.x <= 0 then
			player.x = 0
		end
		
		if love.keyboard.isDown("space") then
			player.fire()
		end

		if #enemies_controller.enemies == 0 then
			nextWave()
		end

		for _,e in pairs(enemies_controller.enemies) do
			if e.y >= love.graphics.getHeight()/5 then
				love.audio.play(player.death_sound)
				game_over = true
			end
			e.y = e.y + e.speed * dt
		end

		for i, b in pairs(player.bullets) do
			if b.y < -10 then
				table.remove(player.bullets, i)
			end
			b.y = b.y - 120 * dt
		end
		
		checkCollisions(enemies_controller.enemies, player)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if game_over or game_win and key == "r" then
		restart()
	end
end