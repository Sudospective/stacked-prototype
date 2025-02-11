require "classes.coffee"
require "classes.soda"

class "Shelf" {
  items = {index = 1};
  __selected = false;
  StockItem = function(self, item)
    table.insert(self.items, item)
  end;
  Select = function(self, on)
    self.__selected = on
  end;
  Draw = function(self)
    for _, item in ipairs(self.items) do
      item:Draw()
    end
  end;
}

class "CoffeeShelf" : extends "Shelf" {
  __init = function(self)
    for i = 1, 2 do
      local coffee = Coffee.new()
      local data = stacked.coffee[math.random(1, #stacked.coffee)]
      coffee:Brew(data)
      self:StockItem(coffee)
    end
  end;
}

class "SodaShelf" : extends "Shelf" {
  __init = function(self)
    local sodas = {
      Blueberry.new(),
      Lemon.new(),
      Orange.new(),
      BlueRazz.new(),
      Grape.new(),
      Lime.new(),
      Cherry.new(),
    }
    for i = 1, 2 do
      local soda = stacked.deepCopy(sodas[math.random(1, #sodas)])
      if math.random(1, 20) == 1 then
        soda = Mystery.new()
      end
      self:StockItem(soda)
    end
  end;
}
