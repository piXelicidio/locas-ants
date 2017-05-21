--- Playing with Ant class
print "TESTING: ant.lua"

api = require('code.api')
TAnt = require('code.ant')
vec = require('extlibs.vec2d')

local myAnts = {}

--- We init the application defining the load event
function api.onLoad()
  for i=1,20 do
    myAnt = TAnt.create()
    myAnts[i] = myAnt
    myAnt.init()    
    myAnt.position.x = 500
    myAnt.position.y = 300 
    myAnt.direction = vec.makeFromAngle( math.random() * math.pi )
  end
end  

function api.onUpdate()
  for _,myAnt in ipairs(myAnts) do
    myAnt.update()
  end
  api.pan(1,0)
end

function api.onDraw()
  --print 'drawing circle'
  for _,myAnt in ipairs(myAnts) do
    myAnt.draw()
  end
  --LOVE CODE  
end

api.start()