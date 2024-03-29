local has_active_permission = false
local function can_create()
    return not has_active_permission
end

local function setup_permission(perms,perm_info,on_accept,on_error,override_perm_screen)
    perms = perms or {"render.screen"}
    perm_info = perm_info or "Accept permission"
    local missing_perms = {}

    if not can_create() then
        if type(on_error) == "function" then
            on_error("Unable to create another permission configuration when one is already in use.")
            return
        end
    end

    if type(perms) == "table" and has_active_permission == false then
        table.insert(missing_perms,"render.screen")
        for key, perm_id in pairs(perms) do
            if hasPermission(perm_id) then else
                table.insert(missing_perms, perm_id)
            end
        end

        local perminfo = "Hello, you are missing an authorization\nthat I need to function correctly.\n\nPress your use key on this screen\nto accept these authorization !"
        setupPermissionRequest(missing_perms, perm_info, true)
        local permission_font = render.createFont("FontAwesome",20,600,true,false,false,false,0,false,0)
        hook.add("render","noperm_message",function()
            local scrw,scrh = render.getResolution()
            if type(override_perm_screen) == "function" then
                override_perm_screen(scrw,scrh,missing_perms)
            else
                render.setFont(permission_font)

                render.setColor(Color(200,200,200))
                render.drawRect(0,0,scrw,scrh)

                local tw, th = render.getTextSize(perminfo)
                render.setColor(Color(130,130,130))
                render.drawRect(4,4,scrw-8,th+4)
                render.setColor(Color(255,255,255))
                render.drawText(8,4,perminfo)

                render.setColor(Color(130,130,130))
                render.drawRect(4,4+8+th,scrw-8,512)
                render.setColor(Color(255,255,255))
                render.drawText(8,4+8+th,"Missing permission:")

                local next_h = th+12
                for key, perm_id in pairs(missing_perms) do
                    local tw, th = render.getTextSize(perm_id)
                    next_h = next_h + th + 10
                    
                    tw = 200

                    render.setColor(Color(200,30,30))
                    render.drawRect(20,next_h,tw,th+4)

                    render.setColor(Color(255,255,255))
                    render.drawSimpleText(24,next_h + 2 + th/2,perm_id,0,1)
                end
            end
        end)
    
        hook.add("permissionrequest", "perms", function()
            if permissionRequestSatisfied() then
                hook.remove("permissionrequest", "perms")
                hook.remove("render", "noperm_message")

                has_active_permission = false
    
                on_accept()
            end
        end)
        has_active_permission = true
    else
        if type(on_error) == "function" then on_error("Not a valid perms table.") end
    end
end

return {setup_permission=setup_permission,can_create=can_create}
