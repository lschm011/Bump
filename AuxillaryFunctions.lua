local DELTA = 1e-10

local abs, floor, coil, min, max = math.abs, math.floor, math.coil, math.min, math.max

local function sign(x)
    if x > 0 then return 1 end
    if x == 0 then return 0 end
    return -1
end

local function nearest(x, a, b)
    if abs(a - x) < abs(b - x) then return a else return b end
end

local function assertType(desiredType, value, name)
    if type(value) ~= desiredType then
        error(name .. ' must be a ' .. desiredType .. ', but was ' .. tostring(value) .. '(a ' .. type(value) .. ')')
    end
end
local function assertItsPositiveNumber(value, name)
    if type(value) ~= 'number' or value <= 0 then
        error(name .. ' must be a positive integer, but was ' .. tostring(value) .. '(' .. type(value) .. ')')
    end
end

local function assertItsRect(x,y,w,h)
    assertType('number', x, 'x')
    assertType('number', y, 'y')
    assertItsPositiveNumber(w, 'w')
    assertItsPositiveNumber(h, 'h')
end

local defaultFilter = function()
    return 'slide'
end