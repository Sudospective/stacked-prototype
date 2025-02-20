class "Menu" {
  __enabled = false;
  __direction = false;
  x = 0;
  y = 0;
  w = 0;
  h = 0;
  elements = {};
  AddElement = function(self, elem)
    local label = Label.new()
    label:LoadFont("assets/sport.otf", 16)
    label.text = elem.text

    table.insert(self.elements, label)
  end;
  Draw = function(self)
    if self.__direction then
    else
    end
    for _, element in ipairs(self.elements) do
      element:Draw()
    end
  end;
}

class "MenuElement" {
  x = 0;
  y = 0;
  text = "";
  label = Label.new();
  __init = function(self)
    self.label:LoadFont("assets/sport.otf", 16)
  end;
  Draw = function(self)
    self.label.text = self.text
    self.label:Draw()
  end;
}
