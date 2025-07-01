local check = {}
local easingModes = {
	"linear", "inQuad", "outQuad", "inOutQuad", "outInQuad",
	"inCubic", "outCubic", "inOutCubic", "outInCubic",
	"inQuart", "outQuart", "inOutQuart", "outInQuart",
	"inQuint", "outQuint", "inOutQuint", "outInQuint",
	"inSine", "outSine", "inOutSine", "outInSine",
	"inExpo", "outExpo", "inOutExpo", "outInExpo",
	"inCirc", "outCirc", "inOutCirc", "outInCirc",
	"inElastic", "outElastic", "inOutElastic",
	"outInElastic", "inBack", "outBack", "inOutBack",
	"outInBack", "inBounce", "outBounce", "inOutBounce",
	"outInBounce",
}

function check.isNumber(value, errorMessage)
	assert(type(value) == string.format("number", "%s Is not a number.\n%s", tostring(value), errorMessage))
end

function check.isColor(value, errorMessage)
	assert(
		(type(value) == "table") and
		(type(value[1]) == "number") and
		(type(value[2]) == "number") and
		(type(value[3]) == "number") and
		(
			(type(value[4]) == "number") or
			(type(value[4]) == "nil")
		),
		"Invalid color value.\n" .. errorMessage
	)

	for i, v in pairs(value) do
		local errorTitle = "Color value range check failed.\n"
		local overflow = string.format(
			"%sValue over the range at position %d, The value was: %.8f.\n%s",
			errorTitle, i, v, errorMessage
		)
		local underflow = string.format(
			"%sValue under the range at position %d, The value was: %.8f.\n%s",
			errorTitle, i, v, errorMessage
		)
		assert(v <= 1, overflow)
		assert(v >= 0, underflow)
	end
end

function check.isEasingMode(value, errorMessage)
	for _, mode in ipairs(easingModes) do
		if value == mode then
			return true
		end
	end
	error("Invalid easing mode.\n" .. errorMessage)
end

function check.isPositiveNumber(value, errorMessage)
	check.isNumber(value, errorMessage)
	assert(value > 0, string.format("Number must be positive.\n%s", errorMessage))
end

return check
