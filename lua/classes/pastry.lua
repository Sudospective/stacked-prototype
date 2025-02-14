require "classes.item"

class "Pastry" : extends "Item" {
  cost = 6;
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
    for i, pastry in ipairs(stacked.bites) do
      if pastry.name == self.name then
        table.remove(stacked.bites, i)
        break
      end
    end
  end;
}
