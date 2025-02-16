require "classes.coffee"
require "classes.soda"
require "classes.pastry"
require "classes.sticker"

class "Shelf" {
  x = 0;
  y = 0;
  name = "";
  items = {index = 1};
  label = Label.new();
  sublabel = Label.new();
  description = Label.new();
  __closed = false;
  __enabled = false;
  __init = function(self)
    self.items = {index = 1}

    --self.label = Label.new()
    self.label.x = self.x
    self.label.y = self.y
    self.label:LoadFont("assets/sport.otf", 32)

    --self.sublabel = Label.new()
    self.sublabel.x = self.x
    self.sublabel.y = self.y + 24
    self.sublabel:LoadFont("assets/sport.otf", 16)

    --self.description = Label.new()
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

    self.sublabel.x = self.x
    self.sublabel.y = self.y + 24
    self.sublabel.text = self.subheading
    self.sublabel:Draw()

    for i, item in ipairs(self.items) do
      item.x = self.x
      item.y = self.y + 32 + i * 16
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
  subheading = "Upgrade Your Score!";
  __ready = function(self)
    for i = 1, #stacked.brews > 3 and 3 or #stacked.brews do
      local coffee = Coffee.new()
      local index = math.random(1, #stacked.brews)
      local data = stacked.brews[index]
      -- no repeats
      for _, brew in ipairs(self.items) do
        while data.name == brew.name do
          index = math.random(1, #stacked.brews)
          data = stacked.brews[index]
        end
      end
      coffee:Brew(data)
      self:StockItem(coffee)
    end
  end;
}

class "PastryShelf" : extends "Shelf" {
  heading = "PASTRIES";
  subheading = "Upgrade Your Matrix!";
  __ready = function(self)
    if #stacked.bites < 1 then
      self:Close()
      return
    end
    for i = 1, #stacked.bites > 2 and 2 or #stacked.bites do
      local pastry = Pastry.new()
      local index = math.random(1, #stacked.bites)
      local data = stacked.bites[index]
      -- no repeats
      for _, bite in ipairs(self.items) do
        while data.name == bite.name do
          index = math.random(1, #stacked.bites)
          data = stacked.bites[index]
          while data.name == "Cinnamon Bun" and math.random(1, 20) ~= 1 do
            index = math.random(1, #stacked.bites)
            data = stacked.bites[index]
          end
        end
      end
      pastry:Bake(data)
      self:StockItem(pastry)
    end
  end;
}

class "SodaShelf" : extends "Shelf" {
  heading = "SODA";
  subheading = "Upgrade Your Actions!";
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

class "StickerShelf" : extends "Shelf" {
  heading = "STICKERS";
  subheading = "Upgrade your Bag!";
  __ready = function(self)
    local stickers = {"I", "O", "T", "L", "J", "S", "Z"}
    for i = 1, 5 do
      local index = math.random(1, #stickers)
      self:StockItem(Sticker.new(stickers[index]))
    end
  end;
}
