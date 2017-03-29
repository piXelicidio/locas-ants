--- simulation 
--(PURE Lua)
local api=require('code.api')
local TAnt = require('code.ant')

local sim = {}

local actors = {}

function sim.init()
  for i=1,10 do
    local newAnt = TAnt.create()    
  end
  print(newAnt.x, newAnt.y)
end

function sim.update()
  for _,actor in ipairs(actors) do
    actor.update()    
  end
end

function sim.draw()
  for _,actor in ipairs(actors) do
    actor.draw()    
  end
end


return sim
