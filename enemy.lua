-- 
--  enemy.lua
--  RedditGameJam-05
--  
--  Created by Jay Roberts on 2011-01-07.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'class'
require 'vector'

Enemy = class(function(enemy, pos)
  
  -- Tileset
  enemy.tileset = love.graphics.newImage('resources/images/spritesheet.png')
  enemy.tileset:setFilter('nearest', 'nearest')

  enemy.tileSize = 16
  enemy.scale = 2
  enemy.offset = vector(enemy.tileSize / 2, enemy.tileSize / 2)

  -- Quads, animation frames
  enemy.animations = {}
  
  enemy.animations['standing'] = {}
  enemy.animations['standing'].frameInterval = 0.2
  enemy.animations['standing'].quads = {
    love.graphics.newQuad(6 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(7 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(4 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(5 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight())
  }
  
  enemy.animations['walking'] = {}
  enemy.animations['walking'].frameInterval = 0.2
  enemy.animations['walking'].quads = {
    love.graphics.newQuad(0 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(1 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(2 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(3 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
  }
  
  enemy.animation = {}
  enemy.animation.current = 'standing'
  enemy.animation.frame = 1
  enemy.animation.elapsed = 0
  
  -- Instance vars
  enemy.flip = 1
  enemy.position = pos
  enemy.speed = 110
  enemy.onground = true
  enemy.state = 'standing'
  enemy.movement = vector(0, 0) -- This holds a vector containing the last movement input recieved
  
  enemy.velocity = vector(0, 0)
  enemy.jumpVector = vector(0, -200)
end)

-- Call during update with a normalized movement vector
function Enemy:setMovement(movement)
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

function Enemy:setAnimation(animation)
  if (self.animation.current ~= animation) then
    self.animation.current = animation
    self.animation.frame = 1
  end
end

-- Returns the world coordinates of the Enemy's corners. If pos is supplied it returns what the Enemy's
-- coordinates would be at that position
function Enemy:getCorners(pos)
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

function Enemy:update(dt, level, target)
  self.animation.elapsed = self.animation.elapsed + dt
  
  -- Get movement
  self:setMovement(self:getAIMovement(target, level))
  
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

-- Takes a target point in the world and a level and calculates a movement vector
function Enemy:getAIMovement(target, level)
  if self.position:dist(target) < 100 then
    return vector(0, 0)
  else
    if self.position.x < target.x then
      return vector(1, 0)
    else
      return vector(-1, 0)
    end
  end
end
  
function Enemy:draw()
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

