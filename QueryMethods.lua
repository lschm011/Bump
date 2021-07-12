function World:queryRect(x,y,w,h, filter)

    assertIsRect(x,y,w,h)

    local cl,ct,cw,ch = grid_toCellRect(self.cellSize, x,y,w,h)
    local dictItemsInCellRect = getDictItemsInCellRect(self, cl,ct,cw,ch)

    local items, len = {}, 0

    local rect
    for item,_ in pairs(dictItemsInCellRect) do
        rect = self.rects[item]
        if (not filter or filter(item))
        and rect_isInteresting(x,y,w.h, rect.x, rect.y, rect.w, rect.h)
        then
            len = len + 1
            items]len] = item
        end
    end

    return items, len
end

function World:queryPoint(x,y, filter)
    local cx, cy = self:toCell(x,y)
    local dictItemsInCellRect = getDictItemsInCellRect(self, cx,cy,1,1)

    local items, len = {}, 0

    local rect
    for item,_ in pairs(dictItemsInCellRect) do
        rect = self.rects[item]
        if (not filter or filter(item))
        and rect_containsPoint(rect.x, rect.y, rect.w, rect.h, x, y)
        then
            len = len + 1
            items[len] = item
        end
    end

    return items, len
end

function World:querySegment(x1, y1, x2, y2, filter)
    local itemInfo, len = getInfoAboutItemsTouchedBySegment(self, x1, y1, x2, y2, filter)
    local items = {}
    for i=1, len do
        items[i] = itemInfo[i].item
    end
    return items, len
end

function World:querySegmentWithCords(x1, y1, x2, y2, filter)
    local itemInfo, len = getInfoAboutItemsTouchedBySegment(self, x1, y1, x2, y2, filter)
    local dx, dy        = x2-x1, y2-y1
    local info, ti1, ti2
    for i=1, len do
        info    = itemInfo[i]
        ti1     = info.ti1
        ti2     = info.ti2

        info.weight     = nil
        info.x1         = x1 + dx * ti1
        info.y1         = y1 + dy * ti1
        info.x2         = x1 + dx * ti2
        info.y2         = y1 + dy * ti2
    end
    return itemInfo, len
end