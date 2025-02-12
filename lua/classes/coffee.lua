require "classes.item"

class "Coffee" : extends "Item" {
  rarity = "Common";
  points = 0;
  ability = function(self, game, action) end;
  condition = function(self, game, action) end;
  __ready = function(self)
    if self.rarity == "Common" then
      self.cost = 6
    elseif self.rarity == "Uncommon" then
      self.cost = 8
    elseif self.rarity == "Rare" then
      self.cost = 10
    elseif self.rarity == "Exotic" then
      self.cost = 12
    end
  end;
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
      return self:ability(game, action)
    end
  end;
  CheckCondition = function(self, game, action)
    if self.condition then
      return self:condition(game, action)
    end
  end;
  Sip = function(self, game, action)
    if self:CheckCondition(game, action) then
      return self:UseAbility(game, action)
    end
  end;
}
