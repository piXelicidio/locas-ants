--- Our main game stuff, 
-- try to keep it simple... oh well..

g_isTesting = false
print(_VERSION)

-- We are going to play with isolated tests or runing the game?
-- (why this? execution only start with main.lua)
if not g_isTesting then
  
  --aliases and modules
  local apiG = love.graphics
  local api = love
  local sim=require('code.simulation')
  local cam=require('code.camview')
  local cfg=require('code.simconfig')
  local suit=require('libs.suit')
  
  --ui 
  local ui = {}
  ui.cnormal = suit.theme.color.normal
  ui.selectedColor =  { bg={55, 113, 140}, fg={255,255,255} } 
  ui.cc = ui.cnormal
  
  
  function ui.onRadioCellsChanged( NewIdx )
    print ( ui.radioBtns_cells.selectedCaption )
  end

  ui.radioBtns_cells = {
    {caption = 'block'},
    {caption = 'grass'},
    {caption = 'cave'},
    {caption = 'food'},
    {caption = 'ground'},
    selectedIdx = 1,
    selectedCaption = 'block',
    onChanged = ui.onRadioCellsChanged
  }
    
  
  function ui.suitRadio( rbtns, x, y, w,h )
    local grow
    x = x or 10
    y = y or 10
    w = w or 100
    h = h or 30
    suit.layout:reset(x, y) 
    suit.layout:padding(10,2)     
    for i=1,#rbtns do 
      if rbtns.selectedIdx  then
        if rbtns.selectedIdx == i then
          ui.cc = ui.selectedColor
          grow = 10
        else
          ui.cc = ui.cnormal
          grow = 0
        end
      end
      rbtns[i].ret = suit.Button(rbtns[i].caption, { color = { normal = ui.cc }} , suit.layout:row(w+grow,h) )  
      if rbtns[i].ret.hit then          
        rbtns.selectedIdx = i
        if rbtns.onChanged then
          rbtns.selectedCaption = rbtns[i].caption
          rbtns.onChanged(i)
        end
      end
    end 
end

  --- We init the application defining the load event
  function api.load()
    TIME_start = os.clock()
    print('Initializing...')
    --if arg[#arg] == "-debug" then require("mobdebug").start() end    
    sim.init()  
    cam.translation.x = 500
    cam.translation.y = 300
    cam.scale.x = 1
    cam.scale.y = 1
    apiG.setBackgroundColor(cfg.colorBk)
    apiG.setDefaultFilter("nearest", "nearest")
    apiG.setLineStyle( 'rough' )
  end    
  
    
  function api.update()
    ui.suitRadio(ui.radioBtns_cells, -5, 50, 80,30)
    sim.update()      
  end  
  
  function api.draw()        
    --gameworld  
    if cfg.simFrameNumber == 1 then print( (os.clock() - TIME_start)..'secs' ) end
        
    apiG.push()
    apiG.translate( cam.translation.x, cam.translation.y )        
    apiG.scale( cam.scale.x, cam.scale.y )    
    sim.draw()
    --ui stuff
    apiG.pop()
    
    --ui
    suit.draw()
    
    apiG.print("FPS: "..tostring(love.timer.getFPS( ))..' F# '..cfg.simFrameNumber, 10, 10)     
    --apiG.print("DebugCounter 1 = "..cfg.debugCounters[1], 10, 25)
    --apiG.print("DebugCounter 2 = "..cfg.debugCounters[2], 10, 40)
  end
  
  function api.keypressed(key)
    if key=='1' then
        
    elseif key=='2' then    
        cfg.antComEveryFrame  = not cfg.antComEveryFrame 
        print('cfg.antComEveryFrame = ',cfg.antComEveryFrame)
    elseif key=='3' then
        cfg.debugGrid = not cfg.debugGrid
        print('cfg.debugGrid =',cfg.debugGrid)
    elseif key=='4' then
        cfg.antComAlgorithm = cfg.antComAlgorithm + 1
        if cfg.antComAlgorithm > 1 then cfg.antComAlgorithm = 0 end     
        print('cfg.antComAlgorithm = ', cfg.antComAlgorithm )
    elseif key=='5' then
        cfg.debugPheromones = not cfg.debugPheromones
        print('cfg.debugPheromones =',cfg.debugPheromones)
    elseif key=='m' then
         print('Memory: '..math.floor( collectgarbage ('count'))..'kb')
    elseif key=='escape' then
        api.event.quit()
    elseif key=='6' then
        cfg.antObjectAvoidance = not cfg.antObjectAvoidance 
        print('cfg.antObjectAvoidance = ', cfg.antObjectAvoidance )
    elseif key=='0'then
        cfg.debugHideAnts = not cfg.debugHideAnts
        print('cfg.debugHideAnts = ', cfg.debugHideAnts )
    end
    
  end
  
  function api.mousemoved(x, y, dx, dy, istouch)
    if api.mouse.isDown(1) then 
      if ui.radioBtns_cells.selectedCaption ~= 'cave' then
        sim.setCell(ui.radioBtns_cells.selectedCaption, cam.screenToWorld(x, y) ) 
      end
    elseif api.mouse.isDown(3) then
      print(dx,dy)
      cam.translation.x = cam.translation.x + dx
      cam.translation.y = cam.translation.y + dy
    end
  end
  
  function api.mousepressed(x, y, button,  istouch)
    if button == 1 then 
      sim.setCell(ui.radioBtns_cells.selectedCaption, cam.screenToWorld(x, y) )
    end
  end
  
  function api.wheelmoved( x, y)    
    local inc
    if y>0 then inc = 0.5 end
    if y<0 then inc = -0.5 end
    cam.scale.x = cam.scale.x + inc
    cam.scale.y = cam.scale.y +  inc
    if cam.scale.x <1 then
      cam.scale.x = 1
      cam.scale.y = 1
    elseif cam.scale.x > cfg.zoomMaxScale then
      cam.scale.x = cfg.zoomMaxScale
      cam.scale.y = cfg.zoomMaxScale
    end    
  end


  

else
-- This is not the game, we are testing stuff
  dofile('test&dev/_testing.lua')
end
