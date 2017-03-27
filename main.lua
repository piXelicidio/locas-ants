--- our main game stuff
--(PURE Lua)
local api=require('code.api')
local sim=require('code.simulation')

--- We init the application defining the load event
function api.onLoad()
  sim.init()
end  
  
function api.onUpdate(dt)
  sim.update()  
end

function api.onDraw()
  --print 'drawing circle'
  sim.draw()
end

api.start()

return game