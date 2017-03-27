--- simulation 
--(PURE Lua)

local sim = {}

function sim.init()
end

function sim.update()
end

function sim.draw()
end

---ABSTRACT (event) called when sim is ended. Implement this somewhere else.
function sim.end() 
end

return sim
