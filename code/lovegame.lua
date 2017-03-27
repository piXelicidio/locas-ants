--- Löve game
-- (LOVE Lua)

local game = {}

local sim = require('code.simulation')

--- initializations, defaults, load
function game.init()
  function love.load()
    sim.init()  
  end
  
  function sim.end()
    print "Simulation ended on Löve"
  end;  
end

--- Run the game
function game.start()
  --  
  function love.update(dt)
    sim.update()
  end
  --
  function love.draw()
    sim.draw()    
  end
  
end

  
return game