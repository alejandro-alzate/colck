local DigitFace = require("digist")

---@class DigitDisplay
---@field digits table<integer, Digit> Array of DigitFace objects
---@field digitCount integer Number of digits in the display
---@field spacing number Horizontal spacing between digits in pixels
---@field x number X position of the display
---@field y number Y position of the display
---@field setPosition? fun(self: DigitDisplay, x: number, y: number) Sets the position of the digit display and updates all digit positions
---@field updateDigitPositions? fun(self: DigitDisplay) Updates the positions of all individual digits based on the display position and spacing
---@field setNumber? fun(self: DigitDisplay, number: integer) Sets the number to display, automatically handling digit separation and zero-padding
---@field setSpacing? fun(self: DigitDisplay, spacing: number) Sets the horizontal spacing between digits and updates their positions
---@field update? fun(self: DigitDisplay, dt: number) Updates all digit animations
---@field draw ?fun(self: DigitDisplay) Draws all digits in the display
local DigitDisplay = {}
DigitDisplay.__index = DigitDisplay

---Creates a new DigitDisplay instance
---@param digitCount integer? Number of digits to display (default: 2)
---@param spacing number? Horizontal spacing between digits in pixels (default: 50)
---@return DigitDisplay display New DigitDisplay instance
function DigitDisplay:new(digitCount, spacing)
	---@type DigitDisplay
	local obj = {
		digits = {},
		digitCount = digitCount or 2,
		spacing = spacing or 50,
		x = 0,
		y = 0
	}

	-- Create the digit faces
	for i = 1, obj.digitCount do
		obj.digits[i] = DigitFace:new()
	end

	setmetatable(obj, DigitDisplay)
	return obj
end

---Sets the position of the digit display and updates all digit positions
---@param x number X coordinate for the display
---@param y number Y coordinate for the display
function DigitDisplay:setPosition(x, y)
	self.x = x
	self.y = y
	self:updateDigitPositions()
end

---Updates the positions of all individual digits based on the display position and spacing
function DigitDisplay:updateDigitPositions()
	for i = 1, self.digitCount do
		local digit = self.digits[i]
		digit.x = self.x + (i - 1) * self.spacing
		digit.y = self.y
	end
end

---Sets the number to display, automatically handling digit separation and zero-padding
---@param number integer The number to display across all digits
function DigitDisplay:setNumber(number)
	local numStr = tostring(number)
	local strLen = string.len(numStr)

	-- Pad with zeros if number has fewer digits than display
	if strLen < self.digitCount then
		numStr = string.rep("0", self.digitCount - strLen) .. numStr
	end

	-- Set each digit
	for i = 1, self.digitCount do
		local digitChar = string.sub(numStr, i, i)
		local digitValue = tonumber(digitChar) or 0
		self.digits[i]:setTargetNumber(digitValue)
	end
end

---Sets the horizontal spacing between digits and updates their positions
---@param spacing number New spacing value in pixels
function DigitDisplay:setSpacing(spacing)
	self.spacing = spacing
	self:updateDigitPositions()
end

---Updates all digit animations
---@param dt number Delta time in seconds
function DigitDisplay:update(dt)
	for i = 1, self.digitCount do
		self.digits[i]:update(dt)
	end
end

---Draws all digits in the display
function DigitDisplay:draw()
	for i = 1, self.digitCount do
		self.digits[i]:draw()
	end
end

---Gets the current number being displayed
---@return integer number The current target number across all digits
function DigitDisplay:getNumber()
	local numStr = ""
	for i = 1, self.digitCount do
		numStr = numStr .. tostring(self.digits[i].targetNumber)
	end
	return tonumber(numStr) or 0
end

---Gets the position of the display
---@return number x, number y The x and y coordinates of the display
function DigitDisplay:getPosition()
	return self.x, self.y
end

---Gets the spacing between digits
---@return number spacing The spacing between digits in pixels
function DigitDisplay:getSpacing()
	return self.spacing
end

return DigitDisplay
