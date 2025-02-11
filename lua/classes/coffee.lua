require "classes.item"

class "Coffee" : extends "Item" {
  rarity = "Common";
  points = 0;
  ability = function(self, game, action) end;
  condition = function(self, game, action) end;
  Brew = function(self, params)
    for k, v in pairs(params) do
      self[k] = v
    end
    self.label.text = self.name.." ("..self.rarity..")"
    self.price.text = self.cost.." lines"
  end;
  Equip = function(self)
    table.insert(stacked.gamestate.brews, self)
  end;
  UseAbility = function(self, game, action)
    if self.ability then
      self:ability(game, action)
    end
  end;
  CheckCondition = function(self, game, action)
    if self.condition then
      return self:condition(game, action)
    end
  end;
  Sip = function(self, game, action)
    if self:CheckCondition(game, action) then
      self:UseAbility(game, action)
    end
  end;
}
