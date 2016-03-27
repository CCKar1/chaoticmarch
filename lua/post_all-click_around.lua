-- let's click some buttons around the screen.

tStringCount = 0
function fill_all_fields()
	local fields = findOfTypes("UITextField", "")

    for index, field in pairs(fields) do
    	-- click it to grab focus.
    	click_button(field)
    	usleep(500000)
    	inputText("Test_string" .. tStringCount)
    	tStringCount = tStringCount + 1
    	usleep(1000000)
    end
end

-- Which buttons have I clicked?
clickedButtons = {}

-- How many interation to wait before giving up
waitTime = 1
attempts = 1

while (attempts > 0) do
	local button = getButton(clickedButtons)

	if(button ~= nil) then
		-- put some info in.
		fill_all_fields()

		-- reset after all buttons disappear
		waitTime = 30

		click_button(button)

		if(button["text"] ~= nil) then
			clickedButtons[button["text"]] = 1
		end

		log("clicked " .. componentString(button))
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
			waitTime = 1
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