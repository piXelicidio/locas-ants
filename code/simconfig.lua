---"Constants", defaults, globals
simconfig = {
  
  numAnts = 1300,
  antMaxSpeed = 1.2,
  antComRadius = 40,             -- Ants communications radious,
  antComEveryFrame = false,      -- comunicate every frame? or use values of antComNeedFrameStep below  
  antComNeedFrameStep = {5,15},  -- {a,b} ant would need for comunication with other ants every amount of frames form a to b. Greater values more speed less path quality.
  antComMaxBetterPaths = 3,      -- During communicaitons, in a single frame  each ant gets many better advices of new direction, how many are enough?  
  antSightDistance  = 40,        -- Only bellow this distance the ant can identify and locate things, bettr if > than antComRadius
  antPositionMemorySize = 15,    -- How many past position they can remember 
  antErratic = 0.1,  
  
  mapMinX = -350,
  mapMinY = -250,
  mapMaxX = 550,
  mapMaxY = 350,
  mapGridSize = 32,
  
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