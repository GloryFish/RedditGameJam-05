-- 
--  block.lua
--  redditgamejam-05
--  
--  Created by Jay Roberts on 2010-12-10.
--  Copyright 2010 GloryFish.org. All rights reserved.
-- 

require 'class'
require 'vector'

FloatingText = class(function(floatingtext)
    floatingtext.texts = {}
    floatingtext.speed = 30 -- Pixels per second
  end)


function FloatingText:addText(msg, pos, col, lftm)
  local text = {
    message = msg,
    position = pos,
    color = col,
    duration = 0,
    lifetime = lftm,
    state = 'floating'
  }
  
  table.insert(self.texts, text)
end

function FloatingText:update(dt)
  local toRemove = {}
  
  -- Move texts up
  for index, text in pairs(self.texts) do
    text.position.y = text.position.y - (self.speed * dt)
    text.duration = text.duration + dt
    
    if text.duration > text.lifetime then
      table.insert(toRemove, index)
    end
  end

  -- Remove texts that are past their lifetime
  for i, index in pairs(toRemove) do
    table.remove(self.texts, index)
  end
  
end
  
function FloatingText:draw()
  for index, text in pairs(self.texts) do
    
    local alpha = 255 - (255 * (text.duration / text.lifetime))
  
    love.graphics.setColor(text.color.r,
                           text.color.g,
                           text.color.b,
                           alpha);

    love.graphics.print(text.message, 
                        text.position.x, 
                        text.position.y);
  end
end

