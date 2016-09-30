Instructions = {}

function Instructions.enter(...)
	g.setBackgroundColor(255, 255, 255)
	g.setFont(FONT_LARGE)
end

function Instructions.exit() end

function Instructions.update(dt) end

function Instructions.draw()
	g.setFont(FONT_TITLE)
	g.setColor(RED_COLOUR)
	g.print("Instructions", p(10), 0)

	g.setColor(0, 0, 0)
	g.setFont(FONT_NORMAL)
	g.printf(
[[Left-click a unit to select it, then right-click to move it to that position.

Units will automatically shoot enemy units, and will deal damage upon collision.

Once in game, press 'q' to exit to the main menu. You can use '~' anywhere in the game to open the terminal.
Use 'g' to toggle the grid. Once enabled, destinations are attracted to the grid intersections.
Use 'escape' to pause and 'f3' to show some in-game information, as well as the controls.

Press any key to return to the main menu.
]], p(10), p(100), p(width()), "left")
end

function Instructions.keypressed(key)
	setState(require "states/menu")
end

function Instructions.keyreleased(key) end

function Instructions.mousepressed(x, y, button, istouch) end

function Instructions.mousemoved(x, y, dx, dy, istouch) end

function Instructions.mousereleased(x, y, button, istouch) end

function Instructions.doubleclick(x, y) end

return Instructions