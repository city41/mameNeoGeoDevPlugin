util = {}

function util.isOnScreen(left, top, right, bottom)
	return not (right < 0 or bottom < 0 or left > 320 or top > 224)
end

function util.calcOnScreenPortion(line, camX, camY)
	local startX = line.startX + camX
	local startY = line.startY + camY
	local endX = line.endX + camX
	local endY = line.endY + camY

	-- slope
	local m = (endY - startY) / (endX - startX)
	-- intercept
	local b = startY - m * startX

	local xAtY0 = -b / m
	local xAtY224 = (224 - b) / m
	local yAtX0 = b
	local yAtX320 = m * 320 + b

	local finalLine = {}

	finalLine.startX = startX
	finalLine.startY = startY

	if startY < 0 then
		finalLine.startY = 0
		finalLine.startX = xAtY0
	elseif startY > 224 then
		finalLine.startY = 224
		finalLine.startX = xAtY224
	end

	if finalLine.startX < 0 then
		finalLine.startX = 0
		finalLine.startY = yAtX0
	elseif finalLine.startX > 320 then
		finalLine.startX = 320
		finalLine.startY = yAtX320
	end

	finalLine.endX = endX
	finalLine.endY = endY

	if endY < 0 then
		finalLine.endY = 0
		finalLine.endX = xAtY0
	elseif endY > 224 then
		finalLine.endY = 224
		finalLine.endX = xAtY224
	end

	if finalLine.endX < 0 then
		finalLine.endX = 0
		finalLine.endY = yAtX0
	elseif finalLine.endX > 320 then
		finalLine.endX = 320
		finalLine.endY = yAtX320
	end

	return finalLine
end

function util.clamp(v, min, max)
	return math.min(max, math.max(min, v))
end
