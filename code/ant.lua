--- TAnt class, 
-- (PURE Lua)

local api = require('code.api')
local TActor = require('code.actor')
local vec = require('extlibs.vec2d')

-- Sorry of the Delphi-like class styles :P
local TAnt = { classParent = TActor, className='TAnt'}
     
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
    
  --PUBLIC properties
  antObj.direction = { x = 1, y = 0 } --direction heading movement unitary vector
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
  
  function antObj.init()
    fVisualObj = api.newCircle(antObj.position.x, antObj.position.y, 4)    
  end
  
  function antObj.update()      
    
    local velocity = vec.makeScale( antObj.direction, antObj.speed )
    vec.add( antObj.position, velocity )
    vec.setFrom( fVisualObj, antObj.position )    
    -- direction variation for next update
    vec.rotate( antObj.direction, antObj.erratic * math.random() -(antObj.erratic*0.5) )
  end
  
  function antObj.draw()
    api.drawCircle(fVisualObj)
  end
  
  return antObj
end

return TAnt