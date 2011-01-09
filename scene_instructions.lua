-- 
--  scene_instructions.lua
--  redditgamejam-05
--  
--  Created by Jay Roberts on 2011-01-06.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 
require 'vector'

instructions = Gamestate.new()

function instructions.enter(self, pre)
  instructions.title = 'Instructions'
  instructions.subtitle = ''

  instructions.instructions = love.graphics.newImage('resources/images/instructions.png')
  instructions.instructions:setFilter('nearest', 'nearest')

  instructions.redditlogo = love.graphics.newImage('resources/images/redditgamejam05.png')
  instructions.heart = love.graphics.newImage('resources/images/heart.png')
  instructions.heart:setFilter('nearest', 'nearest')
  
  instructions.sounds = {
    instructionsselect = love.audio.newSource('resources/sounds/menuselect.mp3', 'static'),
    instructionsmove = love.audio.newSource('resources/sounds/menumove.mp3', 'static')
  } 
  
  instructions.entries = {
    {
      title = 'Back',
      scene = menu,
    },
  }
  
  instructions.colors = {
    text = {
      r = 255,
      g = 255,
      b = 255,
      a = 255
    },
    highlight = {
      r = 255,
      g = 0,
      b = 0,
      a = 255
    },
    background = {
      r = 130,
      g = 250,
      b = 130,
      a = 255
    }
  }
  
  instructions.position = vector(70, 100)
  
  instructions.lineHeight = 30
  
  instructions.index = 1
  
  music.title:setVolume(1.0)
  love.audio.play(music.title)
  
  instructions.leaving = false
  instructions.leaveInterval = 1
  instructions.leaveDuration = 0
  
end

function instructions.update(self, dt)
  if instructions.leaving then
    instructions.leaveDuration = instructions.leaveDuration + dt
    
    music.title:setVolume(1 - ((instructions.leaveInterval - instructions.leaveDuration) / instructions.leaveInterval))
    
    if instructions.leaveDuration > instructions.leaveInterval then
      instructions.leaving = false
      love.audio.stop(music.title)
      Gamestate.switch(instructions.entries[instructions.index].scene)
    end
  else
    input:update(dt)

    if input.state.buttons.newpress.down then
      instructions.index = instructions.index + 1
      if instructions.index > #instructions.entries then
        instructions.index = 1
      end
      love.audio.play(self.sounds.instructionsmove)
    end

    if input.state.buttons.newpress.up then
      instructions.index = instructions.index - 1
      if instructions.index < 1 then
        instructions.index = #instructions.entries
      end
      love.audio.play(self.sounds.instructionsmove)
    end

    if input.state.buttons.newpress.select then
      if instructions.entries[instructions.index].title == 'Quit' then
        love.event.push('q')
      else
        if instructions.entries[instructions.index].level ~= nil then
          instructions.entries[instructions.index].scene.level = instructions.entries[instructions.index].level
        end

        instructions.leaving = true
        instructions.leaveDuration = 0
        love.audio.play(self.sounds.instructionsselect)
      end
    end

    if input.state.buttons.newpress.cancel then
      love.event.push('q')
    end
  end
end

function instructions.draw(self)
  love.graphics.setFont(fonts.large)

  love.graphics.setColor(50, 50, 50, 200)
  love.graphics.print(instructions.title, 39, 19);

  love.graphics.setColor(self.colors.text.r,
                         self.colors.text.g,
                         self.colors.text.b,
                         self.colors.text.a);
  
  love.graphics.print(instructions.title, 40, 20);
  
  love.graphics.setFont(fonts.default)

  love.graphics.setColor(50, 50, 50, 200)
  love.graphics.print(instructions.subtitle, 39, 59);

  love.graphics.setColor(self.colors.text.r,
                         self.colors.text.g,
                         self.colors.text.b,
                         self.colors.text.a);

  love.graphics.print(instructions.subtitle, 40, 60);
  
  love.graphics.setBackgroundColor(self.colors.background.r,
                                   self.colors.background.g,
                                   self.colors.background.b,
                                   self.colors.background.a);

  local currentLinePosition = 0
  
  for index, entry in pairs(self.entries) do
    love.graphics.setColor(50, 50, 50, 200)
    love.graphics.print(entry.title, 
                        self.position.x - 1, 
                        self.position.y + currentLinePosition - 1);
    
    love.graphics.setColor(self.colors.text.r,
                           self.colors.text.g,
                           self.colors.text.b,
                           self.colors.text.a);

    if index == self.index then
      love.graphics.setColor(self.colors.highlight.r,
                             self.colors.highlight.g,
                             self.colors.highlight.b,
                             self.colors.highlight.a);
      love.graphics.draw(self.heart, self.position.x - 20, self.position.y + currentLinePosition + 10, 0, 2, 2, 8, 8)
    end

    love.graphics.print(entry.title, 
                        self.position.x, 
                        self.position.y + currentLinePosition);

    currentLinePosition = currentLinePosition + self.lineHeight;
  end
  
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(instructions.redditlogo, 500, 500)
  
  love.graphics.draw(instructions.instructions, 130, 100, 0, 4, 4)
  

  love.graphics.setColor(50, 50, 50, 200)
  love.graphics.print("This is Frank", 159, 199)

  love.graphics.print("This is Linda", 419, 199)

  love.graphics.print("Franks wants money", 64, 339)

  love.graphics.print("Linda wants love", 419, 339)

  love.graphics.print("Arrow keys or wsad to move, z to jump", 99, 419)
  love.graphics.print("Collect coins, don't let Linda catch you!", 99, 449)
  
  love.graphics.setColor(self.colors.text.r,
                         self.colors.text.g,
                         self.colors.text.b,
                         self.colors.text.a);
  love.graphics.print("This is Frank", 160, 200)

  love.graphics.print("This is Linda", 420, 200)

  love.graphics.print("Franks wants money", 65, 340)

  love.graphics.print("Linda wants love", 420, 340)

  love.graphics.print("Arrow keys or wsad to move, z to jump", 100, 420)
  love.graphics.print("Collect coins, don't let Linda catch you!", 100, 450)
  
  
  if instructions.leaving then
    local overlayAlpha = (1 - ((instructions.leaveInterval - instructions.leaveDuration) / instructions.leaveInterval)) * 255
    love.graphics.setColor(255, 255, 255, overlayAlpha)
    
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  end
  
end

function instructions.leave(self)
end