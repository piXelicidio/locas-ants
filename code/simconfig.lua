---"Constants", defaults, globals........
-- "time" units are defined as frames

local simconfig = {
  
  numAnts = 4600,
  numAntsMobile = 1000,
  antMaxSpeed = 1.2,
  antComAlgorithm = 1,           -- 0 = Nothing; 1 = Pheromones inspiration  
  antComEveryFrame = false,      -- comunicate every frame? or use values of antComNeedFrameStep below  
  antComNeedFrameStep = {3,13},  -- {a,b} ant would need for comunication with other ants every amount of frames form a to b. Greater values more speed less path quality.  
  antSightDistance  = 30,        -- Only bellow this distance the ant can identify and locate|avoid things, bettr if > than antComRadius
  antPositionMemorySize = 10,    -- How many past position they can remember 
  antErratic = 0.2,  
  antInterests = {'food','cave'},
  antObjectAvoidance = true,
  antObjectAvoidance_FOV = 3.14/6, -- Field of view, for avoiding collision, number is half of angle in radians
  
  debugGrid = false,
  debugPheromones = false,
  debugHideAnts = false,
  debugCounters = {0,0,0,0,0,0},
  
  -- our map dimensions, it can grow on any direction not only on positive integers 
  mapMinX = -350,
  mapMinY = -250,
  mapMaxX = 550,
  mapMaxY = 350,
  mapGridSize = 16,
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
  
  zoomMaxScale = 4,
  imgScale = 1/4,  
  idealContentHeight = 720,
  
  colorAnts = {255,255,255},
  colorObstacle = {200,200,200},
  colorFood = {250, 240, 100},
  colorCave = {40,40,40},
  colorBk = {0,0,0},  
  colorBkLimits = {120, 120, 120},  
  
  -- << simFrameNumber is a "global" frame number counter, used to measure Time in the game >>>
  simFrameNumber = 0,  
  
  foo = 0
}



return simconfig