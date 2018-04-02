---"Constants", defaults, globals........
-- "time" units are defined as frames
local api = love
local apiVer = api.getVersion()
print (apiVer)
local cmul
if apiVer >= 11 then cmul = 1/255 else cmul = 1 end

local simconfig = {
  
  apiVersion = apiVer,
  
  numAnts = 3600,
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
  
  colorMul = cmul,
  
  colorAnts = {255*cmul, 255*cmul, 255*cmul},
  colorObstacle = {200*cmul,200*cmul,200*cmul},
  colorFood = {250*cmul, 240*cmul, 100*cmul},
  colorCave = {40*cmul,40*cmul,40*cmul},
  colorBk = {0,0,0},  
  colorBkLimits = {120*cmul, 120*cmul, 120*cmul},  
  
  colorWhite = {255*cmul, 255*cmul, 255*cmul, 255*cmul},
  colorBlue  = {10*cmul, 100*cmul, 250*cmul, 255*cmul},
  colorGray = {130*cmul, 130*cmul, 130*cmul, 130*cmul},
  -- << simFrameNumber is a "global" frame number counter, used to measure Time in the game >>>
  simFrameNumber = 0,  
  
  foo = 0
}



return simconfig