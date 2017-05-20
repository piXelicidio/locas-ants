--- quick list experiment
-- I need a list with fast add and remove,
-- that allows items remove itself.
-- order not important

qList = {
    ---Public properties (for quick access) that you should "THINK" are read-only, so behave.
    array = {},      -- store the list items
    emptyItems = {}, -- store the index of the removed items on array
    count = 0        -- keeps the item count updated
  }
print "qList test"
print (_VERSION)
local fIter = 0

function qList.newListableNode( refObj )
  return {  refList = nil, 
            idx = 0, 
            obj = refObj }
end

--- Adds a node to the list
--  reuse empty items in the array if present
function qList.add( node )
  local idx=0
  if #qList.emptyItems~=0 then
    -- reuse last removed position 
    idx = table.remove(qList.emptyItems)
    qList.array[idx] = node
    node.idx = idx
    node.refList = qList
  else
    -- if no emptyItems (no arry[n]===nil ) to reuse then insert directly
    table.insert(qList.array, node )
    idx = #qList.array                --index is the last one     
  end
  node.idx = idx
  node.refList = qList
  qList.count = qList.count + 1
end

--- remove node quickly just setting it to nil, and saving the idex for reuse
-- no validations for optimization:
-- but be carful is node.refList~=qList or node.idx==0 ploff!!
function qList.remove( node )
  qList.array[node.idx] = nil
  -- save for reuse
  table.insert( qList.emptyItems, node.idx )
  qList.count = qList.count - 1
end

--- pass each element to doFunc, 
-- do it yourself with pairs(qList.array) to avoid this call
-- do not use iparis or for loop with qList.array[i], 
-- will not work well because of nil values present
function qList.forEachObj( doFunc )
  for _,item in pairs(qList.array) do
    doFunc(item.obj)
  end
end

--- empty the list
function qList.clear()
  --TODO
  qList.array = {}
  qList.emptyItems = {}
  qList.count = 0      
end

--- Set iterator to index = 0
function qList.iterReset()
  fIter = 0
end

--- Return next item, move to next.
-- if reach end return nil 
function qList.iterNext()
  local idx, node = next( qList.array, fIter )
  if idx then fIter = idx end
  return node
end
 
----------------
-- testing it
--adding
local n = qList.newListableNode("1juan")
qList.add( n )
local n2 = qList.newListableNode("2maria")
qList.add( n2 )
n = qList.newListableNode("3pedro")
qList.add( n )

-- print listing 
qList.forEachObj( print )

-- remove
qList.remove(n2)
print ('removing: '..n2.obj)
-- print listing 
qList.forEachObj( print )

print ('adding 4jose')
n2.obj = '4jose'
qList.add(n2)
qList.forEachObj( print )

print('count = '..qList.count)
print(':')
print('Iterations')

-- iterating using next
qList.iterReset()
local nodex = qList.iterNext()
while nodex do
  print('iterating: '..nodex.obj)
  nodex = qList.iterNext()  
end

-- iterating with for
qList.iterReset()
for i=1,qList.count do
  nodex = qList.iterNext()
  print(i..')-'..nodex.obj)

end

