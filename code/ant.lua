--- TAnt class, 
-- (PURE Lua)

local api = require('code.api')
local TActor = require('code.actor')

-- Sorry of the Delphi-like class styles :P
local TAnt = { classParent = TActor, className='TAnt'}
     
-- PRIVATE class fields
local fSomething
  
-- PRIVATE class methods
local function doSomthing ()
  
end
  

--- Creating a new instance for TAnt class
function TAnt.crate()
  local antObj = TActor.create()
  
  --private instance fields
  local somevar = 0
  local visualObj 
  
  --PUBLIC properties
  antObj.direction = { x = 1, y = 0 } --direction heading movement unitary vector
  antObj.speed = 1
  
  --PUBLIC functions
  function actorObj.getClassType() return TAnt end
  
  function antObj.init()
    visualObj = api.newCircle(antObj.x, antObj.y, 4)    
  end
  
  function andObj.update()  
    visualObj.x = antObj.x
    visualObj.y = antObj.y
  end
  
  function andObj.draw()
    api.makeCircle(antObj.x, antObj.y, 4)
  end
  
  return antObj
end

return TActor