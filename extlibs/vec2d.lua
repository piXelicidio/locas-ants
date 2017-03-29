--- 2D vector library
-- Intended to work with any table that contains x,y component.
-- Be efficient, simple and fast, accept tables as parameters, avoid unnecessary validations.
-- Assumptions on this Doc:
-- -Every time "vector" refer to any table with {x,y} components. A 2D vector.
--@module vec2d.lua
--@author Denys Almaral (denysalmaral.com) 
--@license MIT
--@usage vec = require('vec2d')
--@usage v={x=10,y=15}
-- vec.add(v, vec.makeFromAngle(math.pi/6))
-- vec.normalize(v)
-- vec.rotate(v, math.pi/4)

--- Module return a table with all functions
local vec = {}

---Returns a new vector by copy 
-- @param v Vector 
-- @return a new vector cloned
function vec.makeFrom(v)
  return {x=v.x, y=v.y}
end

---Sets x,y values to vDest vector
function vec.set(vDest, x, y)
  vDest.x = x
  vDest.y = y
end

--- Copy vector v to vDest
function vec.setFrom(vDest, v)
  vDest.x = v.x
  vDest.y = v.y
end

---Adds v to vDest, result in vDest
function vec.add(vDest, v)
  vDest.x = vDest.x + v.x
  vDest.y = vDest.y + v.y
end

---Sums v1+v2, result in vDest
function vec.sum(vDest, v1, v2)
  vDest.x = v1.x + v2.x
  vDest.y = v1.y + v2.y
end

--- Sum v1+v2, return a new vector with the sum
function vec.makeSum(v1, v2)
  return {x = v1.x + v2.x, 
          y = v1.y + v2.y }
end

--- Substract V from vDest, result in vDest
function vec.sub(vDest, v) 
  vDest.x = vDest.x - v.x
  vDest.y = vDest.y - v.y
end  

--- Returns new vector = (v1-v2) 
function vec.makeSub(v1, v2)
  return { x = v1.x -v2.y, 
           y = v1.y -v2.y 
         }
end  

--- Scale vDest multiplying by num number
function vec.scale(vDest, num)
  vDest.x = vDest.x * num
  vDest.y = vDest.y * num
end

--- Returns a new vector from V*m; where V is vector and m is a number
function vec.makeScale(v, num)
  return { x = v.x * num,
           y = v.y * num }
end

---Returns only Z float value from vector cross product v1 X v2
function vec.crossProd(v1, v2)
  return (v1.x* v2.y- v1.y* v2.x)
end

---returns number vectors dot product v1 * v2
function vec.dotProd(v1, v2)  
  return (v1.x* v2.x+ v1.y* v2.y)
end

---Multiply vDist by v, result in vDist
function vec.multiply(vDest, v)
  vDest.x = vDest.x * v.x
  vDest.y = vDest.y * v.y
end

---Returns new vector multiplied v1*v2
function vec.makeMultiply(v1, v2) 
  return {v1.x*v2.x, v1.y*v2.y}
end

---Returns vector length float
function vec.length(v)
  return math.sqrt(v.x*v.x + v.y*v.y) 
end

---Returns sqr( vec.length(v) ) float
function vec.sqLength(v)
  return (v.x*v.x + v.y*v.y) 
end

---Normalizing vDest vector
function vec.normalize(vDest)
  local tmp = 1 / vec.length(vDest)
  vDest.x = vDest.x * tmp
  vDest.y = vDest.y * tmp
end

---Returns new normalized vector from V
function vec.makeNormalized(v)
  local tmp = 1 / vec.length(v)
  return {
            v.x * tmp,
            v.y * tmp  
          }
end

---Rotate vDist vector, given float angle in radiants
function vec.rotate(vDest, angle)
    vDest.x = vDest.x * math.cos(angle) - vDest.y * math.sin(angle);
    vDest.y = vDest.x * math.sin(angle) + vDest.y * math.cos(angle);    
end

---Returns new vector from V rotated by float angle
function vec.makeRotated(v, angle)
    return {
      x = v.x * math.cos(angle) - v.y * math.sin(angle),
      y = v.x * math.sin(angle) + v.y * math.cos(angle)    
    }
end

---Returns a normalized vector with float angle in radians
function vec.makeFromAngle( angle )
  return {
    x = math.cos(angle),
    y = math.sin(angle)
  }  
end

return vec
