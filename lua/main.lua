require "packages.class"
require "packages.stacked"

require "screens.title"
require "screens.gameplay"
require "screens.cafe"

stacked.screens = {
  __index = stacked.screens,

  title = Title.new(),
  gameplay = Gameplay.new(),
  cafe = Cafe.new(),

  curtain = Quad.new(),

  first = "title",
  current = nil,
  next = nil,
  snapToNext = function(self)
    if self.current then
      self[self.current]:Exit()
    end
    self[self.next]:Enter()
    self.current = self.next
    self.next = nil
  end,
  goToNext = function(self)
    stacked.timer.clear()
    stacked.screens.curtain.x = -stacked.scx

    local time = 0
    local inQuint = stacked.timer.tween.quint
    local outQuint = stacked.timer.tween.out(inQuint)

    stacked.timer.during(0.5, function(dt)
      time = time + dt * 2
      stacked.screens.curtain.x = -stacked.scx + (stacked.sw * inQuint(time))
    end, function()
      time = 0
      stacked.screens.curtain.x = stacked.scx
      if self.current then
        self[self.current]:Exit()
      end
      self[self.next]:Enter()
      self.current = self.next
      self.next = nil
      stacked.timer.during(0.5, function(dt)
        time = time + dt * 2
        stacked.screens.curtain.x = stacked.scx + (stacked.sw * outQuint(time));
      end, function()
        stacked.screens.curtain.x = -stacked.scx
      end)
    end)
  end,
}
setmetatable(stacked.screens, stacked.screens)

local debugging = true
local framerate = 0

local fps = Label.new()

function init()
  stacked.screens.curtain.x = -stacked.scx
  stacked.screens.curtain.y = stacked.scy
  stacked.screens.curtain.w = stacked.sw
  stacked.screens.curtain.h = stacked.sh
  stacked.screens.curtain.color = {
    r = 0,
    g = 0,
    b = 0,
    a = 1,
  }

  -- Debug
  fps.align.v = 0
  fps.align.h = 0
  fps.x = 4
  fps.y = 4
  fps:LoadFont("assets/sport.otf", 16)
  fps.text = "FPS: 0"

  if debugging then
    stacked.timer.every(1, function()
      fps.text = "FPS: "..tostring(math.floor(framerate))
    end)
  end

  -- Final initialization
  stacked.screens.next = stacked.screens.first
  stacked.screens:snapToNext()
  scarlet.music.play("assets/music.mp3")
  scarlet.music.volume(0.35)
end

function input(event)
  if event.type:find("Key") then
    stacked.controls.active = "keyboard"
  elseif event.type:find("Gamepad") then
    stacked.controls.active = "controller"
  end

  if event.type == "KeyUp" then
    if event.button == "F4" then
      scarlet.window.fullscreen(not scarlet.window.fullscreen())
    end
  end

  stacked.screens.title:HandleInput(event)
  stacked.screens.gameplay:HandleInput(event)
  stacked.screens.cafe:HandleInput(event)
end

function update(dt)
  framerate = 1 / dt

  stacked.uptime = stacked.uptime + dt

  stacked.timer.update(dt)

  stacked.screens.title:Update(dt)
  stacked.screens.gameplay:Update(dt)
  stacked.screens.cafe:Update(dt)
end

function draw()
  stacked.screens.title:Draw()
  stacked.screens.gameplay:Draw()
  stacked.screens.cafe:Draw()

  stacked.screens.curtain:Draw()

  -- Debug
  if debugging then
    fps:Draw()
  end
end
