-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.setDrawMode("normal")

levelNum = 0
rowGroup = display.newGroup() --all rows


--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create( event )

end

function onBoxCollision(self, event)
	if (event.phase == "began") then
		 local boxParent = self.parent
		 local numberText = boxParent[2]

		 local value = tonumber(numberText.text) - 1
		 print(value)
		 if self ~= nil then
			 if (value < 1) then
				 timer.performWithDelay(20, function()
					if self ~= nil then
						physics.removeBody(self)
						--self.parent[2]:removeSelf()
						--self.parent:removeSelf()
						--self:removeSelf()
						--display.remove(self.parent[2])
						display.remove(self.parent)
						display.remove(self)
						self = nil
					end
				end)
			 elseif (value >= 1) then
				 self.parent[2].text = tostring(value)
			 end
	 	 end
 	end
end

function onFloorCollision(self, event)
	if (event.phase == "began") then
		if (event.other.myName == "ballz") then
			timer.performWithDelay(20, function()
				if (numBallsLeft == 1) then
					event.other:removeSelf()
					startLevel()
				else
					event.other:removeSelf()
					numBallsLeft = numBallsLeft - 1
				end
			end)
		end
	end
end

local function addBoxes(levelNum)

	local done = true
	local row = display.newGroup();
	while done do -- living on the edge
		for i=0,6 do
			if (math.random(1, 3) == 1) then
				done = false
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
				local doubler = math.random(1, 2)
				local boxValue = levelNum * doubler
				local boxText = display.newText( {parent = boxGroup, text = tostring(boxValue), x = xCoord, y = yCoord, width = 25, height = 25, font = native.systemFont, align = "center"})
				boxText:setFillColor(0)
				physics.addBody(box, "static", { bounce = 1 })

				box.collision = onBoxCollision
				box:addEventListener("collision")

				row:insert(boxGroup)
			end
		end
	end
	rowGroup:insert(row)

end

local function addOrb(xVel, yVel)
	local currentPos = display.contentWidth / 2
	local orb = display.newCircle(currentPos, display.contentHeight - 5, 10)
	orb:setFillColor(0,1,0)
	orb.myName = "ballz"
	physics.addBody(orb, "dynamic", { friction = 0.0, bounce = 1.0, radius = 10 })
	orb.gravityScale = 0.2
	orb:setLinearVelocity(xVel, yVel)
end

function startLevel()
	levelNum = levelNum + 1
	numBallsLeft = levelNum

	local rows = rowGroup.numChildren
	for i=1, rows do
		local row = rowGroup[i]
		for j=1, row.numChildren do
			row[j][1].y = row[j][1].y + display.contentHeight/10
			row[j][2].y = row[j][2].y + display.contentHeight/10
			if (row[j][1].y > display.contentHeight - 30) then
				composer.gotoScene("menu", "fade", 100)

				return true
			end
		end
	end

	addBoxes(levelNum)
	enableTouch = true
end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	enableTouch = true

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen


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

		local leftWall = display.newRect (display.screenOriginX, display.screenOriginY, 1, display.contentHeight * 2);
		local rightWall = display.newRect (screenW, display.screenOriginY, 1, display.contentHeight * 2);
		local ceiling = display.newRect (display.screenOriginX, display.screenOriginY, display.contentWidth, 1);
		local floor = display.newRect (display.screenOriginX, display.actualContentHeight, display.contentWidth, 1);
		leftWall:setFillColor(1)
		rightWall:setFillColor(1)
		ceiling:setFillColor(1)
		floor:setFillColor(1)
		leftWall.anchorX = 0.0;
		leftWall.anchorY = 0.0;
		rightWall.anchorX = 1.0;
		rightWall.anchorY = 0.0;
		ceiling.anchorX = 0.0;
		ceiling.anchorY = 0.0;
		floor.anchorX = 0.0;
		floor.anchorY = 1.0
		floor.myName = "kill"

		floor.collision = onFloorCollision
		floor:addEventListener("collision")

		physics.addBody (leftWall, "static",  { bounce = 1.0} );
		physics.addBody (rightWall, "static", { bounce = 1.0} );
		physics.addBody (ceiling, "static",   { bounce = 1.0} );
		physics.addBody (floor, "static", { bounce = 1.0} );

		function background:touch(e)
			if (e.phase == "began") then
				if (enableTouch) then
					enableTouch = false;
					local targetVelocity = 800;
					local xDist = e.x - display.contentWidth / 2
					local yDist = e.y - display.contentHeight - 5
					local angle = math.atan(yDist/xDist)
					local xVel = math.cos(angle) * targetVelocity * (xDist / (math.abs(xDist)))
					local yVel = math.sin(angle) * targetVelocity * (xDist / (math.abs(xDist)))
					timer.performWithDelay(100, function()
							addOrb(xVel, yVel)
						end, levelNum)
				end
			end
		end

		background:addEventListener("touch", background);

		-- all display objects must be inserted into group
		sceneGroup:insert( background )
	elseif phase == "did" then
		levelNum = 0
		rowGroup = display.newGroup() --all rows
		-- Called when the scene is now on screen
		physics.start()
		startLevel()
	end
end

function scene:hide( event )
	print("Hide")
	local sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		print("HIDE will")
		rowGroup:removeSelf()
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		print("HIDE did")
		-- Called when the scene is now off screen

	end

end

function scene:destroy( event )
	print("Destroy")
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
