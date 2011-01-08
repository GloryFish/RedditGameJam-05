-- 
--  enemy.lua
--  RedditGameJam-05
--  
--  Created by Jay Roberts on 2011-01-07.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'class'
require 'vector'

Enemy = class(function(enemy, pos)
  
  
  -- Tileset
  enemy.tileset = love.graphics.newImage('resources/images/spritesheet.png')
  enemy.tileset:setFilter('nearest', 'nearest')

  enemy.tileSize = 16
  enemy.scale = 2
  enemy.offset = vector(enemy.tileSize / 2, enemy.tileSize / 2)

  -- Quads, animation frames
  enemy.animations = {}
  
  enemy.animations['standing'] = {}
  enemy.animations['standing'].frameInterval = 0.2
  enemy.animations['standing'].quads = {
    love.graphics.newQuad(4 * enemy.tileSize, 2, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(5 * enemy.tileSize, 2, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(6 * enemy.tileSize, 2, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(7 * enemy.tileSize, 2, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight())
  }
  
  enemy.animations['walking'] = {}
  enemy.animations['walking'].frameInterval = 0.2
  enemy.animations['walking'].quads = {
    love.graphics.newQuad(0 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(1 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(2 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
    love.graphics.newQuad(3 * enemy.tileSize, 2 * enemy.tileSize, enemy.tileSize, enemy.tileSize, enemy.tileset:getWidth(), enemy.tileset:getHeight()),
  }
  
  enemy.animation = {}
  enemy.animation.current = 'standing'
  enemy.animation.frame = 1
  enemy.animation.elapsed = 0
  
  -- Instance vars
  enemy.flip = 1
  enemy.position = pos
  enemy.speed = 100
  enemy.onground = true
  enemy.state = 'standing'
  enemy.movement = vector(0, 0) -- This holds a vector containing the last movement input recieved
  
  enemy.velocity = vector(0, 0)
  enemy.jumpVector = vector(0, -200)
end)



