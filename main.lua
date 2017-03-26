--- Locas Ants main module
local game

-- Dirty trick to detect if Corona SDK or Love ;)
if display~=nil then
  -- maybe is corona sdk
  if display.newImage~=nil then
    -- pretty sure it is
    print "Running: Corona SDK"
    game = require('code.coronagame') 
  end
elseif love~=nil then
  -- maybe is löve
  if love.graphics~=nil then
    -- pretty sure it is löve
    print 'Running: Löve'
    game = require('code.lovegame')
  end
end

game.init()
game.start()


