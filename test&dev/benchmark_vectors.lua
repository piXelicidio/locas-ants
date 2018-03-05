vec = require("libs.vec2d")
vecarr = require("libs.vec2d_arr")

local v = {x = 1.2, y = 1.3 }
local v2

local t = os.clock()
local iterations = 10^9 

print ('-------------- calling vec2d.lua funcitons  --- ')
for i=0,iterations do
    v2 = vec.makeFrom(v)
    v.x = v.x + 0.01 
    v.y = v.y * 1.5 
    vec.add(v2, v)
    if v2.x > 0 then v2.x = v2.x * v2.x end
    if v2.y > 0 then v2.y = v2.y * v2.y * 0.05 end
    vec.scale(v, 2)
    vec.sub(v, v2)
end

local t2 = os.clock()

print("v.x = ", v.x )
print("v.y = ", v.y )
print("delay = "..(t2-t).."secs")



print ('-------------- doing direct calculations on table {x=..., y=...}  --- ')
v = {x = 1.2, y = 1.3 }
t = os.clock()

for i=0,iterations do
    v2 = {x = v.x, y = v.y}
    v.x = v.x + 0.01 
    v.y = v.y * 1.5 
    v2.x, v2.y = v2.x+v.x, v2.y+v.y 
    if v2.x > 0 then v2.x = v2.x * v2.x end
    if v2.y > 0 then v2.y = v2.y * v2.y * 0.05 end
    v.x, v.y = v.x * 2, v.y * 2
    v.x, v.y = v.x - v2.x, v.y - v2.y    
end

t2 = os.clock()

print("v.x = ", v.x )
print("v.y = ", v.y )
print("delay = "..(t2-t).."secs")



print ('-------------- with vector arrays module vec2d_arr  --- ')
v = {1.2, 1.3}
t = os.clock()

for i=0,iterations do
    v2 = vecarr.makeFrom(v)
    v[1] = v[1] + 0.01 
    v[2] = v[2] * 1.5 
    vecarr.add(v2, v)
    if v2[1] > 0 then v2[1] = v2[1] * v2[1] end
    if v2[2] > 0 then v2[2] = v2[2] * v2[2] * 0.05 end
    vecarr.scale(v, 2)
    vecarr.sub(v, v2)
end


t2 = os.clock()

print("v[1] = ", v[1] )
print("v[2] = ", v[2] )
print("delay = "..(t2-t).."secs")




print ('-------------- doing direct calculations on vector array {x, y}  --- ')
v = {1.2, 1.3}
t = os.clock()

for i=0,iterations do
    v2 = {v[1], v[2]}
    v[1] = v[1] + 0.01 
    v[2] = v[2] * 1.5 
    v2[1], v2[2] = v2[1]+v[1], v2[2]+v[2] 
    if v2[1] > 0 then v2[1] = v2[1] * v2[1] end
    if v2[1] > 0 then v2[2] = v2[2] * v2[2] * 0.05 end
    v[1], v[2] = v[1] * 2, v[2] * 2
    v[1], v[2] = v[1] - v2[1], v[2] - v2[2]    
end

t2 = os.clock()

print("v[1] = ", v[1] )
print("v[2] = ", v[2] )
print("delay = "..(t2-t).."secs")

