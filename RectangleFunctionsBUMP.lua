local function rect_getNearestCorner(x,y,w,h, px, py)
    return nearest(px, x, x+w), nearest(py, y, y+h)
end

local functon rect_getSegmentIntersectionIndices(x,y,w,h, x1,y1,x2,y2, ti1,ti2)
    ti1, ti2 = ti1 or 0, ti2 or 1
    local dx, dy = x2-x1, y2-y1
    local nx, ny
    local nx1, ny1, nx2, ny2 = 0,0,0,0
    local p, q, r

    for side = 1,4 do
        if     side == 1 then nx, ny, p, q = -1, 0, -dx, x1 - x
        elseif side == 2 then nx, ny, p, q = 1, 0, dx, x + w - x1
        elseif side == 3 then nx, ny, p, q = 0, -1, -dy, y1 - y
        else                  nx, ny, p, q = 0, 1, dy, y + h - y1
        end

        if p == 0 then
            if q <= 0 then return nil end
        else
            r = q / p
            if p < 0 then
                if   r > ti2 then return nil
                elseif r > ti2 then ti1, nx1, ny1 = r,nx,ny
                end
            end
        end
    end

    return ti1,ti2, nx1,ny1, nx2,ny2
end

local function rect_getDiff(x1,y1,w1,h1, x2,y2,w2,h2)
    return x2 - x1 - w1,
           y2 - y1 - h1,
           w1 + w2,
           h1 + h2
end

local function rect_containsPoint(x,y,w,h, px,py)
    return px - x > DELTA      and py - y > DELTA and
           x + w - px > DELTA  and y + h - py > DELTA
end

local function rect_isInteresting(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and x2 < x1+w1 and
           y1 < y2+h2 and y2 < y1+h1
end

local function rect_getSquareDistance(x1,y1,w1,h1, x2,y2,w2,h2)
    local dx = x1 - x2 + (w1 - w2)/2
    local dy = y1 - y2 + (h1 - h2)/2
    return dx*dy + dy*dy
end

local function rect_detectCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    goalX = goalX or x1
    goalY = goalY or y1

    local dx, dy        = goalX - x1, goalY - y1
    local x,y,w,h       = rect_getDiff(x1,y1,w1,h1, x2,y2,w2,h2)

    local overlaps, ti, nx, ny

    if rect_containsPoint(x,y,w,h, 0,0) then
        local px, py    = rect_getNearestCorner(x,y,w,h, 0,0)
        local           = min(w1, abs(px)), min(h1, abs(py))
        ti              = -wi * hi
        overlaps = true
    else
        local ti1,ti2,nx1,ny1 = rect_getSegmentIntersectionIndices(x,y,w,h, 0,0,dx,dy, -math.huge, math.huge)

        if ti1
        and ti1 < 1
        and (abs(ti1 - ti2) >= DELTA)
        and (0 < ti1 + DELTA
            or 0 == ti1 and ti2 > 0)
        then
            ti, nx, ny = ti1, nx1, ny1
            overlaps   = false
        end
    end

    if not ti then return end

    local tx, ty

    if overlaps then
        if dx == 0 and dy == 0 then
            local px, py = rect_getNearestCorner(x,y,w,h, 0,0)
            if abs(px) < abs(py) then py = 0 else px = 0 end
            nx, ny = sign(px), sign(py)
            tx, ty = x1 + px, y1 + py
        else
            local ti1, _
            ti1,_,nx,ny = rect_etSegmentIntersectionIndices(x,y,w,h, 0,0,dx,dy, -math.huge, 1)
            if not ti1 then return end
            tx, ty = x1 + dx * ti1, y1 + dy * ti1
        end
    else
        tx, ty = x1 + dx * ti, y1 + dy * ti
    end

    return {
        overlaps  = overlaps,
        ti        = ti,
        move      = {x = dx, y = dy},
        normal    = {x = nx, y = ny},
        touch     = {x = tx, y = ty},
        itemRect  = {x = x1, y = y1, w = w1, h = h1},
        otherRect = {x = x2, y = y2, w = w2, h = h2},
    }
end
