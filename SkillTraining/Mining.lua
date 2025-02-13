Pause(50)
::strt1::
while Player.Weight < Player.MaxWeight-15 do
	tool = Items.FindByType(3718)
	if not tool then
		Messages.Overhead("No pickaxe found", 30, Player.Serial)
		Pause(1000)
		goto strt1
	else
		Player.Equip(tool.Serial)
		Pause(600)
		goto strt2
	end
end
::strt2::
while Player.Weight < Player.MaxWeight-15 do
	Player.UseObjectByType(3718)
	Targeting.WaitForTarget (1500)
	Messages.Overhead("Click on next mining node", 50, Player.Serial)
	Pause(1500)
	goto strt3
end
::strt3::
while Player.Weight < Player.MaxWeight-15 do
	Player.UseObjectByType(3718)
	Targeting.WaitForTarget (1500)
	Targeting.TargetLast()
	Pause(1500)
	if Journal.Contains('There is no metal here to mine.') then
		Messages.Overhead("There is no metal here to mine.", 30, Player.Serial)
    	Journal.Clear()
    	goto strt2
    elseif Journal.Contains('Target cannot be seen.') then
    	Messages.Overhead("Target cannot be seen.", 30, Player.Serial)
    	Journal.Clear()
    	goto strt2
    elseif Journal.Contains('That is too far away.') then
    	Messages.Overhead("That is too far away.", 30, Player.Serial)
    	Journal.Clear()
    	goto strt2
    elseif Journal.Contains("You can't mine that") then
    	Messages.Overhead("You can't mine that", 30, Player.Serial)
    	Journal.Clear()
    	goto strt2
    elseif Journal.Contains("You can't mine there") then
    	Messages.Overhead("You can't mine there", 30, Player.Serial)
    	Journal.Clear()
    	goto strt2
    elseif Journal.Contains('The pickaxe must be equipped for any serious mining.') then
    	Journal.Clear()
    	Player.Equip(tool.Serial)
		Pause(600)
		goto strt3
    elseif Journal.Contains("Error in function: Item not found") then
    	Journal.Clear()
    	goto strt1
    else
    goto strt3
    end
end
Messages.Overhead("Maximum safe weight has been reached.", 33, Player.Serial)
