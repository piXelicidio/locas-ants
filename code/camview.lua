local cfg = require('code.simconfig')

local cam = {}

cam.translation = {x=0, y=0}
cam.scale ={x = 1, y = 1}

function cam.screenToWorld(x, y)
  return 
    ( (x - cam.translation.x ) /cam.scale.x), 
    ( (y - cam.translation.y ) /cam.scale.y)
end

function cam.screenToGrid(x, y)
    return 
    math.floor( ( (x - cam.translation.x ) /cam.scale.x ) / cfg.mapGridSize ), 
    math.floor( ( (y - cam.translation.y ) /cam.scale.y ) / cfg.mapGridSize )
end

return cam