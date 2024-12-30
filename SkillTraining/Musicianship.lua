--========= Musicianship Trainer ========--
-- Author: 3HMonkey
-- Description: Trains Musicianship
-- Usage: Place a bunch of instruments in 
--		  your backpack and add their types
--		  to the list. Also adjust pause.
-- Dependencies: None
--======================================--

--=========================
--Adjust settings here
pauseInSeconds = 10
instrumentGraphics = {0x0E9D, 0x0EB3, 0x0E9C}  -- List of instrument types
targetSkill = 100
--=========================

while Skills.GetValue('Musicianship') < targetSkill do
    local instrument = nil
    for _, graphic in ipairs(instrumentGraphics) do
        instrument = Items.FindByType(graphic)
        if instrument then
            break  -- Exit the loop as soon as we find an instrument
        end
    end

    if instrument then
        Player.UseObject(instrument.Serial)
        Pause(pauseInSeconds * 1000)
    end
end
Messages.Print('Done skilling to target '..targetSkill, 30)