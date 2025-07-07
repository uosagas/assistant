--========= Simple Scavengerer =========--
-- Author: 3HMonkey
-- Description: Scavenges for specific items
--              and picks them up if found.
-- Usage: Set your item graphic ids in the
--		  itemsToSearchFor table below.
-- Dependencies: None
--======================================--

--=================
-- SETUP HERE
--=================
itemsToSearchFor = {
        0x0f7a, -- Black Pearl
        0x0f7b, -- Blood Moss
        0x0f86, -- Mandrake Root
        0x0f84, -- Garlic
        0x0f85, -- Ginseng
        0x0f88, -- Nightshade
        0x0f8d, -- Spider's Silk
        0x0f8c, -- Sulphurous Ash
       }

--================
-- MAIN ROUTINE
--================
while true do
    filter = {onground=true, rangemax=2, graphics=itemsToSearchFor}
    
    list = Items.FindByFilter(filter)
    for index, item in ipairs(list) do
        Messages.Print('Picking up '..item.Name..' at location x:'..item.X..' y:'..item.Y)
        Player.PickUp(item.Serial, 1000)
        Pause(100)
        Player.DropInBackpack()
        Pause(100)
    end
    -- Important Pause for CPU
    Pause(150)
end