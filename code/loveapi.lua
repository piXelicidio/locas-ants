--- love api 
--(LOVE Lua)

local api = {}

api.name = 'love'

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
  return {x=ax, y=ay, radius=aRadius }
end 

function api.drawCircle( circle )
  love.graphics.circle("line", circle.x, circle.y, circle.radius )  
end

-- in case apis need to init something after being loaded and game starts, this will be called from main.lua 
function api.started()
end

return api