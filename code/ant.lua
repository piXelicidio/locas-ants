--- TAnt class, 

local apiG = love.graphics
local TActor = require('code.actor')
local TSurface = require('code.surface')
local vec = require('libs.vec2d_arr')
local cfg = require('code.simconfig')

-- Sorry of the Delphi-like class styles :P
local TAnt = {}

     
-- PUBLIC class fields
TAnt.SomethingClassy = 0
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
  local fLastTrustable =  {
          comingFromAtTime = 0
        }
  local fPastPositions = {}    --all positions they can remember, this is a fixed size queue as array of vectors
  local fOldestPositionIndex = 0
  local fTargetInSight = false
  local fTargetLocated = {0,0}
  
  --properties
  obj.direction = { 1.0, 0.0 } --direction heading movement unitary vector
  obj.oldPosition = {0, 0}
  obj.speed = 0.1
  obj.friction = 1
  obj.acceleration = 0.04  + math.random()*0.05
  obj.erratic = cfg.antErratic                  --crazyness
  obj.maxSpeed = cfg.antMaxSpeed 
  obj.tasks = {'food','cave'}
  obj.lookingForTask = 1  
  obj.comingFromTask = 0
  obj.lookingFor = 'food'
  obj.comingFrom = ''
  obj.lastTimeSeenFood = -1
  obj.lastTimeSeenCave = -1
  obj.lastTimeSeen = {food = -1, cave = -1}   --we can access t['food'] = n
  obj.comingFromAtTime = 0
  obj.cargo = { material = '', count = 0 } 
  obj.oldestPositionRemembered = {0,0}  --vector 2D arr  
  
  
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
    obj.radius=1  
    --preallocating  array
    for i=1,cfg.antPositionMemorySize do
      fPastPositions[i] = vec.makeFrom( obj.position )
    end
    fOldestPositionIndex = 1
    obj.oldestPositionRemembered = fPastPositions[1]
  end
  
  function obj.collisionTestSurface( surf )
    local dist = vec.distance( surf.position, obj.position )    
    --sight view? 
    if dist < surf.radius + cfg.antSightDistance then
      if obj.tasks[obj.lookingForTask] == surf.name then
        fTargetInSight = true
        fTargetLocated = vec.makeFrom(surf.position)
      end
      if dist < surf.radius + obj.radius then
        fTargetInSight = false
        obj.onSurfaceCollision( surf )
      end
    end
  end
  
  function obj.onSurfaceCollision( surf )
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
      end  
      obj.speed = 0.1
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
      fLastTrustable.comingFromAtTime = 0
      obj.comingFromTask = obj.lookingForTask
      obj.lookingForTask = obj.lookingForTask + 1          
      if obj.lookingForTask > #obj.tasks then obj.lookingForTask = 1 end         
      
      obj.comingFromAtTime = cfg.simFrameNumber
      vec.scale( obj.direction, -1) --go oposite 
      obj.speed = 0
      --debug        
    end 
      
    --if surf.name == 'food' then obj.lastTimeSeenFood = cfg.simFrameNumber
    --elseif surf.name == 'cave' then obj.lastTimeSeenCave = cfg.simFrameNumber end
    obj.lastTimeSeen[surf.name] = cfg.simFrameNumber
  
  end
  
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
    
    --priority target    
    if fTargetInSight then
      obj.headTo( fTargetLocated )      
      fTargetInSight = false         
    end
    
    local velocity = vec.makeScale( obj.direction, obj.speed )
    vec.add( obj.position, velocity )   
    -- direction variation for next update
    vec.rotate( obj.direction, obj.erratic * math.random() -(obj.erratic*0.5) )
      
    --reset friction: 
    --TODO: i don't like this
    obj.friction = 1    
  end
  

  function obj.drawNormal()            
    apiG.setColor(cfg.colorAnts)
        
    apiG.line(obj.position[1] - obj.direction[1]*2, obj.position[2] - obj.direction[2]*2, obj.position[1] + obj.direction[1]*2, obj.position[2] + obj.direction[2]*2 ) 
    if obj.cargo.count~=0 then
      apiG.setColor(cfg.colorFood)
      apiG.circle("line", obj.position[1] + obj.direction[1]*2, obj.position[2] + obj.direction[2]*2, 1)
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
     
  -- TODO: maybe inline this later? Influence from 0..1
  function obj.headTo( posi )         
    local v = vec.makeSub(posi, obj.position)
    local l = vec.length( v )    
    if l>0 then
      -- normalizing, setting new dir 
      v[1] = v[1] / l
      v[2] = v[2] / l
      vec.setFrom(obj.direction, v)
    end
  end
     
  function obj.communicateWith( otherAnt )      
      -- Our essential ant-thinking rules: Have you seen recently what I'm interested in?
      local myNeed = obj.tasks[obj.lookingForTask]
      if otherAnt.lastTimeSeen[myNeed] > fLastTrustable.comingFromAtTime then
        fLastTrustable.comingFromAtTime = otherAnt.lastTimeSeen[myNeed]        
        -- In that case I will go on the direction of last position you remember you are coming        
        obj.headTo( otherAnt.oldestPositionRemembered )        
      end     
  end
  
  return obj
end

return TAnt