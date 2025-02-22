return {
  {
    name = "Joe",
    description = function(self)
      return "+"..self.points.." points on clear\nfor each line in clear"
    end,
    rarity = "Common",
    image = "assets/coffee/joe.png",
    points = 10,
    ability = function(self, game, action)
      return action.points + self.points * action.rows
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows > 0
    end,
  },
  {
    name = "Manilo",
    description = function(self)
      return "+"..self.points.." lines in cache\non tetra clear"
    end,
    rarity = "Common",
    image = "assets/coffee/manilo.png",
    points = 1,
    ability = function(self, game, action)
      stacked.gamestate.cache = stacked.gamestate.cache + self.points
      return action.points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows == 4
    end,
  },
  {
    name = "Lungo",
    description = function(self)
      return "x"..self.points.." points on\nsingle clear"
    end,
    rarity = "Common",
    image = "assets/coffee/lungo.png",
    points = 1.5,
    ability = function(self, game, action)
      return action.points * self.points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows == 1
    end,
  },
  {
    name = "Macchiato",
    description = function(self)
      return "x"..self.points.." points on\nmini T-spin"
    end,
    rarity = "Common",
    image = "assets/coffee/macchiato.png",
    points = 1.25,
    ability = function(self, game, action)
      return action.points * self.points
    end,
    condition = function(self, game, action)
      return action.spin == "mini"
    end,
  },
  {
    name = "Cappuccino",
    description = function(self)
      return "+"..self.points.." points when\nclearing with an\nO tetromino"
    end,
    rarity = "Common",
    image = "assets/coffee/cappuccino.png",
    points = 100,
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
      return "Gains +10 points for\neach hard drop,\nresets on soft drop"
    end,
    rarity = "Common",
    image = "assets/coffee/frappe.png",
    points = 0,
    ability = function(self, game, action)
      if action.drop == "soft" then
        self.points = 0
      elseif action.drop == "hard" then
        self.points = self.points + 10
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
    points = 25,
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
    points = 100,
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
      return "+"..self.points.." points for each\nZ or J\nblock cleared"
    end,
    rarity = "Common",
    image = "assets/coffee/americano.png",
    points = 10,
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
      return "+"..self.points.." points when\nclearing a double"
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
    points = 1.5,
    ability = function(self, game, action)
      return action.points * self.points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows <= 2
    end,
  },
  {
    name = "Dalgona",
    description = function(self)
      return "+"..self.points.." base points\nfor singles and doubles\non tetra clear"
    end,
    rarity = "Common",
    image = "assets/coffee/dalgona.png",
    points = 25,
    ability = function(self, game, action)
      game.matrix.actions.single = game.matrix.actions.single + self.points
      game.matrix.actions.double = game.matrix.actions.double + self.points
      return action.points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows == 4
    end,
  },
  {
    name = "Irish Coffee",
    description = function(self)
      return "+"..self.points.." points when\nclearing a double\nwith an S tetromino"
    end,
    rarity = "Common",
    image = "assets/coffee/irish.png",
    points = 150,
    ability = function(self, game, action)
      return action.points + self.points
    end,
    condition = function(self, game, action)
      return not action.drop and game.curPiece.id == 6 and action.rows == 2
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
      return "+"..self.points.." points on clear\nfor each single cleared\nin this run"
    end,
    rarity = "Uncommon",
    image = "assets/coffee/decaf.png",
    points = 25,
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
      return "Gains +25 points for\neach tetra clear\nsince purchase"
    end,
    rarity = "Uncommon",
    image = "assets/coffee/espresso.png",
    points = 0,
    ability = function(self, game, action)
      self.points = self.points + 25
      return action.points + self.points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows == 4
    end,
  },
  {
    name = "Galão",
    description = function(self)
      return "x"..self.points.." points for each\nL block cleared"
    end,
    rarity = "Uncommon",
    image = "assets/coffee/galao.png",
    points = 1.25,
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
          if cell == 5 then
            blocks = blocks + 1
          end
        end
        if clearCount < stacked.gamestate.lineLength then
          blocks = prevBlocks
        end
      end
      local points = action.points
      for i = 1, blocks do
        points = points * self.points
      end
      return points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows > 0
    end,
  },
  {
    name = "Vienna",
    description = function(self)
      return "x"..self.points.." points when\n clearing a single\nwith an I tetromino"
    end,
    rarity = "Rare",
    image = "assets/coffee/vienna.png",
    points = 2,
    ability = function(self, game, action)
      return action.points * self.points
    end,
    condition = function(self, game, action)
      return not action.drop and game.curPiece.id == 1 and action.rows == 1
    end,
  },
  {
    name = "Tripplo",
    description = function(self)
      return "+"..self.points.." points if clear\ncontains a triple"
    end,
    rarity = "Rare",
    image = "assets/coffee/cortado.png",
    points = 150,
    ability = function(self, game, action)
      return action.points + self.points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows >= 2
    end,
  },
  {
    name = "Antoccino",
    description = function(self)
      return "+"..self.points.." points on clear,\n1 in 20 chance to\nreset clear score"
    end,
    rarity = "Rare",
    image = "assets/coffee/antoccino.png",
    points = 250,
    ability = function(self, game, action)
      local points = action.points + self.points
      if math.random(1, 20) == 1 then
        points = 0
      end
      return points
    end,
    condition = function(self, game, action)
      return not action.drop and action.rows > 0
    end,
  },
  {
    name = "Nitro Brew",
    description = function(self)
      return "x"..self.points.." points"
    end,
    rarity = "Exotic",
    image = "assets/coffee/nitro.png",
    points = 1.5,
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
      return not action.drop and action.rows > 0 and game.matrix.combo > 0
    end,
  },
}
