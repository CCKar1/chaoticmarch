-- let's click some buttons around the screen.

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

		-- check to make sure we are not in alert
		check_alert()

		-- remove back buttom from clicked state
		clickedButtons["Back"] = nil
		clickedButtons["back"] = nil

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