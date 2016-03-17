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

-- check if the file exists
function file_exists(name)
    if type(name) ~= "string" then 
        return false 
    end
    
    return os.rename(name,name) and true or false
end

-- list files from a directory.
function files_ls(glob)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('/bin/ls -A ' .. glob .. '')

    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    
    pfile:close()
    
    return t
end

-- do we continue?
-- CONFIGURABLE: Enter bundles where to run
allowedBundles = {}
allowedBundles["com.highaltitudehacks.dvia"] = 1
allowedBundles["com.gs.pwm.external"] = 1

bundle_id = getBundleID();

if(allowedBundles[bundle_id] == nil) then
    -- we don't want to proceed
    log("Not running in: " .. bundle_id)

    return
end

-- CONFIGURABLE: execute user files
base_path = "/var/root/lua/"

-- execute the scripts
log("Executing user scripts in " .. bundle_id)

-- run general scripts
script_files = files_ls(base_path .. "pre_all*.lua")
for index, file in pairs(script_files) do
    log("Running script: " .. file)

    dofile(file)
end

-- run specific scripts
script_files = files_ls(base_path .. bundle_id .. "*.lua ")
for index, file in pairs(script_files) do
    log("Running script: " .. file)

    dofile(file)
end

-- run general scripts
script_files = files_ls(base_path .. "post_all*.lua")
for index, file in pairs(script_files) do
    log("Running script: " .. file)

    dofile(file)
end

