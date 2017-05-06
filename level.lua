-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.setDrawMode("hybrid")

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create( event )

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()


	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newRect( display.screenOriginX, display.screenOriginY, screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( 0 )

	local leftWall = display.newRect (display.screenOriginX, display.screenOriginY, 1, display.contentHeight);
	local rightWall = display.newRect (screenW, display.screenOriginY, 1, display.contentHeight);
	local ceiling = display.newRect (display.screenOriginX, display.screenOriginY, display.contentWidth, 1);
	leftWall:setFillColor(1)
	rightWall:setFillColor(1)
	ceiling:setFillColor(1)
	leftWall.anchorX = 0.0;
	leftWall.anchorY = 0.0;
	rightWall.anchorX = 1.0;
	rightWall.anchorY = 0.0;
	ceiling.anchorX = 0.0;
	ceiling.anchorY = 0.0;

	physics.addBody (leftWall, "static",  { bounce = 1.0} );
	physics.addBody (rightWall, "static", { bounce = 1.0} );
	physics.addBody (ceiling, "static",   { bounce = 1.0} );

	-- make a table to hold all of the breakable boxes
	rowGroupList = {}
	orbGroup = display.newGroup();

	function background:touch(e)
		if (e.phase == "began") then
			local orbs = orbGroup.numChildren
			local targetVelocity = 1000;
			local xDist = e.x - orbGroup[1].x
			local yDist = e.y - orbGroup[1].y
			local angle = math.atan(yDist/xDist)
			local xVel = math.cos(angle) * targetVelocity * (xDist / (math.abs(xDist)))
			local yVel = math.sin(angle) * targetVelocity * (xDist / (math.abs(xDist)))
			for i=1, orbs do
				timer.performWithDelay(500, sleep)
				local orb = orbGroup[i]
				orb:setLinearVelocity(xVel, yVel)
			end

			timer.performWithDelay(2000, sleep)
			local rows = table.getn(rowGroupList)
			for i=1, rows do
				local row = rowGroupList[i]
				row.y = row.y + display.contentHeight/10
			end
		end
	end

	function sleep()
	end


	background:addEventListener("touch", background);

	-- make a crate (off-screen), position it, and rotate slightly
	--local crate = display.newImageRect( "crate.png", 90, 90 )
	--crate.x, crate.y = 160, -100
	--crate.rotation = 15

	-- add physics to the crate
	--physics.addBody( crate, { density=1.0, friction=0.3, bounce=0.3 } )

	-- create a grass object and add physics (with custom shape)
	--local grass = display.newImageRect( "grass.png", screenW, 82 )
	--grass.anchorX = 0
	--grass.anchorY = 1
	--  draw the grass at the very bottom of the screen
	--grass.x, grass.y = display.screenOriginX, display.actualContentHeight + display.screenOriginY

	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	--local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	--physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	--sceneGroup:insert(boxGroup)
	--sceneGroup:insert( grass)
	--sceneGroup:insert( crate )
end

local function addBoxes(levelNum)

	local rowGroup = display.newGroup();
	for i=0,6 do
		if (math.random(0, 2) == 1) then
			local boxGroup = display.newGroup();
			local xCoord = (display.contentWidth/7)*i + 22
			local yCoord = display.contentHeight/10 - 20
			local box = display.newRect(xCoord, yCoord, 40, 40) --for some reason this is the top left corner
			box:setFillColor(1,1,0)
			box.strokeWidth = 3
			box:setStrokeColor(0)
			box.anchorX = 0.5
			box.anchorY = 0.5
			boxGroup:insert(box)
			local doubler = math.random(1, 3)
			local boxValue = levelNum * doubler
			local boxText = display.newText( {parent = boxGroup, text = tostring(boxValue), x = xCoord, y = yCoord, width = 25, height = 25, font = native.systemFont, align = "center"})
			boxText:setFillColor(0)
			rowGroup:insert(boxGroup)

			physics.addBody(box, "static", { bounce = 1 })
		end
	end
	table.insert(rowGroupList, rowGroup)

end

local function addOrbs(levelNum)
	local currentPos = display.contentWidth / 2
	for i=1,levelNum do
		local orb = display.newCircle(orbGroup, currentPos, display.contentHeight - 5, 10)
		orb:setFillColor(0,1,0)
		orbGroup:insert(orb)
		physics.addBody(orb, "dynamic", { friction = 0.0, bounce = 1.0, radius = 10 })
		orb.gravityScale = 0.0
	end
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		local levelNum = 1
		addBoxes(levelNum)
		addOrbs(levelNum)


		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end

end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view

	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
