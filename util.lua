require "vecutil"

function width() return g.getWidth() end
function height() return g.getHeight() end
function halfWidth() return width() / 2 end
function halfHeight() return height() / 2 end

function circle(x, y, radius)
	return {pos = {x=x; y=y}; radius=radius}
end

function rectangle(x, y, width, height)
	return {x=x; y=y; width=width; height=height}
end

function circlesOverlap(a, b)
	return distVec(a.pos, b.pos) < a.radius + b.radius
end

function circleContains(circle, point)
	return distVec(circle.pos, point) < circle.radius
end

function rectangleContains(rectangle, point)
	if rectangle.width < 0 then
		rectangle.width = math.abs(rectangle.width)
		rectangle.x = rectangle.x - rectangle.width
	end
	if rectangle.height < 0 then
		rectangle.height = math.abs(rectangle.height)
		rectangle.y = rectangle.y - rectangle.height
	end
	return point.x >= rectangle.x and point.y >= rectangle.y and point.x <=
		rectangle.x + rectangle.width and point.y <= rectangle.y + rectangle.height
end

function createInitialUnits(margin, interval, columns, rows)
	local positions = {}
	local half = ( interval * rows) / 2
	for x = margin, margin + (interval * columns) - 1, interval do
		for y = halfHeight() - half, halfHeight() + half - 1, interval do
			positions[#positions + 1] = vec(x, y + interval / 2)
		end
	end

	for i=1,#positions do
		pos = positions[i]
		Unit:new(pos.x, pos.y, RED)
		Unit:new(width() - pos.x, pos.y, BLUE)
	end
end

function tindex(table, element)
	for k, v in pairs(table) do
		if v == element then
			return k
		end
	end
	return nil
end

function tconcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function math.clamp(low, n, high)
	return math.min(math.max(low, n), high)
end

function math.lerp(a, b, t)
	return a + (b - a) * t
end

p = love.window.toPixels
P = love.window.fromPixels

RED, BLUE = 0, 1
RED_COLOUR, BLUE_COLOUR = {215, 60, 80}, {90, 130, 255}
MOVE, CONTROL = 0, 1
MENU, GAME = require "states/game", require "states/menu"
MOVE_TIME = 1.5
GRID_SIZE = 40
HEAL_TIME = 45
UNITS_WIDE = 3
UNITS_HIGH = 9

FONT_TITLE = love.graphics.newFont("fonts/Oswald-Regular.ttf", p(65))
FONT_LARGE = love.graphics.newFont("fonts/Pavanam-Regular.ttf", p(40))
FONT_NORMAL = love.graphics.newFont("fonts/Pavanam-Regular.ttf", p(17))
FONT_SMALL = love.graphics.newFont("fonts/Pavanam-Regular.ttf", p(12))

state = MENU
start = love.timer.getTime()
g = love.graphics
w = love.window
debug = false
lastClick = 0
doubleClickDelay = 0.2
