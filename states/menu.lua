Menu = {}

local options = {}
options[1] = {state=require "states/game", name="Play"}
options[2] = {state=require "states/instructions", name="Instructions"}
options[3] = {state=require "states/exit", name="Exit"}

local option = 1

function Menu.enter(args)
	g.setBackgroundColor(255, 255, 255)
end

function Menu.exit() end

function Menu.update(dt) end

function Menu.draw()
	g.setColor(RED_COLOUR)
	g.setFont(FONT_TITLE)
	g.printf("War Game", 0, p(180), p(width()), "center")

	g.setColor(0, 0, 0)
	g.setFont(FONT_LARGE)
	local yo = 0
	for i=1,#options do
		local op = options[i]
		g.setColor(i == option and RED_COLOUR or {0, 0, 0})
		g.printf(op.name, 0, p(height() / 2 + yo), p(width()), "center")
		yo = yo + 50
	end
end

function Menu.keypressed(key)
	if key == "up" then
		optionUp()
	elseif key == "down" then
		optionDown()
	elseif key == "return" then
		setState(options[option].state)
	end
end

function Menu.keyreleased(key) end

function Menu.mousepressed(x, y, button, istouch) end

function Menu.mousemoved(x, y, dx, dy, istouch) end

function Menu.mousereleased(x, y, button, istouch) end

function Menu.doubleclick(x, y) end

function changeOption(amount)
	option = option + amount
	if option > #options then option = 1 end
    if option < 1 then option = #options end
end

function optionUp()
	changeOption(-1)
end

function optionDown()
	changeOption(1)
end

return Menu