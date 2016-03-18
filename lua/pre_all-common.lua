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

    showCircle(0, x, y, 20);

    touchDown(0, x, y)
    usleep(100000)
    touchUp(0, x, y)

    hideCircle(0);
end

-- try to get out of alert
function check_alert()
    local labels = findOfTypes("UILabel", "")

    for index, label in pairs(labels) do
        if(label["text"] == "Ok") then
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