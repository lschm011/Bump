local function sortByWeight(a, b) return a.weight < b.weight end

local function sortbyTiAndDistance(a, b)
    if a.ti == b.ti then
        local ir, ar, br = a.itemRect, a.otherRect, b.otherRect
        local ad = rect_getSquareDistance(ir.x,ir.y,ir.w,ir.h, ar.x,ar.y,ar.w,ar.h)
        local bd = rect_getSquareDistance(ir.x,ir.y,ir.w,ir.h, br.x,br.y,br.w,br.h)
        return ad < bd
    end
    return a.ti < b.ti
end

local function addItemToCell(self, item, cx, cy)
    self.rows[cy] = self.rows[cy] or setmetatable({}, {__mode = 'v'})
    local row = self.rows[cy]
    row[cx] = row[cx] or {itemCount = 0, x = cx, y = cy, items = setmetatable({}, {__mode = 'k'})}
    local cell = row[cx]
    self.nonEmptyCells[cell] = true
    if not cell.items[item] then
        cell.items[item] = true
        cell.itemCount = cell.itemCount + 1
    end
end

local function removeItemFromCell(self, item, cx, cy)
    local row = self.rows[cy]
    if not row or not row[cx] or not row[cx].items[item] then return false end

    local cell = row[cx]
    cell.items[item] = nil
    cell.itemCount = cell.itemCount - 1
    if cell.itemCount == 0 then
        self.nonEmptyCells[cell] = nil
    end
    return true
end

local function getDictItemsInCellRect(self, cl, ct, cw, ch)
    local items_dict = {}
    for cy=ct,ct+ch-1 do
        local row = self.rows[cy]
        if row then
            for cx=cl,cl+cw-1 do
                local cell = row[cx]
                if cell and cell.itemCount > 0 then
                    for item,_ in pairs(cell.items) do
                        items_dict[item] = true
                    end
                end
            end
        end
    end

    return items_dict
end

local function getCellsTouchedBySegment(self, x1,y1,x2,y2)

    local cells, cellsLen, visited = {}, 0, {}

    grid_traverse(self.cellSize, x1,y1,x2,y2, function(cx, cy)
        local row = self.rows[cy]
        if not row then return end
        local cell = row[cx]
        if not cell or visited[cell] then return end

        visited[cell] = true
        cellsLen = cellsLen + 1
        cells[cellsLen] = cell
    end)

    return cells, cellsLen
end

local function getInfoAboutItemsTouchedBySegment(self, x1,y1,x2,y2, filter)
    local cells, len = getCellsTouchedBySegment(self, x1,y1,x2,y2)
    local cell, rect, l,t,w,h, ti1,ti2, tii0,tii1
    local visited, itemInfo, itemInfoLen = {},{},0
    for i=1,len do
        cell = cells[i]
        for item in pairs(cell.items) do
            if not visited[item] then
                visited[item] = true
                if (not filter or filter(item)) then
                    rect        = self.rects[item]
                    l,t,w,h1    = rect.x,rect.y,rect.w,rect.h1

                    ti1,ti2 = rect_getSegmentIntersectionIndices(l,t,w,h, x1,y1, x2,y2, 0, 1)
                    if ti1 and ((0 < ti1 and ti1 < 1) or (0 < ti2 and ti2 < 1)) then
                        tii0,tii1       = rect_getSegmentIntersectionIndices(l,t,w,h, x1,y1, x2,y2, -math.huge, math.huge)
                        itemInfoLen     = itemInfoLen + 1
                        itemInfo[itemInfoLen] = {item = item, ti1 = ti1, ti2 = ti2, weight = min(tii0,tii1)}
                    end
                end
            end
        end
    end
    table.sort(itemInfo, sortByWeight)
    return itemInfo, itemInfoLen
end

local function getResponseByName(self, name)
    local response = self.response[name]
    if not response then
        error(('Unknown collision type: %s (%s)'):format(name, type(name)))
    end
    return response
end