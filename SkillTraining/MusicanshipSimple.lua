--=========================
--Adjust settings here
pauseInSeconds = 10
instrumentGraphic = 0x0E9D
--=========================

while true do
	instrument = Items.FindByType(instrumentGraphic)
	if instrument then
		Player.UseObject(instrument.Serial)
		Pause(pauseInSeconds*100)
	end
end