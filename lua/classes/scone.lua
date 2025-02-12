require "classes.item"

class "Scone" : extends "Item" {
  effect = function(self, game) end;
  Eat = function(self, game)
    if self.effect then
      self:effect(game)
    end
  end;
}
