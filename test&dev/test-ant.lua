--- Playing with Ant class
print "TESTING: ant.lua"

api = require('code.api')
TAnt = require('code.ant')

local myAnt

--- We init the application defining the load event
function api.onLoad()
  myAnt = TAnt.create()
  myAnt.init()
  local myClass = myAnt.getClassType()
  print ('Class: '..myClass.className)
  print ('Class parent: '..myClass.classParent.className)    
  myAnt.position.x = 500
  myAnt.position.y = 300  
end  

function api.onUpdate()
  myAnt.update()
end

function api.onDraw()
  --print 'drawing circle'
  myAnt.draw()
  --LOVE CODE  
end

api.start()