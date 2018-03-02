--- The global map where objects and actors and ants reside 

-- modules and aliases
local TQuickList = require('code.qlist')
local TSurface = require('code.surface') 
local TAnt = require('code.ant')
local cfg = require('code.simconfig')
local vec = require('libs.vec2d_arr')
local apiG = love.graphics

local map = {}

-- Map limits
map.minX = cfg.mapMinX
map.minY = cfg.mapMinY
map.maxX = cfg.mapMaxX
map.maxY = cfg.mapMaxY

--
map.actors = TQuickList.create()   --All actors including ants and surfaces
map.ants = TQuickList.create()     --All ants
map.surfs = TQuickList.create()    --All static surfaces (obstacles, caves, food... )

map.limitsColor = cfg.colorBkLimits

local limitsRect = {}

--TODO: discard AddActor OR (AddAnt and addSurface) ... think... 
function map.addActor( a )
  local node = map.actors.addNew( a )
  -- remember you are referenced on the actors list
  a.nodeRefs.actorsList = node
end

function map.addAnt( ant )
  local node = map.ants.addNew( ant )
  -- remember you are referenced on the ants list
  ant.nodeRefs.antsList = node   
  map.addActor(ant)
end

function map.addSurface( surf )
  local node = map.surfs.addNew( surf )
  -- remember you are referenced on the surfs list, knowYourNode.com for quick remove 'couse node know index
  surf.nodeRefs.surfsList = node
  map.addActor(surf)
end

function map.init()
  
end

function map.collisionDetection()
  local ant
  for _,node in pairs(map.ants.array) do
    
    --ant bounces with limits
    ant = node.obj 
    if ant.position[1] < map.minX then
      ant.position[1] = map.minX
      ant.speed=0.1
      if ant.direction[1] < 0 then ant.direction[1] = ant.direction[1] *-1 end
    elseif ant.position[1] > map.maxX then
      ant.position[1] = map.maxX
       ant.speed=0.1
      if ant.direction[1] > 0 then ant.direction[1] = ant.direction[1] *-1 end
    end
    
    if ant.position[2] < map.minY then
      ant.position[2] = map.minY
      ant.speed=0.1
      if ant.direction[2] < 0 then ant.direction[2] = ant.direction[2] *-1 end
    elseif ant.position[2] > map.maxY then
      ant.position[2] = map.maxY  
      ant.speed=0.1
      if ant.direction[2] > 0 then ant.direction[2] = ant.direction[2] *-1 end
    end 
    
    --ants with surfaces
    local surf
    for _,surfNode in pairs(map.surfs.array) do
        surf = surfNode.obj
        ant.collisionTestSurface(surf)
    end
    
    
    local otherAnt    
    --TODO: this of course is not final, space partition grid optimization goes here
    for _,node2 in pairs(map.ants.array) do
      --check if not myself -- i don't like this check
      otherAnt = node2.obj      
      if otherAnt ~= ant then
                    
        if vec.distanceInSteps( otherAnt.position, ant.position ) < cfg.antComRadius 
        then ant.communicateWith( otherAnt )     end      
      end --if
    end --for ]]
  end --for 
end;

function map.update()
  map.collisionDetection()
end

function map.draw()      
  apiG.setColor( map.limitsColor )
  apiG.rectangle("line", map.minX, map.minY, map.maxX-map.minX, map.maxY-map.minY )
end

--- Currently return all actors near to given actor, must be optimized later with map partition grid
function map.actorsNear( actor )
  local result
  --if not optimized, return all actors
  result = map.actors
  return result
end

return map