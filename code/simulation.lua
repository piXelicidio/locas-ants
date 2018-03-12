--- simulation 
local cfg = require('code.simconfig')
local cam = require('code.camview')
local TAnt = require('code.ant')
local map = require('code.map')
local TSurface = require('code.surface')
local TQuickList = require('code.qlist')
local vec = require('libs.vec2d_arr')

local sim = {}

sim.interactionAlgorithm = {}

function sim.init()  
  math.randomseed(os.time())
  
  sim.interactionAlgorithm[0] = sim.algorithm0_doNothing
  sim.interactionAlgorithm[1] = sim.algorithm1_ZeroOptimization
  sim.interactionAlgorithm[2] = sim.algorithm2_oldChat
  sim.interactionAlgorithm[3] = sim.algorithm3_groupCells
  sim.interactionAlgorithm[4] = sim.algorithm4_pheromones
  
  map.init()   
  
  local newSur  
  for i=1,1 do
    newSur = TSurface.createCave(-250+200*(math.random()-0.5), 300*(math.random()-0.5), 20)
    newSur.init()    
    map.addSurface( newSur )
  end
  
  for i=1,1 do
    newSur = TSurface.createFood(400+200*(math.random()-0.5), 300*(math.random()-0.5), 30)
    newSur.init()    
    map.addSurface( newSur )
  end
  for i=1,4 do
    newSur = TSurface.createObstacle(-80+40*i, 500*(math.random()-0.5), 30+math.random()*20)    
    newSur.init()    
    map.addSurface( newSur )
  end 
  
  local newAnt
  for i=1,cfg.numAnts do
    newAnt = TAnt.create() 
    newAnt.init()
    map.addAnt( newAnt )
    local ang = math.random()*6.28
    newAnt.direction = {math.cos(ang), math.sin(ang)}
    newAnt.position[1] = math.cos(ang)*(50+i/60)
    newAnt.position[2] = math.sin(ang)*(50+i/60)
    if i<4 then newAnt.setDrawMode("debug") end
  end
  cam.translation.x = 500
  cam.translation.y = 300

  
  local numAnts, numSurs = 0,0;
  for _,node in pairs(map.actors.array) do
    if node.obj.classType == TAnt then numAnts = numAnts + 1 end
    if node.obj.classType == TSurface then numSurs = numSurs + 1 end
  end  
    
  print('numAnts: ',numAnts,' numSurs', numSurs)
  print('Mem used: '..math.floor( collectgarbage ('count'))..'kb')
  

end



function sim.collisionAntWithCells(ant)
   -- TODO: maybe this go better on map.updateOnGrid(...)
    local antX, antY = ant.position[1], ant.position[2]
    local posiXg = math.floor( antX / cfg.mapGridSize )
    local posiYg = math.floor( antY / cfg.mapGridSize )
    if not map.grid[posiXg][posiYg].pass then      
      --block pass
      local centerX = (posiXg + 0.5) * cfg.mapGridSize 
      local centerY = (posiYg + 0.5) * cfg.mapGridSize
      local relX = antX - centerX
      local relY = antY - centerY
      --know in what side of the square relX,relY is:
      if ((relY<-relX) and (relY>relX)) or ((relY>-relX) and (relY<relX)) then
        -- left or right side
        if ant.direction[2] >= 0 then
          ant.direction[1], ant.direction[2] = 0,1
        else
          ant.direction[1], ant.direction[2] = 0,-1
        end
        --push back
        if relX < 0 then ant.position[1] = centerX - ((cfg.mapGridSize /  2) + ant.radius)  
          else
            ant.position[1] = centerX + (cfg.mapGridSize /  2) 
        end
      else
        -- top or bottom
        if ant.direction[1] >= 0 then
          ant.direction[1], ant.direction[2] = 1,0
        else
          ant.direction[1], ant.direction[2] = -1,0
        end
        --push back
        if relY < 0 then ant.position[2] = centerY - ((cfg.mapGridSize /  2) + ant.radius)  
          else
            ant.position[2] = centerY + (cfg.mapGridSize /  2) 
        end
      end
    end
end

function sim.collisionAntWithLimits(ant)   
  
   -- sim.collisionAntWithCells(ant)  
    
    if ant.position[1] < map.minX then
      ant.position[1] = map.minX
      ant.speed=0.1
      if ant.direction[1] < 0 then ant.direction[1] = ant.direction[1] *-1; return true end      
    elseif ant.position[1] > map.maxX then
      ant.position[1] = map.maxX
       ant.speed=0.1
      if ant.direction[1] > 0 then ant.direction[1] = ant.direction[1] *-1; return true end      
    end
    
    if ant.position[2] < map.minY then
      ant.position[2] = map.minY
      ant.speed=0.1
      if ant.direction[2] < 0 then ant.direction[2] = ant.direction[2] *-1; return true end      
    elseif ant.position[2] > map.maxY then
      ant.position[2] = map.maxY  
      ant.speed=0.1
      if ant.direction[2] > 0 then ant.direction[2] = ant.direction[2] *-1; return true end      
    end 
end

function sim.collisionAntWithSurfaces(ant)  
  for _,surfNode in pairs(map.surfs.array) do
      local surf = surfNode.obj
      if ant.collisionTestSurface(surf) then 
        --if test return true, there is an important direction change, nothing else matters, 
        --continue loop with next ant, ignore path advice of our sisters
        return true
      end
  end      
end


function sim.algorithm0_doNothing()
    for _,node in pairs(map.ants.array) do
      --ant bounces with limits
      local ant = node.obj 
      sim.collisionAntWithLimits(ant) 
    end --for ant node  
end

-- **1) No optimizaiton, just test N*N all with all ants** no brain.
--if you are porting the code to other language or api start implementing this for simplicity and safety 
function sim.algorithm1_ZeroOptimization()
    for _,node in pairs(map.ants.array) do
      --ant bounces with limits
      local ant = node.obj 
      if not sim.collisionAntWithLimits(ant)  then
          --ants with surfaces      
        if not sim.collisionAntWithSurfaces(ant) then        
                    
            if (cfg.antComEveryFrame or ant.isComNeeded())  then
              ant.communicateWithAnts(map.ants.array)       
            end            
        end
      end
    end --for ant node  
end

-- **2) Old 2003 way, chat with neighbors** 
function sim.algorithm2_oldChat()
    for _,node in pairs(map.ants.array) do
      --ant bounces with limits
      local ant = node.obj 
      if not sim.collisionAntWithLimits(ant)  then
          --ants with surfaces      
        if not sim.collisionAntWithSurfaces(ant) then
            if (cfg.antComEveryFrame or ant.isComNeeded())  then
              local antLists = map.antsNearMe( ant )
              ant.communicateWithAnts_grid( antLists ) 
            end
        end
      end
    end --for ant node
end

-- 3) **New algorithm 2018 group info matters to all**, share it
function sim.algorithm3_groupCells()
  local centerCell --TQuickList
  local neiborCell --TQuickList
  
    
  -- visinting all cells
  for i = map.minXg+1, map.maxXg-1 do
    for j = map.minYg+1, map.maxYg-1 do
      -- get center cell
      centerCell = map.grid[i][j].qlist
      -- looking for best of these values, for tasks 
      local bestSeen = {}
      local bestDir = {} 
      local bestCount = 0
      
      for tasks = 1, #cfg.antInterests do
        bestSeen[ cfg.antInterests[ tasks ] ] = -1
        bestDir[ cfg.antInterests[ tasks ] ] = {1,0}
      end
      -- visit all neibors and center
      --if math.random()<0.1 then
        for n=1,#cfg.mapGridComScan do
          neiborCell = map.grid[ i + cfg.mapGridComScan[n][1] ][ j + cfg.mapGridComScan[n][2] ].qlist
          --for each ant found
          for _,node in pairs(neiborCell.array) do
            local neiborAnt = node.obj
            for t = 1, #cfg.antInterests do
              local task = cfg.antInterests[t]
              local seen = neiborAnt.lastTimeSeen[task]            
              if seen > bestSeen[ task ] then 
                bestSeen[ task ] = seen
                bestDir[ task ][1] = neiborAnt.oldestPositionRemembered[1]
                bestDir[ task ][2] = neiborAnt.oldestPositionRemembered[2]
                bestCount = bestCount + 1
                --if bestCount > 3 then goto continue end
              end
            end --fortasks  
          end --fora
        end --forn
      --end
      
      --apply collision and com info to center cell ants
      for _,node in pairs(centerCell.array) do
        local centerAnt = node.obj        
        if not sim.collisionAntWithLimits(centerAnt) then          
          if (not sim.collisionAntWithSurfaces(centerAnt)) and centerAnt.isComNeeded() then              
            local need = centerAnt.tasks[ centerAnt.lookingForTask ]
            if bestSeen[need] > centerAnt.maxTimeSeen then
              centerAnt.maxTimeSeen = bestSeen[need]
              centerAnt.headTo( bestDir[need] )
            end                
          end --ifnot
        end --ifnot
      end --for_,node
      
    end --forj
  end --fori
end

-- **4) Old algorithm 2 plus Pheromones inspiration**, store bestSeen info on the cells.
-- this time they communicate indirectly using the Grid cells, equivalent to pheromones nature
function sim.algorithm4_pheromones()  
    for _,node in pairs(map.ants.array) do
      --ant bounces with limits
      local ant = node.obj 
     -- sim.collisionAntWithLimits(ant)  
    --ants with surfaces      
      map.resolve_BlockingCollision_andMove( ant ) 
      sim.collisionAntWithSurfaces(ant) 
      
      
      if (cfg.antComEveryFrame or ant.isComNeeded())  then                            
        --get info on ant cell position, of time and position stored from other ants.
       -- local antPosiX, antPosiY = ant.gridInfo.posi[1], ant.gridInfo.posi[2] 
        local antPosiX = math.floor( ant.position[1] / cfg.mapGridSize )
        local antPosiY = math.floor( ant.position[2] / cfg.mapGridSize )
        local pheromInfoSeen
        for i = 1,1 do --do it for the 9 cells block
          pheromInfoSeen = map.grid[ antPosiX + cfg.mapGridComScan[i][1] ]
                                   [ antPosiY + cfg.mapGridComScan[i][2] ].pheromInfo.seen
          local myInterest = pheromInfoSeen[ ant.tasks[ant.lookingForTask] ]
          
          if myInterest.time > ant.maxTimeSeen then                
            ant.maxTimeSeen = myInterest.time
            ant.headTo( myInterest.where )                                   
           
          end              
        end
        -- share what i Know in the map...
        pheromInfoSeen = map.grid[ antPosiX ] [ antPosiY ].pheromInfo.seen
        for name,time in pairs(ant.lastTimeSeen) do                
          local interest = pheromInfoSeen[ name ]                
          if time > interest.time then
              interest.time = time                    
              interest.where[1] = ant.oldestPositionRemembered[1]
              interest.where[2] = ant.oldestPositionRemembered[2]               
          end
        end --for             
      end   
      
      --ant knows where to go, but lets avoid some future collisons
      ant.objectAvoidance()    
      
    end --for ant node  
end

function sim.update()
  
  sim.interactionAlgorithm[cfg.antComAlgorithm]()

  for _,node in pairs(map.ants.array) do
    node.obj.update()    
    if (cfg.antComAlgorithm == 2) or (cfg.antComAlgorithm==3) then map.updateOnGrid(map.grid, node.obj) end
  end

  cfg.simFrameNumber = cfg.simFrameNumber + 1
end

function sim.draw()
  map.draw()  
  for _,node in pairs(map.actors.array) do
    node.obj.draw()    
  end   
end

function sim.onClick(x, y)
  local xg, yg = map.worldToGrid( x, y)
  print (xg, yg)
  if map.isInsideGrid(xg, yg) then map.grid[xg][yg].pass = false end
end


return sim
