Options = {}

function Options.enter(args)
	g.setBackgroundColor(255, 255, 255)
	g.setFont(FONT_LARGE)
end

function Options.exit() end

function Options.update(dt) end

function Options.draw()
	g.setFont(FONT_TITLE)
	g.setColor(RED_COLOUR)
	g.print("Options", p(10), p(10))
end

function Options.keypressed(key)
	setState(require "states/menu")
end

function Options.keyreleased(key) end

function Options.mousepressed(x, y, button, istouch) end

function Options.mousemoved(x, y, dx, dy, istouch) end

function Options.mousereleased(x, y, button, istouch) end

function Options.doubleclick(x, y) end

return Options