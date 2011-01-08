-- 
--  heartburst.lua
--  RedditGameJam-05
--  
--  Created by Jay Roberts on 2011-01-07.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'vector'
require 'class'

HeartBurst = class(function(heart)
  -- Sounds
  heart.sound = love.audio.newSource('resources/sounds/heartburst.mp3', 'static')

  -- Tileset
  heart.tileset = love.graphics.newImage('resources/images/spritesheet.png')
  heart.tileset:setFilter('nearest', 'nearest')
  heart.tileSize = 16
  heart.quad = love.graphics.newQuad(3 * heart.tileSize, 3 * heart.tileSize, heart.tileSize, heart.tileSize, heart.tileset:getWidth(), heart.tileset:getHeight())

  heart.scale = 2
  heart.offset = vector(heart.tileSize / 2, heart.tileSize / 2)

  heart.maxlifetime = 3 -- The number of seconds that a heart is visible for
  
  heart.mininterval = 3 -- the minimum time between bursts
  heart.elapsed = heart.maxlifetime

  heart.initialspeed = 250
  heart.gravity = vector(0, -30)
  
  heart.hearts = {}
  
end)

function HeartBurst:burst(pos, count)
  if self.elapsed > self.mininterval then
    self.elapsed = 0 -- reset the timer
    
    love.audio.play(self.sound)
    
    for i = 1, count do
      local heart = {
        position = pos:clone(),
        velocity = vector_random() * self.initialspeed * math.random(),
        lifetime = 0
      }
      table.insert(self.hearts, heart)
    end
  end
end


function HeartBurst:update(dt)
  self.elapsed = self.elapsed + dt
  
  local toremove = {}
  
  for i, heart in ipairs(self.hearts) do
    heart.velocity = heart.velocity * 0.95 + self.gravity * dt -- apply friction and gravity
    heart.position = heart.position + heart.velocity * dt
    heart.lifetime = heart.lifetime + dt
    
    if heart.lifetime > self.maxlifetime then
      table.insert(toremove, i)
    end
  end
  
  for i, v in ipairs(toremove) do
    table.remove(self.hearts, v - i + 1)
  end
  
end

function HeartBurst:draw()
  love.graphics.setColor(255, 255, 255, 255)
  
  for i, heart in ipairs(self.hearts) do
    love.graphics.drawq(self.tileset,
                        self.quad, 
                        heart.position.x, 
                        heart.position.y,
                        0,
                        self.scale,
                        self.scale,
                        self.offset.x,
                        self.offset.y)
  end
end