-- 
--  level.lua
--  redditgamejam-05
--  
--  Created by Jay Roberts on 2011-01-02.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'class'
require 'vector'
require 'utility'
require 'astar'

Level = class(function(level, name)
  level.scale = 2
  
  -- Load a map file which will give us a tileset image, 
  -- a set of quads for each image in the tileset indexed by
  -- an ascii character, a string representing the initial level layout,
  -- and the size of each tile in the tileset.
  level.tileset, level.quads, level.tileString, level.tileSize, level.gravity, level.solid = love.filesystem.load(string.format('resources/maps/%s.lua', name))()

  -- Now we build an array of characters from the tileString
  level.tiles = {}
  level.enemyStarts = {}
  
  local width = #(level.tileString:match("[^\n]+"))

  for x = 1, width, 1 do 
    level.tiles[x] = {} 
  end

  local x, y = 1, 1

  for row in level.tileString:gmatch("[^\n]+") do
    assert(#row == width, 'Map is not aligned: width of row ' .. tostring(y) .. ' should be ' .. tostring(width) .. ', but it is ' .. tostring(#row))
    x = 1
    for character in row:gmatch(".") do
      
      -- Handle player start
      if character == 'P' then
        level:setPlayerStart(x, y)
        level.tiles[x][y] = ' '
      elseif character == 'E' then
        level:addEnemyStart(x, y)
        level.tiles[x][y] = ' '
      else  
        level.tiles[x][y] = character
      end
      x = x + 1
    end
    y = y + 1
  end
end)

function Level:setPlayerStart(x, y)
  -- playerStart should be placed in the center of the tile so we need to offset the world coordinates by half tileSize
  local coords = self:toWorldCoords(vector(x, y))
  self.playerStart = coords + vector(math.floor(self.tileSize * self.scale / 2), math.floor(self.tileSize * self.scale / 2))
end

function Level:addEnemyStart(x, y)
  local coords = self:toWorldCoords(vector(x, y))
  table.insert(self.enemyStarts, coords + vector(math.floor(self.tileSize * self.scale / 2), math.floor(self.tileSize * self.scale / 2)))
end

function Level:draw()
  love.graphics.setColor(255, 255, 255, 255)
  for x, column in ipairs(self.tiles) do
    for y, char in ipairs(column) do
      love.graphics.drawq(self.tileset,
                          self.quads[char], 
                          (x - 1) * self.tileSize * self.scale, 
                          (y - 1) * self.tileSize * self.scale,
                          0,
                          self.scale,
                          self.scale)
    end
  end
end

function Level:getWidth()
  return #self.tiles * self.tileSize * self.scale
end

function Level:getHeight()
  return #self.tiles[1] * self.tileSize * self.scale
end

function Level:pointIsWalkable(point)
  local tilePoint = self:toTileCoords(point)
  tilePoint = tilePoint + vector(1, 1)
  
  if self.tiles[tilePoint.x] ~= nil then
    return not in_table(self.tiles[tilePoint.x][tilePoint.y], self.solid)
  end
  
  return true
end

function Level:tilePointIsWalkable(tilePoint)
  tilePoint = tilePoint + vector(1, 1)
  
  if self.tiles[tilePoint.x] ~= nil then
    return not in_table(self.tiles[tilePoint.x][tilePoint.y], self.solid)
  end
  
  return true
end

function Level:tilePointIsWalkableByEnemy(tilePoint)
  tilePoint = tilePoint + vector(1, 1)
  
  if self.tiles[tilePoint.x] ~= nil then
    local tile = self.tiles[tilePoint.x][tilePoint.y]
    
    -- Check for solid
    local solid = {
      '#',
      ']',
      '[',
      '_',
    }
    if in_table(tile, solid) then
      return false
    end
    
    -- is it a ladder?
    if tile == 'h' or tile == 'H' then
      return true
    else
      -- Ensure that there is a solid tile or a ladder directly below
      local tileBelow = self.tiles[tilePoint.x][tilePoint.y + 1]
      if in_table(tileBelow, solid) or tileBelow == 'h' then
        return true
      else
        return false
      end
    end
  end
  
  return true
end



-- This function takes a world point returns the Y position of the top edge of the matching tile in world space
function Level:floorPosition(point)
  local y = math.floor(point.y / (self.tileSize * self.scale))
  
  return y * (self.tileSize * self.scale)
end


function Level:toWorldCoords(point)
  local world = vector(
    (point.x - 1) * self.tileSize * self.scale,
    (point.y - 1) * self.tileSize * self.scale
  )
  
  return world
end

function Level:toWorldCoordsCenter(point)
  local world = vector(
    point.x * self.tileSize * self.scale,
    point.y * self.tileSize * self.scale
  )
  
  world = world + vector(self.tileSize * self.scale / 2, self.tileSize * self.scale / 2)
  
  return world
end


function Level:toTileCoords(point)
  local coords = vector(math.floor(point.x / (self.tileSize * self.scale)),
                        math.floor(point.y / (self.tileSize * self.scale)))

  return coords
end


-- SQ_MapHandler methods

function Level:getNode(location)
  -- ensure location is in map
  if location.x < 0 or location.y < 0 then
    assert(false, 'node out of map on top or left')
    return nil
  end
  
  if location.x > #self.tiles or location.y > #self.tiles[1] then
    assert(false, 'node out of map on right or bottom')
    return nil
  end
  
  
  -- ensure location is walkable
  if not self:tilePointIsWalkableByEnemy(location) then
    return nil
  end
  
  return Node(location:clone(), 10, location.y * #self.tiles + location.x)
end


function Level:getAdjacentNodes(curnode, dest)
  local result = {}
  local cl = curnode.location
  local dl = dest
  
  local n = false
  
  n = self:_handleNode(cl.x + 1, cl.y, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x - 1, cl.y, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x, cl.y + 1, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x, cl.y - 1, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end
  
  return result
end

function Level:_handleNode(x, y, fromnode, destx, desty)
  local n = self:getNode(vector(x, y))
  
  if n ~= nil then
    local dx = math.max(x, destx) - math.min(x, destx)
    local dy = math.max(y, desty) - math.min(y, desty)
    local emCost = dx + dy
    
    n.mCost = n.mCost + fromnode.mCost
    n.score = n.mCost + emCost
    n.parent = fromnode
    
    return n
  end
  
  return nil
end

