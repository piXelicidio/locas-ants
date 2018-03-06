--- Runing isolated tests from here.
-- Maybe this is "Unit Testing", I'm not sure, 
-- I just like to test some small things separated
-- and make specialized benchmarks for optimizing code.

local test = 3

    if test == 1 then dofile('test&dev/test-ant.lua') 
elseif test == 2 then dofile('test&dev/test-qlist_class.lua') 
elseif test == 3 then dofile('test&dev/benchmark_qlists.lua')
elseif test == 4 then dofile('test&dev/test-linkedlist_class.lua')
elseif test == 5 then dofile('test&dev/benchmark_linkedlists.lua')
elseif test == 6 then dofile('test&dev/benchmark_vectors.lua')
end
