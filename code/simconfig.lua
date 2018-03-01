---"Constants", defaults, globals
simconfig = {
  
  numAnts = 420,
  antMaxSpeed = 1.2,
  antComRadius = 50,            -- Ants communications radious
  antPositionMemorySize = 20,    -- How many past position they can remember
  
  mapMinX = -300,
  mapMinY = -200,
  mapMaxX = 400,
  mapMaxY = 300,
  
  colorAnts = {20,10,0},
  colorObstacle = {200,200,200},
  colorFood = {240, 240, 230},
  colorCave = {40,40,40},
  colorBk = {180,180,180},  
  colorBkLimits = {120, 120, 120},  
  
  simFrameNumber = 0,
  
  foo = 0
}



return simconfig