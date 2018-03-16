local cfg = require('code.simconfig')
local apiG = love.graphics

local TCell = {}

TCell.cavesStorage = {}

local imgCave = {}
local imgFood = {}
local imgGrass = {}

local grass = {} --singleton class instance

--- cell base classs
function TCell.newCell()
  local cell={} 
  --public properties
  cell.type = 'obstacle'
  cell.pass = false
  cell.color = cfg.colorObstacle 
  cell.posi = {0,0}     --world position
        
  return cell
end

function TCell.init()
  imgCave = apiG.newImage('images//cave.png')
  imgFood[3] = apiG.newImage('images//food04.png')
  imgFood[2] = apiG.newImage('images//food03.png')
  imgFood[1] = apiG.newImage('images//food02.png')
  imgFood[0] = apiG.newImage('images//food01.png')
  imgGrass = apiG.newImage('images//grass01.png') 
  
  -- singletons  
  grass = TCell.newCell()
  grass.type = 'grass'
  grass.pass = true
  grass.img = imgGrass  
  grass.friction = 0.8
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
  function grass.affectAnt( ant )
    ant.friction = grass.friction
  end
  return grass
end


return TCell

