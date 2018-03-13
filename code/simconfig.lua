---"Constants", defaults, globals........
-- "time" units are defined as frames

local simconfig = {
  
  numAnts = 1550,
  antMaxSpeed = 1.2,
  antComAlgorithm = 1,           -- 0 = Comm disabled; 1 = Pheromones inspiration
  antComRadius = 40,             -- Ants communications radious, ignored on algorithm >1  ... gridSize*3/2 is the equivalent
  antComEveryFrame = false,      -- comunicate every frame? or use values of antComNeedFrameStep below  
  antComNeedFrameStep = {3,13},  -- {a,b} ant would need for comunication with other ants every amount of frames form a to b. Greater values more speed less path quality.
  antComMaxBetterPaths = 3,     -- During communicaitons, in a single frame  each ant gets many better advices of new direction, how many are enough?  (ignored by Algorithm #4)  
  antComTimeToAcceptImLost = 500, -- if in N frames I don't find a fresh direction suggestion then I'll conform with older less quality info
  antComOlderInfoIfLost = 300,   -- How older info I'll accept if I'm lost!? 
  antSightDistance  = 30,        -- Only bellow this distance the ant can identify and locate|avoid things, bettr if > than antComRadius
  antPositionMemorySize = 15,    -- How many past position they can remember 
  antErratic = 0.2,  
  antInterests = {'food','cave'},
  antObjectAvoidance = true,
  
  debugGrid = false,
  debugPheromones = false,
  debugCounters = {0,0,0,0,0,0},
  
  -- our map dimensions, it can grow on any direction not only on positive integers 
  mapMinX = -350,
  mapMinY = -250,
  mapMaxX = 550,
  mapMaxY = 350,
  mapGridSize = 20,
  mapGridComScan = {      
    --this are the neibor cells we are going to scan looking for near ants to do communications... normal is 8 'N'eibor cells in square formation around 'C'enter cell.
    -- mapGridComScan[2..9]=neibors 
    -- mapgridComScan[1]=center
    --  N N N
    --  N 9 N
    --  N N N
      { 0, 0},
      {-1,-1},
      { 0,-1},
      { 1,-1},
      {-1, 0},
      { 1, 0},
      {-1, 1},
      { 0, 1},
      { 1, 1},      
    },
  
  colorAnts = {20,10,0},
  colorObstacle = {200,200,200},
  colorFood = {240, 240, 230},
  colorCave = {40,40,40},
  colorBk = {180,180,180},  
  colorBkLimits = {120, 120, 120},  
  
  -- << simFrameNumber is a "global" frame number counter, used to measure Time in the game >>>
  simFrameNumber = 0,  
  
  foo = 0
}



return simconfig