class "Screen" {
  title = "";
  AddGizmo = function(self, gizmo)
    table.insert(self, gizmo)
  end;
  RemoveGizmo = function(self, name)
    local res
    for i, gizmo in ipairs(self) do
      if gizmo.name == name and gizmo.name ~= "" then
        res = table.remove(self, i)
      end
    end
    return res
  end;
  GetGizmos = function(self)
    local res = {}
    for _, gizmo in ipairs(self) do
      table.insert(res, gizmo)
    end
    return res
  end;
  Enter = function(self)
    self.__active = true
    if self.__enter then
      self:__enter()
    end
  end;
  Exit = function(self)
    self.__active = false
    if self.__exit then
      self:__exit()
    end
  end;
  Update = function(self, dt)
    if not self.__active then return end
    if self.__update then
      self:__update(dt)
    end
  end;
  HandleInput = function(self, event)
    if not self.__active then return end
    if self.__input then
      self:__input(event)
    end
  end;
  Draw = function(self)
    if not self.__active then return end
    for _, gizmo in ipairs(self) do
      gizmo:Draw()
    end
    -- shouldnt use but just in case
    if self.__draw then
      self:__draw()
    end
  end;
  __active = false;
}
