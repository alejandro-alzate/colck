---@class ClockFace
---@field tweens table Tween functions for the clock face
---@field x number X position of the clock face
---@field y number Y position of the clock face
---@field radius number Radius of the clock face
---@field bodyColor table Color of the clock face
---@field borderColor table Color of the border of the clock face
---@field centerColor table Color of the center of the clock face
---@field borderWidth number Width of the border of the clock face
---@field hand1tweeneasing string Tween function for the first hand
---@field hand2tweeneasing string Tween function for the second hand
---@field hand3tweeneasing string Tween function for the third hand
---@field hand1tweeneduration number Duration of the first hand tween in seconds
---@field hand2tweeneduration number Duration of the second hand tween in seconds
---@field hand3tweeneduration number Duration of the third hand tween in seconds
---@field hand1color table Color of the first hand
---@field hand2color table Color of the second hand
---@field hand3color table Color of the third hand
---@field hand1width number Width of the first hand in pixels
---@field hand2width number Width of the second hand in pixels
---@field hand3width number Width of the third hand in pixels
---@field hand1angle number Current angle of the first hand in degrees
---@field hand2angle number Current angle of the second hand in degrees
---@field hand3angle number Current angle of the third hand in degrees
---@field hand1target number Target angle of the first hand in degrees
---@field hand2target number Target angle of the second hand in degrees
---@field hand3target number Target angle of the third hand in degrees

local tween = require("tween")
local check = require("chekc")
local clockFace = {}
clockFace.__index = clockFace


function clockFace.new(params)
	---@type ClockFace
	local c = {
		x = params.x or 0,
		y = params.y or 0,
		radius = params.radius or 50,
		bodyColor = params.bodyColor or { 1, 1, 1, 0.1 },
		centerColor = params.centerColor or { 0, 0, 0, 1 },
		borderColor = params.borderColor or { 0.2, 0.2, 0.2, 1 },
		borderWidth = params.borderWidth or 0.15,

		hand1tweeneasing = params.hand1tweeneasing or "outBounce",
		hand2tweeneasing = params.hand2tweeneasing or "outBounce",
		hand3tweeneasing = params.hand3tweeneasing or "outBounce",

		hand1tweeneduration = params.hand1tweeneduration or 0.5,
		hand2tweeneduration = params.hand2tweeneduration or 0.5,
		hand3tweeneduration = params.hand3tweeneduration or 0.5,

		hand1color = params.hand1color or { 1, 0, 0, 1 },
		hand2color = params.hand2color or { 1, 0, 0, 1 }, --{ 0, 1, 0, 1 },
		hand3color = params.hand3color or { 1, 0, 0, 1 }, --{ 0, 0, 1, 1 },

		hand1width = params.hand1width or 0.100,
		hand2width = params.hand2width or 0.100,
		hand3width = params.hand3width or 0.100,

		hand1angle = params.hand1angle or 0,
		hand2angle = params.hand2angle or 0,
		hand3angle = params.hand3angle or 0,

		hand1target = params.hand1target or 90,
		hand2target = params.hand2target or 120,
		hand3target = params.hand3target or 270,

		tweens = {},
	}

	do --[[Sanity checks]]
		local easing = check.isEasingMode
		local color = check.isColor
		local number = check.isNumber
		local positive = check.isPositiveNumber
		local tweenChecks = {
			hand1tweeneasing = c.hand1tweeneasing,
			hand2tweeneasing = c.hand2tweeneasing,
			hand3tweeneasing = c.hand3tweeneasing,
		}
		local colorChecks = {
			bodyColor = c.bodyColor,
			centerColor = c.centerColor,
			borderColor = c.borderColor,
			hand1color = c.hand1color,
			hand2color = c.hand2color,
			hand3color = c.hand3color,
		}
		local positiveChecks = {
			radius = c.radius,
			hand1width = c.hand1width,
			hand2width = c.hand2width,
			hand3width = c.hand3width,
			hand1tweeneduration = c.hand1tweeneduration,
			hand2tweeneduration = c.hand2tweeneduration,
			hand3tweeneduration = c.hand3tweeneduration,
		}
		local numberChecks = {
			x = c.x,
			y = c.y,
			hand1angle = c.hand1angle,
			hand2angle = c.hand2angle,
			hand3angle = c.hand3angle,
			hand1target = c.hand1target,
			hand2target = c.hand2target,
			hand3target = c.hand3target,
		}

		for name, value in pairs(tweenChecks) do easing(value, string.format("\"%s\" is Invalid.", name)) end
		for name, value in pairs(colorChecks) do color(value, string.format("\"%s\" is Invalid.", name)) end
		for name, value in pairs(positiveChecks) do positive(value, string.format("\"%s\" is Invalid.", name)) end
		for name, value in pairs(numberChecks) do number(value, string.format("\"%s\" is Invalid.", name)) end
	end

	do --[[Setup default tweens]]
		c.tweens = {
			hand1tween = tween.new(c.hand1tweeneduration, c, { hand1angle = c.hand1target }, c.hand1tweeneasing),
			hand2tween = tween.new(c.hand2tweeneduration, c, { hand2angle = c.hand2target }, c.hand2tweeneasing),
			hand3tween = tween.new(c.hand3tweeneduration, c, { hand3angle = c.hand3target }, c.hand3tweeneasing),
		}
	end

	return setmetatable(c, clockFace)
end

function clockFace:drawBody()
	love.graphics.setColor(self.bodyColor)
	love.graphics.circle("fill", 0, 0, self.radius)
	local lastLineWidth = love.graphics.getLineWidth()
	love.graphics.setLineWidth(self.borderWidth * self.radius)
	love.graphics.setColor(self.borderColor)
	love.graphics.circle("line", 0, 0, self.radius)
	love.graphics.setLineWidth(lastLineWidth)
end

local function drawHand(color, angle, radius, width)
	love.graphics.setColor(color)
	love.graphics.rotate(math.rad(angle))
	local x1, y1 = 0, 0 - (radius * width) / 2
	local w1, h1 = radius, radius * width
	love.graphics.rectangle("fill", x1, y1, w1, h1)
	love.graphics.rotate(-math.rad(angle))
end

function clockFace:drawHands()
	drawHand(self.hand3color, self.hand3angle, self.radius, self.hand3width)
	drawHand(self.hand2color, self.hand2angle, self.radius, self.hand2width)
	drawHand(self.hand1color, self.hand1angle, self.radius, self.hand1width)
end

function clockFace:drawPivot()
	love.graphics.setColor(self.centerColor)
	love.graphics.circle("fill", 0, 0, self.radius * 0.15)
end

function clockFace:draw()
	local lastColor = { love.graphics.getColor() }
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	self:drawBody()
	self:drawHands()
	self:drawPivot()
	--love.graphics.print(self.hand1angle .. "\n" .. self.hand1target, self.x, self.y + self.radius + 10)
	love.graphics.pop()
	love.graphics.setColor(lastColor)
end

local function shortest_path_dir(current, target)
	local diff = (target - current) % 360
	if diff > 180 then
		return -1
	elseif diff < -180 then
		return 1
	else
		return diff >= 0 and 1 or -1
	end
end

function clockFace:update(dt)
	for _, t in pairs(self.tweens) do
		t:update(dt)
	end
end

function clockFace:setTargetAngles(a, b, c)
	self.hand1target = a or self.hand1target
	self.hand2target = b or self.hand2target
	self.hand3target = c or self.hand3target

	assert(type(self.hand1target) == "number", "Invalid hand1target")
	assert(type(self.hand2target) == "number", "Invalid hand2target")
	assert(type(self.hand3target) == "number", "Invalid hand3target")

	self.tweens = {
		hand1tween = tween.new(self.hand1tweeneduration, self, { hand1angle = self.hand1target }, self.hand1tweeneasing),
		hand2tween = tween.new(self.hand2tweeneduration, self, { hand2angle = self.hand2target }, self.hand2tweeneasing),
		hand3tween = tween.new(self.hand3tweeneduration, self, { hand3angle = self.hand3target }, self.hand3tweeneasing),
	}
end

function clockFace:setCurrentAngles(a, b, c)
	self.hand1angle = a or self.hand1angle
	self.hand2angle = b or self.hand2angle
	self.hand3angle = c or self.hand3angle

	assert(type(self.hand1angle) == "number", "Invalid hand1angle")
	assert(type(self.hand2angle) == "number", "Invalid hand2angle")
	assert(type(self.hand3angle) == "number", "Invalid hand3angle")
end

function clockFace:getTargetAngles()
	return self.hand1target, self.hand2target, self.hand3target
end

function clockFace:getCurrentAngles()
	return self.hand1angle, self.hand2angle, self.hand3angle
end

return clockFace
