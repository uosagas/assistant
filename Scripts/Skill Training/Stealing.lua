--[[
========= Stealing Trainer ========
Author: Deuce
Description: Trains Stealing 0-GM
Usage: Get a bag. 

       Use -info to get the serial of the 
       bag and paste it below.
	   
       Put the following items in the bag:
       Maul, Club, Cutlass, Spear, Black Staff
       Wooden Shield, Quarter Staff, Gnarled Staff,
       Dagger.

	   Run the script.
       
Dependencies: None
======================================

Adjust settings here--]]
local stealBag = 0x441901F6
--You shouldn't need to adjust below here
local stealItem = nil

while not Player.IsDead do
    Targeting.Target(Player.Serial)
    local stealing = Skills.GetValue('Stealing')
    local stealOptions = {
        {minSkill = 91, item = 0x143B},
        {minSkill = 81, item = 0x13B4},
        {minSkill = 71, item = 0x1441},
        {minSkill = 61, item = 0x0F62},
        {minSkill = 51, item = 0x0DF0},
        {minSkill = 41, item = 0x1B7A},
        {minSkill = 31, item = 0x0E89},
        {minSkill = 21, item = 0x13F8},
    }
    local stealItem = 0x0F52

    for _, option in ipairs(stealOptions) do
        if stealing > option.minSkill then
            Player.UseObject(stealBag)
            Pause(650)
            stealItem = Items.FindByType(option.item).Serial
            break
        end
    end
        
    Player.PickUp(stealBag)
    Pause(650)
    Player.DropOnGround()

    Journal.Clear()
    
    Skills.Use('Stealing')
    if Targeting.WaitForTarget(2000) then
        Targeting.Target(stealItem)
        Pause(500)
    end    
    
    Player.PickUp(stealBag)
    Pause(650)
    Player.DropInBackpack()
    Pause(650)
    
    if Journal.Contains('You successfully steal') then
        Player.PickUp(stealItem, 1)
        Pause(650)
        Player.DropInContainer(stealBag)
    end
    Pause(7000)
end

