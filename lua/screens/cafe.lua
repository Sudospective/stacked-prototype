require "classes.screen"
require "classes.coffee"
require "classes.soda"

local bg = Quad.new()
local sign = Label.new()

class "Cafe" : extends "Screen" {
  title = "Cafe",
  __init = function(self)
    bg.x = stacked.scx
    bg.y = stacked.scy
    bg.w = stacked.sw
    bg.h = stacked.sh
    bg.color = {
      r = 0.2,
      g = 0.3,
      b = 0.1,
      a = 1.0,
    }
    self:AddGizmo(bg)

    sign.x = stacked.scx
    sign.y = 32
    sign.align.v = 0
    sign:LoadFont("assets/sport.otf", 64)
    sign.text = "HARD DROP CAFE"
    self:AddGizmo(sign)
  end;
  __update = function(self, dt)
  end;
  __input = function(self, event)
  end;
  __enter = function(self)
  end;
  __exit = function(self)
  end;
}
