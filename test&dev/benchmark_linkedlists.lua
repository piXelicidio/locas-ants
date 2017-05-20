local TLinkedList = require('code.llist')

local l1 = TLinkedList.create()
local l2 = TLinkedList.create()

local maxnodes = 10000

nodes={}
for i=1,maxnodes do
  nodes[i] = l1.newNode(i)
end

-- start adding 
--randomly to both lists.
local t1 = os.clock()
for _,node in ipairs(nodes) do
  if math.random()>0.5 then  
    l1.add(node)  
  else
    l2.add(node)
  end
end
print ( 'counts:', l1.count, l2.count )

local t2 = os.clock()
print('filling lists: '..(t2-t1)..'secs')

-- randomly removing and adding
t1 = os.clock()
local n
for i=1,10000000 do
    n = nodes[ math.random(maxnodes) ]
    --swapping from lists
    if n.refList==l1 then      
      l1.remove(n);
      l2.add(n);
    else
      l2.remove(n);
      l1.add(n)
    end    
end
t2 = os.clock()
print('randomly swapping: '..(t2-t1)..'secs')
print ( 'counts:', l1.count, l2.count )
--print ('EmptyItems=nil :', #l1.emptyItems, #l2.emptyItems  )

--
local sumIterations = 50000
--swap a bit to make it differnt, then iterate to sum with forEach
local sum=0
local count=0
t1 = os.clock()
for j=1,sumIterations do
  for i=1,100 do
      n = nodes[ math.random(maxnodes) ]
      --swapping from lists
      if n.refList==l1 then      
        l1.remove(n);
        l2.add(n);
      else
        l2.remove(n);
        l1.add(n)
      end    
  end
  function doSum( obj )
    sum = sum + obj
    count = count + 1
  end
  l1.forEachObj( doSum )
  l2.forEachObj( doSum )
end;
t2 = os.clock()
print ('Average: '..sum/count)
print ('calc time: '..(t2-t1)..'secs')

print (':')
print ('This time accessing nodes  directly')
--swap a bit to make it differnt, then iterate to sum directly with in pairs this time
sum=0
count=0
t1 = os.clock()
for j=1,sumIterations do
  for i=1,100 do
      n = nodes[ math.random(maxnodes) ]
      --swapping from lists
      if n.refList==l1 then      
        l1.remove(n);
        l2.add(n);
      else
        l2.remove(n);
        l1.add(n)
      end    
  end
  
  local anode = l1.head
  while anode.nextNode~=l1.tail do
    anode = anode.nextNode
    sum = sum + anode.obj
    count = count + 1
  end; 
  anode = l2.head
  while anode.nextNode~=l2.tail do
    anode = anode.nextNode
    sum = sum + anode.obj
    count = count + 1
  end;   
end;
t2 = os.clock()
print ('Average: '..sum/count)
print ('calc time: '..(t2-t1)..'secs')

