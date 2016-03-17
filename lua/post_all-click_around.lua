-- let's click some buttons around the screen.

-- get all the buttons and select one that was not clicked.
function getButton(clickedState)
	local buttons = findOfType("UIButton")

	for index, button in pairs(buttons) do
	    if(button["text"] ~= nil and clickedState[button["text"]] == nil) then
	    	return button
	    end
	end

	return nil
end

-- Which buttons have I clicked?
clickedButtons = {}

-- How many interation to wait before giving up
waitTime = 30

while true do
	local button = getButton(clickedButtons)

	if(button ~= nil) then
		-- reset after all buttons disappear
		waitTime = 30

		click_button(button)
		clickedButtons[button["text"]] = 1

		log("clicked " .. button["text"])
	else
		log("No buttons found, help!")

		if(waitTime == 0) then
			break
		else
			-- wait less
			waitTime = waitTime - 1
		end
	end

	usleep(2 * 1000000)
end

log("Looks like I've clicked all the buttons")