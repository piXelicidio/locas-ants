--- 2D vector library
-- Intended to work with array in the form {x,y} where arr[1]=x and arr[2]=y
-- Be efficient, simple and fast, avoid unnecessary validations.
-- Assumptions on this Doc:
-- -Every time "vector" refer to any array with {x,y} components. A 2D vector.
--@module vec2d_arr.lua
--@author Denys Almaral (denysalmaral.com) 
--@license MIT
--@usage vec = require('vec2d_arr')
--@usage v={x,y}
-- vec.add(v, vec.makeFromAngle(math.pi/6))
-- vec.normalize(v)
-- vec.rotate(v, math.pi/4)

--- Module return a table with all functions
local vec = {}

---Returns a new vector by copy 
-- @param v Vector 
-- @return a new vector cloned
function vec.makeFrom(v)
  return {v[1], v[2]}
end

---Sets x,y values to vDest vector
function vec.set(vDest, x, y)
  vDest[1] = x
  vDest[2] = y
end

--- Copy vector v to vDest
function vec.setFrom(vDest, v)
  vDest[1], vDest[2]= v[1], v[2]
end

---Adds v to vDest, result in vDest
function vec.add(vDest, v)
  vDest[1] = vDest[1] + v[1]
  vDest[2] = vDest[2] + v[2]
end

---Sums v1+v2, result in vDest
function vec.sum(vDest, v1, v2)
  vDest[1] = v1[1] + v2[1]
  vDest[2] = v1[2] + v2[2]
end

--- Sum v1+v2, return a new vector with the sum
function vec.makeSum(v1, v2)
  return {v1[1] + v2[1], 
          v1[2] + v2[2] }
end

--- Substract V from vDest, result in vDest
function vec.sub(vDest, v) 
  vDest[1] = vDest[1] - v[1]
  vDest[2] = vDest[2] - v[2]
end  

--- Returns new vector = (v1-v2) 
function vec.makeSub(v1, v2)
  return { v1[1] -v2[1], 
           v1[2] -v2[2] 
         }
end  

--- Scale vDest multiplying by num number
function vec.scale(vDest, num)
  vDest[1] = vDest[1] * num
  vDest[2] = vDest[2] * num
end

--- Returns a new vector from V*m; where V is vector and m is a number
function vec.makeScale(v, num)  
  return { v[1] * num,
           v[2] * num }
end

---Returns only Z float value from vector cross product v1 X v2
function vec.crossProd(v1, v2)
  return (v1[1]* v2[2]- v1[2]* v2[1])
end

---returns number vectors dot product v1 * v2
function vec.dotProd(v1, v2)  
  return (v1[1]* v2[1]+ v1[2]* v2[2])
end

---Multiply vDist by v, result in vDist
function vec.multiply(vDest, v)
  vDest[1] = vDest[1] * v[1]
  vDest[2] = vDest[2] * v[2]
end

---Returns new vector multiplied v1*v2
function vec.makeMultiply(v1, v2) 
  return {v1[1]*v2[1], v1[2]*v2[2]}
end

---Returns vector length float
function vec.length(v)
  return math.sqrt(v[1]*v[1] + v[2]*v[2]) 
end

--- Return the distance between two positions vectors
function vec.distance( v1, v2 )
  return vec.length({v2[1]-v1[1], v2[2]-v1[2]}) 
end

---Returns sqr( vec.length(v) ) float
function vec.sqLength(v)
  return (v[1]*v[1] + v[2]*v[2]) 
end

--- Returns the distance between to points in chess King steps  = Manhattan distance = Taxicab geometry
function vec.manhattanDistance(v1, v2)
  return math.abs(v2[1]-v1[1]) + math.abs(v2[2]-v1[2])
end
function vec.manhattanLength(v)
  return math.abs(v[1]+v[2])
end

---Normalizing vDest vector
function vec.normalize(vDest)
  local tmp = 1 / vec.length(vDest)
  vDest[1] = vDest[1] * tmp
  vDest[2] = vDest[2] * tmp
end

---Returns new normalized vector from V
function vec.makeNormalized(v)
  local tmp = 1 / vec.length(v)
  return {
            v[1] * tmp,
            v[2] * tmp  
          }
end

---Rotate vDist vector, given float angle in radiants
function vec.rotate(vDest, angle)
    local tempvDestx = vDest[1]
    vDest[1] = vDest[1] * math.cos(angle) - vDest[2] * math.sin(angle);
    vDest[2] = tempvDestx * math.sin(angle) + vDest[2] * math.cos(angle);    
end

---Returns new vector from V rotated by float angle
function vec.makeRotated(v, angle)
    return {
      v[1] * math.cos(angle) - v[2] * math.sin(angle),
      v[1] * math.sin(angle) + v[2] * math.cos(angle)    
    }
end

---Returns a normalized vector with float angle in radians
function vec.makeFromAngle( angle )
  return {
    math.cos(angle),
    math.sin(angle)
  }  
end

return vec
