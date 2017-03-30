--- TLinkedList; double linked 
local TLinkedList = {}

function TLinkedList.create()  
  --the head and tail will be always present and don't store data obj
  local head = 
           {  refList = nil, 
              prevNode = nil, 
              nextNode = nil, 
              obj = nil }
            
  local tail = 
           {  refList = nil, 
              prevNode = nil, 
              nextNode = nil, 
              obj = nil }
            
  local qList = {
      ---Public properties (for quick access) that you should "THINK" are read-only, so... behave.      
      count = 0         -- keeps the item count updated
    }
   
   head.refList = qList
   head.nextNode = tail
   tail.refList = qList
   tail.prevNode = head
    
  -- private fields
  local fIter = head
  
  -- public properties
  qList.head = head   -- access with care
  qList.tail = tail 

  --public funcitons
  
  --- Returns a new node, usable for any TLinkedList, not tied to this instance.
  -- This actually can be created anywhere as long as the table has the required fields.
  -- Why this? Becasue we don't want to create a new node everytime we add an obj to the list,
  -- we can reuse the same node to jump from list to list (this will be very useful in the grid map later)
  -- @param refObj the data you want to store in the node
  function qList.newNode( refObj )
    return {  refList = nil, 
              prevNode = nil, 
              nextNode = nil, 
              obj = refObj }
  end

  --- Adds (or inserts) a node to the end of the list, before the Tail
  function qList.add( node )
    node.refList = qList
    node.nextNode = tail
    tail.prevNode.nextNode = node
    node.prevNode = tail.prevNode
    tail.prevNode = node
    qList.count = qList.count + 1
  end

  --- remove node 
  function qList.remove( node )    
    node.prevNode.nextNode = node.nextNode                            -- previous node points my next node
    node.nextNode.prevNode = node.prevNode                            -- my next node points back to my previus node
    qList.count = qList.count - 1
  end

  --- pass each element to doFunc,   
  function qList.forEachObj( doFunc )
    local anode = head
    while anode.nextNode~=tail do
      anode = anode.nextNode
      doFunc(anode.obj)            
    end;    
  end
  
  --- pass each element to doFunc acting on Nodes version, 
  function qList.forEachNode( doFunc )
    local anode = head
    while anode.nextNode~=tail do
      anode = anode.nextNode
      doFunc(anode)      
    end;
  end

  --- empty the list
  function qList.clear()
    head.nextNode = tail
    tail.prevNode = head
    qList.count = 0
  end

  --- Set iterator to index = 0
  function qList.iterReset()
    fIter = head
  end

  --- Return next item, move to next.
  -- if reach end return tail
  -- if you keep asking next without reset after nil, then poof! (avoiding validation here)
  function qList.iterNext()
    fIter = fIter.nextNode
    return fIter
  end
  
  function qList.repack()
    --no need
  end
  
  return qList
end

return TLinkedList
 