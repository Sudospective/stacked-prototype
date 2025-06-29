class "Tetromino" {
  id = 0;
  x = 0;
  y = 0;
  row = {
    start = -2,
    offset = 0,
  };
  column = {
    start = 3,
    offset = 0,
  };
  cells = {
    { width = 0, offset = 0, height = 0 },
    { width = 0, offset = 0, height = 0 },
    { width = 0, offset = 0, height = 0 },
    { width = 0, offset = 0, height = 0 },
  };
  kicks = {
    { [-1] = {}, [1] = {}, },
    { [-1] = {}, [1] = {}, },
    { [-1] = {}, [1] = {}, },
    { [-1] = {}, [1] = {}, },
  };
  rotState = 1;
  lastRot = 0;
  visible = true;
  next = false;
  Move = function(self, rows, columns)
    self.row.offset = self.row.offset + rows
    self.column.offset = self.column.offset + columns
  end;
  Rotate = function(self, ccw)
    ccw = ccw or false
    local dir = ccw and -1 or 1
    self.rotState = (self.rotState - 1 + dir) % #self.cells + 1
    self.lastRot = dir
  end;
  GetCellPositions = function(self)
    local res = {}
    for _, cell in ipairs(self.cells[self.rotState]) do
      local newPos = {
        cell[1] + self.row.start + self.row.offset,
        cell[2] + self.column.start + self.column.offset,
      }
      table.insert(res, newPos)
    end
    return res
  end;
  Draw = function(self, x, y)
    if not self.visible then return end
    local cells = self:GetCellPositions()
    local size = self.next and 16 or stacked.size
    for _, cell in ipairs(cells) do
      scarlet.graphics.drawQuad(
        self.x + cell[2] * stacked.size + x,
        self.y + cell[1] * stacked.size + y,
        stacked.size + 1,
        stacked.size + 1,
        0,
        {r = 0, g = 0, b = 0, a = 1}
      )
      scarlet.graphics.drawQuad(
        self.x + cell[2] * stacked.size + x + 1,
        self.y + cell[1] * stacked.size + y + 1,
        stacked.size - 1,
        stacked.size - 1,
        0,
        stacked.colors[self.id]
      )
    end
  end;
}

class "IPiece" : extends "Tetromino" {
  id = 1;
  row = {
    start = -2,
    offset = 0,
  };
  column = {
    start = 3,
    offset = 0,
  };
  cells = {
    { {1, 0}, {1, 1}, {1, 2}, {1, 3}, width = 4, offset = 0, height = 1 },
    { {0, 2}, {1, 2}, {2, 2}, {3, 2}, width = 1, offset = 2, height = 0 },
    { {2, 0}, {2, 1}, {2, 2}, {2, 3}, width = 4, offset = 0, height = 2 },
    { {0, 1}, {1, 1}, {2, 1}, {3, 1}, width = 1, offset = 1, height = 0 },
  };
  kicks = {
    { -- O
      [-1] = { {0, 0}, {2, 0}, {-1, 0}, {2, 1}, {-1, -2}, }, -- R -> O
      [1] = { {0, 0}, {1, 0}, {-2, 0}, {1, -2}, {-2, 1}, }, -- L -> O
    },
    { -- R
      [-1] = { {0, 0}, {1, 0}, {-2, 0}, {1, -2}, {-2, 1}, }, -- 2 -> R
      [1] = { {0, 0}, {-2, 0}, {1, 0}, {-2, -1}, {1, 2}, }, -- O -> R
    },
    { -- 2
      [-1] = { {0, 0}, {-2, 0}, {1, 0}, {-2, -1}, {1, 2}, }, -- L -> 2
      [1] = { {0, 0}, {-1, 0}, {2, 0}, {-1, 2}, {2, -1}, }, -- R -> 2
    },
    { -- L
      [-1] = { {0, 0}, {-1, 0}, {2, 0}, {-1, 2}, {2, -1}, }, -- O -> L
      [1] = { {0, 0}, {2, 0}, {-1, 0}, {2, 1}, {-1, -2}, }, -- 2 -> L
    },
  };
}

class "OPiece" : extends "Tetromino" {
  id = 2;
  row = {
    start = -2,
    offset = 0,
  };
  column = {
    start = 4,
    offset = 0,
  };
  cells = {
    { {0, 0}, {0, 1}, {1, 0}, {1, 1}, width = 2, offset = 0, height = 0 },
    { {0, 0}, {0, 1}, {1, 0}, {1, 1}, width = 2, offset = 0, height = 0 },
    { {0, 0}, {0, 1}, {1, 0}, {1, 1}, width = 2, offset = 0, height = 0 },
    { {0, 0}, {0, 1}, {1, 0}, {1, 1}, width = 2, offset = 0, height = 0 },
  };
  kicks = {
    {
      [-1] = { {0, 0} },
      [1] = { {0, 0} },
    },
    {
      [-1] = { {0, 0} },
      [1] = { {0, 0} },
    },
    {
      [-1] = { {0, 0} },
      [1] = { {0, 0} },
    },
    {
      [-1] = { {0, 0} },
      [1] = { {0, 0} },
    },
  };
}

class "TPiece" : extends "Tetromino" {
  id = 3;
  row = {
    start = -2,
    offset = 0,
  };
  column = {
    start = 3,
    offset = 0,
  };
  cells = {
    { {0, 1}, {1, 0}, {1, 1}, {1, 2}, width = 3, offset = 0, height = 1 },
    { {0, 1}, {1, 1}, {1, 2}, {2, 1}, width = 2, offset = 1, height = 1 },
    { {1, 0}, {1, 1}, {1, 2}, {2, 1}, width = 3, offset = 0, height = 1 },
    { {0, 1}, {1, 0}, {1, 1}, {2, 1}, width = 2, offset = 0, height = 1 },
  };
  kicks = {
    { -- O
      [-1] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}, }, -- R -> O
      [1] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}, }, -- L -> O
    },
    { -- R
      [-1] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}, }, -- 2 -> R
      [1] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}, }, -- O -> R
    },
    { -- 2
      [-1] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}, }, -- L -> 2
      [1] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}, }, -- R -> 2
    },
    { -- L
      [-1] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}, }, -- O -> L
      [1] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}, }, -- 2 -> L
    },
  };
}

class "JPiece" : extends "Tetromino" {
  id = 4;
  row = {
    start = -2,
    offset = 0,
  };
  column = {
    start = 3,
    offset = 0,
  };
  cells = {
    { {0, 0}, {1, 0}, {1, 1}, {1, 2}, width = 3, offset = 0, height = 1 },
    { {0, 1}, {0, 2}, {1, 1}, {2, 1}, width = 2, offset = 1, height = 0 },
    { {1, 0}, {1, 1}, {1, 2}, {2, 2}, width = 3, offset = 0, height = 1 },
    { {0, 1}, {1, 1}, {2, 0}, {2, 1}, width = 2, offset = 0, height = 2 },
  };
  kicks = {
    { -- O
      [-1] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}, }, -- R -> O
      [1] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}, }, -- L -> O
    },
    { -- R
      [-1] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}, }, -- 2 -> R
      [1] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}, }, -- O -> R
    },
    { -- 2
      [-1] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}, }, -- L -> 2
      [1] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}, }, -- R -> 2
    },
    { -- L
      [-1] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}, }, -- O -> L
      [1] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}, }, -- 2 -> L
    },
  };
}

class "LPiece" : extends "Tetromino" {
  id = 5;
  row = {
    start = -2,
    offset = 0,
  };
  column = {
    start = 3,
    offset = 0,
  };
  cells = {
    { {0, 2}, {1, 0}, {1, 1}, {1, 2}, width = 3, offset = 0, height = 1 },
    { {0, 1}, {1, 1}, {2, 1}, {2, 2}, width = 2, offset = 1, height = 2 },
    { {1, 0}, {1, 1}, {1, 2}, {2, 0}, width = 3, offset = 0, height = 1 },
    { {0, 0}, {0, 1}, {1, 1}, {2, 1}, width = 2, offset = 0, height = 0 },
  };
  kicks = {
    { -- O
      [-1] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}, }, -- R -> O
      [1] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}, }, -- L -> O
    },
    { -- R
      [-1] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}, }, -- 2 -> R
      [1] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}, }, -- O -> R
    },
    { -- 2
      [-1] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}, }, -- L -> 2
      [1] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}, }, -- R -> 2
    },
    { -- L
      [-1] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}, }, -- O -> L
      [1] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}, }, -- 2 -> L
    },
  };
}

class "SPiece" : extends "Tetromino" {
  id = 6;
  row = {
    start = -2,
    offset = 0,
  };
  column = {
    start = 3,
    offset = 0,
  };
  cells = {
    { {0, 1}, {0, 2}, {1, 0}, {1, 1}, width = 3, offset = 0, height = 1 },
    { {0, 1}, {1, 1}, {1, 2}, {2, 2}, width = 2, offset = 1, height = 1 },
    { {1, 1}, {1, 2}, {2, 0}, {2, 1}, width = 3, offset = 0, height = 2 },
    { {0, 0}, {1, 0}, {1, 1}, {2, 1}, width = 2, offset = 0, height = 1 },
  };
  kicks = {
    { -- O
      [-1] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}, }, -- R -> O
      [1] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}, }, -- L -> O
    },
    { -- R
      [-1] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}, }, -- 2 -> R
      [1] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}, }, -- O -> R
    },
    { -- 2
      [-1] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}, }, -- L -> 2
      [1] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}, }, -- R -> 2
    },
    { -- L
      [-1] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}, }, -- O -> L
      [1] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}, }, -- 2 -> L
    },
  };
}

class "ZPiece" : extends "Tetromino" {
  id = 7;
  row = {
    start = -2,
    offset = 0,
  };
  column = {
    start = 3,
    offset = 0,
  };
  cells = {
    { {0, 0}, {0, 1}, {1, 1}, {1, 2}, width = 3, offset = 0, height = 1 },
    { {0, 2}, {1, 1}, {1, 2}, {2, 1}, width = 2, offset = 1, height = 1 },
    { {1, 0}, {1, 1}, {2, 1}, {2, 2}, width = 3, offset = 0, height = 2 },
    { {0, 1}, {1, 0}, {1, 1}, {2, 0}, width = 2, offset = 0, height = 1 },
  };
  kicks = {
    { -- O
      [-1] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}, }, -- R -> O
      [1] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}, }, -- L -> O
    },
    { -- R
      [-1] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}, }, -- 2 -> R
      [1] = { {0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}, }, -- O -> R
    },
    { -- 2
      [-1] = { {0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}, }, -- L -> 2
      [1] = { {0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}, }, -- R -> 2
    },
    { -- L
      [-1] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}, }, -- O -> L
      [1] = { {0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}, }, -- 2 -> L
    },
  };
}
