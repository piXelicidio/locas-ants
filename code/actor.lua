--- TActor class, anything visible or positionable in the game world
-- and any game object inherits from TActor 
-- (PURE Lua)

local TActor = {}
local vec = require('extlibs.vec2d')
     
-- PRIVATE class fields
local fSomething = 0
  
-- PRIVATE class methods
local function doSomthing ()
  
end

-- PUBLIC class methods

--- Creating a new instance for TActor class
function TActor.create()
  local obj = {}
  --PRIVATE instance fields
  local fFooFoo = 0
  
  --PUBLIC properties
  obj.position = { x = 1, y = 1 }
  obj.radius = 1
  obj.nodesOnLists = {}   --Array, store nodes of TQuickLists where the actor may be referenced.  To make a clean destruction of the actor.
  
  --PUBLIC functions
  obj.classType = TActor
  obj.classParent = nil
  
  function obj.init() 
  end
  function obj.update()  
  end
  function obj.draw() 
  end
 
  function obj.collisionWith( actor )        
    local d = vec.distance( obj.position, actor.position)    
    
    return ( d < (obj.radius + actor.radius) )
  end
  
  return obj
end

return TActor