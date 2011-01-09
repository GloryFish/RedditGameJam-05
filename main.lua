-- 
--  main.lua
--  redditgamejam-05
--  
--  Created by Jay Roberts on 2010-12-10.
--  Copyright 2010 GloryFish.org. All rights reserved.
-- 

require 'gamestate'
require 'input'
require 'scene_menu'

function love.load()
  love.graphics.setCaption('Unrequited by Jay Roberts')
  debug = false
  
  -- Seed random
  local seed = os.time()
  math.randomseed(seed);
  math.random(); math.random(); math.random()  
  
  fonts = {
    default = love.graphics.newFont('resources/fonts/silk.ttf', 24),
    large =  love.graphics.newFont('resources/fonts/silk.ttf', 48)
  }
  
  music = {
    title = love.audio.newSource("resources/music/titlemusic.mp3", 'stream'),
    game = love.audio.newSource("resources/music/gamemusic.mp3", 'stream')
  }
  
  input = Input()
  
  Gamestate.registerEvents()
  Gamestate.switch(menu)
end

function love.update(dt)
end


