require "classes.coffee"
require "classes.soda"
require "classes.snack"

class "Shelf" {
  x = 0;
  y = 0;
  name = "";
  items = {index = 1};
  label = Label.new();
  description = Label.new();
  __closed = false;
  __enabled = false;
  __init = function(self)
    self.items = {index = 1}

    self.label = Label.new()
    self.label.x = self.x
    self.label.y = self.y
    self.label:LoadFont("assets/sport.otf", 32)

    self.description = Label.new()
    self.description.x = self.x
    self.description.y = stacked.sh - 96
    self.description:LoadFont("assets/sport.otf", 16)

    if self.__ready then
      self:__ready()
    end
  end;
  StockItem = function(self, item)
    table.insert(self.items, item)
  end;
  ClearStock = function(self)
    self.items = {index = 1}
  end;
  Enable = function(self, on)
    self.__enabled = on
    self:Select(0)
  end;
  Open = function(self)
    self:ClearStock()
    self.__closed = false
    if self.__ready then
      self:__ready()
    end
  end;
  Close = function(self)
    self:Enable(false)
    self.__closed = true
  end;
  Select = function(self, offset)
    if not self.__enabled or self.__closed then return end
    self.items.index = (self.items.index - 1 + offset) % #self.items + 1
    while #self.items > 0 and self.items[self.items.index].__purchased do
      self.items.index = (self.items.index - 1 + (offset ~= 0 and offset or 1)) % #self.items + 1
    end
    if #self.items < 1 then
      self:Close()
    end
    self.description.text = self.items[self.items.index]:description()
  end;
  Purchase = function(self)
    local item = self.items[self.items.index]
    item:Purchase()
  end;
  Draw = function(self)
    self.label.x = self.x
    self.label.y = self.y
    self.label.text = self.heading
    self.label:Draw()
    for i, item in ipairs(self.items) do
      item.x = self.x
      item.y = self.y + 16 + i * 16
      if self.items.index == i and self.__enabled then
        item.x = item.x + 6
        item.y = item.y + math.sin(stacked.uptime * 4) * 0.5
      end
      item:Draw()
    end
    if self.__enabled then
      self.description.x = self.x
      self.description.y = stacked.sh - 64
      self.description:Draw()
    end
  end;
}

class "CoffeeShelf" : extends "Shelf" {
  heading = "COFFEE";
  __ready = function(self)
    for i = 1, 3 do
      local coffee = Coffee.new()
      local index = math.random(1, #stacked.brews)
      local data = stacked.brews[index]
      coffee:Brew(data)
      self:StockItem(coffee)
    end
  end;
}

class "SodaShelf" : extends "Shelf" {
  heading = "SODA";
  __ready = function(self)
    local hasMystery = false
    local sodas = {
      Blueberry,
      Lemon,
      Orange,
      BlueRazz,
      Grape,
      Lime,
      Cherry,
    }
    for i = 1, 3 do
      local index = math.random(#sodas)
      local soda = sodas[index].new()
      if math.random(1, 50) == 1 and not hasMystery then
        soda = Mystery.new()
        hasMystery = true
      end
      self:StockItem(soda)
      -- no repeats
      table.remove(sodas, index)
    end
  end;
}

class "SnackShelf" : extends "Shelf" {
  heading = "SNACKS";
  __ready = function(self)
    for i = 1, 2 do
      local snack = Snack.new()
      local index = math.random(1, #stacked.bites)
      local data = stacked.bites[index]
      snack:Bake(data)
      self:StockItem(snack)
    end
  end;
}
