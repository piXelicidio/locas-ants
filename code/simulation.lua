--- simulation 
local cfg = require('code.simconfig')
local cam = require('code.camview')
local TAnt = require('code.ant')
local map = require('code.map')
local TSurface = require('code.surface')
local TQuickList = require('code.qlist')
local vec = require('libs.vec2d_arr')

local sim = {}

function sim.init()  
  math.randomseed(os.time())
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
  for i=1,8 do
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
  print('Initial memory: '..math.floor( collectgarbage ('count'))..'kb')
end

function sim.collisionAntWithLimits(ant)
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

function sim.collisionDetection()
  local ant 
  if cfg.antComAlgorithm ~= 3 then
    for _,node in pairs(map.ants.array) do
      --ant bounces with limits
      ant = node.obj 
      if not sim.collisionAntWithLimits(ant)  then
          --ants with surfaces      
        if not sim.collisionAntWithSurfaces(ant) then
        
          -- **1) No optimizaiton, just test N*N all with all ants**.
          --if you are porting the code to other language or api start implementing this for simplicity and safety
          if cfg.antComAlgorithm == 1 then      
            local otherAnt    
            local betterPathCount = 0      
            if (cfg.antComEveryFrame or ant.isComNeeded())  then
              ant.communicateWithAnts(map.ants.array)       
            end
          
          -- **2) Old 2003 way, chat with neighbors** 
          elseif cfg.antComAlgorithm == 2 then
            if (cfg.antComEveryFrame or ant.isComNeeded())  then
              local antLists = map.antsNearMe( ant )
              ant.communicateWithAnts_grid( antLists ) 
            end
          end   
        end
      end
    end --for ant node
  else  
    -- **3) New 2018, go by cell and process a cell group at once.**
    if cfg.antComAlgorithm == 3 then
      sim.antCommunication3()
    end
  end --if cfg.antCom... ~= 3
end

-- 3) **New algorithm 2018 group info matters to all**, share it
function sim.antCommunication3()
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

function sim.update()
  sim.collisionDetection()

  for _,node in pairs(map.ants.array) do
    node.obj.update()    
    map.updateOnGrid(map.grid, node.obj)
  end

  cfg.simFrameNumber = cfg.simFrameNumber + 1
end

function sim.draw()
  map.draw()  
  for _,node in pairs(map.actors.array) do
    node.obj.draw()    
  end   
end


return sim
