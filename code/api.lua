--- api interface ABSTRACT
-- (MIXED lua)
-- store functions implemented in CoronaApi, LoveApi and any others.
-- Looks dirty :P
-- There is no intention to make a full framework, just interfacing the needed apis
-- implementing each function when is needed.

-- Benefits: 
-- In order to port this game to any other SDK or engine that use Lua, 
-- you only need to implement a new api (like current loveapi.lua) with the basics defined on this interface,
-- later you can continue exending it or just using direct calls to your sdk if you want.

-- Graphics: Assuming all visual objects need two functions: "new" for initialization 
-- and "draw" for drawing. This gerelalize better the way different SDKs works, like
-- corona SDK and Love2D. 


local api = {}

--private vars
local onlyOnce=true

-- Dirty trick to detect if Corona SDK or Love ;)
-- first time we require this module it will be inialized with the current detected SDK
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

--override this events on main.lua
api.onLoad = nil
api.onUpdate = nil
api.onDraw = nil

-- Events functions that SHOULD be called from each api SDK;

--- Called when application begins
function api.load()
  if api.onLoad~=nil then api.onLoad() end
end

--- Called each frame to update game data, dt is delta time between frames
function api.update()
  if api.onUpdate~=nil then api.onUpdate() end
end

--- Called each frame to draw the visuals
-- note: never called from corona SDK
function api.draw()
  if api.onDraw~=nil then api.onDraw() end
end

--- call this from main lua to inform apis things has started;
-- sdks like corona doesn't provide Load event like Löve so it need this to call api.load();

function api.start()
  if onlyOnce then 
    api.started()
    onlyOnce = false
  end
end

--COMMON STUFF

-- Check the "abstract" functions and properties, if they aren't implemented is a fatal error
-- Checking if all abstract functions are implemented:

-- Tries to exit the application
if api.exitGame==nil then print "ERROR: api.exitGame() undefined" end

-- String property with SDK  name
if api.name==nil then print "ERROR: api.name string not defined" end

-- Called from main.lua to tell your api, things has started, load time.
if api.started==nil then print 'ERROR: api.started() undefined' end

-- Creates a circle, should returns table with at least (x,y)
if api.newCircle==nil then print "ERROR: api.makeCircle(x,y,radius) undefined" end  

-- Draws the previous created circle.
if api.drawCircle==nil then print "ERROR: api.drawCircle(circle) undefined" end

-- Set the current pan, to update the view of the screen relative to x,y of the map
if api.setPanning==nil then print "ERROR: api.setPanning(x,y) undefined" end

-- Move the panning using deltaX and deltaY
if api.pan==nil then print "ERROR: api.pan(deltaX, deltaY) undefined" end

-- Get the current panning coords x,y as a table vector
if api.getPanning==nil then print "ERROR: api.getPanning() undefined" end


return api