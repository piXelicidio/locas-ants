local cfg = require('code.simconfig')
local apiG = love.graphics

local TCell = {}

TCell.cavesStorage = {}

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

--- child class food
function TCell.newFood()
  local food=TCell.newCell()
  --public proeprties
  food.type = 'food'
  food.pass = true
  food.color = cfg.colorFood  
  food.storage = 1000  
  food.infinite = true
  
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

--- child class cave
function TCell.newCave()
  local cave=TCell.newCell()
  cave.type = 'cave'
  cave.pass = true
  cave.color = cfg.colorCave
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

return TCell

