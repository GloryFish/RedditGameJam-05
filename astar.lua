-- 
--  astar.lua
--  RedditGameJam-05
--  
--  Based on John Eriksson's Python A* implementation.
--  http://www.pygame.org/project-AStar-195-.html
--
--  Created by Jay Roberts on 2011-01-08.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'class'
require 'vector'
require 'utility'


Path = class(function(path, nodes, totalCost)
  path.nodes = nodes
  path.totalCost = totalCost
end)

function Path:getNodes()
  return self.nodes
end

function Path:getTotalMoveCost()
  return self.totalCost
end

function Path:draw()
  local tileSize = 16
  local scale = 2
  
  love.graphics.setColor(255, 0, 0, 200)
  
  for i, node in ipairs(self.nodes) do
    love.graphics.rectangle('fill', node.location.x * tileSize * scale, node.location.y * tileSize * scale, tileSize * scale, tileSize * scale)
  end
end

Node = class(function(node, location, mCost, lid, parent)
  node.location = location -- Where is the node located
  node.mCost = mCost -- Total move cost to reach this node
  node.parent = parent -- Parent node
  node.score = 0 -- Calculated score for this node
  node.lid = lid -- set the location id - unique for each location in the map
end)

function Node.__eq(a, b)
  return a.lid == b.lid
end


AStar = class(function(astar, maphandler) 
  astar.mh = maphandler
end)

function AStar:_getBestOpenNode()
  local bestNode = nil
  
  for i, n in ipairs(self.on) do
    if bestNode == nil then
      bestNode = n
    else
      if n.score <= bestNode.score then
        bestNode = n
      end
    end
  end
  
  return bestNode
end

function AStar:_tracePath(n)
  local nodes = {}
  local totalCost = n.mCost
  local p = n.parent
  
  table.insert(nodes, 1, n)
  
  while true do
    if p.parent == nil then
      break
    end
    table.insert(nodes, 1, p)
    p = p.parent
  end
  
  return Path(nodes, totalCost)
end

function AStar:_handleNode(node, goal)
  local i = node_table_index(self.o, node.lid)
  table.remove(self.on, i)
  table.remove(self.o, i)
  table.insert(self.c, node.lid)
  
  assert(node.location ~= nil, 'About to pass a node with nil location to getAdjacentNodes')
  
  local nodes = self.mh:getAdjacentNodes(node, goal)

  for i, n in ipairs(nodes) do repeat
    if n.location == goal then -- Reached the destination
      return n
    elseif in_table(n.lid, self.c) then -- Alread in close, skip this
      break
    elseif in_table(n.lid, self.o) then -- Already in open, check if better score   
      local i = node_table_index(self.o, n.lid)
      local on = self.on[i]
    
      if n.mCost < on.mCost then
        table.remove(self.on, i)
        table.remove(self.o, i)
        table.insert(self.on, n)
        table.insert(self.o, n.lid)
      end
    else -- New node, append to open list
      table.insert(self.on, n)
      table.insert(self.o, n.lid)
    end
  until true end
  
  return nil
end

function AStar:findPath(fromlocation, tolocation)
  self.o = {}
  self.on = {}
  self.c = {}
  
  local goal = tolocation
  local fnode = self.mh:getNode(fromlocation)

  local nextNode = nil
  
  if fnode ~= nil then
    table.insert(self.on, fnode)
    table.insert(self.o, fnode.lid)
    nextNode = fnode
  end  
  
  while nextNode ~= nil do
    local finish = self:_handleNode(nextNode, goal)
    
    if finish then
      return self:_tracePath(finish)
    end
    nextNode = self:_getBestOpenNode()
  end

  return nil
  
end

function node_table_index(tbl, lid)
  for i,n in ipairs(tbl) do
    if n == lid then
      return i
    end
  end
end