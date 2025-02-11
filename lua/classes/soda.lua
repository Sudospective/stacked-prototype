require "classes.item"

class "Soda" : extends "Item" {
  cost = 5;
  action = "";
  points = 0;
  flavor = "";
  __ready = function(self)
    self.flavor = self.name:lower()
    local action = self.action
    if action == "tspin" then
      action = "T-spin"
    elseif action == "b2b" then
      action = "back-to-back"
    elseif action == "allclear" then
      action = "perfect"
    elseif action == "mystery" then
      action = "all"
    end
    self.description = function(self)
      local desc = "+"..tostring(self.points).." base points for "..action.." clears"
      if self.action == "b2b" then
        desc = "+"..tostring(self.points).." bonus multiplier for "..action.." clears"
      elseif action == "mystery" then
        desc = "Upgrade all clear types"
      end
      return desc
    end

    self.label.color = stacked.colors[stacked.flavors[self.flavor]]
  end;
  Drink = function(self)
    if self.__purchased then return end
    local actions = stacked.gamestate.actions
    if self.action == "b2b" or self.action == "allclear" then
      actions = stacked.gamestate.bonuses
    end
    if self.action ~= "mystery" then
      actions[self.action] = actions[self.action] + self.points
    else
      for _, flavor in ipairs {
        Blueberry,
        Lemon,
        Orange,
        BlueRazz,
        Grape,
        Lime,
        Cherry,
      } do
        local soda = flavor.new()
        actions[soda.action] = actions[soda.action] + soda.points
      end
    end
  end;
}

class "Blueberry" : extends "Soda" {
  name = "Blueberry";
  action = "single";
  points = 10;
  image = "assets/soda/blueberry.png";
}

class "Lemon" : extends "Soda" {
  name = "Lemon";
  action = "double";
  points = 20;
  image = "assets/soda/lemon.png";
}

class "Orange" : extends "Soda" {
  name = "Orange";
  action = "triple";
  points = 30;
  image = "assets/soda/orange.png";
}

class "BlueRazz" : extends "Soda" {
  name = "BlueRazz";
  action = "tetra";
  points = 40;
  image = "assets/soda/bluerazz.png";
}

class "Grape" : extends "Soda" {
  name = "Grape";
  action = "tspin";
  points = 50;
  image = "assets/soda/grape.png";
}

class "Lime" : extends "Soda" {
  name = "Lime";
  action = "b2b";
  points = 0.3;
  image = "assets/soda/lime.png";
}

class "Cherry" : extends "Soda" {
  name = "Cherry";
  action = "allclear";
  points = 70;
  image = "assets/soda/cherry.png";
}

class "Mystery" : extends "Soda" {
  name = "Mystery";
  action = "mystery";
  points = 80;
  image = "assets/soda/mystery.png";
}
