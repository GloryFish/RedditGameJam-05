-- 
--  enemy.lua
--  RedditGameJam-05
--  
--  Created by Jay Roberts on 2011-01-07.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'class'
require 'vector'

Enemy = class(function(enemy, pos, prey)
  
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

  enemy.animations['frustrated'] = {}
  enemy.animations['frustrated'].frameInterval = 0.03
  enemy.animations['frustrated'].quads = {
    love.graphics.newQuad(6 * enemy.tileSize, 4 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(7 * enemy.tileSize, 4 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(4 * enemy.tileSize, 4 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(5 * enemy.tileSize, 4 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight())
  }
  
  enemy.animations['walking'] = {}
  enemy.animations['walking'].frameInterval = 0.2
  enemy.animations['walking'].quads = {
    love.graphics.newQuad(0 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(1 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(2 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(3 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
  }

  enemy.animations['climbing'] = {}
  enemy.animations['climbing'].frameInterval = 0.1
  enemy.animations['climbing'].quads = {
    love.graphics.newQuad(4 * enemy.tileSize, 3 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(5 * enemy.tileSize, 3 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
  }

  enemy.animations['bursting'] = {}
  enemy.animations['bursting'].frameInterval = 0.2
  enemy.animations['bursting'].quads = {
    love.graphics.newQuad(6 * enemy.tileSize, 5 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(7 * enemy.tileSize, 5 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(4 * enemy.tileSize, 5 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(5 * enemy.tileSize, 5 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight())
  }

  
  enemy.animation = {}
  enemy.animation.current = 'standing'
  enemy.animation.frame = 1
  enemy.animation.elapsed = 0
  
  -- Instance vars
  enemy.flip = 1
  enemy.position = pos
  enemy.startspeed = 115
  enemy.speed = 115
  enemy.onground = true
  enemy.state = 'standing'
  enemy.movement = vector(0, 0) -- This holds a vector containing the last movement input recieved
  
  enemy.velocity = vector(0, 0)
  enemy.jumpVector = vector(0, -200)
  
  enemy.path = nil
  enemy.pathInterval = 3 -- Wait 5 seconds before generating a new path
  enemy.pathDuration = 2 -- how long since last path generation
  
  enemy.bursting = false
  enemy.burstInterval = 3
  enemy.burstDuration = 0
  
end)

-- Call during update with a normalized movement vector
function Enemy:setMovement(movement)
  self.movement = movement
  self.velocity.x = movement.x * self.speed
  self.velocity.y = movement.y * self.speed
  
  if movement.x > 0 then
    self.flip = 1
  end

  if movement.x < 0 then
    self.flip = -1
  end
end

function Enemy:setAnimation(animation)
  if (self.animation.current ~= animation) then
    self.animation.current = animation
    self.animation.frame = 1
    
    if animation == 'frustrated' then
      self.speed = self.speed * 1.1
    end
  end
end

function Enemy:burst()
  if not self.bursting then
    self:setAnimation('bursting')
    self.bursting = true
    self.burstDuration = 0
    self.speed = self.startspeed
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
  self.pathDuration = self.pathDuration + dt
  
  if self.bursting then
    self.burstDuration = self.burstDuration + dt
    if self.burstDuration > self.burstInterval then
      self.burstDuration = 0
      self.bursting = false
    end
  end
  
  -- Get movement
  self:setMovement(self:getAIMovement(target, level))
  
  -- What animation?
  local selfTile = level:toTileCoords(self.position)
  selfTile = selfTile + vector(1, 1)
  
  if self.bursting then
    self:setAnimation('bursting')
  elseif level.tiles[selfTile.x][selfTile.y] == 'h' or level.tiles[selfTile.x][selfTile.y] == 'H' and self.movement.y ~= 0 then
    self:setAnimation('climbing')
  elseif self.movement.x == 0 then
    if self.path == nil then
      self:setAnimation('frustrated')
    else
      self:setAnimation('standing')
    end
  else
    self:setAnimation('walking')
  end 
  
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
  
  if not self.bursting then
    -- Apply velocity to position
    self.position = self.position + self.velocity * dt
  end
end

-- Takes a target entity in the world (typically the player) and the level and calculates a movement vector
function Enemy:getAIMovement(target, level)
  local selfTile = level:toTileCoords(self.position)
  local targetTile = level:toTileCoords(target.position)
  
  -- We can't fly so find the position of the floor under the target
  if not target.onground then
    local y = targetTile.y
    while y < #level.tiles[1] do -- Stop if we reach the bottom of the world
      if in_table(level.tiles[targetTile.x + 1][y + 1], level.solid) then
        targetTile.y = y - 1
        break
      end
      y = y + 1
    end
  end
  
  -- Now we have a target, get a path to it
  if self.pathDuration > self.pathInterval then
    self.pathDuration = 0
    self.path = astar:findPath(selfTile, targetTile)
  end
  
  -- If we have a path, follow it
  if self.path ~= nil then
    local node = self.path.nodes[1]
    
    if node ~= nil then
      if selfTile.x == node.location.x and selfTile.y == node.location.y then -- are we in the first node? REMOVE IT!
        table.remove(self.path.nodes, 1)
        node = self.path.nodes[1]
      end
    else -- we need a new path
      self.pathDuration = 3
    end
  
    if node ~= nil then
      local movement = vector(0, 0)
      
      -- Adjust position
      local nodeWorld = level:toWorldCoordsCenter(node.location)
      
      -- horizontal
      if math.abs(self.position.x - nodeWorld.x) > 1 then
        if self.position.x < nodeWorld.x then
          movement = movement + vector(1, 0)
        elseif self.position.x > nodeWorld.x then
          movement = movement + vector(-1, 0)
        end
      end
      
      -- vertical
      if math.abs(self.position.y - nodeWorld.y) > 1 then
        if self.position.y < nodeWorld.y then
          movement = movement + vector(0, 1)
        elseif self.position.y > nodeWorld.y then
          movement = movement + vector(0, -1)
        end
      end
    
      return movement
    else
       -- We're at the end of the path, stand still for now
      self.pathDuration = 3
      return vector(0, 0)
    end
    
  else -- No path
    return vector(0, 0) -- Just stand there
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

  if self.path ~= nil then
    self.path:draw(0, 0, 255)
  end
end

