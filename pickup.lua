-- 
--  pickup.lua
--  RedditGameJam-05
--  
--  Created by Jay Roberts on 2011-01-09.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'class'
require 'vector'

Pickup = class(function(pickup, pos) 
  -- Sounds
  pickup.sounds = {
    get = love.audio.newSource('resources/sounds/pickup.mp3', 'static'),
  } 
  
  -- Tileset
  pickup.tileset = love.graphics.newImage('resources/images/spritesheet.png')
  pickup.tileset:setFilter('nearest', 'nearest')

  pickup.tileSize = 16
  pickup.scale = 2
  pickup.offset = vector(pickup.tileSize / 2, pickup.tileSize / 2)

  -- Quads, animation frames
  pickup.animations = {}

  pickup.animations['idle'] = {}
  pickup.animations['idle'].frameInterval = 0.1
  pickup.animations['idle'].quads = {
    love.graphics.newQuad(0 * pickup.tileSize, 6 * pickup.tileSize, pickup.tileSize, pickup.tileSize, pickup.tileset:getWidth(), pickup.tileset:getHeight()),
    love.graphics.newQuad(1 * pickup.tileSize, 6 * pickup.tileSize, pickup.tileSize, pickup.tileSize, pickup.tileset:getWidth(), pickup.tileset:getHeight()),
    love.graphics.newQuad(2 * pickup.tileSize, 6 * pickup.tileSize, pickup.tileSize, pickup.tileSize, pickup.tileset:getWidth(), pickup.tileset:getHeight()),
    love.graphics.newQuad(3 * pickup.tileSize, 6 * pickup.tileSize, pickup.tileSize, pickup.tileSize, pickup.tileset:getWidth(), pickup.tileset:getHeight())
  }
  
  pickup.animation = {}
  pickup.animation.current = 'idle'
  pickup.animation.frame = 1
  pickup.animation.elapsed = 0

  pickup.flip = 1
  pickup.position = pos
end)

function Pickup:get()
  -- Play sound
  love.audio.play(self.sounds.get)
end

function Pickup:update(dt)
  self.animation.elapsed = self.animation.elapsed + dt
  
  -- Handle animation
  if #self.animations[self.animation.current].quads > 1 then -- More than one frame
    local interval = self.animations[self.animation.current].frameInterval
    
    if self.animation.elapsed > interval then -- Switch to next frame
      self.animation.frame = self.animation.frame + 1
      if self.animation.frame > #self.animations[self.animation.current].quads then -- Aaaand back around
        self.animation.frame = 1
      end
      self.animation.elapsed = 0
    end
  end
end

function Pickup:draw()
  love.graphics.drawq(self.tileset,
                      self.animations[self.animation.current].quads[self.animation.frame], 
                      self.position.x, 
                      self.position.y,
                      0,
                      self.scale * self.flip,
                      self.scale,
                      self.offset.x,
                      self.offset.y)
end