--- TLinkedList; double linked 
local TLinkedList = {}

function TLinkedList.create()  
  --the first node will be always the head, even when empty
  local head = 
           {  refList = nil, 
              prevNode = nil, 
              nextNode = nil, 
              obj = nil }
            
  local qList = {
      ---Public properties (for quick access) that you should "THINK" are read-only, so... behave.
      last = head,       -- last node
      count = 0         -- keeps the item count updated
    }
  -- private fields
  local fIter = head

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

  --- Adds a node to the end of the list
  function qList.add( node )
    node.refList = qList
    node.nextNode = nil
    qList.last.nextNode = node
    node.prevNode = qList.last
    qList.last = node
    qList.count = qList.count + 1
  end

  --- remove node 
  function qList.remove( node )
    node.prevNode.nextNode = node.nextNode    
    qList.count = qList.count - 1
  end

  --- pass each element to doFunc,   
  function qList.forEachObj( doFunc )
    local anode = head
    while anode.nextNode do
      anode = anode.nextNode
      doFunc(anode.obj)      
    end;
  end
  
  --- pass each element to doFunc acting on Nodes version, 
  function qList.forEachNode( doFunc )
    local anode = head
    while anode.nextNode do
      anode = anode.nextNode
      doFunc(anode)      
    end;
  end

  --- empty the list
  function qList.clear()
    head.nextNode = nil
    qList.last = head
    qList.count = 0
  end

  --- Set iterator to index = 0
  function qList.iterReset()
    fIter = head
  end

  --- Return next item, move to next.
  -- if reach end return nil 
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
 