-- 
--  controller_manager.lua
--  redditgamejam-05
--  
--  Created by Jay Roberts on 2010-12-29.
--  Copyright 2010 GloryFish.org. All rights reserved.
-- 

require 'class'
require 'vector'
require 'utility'
require 'logger'

ControllerManager = class(function(mgr)
  if love.joystick.getNumJoysticks() == 0 then
    mgr.enabled = false
  else
    mgr.enabled = true

    mgr.stickID = 0
    mgr.deadzone = 0.2
  
    love.joystick.open(mgr.stickID)
    mgr.state = {
      joystick = vector(0, 0),
      buttons = {
        a = false,
        b = false,
        x = false,
        y = false,
        back = false,
        guide = false,
        start = false,
        lbumper = false,
        rbumper = false,
        newpress = {
          a = false,
          b = false,
          x = false,
          y = false,
          back = false,
          guide = false,
          start = false,
          lbumper = false,
          rbumper = false
        }
      }
    }
    
    mgr.previous_state = {}
  
    mgr.debug = false
  
    mgr.logger = Logger(vector(10, 10))
  end
end)

function ControllerManager:update(dt)
  self.previous_state = deepcopy(self.state);
  
  -- Dpad-Up 0
  -- Dpad-Left 1
  -- Dpad-Left 2
  -- Dpad-Right 3
  -- Start 4
  -- Back 5
  -- Left Stick 6
  -- Right Stick 7
  -- Left Bumper 8
  -- Right Bumper 9
  -- Guide 10
  -- A 11
  -- B 12
  -- X 13
  -- Y 14
  
  local x, y = love.joystick.getAxes(self.stickID)
  local joy = vector(x, y)
  
  if joy:len() < self.deadzone then
    joy = vector(0, 0)
  end
  
  self.state.joystick = joy

  self.state.buttons.start = love.joystick.isDown(self.stickID, 4)
  self.state.buttons.back = love.joystick.isDown(self.stickID, 5)
  self.state.buttons.guide = love.joystick.isDown(self.stickID, 10)

  self.state.buttons.lbumper = love.joystick.isDown(self.stickID, 8)
  self.state.buttons.rbumper = love.joystick.isDown(self.stickID, 9)

  self.state.buttons.a = love.joystick.isDown(self.stickID, 11)
  self.state.buttons.b = love.joystick.isDown(self.stickID, 12)
  self.state.buttons.x = love.joystick.isDown(self.stickID, 13)
  self.state.buttons.y = love.joystick.isDown(self.stickID, 14)
  
  -- Check for new button presses
  self.state.buttons.newpress.start = self.state.buttons.start and not self.previous_state.buttons.start 
  self.state.buttons.newpress.back  = self.state.buttons.back  and not self.previous_state.buttons.back 
  self.state.buttons.newpress.guide = self.state.buttons.guide and not self.previous_state.buttons.guide 
       
  self.state.buttons.newpress.lbumper = self.state.buttons.lbumper and not self.previous_state.buttons.lbumper 
  self.state.buttons.newpress.rbumper = self.state.buttons.rbumper and not self.previous_state.buttons.rbumper 
       
  self.state.buttons.newpress.a = self.state.buttons.a and not self.previous_state.buttons.a 
  self.state.buttons.newpress.b = self.state.buttons.b and not self.previous_state.buttons.b 
  self.state.buttons.newpress.x = self.state.buttons.x and not self.previous_state.buttons.x 
  self.state.buttons.newpress.y = self.state.buttons.y and not self.previous_state.buttons.y 
  
  if self.debug then
    self.logger:update(dt)
    
    self.logger:addLine(string.format('Joystick #%i', self.stickID))
    self.logger:addLine(string.format('x: %f, y: %f', self.state.joystick.x, self.state.joystick.y))

    if self.state.buttons.start then
      self.logger:addLine("start")
    end
    if self.state.buttons.back then
      self.logger:addLine("back")
    end
    if self.state.buttons.guide then
      self.logger:addLine("guide")
    end

    if self.state.buttons.lbumper then
      self.logger:addLine("lbumper")
    end
    if self.state.buttons.rbumper then
      self.logger:addLine("rbumper")
    end

    if self.state.buttons.a then
      self.logger:addLine("A")
    end
    if self.state.buttons.b then
      self.logger:addLine("B")
    end
    if self.state.buttons.x then
      self.logger:addLine("X")
    end
    if self.state.buttons.y then
      self.logger:addLine("Y")
    end
    
  end
end


function ControllerManager:draw()
  if self.debug then
    self.logger:draw()
  end
end