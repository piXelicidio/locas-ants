--- simulation 
local cfg = require('code.simconfig')
local cam = require('code.camview')
local TAnt = require('code.ant')
local map = require('code.map')
local TQuickList = require('code.qlist')
local vec = require('libs.vec2d_arr')
local TCell = require('code.cell')

local sim = {}

sim.interactionAlgorithm = {}

function sim.init()  
  math.randomseed(os.time())
   
  map.init()  
  TAnt.init()
  
  map.setCell_cave(-6, -4)
  map.setCell_food(12, 5)
  
   
  local newAnt
  local numAnts = cfg.numAnts
  if CURRENT_PLATFORM == 'mobile'then numAnts = cfg.numAntsMobile end
  for i=1,numAnts do
    newAnt = TAnt.create() 
    newAnt.init()
    map.addAnt( newAnt )
    local ang = math.random()*6.28
    newAnt.direction = {math.cos(ang), math.sin(ang)}
    newAnt.position[1] = math.cos(ang)*(50+i/60)
    newAnt.position[2] = math.sin(ang)*(50+i/60)
    if i<4 then newAnt.setDrawMode("debug") end
  end  
end

function sim.algorithm_doNothing()
    
end

function sim.interactionWithCells(ant)
  local gx = math.floor( ant.position[1] / cfg.mapGridSize )
  local gy = math.floor( ant.position[2] / cfg.mapGridSize )
  local cell =  map.grid[gx][gy].cell
  if cell then     
      cell.affectAnt( ant )      
      -- is this cell interesting for me?
      if ant.lastTimeSeen[cell.type] then ant.lastTimeSeen[cell.type] = cfg.simFrameNumber   end
  end
end

-- **Mix of old algorithm with Pheromones inspiration**, store bestSeen info on the cells.
-- this time they communicate indirectly using the Grid cells, equivalent to pheromones nature
function sim.algorithm_pheromones()  
    for _,node in pairs(map.ants.array) do      
      --ant bounces with limits
      local ant = node.obj 
      if not ant.paused then
       
      --ants with surfaces      
        map.resolve_BlockingCollision_andMove( ant ) 
        sim.interactionWithCells(ant)
                
        
        if (cfg.antComEveryFrame or ant.isComNeeded())  then                            
          --get info on ant cell position, of time and position stored from other ants.
         -- local antPosiX, antPosiY = ant.gridInfo.posi[1], ant.gridInfo.posi[2] 
          local antPosiX = math.floor( ant.position[1] / cfg.mapGridSize )
          local antPosiY = math.floor( ant.position[2] / cfg.mapGridSize )
          local pheromInfoSeen
          --TODO: what if ant can see a good phermone close to current cell and go for it? 
          for i=1,9 do
            pheromInfoSeen = map.grid[ antPosiX + cfg.mapGridComScan[i][1]  ]
                                     [ antPosiY + cfg.mapGridComScan[i][2]  ].pheromInfo.seen
            local myInterest = pheromInfoSeen[ ant.lookingFor ]
            
            if myInterest.time > ant.maxTimeSeen then                
              ant.maxTimeSeen = myInterest.time
              ant.headTo( myInterest.where )
            end              
          end
          -- share what i Know in the map... if
          if ant.pheromonesWrite then 
            
            pheromInfoSeen = map.grid[ antPosiX ] [ antPosiY ].pheromInfo.seen
            for name,time in pairs(ant.lastTimeSeen) do                
              local interest = pheromInfoSeen[ name ]                
              if time > interest.time then
                  interest.time = time                    
                  interest.where[1] = ant.oldestPositionRemembered[1]
                  interest.where[2] = ant.oldestPositionRemembered[2]               
              end
            end --for             
            
          elseif cfg.simFrameNumber >= ant.pheromonesBackTime  then ant.enablePheromonesWrite() end
          
        end   
        
        --ant knows where to go, but lets avoid some future collisons
        if cfg.antObjectAvoidance then ant.objectAvoidance()    end
      end --paused?
    end --for ant node  
end

function sim.update()
  
  if cfg.antComAlgorithm == 1 then sim.algorithm_pheromones() else  sim.algorithm_doNothing() end

  for _,node in pairs(map.ants.array) do
    node.obj.update()    
    --update on grid > don't delete yet, maybe needed again chico.
    --map.updateOnGrid(map.grid, node.obj) 
  end

  cfg.simFrameNumber = cfg.simFrameNumber + 1
end

function sim.draw()
  map.draw()  
  if not cfg.debugHideAnts then
    for _,node in pairs(map.actors.array) do
      node.obj.draw()    
    end  
  end
end

function sim.onClick(x, y)
  local xg, yg = map.worldToGrid( x, y)  
  if map.isInsideGrid(xg, yg) then map.grid[xg][yg].pass = false end
end

function sim.removeCell(xg, yg)
  if map.isInsideGrid(xg, yg) then
    local grid = map.grid[xg][yg]
    if grid.cell then
        -- be carful with portals, they are linked
        if grid.cell.type == 'portal' then
          --remove link too
          if grid.cell.link then
            local linkedCell = map.grid[ grid.cell.link.gridPos[1] ][ grid.cell.link.gridPos[2] ]
            linkedCell.pass = true
            linkedCell.cell = nil
          end
        end        
        grid.cell = nil
      end
      grid.pass = true
  end
end

function sim.setCell( cellType, xworld, yworld)
  local xg, yg = map.worldToGrid( xworld, yworld)  
  if map.isInsideGrid(xg, yg) then
    --always remove existing first:
    sim.removeCell(xg, yg)
    local grid = map.grid[xg][yg]
    if (cellType == 'block') or (cellType == 'obstacle') or (cellType == 'donotpass') then
      grid.pass = false
    elseif (cellType == 'grass') then
      grid.pass = true
      grid.cell = TCell.newGrass()
    elseif (cellType == 'food') then
      grid.pass = true
      grid.cell = TCell.newFood()
    elseif (cellType == 'cave') then
      grid.pass = true
      grid.cell = TCell.newCave()
    elseif (cellType == 'ground') or (cellType == "remove") then
      --sim.removeCell(xg, yg)
    elseif (cellType == 'portal') then
      grid.pass = true
      grid.cell = TCell.newPortal()
      grid.cell.gridPos = {xg, yg} 
      grid.cell.posi = {xg * cfg.mapGridSize, yg * cfg.mapGridSize}
    end
  end    
end


return sim
