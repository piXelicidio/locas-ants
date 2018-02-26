--- TAnt class, 

local apiG = love.graphics
local TActor = require('code.actor')
local TSurface = require('code.surface')
local vec = require('libs.vec2d')

local ANT_MAXSPEED = 1.2

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
  obj.direction = { x = 1.0, y = 0.0 } --direction heading movement unitary vector
  obj.oldPosition = {x=0, y=0}
  obj.speed = 0.1
  obj.acceleration = 0.05
  obj.erratic = 0.2                --craziness
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
    if surf.obstacle then
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
    end
  end
  
  function obj.update()   
    
    obj.oldPosition.x = obj.position.x
    obj.oldPosition.y = obj.position.y
    
    obj.speed = obj.speed + obj.acceleration
    if obj.speed > ANT_MAXSPEED then obj.speed = ANT_MAXSPEED end
    
    local velocity = vec.makeScale( obj.direction, obj.speed )
    vec.add( obj.position, velocity )   
    -- direction variation for next update
    vec.rotate( obj.direction, obj.erratic * math.random() -(obj.erratic*0.5) )
        
  end
  
  function obj.draw()            
    apiG.setColor(255,255,0,255);
    apiG.circle( "line", obj.position.x, obj.position.y, obj.radius);
    --debug direction line
    apiG.line(obj.position.x, obj.position.y, obj.position.x + obj.direction.x*10, obj.position.y + obj.direction.y*10 ) 
  end
  
  return obj
end

return TAnt