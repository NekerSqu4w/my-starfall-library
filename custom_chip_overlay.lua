if CLIENT then
    local overlay_title = render.createFont("Roboto",75,700,true)
    local overlay_author = render.createFont("Roboto",55,400,true)
    local overlay_status = render.createFont("Roboto",65,400,true)
    
    render.createRenderTarget("custom_chip_overlay")
    render.setChipOverlay("custom_chip_overlay")
    
    
    local default_icon = material.createFromImage("radon/starfall2.png", "")
    local default_global_color = Color(68, 202, 229)
    local default_global_color_dark = Color(68 / 8, 202 / 8, 229 / 8)
    
    
    local padding = 30
    local iconSize = 130
    local textX = padding + iconSize + 24
    local textY = padding
    local barStartY = padding + iconSize + 70
    
    local sv_usage = 0
    local sv_max_usage = 1
    local cl_usage = 0
    local cl_max_usage = cpuMax()
    
    local use_icon
    local use_global_color
    local use_global_color_dark
    function set_icon(mat) use_icon = mat end
    function set_global_color(color)
        use_global_color = color
        use_global_color_dark = (color / 8):setA(255)
    end
    
    local function drawStatusBar(label, valueText, fillPercent, fillColor, offsetY, barWidth)
        render.setRGBA(238, 238, 238, 255)
        render.drawSimpleText(padding + 15, offsetY, label .. ": " .. valueText)
        
        render.setColor(use_global_color_dark or default_global_color_dark)
        render.drawRectFast(padding, 70 + offsetY, barWidth, padding)
        
        local fillW = barWidth * fillPercent
        render.setColor(fillColor)
        render.drawRectFast(padding, 70 + offsetY, fillW, padding)
    end
    
    local function render_overlay(x,y,w,h)
        cl_usage_smooth = math.lerp(timer.frametime() * 25, cl_usage_smooth or 0, cl_usage)
        sv_usage_smooth = math.lerp(timer.frametime() * 25, sv_usage_smooth or 0, sv_usage)
        
        local m = Matrix()
        m:translate(Vector(x, y))
        render.pushMatrix(m)
        
        
        
        render.setColor(use_global_color or default_global_color)
        render.drawRoundedBox(42, 0, 0, w, h)
        
        render.setRGBA(51, 54, 64, 255)
        render.drawRoundedBox(42 - 4, 4, 4, w - 8, h - 8)
        
        render.setMaterial(use_icon or default_icon)
        if use_icon then render.setRGBA(255, 255, 255, 255) else render.setColor(use_global_color or default_global_color) end
        render.drawTexturedRect(padding, padding, iconSize, iconSize)
        
        
        
        render.setFont(overlay_title)
        render.setRGBA(238, 238, 238, 255)
        render.drawSimpleText(textX, textY, chip():getChipName())
        
        render.setFont(overlay_author)
        render.setRGBA(157, 165, 171, 255)
        render.drawSimpleText(textX, textY + 80, "by: " .. chip():getChipAuthor())
        
        
        render.setFont(overlay_status)
        
        local cl_ratio = math.clamp(cl_usage_smooth / cl_max_usage, 0, 1)
        local sv_ratio = math.clamp(sv_usage_smooth / sv_max_usage, 0, 1)
        
        drawStatusBar("Client", string.format("%0i us (%.1f%%)", cl_usage_smooth * 1000000, cl_ratio * 100), cl_ratio, cl_ratio > 0.9 and Color(229, 68, 68) or (use_global_color or default_global_color), barStartY, w - padding * 2)
        drawStatusBar("Server", string.format("%0i us (%.1f%%)", sv_usage_smooth * 1000000, sv_ratio * 100), sv_ratio, sv_ratio > 0.9 and Color(229, 68, 68) or (use_global_color or default_global_color), barStartY + 140, w - padding * 2)
        
        render.popMatrix()
    end
    
    local function update_overlay()
        hook.add("RenderOffscreen", "renderchip_overlay", function()
            render.selectRenderTarget("custom_chip_overlay")
            render.clearRGBA(0,0,0,0)
            
            render_overlay(0,1024 - 600,1024,500)
            
            render.selectRenderTarget()
            render.setFont(render.getDefaultFont()) // fix font
			
            hook.remove("RenderOffscreen", "renderchip_overlay")
        end)
    end
    
    net.start("custom_chip_overlay_get_max_usage")
    net.send()
    
    net.receive("custom_chip_overlay_retrieve_max_usage", function() sv_max_usage = net.readFloat() end)
    net.receive("custom_chip_overlay_retrieve_usage", function()
        sv_usage = net.readFloat()
        cl_usage = cpuAverage()
        update_overlay()
    end)
    
    return {
        set_icon = set_icon,
        set_global_color = set_global_color
    }
end

if SERVER then
    net.receive("custom_chip_overlay_get_max_usage", function()
        net.start("custom_chip_overlay_retrieve_max_usage")
        net.writeFloat(cpuMax())
        net.send()
    end)
    
    timer.create("custom_chip_overlay_usage_loop", 0.1, 0, function()
        net.start("custom_chip_overlay_retrieve_usage")
        net.writeFloat(cpuAverage())
        net.send()
    end)
end