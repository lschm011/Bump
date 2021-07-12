bump.newWorld = function(cellSize)
    cellSize = cellSize or 64
    assertIsPositiveNumber(cellSize, 'cellSize')
    local world = setmetatable({
        celllSize       = cellSize
        rects           = {},
        rows            = {},
        nonEmptyCells   = {},
        responses       = {}
    }, World_mt)

    world:addResponse('touch', touch)
    world:addResponse('cross', cross)
    world:addResponse('slide', slide)
    world:addResponse('bounce', bounce)

    return world
end

bump.rect = {
    getNearestCorner                    = rect_getNearestCorner,
    getSegmentIntersectionIndices       = rect_getSegmentIntersectionIndices,
    getDiff                             = rect_getDiff,
    containsPoint                       = rect_containsPoint,
    isIntersecting                      = rect_isInteresting,
    getSquareDistance                   = rect_getSquareDistance,
    detectCollision                     = rect_detectCollision
}

bump.responses = {
    touch   = touch,
    cross   = cross,
    slide   = slide,
    bounce  = bounce
}

return bump