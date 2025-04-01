require "classes.screen"
require "classes.shelf"

local bg = Quad.new()
local sign = Label.new()

local activeBorder = Quad.new()
local activeShelves = {}
local selection = Quad.new()

local cacheCounter = Label.new()
local coffeeShelf = CoffeeShelf.new()
local pastryShelf = PastryShelf.new()
local sodaShelf = SodaShelf.new()
local stickerShelf = StickerShelf.new()

local sounds = {
  switch = "assets/sounds/rotate.ogg",
  click = "assets/sounds/lock.ogg",
  purchase = "assets/sounds/clear.ogg",
  reroll = "assets/sounds/purchase.ogg",
  exit = "assets/sounds/hold.ogg",
}

local pause = {
  bg = Quad.new(),
  title = Label.new(),
  quit = Label.new(),
}
local paused = false

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

    activeBorder.x = stacked.scx * 0.4
    activeBorder.y = stacked.scy - 32 + 128
    activeBorder.w = 160
    activeBorder.h = 256
    activeBorder.color = {r = 0, g = 0, b = 0, a = 0.5}
    activeBorder.aux = 0
    self:AddGizmo(activeBorder)

    cacheCounter.x = stacked.scx
    cacheCounter.y = sign.y + 64
    cacheCounter.align.v = 0
    cacheCounter:LoadFont("assets/sport.otf", 32)
    self:AddGizmo(cacheCounter)

    coffeeShelf.x = stacked.scx * 0.25
    coffeeShelf.y = stacked.scy - 16
    self:AddGizmo(coffeeShelf)

    pastryShelf.x = stacked.scx * 0.75
    pastryShelf.y = stacked.scy - 16
    self:AddGizmo(pastryShelf)

    sodaShelf.x = stacked.scx * 1.25
    sodaShelf.y = stacked.scy - 16
    self:AddGizmo(sodaShelf)

    stickerShelf.x = stacked.scx * 1.75
    stickerShelf.y = stacked.scy - 16
    self:AddGizmo(stickerShelf)

    prompt.x = stacked.scx
    prompt.y = cacheCounter.y + 48
    prompt.align.y = 0
    prompt:LoadFont("assets/sport.otf", 16)
    self:AddGizmo(prompt)

    selection.w = 4
    selection.h = 4
    selection.rot = 45
    self:AddGizmo(selection)

    pause.bg.x = stacked.scx
    pause.bg.y = stacked.scy
    pause.bg.w = stacked.sw
    pause.bg.h = stacked.sh
    pause.bg.color = {
      r = 0,
      g = 0,
      b = 0,
      a = 0,
    }
    self:AddGizmo(pause.bg)

    pause.title.x = stacked.scx
    pause.title.y = stacked.scy - 16
    pause.title.align.v = 1
    pause.title:LoadFont("assets/sport.otf", 32)
    pause.title.text = "PAUSED"
    self:AddGizmo(pause.title)

    pause.quit.x = stacked.scx
    pause.quit.y = stacked.scy + 16
    pause.quit.align.v = 0
    pause.quit:LoadFont("assets/sport.otf", 16)
    self:AddGizmo(pause.quit)

    for name, path in pairs(sounds) do
      sounds[name] = Sound.new()
      sounds[name]:LoadSource(path)
      sounds[name].volume = 0.5
    end

    sounds.exit.volume = 1
  end;
  __update = function(self, dt)
    local localization = stacked.localization[stacked.controls.active]
    prompt.text = (
      "Press "..localization.Extra.." to reroll (3 lines)\n"..
      "Press "..localization.Cancel.." to Leave"
    )
    for i, shelf in ipairs(activeShelves) do
      if not shelf.__closed then
        shelf:Enable(not shelf.__closed and activeBorder.aux == i - 1)
        if shelf.__enabled then
          activeBorder.x = shelf.x
        end
      end
    end
    cacheCounter.text = "Lines Available: "..stacked.gamestate.cache

    local item = activeShelves[activeBorder.aux + 1]:GetCurrentItem()
    if item then
      selection.y = item.y + 2
      selection.x = item.x - 72
    else
      selection.x = stacked.scx
      selection.y = stacked.scy
    end

    pause.bg.color.a = paused and 0.75 or 0
    pause.title.color.a = paused and 1 or 0
    pause.quit.color.a = paused and 1 or 0

    local loc = stacked.localization[stacked.controls.active]

    pause.quit.text = (
      "Press "..loc.Pause.." to resume\n"..
      "Press "..loc.Extra.." to quit to Title\n(Will delete current run)"
    )
  end;
  __input = function(self, event)
    if stacked.glossary.enabled then return end
    local binds = stacked.controls[stacked.controls.active]
    local b = event.button
    if event.type == "KeyDown" or event.type == "GamepadDown" then
      if b == binds.Left then
        activeBorder.aux = (activeBorder.aux - 1) % #activeShelves
        while activeShelves[activeBorder.aux + 1].__closed do
          activeBorder.aux = (activeBorder.aux - 1) % #activeShelves
        end
        sounds.switch:Play()
      elseif b == binds.Right then
        activeBorder.aux = (activeBorder.aux + 1) % #activeShelves
        while activeShelves[activeBorder.aux + 1].__closed do
          activeBorder.aux = (activeBorder.aux + 1) % #activeShelves
        end
        sounds.switch:Play()
      elseif b == binds.Up then
        for _, shelf in ipairs(activeShelves) do
          if shelf.__enabled then
            shelf:Select(-1)
            sounds.click:Play()
          end
        end
      elseif b == binds.Down then
        for _, shelf in ipairs(activeShelves) do
          if shelf.__enabled then
            shelf:Select(1)
            sounds.click:Play()
          end
        end
      elseif b == binds.Extra and not paused then
        if stacked.gamestate.cache < 3 then return end
        local shelf = activeShelves[activeBorder.aux + 1]
        if shelf.__enabled then
          shelf:Reroll()
          sounds.reroll:Play()
          stacked.gamestate.cache = stacked.gamestate.cache - 3
        end
      elseif b == binds.Confirm then
        for i, shelf in ipairs(activeShelves) do
          if shelf.__enabled then
            local totalItems = 0
            for _, item in ipairs(shelf.items) do
              if not item.__purchased then
                totalItems = totalItems + 1
              end
            end
            shelf:Purchase()
            local enabledItems = 0
            for _, item in ipairs(shelf.items) do
              if not item.__purchased then
                enabledItems = enabledItems + 1
              end
            end
            if enabledItems < totalItems then
              sounds.purchase:Play()
            end
            if enabledItems < 1 then
              shelf:Close()
              --table.remove(activeShelves, i)
              --i = i - 1
              --activeBorder.aux = activeBorder.aux % #activeShelves
              shelf:Open()
            end
          end
        end
      end
    elseif event.type == "KeyUp" or event.type == "GamepadUp" then
      if b == binds.Cancel and not paused then
        sounds.exit:Play()
        stacked.screens.next = "gameplay"
        stacked.screens:goToNext()
      elseif b == binds.Extra and paused then
        sounds.exit:Play()
        stacked.gamestate = stacked.deepCopy(stacked.default)
        stacked.screens.next = "title"
        stacked.screens:snapToNext()
      elseif b == binds.Pause then
        paused = not paused
      end
    end
  end;
  __enter = function(self)
    stacked.seeds.cafe = math.random(1, 9e9)
    math.randomseed(stacked.seeds.cafe)
    activeShelves = {}
    activeBorder.aux = 0
    coffeeShelf:Open()
    pastryShelf:Open()
    sodaShelf:Open()
    stickerShelf:Open()
    table.insert(activeShelves, coffeeShelf)
    table.insert(activeShelves, pastryShelf)
    table.insert(activeShelves, sodaShelf)
    table.insert(activeShelves, stickerShelf)
    coffeeShelf:Enable(true)
  end;
  __exit = function(self)
    coffeeShelf:Close()
    pastryShelf:Close()
    sodaShelf:Close()
    stickerShelf:Close()
  end;
}
