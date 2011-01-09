-- 
--  scene_game.lua
--  redditgamejam-05
--  
--  Created by Jay Roberts on 2011-01-06.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'logger'
require 'vector'
require 'controller_manager'
require 'level'
require 'player'
require 'enemy'
require 'heartburst'
require 'resolve'
require 'pickup'
require 'floating_text'
require 'astar'
require 'camera'
require 'scene_gameover'

game = Gamestate.new()
game.level = ''

function game.enter(self, pre)
  assert(game.level ~= '', 'game.level not set')
  
  game.heartoverlay = love.graphics.newImage('resources/images/heart.png')
  game.heartoverlay:setFilter('nearest', 'nearest')
  
  game.logger = Logger(vector(40, 40))
  
  if input == nil then
    require 'input'
    input = Input()
  end
  

  level = Level(game.level)

  player = Player(level.playerStart)
  
  game.enemies = {}
  
  for i,enemyStart in ipairs(level.enemyStarts) do
    local enemy = Enemy(enemyStart, player)
    table.insert(game.enemies, enemy)
  end
  
  game.heartburst = HeartBurst()

  camera = Camera()
  camera.bounds = {
    top = 0,
    right = math.max(level:getWidth(), love.graphics.getWidth()),
    bottom = math.max(level:getHeight(), love.graphics.getHeight()),
    left = 0
  }
  camera.position = player.position
  camera:update(0)
  
  astar = AStar(level)
  
  game.pickup = Pickup(vector(0, 0))
  self:spawnRandomPickup()
  
  game.resolve = Resolve(vector(10, 580))
  game.floatingtext = FloatingText()
  
  game.score = 0
  
  love.graphics.setBackgroundColor(255, 255, 255, 255)
  
  love.mouse.setVisible(true)
  
  path = nil
  
  pathMessage = 'No search'
  
  music.game:setVolume(0.5)
  love.audio.play(music.game)
  
  game.dying = false
  game.dyingInterval = 3
  game.dyingDuration = 0
  
  player.resolve = 0.01
  game.score = 500
end

function game.mousereleased(self, x, y, button)
  if debug then
    local mouseWorldPoint = vector(x, y) + camera.offset

    local mouseTilePoint = level:toTileCoords(mouseWorldPoint)

    local playerTilePoint = level:toTileCoords(player.position)

    path = astar:findPath(mouseTilePoint, playerTilePoint)

    if path == nil then
      pathMessage = string.format('No path from %s to %s', tostring(mouseTilePoint), tostring(playerTilePoint))
    else
      pathMessage = "Path found"
    end    
  end
end

function game.spawnRandomPickup(self)
  game.pickup.position = level.pickupSpawns[math.random(#level.pickupSpawns)]
end

function game.startDying()
  if not game.dying then
    game.dying = true
    game.heartoverlaypos = player.position
  end
end

function game.update(self, dt)
  if debug then
    game.logger:update(dt)

    local mouse = vector(love.mouse.getX(), love.mouse.getY()) + camera.offset
    local tile = level:toTileCoords(mouse)
    local tileString = 'air'

    tile = tile + vector(1, 1)
  
    if level.tiles[tile.x] then
      tileString = level.tiles[tile.x][tile.y]
  
      if tileString == nil or tileString == ' ' then
        tileString = 'air'
      end
    end
  
  
    game.logger:addLine(string.format('World: %i, %i', mouse.x, mouse.y))
    game.logger:addLine(string.format('Tile: %i, %i, %s', tile.x, tile.y, tileString))
    if player.onground then
      game.logger:addLine(string.format('State: %s', 'On Ground'))
    else
      game.logger:addLine(string.format('State: %s', 'Jumping'))
    end
    game.logger:addLine(string.format('Width: %i Height: %i', level:getWidth(), level:getHeight()))

    if (level:pointIsWalkable(mouse)) then
      game.logger:addLine(string.format('Walkable'))
    else
      game.logger:addLine(string.format('Wall'))
    end
  
    game.logger:addLine(pathMessage)
  end
  
  if game.dying then
    game.dyingDuration = game.dyingDuration + dt
    if game.dyingDuration > game.dyingInterval then
      gameover.finalscore = game.score
      love.audio.stop(music.game)
      Gamestate.switch(gameover)
    end
  end
  
  input:update(dt)

  -- Update enemies
  for i, enemy in ipairs(game.enemies) do
    enemy:update(dt, level, player)
    
    if player.position:dist(enemy.position) < 32 and not game.dying then
      game.heartburst:burst(player.position, math.random(3, 5))
      enemy:burst()
      player:burst()
      
      if player.resolve < 0 then
        game:startDying()
      end
    end
  end

  -- Update pickup
  game.pickup:update(dt)
  if player.position:dist(game.pickup.position) < 16 then
    game.pickup:get()
    local color = {
      r = 0,
      g = 255,
      b = 0,
      a = 255
    }
    game.floatingtext:addText("+10", game.pickup.position - vector(0, 16), color, 3)
    game.score = game.score + 10
    self:spawnRandomPickup()
  end

  game.heartburst:update(dt)

  -- Apply any controller movement to the player
  if not game.dying then
    player:setMovement(input.state.movement)
  else
    player:setMovement(vector(0, 0))
  end
  
  if input.state.buttons.newpress.jump then
    if player.onground then
      player:jump()
    end
  end
  
  -- Apply gravity
  local gravityAmount = 1
  
  if input.state.buttons.jump and player.velocity.y < 0 then
    gravityAmount = 0.5
  end
  
  player.velocity = player.velocity + level.gravity * dt * gravityAmount -- Gravity
  
  if dt > 0.5 then
    player.velocity.y = 0
  end
  
  local newPos = player.position + player.velocity * dt
  local curUL, curUR, curBL, curBR = player:getCorners()
  local newUL, newUR, newBL, newBR = player:getCorners(newPos)
  
  if player.velocity.y > 0 then -- Falling
    local testBL = vector(curBL.x, newBL.y)
    local testBR = vector(curBR.x, newBR.y)
    
    if level:pointIsWalkable(testBL) == false or level:pointIsWalkable(testBR) == false then -- Collide with bottom
      player:setFloorPosition(level:floorPosition(testBL))
      player.velocity.y = 0
      player.onground = true
    end
  end

  if player.velocity.y < 0 then -- Jumping
    local testUL = vector(curUL.x, newUL.y)
    local testUR = vector(curUR.x, newUR.y)

    if level:pointIsWalkable(testUL) == false or level:pointIsWalkable(testUR) == false then -- Collide with top
      player.velocity.y = 0
    end
  end
  
  newPos = player.position + player.velocity * dt
  curUL, curUR, curBL, curBR = player:getCorners()
  newUL, newUR, newBL, newBR = player:getCorners(newPos)
  
  if player.velocity.x > 0 then -- Collide with right side
    local testUR = vector(newUR.x, curUR.y)
    local testBR = vector(newBR.x, curBR.y - 1)

    if level:pointIsWalkable(testUR) == false or level:pointIsWalkable(testBR) == false then
      player.velocity.x = 0
    end
  end

  if player.velocity.x < 0 then -- Collide with left side
    local testUL = vector(newUL.x, curUL.y)
    local testBL = vector(newBL.x, curBL.y - 1)

    if level:pointIsWalkable(testUL) == false or level:pointIsWalkable(testBL) == false then
      player.velocity.x = 0
    end
  end
  
  
  -- Here we update the player, the final velocity will be applied here
  player:update(dt)
  
  game.resolve.currentamount = player.resolve
  game.resolve:update(dt)
  
  game.floatingtext:update(dt)
  
  camera.focus = player.position
  camera:update(dt)
end

function game.draw(self)
  love.graphics.push()

  -- Game
  love.graphics.translate(-camera.offset.x, -camera.offset.y)
  level:draw()
  
  -- Draw pickups
  game.pickup:draw()

  -- Draw enemies
  for i, enemy in ipairs(game.enemies) do
    enemy:draw()
  end
  
  player:draw()

  game.heartburst:draw()

  game.floatingtext:draw()

  if path ~= nil and debug then
    path:draw(255, 0, 0)
  end

  if game.dying then
    local deathAmount = (game.dyingDuration / game.dyingInterval)
    local scale = 200 * deathAmount
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(game.heartoverlay, game.heartoverlaypos.x, game.heartoverlaypos.y, 0, scale, scale, 8, 8)
  end

  love.graphics.pop()

  -- UI
  love.graphics.translate(0, 0)  
  
  if debug then
    game.logger:draw()
  end

  game.resolve:draw()

  -- Print score
  love.graphics.setColor(0, 0, 0, 255)
  local score = string.format("%i", game.score)
  local scoreWidth = fonts.default:getWidth(score)
  
  love.graphics.print(score, 
                      love.graphics.getWidth() / 2 - scoreWidth, 
                      love.graphics.getHeight() - 24);
end

function game.leave(self)
end