-- let's click some buttons around the screen.

-- wait 5 seconds
usleep(5 * 1000000)

-- get all the buttons and click one.
function getButton(clickedState)
	local buttons = findOfType("UIButton")

	for index, button in pairs(buttons) do
	    if(button["text"] ~= nil and clickedState[button["text"]] == nil) then
	    	return button
	    end
	end

	return nil
end

clickedButtons = {}

while true do
	local button = getButton(clickedButtons)

	if(button ~= nil) then
		click_button(button)
		clickedButtons[button["text"]] = 1

		log("clicked " .. button["text"])
	else
		-- no more buttons left, so exit.
		break
	end

	usleep(2 * 1000000)
end

log("Looks like I've clicked all the buttons")