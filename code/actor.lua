--- TActor class, anything visible or positionable in the game world
-- and any game object inherits from TActor 
-- (PURE Lua)

local TActor = {}
     
-- PRIVATE class fields
local fSomething = 0
  
-- PRIVATE class methods
local function doSomthing ()
  
end

-- PUBLIC class methods

--- Creating a new instance for TActor class
function TActor.create()
  local actorObj = {}
  --PRIVATE instance fields
  local fFooFoo = 0
  
  --PUBLIC properties
  actorObj.position = { x = 1, y = 1 }
  
  --PUBLIC functions
  function actorObj.getClassType() return TActor end
  function actorObj.getClassParent() return nil end
  
  function actorObj.init() 
  end
  function actorObj.update()  
  end
  function actorObj.draw() 
  end
  
  return actorObj
end

return TActor