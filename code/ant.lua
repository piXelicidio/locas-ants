--- TAnt class, 
-- (PURE Lua)

-- Sorry of the Delphi-like class style :P
TAnt = { className='TAnt', 
         classParent = nil )  }
     
-- PRIVATE fields
local fSomething
  
-- PRIVATE methods
local function doSomthing ()
  
end
  

--- Creating a new instance for TAnt class
function TAnt.crate()
  antObj = {}
  
  --PUBLIC properties
  antObj.someNumber = 0
  
  --PUBLIC functions
  function antObj.init()
  end
  function andObj.update()  
  end
  function andObj.draw()
  end
  
  return antObj
end

return TAnt