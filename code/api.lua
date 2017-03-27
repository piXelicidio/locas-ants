--- api interface ABSTRACT
-- (MIXED lua)
-- store functions implemented in CoronaApi, LoveApi and any others.
-- Looks dirty :P
-- There is no intention to make a full framework, just interfacing the needed apis
-- implementing each function when is needed.

-- Benefits: In order to port this game to any other SDK or engine that use Lua, you only need to implement a new api interface.

local api = {}

-- Dirty trick to detect if Corona SDK or Love ;)
if display~=nil then
  -- maybe is corona sdk
  if display.newImage~=nil then
    -- pretty sure it is
    print "Running: Corona SDK"
    api = require('code.coronaapi')     
  end
elseif love~=nil then
  -- maybe is löve
  if love.graphics~=nil then
    -- pretty sure it is löve
    print 'Running: Löve'
    api = require('code.loveapi')    
  end
end

-- Check the "abstract" functions and properties, if they aren't implemented is a fatal error
-- starting with a formality, the name:
if api.name=nil then print "ERROR: api.name not defined"
if api.exitGame=nil then print "ERROR: api.exitGame undefined"
 

return api