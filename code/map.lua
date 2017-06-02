--- The global map where objects and actors and ants reside 
--(PURE Lua)
local api=require('code.api')
local TQuickList = require('code.qlist')

local map = {}

-- Map limits
map.minX = -300
map.minY = -200
map.maxX = 300
map.maxY = 200

--
map.actors = TQuickList.create()

limitsColor = {255,0,0,255}

local limitsRect = {}

function map.init()
  limitsRect = api.newRectangle( map.minX, map.minY, map.maxX-map.minX, map.maxY-map.minY, limitsColor )
end

function map.udpate()
end

function map.draw()
  api.drawRectangle( limitsRect )
end

--- Currently return all actors, must be optimized later with map partition grid
function map.getNearActors(x,y)
     
end

return map