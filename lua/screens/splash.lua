require "classes.screen"

local bg = Quad.new()

local banner = Sprite.new()

class "Splash" : extends "Screen" {
  title = "Splash";
  __init = function(self)
    bg.x = stacked.scx
    bg.y = stacked.scy
    bg.w = stacked.sw
    bg.h = stacked.sh
    bg.color = {
      r = 0.0,
      g = 0.0,
      b = 0.0,
      a = 1.0,
    }
    self:AddGizmo(bg)

    banner.x = stacked.scx
    banner.y = stacked.scy
    banner:LoadTexture("assets/banner.png")
    
    banner.w = banner.w * 0.5
    banner.h = banner.h * 0.5
    self:AddGizmo(banner)
  end;
  __enter = function(self)
    local w, h = banner.w, banner.h
    local time, length = 0, 0.25
    local back = stacked.timer.tween.back
    local outBack = stacked.timer.tween.out(back)

    banner.w = 0
    banner.h = 0
    stacked.timer.after(1.5, function()
      time = 0
      stacked.timer.during(length, function(dt)
        time = time + dt / length
        banner.w = outBack(time) * w
        banner.h = outBack(time) * h
      end, function()
        banner.w = w
        banner.h = h
      end)
      stacked.timer.after(3, function()
        time = 0
        stacked.timer.during(length, function(dt)
          time = time + dt / length
          banner.w = (1 - back(time)) * w
          banner.h = (1 - back(time)) * h
        end, function()
          banner.w = 0
          banner.h = 0
          stacked.timer.after(1, function()
            stacked.screens.next = "title"
            stacked.screens:goToNext()
          end)
        end)
      end)
    end)
  end;
  __update = function(self, dt)
    banner.rot = math.sin(stacked.uptime * 2) * 2
  end;
}
