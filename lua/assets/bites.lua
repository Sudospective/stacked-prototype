return {
  {
    name = "Scone",
    description = function(self)
      return "+1 tetromino in next queue"
    end,
    image = "assets/snacks/scone.png",
    effect = function(self)
      stacked.gamestate.queue = stacked.gamestate.queue + 1
    end,
  },
  {
    name = "Cakepop",
    description = function(self)
      return "+2 matrix height"
    end,
    image = "assets/snacks/cakepop.png",
    effect = function(self)
      stacked.gamestate.height = stacked.gamestate.height + 2
    end,
  },
}
