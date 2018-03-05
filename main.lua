--- Our main game stuff, 
-- try to keep it simple... oh well..

g_isTesting = false
print(_VERSION)

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
    if arg[#arg] == "-debug" then require("mobdebug").start() end    
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
    apiG.print("FPS: "..tostring(love.timer.getFPS( ))..' F# '..cfg.simFrameNumber, 10, 10) 
  end
  
  function api.keypressed(key)
    if key=='1' then
        if cfg.antComMaxBetterPaths== 1 then
          cfg.antComMaxBetterPaths = 10
        else                 
          cfg.antComMaxBetterPaths = 1
        end
        print('cfg.antComMaxBetterPath = ',cfg.antComMaxBetterPaths)
    elseif key=='2' then
        cfg.antComEveryFrame  = not cfg.antComEveryFrame 
        print('cfg.antComEveryFrame = ',cfg.antComEveryFrame)
    elseif key=='m' then
         print('Memory: '..math.floor( collectgarbage ('count'))..'kb')
    end
  end

  apiG.setDefaultFilter("nearest", "nearest")
  apiG.setLineStyle( 'rough' )

else
-- This is not the game, we are testing stuff
  dofile('test&dev/_testing.lua')
end
