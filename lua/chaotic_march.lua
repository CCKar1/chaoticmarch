-- (c) Synack Inc 2016

log("Loaded CHAOTICMARCH")

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
allowedBundles["com.apple.iBooks"] = 1
allowedBundles["com.hdsupply.hdsupplyfm"] = 1
allowedBundles["com.doubleyouapps.mauitop10"] = 1
allowedBundles["com.ebay.iphone"] = 1
allowedBundles["com.intel.ark"] = 1

bundle_id = getBundleID();

if(bundle_id == nil or allowedBundles[bundle_id] == nil) then
    -- we don't want to proceed
    if(bundle_id == nil) then
        bundle_id = "nil"
    end
    
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
script_files = files_ls(base_path .. bundle_id .. "*.lua")
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

