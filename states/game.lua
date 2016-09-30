Game = {}

local mode, moveTimer, grid, selectionRectangle, paused
local moves

function Game.enter(args)
	g.setBackgroundColor(255, 255, 255)

	createInitialUnits(40, 40, UNITS_WIDE, UNITS_HIGH)
	g.setFont(FONT_NORMAL)

	mode = CONTROL
	moveTimer = 0
	grid = true
	paused = false
	selectionRectangle = rectangle(nil, nil, nil, nil)
	moves = {{}}
end

function Game.exit()
	Unit:killAll()
	Bullet:killAll()
end

function Game.update(dt)
	if paused then return end
	if mode == MOVE then
		moveTimer = moveTimer + dt
		if moveTimer >= MOVE_TIME then
			mode = CONTROL
			moveTimer = 0
			Unit.selected = {}
		end
	end
	Bullet:updateAll(dt, mode, true, moves)
	Unit:updateAll(dt, mode)
end

function Game.draw()
	Bullet:drawAll()
	Unit:drawDestinations()
	Unit:drawAll(mode)

	local s = selectionRectangle
	if s.x ~= nil and s.y ~= nil and s.width ~= nil and s.height ~= nil then
		g.setColor(100, 100, 100, 30)
		g.rectangle("fill", p(s.x), p(s.y), p(s.width), p(s.height))
	end

	renderTeamHealthBars()

	if mode == MOVE then
		renderMoveTimeBar()
	end

	g.setColor(0, 0, 0)
	g.setFont(FONT_SMALL)
	if debug then -- Draw some information: fps, mode, mouse pos and controls
		g.print("FPS: " .. love.timer.getFPS(), 5, 0)
		g.print("Mode: " ..  (mode == MOVE and "Move" or "Control"), 5, 30)
		g.print("Mouse: [" .. P(love.mouse.getX()) .. ", " .. P(love.mouse.getY()) .. "]", 5, 60)
		g.print("Press 'escape' to" .. (paused and " un" or " ") .. "pause. The game is currently" ..
			(paused and "" or " not") .. " paused.", 5, 90)
		g.print("Press 'F3' to hide the info menu", 5, 120)
		g.print("Press '~' to open the console", 5, 150)
		g.print("Press 'G' to toggle the grid", 5, 180)
		g.print("Press 'Q' to exit to the main menu", 5, 210)
	else
		g.print("Press 'F3' to show the info menu", 5, 0)
	end

	if grid and mode == CONTROL then
		renderGrid(GRID_SIZE)
	end

	if paused then
		g.setColor(100, 100, 100, 128)
		g.rectangle("fill", 0, 0, p(width()), p(height()))

		g.setFont(FONT_LARGE)
		g.setColor(0, 0, 0)
		g.printf("Paused", 0, p(height() / 2 - 20), p(width()), "center")
	end
end

function Game.keypressed(key)
	if key == "escape" then
		paused = not paused
	elseif key == "space" and mode == CONTROL and not paused then
		mode = MOVE
		moves[#moves + 1] = {}
	elseif key == "g" and not paused then
		grid = not grid
	elseif key == "q" then
		setState(require "states/menu")
	end
end

function Game.keyreleased(key) end

function Game.mousepressed(x, y, button, istouch)
	if paused then return end

	selectionRectangle.x, selectionRectangle.y = x, y

	if button == 1 and mode == CONTROL then
		if not love.keyboard.isDown("lshift", "rshift") then Unit.static.selected = {} end
		local unit = Unit:findUnitAtPoint(vec(x, y))
		if (unit ~= nil) then
			unit:toggleSelect() 
		end
	elseif button == 2 and mode == CONTROL then
		local pos = vec(x, y)
		if grid then
			pos = clampPositionToGrid(pos, p(3), GRID_SIZE)
		end
		local m = Unit:moveSelectedToPoint(pos)
		if m ~= nil then
			moves[#moves] = tconcat(moves[#moves], m)
		end
	end
end

function Game.mousemoved(x, y, dx, dy, istouch)
	if paused then return end
	if selectionRectangle.x ~= nil and selectionRectangle.y ~= nil then
		selectionRectangle.width, selectionRectangle.height =
			x - selectionRectangle.x, y - selectionRectangle.y
	end
end

function Game.mousereleased(x, y, button, istouch)
	if paused then return end --<<<
	local s = selectionRectangle
	if s.x ~= nil and s.y ~= nil and s.width ~= nil and s.height ~= nil then
		local units = Unit:getUnitsInRectangle(s, nil)
		local team = nil
		for i=1,#units do
			local unit = units[i]
			if unit.team == team or team == nil then
				unit:select()
				team = unit.team
			end
		end
	end

	selectionRectangle = rectangle(nil, nil, nil, nil)
end

function Game.doubleclick(x, y)
	local unit = Unit:findUnitAtPoint(vec(x, y))
	if unit ~= nil then
		local team = unit.team
		for i=1,#Unit.units do
			local u = Unit.units[i]
			if u.team == team then
				u:select()
			end
		end
	end
end

function renderGrid(size)
	g.setLineWidth(1)

	for x=0,width(),size / 2 do
		g.setColor(100, 100, 100, x % size == 0 and 20 or 10)
		g.line(p(x), 0, p(x), p(height()))
	end

	for y=0,height(),size / 2 do
		g.setColor(100, 100, 100, y % size == 0 and 20 or 10)
		g.line(0, p(y), p(width()), p(y))
	end
end

function renderMoveTimeBar()
	local width = p(width() - 10)

	g.setColor(230, 230, 230)
	g.rectangle("fill", p(5), p(height() - 5), width, p(-20))

	g.setColor(100, 210, 130)
	g.rectangle("fill", p(5), p(height() - 5), width * (moveTimer / MOVE_TIME), p(-20))
end

function renderTeamHealthBars()
	local red, blue = Unit:getTeamHealth(RED), Unit:getTeamHealth(BLUE)
	local w = 6

	g.setColor(RED_COLOUR)
	g.rectangle("fill", 0, p(height()), p(w), -height() * p(red))

	g.setColor(BLUE_COLOUR)
	g.rectangle("fill", p(width() - w), p(height()), p(w), -height() * p(blue))
end

function clampPositionToGrid(point, threshold, size)
	for x=0,width(),size / 2 do
		for y=0,height(),size / 2 do
			local vert = vec(x, y)
			local dist = distVec(point, vert)
			if dist <= threshold then
				return vert
			end
		end
	end
	return point
end

return Game
