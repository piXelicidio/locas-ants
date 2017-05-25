--- Our main game stuff, 
-- (PURE Lua)
-- try to keep it simple


g_isTesting = false
-- We are going to play with isolated tests or runing the game?
-- (why this? execution only start with main.lua)
if not g_isTesting then

  local api=require('code.api')
  local sim=require('code.simulation')

  --- We init the application defining the load event
  function api.onLoad()
    sim.init()
  end  
    
  function api.onUpdate()
    sim.update()  
  end

  function api.onDraw()
    --print 'drawing circle'
    sim.draw()
  end

  api.start()

else
-- This is not the game, we are testing stuff
  dofile('test&dev/_testing.lua')
end
