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

function util.areTablesEqual(a, b)
	if #a ~= #b then
		return false
	end

	for k, v in pairs(a) do
		if b[k] ~= v then
			return false
		end
	end

	return true
end

-- returns the pairs of a table sorted by their keys
function util.spairs(t, order)
	-- collect the keys
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a, b)
			return order(t, a, b)
		end)
	else
		table.sort(keys)
	end

	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

function util.convert16to24(col16)
	local shadowBit = 2
	local darkBit = col16 >> 15

	local rLSB = (col16 >> 14) & 1
	local gLSB = (col16 >> 13) & 1
	local bLSB = (col16 >> 12) & 1

	local rMSB = (col16 >> 8) & 0xf
	local gMSB = (col16 >> 4) & 0xf
	local bMSB = col16 & 0xf

	local r = (rMSB << 4) | (rLSB << 3) | (darkBit << 2) | shadowBit
	local g = (gMSB << 4) | (gLSB << 3) | (darkBit << 2) | shadowBit
	local b = (bMSB << 4) | (bLSB << 3) | (darkBit << 2) | shadowBit

	return (0xff << 24) | (r << 16) | (g << 8) | b
end
