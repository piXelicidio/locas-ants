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
          antObj = nil,          
          comingFromDir = {1,0},
          comingFromAtTime = 0
        }
  local fPastPositions = {}    --all positions they can remember, this is a fixed size queue as array of vectors
  local fOldestPositionIndex = 0
  local fOldestPositionRemembered = {0,0}  --vector 2D arr
  
  --properties
  obj.direction = { 1.0, 0.0 } --direction heading movement unitary vector
  obj.oldPosition = {0, 0}
  obj.speed = 0.1
  obj.friction = 1
  obj.acceleration = 0.04  + math.random()*0.05
  obj.erratic = 0.02                   --crazyness
  obj.maxSpeed = cfg.antMaxSpeed 
  obj.lookingFor = 'food'
  obj.comingFrom = ''
  obj.lastTimeSeenFood = -1
  obj.lastTimeSeenCave = -1
  obj.comingFromAtTime = 0
  obj.cargo = { material = '', count = 0 } 
    
  
  
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
    --TODO: this is mess, FIX
    if obj.lookingFor == surf.name then
      if surf.name == 'food' then
        if obj.cargo.count == 0 then
          obj.cargo.count = 1
          obj.cargo.material = surf.name
          obj.lookingFor = 'cave'
          obj.comingFrom = 'food'
        end
      elseif surf.name == 'cave' then
        obj.cargo.count = 0
        obj.lookingFor = 'food'
        obj.comingFrom = 'cave'
      end
      obj.comingFromAtTime = cfg.simFrameNumber
      vec.scale( obj.direction, -1) --go oposite
      --debug        
    end 
    
    if surf.name == 'food' then obj.lastTimeSeenFood = cfg.simFrameNumber
    elseif surf.name == 'cave' then obj.lastTimeSeenCave = cfg.simFrameNumber end
  
  end
  
  function obj.update()   
    
    vec.setFrom( obj.oldPosition, obj.position )
    
    obj.speed = obj.speed + obj.acceleration
    obj.speed = obj.speed * obj.friction
    if obj.speed > obj.maxSpeed then obj.speed = obj.maxSpeed end
    
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
    --apiG.circle( "line", obj.position[1], obj.position[2], 2);    
    apiG.line(obj.position[1] - obj.direction[1]*2, obj.position[2] - obj.direction[2]*2, obj.position[1] + obj.direction[1]*2, obj.position[2] + obj.direction[2]*2 ) 
    if obj.cargo.count~=0 then
      apiG.setColor(cfg.colorFood)
      apiG.points( obj.position[1] + obj.direction[1]*2, obj.position[2] + obj.direction[2]*2)
    end
    -- debug    
  end
  
  obj.draw = obj.drawNormal
  
  function obj.drawDebug()
    obj.drawNormal()
    local vdir = vec.makeScale( fLastTrustable.comingFromDir, 10)
    apiG.setColor(100,100,10)
    apiG.line(obj.position[1], obj.position[2], obj.position[1] + vdir[1], obj.position[2] + vdir[2] ) 
  end
  
  function obj.setDrawMode( mode )
    if mode=="debug" then obj.draw = obj.drawDebug
    else obj.draw = obj.drawNormal
    end
  end
     
  function obj.communicateWith( otherAnt )      
      -- Our essential ant-thinking rules: Have you seen recently what I'm interested in?
      if obj.lookingFor == "food" then
        --Ok, but how long from when you visit there? After the last one I trusted in, so I can trust you better?        
        if otherAnt.lastTimeSeenFood > fLastTrustable.comingFromAtTime then
          fLastTrustable.comingFromAtTime = otherAnt.lastTimeSeenFood
          fLastTrustable.antObj = otherAnt
          -- In that case I will go on the oposite direction of your movement
          fLastTrustable.comingFromDir = vec.makeScale( otherAnt.direction, -1)
          obj.direction = fLastTrustable.comingFromDir          
        end
      elseif obj.lookingFor == "cave" then
        --Ok, but how long from when you visit there? After the last one I trusted in, so I can trust you better?        
        if otherAnt.lastTimeSeenCave > fLastTrustable.comingFromAtTime then
          fLastTrustable.comingFromAtTime = otherAnt.lastTimeSeenCave
          fLastTrustable.antObj = otherAnt
          -- In that case I will go on the oposite direction of your movement
          fLastTrustable.comingFromDir = vec.makeScale( otherAnt.direction, -1)
          obj.direction = fLastTrustable.comingFromDir          
        end
      end
  end
  
  return obj
end

return TAnt