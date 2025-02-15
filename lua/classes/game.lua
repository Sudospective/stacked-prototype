require "classes.ghost"
require "classes.matrix"
require "classes.tetromino"

class "Game" {
  matrix = Matrix.new();
  fader = Quad.new();
  smear = Quad.new();
  curPiece = Tetromino.new();
  nextPiece = {};
  heldPiece = Tetromino.new();
  ghostPiece = Ghost.new();
  readyText = Label.new();
  clearText = Label.new();
  levelText = Label.new();
  sounds = {};
  callbacks = {};
  timers = {};
  bag = {};
  hand = {};
  actions = {};
  bonuses = {};
  timings = {};
  controlStates = {};
  timesHeld = 0;
  hardDropping = false;
  dropDistance = 0;
  freezeInput = false;
  lastMove = 0;
  lastKick = 0;
  lastAction = 0;
  infinity = false;
  extendCounter = 0;
  repeatingAction = false;
  lastRotTest = {0, 0};
  levelInProgress = false;
  readyToLock = false;
  clearType = 0;
  spawnTime = 0.2;
  lockTime = 0.5;
  dropTime = 1;
  timeSinceEvent = 0;
  timeUntilARR = 0;
  timeUntilLock = 0;
  over = false;
  won = false;
  __init = function(self)
    self.readyText.x = stacked.scx
    self.readyText.y = stacked.scy
    self.readyText:LoadFont("assets/sport.otf", 32)

    self.clearText.x = stacked.scx
    self.clearText.y = stacked.scy - 32
    self.clearText:LoadFont("assets/sport.otf", 32)
    self.clearText.color.a = 0

    self.sounds = {
      rotate = "assets/sounds/rotate.ogg",
      lock = "assets/sounds/lock.ogg",
      clear = "assets/sounds/clear.ogg",
      tspin = "assets/sounds/tspin.ogg",
      complete = "assets/sounds/complete.ogg",
      lines = "assets/sounds/lines.ogg",
    }

    for name, path in pairs(self.sounds) do
      self.sounds[name] = Sound.new()
      self.sounds[name]:LoadSource(path)
      self.sounds[name].volume = 0.5
    end

    self.sounds.lines.volume = 1

    self:Initialize();
  end;
  Initialize = function(self)
    self.matrix:Initialize();
    self.matrix.x = stacked.scx
    self.matrix.y = stacked.scy
    self.matrix.h = stacked.gamestate.height
    stacked.size = 16 * (20 / self.matrix.h)

    self.fader.color = {
      r = 0,
      g = 0,
      b = 0,
      a = 0,
    }

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
    self.controlStates = {
      left = false,
      right = false,
      down = false,
    }
    self.curPiece = Tetromino:new()
    self.nextPiece = { n = stacked.gamestate.queue }
    self.heldPiece = Tetromino:new()
    self.timesHeld = 0
    self.lastMove = 0
    self.repeatingAction = false
    self.lastRotTest = {0, 0}
    self.dropTime = (0.8 - ((stacked.gamestate.level - 1) * 0.007)) ^ (stacked.gamestate.level - 1)
    self.levelInProgress = false
    
    -- fill gamestate
    self.matrix:FillToGamestate()

    self.timers.ready = stacked.timer.new()
    self.timers.clear = stacked.timer.new()
  end;
  NewGame = function(self)
    -- restore defaults
    stacked.gamestate = stacked.deepCopy(stacked.default)
    stacked.bites = loadfile("assets/bites.lua")()
    self:Initialize()
    self:NewRound()
  end;
  NewRound = function(self)
    self.over = false
    math.randomseed(stacked.seed)

    self.matrix.h = stacked.gamestate.height
    self.matrix.w = stacked.gamestate.width
    stacked.size = 16 * (20 / self.matrix.h)

    self.matrix:FillFromGamestate()
    self.matrix:ResetCells()
    self.matrix:ResetScore()
    self.matrix:SetCriteria()

    self.hand = {}
    self.curPiece = Tetromino.new()
    self.nextPiece = { n = stacked.gamestate.queue }
    self.heldPiece = Tetromino.new()
    self.timesHeld = 0
    self.lastMove = 0
    self.lastRotTest = {0, 0}
    self.infinity = stacked.gamestate.infinity
    self.dropTime = (0.8 - ((stacked.gamestate.level - 1) * 0.007)) ^ (stacked.gamestate.level - 1)
    self:PushNextPiece()
    self:StartRound()
  end;
  StartRound = function(self)
    self.timers.ready:clear()
    self.fader.color.a = 0.5
    self.readyText.color.a = 1
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
      self.fader.color.a = 0
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
    self.timers.ready:clear()
    self.fader.color.a = 0.5
    self.readyText.color.a = 1
    if stacked.gamestate.level > 10 and not self.won then
      self.won = true
      self.readyText.text = "YOU\nWIN!"
    end

    self.levelInProgress = false
    local deposit = self.matrix.limit - self.matrix.lines
    stacked.gamestate.cache = stacked.gamestate.cache + deposit

    self.matrix:FillToGamestate()
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
    self.curPiece.next = false
    for i = 1, self.nextPiece.n do
      self.nextPiece[i].next = true
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
    if self.infinity or self.extendCounter < 15 then
      self.extendCounter = self.extendCounter + 1
      self.timeUntilLock = self.lockTime
    end
  end;
  MoveRight = function(self)
    self.curPiece:Move(0, 1)
    if self:IsPieceOutside() or self:IsPieceColliding() then
      self.curPiece:Move(0, -1)
      return
    end
    self.lastMove = 1
    if self.infinity or self.extendCounter < 15 then
      self.extendCounter = self.extendCounter + 1
      self.timeUntilLock = self.lockTime
    end
  end;
  Rotate = function(self, ccw)
    self.curPiece:Rotate(ccw)
    local fits = false
    for i, offset in ipairs(self.curPiece.kicks[self.curPiece.rotState][self.curPiece.lastRot]) do
      self.lastRotTest[1] = self.curPiece.rotState
      self.lastRotTest[2] = self.curPiece.lastRot
      self.curPiece:Move(-offset[2], offset[1])
      if self:IsPieceOutside() or self:IsPieceColliding() then
        self.curPiece:Move(offset[2], -offset[1])
      else
        fits = true
        self.lastKick = i
        break
      end
    end
    if not fits then
      self.curPiece:Rotate(not ccw)
    else
      self.lastMove = 2
      self.sounds.rotate:Play()
      self:CheckSpin(true)
      if self.infinity or self.extendCounter < 15 then
        self.extendCounter = self.extendCounter + 1
        self:ResetLock()
      end
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
    self.dropDistance = self.ghostPiece.row.offset - self.curPiece.row.offset
    local action = {
      drop = "hard",
      rows = self.dropDistance
    }
    if action.rows > 0 then self:AwardPoints(action) end
    self.curPiece.row.offset = self.ghostPiece.row.offset
    -- just in case
    self.curPiece.column.offset = self.ghostPiece.column.offset

    self:LockToMatrix()
  end;
  Hold = function(self)
    if self.timesHeld >= stacked.gamestate.hold then return end
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
    self.readyToLock = false
    
    self.timesHeld = self.timesHeld + 1
  end;
  PositionGhost = function(self)
    self.ghostPiece:Copy(self.curPiece)
    while not self:IsGhostColliding() and not self:IsGhostOutside() do
      self.ghostPiece:Move(1, 0)
      if self:IsGhostOutside() or self:IsGhostColliding() then
        self.ghostPiece:Move(-1, 0)
        self.dropDistance = self.ghostPiece.row.offset - self.curPiece.row.offset
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
    self.extendCounter = 0
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
    if self.callbacks.lock then return end
    local cells = self.curPiece:GetCellPositions()
    for _, cell in pairs(cells) do
      self.matrix.cells[cell[1]][cell[2]] = self.curPiece.id
    end
    self.sounds.lock:Play()
    local action = {
      spin = self:CheckSpin(),
      b2b = self:CheckB2B(),
      allclear = self:CheckAllClear(),
      rows = self.matrix:CountFullRows(),
    }
    if action.rows == 0 then
      self.matrix.combo = -1
    else
      self.sounds.clear:Play()
      self.matrix.combo = self.matrix.combo + 1
    end
    if action.rows > 0 or action.spin then
      self:AwardPoints(action)
    end

    for row = self.matrix.h - 1, -self.matrix.buffer, -1 do
      if self.matrix:IsRowFull(row) then
        for column = 0, self.matrix.w - 1 do
          self.matrix.cells[row][column] = 8
        end
      end
    end

    self.curPiece.visible = false
    self.ghostPiece.visible = false

    stacked.timer.clear()

    if action.rows > 0 then
      self.fader.color.a = 0.5
    end

    self.callbacks.fade = stacked.timer.after(
      action.rows > 0 and 1 or 0,
      function()
        self.callbacks.fade = nil
        self.fader.color.a = 0
      end
    )

    self.freezeInput = true
    self.callbacks.lock = stacked.timer.after(action.rows > 0 and 1 or self.spawnTime, function()
      self.freezeInput = false
      self.callbacks.lock = nil
      self.curPiece.visible = true
      self.ghostPiece.visible = true
      self:PushNextPiece()
      self.timesHeld = 0
      self.matrix:ClearFullRows()
      self:ResetLock()
      if self.matrix.score >= self.matrix.goal then
        self:RoundClear()
      elseif self.matrix.lines >= self.matrix.limit or self:IsPieceColliding() then
        self:GameOver()
      end
    end)

  end;
  CheckSpin = function(self, play)
    if (
      self.dropDistance > 0
      or self.curPiece.id ~= 3
      or self.lastMove ~= 2
    ) then
      return nil
    end

    play = play or false

    local spin = nil

    local corners = {
      n = 0,
      -- O
      { {0, 0}, {0, 2}, {2, 0}, {2, 2} },
      -- R
      { {0, 2}, {2, 2}, {0, 0}, {2, 0} },
      -- 2
      { {2, 2}, {2, 0}, {0, 2}, {0, 0} },
      -- L
      { {2, 0}, {0, 0}, {2, 2}, {0, 2} },
    }
    for _, corner in ipairs(corners[self.curPiece.rotState]) do
      local cell = {
        corner[1] + self.curPiece.row.start + self.curPiece.row.offset,
        corner[2] + self.curPiece.column.start + self.curPiece.column.offset,
      }

      if (
        cell[1] >= self.matrix.h
        or (cell[2] < 0 or cell[2] >= self.matrix.w)
        or not self.matrix:IsCellEmpty(cell[1], cell[2])
      ) then
        corners.n = corners.n + 1
        corner.covered = true
      end
    end
    if self.lastKick == 5 then
      spin = "full"
    elseif corners.n > 2 then
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

    if spin ~= nil and play then
      self.sounds.tspin:Play()
    end

    return spin
  end;
  CheckB2B = function(self)
    return self.lastAction == 2
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
    return allclear
  end;
  AwardPoints = function(self, action)
    action.rows = action.rows or 0

    local points = 0
    local actions = stacked.gamestate.actions
    local bonuses = stacked.gamestate.bonuses
    local lvl = stacked.gamestate.level

    if action.drop then
      points = actions.drop[action.drop] * action.rows * lvl
    else
      local base
      if action.spin then
        base = actions.tspin[action.spin]
      else
        base = actions
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
        points = points + 50 * self.matrix.combo * lvl
      end

      if not (action.spin or action.rows == 4) then
        action.b2b = false
      end

      if action.b2b then
        if action.spin then
          if action.rows == 1 then
            points = points + base.single * lvl * bonuses.b2b
          elseif action.rows == 2 then
            points = points + base.double * lvl * bonuses.b2b
          elseif action.rows == 3 then
            points = points + base.triple * lvl * bonuses.b2b
          end
        elseif action.rows == 4 then
          points = points + base.tetra * lvl * bonuses.b2b
        end
      end

      if action.allclear then
        base = bonuses.allclear
        if action.rows == 1 then
          points = points + base.single * lvl
        elseif action.rows == 2 then
          points = points + base.double * lvl
        elseif action.rows == 3 then
          points = points + base.triple * lvl
        elseif action.rows == 4 then
          points = points + base.tetra * (action.b2b and 1.6 or 1) * lvl
        end
      end

      if (
        action.rows == 4
        or (action.spin and action.rows > 0)
      ) then
        self.lastAction = 2
      elseif not action.spin then
        self.lastAction = 1
      end
    end

    for _, coffee in ipairs(stacked.gamestate.brews) do
      -- store points so far
      action.points = points
      points = (coffee:Sip(self, action) or points)
    end

    points = math.floor(points)

    local allclear = action.allclear and "PERFECT CLEAR\n" or ""
    local b2b = action.b2b and "BACK-TO-BACK\n" or ""
    local spinType = ""
    local lineType = ""

    if action.spin == "full" then
      spinType = "T-SPIN\n"
    elseif action.spin == "mini" then
      spinType = "MINI T-SPIN\n"
    end

    if action.rows == 1 then
      lineType = "SINGLE\n"
    elseif action.rows == 2 then
      lineType = "DOUBLE\n"
    elseif action.rows == 3 then
      lineType = "TRIPLE\n"
    elseif action.rows == 4 then
      lineType = "TETRA\n"
    end
    
    if not action.drop then
      self.clearText.text = (
        allclear
        ..b2b
        ..spinType
        ..lineType
        ..tostring(points)
      )
      self.clearText.color.a = 1
      self.timers.clear:clear()
      self.timers.clear:during(1, function(dt)
        self.clearText.color.a = self.clearText.color.a - dt
        self.clearText.y = self.clearText.y - dt * 5
      end, function()
        self.clearText.color.a = 0
        self.clearText.y = stacked.scy - 32
      end)
    end

    local stats = {
      tspin = spinType:lower():gsub("%s+", ""),
      line = lineType:lower():gsub("%s+", ""),
      b2b = action.b2b and "b2b" or "",
      allclear = action.allclear and "allclear" or "",
    }

    for _, stat in ipairs(stats) do
      self:IncrementStat(stat)
    end

    self.matrix.score = self.matrix.score + points
  end;
  IncrementStat = function(self, stat)
    local base = self.matrix.stats
    local realStat = ""
    if stat:find("mini") then
      realStat = "mini"
    elseif stat:find("spin") then
      realStat = "tspin"
    elseif stat:find("b2b") then
      realStat = "b2b"
    elseif stat:find("allclear") then
      realStat = "allclear"
    end
    base[realStat] = base[realStat] + 1
  end;
  RoundClear = function(self)
    stacked.gamestate.level = stacked.gamestate.level + 1
    self.readyText.text = "CLEAR!!"
    self:EndRound()
    stacked.seed = math.floor(stacked.uptime * 1000)
    if stacked.gamestate.level <= 10 and not self.over then
      self.sounds.complete:Play()
      self.callbacks.lines = stacked.timer.after(3, function()
        self.callbacks.lines = nil
        self.sounds.lines:Play()
        self.readyText.text = tostring(self.matrix.limit - self.matrix.lines).." LINES\nAWARDED"
      end)
      self.callbacks.cafe = stacked.timer.after(6, function()
        self.callbacks.cafe = nil
        self:ToCafe()
      end)
    else
      self.callbacks.title = stacked.timer.after(3, function()
        self.callbacks.title = nil
        self.matrix:Initialize()
        stacked.gamestate.level = 1
        stacked.gamestate.score = 0
        stacked.gamestate.cache = 0
        stacked.gamestate.brews = {}
        stacked.gamestate.actions = stacked.deepCopy(stacked.actions)
        stacked.gamestate.bonuses = stacked.deepCopy(stacked.bonuses)
        stacked.gamestate.stats = stacked.deepCopy(self.matrix.stats)
        self:ToTitle()
      end)
    end
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
    self.callbacks.title = stacked.timer.after(4, function()
      self.callbacks.title = nil
      self.matrix:Initialize()
      stacked.gamestate.level = 1
      stacked.gamestate.score = 0
      stacked.gamestate.cache = 0
      stacked.gamestate.brews = {}
      stacked.gamestate.actions = stacked.deepCopy(stacked.actions)
      stacked.gamestate.bonuses = stacked.deepCopy(stacked.bonuses)
      stacked.gamestate.stats = stacked.deepCopy(self.matrix.stats)
      self:ToTitle()
    end)
  end;
  GameInput = function(self, event)
    if self.freezeInput then return end
    local b = event.button
    local binds = stacked.controls[stacked.controls.active]
    -- Keyboard
    if event.type == "KeyDown" or event.type == "GamepadDown" then
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
    elseif event.type == "KeyUp" or event.type == "GamepadUp" then
      if b == binds.SoftDrop then
        self.controlStates.down = false
      end
    end
  end;
  Update = function(self, dt)
    for _, handle in pairs(self.timers) do
      handle:update(dt)
    end
    
    self.fader.x = self.matrix.x
    self.fader.y = self.matrix.y
    self.fader.w = self.matrix.w * stacked.size
    self.fader.h = self.matrix.h * stacked.size

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
      if self.dropDistance > 0 then
        self.readyToLock = false
      end
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
        x = stacked.scx + 10 * 16 * 0.3,
        y = stacked.scy - 20 * 16 * 0.3,
      },
      held = {
        x = stacked.scx - 10 * 16 * 1.3,
        y = stacked.scy - 20 * 16 * 0.25,
      }
    }
    self.matrix:Draw()
    self.fader:Draw()
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
