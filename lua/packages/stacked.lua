local async = require "packages.async"
local timer = require "packages.timer"

stacked = {
  -- General
  sw = scarlet.window.width,
  sh = scarlet.window.height,
  scx = scarlet.window.width * 0.5,
  scy = scarlet.window.height * 0.5,
  uptime = 0,
  async = async,
  timer = timer,
  -- Game
  seeds = {},
  size = 16,
  colors = {
    -- Indexed colors
    [0] = {
      r = 0.2,
      g = 0.2,
      b = 0.2,
      a = 1,
    },
    { -- I
      r = 0,
      g = 1,
      b = 1,
      a = 1,
    },
    { -- O
      r = 1,
      g = 1,
      b = 0,
      a = 1,
    },
    { -- T
      r = 0.5,
      g = 0,
      b = 1,
      a = 1,
    },
    { -- J
      r = 0,
      g = 0,
      b = 1,
      a = 1,
    },
    { -- L
      r = 1,
      g = 0.5,
      b = 0,
      a = 1,
    },
    { -- S
      r = 0,
      g = 1,
      b = 0,
      a = 1,
    },
    { -- Z
      r = 1,
      g = 0,
      b = 0,
      a = 1,
    },
    { -- cleared
      r = 1,
      g = 1,
      b = 1,
      a = 1,
    },
    { -- hard dropped
      r = 1,
      g = 1,
      b = 1,
      a = 1,
    },
    -- Keyed colors
    none = {
      r = 0.2,
      g = 0.2,
      b = 0.2,
      a = 1,
    },
    i = {
      r = 0,
      g = 1,
      b = 1,
      a = 1,
    },
    o = {
      r = 1,
      g = 1,
      b = 0,
      a = 1,
    },
    t = {
      r = 0.5,
      g = 0,
      b = 1,
      a = 1,
    },
    l = {
      r = 1,
      g = 0.5,
      b = 0,
      a = 1,
    },
    j = {
      r = 0,
      g = 0,
      b = 1,
      a = 1,
    },
    s = {
      r = 0,
      g = 1,
      b = 0,
      a = 1,
    },
    z = {
      r = 1,
      g = 0,
      b = 0,
      a = 1,
    },
    common = {
      r = 0.75,
      g = 0.5,
      b = 0.25,
      a = 1,
    },
    uncommon = {
      r = 0,
      g = 1,
      b = 0,
      a = 1,
    },
    rare = {
      r = 1,
      g = 0,
      b = 1,
      a = 1,
    },
    exotic = {
      r = 1,
      g = 1,
      b = 0,
      a = 1,
    },
  },
  flavors = {
    mystery = "none", -- upgrade all
    bluerazz = "i", -- upgrade tetra
    lemon = "o", -- upgrade double
    grape = "t", -- upgrade t-spin
    orange = "l", -- upgrade triple
    blueberry = "j", -- upgrade single
    lime = "s", -- upgrade back-to-back
    cherry = "z", -- upgrade all-clear
  },
  actions = {
    -- per row dropped
    -- multiply by drop distance
    drop = {
      soft = 1,
      hard = 2,
    },
    -- per line cleared
    -- multiply by level
    single = 100,
    double = 300,
    triple = 500,
    tetra = 800,
    -- per line cleared
    -- multiply by level
    tspin = {
      mini = {
        none = 100,
        single = 200,
      },
      full = {
        none = 400,
        single = 800,
        double = 1200,
        triple = 1600,
      },
    },
  },
  bonuses = {
    -- based on action
    -- multiply by action points
    b2b = 0.5,
    -- based on lines cleared
    -- multiply by level
    allclear = {
      single = 800,
      double = 1200,
      triple = 1800,
      tetra = 2000,
    },
  },
  gamestate = {
    level = 1,
    limit = 40,
    score = 0,
    cache = 5,
    queue = 3,
    width = 10,
    height = 20,
    lineLength = 10,
    hold = 1,
    infinity = false,
    brews = {},
    actions = {
      -- per row dropped
      -- multiply by drop distance
      drop = {
        soft = 1,
        hard = 2,
      },
      -- per line cleared
      -- multiply by level
      single = 100,
      double = 300,
      triple = 500,
      tetra = 800,
      -- per line cleared
      -- multiply by level
      tspin = {
        mini = {
          none = 100,
          single = 200,
          -- mini t-spin doubles are possible with donut
          double = 400,
        },
        full = {
          none = 400,
          single = 800,
          double = 1200,
          triple = 1600,
        },
      },
    },
    bonuses = {
      -- based on action
      -- multiply by action points
      b2b = 0.5,
      -- based on lines cleared
      -- multiply by level
      allclear = {
        single = 800,
        double = 1200,
        triple = 1800,
        tetra = 2000,
      },
    },
    stats = {
      lines = 0,
      single = 0,
      double = 0,
      triple = 0,
      tetra = 0,
      mini = 0,
      tspin = 0,
      b2b = 0,
      allclear = 0,
    },
  },
  default = {
    level = 1,
    limit = 40,
    score = 0,
    cache = 5,
    queue = 3,
    width = 10,
    height = 20,
    lineLength = 10,
    hold = 1,
    infinity = false,
    brews = {},
    actions = {
      -- per row dropped
      -- multiply by drop distance
      drop = {
        soft = 1,
        hard = 2,
      },
      -- per line cleared
      -- multiply by level
      single = 100,
      double = 300,
      triple = 500,
      tetra = 800,
      -- per line cleared
      -- multiply by level
      tspin = {
        mini = {
          none = 100,
          single = 200,
          -- mini t-spin doubles are possible with donut
          double = 400,
        },
        full = {
          none = 400,
          single = 800,
          double = 1200,
          triple = 1600,
        },
      },
    },
    bonuses = {
      -- based on action
      -- multiply by action points
      b2b = 0.5,
      -- based on lines cleared
      -- multiply by level
      allclear = {
        single = 800,
        double = 1200,
        triple = 1800,
        tetra = 2000,
      },
    },
    stats = {
      lines = 0,
      single = 0,
      double = 0,
      triple = 0,
      tetra = 0,
      mini = 0,
      tspin = 0,
      b2b = 0,
      allclear = 0,
    },
  },
  localization = {
    keyboard = {
      Left = "Left",
      Right = "Right",
      Up = "Up",
      Down = "Down",
      Confirm = "Enter",
      Cancel = "Backspace",

      MoveLeft = "Left",
      MoveRight = "Right",
      SoftDrop = "Down",
      HardDrop = "Up",
      RotateCW = "X",
      RotateCCW = "Z",
      Hold = "Space",
      Extra = "C",
      Pause = "Escape",
      Glossary = "G",
      MuteMusic = "M",
    },
    xbox = {
      Left = "D-Left",
      Right = "D-Right",
      Up = "D-Up",
      Down = "D-Down",
      Confirm = "A",
      Cancel = "B",

      MoveLeft = "D-Left",
      MoveRight = "D-Right",
      SoftDrop = "D-Down",
      HardDrop = "D-Up",
      RotateCW = "B",
      RotateCCW = "A",
      Hold = "RB",
      Extra = "X",
      Pause = "Start",
      Glossary = "LB",
      MuteMusic = "Y",
    },
    playstation = {
      Left = "D-Left",
      Right = "D-Right",
      Up = "D-Up",
      Down = "D-Down",
      Confirm = "Cross",
      Cancel = "Circle",

      MoveLeft = "D-Left",
      MoveRight = "D-Right",
      SoftDrop = "D-Down",
      HardDrop = "D-Up",
      RotateCW = "Circle",
      RotateCCW = "Cross",
      Hold = "R1",
      Extra = "Square",
      Pause = "Start",
      Glossary = "L1",
      MuteMusic = "Triangle",
    },
    nintendo = {
      Left = "D-Left",
      Right = "D-Right",
      Up = "D-Up",
      Down = "D-Down",
      Confirm = "A",
      Cancel = "B",

      MoveLeft = "D-Left",
      MoveRight = "D-Right",
      SoftDrop = "D-Down",
      HardDrop = "D-Up",
      RotateCW = "A",
      RotateCCW = "B",
      Hold = "R",
      Extra = "Y",
      Pause = "Start",
      Glossary = "L",
      MuteMusic = "X",
    },
    generic = {
      Left = "D-Left",
      Right = "D-Right",
      Up = "D-Up",
      Down = "D-Down",
      Confirm = "B-Down",
      Cancel = "B-Right",

      MoveLeft = "D-Left",
      MoveRight = "D-Right",
      SoftDrop = "D-Down",
      HardDrop = "D-Up",
      RotateCW = "B-Right",
      RotateCCW = "B-Down",
      Hold = "R-Top",
      Extra = "B-Left",
      Pause = "Start",
      Glossary = "L-Top",
      MuteMusic = "B-Up",
    },
  },
  controls = {
    active = "keyboard",
    keyboard = {
      Left = "Left",
      Right = "Right",
      Up = "Up",
      Down = "Down",
      Confirm = "Return",
      Cancel = "Backspace",

      MoveLeft = "Left",
      MoveRight = "Right",
      SoftDrop = "Down",
      HardDrop = "Up",
      RotateCW = "X",
      RotateCCW = "Z",
      Hold = "Space",
      Extra = "C",
      Pause = "Escape",
      Glossary = "G",
      MuteMusic = "M",
    },
    -- these strings are from sdl not me
    xbox = {
      Left = "dpleft",
      Right = "dpright",
      Up = "dpup",
      Down = "dpdown",
      Confirm = "a",
      Cancel = "b",

      MoveLeft = "dpleft",
      MoveRight = "dpright",
      SoftDrop = "dpdown",
      HardDrop = "dpup",
      RotateCW = "b",
      RotateCCW = "a",
      Hold = "rightshoulder",
      Extra = "x",
      Pause = "start",
      Glossary = "leftshoulder",
      MuteMusic = "y",
    },
    playstation = {
      Left = "dpleft",
      Right = "dpright",
      Up = "dpup",
      Down = "dpdown",
      Confirm = "a",
      Cancel = "b",

      MoveLeft = "dpleft",
      MoveRight = "dpright",
      SoftDrop = "dpdown",
      HardDrop = "dpup",
      RotateCW = "b",
      RotateCCW = "a",
      Hold = "rightshoulder",
      Extra = "x",
      Pause = "start",
      Glossary = "leftshoulder",
      MuteMusic = "y",
    },
    nintendo = {
      Left = "dpleft",
      Right = "dpright",
      Up = "dpup",
      Down = "dpdown",
      Confirm = "b",
      Cancel = "a",

      MoveLeft = "dpleft",
      MoveRight = "dpright",
      SoftDrop = "dpdown",
      HardDrop = "dpup",
      RotateCW = "b",
      RotateCCW = "a",
      Hold = "rightshoulder",
      Extra = "x",
      Pause = "start",
      Glossary = "leftshoulder",
      MuteMusic = "y",
    },
    generic = {
      Left = "dpleft",
      Right = "dpright",
      Up = "dpup",
      Down = "dpdown",
      Confirm = "a",
      Cancel = "b",

      MoveLeft = "dpleft",
      MoveRight = "dpright",
      SoftDrop = "dpdown",
      HardDrop = "dpup",
      RotateCW = "b",
      RotateCCW = "a",
      Hold = "rightshoulder",
      Extra = "x",
      Pause = "start",
      Glossary = "leftshoulder",
      MuteMusic = "y",
    },
  },
  brews = loadfile("assets/brews.lua")(),
  bites = loadfile("assets/bites.lua")(),
  terms = loadfile("assets/terms.lua")(),
}

function stacked.deepCopy(t)
  if type(t) ~= "table" then return t end
  local meta = getmetatable(t)
  local target = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      target[k] = stacked.deepCopy(v)
    else
      target[k] = v
    end
  end
  setmetatable(target, meta)
  return target
end

return stacked
