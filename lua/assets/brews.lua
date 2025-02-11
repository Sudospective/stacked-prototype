return {
  {
    name = "Joe",
    description = function(self)
      return "+"..self.points.." points for each line cleared"
    end,
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/joe.png",
    points = 20,
    ability = function(self, game, action)
      return self.points * action.rows
    end,
    condition = function(self, game, action)
      return true
    end,
  },
  {
    name = "Latté",
    description = function(self)
      return "+"..self.points.." points for each clear\nif combo is active"
    end,
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/latte.png",
    points = 50,
    ability = function(self, game, action)
      return self.points
    end,
    condition = function(self, game, action)
      return game.matrix.combo > 0
    end,
  },
  {
    name = "Espresso",
    description = function(self)
      return "Gains +20 points for each tetra clear\n(Currently"..self.points..")"
    end,
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/espresso.png",
    points = 0,
    ability = function(self, game, action)
      if action.rows == 4 then
        self.points = self.points + 20
      end
      return self.points
    end,
    condition = function(self, game, action)
      return true
    end,
  },
  {
    name = "Cappuccino",
    description = function(self)
      return "+"..self.points.." points when clearing\nwith an O tetromino"
    end,
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/cappuccino.png",
    points = 100,
    ability = function(self, game, action)
      return self.points
    end,
    condition = function(self, game, action)
      return game.curPiece.id == 2
    end,
  },
}
