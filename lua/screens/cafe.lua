require "classes.screen"
require "classes.shelf"

local bg = Quad.new()
local sign = Label.new()

local activeBorder = Quad.new()
local activeShelves = {}

local cacheCounter = Label.new()
local coffeeShelf = CoffeeShelf.new()
local sodaShelf = SodaShelf.new()
local snackShelf = SnackShelf.new()

local prompt = Label.new()

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
    sign.y = 16
    sign.align.v = 0
    sign:LoadFont("assets/sport.otf", 64)
    sign.text = "HARD DROP CAFE"
    self:AddGizmo(sign)

    activeBorder.x = stacked.scx * 0.5
    activeBorder.y = stacked.scy - 32 + 128
    activeBorder.w = 208
    activeBorder.h = 256
    activeBorder.color = {r = 0, g = 0, b = 0, a = 0.5}
    activeBorder.aux = 0
    self:AddGizmo(activeBorder)

    cacheCounter.x = stacked.scx
    cacheCounter.y = sign.y + 64
    cacheCounter.align.v = 0
    cacheCounter:LoadFont("assets/sport.otf", 32)
    self:AddGizmo(cacheCounter)

    coffeeShelf.x = stacked.scx * 0.4
    coffeeShelf.y = stacked.scy - 16
    self:AddGizmo(coffeeShelf)

    sodaShelf.x = stacked.scx
    sodaShelf.y = stacked.scy - 16
    self:AddGizmo(sodaShelf)

    snackShelf.x = stacked.scx * 1.6
    snackShelf.y = stacked.scy - 16
    self:AddGizmo(snackShelf)

    local binds = stacked.controls[stacked.controls.active]

    prompt.x = stacked.scx
    prompt.y = cacheCounter.y + 48
    prompt.align.y = 0
    prompt:LoadFont("assets/sport.otf", 16)
    prompt.text = "Press "..binds.Cancel.." to Leave"
    self:AddGizmo(prompt)
  end;
  __update = function(self, dt)
    activeBorder.x = stacked.scx * 0.4 + (stacked.scx * 0.6 * activeBorder.aux)
    for i, shelf in ipairs(activeShelves) do
      shelf:Enable(not shelf.__closed and activeBorder.aux == i - 1)
    end
    cacheCounter.text = "Lines Available: "..stacked.gamestate.cache
  end;
  __input = function(self, event)
    local binds = stacked.controls[stacked.controls.active]
    local b = event.button
    if event.type == "KeyDown" then
      if b == binds.Left then
        activeBorder.aux = (activeBorder.aux - 1) % #activeShelves
      elseif b == binds.Right then
        activeBorder.aux = (activeBorder.aux + 1) % #activeShelves
      elseif b == binds.Up then
        for _, shelf in ipairs(activeShelves) do
          if shelf.__enabled then
            shelf:Select(-1)
          end
        end
      elseif b == binds.Down then
        for _, shelf in ipairs(activeShelves) do
          if shelf.__enabled then
            shelf:Select(1)
          end
        end
      elseif b == binds.Confirm then
        for i, shelf in ipairs(activeShelves) do
          if shelf.__enabled then
            shelf:Purchase()
            local enabledItems = 0
            for _, item in ipairs(shelf.items) do
              if not item.__purchased then
                enabledItems = enabledItems + 1
              end
            end
            if enabledItems < 1 then
              shelf:Close()
              table.remove(activeShelves, i)
              activeBorder.aux = activeBorder.aux % #activeShelves
            end
          end
        end
      end
    elseif event.type == "KeyUp" then
      if b == binds.Cancel then
        stacked.screens.next = "gameplay"
        stacked.screens:goToNext()
      end
    end
  end;
  __enter = function(self)
    activeShelves = {}
    activeBorder.aux = 0
    coffeeShelf:Open()
    sodaShelf:Open()
    snackShelf:Open()
    table.insert(activeShelves, coffeeShelf)
    table.insert(activeShelves, sodaShelf)
    table.insert(activeShelves, snackShelf)
    coffeeShelf:Enable(true)
  end;
  __exit = function(self)
    coffeeShelf:Enable(false)
    sodaShelf:Enable(false)
  end;
}
