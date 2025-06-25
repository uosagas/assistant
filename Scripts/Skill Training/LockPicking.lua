--========= Lockpicking Trainer ========--
-- Author: Deuce
-- Description: Trains LockPicking
-- Usage: Get some boxes. Put them in backpack.
--		  use -info to get the serial on the boxes and keys.
--		  Paste them over the examples below.
--		  Run the script.
-- Dependencies: None
--======================================--

--=========================
--Adjust settings here
local boxes = {
    box0 = {boxID = 1079142070, keyID = 1079142071},
    box1 = {boxID = 1079139782, keyID = 1079139783},
    box2 = {boxID = 1079143580, keyID = 1079143581},
    box3 = {boxID = 1079143609, keyID = 1079143610}
}
--You shouldn't need to adjust below here
local firstRun = false

function LockBox(Key, Box)
    Journal.Clear()
    Player.UseObject(Key)
    Targeting.WaitForTarget(1000)
    Targeting.Target(Box)
    Pause(500)
    
    if Journal.Contains("You lock it.") then
        return true
    elseif Journal.Contains("You unlock it.") then
        return LockBox(Key, Box)
    else
        return false
    end
end

function PickBox(box)    
    Journal.Clear()
    lockpick = Items.FindByType(5373)
    Pause(100)
    
    if lockpick == nil or type(lockpick) == "number" then
        Messages.Print("Lockpicks not found.")
        error(0)
    end
    
    Player.UseObject(lockpick.Serial)
    Targeting.WaitForTarget(1000)
    Targeting.Target(box.boxID)

    if Journal.Contains("This does not appear to be locked.") then
        LockBox(box.keyID, box.boxID)
        return false
    else
        Journal.Clear()
        Pause(3750)
        if Journal.Contains("The lock quickly yields") then
            LockBox(box.keyID, box.boxID)
            return true
        elseif Journal.Contains("You are unable to pick") then
            return PickBox(box)
        else
            Messages.Print("Something broke.")
            LockAllBoxes()
            return false
        end
    end
end

function LockAllBoxes()
    for _, box in pairs(boxes) do
        LockBox(box.keyID, box.boxID)
    end
end

function PickAllBoxes()
    for boxName, box in pairs(boxes) do
        local success = PickBox(box)
        if success then
            Messages.Print("Successfully picked and relocked " .. boxName)
        else
            Messages.Print("Failed to pick " .. boxName)
        end
    end
end


while true do
    if firstRun then
        LockAllBoxes()
        firstRun = false
    end     
    PickAllBoxes()
 end
