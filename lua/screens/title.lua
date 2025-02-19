require "classes.screen"

local bg = Quad.new()
local title = Label.new()
local subtitle = Label.new()
local help = Label.new()

local fader = Quad.new()
local controls = Label.new()

local credits = Label.new()

local start = Sound.new()
local quit = Sound.new()

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
    self:AddGizmo(help)

    fader.x = stacked.scx
    fader.y = stacked.scy
    fader.w = stacked.sw
    fader.h = stacked.sh
    fader.color = {
      r = 0,
      g = 0,
      b = 0,
      a = 0,
    }
    self:AddGizmo(fader)

    controls.x = stacked.scx
    controls.y = stacked.scy
    controls:LoadFont("assets/sport.otf", 16)
    controls.color.a = 0
    self:AddGizmo(controls)

    credits.x = 4
    credits.y = stacked.sh - 4
    credits.align = {h = 0, v = 1}
    credits:LoadFont("assets/sport.otf", 16)
    credits.text = "Font by UkiyoMoji Fonts\nSound effects from Pixabay\nSong by LAKEY INSPIRED"
    self:AddGizmo(credits)

    start:LoadSource("assets/sounds/clear.ogg")
    start.volume = 0.5

    quit:LoadSource("assets/sounds/hold.ogg")
  end;
  __update = function(self, dt)
    local localization = stacked.localization[stacked.controls.active]
    help.text = (
      "Press "..localization.Confirm.." to Play\n"..
      "Hold "..localization.Hold.." for controls"
    )

    controls.text = "CONTROLS\n--------\n"..(
      "Move Left: "..localization.MoveLeft.."\n"..
      "Move Right: "..localization.MoveRight.."\n"..
      "Soft Drop: "..localization.SoftDrop.."\n"..
      "Hard Drop: "..localization.HardDrop.."\n"..
      "Rotate Left: "..localization.RotateCCW.."\n"..
      "Rotate Right: "..localization.RotateCW.."\n"..
      "Hold: "..localization.Hold.."\n"..
      "Extra Action: "..localization.Extra.."\n"
    )

    title.rot = math.sin(stacked.uptime * 2) * 2
  end;
  __input = function(self, event)
    local binds = stacked.controls[stacked.controls.active]
    if event.type:find("Down") then
      if event.button == binds.Hold then
        fader.color.a = 0.75
        controls.color.a = 1
      end
    elseif event.type:find("Up") then
      if event.button == binds.Pause then
        scarlet.exit()
      elseif event.button == binds.Hold then
        fader.color.a = 0
        controls.color.a = 0
      elseif event.button == binds.Extra then
        -- this is ideally where the play can input a seed
      elseif event.button == binds.Confirm then
        start:Play()
        stacked.screens.next = "gameplay"
        stacked.screens:goToNext()
      end
    end
  end;
  __enter = function(self)
    stacked.seeds.main = nil
    stacked.seeds.game = nil
    stacked.seeds.cafe = nil
  end;
  __exit = function(self)
    stacked.seeds.main = stacked.seeds.main or math.floor(stacked.uptime * 1000)
    math.randomseed(stacked.seeds.main)
  end;
}
