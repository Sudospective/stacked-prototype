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
  seed = nil,
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
  goals = {
    5000,
    10000,
    20000,
    40000,
    80000,
    160000,
    320000,
    640000,
    1280000,
    2560000,
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
    score = 0,
    cache = 0,
    queue = 3,
    height = 20,
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
  controls = {
    active = "keyboard",
    keyboard = {
      Left = "Left",
      Right = "Right",
      Up = "Up",
      Down = "Down",
      Confirm = "Return",
      Cancel = "Escape",

      MoveLeft = "Left",
      MoveRight = "Right",
      SoftDrop = "Down",
      HardDrop = "Up",
      RotateCW = "X",
      RotateCCW = "Z",
      Hold = "Space",
    },
  },
  brews = loadfile("assets/brews.lua")(),
  bites = loadfile("assets/bites.lua")(),
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
