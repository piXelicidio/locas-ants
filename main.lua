--- Locas Ants main module

-- Dirty trick to detect if Corona SDK or Love ;)
if display~=nil then
  -- maybe is corona sdk
  if display.newImage~=nil then
    -- pretty sure it is
    print "Running: Corona SDK"
  end
elseif love~=nil then
  -- maybe is löve
  if love.graphics~=nil then
    -- pretty sure it is löve
    print 'Running: Löve'
  end
end
