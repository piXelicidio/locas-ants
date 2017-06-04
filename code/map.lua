--- The global map where objects and actors and ants reside 
--(PURE Lua)
local api=require('code.api')
local TQuickList = require('code.qlist')

local map = {}

-- Map limits
map.minX = -300
map.minY = -200
map.maxX = 300
map.maxY = 200

--
map.actors = TQuickList.create()   --All actors including ants and surfaces
map.ants = TQuickList.create()     --All ants
map.surfs = TQuickList.create()    --All surfaces (obstacles, caves, food... )

limitsColor = {255,0,0,255}

local limitsRect = {}

function map.addActor( a )
  local node = map.actors.addNew( a )
  -- remember you are referenced on the actors list
  table.insert( a.nodesOnLists, node )  
end

function map.addAnt( ant )
  local node = map.ants.addNew( ant )
  -- remember you are referenced on the ants list
  table.insert( ant.nodesOnLists, node )  
  map.addActor(ant)
end

function map.addSurface( surf )
  local node = map.surfs.addNew( surf )
  -- remember you are referenced on the surfs list
  table.insert( surf.nodesOnLists, node )    
  map.addActor(surf)
end

function map.init()
  limitsRect = api.newRectangle( map.minX, map.minY, map.maxX-map.minX, map.maxY-map.minY, limitsColor )
end

function map.update()
end

function map.draw()
  api.drawRectangle( limitsRect )
end

--- Currently return all actors near to given actor, must be optimized later with map partition grid
function map.actorsNear( actor )
  local result
  --if not optimized, return all actors
  result = map.actors 
  return result
end

return map