--- simulation 
--(PURE Lua)
local api=require('code.api')
local TAnt = require('code.ant')
local map = require('code.map')
local TMaterial = require('code.material')
local TQuickList = require('code.qlist')

local sim = {}

local ants = {}
local mats = {}
local actors = TQuickList.create()

function sim.init()  
  map.init()
  local newAnt
  for i=1,10 do
    newAnt = TAnt.create() 
    newAnt.init()
    ants[i] = newAnt
    actors.addNew( newAnt )
  end
  api.setPanning(600, 350)
  
  local newMat 
  for i=1,3 do
    newMat = TMaterial.createObstacle(60*i, 50*math.random(), 30)
    --newMat = TMaterial.create()
    newMat.init()
    mats[i] = newMat
    actors.addNew( newMat )
  end
end

function sim.update()
  for _,node in pairs(actors.array) do
    node.obj.update()    
  end
end

function sim.draw()
  map.draw()  
  for _,node in pairs(actors.array) do
    node.obj.draw()    
  end
end


return sim
