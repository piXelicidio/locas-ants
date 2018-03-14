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
    apiG.scale( cam.scale.x, cam.scale.y )    
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
    elseif key=='0'then
        cfg.debugHideAnts = not cfg.debugHideAnts
        print('cfg.debugHideAnts = ', cfg.debugHideAnts )
    end
    
  end
  
  function api.mousemoved(x, y, dx, dy, istouch)
    if api.mouse.isDown(1) then 
      sim.onClick( cam.screenToWorld(x, y) )
    elseif api.mouse.isDown(3) then
      print(dx,dy)
      cam.translation.x = cam.translation.x + dx
      cam.translation.y = cam.translation.y + dy
    end
  end
  
  function api.mousepressed(x, y, button,  istouch)
    if button == 1 then 
      sim.onClick( cam.screenToWorld(x, y) )
    end
  end
  
  function api.wheelmoved( x, y)    
    cam.scale.x = cam.scale.x + y/5
    cam.scale.y = cam.scale.y + y/5
    if cam.scale.x <1 then
      cam.scale.x = 1
      cam.scale.y = 1
    elseif cam.scale.x > 5 then
      cam.scale.x = 5
      cam.scale.y = 5
    end    
  end


  apiG.setDefaultFilter("nearest", "nearest")
  apiG.setLineStyle( 'rough' )

else
-- This is not the game, we are testing stuff
  dofile('test&dev/_testing.lua')
end
