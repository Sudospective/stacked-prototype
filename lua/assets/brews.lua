return {
  {
    name = "Joe",
    description = function(self)
      return "+"..self.points.." points for each line cleared"
    end,
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/joe.png",
    points = 100,
    ability = function(self, game, action)
      return self.points * action.rows
    end,
    condition = function(self, game, action)
      return not action.drop
    end,
  },
  {
    name = "Latté",
    description = function(self)
      return "+"..self.points.." points per consecutive clear\nif combo is active"
    end,
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/latte.png",
    points = 25,
    ability = function(self, game, action)
      return self.points * game.matrix.combo
    end,
    condition = function(self, game, action)
      return game.matrix.combo > 0
    end,
  },
  {
    name = "Espresso",
    description = function(self)
      return "Gains +50 points for each tetra clear\n(Currently "..self.points..")"
    end,
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/espresso.png",
    points = 0,
    ability = function(self, game, action)
      self.points = self.points + 50
      return self.points
    end,
    condition = function(self, game, action)
      return action.rows == 4
    end,
  },
  {
    name = "Cappuccino",
    description = function(self)
      return "+"..self.points.." points when clearing with an\nO tetromino"
    end,
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/cappuccino.png",
    points = 150,
    ability = function(self, game, action)
      return self.points
    end,
    condition = function(self, game, action)
      return game.curPiece.id == 2 and action.rows > 0 and not action.drop
    end,
  },
  {
    name = "Mocha",
    description = function(self)
      return "+"..self.points.." points for each T-spin"
    end,
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/mocha.png",
    points = 100,
    ability = function(self, game, action)
      return self.points
    end,
    condition = function(self, game, action)
      return action.spin ~= nil
    end,
  },
  {
    name = "Americano",
    description = function(self)
      return "+"..self.points.." points for each red or blue block cleared"
    end,
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/americano.png",
    points = 25,
    ability = function(self, game, action)
      local blocks = 0
      for j = -game.matrix.buffer, game.matrix.h - 1 do
        local prevBlocks = blocks
        local clearCount = 0
        for i = 0, game.matrix.w - 1 do
          local cell = game.matrix.cells[j][i]
          if cell ~= 0 then
            clearCount = clearCount + 1
          end
          if cell == 4 or cell == 7 then
            blocks = blocks + 1
          end
        end
        if clearCount < game.matrix.lineLength then
          -- all that work for nothing...
          blocks = prevBlocks
        end
      end
      return self.points * blocks
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows > 0
    end,
  },
}
