require "classes.tetromino"

class "Matrix" {
  x = 0;
  y = 0;
  offset = {
    x = 0,
    y = 0
  };
  w = 10;
  h = 20;
  buffer = 10;
  lines = 0;
  limit = 40;
  score = 0;
  goal = 5000;
  combo = -1;
  actions = {};
  bonuses = {};
  brews = {};
  stats = {
    lines = 0,
    single = 0,
    double = 0,
    triple = 0,
    tetra = 0,
    mini = 0,
    tspin = 0,
    b2b = 0,
    allclear = 0,
  };
  cells = {};
  __init = function(self)
    self:Initialize()
  end;
  Initialize = function(self)
    self.w = 10;
    self.h = 20;
    self.lines = 0
    self.score = 0
    self.combo = -1
    self:FillFromGamestate()
    self:ResetCells()
    self:ResetScore()
    self:SetCriteria()
  end;
  FillFromGamestate = function(self)
    self.stats = stacked.gamestate.stats
    self.actions = stacked.gamestate.actions
    self.bonuses = stacked.gamestate.bonuses
    self.brews = stacked.gamestate.brews
    self.limit = stacked.gamestate.limit
  end;
  FillToGamestate = function(self)
    stacked.gamestate.stats = self.stats
    stacked.gamestate.actions = self.actions
    stacked.gamestate.bonuses = self.bonuses
    stacked.gamestate.brews = self.brews
    stacked.gamestate.limit = self.limit
  end;
  SetCriteria = function(self)
    self.goal = math.floor(5000 * (2 ^ (stacked.gamestate.level - 1)))
  end;
  ResetCells = function(self)
    for j = -self.buffer, self.h - 1 do
      self.cells[j] = {}
      for i = 0, self.w - 1 do
        self.cells[j][i] = 0
      end
    end
  end;
  ResetScore = function(self)
    self.lines = 0
    self.score = 0
  end;
  IsCellOutside = function(self, row, column)
    return not (
      row >= -self.buffer and
      row < self.h and
      column >= 0 and
      column < self.w
    )
  end;
  IsCellEmpty = function(self, row, column)
    return self.cells[row][column] == 0 or self.cells[row][column] == 9
  end;
  IsRowFull = function(self, row, numToClear)
    numToClear = numToClear or stacked.gamestate.lineLength
    local count = 0
    for column = 0, self.w - 1 do
      if self.cells[row][column] ~= 0 then
        count = count + 1
      end
    end
    return count >= numToClear
  end;
  ClearRow = function(self, row)
    for column = 0, self.w - 1 do
      self.cells[row][column] = 0
    end
  end;
  MoveRowDown = function(self, row, numRows)
    for column = 0, self.w - 1 do
      self.cells[row + numRows][column] = self.cells[row][column]
      self.cells[row][column] = 0
    end
  end;
  CountFullRows = function(self)
    local completed = 0
    for row = self.h - 1, -self.buffer, -1 do
      if self:IsRowFull(row) then
        completed = completed + 1
      end
    end
    return completed
  end;
  ClearFullRows = function(self)
    local completed = 0
    for row = self.h - 1, -self.buffer, -1 do
      if self:IsRowFull(row) then
        self:ClearRow(row)
        completed = completed + 1
      elseif completed > 0 then
        if completed == 1 then
          self.stats.single = self.stats.single + 1
        elseif completed == 2 then
          self.stats.double = self.stats.double + 1
        elseif completed == 3 then
          self.stats.triple = self.stats.triple + 1
        else
          self.stats.tetra = self.stats.tetra + 1
        end
        self:MoveRowDown(row, completed)
      end
    end
    self.lines = self.lines + completed
    self.stats.lines = self.stats.lines + completed
    return completed
  end;
  Draw = function(self, paused)
    for j = 0, self.h - 1 do
      for i = 0, self.w - 1 do
        local cell = self.cells[j][i]
        local offset = {
          x = -self.w * stacked.size * 0.5 + i * stacked.size,
          y = -self.h * stacked.size * 0.5 + j * stacked.size,
        }
        scarlet.graphics.drawQuad(
          self.x + self.offset.x + offset.x,
          self.y + self.offset.y + offset.y,
          stacked.size + 1,
          stacked.size + 1,
          0,
          {r = 0, g = 0, b = 0, a = 1}
        )
        scarlet.graphics.drawQuad(
          self.x + self.offset.x + offset.x + 1,
          self.y + self.offset.y + offset.y + 1,
          stacked.size - 1,
          stacked.size - 1,
          0,
          paused and stacked.colors.none or stacked.colors[cell]
        )
      end
    end
  end;
}
