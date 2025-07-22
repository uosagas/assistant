--[[ 
--------------------------------------------------------------------
Show All Hues Assistant Script
--------------------------------------------------------------------
Version History:
v1.0.0 - Initial release
--------------------------------------------------------------------
Script created by: 
  ___   _   _   __  __     ___   _   _   _   _   _   _   ____   ___ 
 | _ \ | | | | |  \/  |   | _ \ | | | | | \ | | | \ | | |  __| | _ \
 |   / | |_| | | |\/| |   |   / | |_| | |  \| | |  \| | |  _|  |   /
 |_|_\  \___/  |_|  |_|   |_|_\  \___/  |_|\__| |_|\__| |____| |_|_\

--------------------------------------------------------------------
This script is designed to be used within the UO Sagas environment.
--------------------------------------------------------------------
Script Description: 
Iterates through a range of hue IDs and prints each hue to the journal.
This is useful for testing or identifying hues/colors in the game.
--------------------------------------------------------------------
Script Notes:
1) The script iterates through hue IDs from 1 to 100.
2) Each hue is printed to the journal with its corresponding ID.
3) You can adjust the range of hues by modifying the `for` loop.
4) The script pauses briefly between each hue to avoid flooding the journal. 
--------------------------------------------------------------------
]]

-- Define Color Scheme
local Colors = {
    Alert   = 33,       -- Red
    Warning = 48,       -- Orange
    Caution = 53,       -- Yellow
    Action  = 67,       -- Green
    Confirm = 73,       -- Light Green
    Info    = 84,       -- Light Blue
    Status  = 93        -- Blue
}

-- Print Initial Start-Up Greeting
Messages.Print("___________________________________", Colors.Info)
Messages.Print("Welcome to the Show All Hues Script!", Colors.Info)
Messages.Print("Booting up... Initializing systems... ", Colors.Info)
Messages.Print("__________________________________", Colors.Info)


------------- Main script is below, do not make changes below this line -------------

-- Main Loop: Iterate through hue IDs and print them to the journal
for i = 1, 100 do
    Messages.Print("Hue ID: " .. i, i)  -- Print the hue ID to the journal
    Pause(50)  -- Pause briefly to avoid flooding the journal
end
