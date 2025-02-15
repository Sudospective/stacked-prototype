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

  first = "cafe",
  current = nil,
  next = nil,
  goToNext = function(self)
    if self.current then
      self[self.current]:Exit()
    end
    self[self.next]:Enter()
    self.current = self.next
    self.next = nil
  end,
}
setmetatable(stacked.screens, stacked.screens)

local debug = true

local fps = Label.new()

function init()
  -- Debug
  fps.align.v = 0
  fps.align.h = 0
  fps.x = 4
  fps.y = 4
  fps:LoadFont("assets/sport.otf", 16)
  fps.text = "FPS: 0"

  -- Final initialization
  stacked.screens.next = stacked.screens.first
  stacked.screens:goToNext()
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
  stacked.uptime = stacked.uptime + dt

  stacked.timer.update(dt)

  stacked.screens.title:Update(dt)
  stacked.screens.gameplay:Update(dt)
  stacked.screens.cafe:Update(dt)

  if debug then
    fps.text = "FPS: "..tostring(math.floor(1 / dt))
  end
end

function draw()
  stacked.screens.title:Draw()
  stacked.screens.gameplay:Draw()
  stacked.screens.cafe:Draw()

  -- Debug
  if debug then
    fps:Draw()
  end
end
