--- simulation 
local cfg = require('code.simconfig')
local cam = require('code.camview')
local TAnt = require('code.ant')
local map = require('code.map')
local TSurface = require('code.surface')
local TQuickList = require('code.qlist')

local sim = {}

function sim.init()  
  math.randomseed(os.time())
  map.init()
  
    
  local newSur  
  for i=1,3 do
    newSur = TSurface.createFood(500*(math.random()-0.5), 300*(math.random()-0.5), 80)
    newSur.init()    
    map.addSurface( newSur )
  end
  for i=1,5 do
    newSur = TSurface.createObstacle(60*i, 400*(math.random()-0.5), 30)    
    newSur.init()    
    map.addSurface( newSur )
  end 
  
  local newAnt
  for i=1,cfg.numAnts do
    newAnt = TAnt.create() 
    newAnt.init()
    map.addAnt( newAnt )
    local ang = math.random()*6.28
    newAnt.direction = {x = math.cos(ang), y = math.sin(ang)}
  end
  cam.translation.x = 500
  cam.translation.y = 300

  
  local numAnts, numSurs = 0,0;
  for _,node in pairs(map.actors.array) do
    if node.obj.classType == TAnt then numAnts = numAnts + 1 end
    if node.obj.classType == TSurface then numSurs = numSurs + 1 end
  end  
  print('numAnts: ',numAnts,' numSurs', numSurs)
end

function sim.update()
  map.update()
  for _,node in pairs(map.actors.array) do
    node.obj.update()    
  end
end

function sim.draw()
  map.draw()  
  for _,node in pairs(map.actors.array) do
    node.obj.draw()    
  end   
end


return sim
