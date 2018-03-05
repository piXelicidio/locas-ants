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

function sim.collisionDetection()
  local ant 
  for _,node in pairs(map.ants.array) do
    --ant bounces with limits
    ant = node.obj 
    if ant.position[1] < map.minX then
      ant.position[1] = map.minX
      ant.speed=0.1
      if ant.direction[1] < 0 then ant.direction[1] = ant.direction[1] *-1; goto continue end      
    elseif ant.position[1] > map.maxX then
      ant.position[1] = map.maxX
       ant.speed=0.1
      if ant.direction[1] > 0 then ant.direction[1] = ant.direction[1] *-1; goto continue end      
    end
    
    if ant.position[2] < map.minY then
      ant.position[2] = map.minY
      ant.speed=0.1
      if ant.direction[2] < 0 then ant.direction[2] = ant.direction[2] *-1; goto continue end      
    elseif ant.position[2] > map.maxY then
      ant.position[2] = map.maxY  
      ant.speed=0.1
      if ant.direction[2] > 0 then ant.direction[2] = ant.direction[2] *-1; goto continue end      
    end     
       
      --ants with surfaces
      local surf      
      for _,surfNode in pairs(map.surfs.array) do
          surf = surfNode.obj
          if ant.collisionTestSurface(surf) then 
            --if test return true, there is an important direction change, nothing else matters, 
            --continue loop with next ant, ignore path advice of our sisters
            goto continue
          end
      end      
      
      local otherAnt    
      local betterPathCount = 0
      --TODO: this of course is not final, space partition grid optimization help here      
      if (cfg.antComEveryFrame or ant.isComNeeded()) and cfg.antComEnabled   then
        ant.communicateWithAnts(map.ants.array)       
      end
      
    --there is no 'continue' keyword in lua, we should use goto or other workaround
    ::continue::
  end --for 
end;

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
