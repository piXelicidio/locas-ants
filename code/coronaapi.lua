--- corona api
--(CORONA Lua)
local api = {}

api.name ='corona'

--- Try to exiting application.
function api.exitGame() 
  native.requestExit()
end

-- in case apis need to init something after being loaded and game starts, this will be called from main.lua 
function api.started()
  -- api.onLoad should be there, good time to call it
  if api.onLoad~=nil) then api.onLoad() end
end

return api