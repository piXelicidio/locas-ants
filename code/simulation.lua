--- simulation 
--(PURE Lua)
local api=require('code.api')
local TAnt = require('code.ant')
local map = require('code.map')
local TSurface = require('code.surface')
local TQuickList = require('code.qlist')

local sim = {}

function sim.init()  
  map.init()
  
    
  local newSur 
  for i=1,4 do
    newSur = TSurface.createObstacle(60*i, 400*(math.random()-0.5), 30)
    --newMat = TSurface.create()
    newSur.init()    
    map.addSurface( newSur )
  end
  
  local newAnt
  for i=1,20 do
    newAnt = TAnt.create() 
    newAnt.init()
    map.addAnt( newAnt )
  end
  api.setPanning(600, 350)

  
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
