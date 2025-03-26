require "packages.class"
require "packages.stacked"

require "screens.splash"
require "screens.title"
require "screens.gameplay"
require "screens.cafe"

local function cmp(a, b)
  a = tostring(a[1])
  b = tostring(b[1])
  local patt = "^(.-)%s*(%d+)$"
  local _,_, col1, num1 = a:find(patt)
  local _,_, col2, num2 = b:find(patt)
  if (col1 and col2) and col1 == col2 then
     return tonumber(num1) < tonumber(num2)
  end
  return a < b
end
table.sort(stacked.terms, cmp)

stacked.screens = {
  __index = stacked.screens,

  splash = Splash.new(),
  title = Title.new(),
  gameplay = Gameplay.new(),
  cafe = Cafe.new(),

  curtain = Quad.new(),

  first = "splash",
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
    self.curtain.x = -stacked.scx

    local time = 0
    local inQuint = stacked.timer.tween.quint
    local outQuint = stacked.timer.tween.out(inQuint)

    stacked.timer.during(0.5, function(dt)
      time = time + dt * 2
      self.curtain.x = -stacked.scx + (stacked.sw * inQuint(time))
    end, function()
      time = 0
      self.curtain.x = stacked.scx
      self:snapToNext()
      stacked.timer.during(0.5, function(dt)
        time = time + dt * 2
        self.curtain.x = stacked.scx + (stacked.sw * outQuint(time));
      end, function()
        self.curtain.x = -stacked.scx
      end)
    end)
  end,
}
setmetatable(stacked.screens, stacked.screens)

stacked.glossary = {
  __index = stacked.glossary,

  enabled = false,
  index = 0,

  bg = Quad.new(),
  title = Label.new(),
  terms1 = Label.new(),
  terms2 = Label.new(),
  controls = Label.new(),

  Initialize = function(self)
    self.bg.x = stacked.scx
    self.bg.y = stacked.scy
    self.bg.w = stacked.sw
    self.bg.h = stacked.sh
    self.bg.color = {
      r = 0,
      g = 0,
      b = 0,
      a = 0.75,
    }

    self.title.x = stacked.scx
    self.title.y = stacked.scy - 64
    self.title.align.v = 1
    self.title:LoadFont("assets/sport.otf", 32)
    self.title.text = "GLOSSARY"

    self.terms1.x = stacked.scx
    self.terms1.y = stacked.scy - 2
    self.terms1.align.v = 1
    self.terms1:LoadFont("assets/sport.otf", 16)

    self.terms2.x = stacked.scx
    self.terms2.y = stacked.scy + 2
    self.terms2.align.v = 0
    self.terms2:LoadFont("assets/sport.otf", 16)

    self.controls.x = stacked.scx
    self.controls.y = stacked.sh - 64
    self.controls.align.v = 1
    self.controls:LoadFont("assets/sport.otf", 32)
    self.controls.text = "<     >"
  end,
  HandleInput = function(self, event)
    if not self.enabled then return end
    local binds = stacked.controls[stacked.controls.active]
    if event.type:find("Down") then
      if event.button == binds.Left then
        self.index = (self.index - 1) % #stacked.terms
      elseif event.button == binds.Right then
        self.index = (self.index + 1) % #stacked.terms
      end
    end
  end,
  Update = function(self, dt)
    local term = stacked.terms[self.index + 1]
    self.terms1.text = term[1].."\n("..term[2]..")"
    self.terms2.text = term[3]
  end,
  Draw = function(self)
    if not self.enabled then return end
    self.bg:Draw()
    self.title:Draw()
    self.terms1:Draw()
    self.terms2:Draw()
    self.controls:Draw()
  end,
}
setmetatable(stacked.glossary, stacked.glossary)

local debugging = false
local framerate = 0
local musicVol = 0.25

local fps = Label.new()
local version = Label.new()

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

  version.align.v = 0
  version.align.h = 1
  version.x = stacked.sw - 4
  version.y = 4
  version:LoadFont("assets/sport.otf", 16)
  version.text = "Prototype v0.1.0"

  if debugging then
    stacked.timer.every(1, function()
      fps.text = "FPS: "..tostring(math.floor(framerate))
    end)
  end

  -- Final initialization
  scarlet.music.volume(0.25)
  scarlet.music.play("assets/music.mp3")
  stacked.screens.next = stacked.screens.first
  stacked.screens:snapToNext()

  stacked.glossary:Initialize()
end

function input(event)
  if event.type:find("Key") then
    stacked.controls.active = "keyboard"
  elseif event.type:find("Gamepad") then
    stacked.controls.active = event.controller.type
  end

  if event.type == "KeyUp" then
    if event.button == "F4" then
      scarlet.window.fullscreen(not scarlet.window.fullscreen())
    end
  end

  local binds = stacked.controls[stacked.controls.active]

  if event.type:find("Down") then
    if event.button == binds.Glossary then
      stacked.glossary.enabled = true
    end
  elseif event.type:find("Up") then
    if event.button == binds.Glossary then
      stacked.glossary.enabled = false
    elseif event.button == binds.MuteMusic then
      scarlet.music.volume(musicVol - scarlet.music.volume())
    end
  end

  stacked.screens[stacked.screens.current]:HandleInput(event)

  stacked.glossary:HandleInput(event)
end

function update(dt)
  framerate = 1 / dt

  stacked.uptime = stacked.uptime + dt

  stacked.timer.update(dt)

  stacked.screens[stacked.screens.current]:Update(dt)

  stacked.glossary:Update(dt)
end

function draw()
  stacked.screens[stacked.screens.current]:Draw()

  stacked.glossary:Draw()

  stacked.screens.curtain:Draw()

  -- Debug
  if debugging then
    fps:Draw()
  end

  if stacked.screens.current == "title" then
    version:Draw()
  end
end
