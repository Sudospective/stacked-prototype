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

local clearLabel = Label.new()

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

    local xOffset = (game.matrix.w * stacked.size * 0.5) + 16

    nextLabel.x = stacked.scx + xOffset
    nextLabel.y = stacked.scy - (game.matrix.h * stacked.size * 0.5) + 4
    nextLabel.align = {h = 0, v = 0}
    nextLabel:LoadFont("assets/sport.otf", 32)
    nextLabel.text = "NEXT"
    self:AddGizmo(nextLabel)

    holdLabel.x = stacked.scx - xOffset
    holdLabel.y = stacked.scy - (game.matrix.h * stacked.size * 0.5) + 4
    holdLabel.align = {h = 1, v = 0}
    holdLabel:LoadFont("assets/sport.otf", 32)
    holdLabel.text = "HOLD"
    self:AddGizmo(holdLabel)

    scoreLabel.x = stacked.scx - xOffset
    scoreLabel.y = stacked.scy
    scoreLabel.align = {h = 1, v = 0.5}
    scoreLabel:LoadFont("assets/sport.otf", 32)
    scoreLabel.text = "SCORE"
    self:AddGizmo(scoreLabel)

    scoreText.x = stacked.scx - xOffset - 4
    scoreText.y = stacked.scy + 32
    scoreText.align = {h = 1, v = 1}
    scoreText:LoadFont("assets/sport.otf", 16)
    scoreText.text = "0"
    self:AddGizmo(scoreText)

    scoreDivider.x = stacked.scx - xOffset - 32
    scoreDivider.y = stacked.scy + 32 + 2
    scoreDivider.w = 64
    scoreDivider.h = 2
    self:AddGizmo(scoreDivider)

    scoreLimit.x = stacked.scx - xOffset - 4
    scoreLimit.y = stacked.scy + 32
    scoreLimit.align = {h = 1, v = 0}
    scoreLimit:LoadFont("assets/sport.otf", 16)
    scoreLimit.text = "0"
    self:AddGizmo(scoreLimit)

    linesLabel.x = stacked.scx - xOffset
    linesLabel.y = stacked.scy + 80
    linesLabel.align = {h = 1, v = 0.5}
    linesLabel:LoadFont("assets/sport.otf", 32)
    linesLabel.text = "LINES"
    self:AddGizmo(linesLabel)

    linesText.x = stacked.scx - xOffset - 4
    linesText.y = stacked.scy + 112
    linesText.align = {h = 1, v = 1}
    linesText:LoadFont("assets/sport.otf", 16)
    linesText.text = "0"
    self:AddGizmo(linesText)

    linesDivider.x = stacked.scx - xOffset - 32
    linesDivider.y = stacked.scy + 112 + 2
    linesDivider.w = 64
    linesDivider.h = 2
    self:AddGizmo(linesDivider)

    linesLimit.x = stacked.scx - xOffset - 4
    linesLimit.y = stacked.scy + 112
    linesLimit.align = {h = 1, v = 0}
    linesLimit:LoadFont("assets/sport.otf", 16)
    linesLimit.text = "0"
    self:AddGizmo(linesLimit)

    game.x = stacked.scx
    game.y = stacked.scy
    self:AddGizmo(game)
  end;
  __update = function(self, dt)
    game:Update(dt)

    scoreText.text = tostring(game.matrix.score)
    scoreLimit.text = tostring(game.matrix.goal)
    linesText.text = tostring(game.matrix.lines)
    linesLimit.text = tostring(game.matrix.limit)
  end;
  __input = function(self, event)
    local b = event.button
    local binds = stacked.controls.keyboard
    if event.type == "KeyDown" then
      if b == binds.MoveLeft then
        game.controlStates.left = true
      elseif b == binds.MoveRight then
        game.controlStates.right = true
      end
    elseif event.type == "KeyUp" then
      if b == binds.MoveLeft then
        game.controlStates.left = false
      elseif b == binds.MoveRight then
        game.controlStates.right = false
      elseif b == "Escape" then
        game:Initialize()
        game:ToTitle()
      end
    end
    if game.levelInProgress then
      game:GameInput(event)
    else
      game:MenuInput(event)
    end
  end;
  __enter = function(self)
    stacked.seed = stacked.seed or math.floor(stacked.uptime * 1000)
    game:NewRound()
  end;
  __exit = function(self)
    stacked.timer.clear()
  end;
}
