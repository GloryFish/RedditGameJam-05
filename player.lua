-- 
--  player.lua
--  redditgamejam-05
--  
--  Created by Jay Roberts on 2010-12-10.
--  Copyright 2010 GloryFish.org. All rights reserved.
-- 

require 'class'
require 'vector'

Player = class(function(player, pos)

  -- Sounds
  player.sounds = {
    jump = love.audio.newSource('resources/sounds/jump.mp3', 'static'),
  } 

  -- Tileset
  player.tileset = love.graphics.newImage('resources/images/spritesheet.png')
  player.tileset:setFilter('nearest', 'nearest')

  player.tileSize = 16
  player.scale = 2
  player.offset = vector(player.tileSize / 2, player.tileSize / 2)

  -- Quads, animation frames
  player.animations = {}
  
  player.animations['standing'] = {}
  player.animations['standing'].frameInterval = 0.2
  player.animations['standing'].quads = {
    love.graphics.newQuad(4 * player.tileSize, 0, player.tileSize, player.tileSize, player.tileset:getWidth(), player.tileset:getHeight()),
    love.graphics.newQuad(5 * player.tileSize, 0, player.tileSize, player.tileSize, player.tileset:getWidth(), player.tileset:getHeight()),
    love.graphics.newQuad(6 * player.tileSize, 0, player.tileSize, player.tileSize, player.tileset:getWidth(), player.tileset:getHeight()),
    love.graphics.newQuad(7 * player.tileSize, 0, player.tileSize, player.tileSize, player.tileset:getWidth(), player.tileset:getHeight())
  }
  
  player.animations['jumping'] = {}
  player.animations['jumping'].quads = {
    love.graphics.newQuad(0 * player.tileSize, 1 * player.tileSize, player.tileSize, player.tileSize, player.tileset:getWidth(), player.tileset:getHeight())
  }

  player.animations['walking'] = {}
  player.animations['walking'].frameInterval = 0.2
  player.animations['walking'].quads = {
    love.graphics.newQuad(0 * player.tileSize, 0 * player.tileSize, player.tileSize, player.tileSize, player.tileset:getWidth(), player.tileset:getHeight()),
    love.graphics.newQuad(1 * player.tileSize, 0 * player.tileSize, player.tileSize, player.tileSize, player.tileset:getWidth(), player.tileset:getHeight()),
    love.graphics.newQuad(2 * player.tileSize, 0 * player.tileSize, player.tileSize, player.tileSize, player.tileset:getWidth(), player.tileset:getHeight()),
    love.graphics.newQuad(3 * player.tileSize, 0 * player.tileSize, player.tileSize, player.tileSize, player.tileset:getWidth(), player.tileset:getHeight()),
  }
  
  player.animation = {}
  player.animation.current = 'standing'
  player.animation.frame = 1
  player.animation.elapsed = 0
  
  -- Instance vars
  player.flip = 1
  player.position = pos
  player.speed = 100
  player.onground = true
  player.onwall = false
  player.state = 'standing'
  player.movement = vector(0, 0) -- This holds a vector containing the last movement input recieved
  
  player.velocity = vector(0, 0)
  player.jumpVector = vector(0, -200)
end)

-- Call during update with the joystick vector
function Player:setMovement(movement)
  self.movement = movement
  self.velocity.x = movement.x * self.speed
  
  if movement.x > 0 then
    self.flip = 1
  end

  if movement.x < 0 then
    self.flip = -1
  end

  if self.onground then
    if movement.x == 0 then
      self:setAnimation('standing')
    else
      self:setAnimation('walking')
    end    
  end
end

-- Adjusts the player's y position so that it is standing on the floor value
function Player:setFloorPosition(floor)
  self.position.y = floor - self.tileSize / 2 * self.scale
end

function Player:jump()
  self.velocity = self.velocity + self.jumpVector
  self.onground = false
  self:setAnimation('jumping')
  love.audio.play(self.sounds.jump)
end

function Player:wallslide()
  self.onwall = true
  self:setAnimation('wallsliding')
end

function Player:land()
  self.onground = true
  self.onwall = false
  self:setAnimation('standing')
  love.audio.play(self.sounds.land)
end

-- TODO: Fix state code, make sure proper state transitions are maintained
-- make sure there is running, jumping, falling with correct changing between them
function Player:setAnimation(animation)
  if (self.animation.current ~= animation) then
    self.animation.current = animation
    self.animation.frame = 1
  end
end

-- Returns the world coordinates of the Player's corners. If pos is supplied it returns what the Player's
-- coordinates would be at that position
function Player:getCorners(pos)
  if pos == nil then
    pos = self.position
  end
  
  local margin = 4
  
  local ul, ur, bl, br = vector(math.floor(pos.x - (self.tileSize / 2 * self.scale)), math.floor(pos.y - (self.tileSize / 2 * self.scale))), -- UL
                         vector(math.floor(pos.x + (self.tileSize / 2 * self.scale)), math.floor(pos.y - (self.tileSize / 2 * self.scale))), -- UR
                         vector(math.floor(pos.x - (self.tileSize / 2 * self.scale)), math.floor(pos.y + (self.tileSize / 2 * self.scale))), -- BL
                         vector(math.floor(pos.x + (self.tileSize / 2 * self.scale)), math.floor(pos.y + (self.tileSize / 2 * self.scale))) -- BR

  -- Make the width just a bt smaller cause our ninja is skinny
  ul.x = ul.x + margin
  ur.x = ur.x - margin
  bl.x = bl.x + margin
  br.x = br.x - margin
  
  return ul, ur, bl, br
  
end

function Player:update(dt)
  self.animation.elapsed = self.animation.elapsed + dt
  
  -- Handle animation
  if #self.animations[self.animation.current].quads > 1 then -- More than one frame
    local interval = self.animations[self.animation.current].frameInterval
    interval = interval + (interval - (interval * math.abs(self.movement.x)))
    
    if self.animation.elapsed > interval then -- Switch to next frame
      self.animation.frame = self.animation.frame + 1
      if self.animation.frame > #self.animations[self.animation.current].quads then -- Aaaand back around
        self.animation.frame = 1
      end
      self.animation.elapsed = 0
    end
  end
  
  -- Apply velocity to position
  self.position = self.position + self.velocity * dt
end
  
function Player:draw()
  love.graphics.setColor(255, 255, 255, 255)
  
  love.graphics.drawq(self.tileset,
                      self.animations[self.animation.current].quads[self.animation.frame], 
                      self.position.x, 
                      self.position.y,
                      0,
                      self.scale * self.flip,
                      self.scale,
                      self.offset.x,
                      self.offset.y)
end