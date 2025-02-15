require "classes.item"
require "classes.tetromino"

class "Sticker" : extends "Item" {
  name = "Sticker";
  cost = 3;
  piece = Tetromino.new();
  Collect = function(self)
    table.insert(stacked.gamestate.bag, self.piece)
  end;
}
