class "Test" {
  Method = function(self)
    print("base method")
  end;
}

class "DerivedTest" : extends "Test" {
  Method = function(self)
    print("derived method")
  end;
}
