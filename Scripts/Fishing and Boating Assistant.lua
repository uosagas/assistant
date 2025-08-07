-- Name: Fishing and Boating Assistant
-- Authors: Tacuba, Coolskin
-- Description: Boat navigation Gump
--              and fishing assistance
-- Last Updated: August 1, 2025

-- ====================================
-- ADDED: Coordinate Conversion Function
-- ====================================
local function ConvertXYtoNEWS(x, y)
    -- Calculation constants
    local width = 5120
    local height = 4096
    local center_x = 1323.1624
    local center_y = 1624
    
    -- Inverse calculation
    local normalized_longitude = (((x - center_x) * 360) / width)
    if normalized_longitude < 0 then normalized_longitude = normalized_longitude + 360 end
    local normalized_latitude = (((y - center_y) * 360) / height)
    if normalized_latitude < 0 then normalized_latitude = normalized_latitude + 360 end
    
    -- Determine hemisphere and decimal degrees
    local dec_lat, lat_hem, dec_lon, lon_hem
    if normalized_latitude > 180 then dec_lat = 360 - normalized_latitude; lat_hem = "N" else dec_lat = normalized_latitude; lat_hem = "S" end
    if normalized_longitude > 180 then dec_lon = 360 - normalized_longitude; lon_hem = "W" else dec_lon = normalized_longitude; lon_hem = "E" end

    -- Convert to Degrees and Minutes
    local lat_deg = math.floor(dec_lat)
    local lat_min = math.floor((dec_lat - lat_deg) * 60)
    local lon_deg = math.floor(dec_lon)
    local lon_min = math.floor((dec_lon - lon_deg) * 60)

    -- Final formatting without the '°' symbol
    return lat_deg .. "d " .. lat_min .. "'" .. lat_hem .. ", " .. lon_deg .. "d " .. lon_min .. "'" .. lon_hem
end

-- ====================================
-- Ship Navigation Gump
-- ====================================

local navWindow = nil
local coordLabel = nil
local newsCoordLabel = nil -- ADDED for Geo Coords
local statusLabel = nil
local speedSingleCheck = nil
local speedNormalCheck = nil
local fishingAssistantOn = nil
local fishingAssistantOff = nil
local isFishingOn = false

-- Use a real Lua variable for reliable toggle tracking
local isSingleCheck = false

local shipStatus = "Stopped"

-- ====================================
-- Create the Gump window
navWindow = UI.CreateWindow('ShipNavWindow', 'Ship Navigation')
if navWindow then
    navWindow:SetPosition(975, 50)
    navWindow:SetSize(345, 505)
    navWindow:SetResizable(false)

    -- General Information Section
    navWindow:AddLabel(20, 30, 'GENERAL INFORMATION'):SetColor(0.9, 0.9, 1, 1)

    -- Ship Location
    navWindow:AddLabel(50, 50, 'Ship Location:'):SetColor(1,1,1,1)
    coordLabel = navWindow:AddLabel(160, 50, 'n/a')
    coordLabel:SetColor(0.3,1,0.3,1)

    -- ADDED: Geo Coords Label
    navWindow:AddLabel(50, 70, 'Geo. Coords:'):SetColor(1,1,1,1)
    newsCoordLabel = navWindow:AddLabel(160, 70, 'n/a')
    newsCoordLabel:SetColor(0.3, 0.8, 1, 1)

    -- Ship Status - MOVED DOWN
    navWindow:AddLabel(50, 90, 'Status: '):SetColor(1, 1, 1, 1)
    statusLabel = navWindow:AddLabel(110, 90, 'n/a')
    statusLabel:SetColor(1,1,0.3,1)

    -- Speed Toggle - MOVED DOWN
    navWindow:AddLabel(20, 115, 'SPEED'):SetColor(1, 1, 1, 1)

    speedSingleCheck = navWindow:AddCheckbox(50, 130, '1 Tile', false)
    speedNormalCheck = navWindow:AddCheckbox(50, 155, 'Normal', true)

    -- Radio behavior: keep state synced
    speedSingleCheck:SetOnCheckedChanged(function(isChecked)
        isSingleCheck = isChecked
        if isChecked then
            speedNormalCheck:SetChecked(false)
        else
            speedNormalCheck:SetChecked(true)
            isNormalCheck = true
        end
    end)

    speedNormalCheck:SetOnCheckedChanged(function(isChecked)
        if isChecked then
            speedSingleCheck:SetChecked(false)
            isSingleCheck = false
        else
            speedSingleCheck:SetChecked(true)
            isSingleCheck = true
        end
    end)

    -- Navigation Buttons - MOVED DOWN
    navWindow:AddLabel(20, 185, 'NAVIGATION'):SetColor(1, 1, 1, 1)

    navWindow:AddButton(135, 200, ' Forward '):SetOnClick(function()
        local command = "Forward"
        if isSingleCheck then
            command = command .. " One"
        end
        Player.Say(command)
        shipStatus = "Forward"
    end)

    navWindow:AddButton(70, 230, ' Forward \nStarboard '):SetOnClick(function()
        local command = "Forward Left"
        if isSingleCheck then
            command = command .. " One"
        end
        Player.Say(command)
        shipStatus = "Forward, Starboard"
    end)

    navWindow:AddButton(200, 230, ' Forward \n  Port  '):SetOnClick(function()
        local command = "Forward Right"
        if isSingleCheck then
            command = command .. " One"
        end
        Player.Say(command)
        shipStatus = "Forward, Port"
    end)

    navWindow:AddButton(20, 275, ' Turn \n Left'):SetOnClick(function()
        local command = "Turn Left"
        if isSingleCheck then
            command = "Turn Left"
        end
        Player.Say(command)
        shipStatus = "Turning Left"
    end)

    navWindow:AddButton(80, 275, ' Drift \n Left'):SetOnClick(function()
        local command = "Drift Left"
        if isSingleCheck then
            command = "Left One"
        end
        Player.Say(command)
        shipStatus = "Drifting Left"
    end)

    navWindow:AddButton(145, 270, '\n Stop \n '):SetOnClick(function()
        Player.Say("Stop")
        shipStatus = "Stopped"
    end)

    navWindow:AddButton(205, 275, ' Drift \n Right'):SetOnClick(function()
        local command = "Drift Right"
        if isSingleCheck then
            command = "Right one"
        end
        Player.Say(command)
        shipStatus = "Drifting Right"
    end)

    navWindow:AddButton(270, 275, ' Turn \n Right '):SetOnClick(function()
        local command = "Turn Right"
        if isSingleCheck then
            command = "Turn Right"
        end
        Player.Say(command)
        shipStatus = "Turning Right"
    end)

    navWindow:AddButton(70, 325, ' Backward \nStarboard '):SetOnClick(function()
        local command = "Backward Left"
        if isSingleCheck then
            command = command .. " One"
        end
        Player.Say(command)
        shipStatus = "Backward, Starboard"
    end)

    navWindow:AddButton(200, 325, ' Backward \n  Port  '):SetOnClick(function()
        local command = "Backward Right"
        if isSingleCheck then
            command = command .. " One"
        end
        Player.Say(command)
        shipStatus = "Backward, Port"
    end)

    navWindow:AddButton(145, 370, ' Back '):SetOnClick(function()
        local command = "Back"
        if isSingleCheck then
            command = command .. " One"
        end
        Player.Say(command)
        shipStatus = "Reversing"
    end)

    -- Anchor Section - MOVED DOWN
    navWindow:AddLabel(20, 395, 'ANCHOR'):SetColor(1, 1, 1, 1)

    navWindow:AddButton(60, 415, 'Raise Anchor'):SetOnClick(function()
        Player.Say("Raise Anchor")
        shipStatus = "Anchor Raised"
    end)

    navWindow:AddButton(160, 415, 'Drop Anchor'):SetOnClick(function()
        Player.Say("Drop Anchor")
        shipStatus = "Anchor Dropped"
    end)

    -- Fishing Assistant Script Section - MOVED DOWN
    navWindow:AddLabel(20, 450, "TACUBA'S FISHING ASSISTANT"):SetColor(1, 1, 1, 1)

    fishingAssistantOn = navWindow:AddCheckbox(50, 470, 'On', false)
    fishingAssistantOff = navWindow:AddCheckbox(100, 470, 'Off', true)

    -- Radio behavior: keep state synced
    fishingAssistantOn:SetOnCheckedChanged(function(isChecked)
        isFishingOn = isChecked
        if isChecked then
            fishingAssistantOff:SetChecked(false)
            Messages.Overhead("Fishing Assistant: ON", 85, Player.Serial)
            mainFishingLoop() -- start loop
        else
            fishingAssistantOff:SetChecked(true)
            isFishingOn = false
            Messages.Overhead("Fishing Assistant: OFF", 33, Player.Serial)
        end
    end)

    fishingAssistantOff:SetOnCheckedChanged(function(isChecked)
        if isChecked then
            fishingAssistantOn:SetChecked(false)
            isFishingOn = false
            Messages.Overhead("Fishing Assistant: OFF", 33, Player.Serial)
        else
            fishingAssistantOn:SetChecked(true)
            Messages.Overhead("Fishing Assistant: ON", 85, Player.Serial)
            mainFishingLoop() -- start loop
        end
    end)
end

-- ==========================
-- Tacuba's Fishing Assistant
-- === SCRIPT VARIABLES ===

-- List of fish
local BigFish = {
    0x09CC, -- Green Fish
    0x09CD, -- Red/Brown Fish
    0x09CE, -- Purple Fish
    0x09CF  -- Yellow Fish
	}

-- Map each graphic to a color name and hue
local FishColors = {
    [0x09CC] = { name = "Green", hue = 72 },
    [0x09CD] = { name = "Red/Brown", hue = 34 },
    [0x09CE] = { name = "Purple", hue = 15 },
    [0x09CF] = { name = "Yellow", hue = 55 }
	}

-- List of bladed weapons (for Fish Steaks)
local bladedWeapons = {
    0x0F52, -- Dagger
    0x13FF, -- Katana
    0x1401, -- Kryss
    0x143E, -- Viking Sword
    0x1441, -- Cutlass
    0x13B6, -- Butcher Knife
    0xFEA9, -- Skinning Knife
    0x0F43, -- Hatchet
	}

-- Check to see if you have a Fishing Pole
local function findFishingPole()
	--First check your hands
	local equippedItem = Items.FindByLayer(2)
	if equippedItem and string.find(string.lower(equippedItem.Name or ""), "fishing") then
		Messages.Overhead("Fishing pole is equipped!", 72, Player.Serial)
		Pause(800)
		return equippedItem
	end

	--Next check your backpack
	local fishingPole = Items.FindByType(0x0DC0)
	if fishingPole and fishingPole.RootContainer == Player.Serial then
		Messages.Overhead("Fishing pole found in backpack!", 72, Player.Serial)
		Pause(800)
		return fishingPole
	else
		Messages.Overhead("No fishing pole!", 33, Player.Serial)
		Pause(600)
		return nil
	end
end

-- Equip Fishing Pole, if needed 
local function equipFishingPole()
    local equipped = Items.FindByLayer(2)
    if equipped and string.find(string.lower(equipped.Name or ""), "fishing") then
        Messages.Overhead("Fishing pole is equipped!", 72, Player.Serial)
        Pause(800)
        return equipped
    end
    
    local pole = findFishingPole()
    
    if pole then
    	Player.ClearHands("both")
    	Messages.Overhead("Equipping fishing pole.", 60, Player.Serial)
    	Pause(1200)
    	Player.Equip(pole.Serial)
    	Pause(1200)
    	return pole
    else
    	Messages.Overhead("Exiting script!", 33, Player.Serial)
    	return nil
    end
end

-- Iterate through your fish
local function gettingHeavy()
	Messages.Overhead("Your backpack is heavy!", 44, Player.Serial)
	Pause(800)
	
	--Find fish in your backpack
	local fishFilter = {onground = false, graphics = BigFish}
    local fishList = Items.FindByFilter(fishFilter)

    if not fishList or #fishList == 0 then
        Messages.Overhead("No fish found in backpack!", 33, Player.Serial)
        Pause(1400)
        return
    end
    
    --Find a bladed weapon in your backpack
	local bladeFilter = {onground = false, graphics = bladedWeapons}
    local blades = Items.FindByFilter(bladeFilter)
    
    if not fishList or #fishList == 0 then
        Messages.Overhead("No blade to cut fish!", 33, Player.Serial)
        Pause(1000)
        return
    end    
    
    --Use the first blade located	
	if blades[1].Name ~= nil and blades[1].RootContainer == Player.Serial then
		blade = blades[1]
	else
		blade = blades[2]
	end

    if blade.RootContainer == Player.Serial then
    	Messages.Overhead("Found a "..blade.Name..".", 72, Player.Serial)
    end
    
    Pause(1200)
    
    if blade.RootContainer ~= Player.Serial then
    	Messages.Overhead("No blade found in backpack!", 33, Player.Serial)  
    		--Note: Error message thrown if blade leaves backpack; edge case to fix later.
    	return
    end
            
    --Cut each fish
    for _, item in ipairs(fishList) do
        if item.RootContainer == Player.Serial then
            local colorInfo = FishColors[item.Graphic] or { name = "Unknown", hue = 1150 }
            Messages.Overhead("Cut "..item.Amount.." "..colorInfo.name.." fish into steaks.", colorInfo.hue, Player.Serial)
            Pause(1000)
            Player.UseObject(blade.Serial)
            Targeting.WaitForTarget(600)
            Targeting.Target(item.Serial)
            Pause(1600)
        end
    end
Messages.Overhead("Finished making Fish Steaks.", 85, Player.Serial)
Pause(800)
Messages.Overhead("Let's get back to fishing!", 60, Player.Serial)
Pause(800)
Messages.Overhead("Warning! You must now select a water tile!", 44, Player.Serial)
Pause(800)
Messages.Overhead("Pick a new fishing spot!", 60, Player.Serial)
Pause(800)
Player.UseObject(righthand.Serial)
Pause(6000)
end

local function goneFishing()
	Pause(100)
	Messages.Overhead("Fishing...", 96, Player.Serial)
	Pause(2000)
	Messages.Overhead("Fishing...", 94, Player.Serial)
	Pause(2000)
	Messages.Overhead("Fishing...", 96, Player.Serial)
	Pause(2000)
	Messages.Overhead("Fishing...", 94, Player.Serial)
	Pause(2000)
end  

--Check for a Fishing Pole when one is no longer equipped.
local function checkFishingPole()
    -- Check your backpack
    local fishingPole = Items.FindByType(0x0DC0)

    if fishingPole and fishingPole.RootContainer == Player.Serial then
        Messages.Overhead("Fishing pole found in backpack!", 72, Player.Serial)
        Pause(800)
        Messages.Overhead("Equipping fishing pole.", 60, Player.Serial)
        Pause(1200)
        Player.Equip(fishingPole.Serial)
        Pause(1500)

        -- Check for Fishing Pole
        local newPole = Items.FindByLayer(2)

        if newPole then
            Player.UseObject(newPole.Serial)
            Pause(300)
            Targeting.TargetLast(SavedTargetPosition)
            goneFishing()
            return newPole
        else
            Messages.Overhead("Failed to equip fishing pole!", 33, Player.Serial)
            return nil
        end
    else
        Messages.Overhead("WARNING: You're out of fishing poles!", 33, Player.Serial)
        Pause(1200)
        Messages.Overhead("Exiting script!", 33, Player.Serial)
        return nil
    end
end

--Identify action items based on journal entries.
local function journalEntries()
	for i = 1, 20 do    
	    -- Successful casts
	    if Journal.Contains("You cannot fish here") then
	        Messages.Overhead("Unable to fish here", 34, Player.Serial)
	        Pause(800)
	        break
	    elseif Journal.Contains("You fish a while, but fail to catch anything.") then
	        Messages.Overhead("Failed to catch anything. Let's try again!", 56, Player.Serial)
	        Pause(800)
	        break
	    elseif Journal.Contains("You pull out an item") then
	        Messages.Overhead("Wohoo! Hope it was good!", 77, Player.Serial)
	        Pause(800)
	        break
	    end
	
		-- Unsuccessful subsequent casts
		if Journal.Contains("Target cannot be seen.") 
			or Journal.Contains("You need to be closer to the water to fish!")
			or Journal.Contains("The fish don't seem to be biting here.")
			then
			Messages.Overhead("Invalid fishing spot. Pick again!", 44, Player.Serial)
			Journal.Clear()
			Pause(800)
			righthand = Items.FindByLayer(2) -- In case you re-equipped fishing pole.
			Player.UseObject(righthand.Serial)
			Targeting.WaitForTarget(14000) -- Assumes you have selected a spot to fish!
			Pause(5500)
			goneFishing()
		end
		
		if Journal.Contains("You broke your fishing pole.") or
			Journal.Contains("You have worn") then
			Pause(600)
			checkFishingPole()
			Pause(1200)
		end
		
		if Journal.Contains("The fishing pole must be equipped") then
			Pause(600)
			Messages.Overhead("Where did the fishing pole go?", 44, Player.Serial)
			Pause(1200)
			checkFishingPole()
			Pause(500)
			break
		end
	end
	-- Unable to fish
	if Journal.Contains("The fish don't seem to be biting here.") then
	   Messages.Overhead("Nothing to fish! Pick a new spot.", 30, Player.Serial)
	   Pause(600)
	   Player.UseObject(righthand.Serial)
	   Pause(5000)
	end
end

local function checkErrors()
	for i = 1, 20 do
		-- Unsuccessful subsequent casts
		if Journal.Contains("Target cannot be seen.") 
			or Journal.Contains("You need to be closer to the water to fish!")
			--or Journal.Contains("The fish don't seem to be biting here.")
			then
			Messages.Overhead("Invalid fishing spot. Pick again!", 44, Player.Serial)
			Journal.Clear()
			Pause(800)
			Player.UseObject(righthand.Serial)
			Targeting.WaitForTarget(14000) -- Assumes you have selected a spot to fish!
			Pause(5500)
			goneFishing()
		end
		
		if Journal.Contains("The fish don't seem to be biting here.") then
			Messages.Overhead("No more fish here!", 44, Player.Serial)
			Pause(600)
			Messages.Overhead("Pick a new spot to fish.", 34, Player.Serial)
			Player.UseObject(righthand.Serial)
			Targeting.WaitingForTarget(14000) -- Assumes you have selected a spot to fish!
			Pause(5500)
			goneFishing()
		end
		
		if Journal.Contains("You broke your fishing pole.") or
			Journal.Contains("You have worn") then
			Pause(1200)
			checkFishingPole()
			Pause(500)
			break
		end
		
		if Journal.Contains("The fishing pole must be equipped") then
			Pause(600)
			Messages.Overhead("Where did the fishing pole go?", 44, Player.Serial)
			Pause(1200)
			Journal.Clear()
			checkFishingPole()
			Pause(500)
			break
		end
	end
end

local function main()
	righthand = Items.FindByLayer(2)
	if righthand == nil then
	else
		Journal.Clear()
		Messages.Overhead("Let's fish!", 85, Player.Serial)
		Pause(800)
		Messages.Overhead("Pick a spot to fish.", 11, Player.Serial)
		Pause(300)
		Player.UseObject(righthand.Serial)
		Targeting.WaitForTarget(14000) -- Assumes you have selected a spot to fish!
		Pause(5500)
		
		-- Unsuccessful initial cast
		if Journal.Contains("Target cannot be seen.") 
			or Journal.Contains("You need to be closer to the water to fish!")
			or Journal.Contains("The fish don't seem to be biting here.")
			then
			Messages.Overhead("Invalid fishing spot. Pick again!", 44, Player.Serial)
			Journal.Clear()
			Pause(800)
			main()
		
		--Successful initial (or looped) cast
		else
			goneFishing()
			Pause(600)
			while true do
			    local righthand = Items.FindByLayer(2)
			    if righthand ~= nil then
			    	checkErrors()
			        Messages.Overhead("Let's keep fishing!", 85, Player.Serial)
			        Player.UseObject(righthand.Serial)
			        Pause(300)
			        Targeting.TargetLast(SavedTargetPosition)
			        Pause(300)
			        Journal.Clear()
			        
			        -- Check journal to determine next path
			        journalEntries()
			    end
			    
			    -- Check for errors
			    checkErrors()
			    
			    --Reduce weight, if needed
			    if Player.Weight > Player.MaxWeight-10 then    
			    	Pause(800)
			    	gettingHeavy()
			    end
			    
			    --Check for edge case error
			    if Journal.Contains("That is not accessible.") then
			    	Pause(300)
			    	Player.UseObject(righthand.Serial)
			    	Messages.Overhead("Pick where to fish.", 55, Player.Serial)
			    	Pause(4500)
			    break
	
				if Journal.Contains("You broke your fishing pole.") then
					Pause(300)
					Messages.Overhead("Your fishing pole broke!", 44, Player.Serial)
					Pause(1200)
					checkFishingPole()
					Pause(1200)
				end
				
				-- Proceed with fishing
				else
			  		Pause(800)
			  	
			  		local fishingPole = Items.FindByType(0x0DC0)
    				if fishingPole == nil or fishingPole.RootContainer == nil then
        				Messages.Overhead("Fishing pole found in backpack!", 72, Player.Serial)
        				Messages.Overhead("WARNING: You're out of fishing poles!", 33, Player.Serial)
        				Pause(1200)
       					Messages.Overhead("Exiting script!", 33, Player.Serial)
        				return
        				
        			else
			  			checkErrors()
			  			Pause(5500)
			  			righthand = Items.FindByLayer(2)
			   			Pause(600)
			   			Messages.Overhead("Fishing last target position.", 11, Player.Serial)
			   			Pause(1200)
			 			checkErrors()
			 		
				 		-- Not sure why, but on occassion does not check for righthand above			 					 		
				 		righthand = Items.FindByLayer(2)  
			 		
				 		if righthand ~= nil then
				 			Player.UseObject(righthand.Serial)
				 			Pause(600)
				 			Targeting.TargetLast(SavedTargetPosition)
			 				goneFishing()
			 			else
			 				return
			 			end
			 		end
				end
				Pause(800)
				Messages.Overhead("Checking journal.", 311, Player.Serial)
				Pause(800)
				journalEntries()
				Pause(800)
			end
		end
	end
end

function mainFishingLoop()
    equipFishingPole()
    while isFishingOn do
        main()
    end
end

-- ====================================
-- Main Gump loop to update info
while true do
    Pause(50)
    
    if navWindow and not navWindow.IsDisposed then
        coordLabel:SetText('(' .. Player.X .. ', ' .. Player.Y .. ')')
        
        -- ADDED: Update geographical coordinates
        local news_coords = ConvertXYtoNEWS(Player.X, Player.Y)
        newsCoordLabel:SetText(news_coords)

        statusLabel:SetText(shipStatus)
    else
        break -- Stop script if window is closed
    end

    -- Check for Fishing Assistant request
    if isFishingOn then
        fishingAssistantOff = false  -- Reset the flag
        mainFishingLoop()
    end
    Pause(2000)
end
