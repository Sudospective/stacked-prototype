return {
  {
    name = "Scone",
    description = function(self)
      return "+2 tetrominos in next queue"
    end,
    image = "assets/pastries/scone.png",
    effect = function(self)
      stacked.gamestate.queue = stacked.gamestate.queue + 2
    end,
  },
  {
    name = "Cakepop",
    description = function(self)
      return "+5 matrix height"
    end,
    image = "assets/pastries/cakepop.png",
    effect = function(self)
      stacked.gamestate.height = stacked.gamestate.height + 5
    end,
  },
  {
    name = "Muffin",
    description = function(self)
      return "Allow one re-hold\nper tetromino"
    end,
    image = "assets/pastries/muffin.png",
    effect = function(self)
      stacked.gamestate.hold = stacked.gamestate.hold + 1
    end,
  },
  {
    name = "Donut",
    description = function(self)
      return "Lines with one gap\ncount as cleared"
    end,
    image = "assets/pastries/donut.png",
    effect = function(self)
      stacked.gamestate.lineLength = stacked.gamestate.width - 1
    end,
  },
  {
    name = "Danish",
    description = function(self)
      return "-1 level"
    end,
    image = "assets/pastries/danish.png",
    effect = function(self)
      stacked.gamestate.level = stacked.gamestate.level - 1
    end,
  },
  {
    name = "Cinnamon Bun",
    description = function(self)
    end,
    image = "assets/pastries/bun.png",
    effect = function(self)
      stacked.gamestate.infinity = true
    end,
  },
  --[[
  {
    name = "Fruit Cake",
    description = function(self)
      local binds = stacked.controls[stacked.controls.active]
      return "Allow undoing a drop\n(Press "..binds.Extra.." to activate)"
    end,
  },
  --]]
}
