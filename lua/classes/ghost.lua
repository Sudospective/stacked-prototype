require "classes.tetromino"

class "Ghost" : extends "Tetromino" {
  __init = function(self, tetromino)
    if tetromino then self:Copy(tetromino) end
  end;
  Copy = function(self, tetromino)
    self.id = tetromino.id
    self.cells = tetromino.cells
    self.rotState = tetromino.rotState
    self.row.start = tetromino.row.start
    self.row.offset = tetromino.row.offset
    self.column.start = tetromino.column.start
    self.column.offset = tetromino.column.offset
  end;
  Draw = function(self, x, y)
    local cells = self:GetCellPositions()
    local color = {
      r = stacked.colors[self.id].r,
      g = stacked.colors[self.id].g,
      b = stacked.colors[self.id].b,
      a = 0.25
    }
    for _, cell in pairs(cells) do
      scarlet.graphics.drawQuad(
        self.x + cell[2] * stacked.size + x,
        self.y + cell[1] * stacked.size + y,
        stacked.size + 1,
        stacked.size + 1,
        0,
        {r = 0, g = 0, b = 0, a = 0.25}
      )
      scarlet.graphics.drawQuad(
        self.x + cell[2] * stacked.size + x + 1,
        self.y + cell[1] * stacked.size + y + 1,
        stacked.size - 1,
        stacked.size - 1,
        0,
        color
      )
    end
  end;
}
