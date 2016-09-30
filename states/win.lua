Win = {}

local winner, moves

function Win.enter(args)
	winner = args[1]
	moves = args[2]

	g.setBackgroundColor(255, 255, 255)
	g.setFont(FONT_LARGE)
end

function Win.exit() end

function Win.update(dt) end

function Win.draw()
	g.setFont(FONT_TITLE)
	g.setColor(winner == RED and RED_COLOUR or BLUE_COLOUR)
	g.printf((winner == RED and "Red" or "Blue") .. " wins!", 0, halfWidth() + p(25), p(width()), "center")

	g.setFont(FONT_NORMAL)
	g.printf("Press any key to return to the main menu", 0, halfWidth() + p(120), p(width()), "center")
end

function Win.keypressed(key)
	setState(require "states/menu")
end

function Win.keyreleased(key) end

function Win.mousepressed(x, y, button, istouch) end

function Win.mousemoved(x, y, dx, dy, istouch) end

function Win.mousereleased(x, y, button, istouch) end

function Win.doubleclick(x, y) end

return Win