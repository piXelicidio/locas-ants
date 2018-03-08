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

-- calculating grid map dimensions, -- extra border (fGridBorder) to get rid of validations
map.minXg = math.floor(map.minX / map.gridSize) - gridBorder
map.maxXg = math.floor(map.maxX / map.gridSize) + gridBorder
map.minYg = math.floor(map.minY / map.gridSize) - gridBorder
map.maxYg = math.floor(map.maxY / map.gridSize) + gridBorder

function map.init()
  -- initializing all Grid data structure, avoiding future validations and mem allocation
  
  for i = map.minXg, map.maxXg do
    map.grid[i]={}
    for j = map.minYg, map.maxYg do
      map.grid[i][j] = {
        qlist = TQuickList.create(),
        dcolor = {math.random(160), math.random(160), math.random(250)},
        pheromInfo = {
            seen = {}            
          }
      }
      for k = 1, #cfg.antInterests do
        map.grid[i][j].pheromInfo.seen[ cfg.antInterests[k] ] = {
            time = -1,
            where = {1,0}  --last position remembered on the direction coming from
          }
      end
      
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
        posi = { idxX, idxY }       
        }
      -- insert my node on the bidimentional array grid
      grid[ actor.gridInfo.posi[1] ][ actor.gridInfo.posi[2] ].qlist.add( actor.nodeRefs.gridNode )
end

function map.updateOnGrid(grid, actor)
  local posiX = math.floor(actor.position[1]/map.gridSize)
  local posiY = math.floor(actor.position[2]/map.gridSize)   
  --comparing to know if actor is now in a new grid X,Y
  if (posiX ~= actor.gridInfo.posi[1] ) or (posiY ~= actor.gridInfo.posi[2] ) then
    --move from old list to new list
    actor.nodeRefs.gridNode.selfRemove()
    grid[ posiX ][ posiY ].qlist.add( actor.nodeRefs.gridNode )
    actor.gridInfo.posi[1] = posiX
    actor.gridInfo.posi[2] = posiY    
    --if cfg.debugGrid then actor.color = grid[ posiX ][ posiY ].dcolor end
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

--- for each grid cell run doFunc( TQuickList, x, y )
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
  local  cellcount = function(cell, i, j)
      if cell.qlist.count>0 then
        apiG.setColor( cell.dcolor )
        apiG.print(cell.qlist.count, i * map.gridSize, j * map.gridSize) 
      end
    end  
  if cfg.debugGrid  then
    map.gridForEachCell( cellcount )
  end
end


--- Returns array of TQuickLists with all near ants
-- do not modify this lists, use as read-only
-- 9 TQuickLists 
function map.antsNearMe( ant )
  local near={}
  local v
  --integer position on the grid for 'ant'
  local gx = ant.gridInfo.posi[1]
  local gy = ant.gridInfo.posi[2]
  --return ant neibours in 3x3 area
  for i = 1,#cfg.mapGridComScan do
    v=cfg.mapGridComScan[i]
    near[i] = map.grid[ gx + v[1] ][ gy + v[2] ].qlist
  end
  return near
end

return map