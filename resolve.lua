-- 
--  resolve.lua
--  RedditGameJam-05
--  
--  Created by Jay Roberts on 2011-01-09.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'vector'
require 'class'

Resolve = class(function(resolve, pos) 
  resolve.position = pos

  resolve.width = 300
  resolve.height = 16
  resolve.startcolor = {
    r = 0,
    g = 255,
    b = 0,
    a = 255
  }
  resolve.middlecolor = {
    r = 200,
    g = 255,
    b = 60,
    a = 255
  }
  resolve.endcolor = {
    r = 0,
    g = 255,
    b = 0,
    a = 255
  }
  resolve.currentamount = 1
  resolve.target = 1
  resolve.speed = 0.001 
end)


function Resolve:update(dt)
  if self.currentamount < 0 then
    self.currentamount = 0
  end
end

function Resolve:draw()
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle('fill', self.position.x, self.position.y, self.width, self.height)

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.rectangle('fill', self.position.x + 2, self.position.y + 2, self.width - 4, self.height - 4)

  local color = nil

  if self.currentamount < 0.3 then
    color = self.endcolor
  elseif self.currentamount >= 0.3 and self.currentamount < 0.7 then
    color = self.middlecolor
  else
    color = self.startcolor
  end
  
  love.graphics.setColor(color.r, color.g, color.b, color.a)
  love.graphics.rectangle('fill', self.position.x + 4, self.position.y + 4, math.floor((self.width - 8) * self.currentamount), self.height - 8)
end