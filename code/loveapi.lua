--- love api 
--(LOVE Lua)

-- Each api inherits some stuff from api.lua, by agregation, search on api.lua "COMMONS STUFF"

local api = {}

api.name = 'love'

local panX, panY = 0,0              -- Wolrd panning

function api.exitGame()
  love.event.quit() -- i think.
end

function love.load()
  if api.load~=nil then api.load() end
end;

function love.update(dt)
  --will be fixed framerate we don't need the delta time every frame
  if api.update~=nil then api.update() end
end

function love.draw()
  if api.draw~=nil then api.draw() end
end

--- Inits a circle, on love we just store the data on a table for later draw
function api.newCircle(ax,ay, aRadius )
  return {x=ax, y=ay, radius=aRadius}
end 

function api.drawCircle( circle )
  love.graphics.circle("line", circle.x + panX, circle.y + panY, circle.radius )  
end

--- in case apis need to init something after being loaded and game starts, this will be called from main.lua 
function api.started()
end

function api.setPanning(x,y)
  panX = x
  panY = y
end

function api.pan(deltaX, deltaY)
  panX = panX + deltaX
  panY = panY + deltaY
end

function api.getPanning()
  return {panX, panY}
end


return api