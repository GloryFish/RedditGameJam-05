-- 
--  scene_instructions.lua
--  RedditGameJam-05
--  
--  Created by Jay Roberts on 2011-01-08.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'vector'

instructions = Gamestate.new()

function instructions.enter(self, pre)
  menu.title = 'Unrequited'
  menu.subtitle = 'a game by Jay Roberts'
  
  menu.entries = {
    {
      title = 'Play',
      scene = game,
      level = 'levelone'
    },
    {
      title = 'How to play',
      scene = instructions,
    },
    {
      title = 'Quit'
    }
  }
  
  menu.colors = {
    text = {
      r = 255,
      g = 255,
      b = 255,
      a = 255
    },
    highlight = {
      r = 0,
      g = 0,
      b = 0,
      a = 255
    },
    background = {
      r = 200,
      g = 200,
      b = 220,
      a = 255
    }
  }
  
  menu.position = vector(100, 100)
  
  menu.lineHeight = 20
  
  menu.index = 1
  
end

function instructions.update(self, dt)
  input:update(dt)
  
  if input.state.buttons.newpress.cancel then
    Gamestate.switch(menu)
  end
end

function instructions.draw(self)
  love.graphics.setColor(self.colors.text.r,
                         self.colors.text.g,
                         self.colors.text.b,
                         self.colors.text.a);
  
  love.graphics.setFont(fonts.large)
  love.graphics.print(menu.title, 40, 20);
  
  love.graphics.setFont(fonts.default)

  love.graphics.print(menu.subtitle, 40, 60);
  
  love.graphics.setBackgroundColor(self.colors.background.r,
                                   self.colors.background.g,
                                   self.colors.background.b,
                                   self.colors.background.a);

  local currentLinePosition = 0
  
  for index, entry in pairs(self.entries) do
    love.graphics.setColor(self.colors.text.r,
                           self.colors.text.g,
                           self.colors.text.b,
                           self.colors.text.a);

    if index == self.index then
      love.graphics.setColor(self.colors.highlight.r,
                             self.colors.highlight.g,
                             self.colors.highlight.b,
                             self.colors.highlight.a);
    end

    love.graphics.print(entry.title, 
                        self.position.x, 
                        self.position.y + currentLinePosition);

    currentLinePosition = currentLinePosition + self.lineHeight;
  end
end

function instructions.leave(self)
end