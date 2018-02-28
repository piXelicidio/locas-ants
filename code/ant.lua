--- TAnt class, 

local apiG = love.graphics
local TActor = require('code.actor')
local TSurface = require('code.surface')
local vec = require('libs.vec2d_arr')
local cfg = require('code.simconfig')

-- Sorry of the Delphi-like class styles :P
local TAnt = {}

     
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
    
  --PUBLIC properties
  obj.direction = { 1.0, 0.0 } --direction heading movement unitary vector
  obj.oldPosition = {0, 0}
  obj.speed = 0.1
  obj.friction = 1
  obj.acceleration = 0.04  + math.random()*0.05
  obj.erratic = 0.2                   --crazyness
  obj.maxSpeed = cfg.antMaxSpeed 
  obj.task = {collect = 'food', bringTo = 'cave'}
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
    obj.radius=4        
  end
  
  
  function obj.surfaceCollisionEvent( surf )
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
  
  function obj.draw()            
    apiG.setColor(cfg.colorAnts)
    -- apiG.circle( "line", obj.position[1], obj.position[2], obj.radius);    
    apiG.line(obj.position[1], obj.position[2], obj.position[1] + obj.direction[1]*5, obj.position[2] + obj.direction[2]*5 ) 
    
  end
  
  return obj
end

return TAnt