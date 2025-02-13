Pause(50)
::strt1::
while Player.Weight < Player.MaxWeight-2 do
	tool = Items.FindByType(3907)
	if tool then
		Player.Equip(tool.Serial)
		Pause(600)
		goto strt2
	else
		Messages.Overhead("No axe or hatchet found", 30, Player.Serial)
		Pause(1000)
		goto strt1
	end
end
::strt2::
while Player.Weight < Player.MaxWeight-2 do
	Player.UseObjectByType(3907)
	Targeting.WaitForTarget (1000)
	Messages.Overhead("Click on next tree", 50, Player.Serial)
	Pause(1500)
	goto strt3
end
::strt3::
while Player.Weight < Player.MaxWeight-2 do
	Journal.Clear()
	Player.UseObjectByType(3907)
	Targeting.WaitForTarget (1000)
	Targeting.TargetLast()
	Pause(3000)
	if Journal.Contains("There's not enough wood here to harvest.") then
		Messages.Overhead("There's not enough wood here to harvest", 30, Player.Serial)
    	Journal.Clear()
    	goto strt2
    elseif Journal.Contains("You can't use an axe on that.") then
    	Messages.Overhead("You can't use an axe on that", 30, Player.Serial)
    	Journal.Clear()
    	goto strt2
    elseif Journal.Contains('That is too far away.') then
    	Messages.Overhead("That is too far away", 30, Player.Serial)
    	Journal.Clear()
    	goto strt2
    elseif Journal.Contains("Target cannot be seen.") then
    	Messages.Overhead("Target cannot be seen", 30, Player.Serial)
    	Journal.Clear()
    	goto strt2
    elseif Journal.Contains('The axe must be equipped for any serious wood chopping') then
    	Journal.Clear()
    	goto strt1
    elseif Journal.Contains("Error in function: Item not found") then
    	Journal.Clear()
    	goto strt1
    else
    goto strt3
    end
end
Messages.Overhead("Maximum safe weight has been reached", 33, Player.Serial)
Pause(600)
Messages.Overhead("Turning logs into boards", 50, Player.Serial)
logs = Items.FindByType(7133)
Player.UseObjectByType(3907)
Targeting.WaitForTarget(100)
Targeting.Target(logs.Serial)
Pause(600)
if Player.Weight < Player.MaxWeight-10 then
	goto strt1
	else
	Messages.Overhead("I must empty my bag", 33, Player.Serial)
	return
end
