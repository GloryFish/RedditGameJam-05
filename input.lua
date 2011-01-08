-- 
--  input.lua
--  redditgamejam-05
--  
--  Created by Jay Roberts on 2011-01-06.
--  Copyright 2011 GloryFish.org. All rights reserved.
-- 

require 'class'
require 'vector'
require 'controller_manager'
require 'utility'

Input = class(function(input)
  input.controller = ControllerManager()
  
  input.state = {
    movement = vector(0, 0),
    buttons = {
      jump = false,
      fire = false,
      back = false,
      start = false,
      newpress = {
        jump = false,
        fire = false,
        back = false,
        start = false,
      }
    }
  }

  input.previous_state = {}
  
end)


function Input:update(dt)
  self.previous_state = deepcopy(self.state);
  
  self.state.movement = vector(0, 0)
  
  -- Get keyboard movement
  self.state.buttons.left = false
  self.state.buttons.right = false
  if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
    self.state.movement.x = -1
    self.state.buttons.left = true
  elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
    self.state.movement.x = 1
    self.state.buttons.right = true
  end

  self.state.buttons.up = false
  self.state.buttons.down = false
  if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
    self.state.movement.y = -1
    self.state.buttons.up = true
  elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
    self.state.movement.y = 1
    self.state.buttons.down = true
  end
  
  -- Get keyboard buttons
  self.state.buttons.jump = love.keyboard.isDown('z')
  self.state.buttons.fire = love.keyboard.isDown('x')
  self.state.buttons.back = love.keyboard.isDown('escape')
  self.state.buttons.start = love.keyboard.isDown('return')

  -- Get controller movement
  if self.controller.enabled then
    self.controller:update(dt)

    if self.controller.state.joystick ~= vector(0, 0) then 
      self.state.movement = self.controller.state.joystick
      
      -- Apply joystick movement as button presses
      if self.controller.state.joystick.x < 0 then
        self.state.buttons.left = true
      end
      if self.controller.state.joystick.x > 0 then
        self.state.buttons.right = true
      end
      if self.controller.state.joystick.y < 0 then
        self.state.buttons.up = true
      end
      if self.controller.state.joystick.y > 0 then
        self.state.buttons.down = true
      end
      
    end
    
    if self.controller.state.buttons.a then
      self.state.buttons.jump = true
    end
    if self.controller.state.buttons.x then
      self.state.buttons.fire = true
    end
    if self.controller.state.buttons.back then
      self.state.buttons.back = true
    end
    if self.controller.state.buttons.start then
      self.state.buttons.start = true
    end
  end
  
  -- Add meta buttons
  self.state.buttons.select = self.state.buttons.start or self.state.buttons.jump or self.state.buttons.fire
  self.state.buttons.cancel = self.state.buttons.back
  
  if self.controller.enabled then
    self.state.buttons.cancel = self.state.buttons.cancel or self.controller.state.buttons.b
  end
  
  -- Check for new button presses
  self.state.buttons.newpress.up    = self.state.buttons.up    and not self.previous_state.buttons.up 
  self.state.buttons.newpress.down  = self.state.buttons.down  and not self.previous_state.buttons.down 
  self.state.buttons.newpress.left  = self.state.buttons.left  and not self.previous_state.buttons.left 
  self.state.buttons.newpress.right = self.state.buttons.right and not self.previous_state.buttons.right 

  self.state.buttons.newpress.jump  = self.state.buttons.jump  and not self.previous_state.buttons.jump 
  self.state.buttons.newpress.fire  = self.state.buttons.fire  and not self.previous_state.buttons.fire 
  self.state.buttons.newpress.start = self.state.buttons.start and not self.previous_state.buttons.start 
  self.state.buttons.newpress.back  = self.state.buttons.back  and not self.previous_state.buttons.back 

  self.state.buttons.newpress.select  = self.state.buttons.select  and not self.previous_state.buttons.select 
  self.state.buttons.newpress.cancel  = self.state.buttons.cancel  and not self.previous_state.buttons.cancel 
end