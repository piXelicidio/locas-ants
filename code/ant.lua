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
  local fDirection = {x=1, y=0} --direction heading movement unitary vector  
  --PUBLIC properties
  
  antObj.speed = 1
  antObj.erratic = 0.1                --craziness
  
  --PUBLIC functions
  function antObj.getClassType() return TAnt end
    
  
  function antObj.init()
    fVisualObj = api.newCircle(antObj.x, antObj.y, 4)    
  end
  
  function antObj.update()  
    fDirection.x = math.cos(antObj.angle)
    fDirection.y = math.sin(angObj.angle)
    local velocity = vec.makeScale( fDirection, antObj.speed )
    vec.add( antObj.position, velocity )
    vec.setFrom( fVisualObj, antObj.position )    
    -- direction variation for next update
    antObj.angle = antObj.angle + ( antObj.erratic * math.random() - (antObj.erratic*0.5) )
  end
  
  function antObj.draw()
    api.drawCircle(fVisualObj)
  end
  
  return antObj
end

return TAnt