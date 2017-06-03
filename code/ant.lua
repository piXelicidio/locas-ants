--- TAnt class, 
-- (PURE Lua)

local api = require('code.api')
local TActor = require('code.actor')
local TSurface = require('code.surface')
local vec = require('extlibs.vec2d')
local map = require('code.map')


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
  local fVisualObj     
  local fDebugDir 
    
  --PUBLIC properties
  obj.direction = { x = 1.0, y = 0.0 } --direction heading movement unitary vector
  obj.speed = 1
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
    fVisualObj = api.newCircle(obj.position.x, obj.position.y, obj.radius, {255,255,0,255} )    
    fDebugDir = api.newLine( obj.position.x, obj.position.y, obj.position.x + obj.direction.x*10, obj.position.y + obj.direction.y*10, {0,255,255,255});
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
            obj.speed = 0.01
          end else obj.speed = 1
        end
      end
    end
  end
  
  function obj.update()          
    local velocity = vec.makeScale( obj.direction, obj.speed )
    vec.add( obj.position, velocity )
    vec.setFrom( fVisualObj, obj.position )    
    -- direction variation for next update
    vec.rotate( obj.direction, obj.erratic * math.random() -(obj.erratic*0.5) )
    
    --debug direction line
    fDebugDir.x1 = obj.position.x
    fDebugDir.y1 = obj.position.y
    fDebugDir.x2 = obj.position.x + obj.direction.x*10
    fDebugDir.y2 = obj.position.y + obj.direction.y*10
    
    --- checking for limits and bounce
    if obj.position.x < map.minX then
      obj.position.x = map.minX
      if obj.direction.x < 0 then obj.direction.x = obj.direction.x *-1 end
    elseif obj.position.x > map.maxX then
      obj.position.x = map.maxX
      if obj.direction.x > 0 then obj.direction.x = obj.direction.x *-1 end
    end
    
    if obj.position.y < map.minY then
      obj.position.y = map.minY
      if obj.direction.y < 0 then obj.direction.y = obj.direction.y *-1 end
    elseif obj.position.y > map.maxY then
      obj.position.y = map.maxY  
      if obj.direction.y > 0 then obj.direction.y = obj.direction.y *-1 end
    end
    
    --- interact with other ants and objects
    obj.interactions()
  end
  
  function obj.draw()
    api.drawCircle(fVisualObj)
    api.drawLine(fDebugDir)
  end
  
  return obj
end

return TAnt