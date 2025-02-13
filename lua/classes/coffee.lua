require "classes.item"

class "Coffee" : extends "Item" {
  rarity = "Common";
  points = 0;
  Brew = function(self, params)
    for k, v in pairs(params) do
      self[k] = v
    end

    if self.rarity == "Common" then
      self.cost = 10
    elseif self.rarity == "Uncommon" then
      self.cost = 12
    elseif self.rarity == "Rare" then
      self.cost = 14
    elseif self.rarity == "Exotic" then
      self.cost = 16
    end

    self.label.text = self.name
    self.label.color = stacked.colors[self.rarity:lower()]
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
