require "classes.item"
require "classes.tetromino"

class "Sticker" : extends "Item" {
  name = "Sticker";
  cost = 3;
  piece = Tetromino.new();
  __ready = function(self, name)
    self.name = name
    self.piece = _ENV[self.name.."Piece"].new()
    self.label.text = self.name.." Sticker"
    self.label.color = stacked.colors[self.name:lower()]
    self.description = function(self)
      return "+1 "..self.name.." tetromino in bag"
    end
  end;
  Collect = function(self)
    table.insert(stacked.gamestate.bag, self.piece)
  end;
}
