while true do
	instrument = Items.FindByType(0x0E9D)
	if instrument then
		Player.UseObject(instrument.Serial)
		Pause(10000)
	end
end