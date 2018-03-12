--- TAnt class, 

local apiG = love.graphics
local TActor = require('code.actor')
local TSurface = require('code.surface')
local vec = require('libs.vec2d_arr')
local cfg = require('code.simconfig')

-- Sorry of the Delphi-like class styles :P
local TAnt = {}

     
-- PUBLIC class fields
-- Sim has to set this refernce to the grid 
TAnt.grid = nil
-- PRIVATE class fields
local fSomething
  
-- PRIVATE class methods
local function doSomthing ()
  
end
  

--- Creating a new instance for TAnt class
function TAnt.create()
  local obj = TActor.create()
  
  --private instance fields
  local fSomevar = 0    
  local fPastPositions = {}    --all positions they can remember, this is a fixed size queue as array of vectors
  local fOldestPositionIndex = 0
  local fComEvery = math.random(unpack(cfg.antComNeedFrameStep))
  local fComEveryOffset =math.random(cfg.antComNeedFrameStep[2]) 
    
  --properties
  obj.direction = { 1.0, 0.0 } --direction heading movement unitary vector
  obj.oldPosition = {0, 0}
  obj.radius = 2
  obj.speed = 0.1  
  obj.friction = 1
  obj.acceleration = 0.04  + math.random()*0.05
  obj.erratic = cfg.antErratic                  --crazyness
  obj.maxSpeed = cfg.antMaxSpeed 
  obj.tasks = {'food','cave'}  --TODO: no need for Array of task, they can only have to targets, use two variables and swap
  obj.lookingForTask = 1  
  obj.comingFromTask = 0
  --obj.lookingFor = 'food'
  obj.comingFrom = ''
  obj.lastTimeSeenFood = -1
  obj.lastTimeSeenCave = -1
  obj.lastTimeSeen = {food = -1, cave = -1}   --we can access t['food'] = n
  obj.maxTimeSeen = -1
  obj.comingFromAtTime = 0
  obj.lastTimeUpdatedPath = -1
  obj.cargo = { material = '', count = 0 } 
  obj.oldestPositionRemembered = {0,0}  --vector 2D arr  
  obj.betterPathCount = 0
  obj.color = cfg.colorAnts
  obj.lastCollisionTime = -1
  
  
  
  obj.antPause = {
      iterMin = 10,                   --Stop for puse every iterMin to iterMax iterations.
      iterMax = 20,
      timeMin = 5,                    --Stop time from timeMin to timeMax iterations.
      timeMax = 15,
      nextPause = -1                  --When is the next pause?
    }
  obj.comRadius = 20                  -- Distance of comunication Ant-to-Ant. obj.radius is body radius
  --PRIVATE functions
  --TODO: local function checkFor
    
  --PUBLIC 
  obj.classType = TAnt 
  obj.classParent = TActor 
  
    
  function obj.init()      
    --preallocating  array
    for i=1,cfg.antPositionMemorySize do
      fPastPositions[i] = vec.makeFrom( obj.position )
    end
    fOldestPositionIndex = 1
    obj.oldestPositionRemembered = fPastPositions[1]
  end
  
  --return normalized dir heading to Posi, or {1,0} if length = 0
  
  function obj.getDirectionTo( posi )
    local tempVec = vec.makeSub( posi, obj.position )
    local tempLen = vec.length( tempVec )
    if tempLen == 0 then tempVec[1],tempVec[2] = 1,0 else
      tempVec[1] = tempVec[1] / tempLen
      tempVec[2] = tempVec[2] / tempLen
    end  
    return tempVec
  end
  
  -- same as getDirectionTo, but do not create and not return a new table, use the one in the parameter
  function obj.setDirectionTo(varVec, posi )
    vec.setFrom( varVec, posi)
    vec.sub( varVec, obj.position )
    local tempLen = vec.length( varVec )
    if tempLen == 0 then varVec[1], varVec[2] = 1,0 else
      varVec[1] = varVec[1] / tempLen
      varVec[2] = varVec[2] / tempLen
    end      
  end
  
  --return True if bounced with not passable object
  function obj.collisionTestSurface( surf )
    
    local dist = vec.distance( surf.position, obj.position )    
    
    if dist < surf.radius + obj.radius then                 
      --obj.onSurfaceCollision( surf )
      if not surf.passable then
        local dv = vec.makeSub(surf.position, obj.position)
        local z = vec.crossProd( dv, obj.direction )      
        if vec.length(dv)>0 then
          vec.normalize(dv)        
          -- push out
          pushed = vec.makeScale(dv, -(surf.radius + obj.radius+0.01) )
          vec.setFrom( obj.position, surf.position )
          vec.add( obj.position, pushed )
          -- rotate direction to circle tanget
          if z < 0 then
            vec.rotate(dv, -(math.pi)/2)          
          else
            vec.rotate(dv, (math.pi)/2 )
          end            
          obj.direction = dv  
          --priority direction change, must return
          return true
        end  
        --obj.speed = 0.1
      else
        obj.friction = surf.friction
      end

      --i'm looking for you?

      myNeed = obj.tasks[obj.lookingForTask]
      if myNeed == surf.name then      
        if surf.name == 'food' then        
          obj.cargo.count = 1
          obj.cargo.material = surf.name                          
        elseif surf.name == 'cave' then
          obj.cargo.count = 0      
        end      
        obj.maxTimeSeen = 0
        obj.comingFromTask = obj.lookingForTask
        obj.lookingForTask = obj.lookingForTask + 1          
        if obj.lookingForTask > #obj.tasks then obj.lookingForTask = 1 end         

        obj.comingFromAtTime = cfg.simFrameNumber
        dv = vec.makeScale( obj.direction, -1) --go oposite 
        obj.direction = dv      
        obj.speed = 0
        --debug        
      end 

      --if surf.name == 'food' then obj.lastTimeSeenFood = cfg.simFrameNumber
      --elseif surf.name == 'cave' then obj.lastTimeSeenCave = cfg.simFrameNumber end
      obj.lastTimeSeen[surf.name] = cfg.simFrameNumber   
      --vec.setFrom(obj.oldestPositionRemembered, surf.position)

    elseif (dist < surf.radius + cfg.antSightDistance)  then
      if obj.tasks[obj.lookingForTask] == surf.name then
        --fTargetInSight = true
        --fTargetLocated = vec.makeFrom(surf.position)        
        obj.headTo(surf.position)
        return true         
      end    
    end 
  end --function
  
  
  function obj.storePosition( posi )
     vec.setFrom( fPastPositions[fOldestPositionIndex], posi )
     fOldestPositionIndex = fOldestPositionIndex + 1
     if fOldestPositionIndex > cfg.antPositionMemorySize then fOldestPositionIndex = 1 end     
     obj.oldestPositionRemembered = fPastPositions[ fOldestPositionIndex ]
  end
  
  function obj.update()     
    obj.storePosition( obj.position )    
    obj.speed = obj.speed + obj.acceleration
    obj.speed = obj.speed * obj.friction
    if obj.speed > obj.maxSpeed then obj.speed = obj.maxSpeed end           
    -- direction variation for next update
    vec.rotate( obj.direction, obj.erratic * math.random() -(obj.erratic*0.5) )    
    -- MOVE, not move, just TRY by testing collisions first
     --vec.add( obj.position, vec.makeScale( obj.direction, obj.speed ) )   
     
     -- This ant wants to move obj.position + obj.direction * obj.speed; future collision tests will tell if possible and determine.
     -- Simulation determine collision and actual modtion.
    
    --I'm lost?
    if (cfg.simFrameNumber - obj.lastTimeUpdatedPath) > cfg.antComTimeToAcceptImLost then
      --reconsider my demands
      obj.maxTimeSeen = - obj.maxTimeSeen - cfg.antComOlderInfoIfLost
      if obj.maxTimeSeen < -1 then obj.maxTimeSeen = -1 end      
    end      
    --reset friction: 
    --TODO: i don't like this
    obj.friction = 1   
    
  end
  

  function obj.drawNormal()            
    apiG.setColor(obj.color)
        
    apiG.line(obj.position[1] - obj.direction[1]*2, obj.position[2] - obj.direction[2]*2, obj.position[1] + obj.direction[1]*2, obj.position[2] + obj.direction[2]*2 ) 
    if obj.cargo.count~=0 then
      apiG.setColor(cfg.colorFood)
      if not cfg.debugGrid then apiG.circle("line", obj.position[1] + obj.direction[1]*2, obj.position[2] + obj.direction[2]*2, 0.5) end
    end
    -- debug    
  end
  
  obj.draw = obj.drawNormal
  
  function obj.drawDebug()
    obj.drawNormal()
    
    
        apiG.setColor(10,100,250)
    apiG.circle("line",obj.oldestPositionRemembered[1], obj.oldestPositionRemembered[2],1);
    --sight and comunication radius
    apiG.setColor(130,130,130)
    apiG.circle( "line", obj.position[1], obj.position[2], cfg.antSightDistance );
    apiG.line( obj.position[1] , obj.position[2] - cfg.antComRadius, 
               obj.position[1] + cfg.antComRadius, obj.position[2], 
               obj.position[1] , obj.position[2] + cfg.antComRadius, 
               obj.position[1] - cfg.antComRadius , obj.position[2],
               obj.position[1] , obj.position[2] - cfg.antComRadius)
  end
  
  function obj.setDrawMode( mode )
    if mode=="debug" then obj.draw = obj.drawDebug
    else obj.draw = obj.drawNormal
    end
  end
     
  -- TODO: maybe inline this later? 
  function obj.headTo( posi )         
    --local v = obj.getDirectionTo( posi )
    --vec.setFrom(obj.direction, v)    
    obj.setDirectionTo( obj.direction, posi )
    obj.lastTimeUpdatedPath = cfg.simFrameNumber
  end 
  
  --- ask ant if need comunication for this frame
  -- TODO: name has to change, is not always communication.. not in algorithm 4
  function obj.isComNeeded()
    return 
      ((cfg.simFrameNumber + fComEveryOffset) % fComEvery == 0     )   
  end
  
  --- This is the heart of the path finding magic (1)
  -- returns true IF better direction path is offered by the other ant 
  function obj.communicateWith( otherAnt )      
      -- Our essential ant-thinking rules: Have you seen recently what I'm interested in?      
      local myNeed = obj.tasks[obj.lookingForTask]
      if otherAnt.lastTimeSeen[myNeed] > obj.maxTimeSeen then
        obj.maxTimeSeen = otherAnt.lastTimeSeen[myNeed]        
        -- In that case I will go on the direction of last position you remember you are coming        
        obj.headTo( otherAnt.oldestPositionRemembered ) 
        --obj.speed = 0.1
        return true
      end          
  end
  
  --- This is the heart of the path finding magic (2) (TQuickList.array version;)  
  --  Don't test if obj~-otherAnt and dont' test manhattanDistance.
  function obj.communicateWithAnts( otherAntsList )            
      local myNeed
      local betterPathCount = 0
      local node
      --using pairs becasue some items may be nil  
      for _,node in pairs(otherAntsList) do
        --the array stores nodes, nodes store obj
        local otherAnt = node.obj
        if (vec.manhattanDistance( otherAnt.position, obj.position ) < cfg.antComRadius) 
            and (otherAnt~=obj) then --TODO: this should be eliminated when GRID implemented.
        -- Our essential ant-thinking rules: Have you seen recently what I'm interested in? 
          myNeed = obj.tasks[obj.lookingForTask]
          if otherAnt.lastTimeSeen[myNeed] > obj.maxTimeSeen then
            obj.maxTimeSeen = otherAnt.lastTimeSeen[myNeed]        
            -- In that case I will go on the direction of last position you remember you are coming        
            obj.headTo( otherAnt.oldestPositionRemembered )           
            betterPathCount = betterPathCount + 1
            if  betterPathCount >= cfg.antComMaxBetterPaths then return end
          end          
        end
      end
        
  end
  
  --- This is the heart of the path finding magic (3) (array of TQuickList version;)  
  --  Don't test if obj~-otherAnt and dont' test manhattanDistance.
  function obj.communicateWithAnts_grid( otherAntsLists )            
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
            myNeed = obj.tasks[obj.lookingForTask]
            if otherAnt.lastTimeSeen[myNeed] > obj.maxTimeSeen then
              obj.maxTimeSeen = otherAnt.lastTimeSeen[myNeed]        
              -- In that case I will go on the direction of last position you remember you are coming        
              obj.headTo( otherAnt.oldestPositionRemembered )           
              betterPathCount = betterPathCount + 1
              if  betterPathCount >= cfg.antComMaxBetterPaths then return end
            end          
          
        end
      end  
  end
  
  return obj
end

return TAnt