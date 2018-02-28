--- Our main game stuff, 
-- try to keep it simple... oh well..

g_isTesting = false

-- We are going to play with isolated tests or runing the game?
-- (why this? execution only start with main.lua)
if not g_isTesting then
  
  --aliases and modules
  local apiG = love.graphics
  local api = love
  local sim=require('code.simulation')
  local cam=require('code.camview')
  local cfg=require('code.simconfig')

  --- We init the application defining the load event
  function api.load()
    sim.init()  
    apiG.setBackgroundColor(cfg.colorBk)
  end  
    
  function api.update()
    sim.update()  
  end

  function api.draw()        
    --gameworld  
    
        
    apiG.push()
    apiG.translate( cam.translation.x, cam.translation.y )
    sim.draw()
    --ui stuff
    apiG.pop()
    apiG.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
  end

  apiG.setDefaultFilter("nearest", "nearest")
  apiG.setLineStyle( 'rough' )

else
-- This is not the game, we are testing stuff
  dofile('test&dev/_testing.lua')
end
