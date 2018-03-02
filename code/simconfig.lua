---"Constants", defaults, globals
simconfig = {
  
  numAnts = 450,
  antMaxSpeed = 1.2,
  antComRadius = 100,             -- Ants communications radious,
  antSightDistance  = 60,       -- Only bellow this distance the ant can identify and locate things, bettr if > than antComRadius
  antPositionMemorySize = 20,    -- How many past position they can remember (should be > than antComRadius )
  
  mapMinX = -350,
  mapMinY = -250,
  mapMaxX = 450,
  mapMaxY = 350,
  
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