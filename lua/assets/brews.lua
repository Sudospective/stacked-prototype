return {
  {
    name = "Joe",
    description = function(self)
      return "+"..self.points.." points on clear\nfor each line in clear"
    end,
    rarity = "Common",
    image = "assets/coffee/joe.png",
    points = 50,
    ability = function(self, game, action)
      return action.points + self.points * action.rows
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows > 0
    end,
  },
  {
    name = "Cappuccino",
    description = function(self)
      return "+"..self.points.." points when\nclearing with an\nO tetromino"
    end,
    rarity = "Common",
    image = "assets/coffee/cappuccino.png",
    points = 150,
    ability = function(self, game, action)
      return action.points + self.points
    end,
    condition = function(self, game, action)
      return game.curPiece.id == 2 and action.rows > 0 and not action.drop
    end,
  },
  {
    name = "Frappé",
    description = function(self)
      return "Gains +2 points for\neach hard drop,\nresets on soft drop"
    end,
    rarity = "Common",
    image = "assets/coffee/frappe.png",
    points = 0,
    ability = function(self, game, action)
      if action.drop == "soft" then
        self.points = 0
      elseif action.drop == "hard" then
        self.points = self.points + 2
      end
      return action.points + self.points
    end,
    condition = function(self, game, action)
      return action.drop ~= nil
    end
  },
  {
    name = "Ristretto",
    description = function(self)
      return "+"..self.points.." points for\neach brew triggered"
    end,
    rarity = "Common",
    image = "assets/coffee/ristretto.png",
    points = 10,
    ability = function(self, game, action)
      local mult = 0
      for _, brew in ipairs(game.matrix.brews) do
        if brew:CheckCondition(game, action) then
          mult = mult + 1
        end
      end
      return action.points + self.points * mult
    end,
    condition = function(self, game, action)
      return true
    end,
  },
  {
    name = "Latté",
    description = function(self)
      return "+"..self.points.." points on clear\nif 10 or less blocks\nremain in matrix"
    end,
    rarity = "Common",
    image = "assets/coffee/latte.png",
    points = 250,
    ability = function(self, game, action)
      return action.points + self.points
    end,
    condition = function(self, game, action)
      if action.drop then return false end
      local blocks = 0
      for row = game.matrix.h - 1, -game.matrix.buffer, -1 do
        for column = 0, game.matrix.w - 1 do
          if game.matrix.cells[row][column] ~= 0 then
            blocks = blocks + 1
          end
        end
      end
      return blocks <= 10
    end,
  },
  {
    name = "Americano",
    description = function(self)
      return "+"..self.points.." points for each\nred or blue block cleared"
    end,
    rarity = "Common",
    image = "assets/coffee/americano.png",
    points = 25,
    ability = function(self, game, action)
      local blocks = 0
      for j = game.matrix.h - 1, -game.matrix.buffer, -1 do
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
        if clearCount < stacked.gamestate.lineLength then
          -- all that work for nothing...
          blocks = prevBlocks
        end
      end
      return action.points + self.points * blocks
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows > 0
    end,
  },
  {
    name = "Doppio",
    description = function(self)
      return "+"..self.points.." points if\nclear is a double"
    end,
    rarity = "Common",
    image = "assets/coffee/doppio.png",
    points = 200,
    ability = function(self, game, action)
      return action.points + self.points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows == 2
    end,
  },
  {
    name = "Mocha",
    description = function(self)
      return "x"..self.points.." points if\nlines cleared is\ntwo or less"
    end,
    rarity = "Common",
    image = "assets/coffee/mocha.png",
    points = 1.25,
    ability = function(self, game, action)
      return action.points * self.points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows <= 2
    end,
  },
  {
    name = "Cortado",
    description = function(self)
      return "+"..self.points.." points for\neach consecutive clear\nif combo is active"
    end,
    rarity = "Uncommon",
    image = "assets/coffee/cortado.png",
    points = 25,
    ability = function(self, game, action)
      return action.points + self.points * game.matrix.combo
    end,
    condition = function(self, game, action)
      return not action.drop and game.matrix.combo > 0
    end,
  },
  {
    name = "Decaf",
    description = function(self)
      return "+"..self.points.." points on clear\nfor each single cleared\nin the run"
    end,
    rarity = "Uncommon",
    image = "assets/coffee/decaf.png",
    points = 5,
    ability = function(self, game, action)
      return action.points + self.points * stacked.gamestate.actions.single
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows > 0
    end,
  },
  {
    name = "Espresso",
    description = function(self)
      return "Gains +50 points for\neach tetra clear"
    end,
    rarity = "Uncommon",
    image = "assets/coffee/espresso.png",
    points = 0,
    ability = function(self, game, action)
      self.points = self.points + 50
      return action.points + self.points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows == 4
    end,
  },
  {
    name = "Tripplo",
    description = function(self)
      return "x"..self.points.." points if clear\ncontains a triple"
    end,
    rarity = "Rare",
    image = "assets/coffee/cortado.png",
    points = 1.5,
    ability = function(self, game, action)
      return action.points * self.points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows >= 2
    end,
  },
  {
    name = "Nitro Brew",
    description = function(self)
      return "x"..self.points.." points"
    end,
    rarity = "Exotic",
    image = "assets/coffee/nitro.png",
    points = 2,
    ability = function(self, game, action)
      return action.points * self.points
    end,
    condition = function(self, game, action)
      return true
    end,
  },
  {
    name = "Affogato",
    description = function(self)
      return "Multiply points by combo\nif combo is active"
    end,
    rarity = "Exotic",
    image = "assets/coffee/affogato.png",
    ability = function(self, game, action)
      return action.points * game.matrix.combo
    end,
    condition = function(self, game, action)
      return game.matrix.combo > 0
    end,
  },
}
