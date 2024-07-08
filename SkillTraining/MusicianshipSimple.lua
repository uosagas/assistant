--=========================
--Adjust settings here
pauseInSeconds = 10
instrumentGraphic = 0x0E9D
stopTrainingAt = 100
--=========================

while Skills.GetValue('Musicianship') < stopTrainingAt do
	instrument = Items.FindByType(instrumentGraphic)
	if instrument then
		Player.UseObject(instrument.Serial)
		Pause(pauseInSeconds*1000)
	end
end