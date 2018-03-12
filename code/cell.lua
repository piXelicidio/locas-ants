local cfg = require('code.simconfig')

local TCell = {}

--- cell base classs
function TCell.newCell()
  local cell={} 
  --public properties
  cell.type = 'obstacle'
  cell.pass = false
  cell.color = cfg.colorObstacle 
  return cell
end

--- child class food
function TCell.newFood()
  local food=TCell.newCell()
  --public proeprties
  food.type = 'food'
  food.pass = true
  food.color = cfg.colorFood
  return food
end

--- child class cave
function TCell.newCave()
  local cave=TCell.newCell()
  cave.type = 'cave'
  cave.pass = true
  cave.color = cfg.colorCave
  return cave
end

return TCell

