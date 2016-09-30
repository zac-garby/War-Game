require "lib/cupid"
require "util"
require "unit"
require "bullet"

Game = require "states/game"
Menu = require "states/menu"

function love.load()
	math.randomseed(os.time())
	setState(Menu)
end

function love.draw()
	state.draw()
end

function love.update(dt)
	state.update(dt)
end

function love.keypressed(key)
	state.keypressed(key)
end

function love.keyreleased(key)
	if key == "f3" then
		debug = not debug
	end
	state.keyreleased(key)
end

function love.mousepressed(x, y, button, istouch)
	x, y = P(x), P(y)

	local time = love.timer.getTime()

	if time - lastClick < doubleClickDelay and button == 1 then
		onDoubleClick(x, y)
		lastClick = 0
		return
	end

	state.mousepressed(x, y, button, istouch)

	lastClick = time
end

function love.mousemoved(x, y, dx, dy, istouch)
	x, y = P(x), P(y)

	state.mousemoved(x, y, dx, dy, istouch)
end

function love.mousereleased(x, y, button, istouch)
	x, y = P(x), P(y)

	state.mousereleased(x, y, button, istouch)
end

function onDoubleClick(x, y)
	state.doubleclick(x, y)
end

function setState(newState, ...)
	local arg = {...}
	if newState ~= nil then
		state.exit()

		state = newState

		state.enter(arg)
	end
end
