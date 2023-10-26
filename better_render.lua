
//better render lib
// by AstalNeker

local polyBuffer = {} //to reduce lag

render = table.copy(render)
math = table.copy(math)

render.drawRoundedBox2 = function(r1,r2,r3,r4,x,y,w,h,segments)
    r1 = r1 or h/2
    r2 = r2 or h/2
    r3 = r3 or h/2
    r4 = r4 or h/2
    x = x or 0
    y = y or 0
    w = w or 150
    h = h or 80
    segments = segments or 14

    local id = "drbox2"..r1.."_"..r2.."_"..r3.."_"..r4.."_"..x.."_"..y.."_"..w.."_"..h.."_"..segments
    if not polyBuffer[id] then
        local roundedBox = {}
    
        --Setup max radius depends of size
        if r1 > h/2 then r1 = h/2 end
        if r1 > w/2 then r1 = w/2 end
        if r2 > h/2 then r2 = h/2 end
        if r2 > w/2 then r2 = w/2 end
        if r3 > h/2 then r2 = h/2 end
        if r3 > w/2 then r3 = w/2 end
        if r4 > h/2 then r4 = h/2 end
        if r4 > w/2 then r4 = w/2 end
    
        --Draw top left border
        for i=0, segments do
            local t = (i/segments) * (math.pi/2)
            table.insert(roundedBox,{x=x + r1 - math.cos(t) * r1,y=y + r1 - math.sin(t) * r1})
        end

        --Draw top right border
        for i=0, segments do
            local t = math.pi/2 + (i/segments) * (math.pi/2)
            table.insert(roundedBox,{x=x + w - r2 - math.cos(t) * r2,y=y + r2 - math.sin(t) * r2})
        end

        --Draw bottom right border
        for i=0, segments do
            local t = math.pi + (i/segments) * (math.pi/2)
            table.insert(roundedBox,{x=x + w - r3 - math.cos(t) * r3,y=y + h - r3 - math.sin(t) * r3})
        end
            
        --Draw bottom left border
        for i=0, segments do
            local t = math.pi*1.5 + (i/segments) * (math.pi/2)
            table.insert(roundedBox,{x=x + r4 - math.cos(t) * r4,y=y + h - r4 - math.sin(t) * r4})
        end

        polyBuffer[id] = roundedBox
    end

    render.drawPoly(polyBuffer[id]) 
end

render.texturedCircle = function(x,y,w,h,segments)
    x = x or 0
    y = y or 0
    rx = w or h
    ry = h or w
    segments = segments or 14

    local id = "drfcircle"..x.."_"..y.."_"..rx.."_"..ry.."_"..segments
    if not polyBuffer[id] then
        local circle = {}
        for i=0, segments, 1 do
            local sin, cos = math.sin(math.rad(45) + math.rad((i/segments)*-360)), math.cos(math.rad(45) + math.rad((i/segments)*-360))
            local data = {
                x = (sin*rx)+x,
                y = (cos*ry)+y,
                u = (sin*0.5)+0.5,
                v = (cos*0.5)+0.5
            }
            table.insert(circle,data)
        end
        polyBuffer[id] = circle
    end

    render.drawPoly(polyBuffer[id])
end

render.drawPolyLine = function(tbl)
    tbl = tbl or {
        {x=0,y=0},
        {x=50,y=0},
        {x=30,y=70},
    }
    
    local lx,ly = tbl[1].x, tbl[1].y
    for i=1, #tbl+1 do
        if i >= #tbl+1 then
            x = tbl[1].x
            y = tbl[1].y
        else
            x = tbl[i].x
            y = tbl[i].y
        end
        render.drawLine(x,y,lx,ly)
        lx = x
        ly = y
    end
end


render.drawLayoutText = function(x,y,layout_width,txt)
    
    local splited_text = string.split(txt," ")
    local next_width, next_height = 0, 0
    for _, t in pairs(splited_text) do
        local add_width, add_height = render.drawSimpleText(x+next_width, y+next_height, t .. " ", 0, 0)        
        next_width = next_width + add_width
        
        local fix_width, _ = render.getTextSize((splited_text[_+1] or "") .. " ")
        if next_width+fix_width > layout_width then
            next_height = next_height + add_height
            next_width = 0
        end
    end

    local _, fix_height = render.getTextSize(" ")
    next_height = next_height + fix_height

    return layout_width, next_height
    

    --Buged doesn't show end of text
    --[[
    local new_line = ""
    local final_txt = ""
    for i=1, #txt do
        new_line = new_line .. txt[i]

        local w,_ = render.getTextSize(new_line)
        local fix_w,_ = render.getTextSize(txt[i+1] or "")
        if w+fix_w > layout_width then
            final_txt = final_txt .. new_line .. "\n"
            new_line = ""
        end
    end

    final_txt = string.sub(final_txt,0,#final_txt-2)
    render.drawText(x,y,final_txt)
    return render.getTextSize(final_txt)
    ]]
end


render.arc = function(x,y,size,thickness,startAng,arcAng,detail)
    local innerRadius = size/2-thickness
    local lastPoint = {x = x + (size/2) * math.cos((startAng/360) * (math.pi*2)), y = y + (size/2) * math.sin((startAng/360) * (math.pi*2))}
    local lastInnerPoint = {x = x + innerRadius * math.cos((startAng/360) * (math.pi*2)), y = y + innerRadius * math.sin((startAng/360) * (math.pi*2))}
    for i=0, detail do
        local point = {x = x + (size/2) * math.cos((startAng/360) * (math.pi*2) + (i/detail) * (arcAng/360) * (math.pi*2)), y = y + (size/2) * math.sin((startAng/360) * (math.pi*2) + (i/detail) * (arcAng/360) * (math.pi*2))}
        local innerPoint = {x = x + innerRadius * math.cos((startAng/360) * (math.pi*2) + (i/detail) * (arcAng/360) * (math.pi*2)), y = y + innerRadius * math.sin((startAng/360) * (math.pi*2) + (i/detail) * (arcAng/360) * (math.pi*2))}
                
        render.drawPoly({lastPoint,point,innerPoint,lastInnerPoint})
                
        lastPoint = point
        lastInnerPoint = innerPoint
    end
    render.setMaterial()
end

render.star = function(x,y,size,add_ang)
    local number_of_spikes = 10
    local angle = math.pi * 2 / number_of_spikes
    local star = {}
    local radius = size
    for i=0, number_of_spikes do
        local x2 = radius * math.cos(add_ang + angle * i)
        local y2 = radius * math.sin(add_ang + angle * i)
        star[i] = {x=x + x2,y=y + y2}
        radius = radius == size and size/2 or size
    end
    render.setMaterial()
    render.drawPoly(star)
end

//gwen code basically
render.createTextureBorder = function(_xo, _yo, _wo, _ho, l, t, r, b)
    return function(x, y, w, h, tex)
        local _x = _xo / tex:getWidth()
        local _y = _yo / tex:getHeight()
        local _w = _wo / tex:getWidth()
        local _h = _ho / tex:getHeight()
            
        local left = math.min(l, math.ceil(w / 2))
        local right = math.min(r, math.floor(w / 2))
        local top = math.min(t, math.ceil(h / 2))
        local bottom = math.min(b, math.floor(h / 2))
            
        local _l = left / tex:getWidth()
        local _t = top / tex:getHeight()
        local _r = right / tex:getWidth()
        local _b = bottom / tex:getHeight()

        render.setMaterial(tex)
        render.setColor(Color(255,255,255))
            
        //top
        render.drawTexturedRectUV( x, y, left, top, _x, _y, _x + _l, _y + _t )
        render.drawTexturedRectUV( x + left, y, w - left - right, top, _x + _l, _y, _x + _w - _r, _y + _t )
        render.drawTexturedRectUV( x + w - right, y, right, top, _x + _w - _r, _y, _x + _w, _y + _t )
            
        //middle
        render.drawTexturedRectUV( x, y + top, left, h - top - bottom, _x, _y + _t, _x + _l, _y + _h - _b )
        render.drawTexturedRectUV( x + left, y + top, w - left - right, h - top - bottom, _x + _l, _y + _t, _x + _w - _r, _y + _h - _b )
        render.drawTexturedRectUV( x + w - right, y + top, right, h - top - bottom, _x + _w - _r, _y + _t, _x + _w, _y + _h - _b )
            
        //bottom
        render.drawTexturedRectUV( x, y + h - bottom, left, bottom, _x, _y + _h - _b, _x + _l, _y + _h )
        render.drawTexturedRectUV( x + left, y + h - bottom, w - left - right, bottom, _x + _l, _y + _h - _b, _x + _w - _r, _y + _h )
        render.drawTexturedRectUV( x + w - right, y + h - bottom, right, bottom, _x + _w - _r, _y + _h - _b, _x + _w, _y + _h )
    end
end

render.createTextureNormal = function(_xo, _yo, _wo, _ho)
    return function(x, y, w, h, tex)
        local _x = _xo / tex:getWidth()
        local _y = _yo / tex:getHeight()
        local _w = _wo / tex:getWidth()
        local _h = _ho / tex:getHeight()

        render.setMaterial(tex)
        render.setColor(Color(255,255,255))

        render.drawTexturedRectUV( x, y, w, h, _x, _y, _x + _w, _y + _h )
    end
end

/* EXPERIMENTAL but it's should work */
function math.linear_interpolate(color1, color2, progress)
    local r = math.floor(color1.r + (color2.r - color1.r) * progress)
    local g = math.floor(color1.g + (color2.g - color1.g) * progress)
    local b = math.floor(color1.b + (color2.b - color1.b) * progress)
    local a = math.floor(color1.a + (color2.a - color1.a) * progress)
    return Color(r,g,b,a)
end

function math.generate_gradient(colors, steps)
    local gradient = {}
    for i=1,#colors-1 do
        for j=0,steps-1 do
            local progress = j / (steps-1)
            local color = math.linear_interpolate(colors[i], colors[i+1], progress)
            table.insert(gradient, color)
        end
    end
    table.insert(gradient, colors[#colors])
    return gradient
end

return render,math
