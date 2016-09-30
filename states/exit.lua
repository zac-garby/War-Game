Exit = {}

function Exit.enter(args)
	love.event.quit()
end

function Exit.exit() end

function Exit.update(dt) end

function Exit.draw() end

function Exit.keypressed(key) end

function Exit.keyreleased(key) end

function Exit.mousepressed(x, y, button, istouch) end

function Exit.mousemoved(x, y, dx, dy, istouch) end

function Exit.mousereleased(x, y, button, istouch) end

function Exit.doubleclick(x, y) end

return Exit