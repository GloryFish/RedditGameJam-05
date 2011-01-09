-- 
--  scene_menu.lua
--  redditgamejam-05
--  
--  Created by Jay Roberts on 2011-01-06.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 
require 'vector'

-- Game scenes
require 'scene_game'
require 'scene_instructions'

menu = Gamestate.new()

function menu.enter(self, pre)
  menu.title = 'Unrequited'
  menu.subtitle = 'a game by Jay Roberts'

  menu.bird = love.graphics.newImage('resources/images/menubird.png')
  menu.redditlogo = love.graphics.newImage('resources/images/redditgamejam05.png')
  menu.heart = love.graphics.newImage('resources/images/heart.png')
  menu.heart:setFilter('nearest', 'nearest')
  
  menu.sounds = {
    menuselect = love.audio.newSource('resources/sounds/menuselect.mp3', 'static'),
    menumove = love.audio.newSource('resources/sounds/menumove.mp3', 'static')
  } 
  
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
      r = 255,
      g = 0,
      b = 0,
      a = 255
    },
    background = {
      r = 200,
      g = 200,
      b = 250,
      a = 255
    }
  }
  
  menu.position = vector(70, 100)
  
  menu.lineHeight = 30
  
  menu.index = 1
  
  music.title:setVolume(1.0)
  love.audio.play(music.title)
  
  menu.leaving = false
  menu.leaveInterval = 1
  menu.leaveDuration = 0
  
end

function menu.update(self, dt)
  if menu.leaving then
    menu.leaveDuration = menu.leaveDuration + dt
    
    music.title:setVolume(1 - ((menu.leaveInterval - menu.leaveDuration) / menu.leaveInterval))
    
    if menu.leaveDuration > menu.leaveInterval then
      menu.leaving = false
      music.title:pause()
      Gamestate.switch(menu.entries[menu.index].scene)
    end
  else
    input:update(dt)

    if input.state.buttons.newpress.down then
      menu.index = menu.index + 1
      if menu.index > #menu.entries then
        menu.index = 1
      end
      love.audio.play(self.sounds.menumove)
    end

    if input.state.buttons.newpress.up then
      menu.index = menu.index - 1
      if menu.index < 1 then
        menu.index = #menu.entries
      end
      love.audio.play(self.sounds.menumove)
    end

    if input.state.buttons.newpress.select then
      if menu.entries[menu.index].title == 'Quit' then
        love.event.push('q')
      else
        if menu.entries[menu.index].level ~= nil then
          menu.entries[menu.index].scene.level = menu.entries[menu.index].level
        end

        menu.leaving = true
        menu.leaveDuration = 0
        love.audio.play(self.sounds.menuselect)
      end
    end

    if input.state.buttons.newpress.cancel then
      love.event.push('q')
    end
  end
end

function menu.draw(self)
  love.graphics.setFont(fonts.large)

  love.graphics.setColor(50, 50, 50, 200)
  love.graphics.print(menu.title, 39, 19);

  love.graphics.setColor(self.colors.text.r,
                         self.colors.text.g,
                         self.colors.text.b,
                         self.colors.text.a);
  
  love.graphics.print(menu.title, 40, 20);
  
  love.graphics.setFont(fonts.default)

  love.graphics.setColor(50, 50, 50, 200)
  love.graphics.print(menu.subtitle, 39, 59);

  love.graphics.setColor(self.colors.text.r,
                         self.colors.text.g,
                         self.colors.text.b,
                         self.colors.text.a);

  love.graphics.print(menu.subtitle, 40, 60);
  
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
  love.graphics.draw(menu.redditlogo, 500, 500)
  
  love.graphics.draw(menu.bird, 660, 50, 0, -1 * 0.9, 1 * 0.9)
  
  if menu.leaving then
    local overlayAlpha = (1 - ((menu.leaveInterval - menu.leaveDuration) / menu.leaveInterval)) * 255
    love.graphics.setColor(255, 255, 255, overlayAlpha)
    
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  end
  
end

function menu.leave(self)
end