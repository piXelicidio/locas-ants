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
    TIME_start = os.clock()
    print('Initializing...')
    --if arg[#arg] == "-debug" then require("mobdebug").start() end    
    sim.init()  
    apiG.setBackgroundColor(cfg.colorBk)
    
  end  
    
  function api.update()    
    sim.update()      
  end  
  
  function api.draw()        
    --gameworld  
    if cfg.simFrameNumber == 1 then print( (os.clock() - TIME_start)..'secs' ) end
        
    apiG.push()
    apiG.translate( cam.translation.x, cam.translation.y )
    sim.draw()
    --ui stuff
    apiG.pop()
    apiG.print("FPS: "..tostring(love.timer.getFPS( ))..' F# '..cfg.simFrameNumber, 10, 10) 
    --apiG.print("DebugCounter 1 = "..cfg.debugCounters[1], 10, 25)
    --apiG.print("DebugCounter 2 = "..cfg.debugCounters[2], 10, 40)
  end
  
  function api.keypressed(key)
    if key=='1' then
        
    elseif key=='2' then    
        cfg.antComEveryFrame  = not cfg.antComEveryFrame 
        print('cfg.antComEveryFrame = ',cfg.antComEveryFrame)
    elseif key=='3' then
        cfg.debugGrid = not cfg.debugGrid
        print('cfg.debugGrid =',cfg.debugGrid)
    elseif key=='4' then
        cfg.antComAlgorithm = cfg.antComAlgorithm + 1
        if cfg.antComAlgorithm > 1 then cfg.antComAlgorithm = 0 end     
        print('cfg.antComAlgorithm = ', cfg.antComAlgorithm )
    elseif key=='5' then
        cfg.debugPheromones = not cfg.debugPheromones
        print('cfg.debugPheromones =',cfg.debugPheromones)
    elseif key=='m' then
         print('Memory: '..math.floor( collectgarbage ('count'))..'kb')
    elseif key=='escape' then
        api.event.quit()
    elseif key=='6' then
        cfg.antObjectAvoidance = not cfg.antObjectAvoidance 
        print('cfg.antObjectAvoidance = ', cfg.antObjectAvoidance )
    end
  end
  
  function api.mousemoved(x, y,  istouch)
    if api.mouse.isDown(1) then 
      sim.onClick( cam.screenToWorld(x, y) )
    end
  end
  
  function api.mousepressed(x, y, button,  istouch)
    if button == 1 then 
      sim.onClick( cam.screenToWorld(x, y) )
    end
  end


  apiG.setDefaultFilter("nearest", "nearest")
  apiG.setLineStyle( 'rough' )

else
-- This is not the game, we are testing stuff
  dofile('test&dev/_testing.lua')
end
