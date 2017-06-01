--- TAnt class, 
-- (PURE Lua)

local api = require('code.api')
local TActor = require('code.actor')
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
  local antObj = TActor.create()
  
  --private instance fields
  local fSomevar = 0
  local fVisualObj     
  local fDebugDir 
    
  --PUBLIC properties
  antObj.direction = { x = 1.0, y = 0.0 } --direction heading movement unitary vector
  antObj.speed = 1
  antObj.erratic = 0.1                --craziness
  antObj.antPause = {
      iterMin = 10,                   --Stop for puse every iterMin to iterMax iterations.
      iterMax = 20,
      timeMin = 5,                    --Stop time from timeMin to timeMax iterations.
      timeMax = 15,
      nextPause = -1                  --When is the next pause?
    }
  --PRIVATE functions
  --TODO: local function checkFor
  
  --PUBLIC functions
  function antObj.getClassType() return TAnt end
  function antObj.getClassParent() return TActor end
  
  function antObj.init()
    fVisualObj = api.newCircle(antObj.position.x, antObj.position.y, 4, {255,255,0,255})    
    fDebugDir = api.newLine( antObj.position.x, antObj.position.y, antObj.position.x + antObj.direction.x*10, antObj.position.y + antObj.direction.y*10, {0,255,255,255});
  end
  
  function antObj.update()          
    local velocity = vec.makeScale( antObj.direction, antObj.speed )
    vec.add( antObj.position, velocity )
    vec.setFrom( fVisualObj, antObj.position )    
    -- direction variation for next update
    vec.rotate( antObj.direction, antObj.erratic * math.random() -(antObj.erratic*0.5) )
    vec.rotate( antObj.direction, antObj.erratic * math.random() -(antObj.erratic*0.5) )
    vec.rotate( antObj.direction, antObj.erratic * math.random() -(antObj.erratic*0.5) )
    vec.rotate( antObj.direction, antObj.erratic * math.random() -(antObj.erratic*0.5) )
    --debug direction line
    fDebugDir.x1 = antObj.position.x
    fDebugDir.y1 = antObj.position.y
    fDebugDir.x2 = antObj.position.x + antObj.direction.x*50
    fDebugDir.y2 = antObj.position.y + antObj.direction.y*50
    
    --- checking for limits and bounce
    if antObj.position.x < map.minX then
      antObj.position.x = map.minX
      if antObj.direction.x < 0 then antObj.direction.x = antObj.direction.x *-1 end
    elseif antObj.position.x > map.maxX then
      antObj.position.x = map.maxX
      if antObj.direction.x > 0 then antObj.direction.x = antObj.direction.x *-1 end
    end
    
    if antObj.position.y < map.minY then
      antObj.position.y = map.minY
      if antObj.direction.y < 0 then antObj.direction.y = antObj.direction.y *-1 end
    elseif antObj.position.y > map.maxY then
      antObj.position.y = map.maxY  
      if antObj.direction.y > 0 then antObj.direction.y = antObj.direction.y *-1 end
    end
  
  end
  
  function antObj.draw()
    api.drawCircle(fVisualObj)
    api.drawLine(fDebugDir)
  end
  
  return antObj
end

return TAnt