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
require 'camera'

game = Gamestate.new()
game.level = ''

function game.enter(self, pre)
  assert(game.level ~= '', 'game.level not set')
  
  game.logger = Logger(vector(40, 40))
  
  if input == nil then
    require 'input'
    input = Input()
  end
  

  lvl = Level(game.level)

  player = Player(lvl.playerStart)
  
  game.enemies = {}
  
  for i,enemyStart in ipairs(lvl.enemyStarts) do
    local enemy = Enemy(enemyStart)
    table.insert(game.enemies, enemy)
  end

  camera = Camera()
  camera.bounds = {
    top = 0,
    right = math.max(lvl:getWidth(), love.graphics.getWidth()),
    bottom = math.max(lvl:getHeight(), love.graphics.getHeight()),
    left = 0
  }
  camera.position = player.position
  camera:update(0)
  
  love.graphics.setBackgroundColor(255, 255, 255, 255)
  
  love.mouse.setVisible(true)
end

function game.update(self, dt)
  game.logger:update(dt)
  
  local mouse = vector(love.mouse.getX(), love.mouse.getY())
  local tile = lvl:toTileCoords(mouse)
  
  tile = tile + vector(1, 1)
  
  game.logger:addLine(string.format('World: %i, %i', mouse.x, mouse.y))
  game.logger:addLine(string.format('Tile: %i, %i', tile.x, tile.y))
  if player.onground then
    game.logger:addLine(string.format('State: %s', 'On Ground'))
  else
    game.logger:addLine(string.format('State: %s', 'Jumping'))
  end
  game.logger:addLine(string.format('Width: %i Height: %i', lvl:getWidth(), lvl:getHeight()))

  if (lvl:pointIsWalkable(mouse)) then
    game.logger:addLine(string.format('Walkable'))
  else
    game.logger:addLine(string.format('Wall'))
  end
  
  input:update(dt)
  
  if input.state.buttons.newpress.back then
    Gamestate.switch(menu)
  end

  -- Update enemies
  for i, enemy in ipairs(game.enemies) do
    enemy:update(dt, lvl, player.position)
  end

  -- Apply any controller movement to the player
  player:setMovement(input.state.movement)
  
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
  
  player.velocity = player.velocity + lvl.gravity * dt * gravityAmount -- Gravity
  
  if dt > 0.5 then
    player.velocity.y = 0
  end
  
  -- if temp == true then
  --   player.velocity = player.velocity + lvl.gravity * dt * gravityAmount -- Gravity
  -- else
  --   temp = true
  -- end
  
  local newPos = player.position + player.velocity * dt
  local curUL, curUR, curBL, curBR = player:getCorners()
  local newUL, newUR, newBL, newBR = player:getCorners(newPos)
  
  if player.velocity.y > 0 then -- Falling
    local testBL = vector(curBL.x, newBL.y)
    local testBR = vector(curBR.x, newBR.y)
    
    if lvl:pointIsWalkable(testBL) == false or lvl:pointIsWalkable(testBR) == false then -- Collide with bottom
      player:setFloorPosition(lvl:floorPosition(testBL))
      player.velocity.y = 0
      player.onground = true
    end
  end

  if player.velocity.y < 0 then -- Jumping
    local testUL = vector(curUL.x, newUL.y)
    local testUR = vector(curUR.x, newUR.y)

    if lvl:pointIsWalkable(testUL) == false or lvl:pointIsWalkable(testUR) == false then -- Collide with top
      player.velocity.y = 0
    end
  end
  
  newPos = player.position + player.velocity * dt
  curUL, curUR, curBL, curBR = player:getCorners()
  newUL, newUR, newBL, newBR = player:getCorners(newPos)
  
  if player.velocity.x > 0 then -- Collide with right side
    local testUR = vector(newUR.x, curUR.y)
    local testBR = vector(newBR.x, curBR.y - 1)

    if lvl:pointIsWalkable(testUR) == false or lvl:pointIsWalkable(testBR) == false then
      player.velocity.x = 0
    end
  end

  if player.velocity.x < 0 then -- Collide with left side
    local testUL = vector(newUL.x, curUL.y)
    local testBL = vector(newBL.x, curBL.y - 1)

    if lvl:pointIsWalkable(testUL) == false or lvl:pointIsWalkable(testBL) == false then
      player.velocity.x = 0
    end
  end
  
  -- Here we update the player, the final velocity will be applied here
  player:update(dt)
  
  camera.focus = player.position
  camera:update(dt)


end

function game.draw(self)
  love.graphics.push()

  -- Game
  love.graphics.translate(-camera.offset.x, -camera.offset.y)
  lvl:draw()
  
  -- Update enemies
  for i, enemy in ipairs(game.enemies) do
    enemy:draw()
  end
  
  player:draw()

  love.graphics.pop()

  -- UI
  love.graphics.translate(0, 0)  
  game.logger:draw()
end

function game.leave(self)
end