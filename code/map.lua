--- The global map where objects and actors and ants reside 
--(PURE Lua)
local api=require('code.api')

local map = {}

-- Map limits
map.minX = -300
map.minY = -200
map.maxX = 300
map.maxY = 200

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

return map