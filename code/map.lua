--- The global map where objects and actors and ants reside 

-- modules and aliases
local TQuickList = require('code.qlist')
local TSurface = require('code.surface') 
local cfg = require('code.simconfig')
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
  local obj
  for _,node in pairs(map.ants.array) do
    
    --ant bounces with limits
    obj = node.obj
    if obj.position.x < map.minX then
      obj.position.x = map.minX
      obj.speed=0.1
      if obj.direction.x < 0 then obj.direction.x = obj.direction.x *-1 end
    elseif obj.position.x > map.maxX then
      obj.position.x = map.maxX
       obj.speed=0.1
      if obj.direction.x > 0 then obj.direction.x = obj.direction.x *-1 end
    end
    
    if obj.position.y < map.minY then
      obj.position.y = map.minY
      obj.speed=0.1
      if obj.direction.y < 0 then obj.direction.y = obj.direction.y *-1 end
    elseif obj.position.y > map.maxY then
      obj.position.y = map.maxY  
      obj.speed=0.1
      if obj.direction.y > 0 then obj.direction.y = obj.direction.y *-1 end
    end 
    
    --ants with everthing else
    local others = map.actorsNear(obj)    
    local a
    for _,node2 in pairs(others.array) do
      --check if not myself -- i don't like this check
      a = node2.obj      
      if a ~= obj then
        --           
        if a.classType==TSurface then                     
          if obj.collisionWith(a)==true then
            -- collision with surfaces             
            
            obj.surfaceCollisionEvent(a)
          end 
        end
      end --if
    end --for
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