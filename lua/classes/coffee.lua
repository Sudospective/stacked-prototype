class "Coffee" {
  x = 0;
  y = 0;
  name = "";
  description = "";
  cost = 0;
  rarity = "Common";
  image = "";
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
