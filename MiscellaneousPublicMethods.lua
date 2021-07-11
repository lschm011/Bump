function World:addResponseByName(name, response)
    self.responses[name] = response
end

function World:project(item, x,y,w,h, goalX, goalY, filter)
    assertIsRect(x,y,w,h)

    goalX = goalX or x
    goalY = goalY or y
    filter = filter or defaultFilter

    local collisions, len = {}, 0

    local visited = {}
    if item ~= nil then visited[item] = true end

    local tl, tt = min(goalX, x),       min(goalY, y)
    local tr, tb = max(goalX + w, x+w), max(goalY + h, y+h)
    local tw, th = tr-tl, tb-tt

    local cl, ct, cw, ch = grid_toCellRect(self.cellSize, tl,tt,tw,th)

    local dictItemsInCellRect = getDictItemsInCellRect(self, cl,ct,cw,ch)

    for other,_ in pairs(dictItemsInCellRect) do
        if not visited[other] then
            visited[other] = true

            local responseName = filter(item, other)
            if responseName then
                local ox,oy,ow,oh   = self:getRect(other)
                local col           = rect_detectCollision(x,y,w,h, ox,oy,ow,oh, goalX, goalY)

                if col then
                    col.other   = other
                    col.item    = item
                    col.type    = responseName

                    len = len + 1
                    collisions[len] = col
                end
            end
        end
    end

    table.sort(collisions, sortByTiAndDistance)

    return collisions, len
end

function World:hasItem(item)
    return not not self.rects[item]
end

function World:getItems()
    local items, len = {}, 0
    for item,_ in pairs(self.rects) do
        len = len + 1
        items[len] = item
    end

    function World:countItems()
        local len = 0
        for _ in pairs(self.rects) do len = len + 1 end
        return len
    end

    function World:getRect(item)
        local rect = self.rects[item]
        if not rect then
            error('Item ' .. tostring(item) .. ' must be added to the world before getting its rect. Use world:add(item, x,y,w,h) to add it first.')
        end
        return rect.x, rect.y, rect.w, rect.h
    end

    function World:toWorld(cx, cy)
        return grid_toWorld(self.cellSize, cx, cy)
    end

    function World:toCell(x, y)
        return grid_toCell(self.cellSize, x, y)
    end