local class = require "lib/middleclass"
require "util"
require "vecutil"

Unit = class("Unit")

Unit.static.units = {}
Unit.static.selected = {}
Unit.static.nextId = 0

Unit.static.RADIUS = 13
Unit.static.STOP_DISTANCE = 1
Unit.static.SPEED = 10
Unit.static.FIRE_RATE = 0.5
Unit.static.MAX_SHOOT_SPEED = 20

-- The unit constructor
function Unit:initialize(x, y, team)
	self.pos = vec(x, y)
	self.dest = vec(x, y)
	self.vel = vec(0, 0)
	self.id = Unit.nextId
	Unit.static.nextId = Unit.nextId + 1
	self.team = team
	self.health = 100
	self.dead = false
	self.nextShotTimer = 0

	Unit.units[#Unit.units+1] = self
end

-- Draws all the parts of the unit:
	--> The selection outline
	--> The body
	--> The health pie-chart
function Unit:draw(mode)
	if (self.dead) then return end

	if mode == CONTROL and (self:isSelected()) then
		g.setColor(self:getColour())
		g.setLineWidth(p(1))
		g.circle("line", p(self.pos.x), p(self.pos.y), p(Unit.RADIUS * 1.15))

		if distVec(self.pos, self.dest) > Unit.RADIUS then
			g.setColor(0, 0, 0, 10)
			g.circle("fill", p(self.dest.x), p(self.dest.y), p(Bullet.DISTANCE))
		end
	end

	-- Render unit
	g.setColor(self:getColour())
	g.circle("fill", p(self.pos.x), p(self.pos.y), p(Unit.RADIUS))

	-- Render health pi-chart
	g.setColor(255, 255, 255)
	g.arc("fill", p(self.pos.x), p(self.pos.y), p(Unit.RADIUS * 0.85), math.pi *
		1.5, (2 * math.pi * ((100 - self.health) / 100)) + math.pi * 1.5)
end

-- Draws a line to the destination
function Unit:drawDestination()
	g.setColor(self:getColour())

	g.setLineWidth(p(3))
	g.line(p(self.pos.x), p(self.pos.y), p(self.dest.x), p(self.dest.y))

	g.circle("fill", p(self.dest.x), p(self.dest.y), p(3))
end

-- Updates the unit. First, clamps its health between 0-100, then kills it if it should be dead.
-- If the global action mode is MOVE, it moves to the destination and collides with other units.
function Unit:update(dt, mode)
	if self.health > 100 then self.health = 100 end
	if self.health <= 0 then self:kill() end

	if mode == MOVE then
		local speed = self:getSpeed()

		self.health = self.health + (100 * dt / HEAL_TIME)

		self.nextShotTimer = self.nextShotTimer + dt
		if self.nextShotTimer > 1 / Unit.FIRE_RATE and speed <= Unit.MAX_SHOOT_SPEED then
			local closest = self:findTarget()
			if closest ~= nil then
				self:shootAt(closest.pos)
				self.nextShotTimer = 0
			end
		end

		-- If it's far enough away from the destination,
		if distVec(self.pos, self.dest) > Unit.STOP_DISTANCE then
			local diff = self:getDirectionTo(self.dest)
			diff = scaleVec(diff, Unit.SPEED)
			self:addVelocity(diff)
		end
		self.vel = scaleVec(self.vel, 0.935)

		-- Calculate collisions and speed
		local collisionX, collisionY = self:getCollisionX(dt), self:getCollisionY(dt)

		-- Move on the X axis if there isn't a unit in the way. If there is, push it away
		if collisionX == nil then
			self.pos.x = self.pos.x + self.vel.x * dt
		else
			self.vel.x = self.vel.x * -0.8
			collisionX:addVelocity(scaleVec(collisionX:getDirectionTo(self.pos), -speed * 0.7))
		end

		-- Move on the Y axis if there isn't a unit in the way. If there is, push it away
		if collisionY == nil then
			self.pos.y = self.pos.y + self.vel.y * dt
		else
			self.vel.y = self.vel.y * -0.8
			collisionY:addVelocity(scaleVec(collisionY:getDirectionTo(self.pos), -speed * 0.7))
		end

		-- Handle melee damage
		if ((collisionX ~= nil or collisionY ~= nil) and speed > 40) then
			if collisionX ~= nil and collisionX.team ~= self.team then collisionX:takeHealth(speed / 4) end
			if collisionY ~= nil and collisionY.team ~= self.team then collisionY:takeHealth(speed / 4) end
		end
	end

	self.pos.x = math.clamp(Unit.RADIUS, self.pos.x, width() - Unit.RADIUS)
	self.pos.y = math.clamp(Unit.RADIUS, self.pos.y, height() - Unit.RADIUS)
end

-- Checks if the unit, translated on the X axis as it will be next frame, will collide with any units
function Unit:willCollideX(dt)
	return self:getCollisionX(dt) ~= nil
end

-- Checks if the unit, translated on the Y axis as it will be next frame, will collide with any units
function Unit:willCollideY(dt)
	return self:getCollisionY(dt) ~= nil
end

-- Returns the unit that this unit, translated on the X axis, will collide with next frame, if any
function Unit:getCollisionX(dt)
	local translated = addVec(self.pos, vec(dt * self.vel.x, 0))
	for i = 1, #Unit.units do
		local unit = Unit.units[i]
		if unit.id ~= self.id and unit:overlaps(self:getTranslatedX(dt)) then
			return unit
		end
	end
	return nil
end

-- Returns the unit that this unit, translated on the Y axis, will collide with next frame, if any
function Unit:getCollisionY(dt)
	local translated = addVec(self.pos, vec(0, dt * self.vel.y))
	for i = 1, #Unit.units do
		local unit = Unit.units[i]
		if unit.id ~= self.id and unit:overlaps(self:getTranslatedY(dt)) then
			return unit
		end
	end
	return nil
end

-- Gets the position the unit would be next frame if it only was translated on the X axis
function Unit:getTranslatedX(dt)
	return circle(self.pos.x + self.vel.x * dt, self.pos.y, Unit.RADIUS)
end

-- Gets the position the unit would be next frame if it only was translated on the Y axis
function Unit:getTranslatedY(dt)
	return circle(self.pos.x, self.pos.y + self.vel.y * dt, Unit.RADIUS)
end

-- Adds velocity to the unit
function Unit:addVelocity(vel)
	self.vel = addVec(self.vel, vel)
end

-- Gets a vector pointing at 'vec'
function Unit:getDirectionTo(vec)
	local diff = subtractVec(vec, self.pos)
	diff = normalizeVec(diff)
	return diff
end

-- Kills the unit - removes it from the units table
function Unit:kill()
	self.dead = true
	table.remove(Unit.units, tindex(Unit.units, self))
	self:deselect()

	local allDead = true
	for i=1,#Unit.units do
		local unit = Unit.units[i]
		if unit.team == self.team and not unit.dead then
			allDead = false
		end
	end
	if allDead then
		setState(require "states/win", self.team == RED and BLUE or RED)
	end
end

-- Takes some health from the unit
function Unit:takeHealth(amount)
	self.health = self.health - amount
end

-- Gets the colour of the unit's team
function Unit:getColour()
	if self.team == RED then
		return RED_COLOUR
	else
		return BLUE_COLOUR
	end
end

-- Returns a circle which represents the unit's collision bounds
function Unit:getCollisionCircle()
	return circle(self.pos.x, self.pos.y, Unit.RADIUS)
end

-- Checks if the unit contains a point, 'a'
function Unit:contains(a)
	return circleContains(self:getCollisionCircle(), a)
end

-- Checks if the unit overlaps a circle, 'circle'
function Unit:overlaps(circle)
	return circlesOverlap(self:getCollisionCircle(), circle)
end

-- Gets the length of the velocity, i.e. the speed
function Unit:getSpeed()
	return lenVec(self.vel)
end

-- Selects the unit: adds it to the selected table
function Unit:select()
	if self.team == Unit:getSelectedTeam() or Unit:getSelectedTeam() == nil then
		Unit.selected[#Unit.selected+1] = self
	end
end

-- Deselects the unit
function Unit:deselect()
	table.remove(Unit.selected, tindex(Unit.selected, self))
end

-- Toggles the unit's selection status
function Unit:toggleSelect()
	if self:isSelected() then self:deselect() else self:select() end
end

-- Checks if the unit is in the selected array
function Unit:isSelected()
	return tindex(Unit.selected, self) ~= nil
end

-- Finds the closest enemy in range
function Unit:findTarget()
	local dist, unit = Bullet.DISTANCE, nil
	for i=1,#Unit.units do
		local un = Unit.units[i]
		local distance = distVec(self.pos, un.pos)

		if distance < dist and un.team ~= self.team then
			unit = un
			dist = distance
		end
	end
	return unit, dist
end

-- Shoots at the given point
function Unit:shootAt(point)
	Bullet:new(self.pos.x, self.pos.y, self.team, self, self:getDirectionTo(point))
end

-- Returns a string representation of the unit
function Unit:tostring()
	return "Unit, " .. self.id .. ", @ [" .. self.pos.x .. ", " .. self.pos.y .. "]"
end

-- Draws all units in the Unit.units table
function Unit.static:drawAll(mode)
	for i = 1, #Unit.units do
		Unit.units[i]:draw(mode)
	end
end

-- Draws all the destination lines
function Unit.static:drawDestinations()
	for i=1,#Unit.units do
		Unit.units[i]:drawDestination()
	end
end

-- Updates all units in the Unit.units table
function Unit.static:updateAll(dt, mode)
	for i = 1, #Unit.units do
		if i > #Unit.units then break end
		Unit.units[i]:update(dt, mode)
	end
end

-- Finds a unit at the given point
function Unit.static:findUnitAtPoint(point)
	for i = 1, #Unit.units do
		local unit = Unit.units[i]
		if (unit:contains(point)) then return unit end
	end
	return nil
end

-- Returns the team of the first selected unit
function Unit.static:getSelectedTeam()
	if #Unit.selected == 0 then
		return nil
	end
	return Unit.selected[1].team
end

-- Gets the closest selected unit to the given point
function Unit.static:getClosestSelectedUnit(point)
	local dist, unit = math.huge, nil
	for i=1,#Unit.selected do
		local un = Unit.selected[i]
		local distance = distVec(point, un.pos)
		if distance < dist then
			dist = distance
			unit = un
		end
	end
	return unit, dist
end

-- Sets the destinations of all the selected units, relative to the closest unit, to the given point
function Unit.static:moveSelectedToPoint(point)
	local closestUnit, closestDistance = Unit:getClosestSelectedUnit(point)
	if closestUnit == nil then
		return
	end
	local relativeMovement = subtractVec(point, closestUnit.pos)
	local moves = {}
	for i=1,#Unit.selected do
		local unit = Unit.selected[i]
		local dest = addVec(unit.pos, relativeMovement)
		unit.dest = dest
		moves[#moves + 1] = {
			id=unit.id,
			destination=dest
		}
	end

	return moves
end

-- Finds the first unit with the specified ID
function Unit.static:findUnitWithId(id)
	for i=1,#Unit.units do
		local unit = Unit.selected[i]
		if unit.id == id then return unit end
	end
	return nil
end

-- Returns all the units of the given team which are inside the given rectangle
function Unit.static:getUnitsInRectangle(rect, team)
	local units = {}
	for i=1,#Unit.units do
		local unit = Unit.units[i]
		if rectangleContains(rect, unit.pos) and (unit.team == team or team == nil) then
			units[#units+1] = unit
		end
	end
	return units
end

-- Kills all units
function Unit.static:killAll()
	Unit.static.units, Unit.static.selected = {}, {}
	Unit.static.nextId = 0
end

--
function Unit.static:getTeamHealth(team)
	local max, hp = UNITS_WIDE * UNITS_HIGH * 100, 0
	for i=1,#Unit.units do
		local unit = Unit.units[i]
		if unit.team == team then
			hp = hp + unit.health
		end
	end
	return hp / max
end

