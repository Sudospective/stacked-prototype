return {
  {
    name = "Scone",
    description = function(self)
      return "+1 tetromino in next queue"
    end;
    image = "assets/food/scone.png";
    effect = function(self)
      stacked.gaemstate.queue = stacked.gamestate.queue + 1
    end
  },
  {
    name = "Cakepop",
    description = function(self)
      return "+2 matrix height"
    end;
    effect = function(self)
      stacked.gamestate.matrix.h = stacked.gamestate.matrix.h + 2
    end;
  },
}
