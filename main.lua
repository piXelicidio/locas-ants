--- Our main game stuff, 
-- try to keep it simple... oh well..
  
--aliases and modules
local apiG = love.graphics
local api = love
local sim = require('code.simulation')
local cam = require('code.camview')
local cfg = require('code.simconfig') 
local ui = require('code.gui')


--- We init the application defining the load event
function api.load()
  TIME_start = os.clock()
  print('Initializing...')
  --if arg[#arg] == "-debug" then require("mobdebug").start() end    
  sim.init()  
  cam.translation.x = 500
  cam.translation.y = 300
  cam.scale.x = 1
  cam.scale.y = 1
  apiG.setBackgroundColor(cfg.colorBk)
  apiG.setDefaultFilter("nearest", "nearest")
  apiG.setLineStyle( 'rough' )
end    

  
function api.update()
  ui.suitRadio(ui.radioBtns_cells, 10, 50 )
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
  
  --ui
  ui.draw()  
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
  if api.mouse.isDown(1) and (x > ui.leftPanelWidth) then 
    if ui.radioBtns_cells.selectedCaption ~= 'cave' then
      sim.setCell(ui.radioBtns_cells.selectedCaption, cam.screenToWorld(x, y) ) 
    end
  elseif api.mouse.isDown(3) or api.mouse.isDown(2) then      
    cam.translation.x = cam.translation.x + dx
    cam.translation.y = cam.translation.y + dy
  end
end

function api.mousepressed(x, y, button,  istouch)
  if button == 1 and (x > ui.leftPanelWidth) then 
    sim.setCell(ui.radioBtns_cells.selectedCaption, cam.screenToWorld(x, y) )
  end
end

function api.wheelmoved( x, y)    
  local inc
  if y>0 then inc = 0.5 end
  if y<0 then inc = -0.5 end
  cam.scale.x = cam.scale.x + inc
  cam.scale.y = cam.scale.y +  inc
  if cam.scale.x <1 then
    cam.scale.x = 1
    cam.scale.y = 1
  elseif cam.scale.x > cfg.zoomMaxScale then
    cam.scale.x = cfg.zoomMaxScale
    cam.scale.y = cfg.zoomMaxScale
  end    
end


  
