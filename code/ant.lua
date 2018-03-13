--- TAnt class, 

local apiG = love.graphics
local TActor = require('code.actor')
local vec = require('libs.vec2d_arr')
local cfg = require('code.simconfig')
local map = {}                          --circular reference to Map module. Set with TAnt.setMap on map.lua


-- Sorry of the Delphi-like class styles :P
local TAnt = {}

     
-- PUBLIC class fields
function TAnt.setMap ( ourMap )
  map = ourMap
end


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
  ant.pheromonesBackTime = -1
  ant.pheromonesWrite = true
  
  
  
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
  
  --- 
  function ant.disablePheromonesWrite( time )
    ant.pheromonesWrite = false
    ant.pheromonesBackTime = cfg.simFrameNumber + time
  end
  
  function ant.enablePheromonesWrite()
    ant.pheromonesWrite = true
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
  
  --- Avoid collisions with obstacles
 
  function ant.objectAvoidance()
    local ahead = vec.makeScale( ant.direction, cfg.antSightDistance )
    if  not map.gridCanPass(vec.makeSum( ant.position, ahead )) --[[TAnt.map.anyCollisionWith( vec.makeSum( ant.position, ahead ) )]] then
      -- if something blocking ahead, where to turn? left or right?
      --print('something in my way')
      local vLeft = vec.makeFrom( ant.direction )
      local vRight = vec.makeFrom( ant.direction )
      vec.rotate( vLeft, -cfg.antObjectAvoidance_FOV )
      vec.rotate( vRight, cfg.antObjectAvoidance_FOV )
      local goLeft = vec.makeScale( vLeft, cfg.antSightDistance/2 )
      local goRight = vec.makeScale( vRight, cfg.antSightDistance/2 )    
      vec.add( goLeft, ant.position )
      vec.add( goRight, ant.position )
      local freeLeft = not map.gridCanPass( goLeft )
      local freeRight = not map.gridCanPass( goRight )      
      
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
  end
  
  function ant.setDrawMode( mode )
    if mode=="debug" then ant.draw = ant.drawDebug
    else ant.draw = ant.drawNormal
    end
  end
     
  
  function ant.headTo( posi )             
    vec.setFrom( ant.direction, posi)
    vec.sub( ant.direction, ant.position )
    local tempLen = vec.length( ant.direction )
    if tempLen == 0 then ant.direction[1], ant.direction[2] = 1,0 else
     ant.direction[1] = ant.direction[1] / tempLen
     ant.direction[2] = ant.direction[2] / tempLen
    end
    ant.lastTimeUpdatedPath = cfg.simFrameNumber
  end 
  
  --- ask ant if need comunication for this frame
  -- TODO: name has to change, is not always communication.. not in algorithm 4
  function ant.isComNeeded()
    return 
      ((cfg.simFrameNumber + fComEveryOffset) % fComEvery == 0     )   
  end
  
  
  return ant
end

return TAnt