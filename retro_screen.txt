--@name Retro screen

--[[
Trasnform any screen into an retro computer screen

To use

--@include https://raw.githubusercontent.com/NekerSqu4w/my-starfall-library/main/retro_screen.txt as retro_screen.txt
local retro_screen = require("retro_screen.txt")
    
retro_screen.push()

draw your thing here into
render.drawRect(256,256,128,340)

retro_screen.pop()


retro_screen.draw(256,256,true,true) --Draw the final screen
]]

local retro = {}

retro.target = "retro_rdt"
retro.target_temp = "retro_rdt_buffer"
retro.final_target = "retro_rdt_finalcomp"
retro.w = 64
retro.h = 64

retro.x = -1
retro.y = -1

render.createRenderTarget(retro.target)
render.createRenderTarget(retro.target_temp)
render.createRenderTarget(retro.final_target)

function push_retro(do_clear,clr)
    do_clear = do_clear or true
    if do_clear then clr = clr or Color(0,0,0,255) end
    render.selectRenderTarget(retro.target)
    if do_clear then render.clear(clr) end
end


function pop_retro()
    render.selectRenderTarget(nil)
end


function draw_retro(w,h,antialias)
    local scr_w, scr_h = 512,512
    retro.w = w
    retro.h = h

    local scl1 = (scr_w*2)/w
    local scl2 = (scr_h*2)/h


    //do first process to scale to lower res
    render.setFilterMag(2)
    render.setFilterMin(2)
    if antialias == false then
        render.setFilterMag(1)
        render.setFilterMin(1)
    end
    render.selectRenderTarget(retro.target_temp)
    render.setColor(Color(255,255,255))
    render.setRenderTargetTexture(retro.target)
    render.drawTexturedRect(0,0,retro.w+1,retro.h+1)
    render.selectRenderTarget(nil)


    //do rescaling because the lastest target was to a lower res
    render.selectRenderTarget(retro.final_target)
    render.setColor(Color(255,255,255))
    render.setRenderTargetTexture(retro.target_temp)
    render.drawTexturedRect(0,0,1024*scl1,1024*scl2)
    render.selectRenderTarget(nil)


    //draw the new target 1024x1024
    render.setColor(Color(255,255,255))
    render.setRenderTargetTexture(retro.final_target)
    render.drawTexturedRect(0,0,1024,1024)

    render.setFilterMag(2)
    render.setFilterMin(2)
end

function get_target()
    return {final_buffer=retro.final_target,second_buffer=retro.target_temp,first_buffer=retro.target}
end


return {
    pop = pop_retro,
    push = push_retro,
    draw = draw_retro,
    get_target = get_target
}