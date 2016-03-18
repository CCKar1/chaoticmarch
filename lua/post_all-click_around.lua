-- let's click some buttons around the screen.

-- Which buttons have I clicked?
clickedButtons = {}

-- How many interation to wait before giving up
waitTime = 15
attempts = 2

while (attempts > 0) do
	local button = getButton(clickedButtons)

	if(button ~= nil) then
		-- reset after all buttons disappear
		waitTime = 30

		click_button(button)

		if(button["text"] ~= nil) then
			clickedButtons[button["text"]] = 1
		end

		log("clicked " .. button["text"])
	else
		log("No buttons found, help!")

		-- check to make sure we are not in alert
		check_alert()

		-- remove back buttom from clicked state
		clickedButtons["Back"] = nil
		clickedButtons["back"] = nil

		if(waitTime == 0) then
			-- do a reset and maybe try again
			clickedButtons = {}
			waitTime = 30
			attempts = attempts - 1

			log("Finished a run, resetting for attempt " .. tostring(attempts))
		else
			-- wait less
			waitTime = waitTime - 1
		end
	end

	usleep(2 * 1000000)
end

log("Looks like I've clicked everything! Bye!")