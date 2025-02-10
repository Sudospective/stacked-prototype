return {
  {
    name = "Joe",
    description = "+25 points for each line cleared",
    cost = 8,
    rarity = "Common",
    image = "assets/coffee/joe.png",
    ability = function(self, game, action)
      return 25 * action.rows
    end,
    condition = function(self, game, action)
      return true
    end,
  },
}
