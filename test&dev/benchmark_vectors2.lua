--vec2d_arr vs pascal TVec2d 
local vec = require('vec2d_arr')

for r =1,2 do
  

print('Vector calc benchmark:')
local t = love.timer.getTime( )
local N = 100 * 1000;
local av = {}
local iters = 0;

  for i=0,N-1 do  
    av[i] = {i/1000,N-i/1000};
  end

  for j=0,3000 do  
    for i=0,N-2 do    
      --av[i] := ( av[i] * 0.5 ) + ( av[i+1] * 0.5 );
      local v1 = vec.makeFrom(av[i]);
      local v2 = vec.makeFrom(av[i+1]);
      vec.scale(v1, 0.5);
      vec.scale(v2, 0.5);
      vec.add(v1, v2);
      vec.setFrom(av[i], v1);
      iters = iters + 1
    end
  end
  local ave = 0;
  for i=0,N-1 do  
    ave = ave + vec.length(av[i]) / N;
    iters = iters + 1
  end;
  local dt = love.timer.getTime( ) - t;
  print( 'time: ' .. tostring(dt) .. 'seconds.');
  print( 'Result: ' .. tostring( ave ) );         
  print( 'Iterations:'..iters )
  
  end;