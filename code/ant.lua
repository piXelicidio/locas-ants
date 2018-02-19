--- TAnt class, 
-- (PURE Lua)

local TActor = require('code.actor')
local TSurface = require('code.surface')
local vec = require('extlibs.vec2d')
local map = require('code.map')

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
  
  function obj.interactions()
    local actors = map.actorsNear(obj)    
    for _,node in pairs(actors.array) do
      --check if not myself -- i don't like this check
      local a = node.obj      
      if a ~= obj then
        --        
        if a.classType==TSurface then           
          if obj.collisionWith(a)==true then
            -- collision with surfaces             
            obj.surfaceCollisionEvent(a)
          end 
        end
      end
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
       
    --- checking for limits and bounce
    if obj.position.x < map.minX then
      obj.position.x = map.minX
      obj.speed=0.1
      if obj.direction.x < 0 then obj.direction.x = obj.direction.x *-1 end
    elseif obj.position.x > map.maxX then
      obj.position.x = map.maxX
       obj.speed=0.1
      if obj.direction.x > 0 then obj.direction.x = obj.direction.x *-1 end
    end
    
    if obj.position.y < map.minY then
      obj.position.y = map.minY
      obj.speed=0.1
      if obj.direction.y < 0 then obj.direction.y = obj.direction.y *-1 end
    elseif obj.position.y > map.maxY then
      obj.position.y = map.maxY  
      obj.speed=0.1
      if obj.direction.y > 0 then obj.direction.y = obj.direction.y *-1 end
    end
    
    --- interact with other ants and objects
    obj.interactions()
  end
  
  function obj.draw()            
    love.graphics.setColor(255,255,0,255);
    love.graphics.circle( "line", obj.position.x, obj.position.y, obj.radius);
    --debug direction line
    love.graphics.line(obj.position.x, obj.position.y, obj.position.x + obj.direction.x*10, obj.position.y + obj.direction.y*10 ) 
  end
  
  return obj
end

return TAnt