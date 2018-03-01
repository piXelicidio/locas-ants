--- TSurface class, 
-- TSurface represent world objects, that can be rocks for obstacles, or water and food as resources
-- (PURE Lua)

local TActor = require('code.actor')
local vec = require('libs.vec2d_arr')
local cfg = require('code.simconfig') 


-- Sorry of the Delphi-like class styles :P
local TSurface = {}

--- Creating a new instance for TSurface class
function TSurface.create()
  local obj = TActor.create()
  --public fields
  obj.radius = 20  
  obj.name = "obstacle"
  obj.passable = false              -- you shall not pass 
  obj.friction = 1                  -- this is actually a multiplier of speed; 1 = no friction. 0.5 = high friction
  obj.storing = false              -- false store only equal, true store mutiple like caves   
  obj.storage = {}                 -- resource stores, keyName=number pairs.
  obj.resourceCount = 0            -- amount of resources units integer
  obj.surfaceRatioMultiplier = 0  -- how much the visual ratio represent the surface content, 0 = constant radius size
  obj.color = cfg.colorObstacle
  
  --private instance fields  
  local fCircle
  -- private funcitons
  -- public functions
    --PUBLIC functions
  obj.classType = TSurface
  obj.classParent = TActor
    
  function obj.init()
    
  end
  function obj.update()  
    --TODO: Why this line bellow???????
    if obj.surfaceRatioMultiplier ~= 0 then obj.radius = obj.surfaceCount * obj.surfaceRatioMultiplier end
  end
  function obj.draw() 
    love.graphics.setColor(obj.color)
    love.graphics.circle("fill", obj.position[1], obj.position[2], obj.radius)
  end
  
  return obj
end

function TSurface.createObstacle(x,y, size)
  local sur = TSurface.create()
  sur.position = {x, y}
  sur.radius = size
  return sur
end

function TSurface.createFood(x,y, size)
  local sur = TSurface.create()
  sur.position = {x, y}
  sur.radius = size
  sur.name = "food"
  sur.passable = true
  sur.friction = 0.9
  sur.color = cfg.colorFood
  return sur
end

function TSurface.createCave(x,y, size)
  local sur = TSurface.create()
  sur.position = {x,y}
  sur.radius = size
  sur.name = 'cave'
  sur.passable = true
  sur.friction = 1
  sur.color = cfg.colorCave
  return sur
end


return TSurface