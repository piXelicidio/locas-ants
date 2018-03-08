--- TActor class, anything visible or positionable in the game world
-- and any game object inherits from TActor 
-- (PURE Lua)

local TActor = {}
local vec = require('libs.vec2d_arr')
     
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
  obj.position = {0, 0}
  obj.radius = 1
  obj.nodeRefs = {}   --keys=values, store nodes of TQuickLists where the actor may be referenced.  To make a clean "destruction" of the actor.
  obj.gridInfo = {posi = {0,0}}   --store stuff useful for Grid  
  
  --PUBLIC functions
  obj.classType = TActor
  obj.classParent = nil
  
  function obj.init()    --override this
  end
  function obj.update()  --override this :TODO:optional, 
  end
  function obj.draw()    --override this
  end

  
  return obj
end

return TActor