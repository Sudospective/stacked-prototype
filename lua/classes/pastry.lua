require "classes.item"

class "Pastry" : extends "Item" {
  cost = 5;
  Bake = function(self, data)
    for k, v in pairs(data) do
      self[k] = v
    end
    self.label.text = self.name
    self.price.text = self.cost.." lines"
  end;
  Eat = function(self, game)
    if self.effect then
      self:effect(game)
    end
  end;
}
