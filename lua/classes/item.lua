class "Item" {
  __purchased = false;
  x = 0;
  y = 0;
  name = "";
  label = Label.new();
  price = Label.new();
  cost = 0;
  image = "";
  description = function(self)
    return ""
  end;
  __init = function(self, ...)
    self.label = Label.new()
    self.label.x = self.x - 128
    self.label.y = self.y
    self.label.align.h = 0
    self.label:LoadFont("assets/sport.otf", 16)
    self.label.text = self.name

    self.price = Label.new()
    self.price.x = self.x + 128
    self.price.y = self.y
    self.price.align.h = 1
    self.price:LoadFont("assets/sport.otf", 16)
    self.price.text = self.cost.." lines"

    if self.__ready then
      self:__ready(...)
    end
  end;
  Purchase = function(self)
    self.label.color = {
      r = self.label.color.r * 0.5,
      g = self.label.color.g * 0.5,
      b = self.label.color.b * 0.5,
      a = 1.0,
    }
    self.price.color = {
      r = 0.5,
      g = 0.5,
      b = 0.5,
      a = 1.0,
    }
    self.price.text = "SOLD OUT"
    if self.__class == "Coffee" then
      self:Equip()
    elseif self.__class == "Soda" then
      self:Drink()
    end
    stacked.gamestate.cache = stacked.gamestate.cache - self.cost
    self.__purchased = true
  end;
  Draw = function(self)
    self.label.x = self.x - 128
    self.label.y = self.y
    self.label:Draw()

    self.price.x = self.x + 128
    self.price.y = self.y
    self.price:Draw()
  end;
}
