local class = require "lib/middleclass"
require "util"
require "vecutil"
require "unit"

Bullet = class("Bullet")

Bullet.static.bullets = {}
Bullet.static.nextId = 0

Bullet.static.RADIUS = 3
Bullet.static.SPEED = 200
Bullet.static.DISTANCE = 210
Bullet.static.DAMAGE = 20
Bullet.static.KNOCKBACK = 130

-- The bullet constructor
function Bullet:initialize(x, y, team, shooter, vel)
	self.pos = vec(x, y)
	self.vel = scaleVec(normalizeVec(vel), Bullet.SPEED)
	self.id = Bullet.nextId
	Bullet.static.nextId = Bullet.nextId + 1
	self.shooter = shooter
	self.team = team
	self.dead = false
	self.distanceTravelled = 0

	Bullet.bullets[#Bullet.bullets+1] = self
end

-- Draws the bullet as a circle the same colour as the shooter
function Bullet:draw()
	if (self.dead) then return end

	g.setColor(self.shooter:getColour())
	g.circle("fill", p(self.pos.x), p(self.pos.y), p(Bullet.RADIUS))
end


-- Updates the bullet:
	--> Kills it if it's went too far
	--> Moves it
	--> Checks overlap with units and damages them if it does
function Bullet:update(dt, mode)
	if (self.dead) then return end

	if mode == MOVE then
		self.distanceTravelled = self.distanceTravelled + lenVec(scaleVec(self.vel, dt))
		if self.distanceTravelled > Bullet.DISTANCE then
			self:kill()
		end
		self.pos = addVec(self.pos, scaleVec(self.vel, dt))

		for i=1,#Unit.units do
			local unit = Unit.units[i]
			if unit:overlaps(self:getCollisionCircle()) and unit.team ~= self.team then
				self:kill()
				unit:takeHealth(Bullet.DAMAGE)
				unit:addVelocity(scaleVec(unit:getDirectionTo(self.pos), -Bullet.KNOCKBACK))
				return
			end
		end
	end
end

-- Kills the bullet
function Bullet:kill()
	self.dead = true
	table.remove(Bullet.bullets, tindex(Bullet.bullets, self))
end

-- Gets a circle representing the collision bounds of the bullet
function Bullet:getCollisionCircle()
	return circle(self.pos.x, self.pos.y, Unit.RADIUS)
end

-- Returns a string representation of the unit
function Unit:tostring()
	return "Bullet, " .. self.id .. ", @ [" .. self.pos.x .. ", " .. self.pos.y .. "]"
end

-- Draws all bullets in Bullet.bullets
function Bullet.static:drawAll()
	for i=1,#Bullet.bullets do
		Bullet.bullets[i]:draw()
	end
end

-- Updates all bullets in Bullet.bullets
function Bullet.static:updateAll(dt, mode)
	for i=1,#Bullet.bullets do
		Bullet.bullets[i]:update(dt, mode)
	end
end

-- Kills all bullets
function Bullet.static:killAll()
	Bullet.static.bullets = {}
end
