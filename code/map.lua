--- The global map where objects and actors and ants reside 

-- modules and aliases
local TQuickList = require('code.qlist')
local TAnt = require('code.ant')
local cfg = require('code.simconfig')
local vec = require('libs.vec2d_arr')
local TCell = require('code.cell')
local apiG = love.graphics

local map = {}

TAnt.setMap( map )   -- back reference, ants want to know about map too.

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
map.grid = {}                       --array[X] of array[Y] of (qlist, dcolor, pheromInfo)

map.limitsColor = cfg.colorBkLimits

local limitsRect = {}
local gridBorder = 2

-- calculating grid map dimensions, 
-- extra border (fGridBorder) to get rid of validations (extraborder limits map)
map.minXg = math.floor(map.minX / map.gridSize) - gridBorder
map.maxXg = math.floor(map.maxX / map.gridSize) + gridBorder
map.minYg = math.floor(map.minY / map.gridSize) - gridBorder
map.maxYg = math.floor(map.maxY / map.gridSize) + gridBorder

local imgGround = apiG.newImage('images//ground01.png')
local imgBlock = apiG.newImage('images//block01.png')

function map.init()
  -- initializing all Grid data structure, avoiding future validations and mem allocation  
  TCell.init()
  for i = map.minXg, map.maxXg do
    map.grid[i]={}
    for j = map.minYg, map.maxYg do
      map.initCell(i,j)      
    end
  end  
end

function map.initCell(xg, yg)
    map.grid[xg][yg] = {
        qlist = TQuickList.create(),
        dcolor = {math.random(160), math.random(160), math.random(250)},
        pheromInfo = { seen = {} },
        pass = true,  --pasable or obstacle? setting borders 
        cell = nil,   --if 
      }
      for k = 1, #cfg.antInterests do
        map.grid[xg][yg].pheromInfo.seen[ cfg.antInterests[k] ] = {
            time = -1,
            where = {0,0},  --the non-normalized vector direction of last position remembered.            
          }
      end
    if math.random()<0.002 then map.grid[xg][yg].cell = TCell.newGrass() end
    if math.random()<0.001 then map.grid[xg][yg].pass = false end
end

function map.setCell_food(xg, yg)
  if not map.grid[xg][yg] then  
    map.initCell(xg,yg)
  end
  local cell = TCell.newFood()
  map.grid[xg][yg].cell = cell  
  cell.posi = {xg * cfg.mapGridSize, yg * cfg.mapGridSize }
end

function map.setCell_cave(xg, yg)
  if not map.grid[xg][yg] then  
    map.initCell(xg,yg)
  end  
  local cell = TCell.newCave() 
  map.grid[xg][yg].cell = TCell.newCave()
  cell.posi = {xg * cfg.mapGridSize, yg * cfg.mapGridSize }
end

--TODO: discard AddActor OR (AddAnt and addSurface) ... think... 
function map.addActor( a )
  local node = map.actors.addNew( a )
  -- remember you are referenced on the actors list
  a.nodeRefs.actorsList = node
end


function map.fixTraped( ant ) 
  --doing the spiral of freedom  
  local a, r= 0, 1, 0, 0
  local p = {0,0}
  local mcos, msin = math.cos, math.sin
  local collision =  true
  repeat 
    
    r = r + 1
    a = a + 0.1
    p[1] = ant.position[1] + r * mcos( a )
    p[2] = ant.position[2] + r * msin( a )
    collision = map.anyCollisionWith( p, ant.direction )
  until (not collision) or r >= 100
  if r < 100 then
    --fixed
    vec.setFrom( ant.position, p)    
  else 
    -- extreme case
    --print ('Ant stuck bigly');
  end
end

function map.gridCanPass( position )
  local posiXg = math.floor( position[1] / cfg.mapGridSize )
  local posiYg = math.floor( position[2] / cfg.mapGridSize )
  return map.grid[posiXg][posiYg].pass
end

function map.anyCollisionWithCell(position, direction)
    local antX, antY = position[1], position[2]
    local posiXg = math.floor( antX / cfg.mapGridSize )
    local posiYg = math.floor( antY / cfg.mapGridSize )
    direction = direction or {1,0} 
    
    if not map.grid[posiXg][posiYg].pass then      
      --block pass
      local centerX = (posiXg + 0.5) * cfg.mapGridSize 
      local centerY = (posiYg + 0.5) * cfg.mapGridSize
      local relX = antX - centerX
      local relY = antY - centerY
      --know in what side of the square relX,relY is:
      --suggest a new direction to go
      if ((relY<-relX) and (relY>relX)) or ((relY>-relX) and (relY<relX)) then
        -- left or right side
        if direction[2] >= 0 then
          direction[1], direction[2] = 0,1
        else
          direction[1], direction[2] = 0,-1
        end     
      else
        -- top or bottom        
        if direction[1] >= 0 then
           direction[1], direction[2] = 1,0
        else
          direction[1], direction[2] = -1,0
        end 
      end
      return true
    end
end

function map.anyCollisionWithLimits(position, direction)     
    -- sim.collisionAntWithCells(ant)      
    direction = direction or {1,0} 
    if position[1] < map.minX then
      if direction[1] < 0 then direction[1] = direction[1] *-1 end
      return true
    elseif position[1] > map.maxX then
      if direction[1] > 0 then direction[1] = direction[1] *-1 end
      return true
    end
    
    if position[2] < map.minY then  
      if direction[2] < 0 then direction[2] = direction[2] *-1 end
      return true
    elseif position[2] > map.maxY then
      if direction[2] > 0 then direction[2] = direction[2] *-1 end
      return true
    end 
end

function map.anyCollisionWith(position, direction)
    if map.anyCollisionWithLimits(position, direction) then
      return true
    elseif map.anyCollisionWithCell(position, direction) then
      return true
    end
end


function map.resolve_BlockingCollision_andMove( ant )
  local numTries = 0
  local collision = false
  local newPosi = {0, 0}
  local dir = { ant.direction[1], ant.direction[2] }
  
  repeat 
    numTries = numTries + 1
    vec.setFrom(newPosi, ant.position)
    newPosi[1] = newPosi[1] + dir[1] * ant.speed
    newPosi[2] = newPosi[2] + dir[2] * ant.speed
    
    --Test collision with cells:
    collision = map.anyCollisionWith( newPosi, dir )
    if collision and numTries==3 then
      --looks like stuck, try going back
      dir[1] = -ant.direction[1]
      dir[2] = -ant.direction[2]
    elseif collision and numTries == 6 then
      --no way to go     
      --do a severe push back to find a non-colliding place
      --this usually ocours if the user place a blocking object/gridCell over any ant
      map.fixTraped( ant )
    end
        
  until (not collision)  or (numTries >= 6)  
    
  vec.setFrom( ant.direction, dir)
  ant.position[1] =  ant.position[1] + dir[1] * ant.speed
  ant.position[2] =  ant.position[2] + dir[2] * ant.speed
  ant.traveled = ant.traveled + ant.speed
  
  if numTries > 1 then
    --there was al least one collision
    ant.lastCollisionTime = cfg.simFrameNumber
  end
  
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

local  cellcount = function(cell, i, j)
      if cell.qlist.count>0 then
        apiG.setColor( cell.dcolor )
        apiG.print(cell.qlist.count, i * map.gridSize, j * map.gridSize) 
      end
end  

local cellPheromInfo = function(cell, i, j)
    local pheromInfo = cell.pheromInfo
    for name,info in pairs(pheromInfo.seen) do      
      local alpha = 255 - (( cfg.simFrameNumber - info.time) / 5);
      if alpha < 30 then alpha = 10 end
      if name=='food' then apiG.setColor(255,255,200, alpha) 
      elseif name=='cave' then apiG.setColor(200,200,255, alpha) end
      if info.where[1]~=0 and info.where[2]~=0 then
        apiG.circle('line', i * map.gridSize + map.gridSize/2, j * map.gridSize + map.gridSize/2, 1 )           
        apiG.line( i * map.gridSize + map.gridSize/2, j * map.gridSize + map.gridSize/2, info.where[1], info.where[2] )
      end
    end
end

function map.draw()      
    --
  for i = map.minXg, map.maxXg do
    for j = map.minYg, map.maxYg do
      if map.grid[i][j].pass then
         apiG.setColor(255,255,255); 
         apiG.draw(imgGround, i*cfg.mapGridSize, j*cfg.mapGridSize, 0, cfg.imgScale, cfg.imgScale );
        local cell = map.grid[i][j].cell
        if cell then
          --apiG.setColor( cell.color )
          apiG.draw(cell.img, i*cfg.mapGridSize, j*cfg.mapGridSize, 0, cfg.imgScale, cfg.imgScale    )   
        end
      else
--        apiG.setColor( cfg.colorObstacle )
--        apiG.rectangle('fill',i*cfg.mapGridSize, j*cfg.mapGridSize, cfg.mapGridSize , cfg.mapGridSize )   
         apiG.setColor(255,255,255);
         apiG.draw(imgBlock, i*cfg.mapGridSize, j*cfg.mapGridSize, 0, cfg.imgScale, cfg.imgScale );
      end
    end
  end 
  --debuging grid
  apiG.setColor( map.limitsColor )
  apiG.rectangle("line", map.minX, map.minY, map.maxX-map.minX, map.maxY-map.minY )
  
  if cfg.debugGrid  then
    map.gridForEachCell( cellcount )
  end
  
  if cfg.debugPheromones then
    map.gridForEachCell( cellPheromInfo )
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

function map.isInsideGrid( xg, yg )
  return
    (xg >= map.minXg) and (xg <= map.maxXg) and (yg >= map.minYg) and (yg <= map.maxYg )
end

function map.worldToGrid( x, y)
  return math.floor(x / cfg.mapGridSize), math.floor(y / cfg.mapGridSize)
end

return map