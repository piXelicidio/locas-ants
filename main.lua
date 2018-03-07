--- Our main game stuff, 
-- try to keep it simple... oh well..

print(_VERSION)
  
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
        cfg.antComMaxBetterPaths = 3
      else                 
        cfg.antComMaxBetterPaths = 1
      end
      print('cfg.antComMaxBetterPath = ',cfg.antComMaxBetterPaths)
  elseif key=='2' then    
      cfg.antComEveryFrame  = not cfg.antComEveryFrame 
      print('cfg.antComEveryFrame = ',cfg.antComEveryFrame)
  elseif key=='3' then
      cfg.debugGrid = not cfg.debugGrid
      print('cfg.debugGrid =',cfg.debugGrid)
  elseif key=='4' then
      cfg.antComAlgorithm = cfg.antComAlgorithm + 1
      if cfg.antComAlgorithm > 3 then cfg.antComAlgorithm = 0 end     
      print('cfg.antComAlgorithm = ', cfg.antComAlgorithm )
  elseif key=='m' then
       print('Memory: '..math.floor( collectgarbage ('count'))..'kb')
  elseif key=='escape' then
      api.event.quit()
  end
end

apiG.setDefaultFilter("nearest", "nearest")
apiG.setLineStyle( 'rough' )

