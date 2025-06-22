local UUIDLIST = {}
local UUIDCHAR = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

local function uuid(length,compose_length)
    length = length or 6
    compose_length = compose_length or 4
    local uuidstr = ""

    for i=1, length do
        local compose_id = ""
        for i=1, compose_length do
            compose_id = compose_id .. "" .. UUIDCHAR[math.random(1,#UUIDCHAR)]
        end
        uuidstr = uuidstr .. compose_id .. "-"
    end
    uuidstr = uuidstr:sub(1,#uuidstr-1)

    --Regenerate if already exist
    if UUIDLIST[uuidstr] then
        return uuid()
    end
    return uuidstr
end

return {uuid=uuid}