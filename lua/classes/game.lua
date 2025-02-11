require "classes.ghost"
require "classes.matrix"
require "classes.tetromino"
require "classes.coffee"

class "Game" {
  matrix = Matrix.new();
  curPiece = Tetromino.new();
  nextPiece = {};
  heldPiece = Tetromino.new();
  ghostPiece = Ghost.new();
  readyText = Label.new();
  clearText = Label.new();
  levelText = Label.new();
  callbacks = {};
  timers = {};
  bag = {};
  hand = {};
  actions = {};
  bonuses = {};
  timings = {};
  coffees = {};
  controlStates = {};
  alreadyHeld = false;
  hardDropping = false;
  dropDistance = 0;
  lastMove = 0;
  lastAction = 0;
  repeatingAction = false;
  lastRotTest = {0, 0};
  levelInProgress = false;
  readyToLock = false;
  clearType = 0;
  lockTime = 0.5;
  dropTime = 1;
  timeSinceEvent = 0;
  timeUntilARR = 0;
  over = false;
  __init = function(self)
    self.readyText.x = stacked.scx
    self.readyText.y = stacked.scy
    self.readyText:LoadFont("assets/sport.otf", 32)

    self.clearText.x = stacked.scx
    self.clearText.y = stacked.scy - 32
    self.clearText:LoadFont("assets/sport.otf", 32)
    self.clearText.color.a = 0

    self:Initialize();
  end;
  Initialize = function(self)
    self.matrix:Initialize();
    self.matrix.x = stacked.scx
    self.matrix.y = stacked.scy

    self.bag = {
      IPiece.new(),
      OPiece.new(),
      TPiece.new(),
      JPiece.new(),
      LPiece.new(),
      SPiece.new(),
      ZPiece.new(),
    }
    self.hand = {}
    self.actions = stacked.deepCopy(stacked.actions)
    self.bonuses = stacked.deepCopy(stacked.bonuses)
    self.timings = {
      das = 0.167,
      arr = 0.033,
      are = 0.100,
    }
    self.clearTypes = {
      normal = false,
      tspin = false,
      mini = false,
      allclear = false,
    }
    self.controlStates = {
      left = false,
      right = false,
      down = false,
    }
    self.curPiece = Tetromino:new()
    self.nextPiece = { n = 3 }
    self.heldPiece = Tetromino:new()
    self.alreadyHeld = false
    self.lastMove = 0
    self.repeatingAction = false
    self.lastRotTest = {0, 0}
    self.dropTime = (0.8 - ((stacked.gamestate.level - 1) * 0.007)) ^ (stacked.gamestate.level - 1)
    self.levelInProgress = false

    self.timers.ready = stacked.timer.new()
    self.timers.clear = stacked.timer.new()
  end;
  NewRound = function(self)
    self.over = false
    math.randomseed(stacked.seed)
    self.matrix:ResetCells()
    self.matrix:ResetScore()
    self.matrix:SetCriteria()
    self.hand = {}
    self.curPiece = Tetromino.new()
    self.nextPiece = { n = self.nextPiece.n }
    self.heldPiece = Tetromino.new()
    self.alreadyHeld = false
    self.lastMove = 0
    self.lastRotTest = {0, 0}
    self:PushNextPiece()
    self.dropTime = (0.8 - ((stacked.gamestate.level - 1) * 0.007)) ^ (stacked.gamestate.level - 1)
    self:StartRound()
  end;
  StartRound = function(self)
    self.readyText.text = (
      "Score\n"..
      tostring(math.floor(self.matrix.goal)).." points\n"..
      "in\n"..
      tostring(self.matrix.limit).." lines"
    )
    if self.boss then
      self.readyText.text = self.boss.description
    end
    self.timers.ready:after(3, function()
      self.readyText.text = "READY..."
    end)
    self.timers.ready:after(4, function()
      self.readyText.text = "GO!!"
      self.levelInProgress = true
      self.timers.ready:during(1, function(dt)
        self.readyText.color.a = self.readyText.color.a - dt
      end)
    end)
    self.timers.ready:after(5, function()
      self.readyText.text = ""
    end)
  end;
  EndRound = function(self)
    if stacked.gamestate.level > 10 then
      self.readyText.text = "YOU\nWIN!"
    end

    self.levelInProgress = false
    stacked.gamestate.stats = stacked.deepCopy(self.matrix.stats)
    local deposit = self.matrix.limit - self.matrix.lines
    stacked.gamestate.cache = stacked.gamestate.cache + deposit
  end;
  GetRandomPiece = function(self)
    if #self.hand < 1 then
      self:RefillHand()
    end
    local index = math.ceil(math.random() * #self.hand)
    local piece = self.hand[index]
    table.remove(self.hand, index)
    return piece
  end;
  PushNextPiece = function(self)
    if self.curPiece.id == 0 then
      self.curPiece = self:GetRandomPiece()
      for i = 1, self.nextPiece.n do
        self.nextPiece[i] = self:GetRandomPiece()
      end
    else
      self.curPiece = self.nextPiece[1]
      if self.nextPiece.n > 1 then
        for i = 2, self.nextPiece.n do
          if self.nextPiece[i] then
            self.nextPiece[i - 1] = self.nextPiece[i]
          end
        end
      end
      self.nextPiece[self.nextPiece.n] = self:GetRandomPiece()
    end
  end;
  RefillHand = function(self)
    self.hand = stacked.deepCopy(self.bag)
  end;
  IsPieceOutside = function(self)
    local cells = self.curPiece:GetCellPositions()
    for _, cell in pairs(cells) do
      if self.matrix:IsCellOutside(cell[1], cell[2]) then
        return true
      end
    end
    return false
  end;
  IsPieceColliding = function(self)
    local cells = self.curPiece:GetCellPositions()
    for _, cell in pairs(cells) do
      if not self.matrix:IsCellEmpty(cell[1], cell[2]) then
        return true
      end
    end
    return false
  end;
  IsGhostOutside = function(self)
    local cells = self.ghostPiece:GetCellPositions()
    for _, cell in pairs(cells) do
      if self.matrix:IsCellOutside(cell[1], cell[2]) then
        return true
      end
    end
    return false
  end;
  IsGhostColliding = function(self)
    local cells = self.ghostPiece:GetCellPositions()
    for _, cell in pairs(cells) do
      if not self.matrix:IsCellEmpty(cell[1], cell[2]) then
        return true
      end
    end
    return false
  end;
  MoveLeft = function(self)
    self.curPiece:Move(0, -1)
    if self:IsPieceOutside() or self:IsPieceColliding() then
      self.curPiece:Move(0, 1)
      return
    end
    self.lastMove = 1
    self.timeUntilLock = self.lockTime
  end;
  MoveRight = function(self)
    self.curPiece:Move(0, 1)
    if self:IsPieceOutside() or self:IsPieceColliding() then
      self.curPiece:Move(0, -1)
      return
    end
    self.lastMove = 1
    self.timeUntilLock = self.lockTime
  end;
  Rotate = function(self, ccw)
    self.curPiece:Rotate(ccw)
    local fits = false
    for _, offset in ipairs(self.curPiece.kicks[self.curPiece.rotState][self.curPiece.lastRot]) do
      self.lastRotTest[1] = self.curPiece.rotState
      self.lastRotTest[2] = self.curPiece.lastRot
      self.curPiece:Move(-offset[2], offset[1])
      if self:IsPieceOutside() or self:IsPieceColliding() then
        self.curPiece:Move(offset[2], -offset[1])
      else
        fits = true
        break
      end
    end
    if not fits then
      self.curPiece:Rotate(not ccw)
    else
      self.lastMove = 2
      self:ResetLock()
    end
  end;
  RotateCW = function(self)
    self:Rotate()
  end;
  RotateCCW = function(self)
    self:Rotate(true)
  end;
  SoftDrop = function(self)
    self.curPiece:Move(1, 0)
    if self:IsPieceOutside() or self:IsPieceColliding() then
      self.curPiece:Move(-1, 0)
      self.timeUntilLock = self.lockTime
      self.readyToLock = true
    elseif self.controlStates.down then
      local action = {
        drop = "soft",
        rows = 1
      }
      self:AwardPoints(action)
    end
  end;
  HardDrop = function(self)
    self.hardDropping = true
    self.dropDistance = self.ghostPiece.row.offset - self.curPiece.row.offset
    local action = {
      drop = "hard",
      rows = self.dropDistance
    }
    if action.rows > 0 then self:AwardPoints(action) end
    local piece = self.curPiece
    self.curPiece.row.offset = self.ghostPiece.row.offset
    -- just in case
    self.curPiece.column.offset = self.ghostPiece.column.offset
    self:LockToMatrix()
  end;
  Hold = function(self)
    if self.alreadyHeld then return end
    local curPiece = self.curPiece
    if self.heldPiece.id ~= 0 then
      self.curPiece = self.heldPiece
    else
      self:PushNextPiece()
    end
    self.heldPiece = curPiece
    self.curPiece.row.offset = 0
    self.curPiece.column.offset = 0
    self.curPiece.rotState = 1
    self.heldPiece.row.offset = 0
    self.heldPiece.column.offset = 0
    self.heldPiece.rotState = 1
    self.alreadyHeld = true
    self.readyToLock = false
  end;
  PositionGhost = function(self)
    self.ghostPiece:Copy(self.curPiece)
    while not self:IsGhostColliding() and not self:IsGhostOutside() do
      self.ghostPiece:Move(1, 0)
      if self:IsGhostOutside() or self:IsGhostColliding() then
        self.ghostPiece:Move(-1, 0)
        self.dropDistance = self.ghostPiece.column.offset - self.curPiece.column.offset
        break
      end
    end
  end;
  DropTriggered = function(self, dt, interval)
    self.timeSinceDrop = self.timeSinceDrop + dt
    if self.timeSinceDrop >= interval then
      self.timeSinceDrop = 0
      return true
    end
  end;
  EventTriggered = function(self, dt, interval)
    self.timeSinceEvent = self.timeSinceEvent + dt
    if self.timeSinceEvent >= interval then
      self.timeSinceEvent = 0
      return true
    end
    return false
  end;
  ResetEventTimer = function(self)
    self.timeSinceEvent = 0
  end;
  ResetLock = function(self)
    self.readyToLock = false
    self:ResetEventTimer()
  end;
  ARRTriggered = function(self, dt, interval)
    if (
      not self.controlStates.left
      and not self.controlStates.right
    ) then
      return false
    end
    self.timeUntilARR = self.timeUntilARR + dt
    if self.timeUntilARR >= interval then
      self.timeUntilARR = 0
      return true
    end
    return false
  end;
  PrepareLock = function(self, dt, interval)
    if self.curPiece.row.offset ~= self.ghostPiece.row.offset then
      self.readyToLock = false
      self.timeUntilLock = interval
      return false
    end
    self.timeUntilLock = self.timeUntilLock - dt
    if self.timeUntilLock <= 0 then
      self:LockToMatrix()
      self.timeUntilLock = interval
      return true
    end
    return false
  end;
  LockToMatrix = function(self)
    local cells = self.curPiece:GetCellPositions()
    for _, cell in pairs(cells) do
      self.matrix.cells[cell[1]][cell[2]] = self.curPiece.id
    end
    local action = {
      spin = self:CheckSpin(),
      b2b = self:CheckB2B(),
      allclear = self:CheckAllClear(),
      rows = self.matrix:ClearFullRows(),
    }
    if action.rows == 0 then
      self.matrix.combo = -1
    else
      self.matrix.combo = self.matrix.combo + 1
    end
    if action.rows > 0 or action.spin then
      self:AwardPoints(action)
    end
    self:PushNextPiece()
    if self:IsPieceColliding() then
      self:GameOver()
    end
    self.alreadyHeld = false
    for name in pairs(self.clearTypes) do
      self.clearTypes[name] = false
    end
    self:ResetLock()
    if self.matrix.score >= self.matrix.goal then
      self:RoundClear()
    end
  end;
  CheckSpin = function(self)
    local spin = nil
    if (
      self.dropDistance > 0
      or self.curPiece.id ~= 3
      or self.lastMove ~= 2
    ) then
      return nil
    end

    local corners = {
      n = 0,
      -- O
      { {0, 0}, {0, 2}, {2, 0}, {2, 2}, covered = false },
      -- R
      { {0, 2}, {2, 2}, {0, 0}, {2, 0}, covered = false },
      -- 2
      { {2, 2}, {2, 0}, {0, 2}, {0, 0}, covered = false },
      -- L
      { {2, 0}, {0, 0}, {2, 2}, {0, 2}, covered = false },
    }
    for _, corner in ipairs(corners[self.curPiece.rotState]) do
      local cell = {
        corner[1] + self.curPiece.row.start + self.curPiece.row.offset - 1,
        corner[2] + self.curPiece.column.start + self.curPiece.column.offset,
      }
      if (
        cell[1] >= self.matrix.h
        or not self.matrix:IsCellEmpty(cell[1], cell[2])
      ) then
        corners.n = corners.n + 1
        corner.covered = true
      end
    end
    if corners.n >= 2 and self.lastRotTest[1] == 5 then
      spin = "full"
    elseif corners.n >= 3 then
      local set = corners[self.curPiece.rotState]
      if set[1].covered and set[2].covered then
        if set[3].covered or set[4].covered then
          spin = "full"
        end
      elseif set[3].covered and set[4].covered then
        if set[1].covered or set[2].covered then
          spin = "mini"
        end
      end
    end
    if spin then
      local stats = self.matrix.stats
      if spin == "full" then
        stats.tspin = stats.tspin + 1
      elseif spin == "mini" then
        stats.mini = stats.mini + 1
      end
    end
    return spin
  end;
  CheckB2B = function(self)
    local b2b = self.lastAction == 2
    if b2b then
      self.matrix.stats.b2b = self.matrix.stats.b2b + 1
    end
    return b2b
  end;
  CheckAllClear = function(self)
    local allclear = true
    for row = -self.matrix.buffer, self.matrix.h - 1 do
      for column = 0, self.matrix.w - 1 do
        if not self.matrix:IsCellEmpty(row, column) then
          allclear = false
          break
        end
      end
    end
    if allclear then
      self.matrix.stats.allclear = self.matrix.stats.allclear + 1
    end
    return allclear
  end;
  AwardPoints = function(self, action)
    local points = 0
    action.rows = action.rows or 0
    local lvl = stacked.gamestate.level

    if action.drop then
      points = self.actions.drop[action.drop] * action.rows * lvl
    else
      local base
      if action.spin then
        base = self.actions.tspin[action.spin]
      else
        base = self.actions
      end
      if action.spin and action.rows == 0 then
        points = base.none * lvl
      elseif action.rows == 1 then
        points = base.single * lvl
      elseif action.rows == 2 then
        points = base.double * lvl
      elseif action.rows == 3 then
        points = base.triple * lvl
      elseif action.rows == 4 then
        points = base.tetra * lvl
      end

      if self.matrix.combo > 0 then
        points = points + (50 * self.matrix.combo * lvl)
      end

      if not (action.spin or action.rows == 4) then
        action.b2b = false
      end

      if action.b2b then
        if action.spin then
          if action.rows == 1 then
            points = points + (base.single * lvl * self.bonuses.b2b)
          elseif action.rows == 2 then
            points = points + (base.double * lvl * self.bonuses.b2b)
          elseif action.rows == 3 then
            points = points + (base.triple * lvl * self.bonuses.b2b)
          end
        elseif action.rows == 4 then
          points = points + (base.tetra * lvl * self.bonuses.b2b)
        end
      end

      if action.allclear then
        if action.rows == 1 then
          points = points + (800 * lvl)
        elseif action.rows == 2 then
          points = points + (1200 * lvl)
        elseif action.rows == 3 then
          points = points + (1800 * lvl)
        elseif action.rows == 4 then
          points = points + ((action.b2b and 3200 or 2000) * lvl)
        end
      end

      if (
        action.rows == 4
        or action.spin and action.rows > 0
      ) then
        self.lastAction = 2
      else
        self.lastAction = 1
      end
    end
    
    self.clearText.text = tostring(points)
    self.clearText.color.a = 1
    
    self.timers.clear:clear()
    self.timers.clear:during(1, function(dt)
      self.clearText.color.a = self.clearText.color.a - dt
      self.clearText.y = self.clearText.y - dt * 5
    end, function()
      self.clearText.color.a = 0
      self.clearText.y = stacked.scy - 32
    end)

    self.matrix.score = self.matrix.score + points
  end;
  RoundClear = function(self)
    stacked.gamestate.level = stacked.gamestate.level + 1
    self.readyText.text = "CLEAR!"
    self:EndRound()
    stacked.seed = math.floor(stacked.uptime * 1000)
    self.callbacks.cafe = stacked.timer.after(4, function()
      self.callbacks.cafe = nil
      self:ToCafe()
    end)
  end;
  ToCafe = function(self)
    stacked.screens.next = "cafe"
    stacked.screens:goToNext()
  end;
  ToTitle = function(self)
    stacked.screens.next = "title"
    stacked.screens:goToNext()
  end;
  GameOver = function(self)
    self.over = true
    self.readyText.text = "GAME\nOVER"
    self:EndRound()
    stacked.seed = math.floor(stacked.uptime * 1000)
  end;
  GameInput = function(self, event)
    local b = event.button
    -- Keyboard
    if event.type == "KeyDown" then
      local binds = stacked.controls.keyboard
      if b == binds.MoveLeft then
        self:MoveLeft()
      elseif b == binds.MoveRight then
        self:MoveRight()
      elseif b == binds.SoftDrop then
        self.controlStates.down = true
      elseif b == binds.HardDrop then
        self:HardDrop()
      elseif b == binds.RotateCW then
        self:RotateCW()
      elseif b == binds.RotateCCW then
        self:RotateCCW()
      elseif b == binds.Hold then
        self:Hold()
      end
    elseif event.type == "KeyUp" then
      local binds = stacked.controls.keyboard
      if b == binds.SoftDrop then
        self.controlStates.down = false
      end
    end
  end;
  MenuInput = function(self, event)
    if event.type == "KeyUp" then
    end
  end;
  Update = function(self, dt)
    for _, handle in pairs(self.timers) do
      handle:update(dt)
    end

    self:PositionGhost()

    if not self.levelInProgress then return end

    if not self.readyToLock and (
      (
        self.controlStates.down
        and self:EventTriggered(dt, self.dropTime / 20)
      )
      or (
        not self.controlStates.down
        and self:EventTriggered(dt, self.dropTime)
      )
    ) then
      self:SoftDrop()
    elseif self.levelInProgress and self.readyToLock then
      if self:EventTriggered(dt, self.lockTime) then
        self:LockToMatrix()
      end
    end
    if self.controlStates.left or self.controlStates.right then
      if (
        self.repeatingAction
        and self:ARRTriggered(dt, self.timings.arr)
      ) or (
        not self.repeatingAction
        and self:ARRTriggered(dt, self.timings.das)
      ) then
        self.repeatingAction = true
        if self.controlStates.left then
          self:MoveLeft()
        end
        if self.controlStates.right then
          self:MoveRight()
        end
      end
    else
      self.repeatingAction = false
      self.timeUntilARR = 0
    end
  end;
  Draw = function(self)
    local offset = {
      current = {
        x = stacked.scx - self.matrix.w * stacked.size * 0.5,
        y = stacked.scy - self.matrix.h * stacked.size * 0.5,
      },
      next = {
        x = stacked.scx + self.matrix.w * stacked.size * 0.3,
        y = stacked.scy - self.matrix.h * stacked.size * 0.3,
      },
      held = {
        x = stacked.scx - self.matrix.w * stacked.size * 1.3,
        y = stacked.scy - self.matrix.h * stacked.size * 0.25,
      }
    }
    self.matrix:Draw()
    for i = self.nextPiece.n, 1, -1 do
      local nextOffset = stacked.deepCopy(offset.next)
      nextOffset.y = nextOffset.y + (i - 1) * ((self.matrix.h * (stacked.size - 3) / self.nextPiece.n)) + stacked.size * 1.5
      self.nextPiece[i]:Draw(nextOffset.x, nextOffset.y)
    end
    self.heldPiece:Draw(offset.held.x, offset.held.y)
    self.ghostPiece:Draw(offset.current.x, offset.current.y)
    self.curPiece:Draw(offset.current.x, offset.current.y)

    self.readyText:Draw()
    self.clearText:Draw()
  end;
}
