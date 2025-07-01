love.graphics.setDefaultFilter("nearest", "nearest")
local twelveHourFormat = true
local DigitDisplay = require("digistdisplya")
local clockCanvas = love.graphics.newCanvas(640, 200)
local hoursDisplay = DigitDisplay:new(2, 80)
local minutesDisplay = DigitDisplay:new(2, 80)
local secondsDisplay = DigitDisplay:new(2, 80)

local lastEpoch = os.time()

local function updateClock()
	local currentTime = os.date("*t")

	hoursDisplay:setNumber(tonumber(twelveHourFormat and currentTime.hour % 12 or currentTime.hour) or 0)
	minutesDisplay:setNumber(tonumber(currentTime.min) or 0)
	secondsDisplay:setNumber(tonumber(currentTime.sec) or 0)
end

local function updateCanvas()
	love.graphics.setCanvas(clockCanvas)
	love.graphics.clear()
	hoursDisplay:draw()
	minutesDisplay:draw()
	secondsDisplay:draw()
	love.graphics.setCanvas()
end

function love.load()
	hoursDisplay:setPosition(60, 60)
	minutesDisplay:setPosition(260, 60)
	secondsDisplay:setPosition(460, 60)
end

function love.update(dt)
	local currentEpoch = os.time()
	if currentEpoch ~= lastEpoch then
		lastEpoch = currentEpoch
		updateClock()
	end

	hoursDisplay:update(dt)
	minutesDisplay:update(dt)
	secondsDisplay:update(dt)

	updateCanvas()
end

local function drawClockCanvas()
	local vw, vh = love.graphics.getDimensions()
	local cw, ch = clockCanvas:getDimensions()
	local size = math.min(vw / cw, vh / ch)
	local sx, sy = size, size
	love.graphics.draw(clockCanvas, vw / 2, vh / 2, 0, sx, sy, cw / 2, ch / 2)
end

local function drawMouseCrosshair()
	local vw, vh = love.graphics.getDimensions()
	local mx, my = love.mouse.getPosition()

	love.graphics.print(mx .. ", " .. my)
	love.graphics.line(0, my, vw, my)
	love.graphics.line(mx, 0, mx, vh)
end

function love.draw()
	--love.graphics.reset()
	drawClockCanvas()
end
