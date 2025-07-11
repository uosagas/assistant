local window = nil
local nameLabel = nil
local coordinatesLabel = nil

local buttonSetPetPushed = false
local pet1Serial = nil
local basicProgressBar = nil


window = UI.CreateWindow('MainWindow', 'Just my title')
if window then
    window:SetPosition(200, 400)
    window:SetSize(300, 400)
    window:SetResizable(false)
    window:AddLabel(30, 30, 'Information'):SetColor(1,1,1,1)

    local yOffset = 60
    window:AddLabel(30, yOffset, 'Player: '):SetColor(1,1,1,1)
    window:AddLabel(30, yOffset +20, 'Coordinates: '):SetColor(1,1,1,1)
    
    nameLabel = window:AddLabel(90, yOffset, 'n/a')
    nameLabel:SetColor(1,0.5,0,1)

    coordinatesLabel = window:AddLabel(120, yOffset + 20, 'n/a')
    coordinatesLabel:SetColor(1,0.5,0,1)

    window:AddButton(30, 140, 'Set Pet'):SetOnClick(function() buttonSetPetPushed = true end)
    basicProgressBar = window:AddProgressBar(30, 160, 180, 15, 0)
    
end

while true do
       
    if buttonSetPetPushed then
        pet1Serial = Targeting.GetNewTarget(10000)
        buttonSetPetPushed = false
    end

    if pet1Serial then
        pet1 = Mobiles.FindBySerial(pet1Serial)
    end

    local healthPercent = pet1.Hits/pet1.HitsMax

    if healthPercent < 0.25 then
        basicProgressBar:SetColor(1, 0, 0, 1)
    elseif healthPercent < 0.5 then
        basicProgressBar:SetColor(1, 0.5, 0, 1)
    elseif healthPercent < 0.75 then
        basicProgressBar:SetColor(1, 1, 0, 1)
    else
        basicProgressBar:SetColor(0, 1, 0, 1)
    end
    

    basicProgressBar:SetValue(healthPercent)
    basicProgressBar:SetOverlay((healthPercent*100)..'%')


    
    nameLabel:SetText(Player.Name)
    coordinatesLabel:SetText('('..Player.X..', '..Player.Y..', '..Player.Z..')')
    Pause(50)
end



