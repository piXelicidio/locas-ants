--- TAnt class, 

local apiG = love.graphics
local TActor = require('code.actor')
local TSurface = require('code.surface')
local vec = require('libs.vec2d_arr')
local cfg = require('code.simconfig')


-- Sorry of the Delphi-like class styles :P
local TAnt = {}

     
-- PUBLIC class fields
TAnt.map = {}  --circular reference to Map module. Set on map.lua

-- Sim has to set this refernce to the grid 
TAnt.grid = nil
-- PRIVATE class fields
local fSomething
  
-- PRIVATE class methods
local function doSomthing ()
  
end
  

--- Creating a new instance for TAnt class
function TAnt.create()
  local ant = TActor.create()
  
  --private instance fields
  local fSomevar = 0    
  local fPastPositions = {}    --all positions they can remember, this is a fixed size queue as array of vectors
  local fOldestPositionIndex = 0
  local fComEvery = math.random(unpack(cfg.antComNeedFrameStep))
  local fComEveryOffset =math.random(cfg.antComNeedFrameStep[2]) 
    
  --properties
  ant.direction = { 1.0, 0.0 } --direction heading movement unitary vector
  ant.oldPosition = {0, 0}
  ant.radius = 2
  ant.speed = 0.1  
  ant.friction = 1
  ant.acceleration = 0.04  + math.random()*0.05
  ant.erratic = cfg.antErratic                  --crazyness
  ant.maxSpeed = cfg.antMaxSpeed 
  ant.tasks = {'food','cave'}  --TODO: no need for Array of task, they can only have to targets, use two variables and swap
  ant.lookingForTask = 1  
  ant.comingFromTask = 0
  --ant.lookingFor = 'food'
  ant.comingFrom = ''
  ant.lastTimeSeenFood = -1
  ant.lastTimeSeenCave = -1
  ant.lastTimeSeen = {food = -1, cave = -1}   --we can access t['food'] = n
  ant.maxTimeSeen = -1
  ant.comingFromAtTime = 0
  ant.lastTimeUpdatedPath = -1
  ant.cargo = { material = '', count = 0 } 
  ant.oldestPositionRemembered = {0,0}  --vector 2D arr  
  ant.betterPathCount = 0
  ant.color = cfg.colorAnts
  ant.lastCollisionTime = -1
  
  
  
  ant.antPause = {
      iterMin = 10,                   --Stop for pause every iterMin to iterMax iterations.
      iterMax = 20,
      timeMin = 5,                    --Stop time from timeMin to timeMax iterations.
      timeMax = 15,
      nextPause = -1                  --When is the next pause?
    }
  ant.comRadius = 20                  -- Distance of comunication Ant-to-Ant. ant.radius is body radius
    
  
  --PRIVATE functions
  --TODO: local function checkFor
    
  --PUBLIC 
  ant.classType = TAnt 
  ant.classParent = TActor 
  
    
  function ant.init()          
    --preallocating  array
    for i=1,cfg.antPositionMemorySize do
      fPastPositions[i] = vec.makeFrom( ant.position )
    end
    fOldestPositionIndex = 1
    ant.oldestPositionRemembered = fPastPositions[1]
  end
  
  function ant.updatePaused()    
    if cfg.simFrameNumber >= ant.pauseUntil then ant.unPause() end    
  end
  
  --- Pause ant movement and thinking
  -- negaive time to pause indefinitely 
  function ant.pause( time )    
    ant.pauseUntil = cfg.simFrameNumber + time
    ant.paused = true    
  end
 
  function ant.unPause()
    ant.paused = false
  end
  
  --return normalized dir heading to Posi, or {1,0} if length = 0
  
  function ant.getDirectionTo( posi )
    local tempVec = vec.makeSub( posi, ant.position )
    local tempLen = vec.length( tempVec )
    if tempLen == 0 then tempVec[1],tempVec[2] = 1,0 else
      tempVec[1] = tempVec[1] / tempLen
      tempVec[2] = tempVec[2] / tempLen
    end  
    return tempVec
  end
  
  -- same as getDirectionTo, but do not create and not return a new table, use the one in the parameter
  function ant.setDirectionTo(varVec, posi )
    vec.setFrom( varVec, posi)
    vec.sub( varVec, ant.position )
    local tempLen = vec.length( varVec )
    if tempLen == 0 then varVec[1], varVec[2] = 1,0 else
      varVec[1] = varVec[1] / tempLen
      varVec[2] = varVec[2] / tempLen
    end      
  end
  
  --return True if bounced with not passable object
  function ant.collisionTestSurface( surf )
    
    local dist = vec.distance( surf.position, ant.position )    
    
    if dist < surf.radius + ant.radius then                 
      --ant.onSurfaceCollision( surf )
      if not surf.passable then
        local dv = vec.makeSub(surf.position, ant.position)
        local z = vec.crossProd( dv, ant.direction )      
        if vec.length(dv)>0 then
          vec.normalize(dv)        
          -- push out
          local pushed = vec.makeScale(dv, -(surf.radius + ant.radius+0.01) )
          vec.setFrom( ant.position, surf.position )
          vec.add( ant.position, pushed )
          -- rotate direction to circle tanget
          if z < 0 then
            vec.rotate(dv, -(math.pi)/2)          
          else
            vec.rotate(dv, (math.pi)/2 )
          end            
          ant.direction = dv  
          --priority direction change, must return
          return true
        end  
        --ant.speed = 0.1
      else
        ant.friction = surf.friction
      end

      --i'm looking for you?

      local myNeed = ant.tasks[ant.lookingForTask]
      if myNeed == surf.name then      
        --ant.pause(20)
        if surf.name == 'food' then        
          ant.cargo.count = 1
          ant.cargo.material = surf.name                          
        elseif surf.name == 'cave' then
          ant.cargo.count = 0      
        end      
        ant.maxTimeSeen = 0
        ant.comingFromTask = ant.lookingForTask
        ant.lookingForTask = ant.lookingForTask + 1          
        if ant.lookingForTask > #ant.tasks then ant.lookingForTask = 1 end         

        ant.comingFromAtTime = cfg.simFrameNumber
        local dv = vec.makeScale( ant.direction, -1) --go oposite 
        --ant.direction = dv      
        ant.speed = 0        
        ant.resetPositionMemory(surf.position)
        --debug        
      end 

      --if surf.name == 'food' then ant.lastTimeSeenFood = cfg.simFrameNumber
      --elseif surf.name == 'cave' then ant.lastTimeSeenCave = cfg.simFrameNumber end
      ant.lastTimeSeen[surf.name] = cfg.simFrameNumber   
      --vec.setFrom(ant.oldestPositionRemembered, surf.position)

    elseif (dist < surf.radius + cfg.antSightDistance)  then
      if ant.tasks[ant.lookingForTask] == surf.name then
        --fTargetInSight = true
        --fTargetLocated = vec.makeFrom(surf.position)        
        --ant.headTo(surf.position)
        return true         
      end    
    end 
  end --function
  
  
  function ant.storePosition( posi )
     vec.setFrom( fPastPositions[fOldestPositionIndex], posi )
     fOldestPositionIndex = fOldestPositionIndex + 1
     if fOldestPositionIndex > cfg.antPositionMemorySize then fOldestPositionIndex = 1 end     
     ant.oldestPositionRemembered = fPastPositions[ fOldestPositionIndex ]
  end
  
  function ant.resetPositionMemory( posi )
      for i = 1, #fPastPositions do
        vec.setFrom( fPastPositions[i], posi )
      end
  end
  
  function ant.objectAvoidance()
    local ahead = vec.makeScale( ant.direction, cfg.antSightDistance )
    if TAnt.map.anyCollisionWith( vec.makeSum( ant.position, ahead ) ) then
      -- if something blocking ahead, where to turn? left or right?
      --print('something in my way')
      local vLeft = vec.makeFrom( ant.direction )
      local vRight = vec.makeFrom( ant.direction )
      vec.rotate( vLeft, -3.14/6 )
      vec.rotate( vRight, 3.14/6 )
      local goLeft = vec.makeScale( vLeft, cfg.antSightDistance/2 )
      local goRight = vec.makeScale( vRight, cfg.antSightDistance/2 )    
      vec.add( goLeft, ant.position )
      vec.add( goRight, ant.position )
      local freeLeft = not TAnt.map.anyCollisionWith( goLeft )
      local freeRight = not TAnt.map.anyCollisionWith( goRight )      
      
      if freeLeft and not freeRight then
        --goleft
        vec.setFrom( ant.direction, vLeft )        
      elseif not freeLeft then
        --goright
        vec.setFrom( ant.direction, vRight )              
      end --else keep going
    end
  end
  
  
  function ant.update()     
    ant.storePosition( ant.position )    
    
    if ant.paused then
      ant.updatePaused()
    else      
      ant.speed = ant.speed + ant.acceleration
      ant.speed = ant.speed * ant.friction
      if ant.speed > ant.maxSpeed then ant.speed = ant.maxSpeed end               
      
      -- direction variation for next update    
      vec.rotate( ant.direction, ant.erratic * math.random() -(ant.erratic*0.5) )    
      
      ant.friction = 1   
      --if math.random()<0.01 then ant.pause(10) end
      
    end    
    --test pause    
  end
  

  function ant.drawNormal()            
    apiG.setColor(ant.color)
        
    apiG.line(ant.position[1] - ant.direction[1]*2, ant.position[2] - ant.direction[2]*2, ant.position[1] + ant.direction[1]*2, ant.position[2] + ant.direction[2]*2 ) 
    if ant.cargo.count~=0 then
      apiG.setColor(cfg.colorFood)
      if not cfg.debugGrid then apiG.circle("line", ant.position[1] + ant.direction[1]*2, ant.position[2] + ant.direction[2]*2, 0.5) end
    end
    -- debug    
  end
  
  ant.draw = ant.drawNormal
  
  function ant.drawDebug()
    ant.drawNormal()
    
    
        apiG.setColor(10,100,250)
    apiG.circle("line",ant.oldestPositionRemembered[1], ant.oldestPositionRemembered[2],1);
    --sight and comunication radius
    apiG.setColor(130,130,130)
    apiG.circle( "line", ant.position[1], ant.position[2], cfg.antSightDistance );
    apiG.line( ant.position[1] , ant.position[2] - cfg.antComRadius, 
               ant.position[1] + cfg.antComRadius, ant.position[2], 
               ant.position[1] , ant.position[2] + cfg.antComRadius, 
               ant.position[1] - cfg.antComRadius , ant.position[2],
               ant.position[1] , ant.position[2] - cfg.antComRadius)
  end
  
  function ant.setDrawMode( mode )
    if mode=="debug" then ant.draw = ant.drawDebug
    else ant.draw = ant.drawNormal
    end
  end
     
  -- TODO: maybe inline this later? 
  function ant.headTo( posi )         
    --local v = ant.getDirectionTo( posi )
    --vec.setFrom(ant.direction, v)    
    local v = {1,0}
--    ant.setDirectionTo( v, posi)
--    vec.scale(v, 5)
--    vec.add(v, ant.direction)
--    vec.normalize(v)
--    vec.setFrom(ant.direction, v)
    ant.setDirectionTo( ant.direction, posi )
    ant.lastTimeUpdatedPath = cfg.simFrameNumber
  end 
  
  --- ask ant if need comunication for this frame
  -- TODO: name has to change, is not always communication.. not in algorithm 4
  function ant.isComNeeded()
    return 
      ((cfg.simFrameNumber + fComEveryOffset) % fComEvery == 0     )   
  end
  
  --- This is the heart of the path finding magic (1)
  -- returns true IF better direction path is offered by the other ant 
  function ant.communicateWith( otherAnt )      
      -- Our essential ant-thinking rules: Have you seen recently what I'm interested in?      
      local myNeed = ant.tasks[ant.lookingForTask]
      if otherAnt.lastTimeSeen[myNeed] > ant.maxTimeSeen then
        ant.maxTimeSeen = otherAnt.lastTimeSeen[myNeed]        
        -- In that case I will go on the direction of last position you remember you are coming        
        ant.headTo( otherAnt.oldestPositionRemembered ) 
        --ant.speed = 0.1
        return true
      end          
  end
  
  --- This is the heart of the path finding magic (2) (TQuickList.array version;)  
  --  Don't test if obj~-otherAnt and dont' test manhattanDistance.
  function ant.communicateWithAnts( otherAntsList )            
      local myNeed
      local betterPathCount = 0
      local node
      --using pairs becasue some items may be nil  
      for _,node in pairs(otherAntsList) do
        --the array stores nodes, nodes store obj
        local otherAnt = node.obj
        if (vec.manhattanDistance( otherAnt.position, ant.position ) < cfg.antComRadius) 
            and (otherAnt~=obj) then --TODO: this should be eliminated when GRID implemented.
        -- Our essential ant-thinking rules: Have you seen recently what I'm interested in? 
          myNeed = ant.tasks[ant.lookingForTask]
          if otherAnt.lastTimeSeen[myNeed] > ant.maxTimeSeen then
            ant.maxTimeSeen = otherAnt.lastTimeSeen[myNeed]        
            -- In that case I will go on the direction of last position you remember you are coming        
            ant.headTo( otherAnt.oldestPositionRemembered )           
            betterPathCount = betterPathCount + 1
            if  betterPathCount >= cfg.antComMaxBetterPaths then return end
          end          
        end
      end
        
  end
  
  --- This is the heart of the path finding magic (3) (array of TQuickList version;)  
  --  Don't test if obj~-otherAnt and dont' test manhattanDistance.
  function ant.communicateWithAnts_grid( otherAntsLists )            
      local myNeed
      local betterPathCount = 0
      local node
      local otherAnt
      --using pairs becasue some items may be nil 
      for i=1,#otherAntsLists do
        for _,node in pairs(otherAntsLists[i].array) do
          --the array stores nodes, nodes store obj
          otherAnt = node.obj
          --(manhattan distance check removed, Lists should include only near ants)
          --otherAnt = obj, check if myself also removed, nothing bad happens if communication with itself occurs
          -- Our essential ant-thinking rules: Have you seen recently what I'm interested in? 
            myNeed = ant.tasks[ant.lookingForTask]
            if otherAnt.lastTimeSeen[myNeed] > ant.maxTimeSeen then
              ant.maxTimeSeen = otherAnt.lastTimeSeen[myNeed]        
              -- In that case I will go on the direction of last position you remember you are coming        
              ant.headTo( otherAnt.oldestPositionRemembered )           
              betterPathCount = betterPathCount + 1
              if  betterPathCount >= cfg.antComMaxBetterPaths then return end
            end          
          
        end
      end  
  end
  
  return ant
end

return TAnt