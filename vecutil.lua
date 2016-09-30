function vec(x, y)
	return {x=x; y=y}
end

function lenVec(a)
	return math.sqrt(a.x * a.x + a.y * a.y)
end

function distVec(a, b)
	return lenVec(vec(math.abs(a.x - b.x), math.abs(a.y - b.y)))
end

function addVec(a, b)
	return vec(a.x + b.x, a.y + b.y)
end

function subtractVec(a, b)
	return addVec(a, scaleVec(b, -1))
end

function scaleVec(a, scalar)
	return vec(a.x * scalar, a.y * scalar)
end

function normalizeVec(a)
	len = lenVec(a)
	if len == 0 then return a end
	return vec(a.x / len, a.y / len)
end
