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
--Space Partition Grid
map.gridSize = cfg.mapGridSize
map.grid = {}

map.limitsColor = cfg.colorBkLimits

local limitsRect = {}
local gridBorder = 2
map.minXg = math.floor(map.minX / map.gridSize) - gridBorder
map.maxXg = math.floor(map.maxX / map.gridSize) + gridBorder
map.minYg = math.floor(map.minY / map.gridSize) - gridBorder
map.maxYg = math.floor(map.maxY / map.gridSize) + gridBorder

function map.init()
  -- calculating grid map dimensions
  -- extra border (fGridBorder) to get rid of validations

  for i = map.minXg, map.maxXg do
    map.grid[i]={}
    for j = map.minYg, map.maxYg do
      map.grid[i][j] = {
        qlist = TQuickList.create(),
        dcolor = {math.random(160), math.random(160), math.random(250)}
      }
    end
  end
end

--TODO: discard AddActor OR (AddAnt and addSurface) ... think... 
function map.addActor( a )
  local node = map.actors.addNew( a )
  -- remember you are referenced on the actors list
  a.nodeRefs.actorsList = node
end

function map.updateOnGrid_firstTime(grid, actor )
  --vector position inside grid, integer values x,y
  local idxX, idxY = math.floor(actor.position[1]/map.gridSize), math.floor(actor.position[2]/map.gridSize) 
  actor.gridInfo = {
        posi = { idxX, idxY },       
        lastPosi = { idxX, idxY }  
        }
      -- insert my node on the bidimentional array grid
      grid[ actor.gridInfo.posi[1] ][ actor.gridInfo.posi[2] ].qlist.add( actor.nodeRefs.gridNode )
end

function map.updateOnGrid(grid, actor)
  actor.gridInfo.posi[1] = math.floor(actor.position[1]/map.gridSize)
  actor.gridInfo.posi[2] = math.floor(actor.position[2]/map.gridSize)   
  --comparing to know if actor is now in a new grid X,Y
  if (actor.gridInfo.posi[1] ~= actor.gridInfo.lastPosi[1] ) or (actor.gridInfo.posi[2] ~= actor.gridInfo.lastPosi[2] ) then
    --move from old list to new list
    actor.nodeRefs.gridNode.selfRemove()
    grid[ actor.gridInfo.posi[1] ][ actor.gridInfo.posi[2] ].qlist.add( actor.nodeRefs.gridNode )
    actor.gridInfo.lastPosi[1] = actor.gridInfo.posi[1]
    actor.gridInfo.lastPosi[2] = actor.gridInfo.posi[2]
    if cfg.debugGrid then actor.color = grid[ actor.gridInfo.posi[1] ][ actor.gridInfo.posi[2] ].dcolor end
  end  
end

function map.addAnt( ant )
  local node = map.ants.addNew( ant )
  -- remember you are referenced on the ants list
  ant.nodeRefs.antsList = node   
  map.addActor(ant)
  --first time on the Grid map? you need node and more
  if not ant.nodeRefs.gridNode then 
    ant.nodeRefs.gridNode = TQuickList.newNode( ant ) 
    map.updateOnGrid_firstTime(map.grid, ant)   
  end
end

function map.addSurface( surf )
  local node = map.surfs.addNew( surf )
  -- remember you are referenced on the surfs list, knowYourNode.com for quick remove 'couse node know index
  surf.nodeRefs.surfsList = node
  map.addActor(surf)
end


function map.update()
  --map.collisionDetection()
end

function map.gridForEachCell( doFunc )
  for i = map.minXg+1, map.maxXg-1 do
    for j = map.minYg+1, map.maxYg-1 do
      doFunc(map.grid[i][j], i,j)      
    end
  end
end

function map.draw()      
  apiG.setColor( map.limitsColor )
  apiG.rectangle("line", map.minX, map.minY, map.maxX-map.minX, map.maxY-map.minY )
  --debuging grid
  if cfg.debugGrid  then
    map.gridForEachCell(
      function(cell, i, j)
        if cell.qlist.count>0 then
          apiG.setColor( cell.dcolor )
          apiG.print(cell.qlist.count, i * map.gridSize, j * map.gridSize) 
        end
      end
    )
  end
end


--- Currently return all actors near to given actor, must be optimized later with map partition grid
function map.actorsNear( actor )
  local result
  --if not optimized, return all actors
  result = map.actors
  return result
end

return map