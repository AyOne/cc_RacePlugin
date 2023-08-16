local CD = {}









function CD.lineToLine(x1, y1, x2, y2, x3, y3, x4, y4)
	local uA, uB, intersectX, intersectY, A_C, A_B, factor = 0,0,0,0,0,0,0
	uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
	uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))

	if (uA >= 0 and uA <= 1 and uB >= 0 and uB <= 1) then
		intersectX = x1 + (uA * (x2-x1))
		intersectY = y1 + (uA * (y2-y1))
		A_C = math.sqrt((x1-x3)^2 + (y1-y3)^2)
		A_B = math.sqrt((x1-x2)^2 + (y1-y2)^2)
		factor = A_C / A_B
		return true, factor, intersectX, intersectY
	end
	return false, 0, 0, 0
end



function CD.lineToRect(x1, y1, x2, y2, rx, ry, rw, rh)
	local factor, left, right, top, bottom = 0,0,0,0,0
	left, factor = CD.lineToLine(x1, y1, x2, y2, rx, ry, rx, ry+rh)
	if (left) then
		return true, factor
	end
	
	right, factor = CD.lineToLine(x1, y1, x2, y2, rx+rw, ry, rx+rw, ry+rh)
	if (right) then
		return true, factor
	end

	top, factor = CD.lineToLine(x1, y1, x2, y2, rx, ry, rx+rw, ry)
	if (top) then
		return true, factor
	end

	bottom, factor = CD.lineToLine(x1, y1, x2, y2, rx, ry+rh, rx+rw, ry+rh)
	if (bottom) then
		return true, factor
	end

	return false, 0
end


function CD.lineToHitbox(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
	local zy_axe, zy_factor = CD.lineToRect(y1, z1, y2, z2, y3, z3, y4-y3, z4-z3)
	local xz_axe, xz_factor = CD.lineToRect(x1, z1, x2, z2, x3, z3, x4-x3, z4-z3)
	local xy_axe, zy_factor = CD.lineToRect(x1, y1, x2, y2, x3, y3, x4-x3, y4-y3)
	
	-- if at least two are true, then the line is colliding with the hitbox
	if (zy_axe and xz_axe) then
		return true, math.max(zy_factor, xz_factor)
	elseif (zy_axe and xy_axe) then
		return true, math.max(zy_factor, xy_factor)
	elseif (xz_axe and xy_axe) then
		return true, math.max(xz_factor, xy_factor)
	end
	return false, 0
end





return CD