--- corona api
--(CORONA Lua)
local api = {}

api.name ='corona'

--- Try to exiting application.
function api.exitGame() 
  native.requestExit()
end

--- Creates a circle shape
function api.newCircle(ax,ay, aRadius)
  local circle = display.newCircle(ax,ay,aRadius)
  circle:setFillColor(0,0,0,0)
  circle.strokeWidth = 1
  circle:setStrokeColor(1,1,1) 
  return(circle)
end 

function api.drawCircle( data )
  -- no need to draw in corona
end

-- in case apis need to init something after being loaded and game starts, this will be called from main.lua 
function api.started()
  -- api.onLoad should be there, good time to call it
  if api.onLoad~=nil then api.onLoad() end
end

--- calling onUpdate
local function updateEvent( event )
  if api.onUpdate~=nil then api.onUpdate() end
end

Runtime:addEventListener("enterFrame", updateEvent )


return api