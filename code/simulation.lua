--- simulation 
--(PURE Lua)
local api=require('code.api')
local TAnt = require('code.ant')
local map = require('code.map')

local sim = {}

local actors = {}

function sim.init()  
  map.init()
  local newAnt
  for i=1,10 do
    newAnt = TAnt.create() 
    newAnt.init()
    actors[i] = newAnt
  end
  api.setPanning(600, 350)
end

function sim.update()
  for _,actor in ipairs(actors) do
    actor.update()    
  end
end

function sim.draw()
  map.draw()  
  for _,actor in ipairs(actors) do
    actor.draw()    
  end
end


return sim
