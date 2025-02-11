require "classes.screen"

local bg = Quad.new()
local title = Label.new()
local subtitle = Label.new()
local help = Label.new()

class "Title" : extends "Screen" {
  title = "Title";
  __init = function(self)
    bg.x = stacked.scx
    bg.y = stacked.scy
    bg.w = stacked.sw
    bg.h = stacked.sh
    bg.color = {
      r = 0.3,
      g = 0.1,
      b = 0.2,
      a = 1.0,
    }
    self:AddGizmo(bg)

    title.x = stacked.scx
    title.y = stacked.scy * 0.5 + 16
    title.align.v = 1
    title:LoadFont("assets/sport.otf", 64)
    title.text = "STACKED"
    self:AddGizmo(title)

    subtitle.x = stacked.scx
    subtitle.y = stacked.scy * 0.5 + 16
    subtitle.align.v = 0
    subtitle:LoadFont("assets/sport.otf", 16)
    subtitle.text = "A Tetromino Roguelike"
    self:AddGizmo(subtitle)

    help.x = stacked.scx
    help.y = stacked.scy * 1.5
    help:LoadFont("assets/sport.otf", 32)
    help.text = "Press Enter or Start"
    self:AddGizmo(help)
  end;
  __update = function(self, dt)
  end;
  __input = function(self, event)
    if event.type == "KeyUp" then
      if event.button == "Escape" then
        scarlet.exit()
      elseif event.button == "Return" then
        stacked.screens.next = "gameplay"
        stacked.screens:goToNext()
      end
    end
  end;
  __enter = function(self)
  end;
  __exit = function(self)
  end;
}
