-----------------------------------------------------------------------------------------
--
-- menu.lua
-- Here the player can choose between playing the game or
-- visiting another scene.
-- Shows some animations in the background for fun.
-----------------------------------------------------------------------------------------
local perspective = require("perspective")

local composer = require( "composer" )


local scene = composer.newScene()

local physics = require("physics")
physics:start()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local camera = perspective.createView()
local playBtn
local titleLogo
local aboutBtn
local wrapAround
local sheet_ground, sheet_tank
local tank
-------------------------------------------
local ground = {}
local ground_group = display.newGroup()
-- The "ground" is the ground_group display group
-- Which is composed of tiles from the 'ground' table
-------------------------------------------
local buildings = {}
local screenW = display.contentWidth
local screenH = display.contentHeight
local halfW = screenW*0.5
local halfH = screenH*0.5

-- Image sheets for background anims
sheet_ground = graphics.newImageSheet( "groundsheet.png",
	{
		width = 32,
		height = 32,
		numFrames = 3
	})

	sheet_buildings = graphics.newImageSheet( "buildingssheet.png",
	{
		frames =
		{
			{
				x = 0,
	            y = 0,
	            width = 48,
	            height = 64
			},
			{
				x = 48,
	            y = 0,
	            width = 34,
	            height = 64
			},
			{
				x = 82,
	            y = 0,
	            width = 66,
	            height = 64
			},
			{
				x = 148,
	            y = 0,
	            width = 42,
	            height = 64
			}
		}
	})

	sheet_tank = graphics.newImageSheet( "tanksheet.png",
	{
		width = 16,
		height = 16,
		numFrames = 8
	})

-------------------------------------------------------
-- LOCAL SCENE FUNCTIONS
-------------------------------------------------------

-- 'onRelease' event listener for playBtn
-- This is what happens after the player touches the btn
local function onPlayBtnRelease()
	
	-- go to rungame scene/ actually play the game
	composer.gotoScene( "rungame", "fade", 500 )
	
	return true	-- indicates successful touch
	-- Otherwise the touch would 'fall through'
end

local function onAboutBtnRelease()
	
	-- can change to show a new scene like an about scene
	composer.gotoScene( "rungame", "fade", 500 )
	
	return true	-- indicates successful touch
end

-- Fun little animation for the background.
local function createDynamicBackground( )
	local tileSize = 32
	local numTilesW = ((screenW/tileSize) * 8)
	local numTilesH = ((screenH/tileSize) * 8)

	for i = 0, numTilesH do
		for j = 0, numTilesW do

			local x =  2*(-screenW - halfW) + tileSize*j
			local y = 2*(-screenH - halfH) + tileSize*i

			local switch = math.random(1,3)
			ground[(i*100)+j] = display.newImage(sheet_ground, switch)
			ground[(i*100)+j].x = x
			ground[(i*100)+j].y = y
			ground_group:insert(ground[(i*100)+j])
		end

	end

	tank = display.newImage(sheet_tank,1)
	physics.addBody(tank,"dynamic",{density = 200})
	wrapAround = timer.performWithDelay(1,function()
		-- Wraps the tank around the screen and also pushes it in random
		-- directions
		local chance = math.random(1,10)
		if (chance == 5) then
			tank:applyForce(math.random(-8000,8000),
							math.random(-8000,8000),
							tank.x,tank.y)
		end
	
		if tank.x > screenW*4 then
			tank.x = -2*screenW
		elseif tank.x < -2*screenW then
			tank.x = screenW*4
		elseif tank.y > screenH*4 then
			tank.y = -2*screenH
		elseif tank.y < -2*screenH then
			tank.y = screenH*4
		end
	end,-1)

	
	camera:add(ground_group,1)
	camera:add(tank,1)
	camera.damping = 7
	camera:setFocus(tank)
	camera:track()

	for f = 0, 100 do
		local x = math.random(-screenW,2*screenW)
		local y = math.random(-screenH,2*screenH)
		local switch = math.random(1,4)
		buildings[f] = display.newImage(sheet_buildings, switch)
		buildings[f].x = x
		buildings[f].y = y
		buildings[f].buildingType = switch
		physics.addBody(buildings[f], "static")
		ground_group:insert(buildings[f])
	end
end

-----------------------------------------------------------
-- GLOBAL SCENE FUNCTIONS
-----------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view


	createDynamicBackground()
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		-- create/position logo/title image on upper-half of the screen
	titleLogo = display.newImage( "title.png", display.contentWidth * -2, 100 )
	titleLogo.x = display.contentWidth * -2
	titleLogo.y = 100
	
	-- create a widget button for 'Play Game'
	playBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="playbtn.png",
		width=115, height=40,
		onRelease = onPlayBtnRelease	-- event listener in local functions
	}
	playBtn.x = display.contentWidth*2
	playBtn.y = display.contentHeight - 125

	-- Widget button for 'About Game'
	aboutBtn = widget.newButton{
		labelColor = { default={255}, over={128} },
		defaultFile="aboutbtn.png",
		width=154, height=40,
		onRelease = onAboutBtnRelease	-- event listener in local functions
	}
	aboutBtn.x = display.contentWidth*0.5
	aboutBtn.y = display.contentHeight*2
	
	-- all display objects must be inserted into group
	sceneGroup:insert(camera)
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( aboutBtn )
	sceneGroup:insert( playBtn )
	
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- Cool animation for buttons sliding onto screen
		-- Uses Corona's Built in easing functions
			transition.to(playBtn,{time=2000,x=(display.contentWidth*0.5),transition=easing.outExpo})
			transition.to(titleLogo,{time=2000,x=(display.contentWidth*0.5),transition=easing.outExpo})
			transition.to(aboutBtn,{time=2000,y=(display.contentHeight-60),transition=easing.outExpo})
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
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	timer.cancel( wrapAround )
	ground_group:removeSelf()
	camera:cancel()
	camera:destroy()
	sceneGroup:removeSelf()
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
	if aboutBtn then
		aboutBtn:removeSelf()	-- widgets must be manually removed
		aboutBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene