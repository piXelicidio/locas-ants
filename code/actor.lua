--- TActor class, anything visible or positionable in the game world
-- and any game object inherits from TActor 
-- (PURE Lua)

TActor = { className='TAnt', 
           classParent = nil )  }
     
-- PRIVATE fields
local fVisualObj = {
  x=0, 
  y=0
}
  
-- PRIVATE methods
local function doSomthing ()
  
end
  

--- Creating a new instance for TActor class
function TActor.crate()
  actorObj = {}
  
  --PUBLIC properties
  actorObj.someNumber = 0
  
  --PUBLIC functions
  function actorObj.init() 
  end
  function actorObj.update()  
  end
  function actorObj.draw() 
  end
  
  return antObj
end

return TActor