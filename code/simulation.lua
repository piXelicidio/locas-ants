--- simulation 
--(PURE Lua)
local api=require('code.api')
local TAnt = require('code.ant')
local map = require('code.map')
local TSurface = require('code.surface')
local TQuickList = require('code.qlist')

local sim = {}

local ants = {}
local surs = {}

function sim.init()  
  map.init()
  local newAnt
  for i=1,10 do
    newAnt = TAnt.create() 
    newAnt.init()
    ants[i] = newAnt
    map.actors.addNew( newAnt )
  end
  api.setPanning(600, 350)
  
  local newSur 
  for i=1,3 do
    newSur = TSurface.createObstacle(60*i, 50*math.random(), 30)
    --newMat = TSurface.create()
    newSur.init()
    surs[i] = newSur
    map.actors.addNew( newSur )
  end
  
  local numAnts, numSurs = 0,0;
  for _,node in pairs(map.actors.array) do
    if node.obj.classType == TAnt then numAnts = numAnts + 1 end
    if node.obj.classType == TSurface then numSurs = numSurs + 1 end
  end  
  print('numAnts: ',numAnts,' numSurs', numSurs)
end

function sim.update()
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
