-- 
--  testmap.lua
--  redditgamejam-05
--  
--  A map with some testing tiles
--
--  Maps should return a tileset image file
--  a quads array containing quads mapped to characters
--  and a tileString defining the level
--
--  Created by Jay Roberts on 2011-01-02.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'vector'

local tileset = love.graphics.newImage('resources/images/spritesheet.png')
tileset:setFilter('nearest', 'nearest')

local tileWidth, tileHeight = 16, 16

local quadInfo = { 
  { ' ', 7 * tileWidth, 7 * tileHeight}, -- 1 = air 
  { '#', 1 * tileWidth, 3 * tileHeight}, -- 2 = brick floor
  { ']', 2 * tileWidth, 4 * tileHeight}, -- 2 = brick wall left
  { '[', 0 * tileWidth, 4 * tileHeight}, -- 2 = brick wall right
  { '_', 1 * tileWidth, 5 * tileHeight}, -- 2 = brick ceiling
  { 'h', 3 * tileWidth, 4 * tileHeight}, -- 2 = ladder in brick
  { 'H', 3 * tileWidth, 5 * tileHeight}, -- 2 = ladder
}

local solid = {
  '#',
  ']',
  '[',
  '_',
  'h'
}


local quads = {}

for _,info in ipairs(quadInfo) do
  -- info[1] = character, info[2]= x, info[3] = y
  quads[info[1]] = love.graphics.newQuad(info[2], info[3], tileWidth, tileHeight, tileset:getWidth(), tileset:getHeight())
end


local tileString = [[
______________________________________________
]                                            [
]                                            [
]                                            [
]                                            [
]                                            [
]                                            [
]                                            [
]                                            [
]                                            [
]                                            [
]                                            [
]   P                                        [
] h#######                                   [
] H                                          [
] H      ##h#######################h         [
] H        H                       H         [
] H        H                       H         [
] H   ##########           ###h#########     [
] H                          H               [
] H                          H               [
] H    ###h######  ####h################h    [
] H       H            H                H    [
] H    E  H            H                H    [
##############################################
]]

local gravity = vector(0, 600)

return tileset, quads, tileString, tileWidth, gravity, solid