local ClockFace = require("colck")

---@class LayoutConfig
---@field cols integer Number of columns in the digit layout
---@field rows integer Number of rows in the digit layout
---@field spacing_x number Horizontal spacing between clocks in pixels
---@field spacing_y number Vertical spacing between clocks in pixels
---@field clock_radius number Radius of each individual clock

---@class Digit
---@field x number X position of the digit display
---@field y number Y position of the digit display
---@field clocks ClockFace[] An array of ClockFace objects representing the digit's clocks
---@field targetNumber integer The target number to display on the digit (0-9)
---@field lastNumber integer The last number that was set (used for change detection)
---@field layout LayoutConfig Configuration for the digit's clock layout
---@field draw? fun(self: Digit) Draws all clocks in the digit
---@field updateAngles? fun(self: Digit) Updates the target angles for all clocks based on the current target number
---@field updatePosition? fun(self: Digit) Updates the positions of all clocks based on the digit's position and layout
---@field updateClocks? fun(self: Digit, dt: number) Updates all clock animations
---@field update? fun(self: Digit, dt: number) Updates the digit (angles, positions, and clock animations)
---@field setTargetNumber? fun(self: Digit, num: integer?) Sets the target number for the digit to display

local digit = {}
digit.__index = digit

---@enum Direction
local dir = {
	right = 0,
	down_right = 45,
	down = 90,
	down_left = 135,
	left = 180,
	up_left = 225,
	up = 270,
	up_right = 315,
}

---@type table<integer, Direction[]>
local BCD_lookup = {
	--one
	{
		dir.down_left, dir.down_left, dir.down_left,
		dir.down, dir.down, dir.down,
		dir.down_left, dir.down_left, dir.down_left,
		dir.up, dir.up, dir.down,
		dir.down_left, dir.down_left, dir.down_left,
		dir.up, dir.up, dir.up,
	},

	--two
	{
		dir.right, dir.right, dir.right,
		dir.left, dir.left, dir.down,
		dir.right, dir.right, dir.down,
		dir.up, dir.up, dir.left,
		dir.up, dir.up, dir.right,
		dir.left, dir.left, dir.left,
	},

	--three
	{
		dir.right, dir.right, dir.right,
		dir.left, dir.left, dir.down,
		dir.right, dir.right, dir.right,
		dir.left, dir.up, dir.down,
		dir.right, dir.right, dir.right,
		dir.left, dir.left, dir.up,
	},

	--four
	{
		dir.down, dir.down, dir.down,
		dir.down, dir.down, dir.down,
		dir.up, dir.up, dir.right,
		dir.left, dir.up, dir.down,
		dir.down_left, dir.down_left, dir.down_left,
		dir.up, dir.up, dir.up,
	},

	--five
	{
		dir.right, dir.right, dir.down,
		dir.left, dir.left, dir.left,
		dir.up, dir.up, dir.right,
		dir.down, dir.down, dir.left,
		dir.right, dir.right, dir.right,
		dir.left, dir.left, dir.up,
	},

	--six
	{
		dir.right, dir.right, dir.down,
		dir.left, dir.left, dir.left,
		dir.up, dir.down, dir.right,
		dir.down, dir.down, dir.left,
		dir.right, dir.right, dir.up,
		dir.left, dir.left, dir.up,
	},

	--seven
	{
		dir.right, dir.right, dir.down,
		dir.left, dir.left, dir.down,
		dir.down_left, dir.down_left, dir.down_left,
		dir.down, dir.down, dir.up,
		dir.down_left, dir.down_left, dir.down_left,
		dir.up, dir.up, dir.up,
	},

	--eight
	{
		dir.down, dir.down, dir.right,
		dir.left, dir.left, dir.down,
		dir.up, dir.down, dir.right,
		dir.up, dir.down, dir.left,
		dir.up, dir.up, dir.right,
		dir.up, dir.up, dir.left,
	},

	--nine
	{
		dir.down, dir.down, dir.right,
		dir.left, dir.left, dir.down,
		dir.up, dir.up, dir.right,
		dir.up, dir.down, dir.left,
		dir.right, dir.right, dir.right,
		dir.up, dir.up, dir.left,
	},

	--zero
	{
		dir.down, dir.down, dir.right,
		dir.left, dir.left, dir.down,
		dir.up, dir.down, dir.down,
		dir.up, dir.down, dir.down,
		dir.up, dir.up, dir.right,
		dir.up, dir.up, dir.left,
	},
}

---@class DigitParams
---@field x number? X position of the digit (default: 0)
---@field y number? Y position of the digit (default: 0)
---@field cols integer? Number of columns in layout (default: 2)
---@field rows integer? Number of rows in layout (default: 3)
---@field spacing_x number? Horizontal spacing between clocks (default: 40)
---@field spacing_y number? Vertical spacing between clocks (default: 40)
---@field clock_radius number? Radius of each clock (default: 20)

---Creates a new Digit instance with the specified parameters
---@param params DigitParams? Configuration parameters for the digit
---@return Digit digit New digit instance
function digit.new(params)
	params = params or {}
	---@type Digit
	local d = {
		x = params.x or 0,
		y = params.y or 0,
		clocks = {},
		targetNumber = 0,
		lastNumber = 1,
		-- Layout configuration
		layout = {
			cols = params.cols or 2,
			rows = params.rows or 3,
			spacing_x = params.spacing_x or 40,
			spacing_y = params.spacing_y or 40,
			clock_radius = params.clock_radius or 20,
		}
	}

	-- Create clocks based on layout configuration
	for row = 0, d.layout.rows - 1 do
		for col = 0, d.layout.cols - 1 do
			local clock_x = col * d.layout.spacing_x
			local clock_y = row * d.layout.spacing_y
			table.insert(d.clocks, ClockFace.new {
				x = clock_x,
				y = clock_y,
				radius = d.layout.clock_radius
			})
		end
	end

	return setmetatable(d, digit)
end

---Draws all clocks in the digit
function digit:draw()
	for _, clock in ipairs(self.clocks) do
		clock:draw()
	end
end

---Updates the target angles for all clocks based on the current target number
function digit:updateAngles()
	if self.targetNumber ~= self.lastNumber then
		self.lastNumber = self.targetNumber
		-- Map targetNumber to BCD_lookup index (0 maps to index 10, 1-9 map to their indices)
		local lookupIndex = self.targetNumber == 0 and 10 or self.targetNumber
		local targetAngles = BCD_lookup[lookupIndex]

		-- Unpack angles in batches of 3 for each clock
		for i = 1, 6 do
			local startIndex = (i - 1) * 3 + 1
			local angle1 = targetAngles[startIndex]
			local angle2 = targetAngles[startIndex + 1]
			local angle3 = targetAngles[startIndex + 2]

			self.clocks[i]:setTargetAngles(angle1, angle2, angle3)
		end
	end
end

---Updates the positions of all clocks based on the digit's position and layout
function digit:updatePosition()
	local clock_index = 1
	for row = 0, self.layout.rows - 1 do
		for col = 0, self.layout.cols - 1 do
			if self.clocks[clock_index] then
				self.clocks[clock_index].x = self.x + (col * self.layout.spacing_x)
				self.clocks[clock_index].y = self.y + (row * self.layout.spacing_y)
				clock_index = clock_index + 1
			end
		end
	end
end

---Updates all clock animations
---@param dt number Delta time in seconds
function digit:updateClocks(dt)
	for _, clock in ipairs(self.clocks) do
		clock:update(dt)
	end
end

---Updates the digit (angles, positions, and clock animations)
---@param dt number Delta time in seconds
function digit:update(dt)
	self:updateAngles()
	self:updatePosition()
	self:updateClocks(dt)
end

---Sets the target number for the digit to display
---@param num integer? The target number (0-9), defaults to 0 if nil
function digit:setTargetNumber(num)
	self.targetNumber = num or 0
	self:update(0)
end

return digit
