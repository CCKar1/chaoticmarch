-- (c) Synack Inc 2016

-- some required types
ORIENTATION_TYPE = { 
    UNKNOWN = 0,
    PORTRAIT = 1,
    PORTRAIT_UPSIDE_DOWN = 2,
    LANDSCAPE_LEFT = 3,
    LANDSCAPE_RIGHT = 4
}

function screen_press(x, y)
    local cmd = '/usr/bin/stouch touch ' .. tostring(x) .. ' ' .. tostring(y)
    log(cmd)
    
    local pfile = io.popen(cmd)

    for line in pfile:lines() do
    end
    
    pfile:close()
end

touchNum = 0

-- some required functions
function click_button(button)
    local x = button["x"] + math.floor((button["width"]/2))
    local y = button["y"] + math.floor((button["height"]/2))

    showCircle(0, x, y, 20);

    touchNum = (touchNum + 1) % 9

    touchDown(touchNum, x, y)
    usleep(83410.29)
    touchUp(touchNum, x, y)

    hideCircle(0);
end

-- try to get out of alert
function check_alert()
    local labels = findOfTypes("UILabel", "")

    for index, label in pairs(labels) do
        usleep(100000)
        log("check alert: " .. label["text"])

        if(label["text"] == "Ok" or label["text"] == "Ok" or 
           label["text"] == "Try Again" or label["text"] == "Cancel" or
           label["title"] == "Error") then
            click_button(label)
        end
    end
end

-- get all the buttons and select one that was not clicked.
function getButton(clickedState)
    -- Basically anything we might consider clickable
    local buttons = findOfTypes("UIButton", "UINavigationItemButtonView", 
        "UINavigationItemView", "_UIAlertControllerActionView", "UISegmentLabel", 
        "UILabel", "")

    for index, button in pairs(buttons) do
        if(button["text"] ~= nil and clickedState[button["text"]] == nil) then
            return button
        end
    end

    return nil
end

function getInptFields(inputState)
    local fields = findOfTypes("UITextField", "")

    for index, field in pairs(fields) do
        if(field["text"] ~= nil and inputState[field["text"]] == nil) then
            return field
        end
    end

    return nil
end

function componentString(c)
    return tostring(c["class"]) .. ": @" .. 
           tostring(c["x"]) .. "," .. tostring(c["y"]) .. " " ..
           tostring(c["width"]) .. "x" .. tostring(c["height"]) .. 
           ", text:" .. tostring(c["text"]) ..
           ", title:" .. tostring(c["title"])
end