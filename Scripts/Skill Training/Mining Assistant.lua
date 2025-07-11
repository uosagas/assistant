-- Name: Mining Assistant
-- Authors: Hawks, Tacuba 
-- Description: Assistant to help equip pickaxes, mines, and combines ore
-- Last Updated: July 11, 2025

-- ====================================
-- Mining Tool Type ID
local PICKAXE_TYPE = 0x0E86  -- Replace if needed
-- ====================================

-- ====================================
-- Find a pickaxe equipped or in backpack
local function findPickAxe()

    Messages.Overhead("Running findPickAxe()", 11, Player.Serial)
    local equippedRight = Items.FindByLayer(1)

    if equippedRight and string.find(string.lower(equippedRight.Name or ""), "pick") then
        Messages.Overhead("Pickaxe is equipped!", 65, Player.Serial)
        Pause(600)
        return equippedRight
    end

    local pickaxe = Items.FindByType(PICKAXE_TYPE)

    if pickaxe and pickaxe.RootContainer == Player.Serial then
        Messages.Overhead("Pickaxe found in backpack!", 55, Player.Serial)
        Pause(600)
        return pickaxe
    end
    Messages.Overhead("No pickaxe found!", 35, Player.Serial)
    Pause(600)
    return nil
end

-- ====================================

-- ====================================
-- Equip pickaxe if needed

local function equipPickAxe()
    local equippedRight = Items.FindByLayer(1)
    local equippedLeft  = Items.FindByLayer(2)

    -- Already have pickaxe equipped
    if equippedRight and string.find(string.lower(equippedRight.Name or ""), "pick") then
        Messages.Overhead("Pickaxe already equipped!", 55, Player.Serial)
        Pause(600)
        return equippedRight
    end
  
    local pickaxe = findPickAxe()
    if not pickaxe then
        Messages.Overhead("Unable to mine. Ending script.", 33, Player.Serial)
        return nil
    end
  
    -- Simple equip if empty-handed
    if equippedRight == nil and equippedLeft == nil then   
        Messages.Overhead("Equipping pickaxe...", 55, Player.Serial)
        Player.Equip(pickaxe.Serial)
        Pause(1200)
        return
    end

    -- Unequip right-hand weapon if not a pickaxe
    if equippedRight then
        Messages.Overhead("Unequipping right-hand item...", 16, Player.Serial)
        Player.ClearHands("left") -- "left" on the Paperdoll view, even though it is the right hand.
        Pause(600)
    end

    if equippedLeft and string.find(string.lower(equippedLeft.Name or ""), "shield") then
        Messages.Overhead("Unequipping right-anded item...", 16, Player.Serial)
        Player.ClearHands("left")
        Pause(600)
    else
        Messages.Overhead("Unequipping 2-Handed item...", 16, Player.Serial)

        Player.ClearHands("both")

        Pause(600)
    end

    -- Do NOT clear the shield
    -- Only clear left hand if you want to force shield off, which we don't
    -- So we skip clearing left hand

    -- Equip pickaxe
    Messages.Overhead("Equipping pickaxe...", 55, Player.Serial)
    Player.Equip(pickaxe.Serial)
    Pause(1200)

    -- Confirm it equipped
    equippedRight = Items.FindByLayer(1)

    if equippedRight and string.find(string.lower(equippedRight.Name or ""), "pick") then
        Messages.Overhead("Pickaxe equipped successfully!", 65, Player.Serial)
        return equippedRight
    else
        Messages.Overhead("Failed to equip pickaxe!", 33, Player.Serial)
        return nil
    end
end

-- ====================================

-- Consolidate ore piles
function oreProcessing()
    local itemIdSmallOrePile = {0x19B9, 0x19B8, 0x19BA, 0x19B7}
    local didCombine = false

    local itemList1 = Items.FindByFilter({})
    for index, item1 in ipairs(itemList1) do
        if item1 ~= nil then
            if item1.RootContainer ~= Player.Serial then goto continue end

            if item1.Graphic == itemIdSmallOrePile[1]
            or item1.Graphic == itemIdSmallOrePile[2]
            or item1.Graphic == itemIdSmallOrePile[3] then

                Messages.Overhead("Combining ore piles...", 55, Player.Serial)

                local itemList2 = Items.FindByFilter({})
                for index, item2 in ipairs(itemList2) do
                    if item2 ~= nil then
                        if item2.RootContainer ~= Player.Serial then goto continue end
                        if item1.Hue ~= item2.Hue then goto continue end

                        if item2.Graphic == itemIdSmallOrePile[4] then
                            Player.UseObject(item1.Serial)
                            if Targeting.WaitForTarget(1000) then
                                Messages.Overhead("Let's put this here, that there...", 446, Player.Serial)
                                Targeting.Target(item2.Serial)
                                Pause(1000)
                                didCombine = true
                                break
                            end
                        end
                        ::continue::
                    end
                end
            end
            ::continue::
        end
    end

    if didCombine then
        Messages.Overhead("Finished combining ore.", 65, Player.Serial)
        Pause(800)
        return true
    end

    return false
end

-- ====================================
-- Check journal for mining result
-- Return:
--   true => stop mining
--   false => continue mining
--   "retarget" => pick new spot
local function checkJournal()
    if Journal.Contains("You have worn out your tool!") then
        Messages.Overhead("Pickaxe broke. Re-equipping...", Player.Serial)
        local newPickAxe = equipPickAxe()
        if not newPickAxe then
            Messages.Overhead("No pickaxe left. Stopping.", 33, Player.Serial)
            return true  -- stop mining
        end
        return "retarget"  -- re-equipped, now pick new spot
    end

    if Journal.Contains("Target cannot be seen.") or
       Journal.Contains("You can't mine there.") or
       Journal.Contains("That is too far away.") then
        Messages.Overhead("Invalid target. Pick a new spot.", 45, Player.Serial)
        Pause(900)
        return "retarget"
    end

    if Journal.Contains("You loosen some") or
       Journal.Contains("You dig some") then
        Pause(800)
        return false
    end

    if Journal.Contains("You have found") then
        Messages.Overhead("Found a gem!", 88, Player.Serial)
        Pause(800)
        return false
    end

    if Journal.Contains("There is no metal here to mine.") then
        Messages.Overhead("This spot is empty!", 45, Player.Serial)
        Pause(900)
        return "retarget"
    end

    return false
end
-- ====================================

-- ====================================
-- Main mining loop
local function mineOre()
    local rightHand = equipPickAxe()
    if not rightHand then
        rightHand = equipPickAxe()
    end

    Journal.Clear()
    Messages.Overhead("Let's look for ore!", 85, Player.Serial)
    Pause(800)

    Messages.Overhead("Pick a spot to mine.", 11, Player.Serial)
    Pause(300)

    Player.UseObject(rightHand.Serial)
    if not Targeting.WaitForTarget(300000) then
        Messages.Overhead("No target selected. Stopping.", Player.Serial)
        return
    end

    Pause(500)

    while true do
        if Player.Weight > 389 then
            Messages.Overhead("This ore is too heavy.", 45, Player.Serial)
            Pause(900)
            local combined = oreProcessing()
            if combined then
                Pause(500) -- Small pause after combining
                Messages.Overhead("Weight adjusted. Please select a new mining spot.", 55, Player.Serial)
                Pause(900)

                -- PROMPT for NEW TILE:
                Player.UseObject(rightHand.Serial)
                if not Targeting.WaitForTarget(300000) then
                    Messages.Overhead("No new target. Stopping.", 33, Player.Serial)
                    break
                end
                Pause(500)
                -- continue mining loop with new tile
            else
                Messages.Overhead("I'm still overburdened avatar. Ending script.", 33, Player.Serial)
                return -- Exit the script if still overweight and can't combine
            end
        end

        Journal.Clear()

        Player.UseObject(rightHand.Serial)
        if Targeting.WaitForTarget(2000) then
            Targeting.TargetLast()
        else
            equipPickAxe()
            --Messages.Overhead("No target available. Stopping.", 33, Player.Serial)
            --break
        end

        Pause(1000)

        local result = checkJournal()
        if result == true then
            break -- stop mining
        elseif result == "retarget" then
            Messages.Overhead("Pick a new mining spot.", 55, Player.Serial)
            Player.UseObject(rightHand.Serial)
            if not Targeting.WaitForTarget(300000) then
                Messages.Overhead("No new target. Stopping.", 33, Player.Serial)
                break
            end
            Pause(500)
        end
    end
end
-- ====================================

mineOre()