-- 
--  logger.lua
--  arrow_chase
--  
--  Display an onscreen log.
--
--  Created by Jay Roberts on 2010-09-29.
--  Copyright 2010 GloryFish.org. All rights reserved.
-- 

require 'class'

Logger = class(function(logger, pos)
  logger.position = pos
  logger.color = {
    r = 200,
    g = 200,
    b = 200,
    a = 150,
  }
  logger.lineHeight = 15
  logger.lines = {}
end)


function Logger:addLine(line)
  table.insert(self.lines, line)
end

function Logger:draw()
  love.graphics.setFont(fonts.default)
  
  love.graphics.setColor(self.color.r,
                         self.color.g,
                         self.color.b,
                         self.color.a);

  local currentLinePosition = 0
  
  for index, line in pairs(self.lines) do
    love.graphics.print(line, 
                        self.position.x, 
                        self.position.y + currentLinePosition);
    currentLinePosition = currentLinePosition + self.lineHeight;
  end

end

function Logger:update(dt)
  self.lines = {}
end