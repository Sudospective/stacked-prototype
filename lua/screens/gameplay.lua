require "classes.screen"
require "classes.game"

local bg = Quad.new()

local nextLabel = Label.new()
local holdLabel = Label.new()

local scoreLabel = Label.new()
local scoreText = Label.new()
local scoreDivider = Quad.new()
local scoreLimit = Label.new()

local linesLabel = Label.new()
local linesText = Label.new()
local linesDivider = Quad.new()
local linesLimit = Label.new()

local levelLabel = Label.new()

local brewsLabel = Label.new()
local brewsText = Label.new()

local pause = {
  bg = Quad.new(),
  title = Label.new(),
}

local game = Game.new()

class "Gameplay" : extends "Screen" {
  title = "Gameplay";
  __init = function(self)
    if stacked.gamestate.level == 1 then
      game:Initialize()
    end

    bg.x = stacked.scx
    bg.y = stacked.scy
    bg.w = stacked.sw
    bg.h = stacked.sh
    bg.color = {
      r = 0.1,
      g = 0.2,
      b = 0.3,
      a = 1.0,
    }
    self:AddGizmo(bg)

    local xOffset = (10 * 16 * 0.5) + 16
    local yOffset = (20 * 16 * 0.5) + 4

    nextLabel.x = stacked.scx + xOffset
    nextLabel.y = stacked.scy - yOffset
    nextLabel.align = {h = 0, v = 0}
    nextLabel:LoadFont("assets/sport.otf", 32)
    nextLabel.text = "NEXT"
    self:AddGizmo(nextLabel)

    holdLabel.x = stacked.scx - xOffset
    holdLabel.y = stacked.scy - yOffset
    holdLabel.align = {h = 1, v = 0}
    holdLabel:LoadFont("assets/sport.otf", 32)
    holdLabel.text = "HOLD"
    self:AddGizmo(holdLabel)

    scoreLabel.x = stacked.scx - xOffset
    scoreLabel.y = stacked.scy - 16
    scoreLabel.align = {h = 1, v = 0.5}
    scoreLabel:LoadFont("assets/sport.otf", 32)
    scoreLabel.text = "SCORE"
    self:AddGizmo(scoreLabel)

    scoreText.x = stacked.scx - xOffset - 4
    scoreText.y = stacked.scy + 16
    scoreText.align = {h = 1, v = 1}
    scoreText:LoadFont("assets/sport.otf", 16)
    scoreText.text = "0"
    self:AddGizmo(scoreText)

    scoreDivider.x = stacked.scx - xOffset - 32
    scoreDivider.y = stacked.scy + 16 + 2
    scoreDivider.w = 64
    scoreDivider.h = 2
    self:AddGizmo(scoreDivider)

    scoreLimit.x = stacked.scx - xOffset - 4
    scoreLimit.y = stacked.scy + 16
    scoreLimit.align = {h = 1, v = 0}
    scoreLimit:LoadFont("assets/sport.otf", 16)
    scoreLimit.text = "0"
    self:AddGizmo(scoreLimit)

    linesLabel.x = stacked.scx - xOffset
    linesLabel.y = stacked.scy + 64
    linesLabel.align = {h = 1, v = 0.5}
    linesLabel:LoadFont("assets/sport.otf", 32)
    linesLabel.text = "LINES"
    self:AddGizmo(linesLabel)

    linesText.x = stacked.scx - xOffset - 4
    linesText.y = stacked.scy + 96
    linesText.align = {h = 1, v = 1}
    linesText:LoadFont("assets/sport.otf", 16)
    linesText.text = "0"
    self:AddGizmo(linesText)

    linesDivider.x = stacked.scx - xOffset - 32
    linesDivider.y = stacked.scy + 96 + 2
    linesDivider.w = 64
    linesDivider.h = 2
    self:AddGizmo(linesDivider)

    linesLimit.x = stacked.scx - xOffset - 4
    linesLimit.y = stacked.scy + 96
    linesLimit.align = {h = 1, v = 0}
    linesLimit:LoadFont("assets/sport.otf", 16)
    linesLimit.text = "0"
    self:AddGizmo(linesLimit)

    levelLabel.x = stacked.scx - xOffset
    levelLabel.y = stacked.scy + yOffset - 8
    levelLabel.align = {h = 1, v = 1}
    levelLabel:LoadFont("assets/sport.otf", 32)
    levelLabel.text = "LEVEL 0"
    self:AddGizmo(levelLabel)

    brewsLabel.x = stacked.scx - xOffset * 2 - 16
    brewsLabel.y = stacked.scy - yOffset
    brewsLabel.align = {h = 1, v = 0}
    brewsLabel:LoadFont("assets/sport.otf", 32)
    brewsLabel.text = "COFFEE"
    self:AddGizmo(brewsLabel)

    brewsText.x = stacked.scx - (xOffset * 2) - 58
    brewsText.y = stacked.scy - yOffset + 32
    brewsText.align.v = 0
    brewsText:LoadFont("assets/sport.otf", 16)
    self:AddGizmo(brewsText)

    game.x = stacked.scx
    game.y = stacked.scy
    self:AddGizmo(game)

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
    pause.title.y = stacked.scy
    pause.title:LoadFont("assets/sport.otf", 32)
    pause.title.text = "PAUSED"
    self:AddGizmo(pause.title)
  end;
  __update = function(self, dt)
    game:Update(dt)

    scoreText.text = tostring(game.matrix.score)
    scoreLimit.text = tostring(game.matrix.goal)
    linesText.text = tostring(game.matrix.lines)
    linesLimit.text = tostring(game.matrix.limit)

    pause.bg.color.a = game.paused and 1 or 0
    pause.title.color.a = game.paused and 1 or 0
  end;
  __input = function(self, event)
    local b = event.button
    local binds = stacked.controls[stacked.controls.active]
    if event.type == "KeyDown" or event.type == "GamepadDown" then
      if b == binds.MoveLeft then
        game.controlStates.left = true
      elseif b == binds.MoveRight then
        game.controlStates.right = true
      end
    elseif event.type == "KeyUp" or event.type == "GamepadUp" then
      if b == binds.MoveLeft then
        game.controlStates.left = false
      elseif b == binds.MoveRight then
        game.controlStates.right = false
      elseif b == binds.Pause then
        if not game.paused then
          game:Pause()
        else
          game:Unpause()
        end
      end
    end
    if game.levelInProgress then
      game:GameInput(event)
    end
  end;
  __enter = function(self)
    stacked.seeds.game = math.random(1, 9e9)
    math.randomseed(stacked.seeds.game)
    levelLabel.text = "LEVEL "..stacked.gamestate.level
    brewsText.text = ""
    local counts = {}
    for _, brew in ipairs(stacked.gamestate.brews) do
      counts[brew.name] = counts[brew.name] or 0
      counts[brew.name] = counts[brew.name] + 1
    end

    for name, count in pairs(counts) do
      brewsText.text = brewsText.text..tostring(name).." x "..tostring(count).."\n"
    end

    if #stacked.gamestate.brews == 0 then
      brewsText.text = "No brews"
    end
    if game.over then
      game:NewGame()
    else
      game:NewRound()
    end
  end;
  __exit = function(self)
    stacked.timer.clear()
  end;
}
