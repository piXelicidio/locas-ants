--- TQuickList; quick adding and removing collection. 
local TQuickList = {}

function TQuickList.create()  
  local qList = {
      ---Public properties (for quick access) that you should "THINK" are read-only, so... behave.
      array = {},      -- store the list items, avoid using qList.array[index], some items may be nil
      emptyItems = {}, -- store the index of the removed items on array
      count = 0        -- keeps the item count updated
    }
  -- private fields
  local fIter = nil

  --public funcitons
  
  --- Returns a new node, usable for any TQuickList, not tied to this instance.
  -- This actually can be created anywhere as long as the table has the required fields.
  -- Why this? Becasue we don't want to create a new node everytime we add an obj to the list,
  -- we can reuse the same node to jump from list to list (this will be very useful in the grid map later)
  -- @param refObj the data you want to store in the node
  function qList.newNode( refObj )
    local node = 
    {  refList = nil, 
       idx = 0, 
       obj = refObj 
    }    
    -- each node has the de capability to remove itself from the current list owner (refList)
    function node.selfRemove()      
      if node.refList ~= nil then
        node.refList.remove( node )          
      end
    end
    
    return node
  end

  --- Adds a node to the list
  -- reuse empty items in the array if present
  -- Warning: no validations, if you add the same node twice it gets duplicated
  function qList.add( node )
    local idx=0
    if #qList.emptyItems~=0 then
      -- reuse last removed position 
      idx = table.remove(qList.emptyItems)
      qList.array[idx] = node      
    else
      -- if no emptyItems (no arry[n]===nil ) to reuse then insert directly
      table.insert(qList.array, node )
      idx = #qList.array                --index is the last one     
    end
    node.idx = idx
    node.refList = qList
    qList.count = qList.count + 1
  end
  
  --- Creates a new node and adds it to the list, combines both .add and newNode, returns node
  function qList.addNew( refObj )
    local node = qList.newNode( refObj )
    qList.add( node )
    return node
  end

  --- remove node quickly just setting it to nil, and saving the idex for reuse
  -- no validations for optimization:
  -- but be careful is node.refList~=qList or node.idx==0 ploff!!
  function qList.remove( node )
    qList.array[node.idx] = nil
    node.refList = nil
    -- save array spot for reuse (not the node, the node is free to move to other list)
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
  
  --- pass each element to doFunc acting on Nodes version, 
  -- do it yourself with pairs(qList.array) to avoid this call
  -- do not use iparis or for loop with qList.array[i], 
  -- will not work well because of nil values present
  function qList.forEachNode( doFunc )
    for _,item in pairs(qList.array) do
      doFunc(item)
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
    fIter = nil
  end

  --- Return next item, move to next.
  -- if reach end return nil 
  function qList.iterNext()
    local idx, node = next( qList.array, fIter )
    if idx then fIter = idx end
    return node
  end
  
  --- TODO: repacks arrays removing nil items. 
  -- (Slowly) Optimize the array removing nil items, use wisely. 
  function qList.repack()
    -- goes to every idx=emtpyItems[i] 
    -- remove array[idx]
    -- update all the nodes after idx decreasing node.idx
    -- repeat
  end
  
  return qList
end

return TQuickList
 