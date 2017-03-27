--- corona api
--(CORONA Lua)
local api = {}

api.name ='corona'

function api.exitGame() 
  native.requestExit()
end

return api