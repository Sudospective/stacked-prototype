return {
  {
    name = "Scone",
    description = function(self)
      return "+2 tetromino in next queue"
    end,
    image = "assets/pastries/scone.png",
    effect = function(self)
      stacked.gamestate.queue = stacked.gamestate.queue + 1
    end,
  },
  {
    name = "Cakepop",
    description = function(self)
      return "+5 matrix height"
    end,
    image = "assets/pastries/cakepop.png",
    effect = function(self)
      stacked.gamestate.height = stacked.gamestate.height + 2
    end,
  },
  {
    name = "Muffin",
    description = function(self)
      return "Allow +1 Hold action"
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
      stacked.gamestate.lineLength = 9
    end,
  },
}
