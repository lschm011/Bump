function World:add(item, x,y,w,h)
    local rect = self.rects[item]
    if rect then
        error('Item ' .. tostring(item) .. ' added to the world twice.')
    end
    assertIsRect(x,y,w,h)

    self.rects[item] = {x=x, y=y, w=w, h=h}

    local cl,ct,cw,ch = grid_toCellRect(self.cellSize, x,y,w,h)
    for cy = ct, ct+ch-1 do
        for cx = cl, cl+cw-1 do
            addItemToCell(self, item, cx, cy)
        end
    end

    return item
end

function World:remove(item)
    local x,y,w,h = self:getRect(item)

    self.rects[item] = nil
    local cl,ct,cw,ch = grid_toCellRect(self.cellSize, x,y,w,h)
    for cy = ct, ct+ch-1 do
        for cx = cl, cl+cw-1 do
            removeItemFromCell(self, item, cx, cy)
        end
    end
end

function World:update(item, x2,y2,w2,h2)
    local x1,y1,w1,h1 = self:getRect(item)
    w2,h2 = w2 or w1, h2 or h1
    assertIsRect(x2,y2,w2,h2)

    if x1 ~= x2 or y1 ~= y2 or w1 ~= w2 or h1 ~= h2 then

        local cellSize = self.cellSize
        local cl1,ct1,cw1,ch1 = grid_toCellRect(cellSize, x1,y1,w1,h1)
        local cl2,ct2,cw2,ch2 = grid_toCellRect(cellSize, x2,y2,w2,h2)

        if cl1 ~= cl2 or ct1 ~= ct2 or cw1 ~= cw2 or ch1 ~= ch2 then
                
            local cr1, cb1 = cl1+cw1-1, ct1+ch1-1
            local cr2, cb2 = cl2+cw2-1, ct2+ch2-1
            local cyOut

            for cy = ct1, cb1 do
                cyOut = cy < ct2 or cy > cb2
                for cx = cl1, cr1 do
                    if cyOut or cx < cl2 or cx > cr2 then
                        removeItemFromCell(self, item, cx, cy)
                    end
                end
            end

            for cy = ct2, cb2 do
                cyOut = cy < ct1 or cy > cb1
                for cx = cl2, cr2 do
                    if cyOut or cx < cl1 or cx > cr1 then
                        addItemToCell(self, item, cx, cy)
                    end
                end
            end
        end

        local rect = self.rects[item]
        rect.x, rect.y, rect.w, rect.h = x2,y2,w2,h2
    end
end

function World:move(item, goalX, goalY, filter)
    local actualX, actualY, cols, len = self:check(item, goalX, goalY, filter)

    self:update(item, actualX, actualY)

    return actualX, actualY, cols, len
end

function World:check(item, goalX, goalY, filter)
    filter = filter or defaultFilter

    local visited = {[item] = true}
    local visitedFilter = function(itm, other)
        if visited[other] then return false end
        return filter(itm, other)
    end

    local cols, len = {}, 0

    local x,y,w,h = self:getRect(item)

    local projected_cols, projected_len = self:project(item, x,y,w,h, goalX,goalY, visitedFilter)
    while projected_len > 0 do
        local col = projected_cols[1]
        len       = len + 1
        cols[len] = col

        visited[col.other] = true

        local response = getResponseByName(self, col.type)

        goalX, goalY, projected_cols, projected_len = response(
            self,
            col,
            x, y, w, h,
            goalX, goalY,
            visitedFilter
        )
    end

    return goalX, goalY, cols, len
end