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

-- try to get out of alert
function check_alert()
    local labels = findOfTypes("UILabel", "")

    for index, label in pairs(labels) do
        if(label["text"] == "Ok") then
            click_button(label)
        end
    end
end