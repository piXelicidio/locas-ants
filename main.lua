--- Our main game stuff, 
-- try to keep it simple


g_isTesting = false
-- We are going to play with isolated tests or runing the game?
-- (why this? execution only start with main.lua)
if not g_isTesting then
  
  local sim=require('code.simulation')
  local loveme=require('code.loveme')

  --- We init the application defining the load event
  function love.load()
    sim.init()
  end  
    
  function love.update()
    sim.update()  
  end

  function love.draw()        
    --gameworld
    love.graphics.push()
    love.graphics.translate( loveme.camera.x, loveme.camera.y )
    sim.draw()
    --ui stuff
    love.graphics.pop()
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
  end

  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setLineStyle( 'rough' )

else
-- This is not the game, we are testing stuff
  dofile('test&dev/_testing.lua')
end
