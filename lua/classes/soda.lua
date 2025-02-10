class "Soda" {
  x = 0;
  y = 0;
  name = "";
  action = "";
  cost = 5;
  points = 0;
  flavor = "";
  description = "";
  __init = function(self)
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
    self.description = "+"..tostring(self.points).." base points for "..action.." clears"
  end;
  Eat = function(self, actions)
    actions[self.action] = actions[self.action] + self.points
  end;
  Draw = function(self)
    scarlet.graphics.drawQuad(
      self.x - 16, self.y - 16,
      32, 32,
      45,
      stacked.colors[stacked.flavors[self.name:lower()]]
    )
  end;
}

class "Blueberry" : extends "Soda" {
  name = "Blueberry";
  action = "single";
  points = 10;
}

class "Lemon" : extends "Soda" {
  name = "Lemon";
  action = "double";
  points = 20;
}

class "Orange" : extends "Soda" {
  name = "Orange";
  action = "triple";
  points = 30;
}

class "BlueRazz" : extends "Soda" {
  name = "BlueRazz";
  action = "tetra";
  points = 40;
}

class "Grape" : extends "Soda" {
  name = "Grape";
  action = "tspin";
  points = 50;
}

class "Lime" : extends "Soda" {
  name = "Lime";
  action = "b2b";
  points = 60;
}

class "Cherry" : extends "Soda" {
  name = "Cherry";
  action = "allclear";
  points = 70;
}

class "Mystery" : extends "Soda" {
  name = "Mystery";
  action = "mystery";
  points = 80;
}
