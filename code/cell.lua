local cfg = require('code.simconfig')
local apiG = love.graphics

local TCell = {}

TCell.cavesStorage = {}

local imgCave = {}
local imgFood = {}
local imgGrass = {}
local imgPortals = {}

local grass = {} --singleton class instance

--- cell base abstract classs
function TCell.newCell()
  local cell={} 
  --public properties
  cell.type = 'obstacle'
  cell.pass = false
  cell.color = cfg.colorObstacle 
  cell.posi = {0,0}     --world position
  
  function cell.affectAnt( ant )
    --subclasses should implement this
  end
  
  function cell.draw(x, y)
    apiG.draw(cell.img, x, y, 0, cfg.imgScale, cfg.imgScale)
  end
        
  return cell
end

function TCell.init()
  imgCave = apiG.newImage('images//cave.png')
  imgFood[3] = apiG.newImage('images//food04.png')
  imgFood[2] = apiG.newImage('images//food03.png')
  imgFood[1] = apiG.newImage('images//food02.png')
  imgFood[0] = apiG.newImage('images//food01.png')
  imgGrass = apiG.newImage('images//grass01.png') 
  
  imgPortals.blue = {
      apiG.newImage('images/portalBlue_00.png'),
      apiG.newImage('images/portalBlue_01.png'),
      apiG.newImage('images/portalBlue_02.png')
    }
  
  imgPortals.orange = {
      apiG.newImage('images/portalOrange_00.png'),
      apiG.newImage('images/portalOrange_01.png'),
      apiG.newImage('images/portalOrange_02.png')
    }
  
  
  -- singletons  
  grass = TCell.newCell()
  grass.type = 'grass'
  grass.pass = true
  grass.img = imgGrass  
  grass.friction = 0.8
  function grass.affectAnt( ant )
    ant.friction = grass.friction
  end  
end

--- child class food
function TCell.newFood()
  local food=TCell.newCell()
  --public proeprties
  food.type = 'food'
  food.pass = true
  food.color = cfg.colorFood  
  food.storage = 1000  
  food.infinite = true
  food.img = imgFood[3]
  
  --methods
  function food.affectAnt( ant )
    if ant.lookingFor == food.type then
      if (ant.cargo.count < ant.cargo.capacity ) and ( food.storage > 0 )  then
        local take = ant.cargo.capacity - ant.cargo.count
        if take >= food.storage then 
          ant.cargo.count = ant.cargo.count + food.storage
          food.storage = 0
        else
          ant.cargo.count = ant.cargo.count + take          
          if not food.infinite then food.storage = food.storage - take end
        end         
      end
      ant.maxTimeSeen = 0
      ant.taskFound(food)
    end
  end
    
  return food
end

--- child class cave - singleton?
function TCell.newCave()
  local cave=TCell.newCell()
  cave.type = 'cave'
  cave.pass = true
  cave.color = cfg.colorCave
  cave.img = imgCave
  --methods
  function cave.affectAnt( ant )
      if ant.lookingFor == cave.type then        
        ant.cargo.count = 0
        ant.maxTimeSeen = 0
        ant.taskFound(cave)
      end            
  end
  return cave
end

--- child class grass - singleton
function TCell.newGrass()
  return grass
end

--- Portals O.o
--
local lastPortal = nil
function TCell.newPortal()
  local portal = TCell.newCell() 
  portal.type = 'portal'
  portal.gridPos = {0,0} -- need to set this after creation by caller
  portal.needUpdate = true --need to update the animation
  -- every time we create a Portal it alternate colors, started with blue the first one,
  if lastPortal==nil then 
    portal.color = "blue"
    portal.img = imgPortals.blue[1]
    portal.imgs = imgPortals.blue
  elseif lastPortal.color == "blue" then 
    portal.color = "orange" 
    portal.img = imgPortals.orange[1]
    portal.imgs = imgPortals.orange
    -- when the current color is Orange, it will link with the last portal that was Blue.
    portal.link = lastPortal
    lastPortal.link = portal
  else 
    portal.color = "blue" 
    portal.img = imgPortals.blue[1]
    portal.imgs = imgPortals.blue
  end
  
  --handle ant
  function portal.affectAnt( ant )
    local teleport = false
    if ant.teleportedOnFrame then
      --check when
      if (cfg.simFrameNumber - ant.teleportedOnFrame) > 30 then
        --teleport
        teleport = true
      end
    else teleport = true end
    if teleport and portal.link then
      ant.position[1] = portal.link.posi[1] + cfg.mapGridSize / 2
      ant.position[2] = portal.link.posi[2] + cfg.mapGridSize / 2
      ant.resetPositionMemory( ant.position )
      ant.teleportedOnFrame = cfg.simFrameNumber
    end
  end
  
  function portal.draw(x, y)
    apiG.draw(portal.imgs[ (math.floor(cfg.simFrameNumber/4) % 3) + 1 ], x, y, 0, cfg.imgScale, cfg.imgScale)
    if portal.link then
      local mid = cfg.mapGridSize /2
      apiG.setColor(255*cfg.colorMul, 255*cfg.colorMul, 255*cfg.colorMul, 50*cfg.colorMul)
      apiG.line(portal.posi[1] + mid, portal.posi[2] + mid, portal.link.posi[1] + mid, portal.link.posi[2] + mid )
    end
  end
    
  lastPortal = portal
  return portal    
end


return TCell

