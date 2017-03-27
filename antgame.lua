--- our main game stuff
--(PURE Lua)
local api=require('code.api')
local game={}
local circleTest

--- We init the application defining the load event
function api.onLoad()
    circleTest = api.makeCircle(20,20,20)    
end  
  
function api.onUpdate(dt)
end

function api.onDraw()
  --print 'drawing circle'
  api.drawCircle(circleTest)  
end

function game.start()
  
end

return game