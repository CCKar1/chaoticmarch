-- wait 5 seconds
usleep(5 * 1000000)

-- get all the buttons and click one.
buttons = findOfType("UIButton")

for index, button in pairs(buttons) do
    log("button " .. tostring(index) .. ": " .. tostring(button["text"]))
end

click_button(buttons[3])