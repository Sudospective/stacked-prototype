class "Coffee" {
  x = 0;
  y = 0;
  name = "";
  description = "";
  cost = 0;
  rarity = "Common";
  image = "";
  Brew = function(self, params)
    for k, v in pairs(params) do
      self[k] = v
    end
  end;
  UseAbility = function(self, game, action)
    if self.ability then
      self:ability(game, action)
    end
  end;
  CheckCondition = function(self, game, action)
    if self.condition then
      self:condition(game, action)
    end
  end;
  Draw = function(self)
    if self.DrawPrimitives then
      self:DrawPrimitives()
    end
  end;
}
