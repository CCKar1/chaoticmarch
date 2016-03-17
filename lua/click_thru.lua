log("Loaded CACOPHONIC MARCH")
-- some required types
ORIENTATION_TYPE = { 
    UNKNOWN = 0,
    PORTRAIT = 1,
    PORTRAIT_UPSIDE_DOWN = 2,
    LANDSCAPE_LEFT = 3,
    LANDSCAPE_RIGHT = 4
}

-- some required functions
function click_button(button)
    local x = button["x"] + math.floor((button["width"]/2))
    local y = button["y"] + math.floor((button["height"]/2))

    touchDown(0, x, y)
    usleep(100000)
    touchUp(0, x, y)
end

-- do we continue?
allowedBundles = {}
allowedBundles["com.highaltitudehacks.dvia"] = 1

bundle_id = getBundleID();

if(allowedBundles[bundle_id] == nil) then
    -- we don't want to proceed
    return
end

-- execute user files:
base_path = "/var/root/lua/"

log("Executing user scripts in " .. bundle_id)

dofile(base_path .. "click_first_button.lua")