--- TSurface class, 
-- TSurface represent world objects, that can be rocks for obstacles, or water and food as resources
-- (PURE Lua)

local api = require('code.api')
local TActor = require('code.actor')
local vec = require('extlibs.vec2d')
local map = require('code.map')


-- Sorry of the Delphi-like class styles :P
local TSurface = {}

--- Creating a new instance for TSurface class
function TSurface.create()
  local obj = TActor.create()
  --public fields
  obj.radius = 20  
  obj.name = "obstacle"
  obj.obstacle = true              -- true, you shall not pass 
  obj.friction = 0
  obj.storing = false              -- false store only equal, true store mutiple like caves   
  obj.storage = {}                 -- resource stores, keyName=number pairs.
  obj.resourceCount = 0            -- amount of resources units integer
  obj.surfaceRatioMultiplier = 0  -- how much the visual ratio represent the surface content, 0 = constant radius size
  obj.color = {100,100,100,255}  
  
  --private instance fields  
  local fCircle
  -- private funcitons
  -- public functions
    --PUBLIC functions
  obj.classType = TSurface
  obj.classParent = TActor
    
  function obj.init()
    fCircle = api.newCircle(obj.position.x, obj.position.y, obj.radius, obj.color,"fill" )  
  end
  function obj.update()  
    if obj.surfaceRatioMultiplier ~= 0 then obj.radius = obj.surfaceCount * obj.surfaceRatioMultiplier end
  end
  function obj.draw() 
    api.drawCircle(fCircle)
  end
  
  return obj
end

function TSurface.createObstacle(x,y, size)
  local sur = TSurface.create()
  sur.position.x = x
  sur.position.y = y
  sur.radius = size
  return sur
end

return TSurface