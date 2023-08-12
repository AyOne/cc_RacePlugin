local CD = {}









function CD.lineToLine(x1, y1, x2, y2, x3, y3, x4, y4)
	uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
	uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))

	if (uA >= 0 and uA <= 1 and uB >= 0 and uB <= 1) then
		intersectX = x1 + (uA * (x2-x1))
		intersectY = y1 + (uA * (y2-y1))
		return true, intersectX, intersectY
	end
	return false, nil, nil
end



function CD.lineToRect(x1, y1, x2, y2, rx, ry, rw, rh)
	local left = CD.lineToLine(x1, y1, x2, y2, rx, ry, rx, ry+rh)
	local right = CD.lineToLine(x1, y1, x2, y2, rx+rw, ry, rx+rw, ry+rh)
	local top = CD.lineToLine(x1, y1, x2, y2, rx, ry, rx+rw, ry)
	local bottom = CD.lineToLine(x1, y1, x2, y2, rx, ry+rh, rx+rw, ry+rh)

	if (left or right or top or bottom) then
		return true
	end
	return false
end


function CD.lineToHitbox(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
	local zy_axe = CD.lineToRect(y1, z1, y2, z2, y3, z3, y4-y3, z4-z3)
	local xz_axe = CD.lineToRect(x1, z1, x2, z2, x3, z3, x4-x3, z4-z3)
	local xy_axe = CD.lineToRect(x1, y1, x2, y2, x3, y3, x4-x3, y4-y3)
	
	-- if at least two are true, then the line is colliding with the hitbox
	if (zy_axe and xz_axe) then
		return true
	elseif (zy_axe and xy_axe) then
		return true
	elseif (xz_axe and xy_axe) then
		return true
	end
	return false
end





return CD