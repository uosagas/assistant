-- =============================================================================
-- Inscription Assistant v1.0 for UOSagas Assistant
-- Author: Proximo
-- Currently designed for crafting full spellbooks
-- =============================================================================

-- Color name - RGBA map
local COLOR_MAP = {
	Red    = {1, 0, 0, 1},
	Green  = {0, 1, 0, 1},
	Blue   = {0, 0, 1, 1},
	White  = {1, 1, 1, 1},
	Black  = {0, 0, 0, 1},
	Orange = {1, 0.5, 0, 1},
}

-- =============================================================================
-- PART 1: VARIABLES AND SETUP
-- =============================================================================

local window
local selectAllButton, startButton, selectSpellbookButton
local circle1Checkbox, circle2Checkbox, circle3Checkbox, circle4Checkbox
local circle5Checkbox, circle6Checkbox, circle7Checkbox, circle8Checkbox
local spellbookLabel
local statusTitleLabel, statusLabel
local manaLabel, manaBar

local craftCircle1, craftCircle2, craftCircle3, craftCircle4 = false, false, false, false
local craftCircle5, craftCircle6, craftCircle7, craftCircle8 = false, false, false, false

local startCraftingClicked    = false
local selectSpellBookClicked  = false
local selectAllCirclesClicked = false
local spellbookSerial = nil
local spellbook = nil
local craftingStatus = 'Not Started'
local requirementsMet = true

local INSCRIPTION_GUMP = 2653346093  -- do not change this!

local spellCircles = {
	{
		name     = "First Circle",
		buttonId = 1,
		manaCost = 4,
		spells   = {
			{ name = "Reactive Armor", buttonId = 3  },
			{ name = "Clumsy",         buttonId = 10 },
			{ name = "Create Food",    buttonId = 17 },
			{ name = "Feeblemind",     buttonId = 24 },
			{ name = "Heal",           buttonId = 31 },
			{ name = "Magic Arrow",    buttonId = 38 },
			{ name = "Night Sight",    buttonId = 45 },
			{ name = "Weaken",         buttonId = 52 },
		}
	},
	{
		name     = "Second Circle",
		buttonId = 8,
		manaCost = 6,
		spells   = {
			{ name = "Agility",      buttonId = 3  },
			{ name = "Cunning",      buttonId = 10 },
			{ name = "Cure",         buttonId = 17 },
			{ name = "Harm",         buttonId = 24 },
			{ name = "Magic Trap",   buttonId = 31 },
			{ name = "Magic Untrap", buttonId = 38 },
			{ name = "Protection",   buttonId = 45 },
			{ name = "Strength",     buttonId = 52 },
		}
	},
	{
		name     = "Third Circle",
		buttonId = 15,
		manaCost = 9,
		spells   = {
			{ name = "Bless",         buttonId = 3  },
			{ name = "Fireball",      buttonId = 10 },
			{ name = "Magic Lock",    buttonId = 17 },
			{ name = "Poison",        buttonId = 24 },
			{ name = "Telekinesis",   buttonId = 31 },
			{ name = "Teleport",      buttonId = 38 },
			{ name = "Unlock",        buttonId = 45 },
			{ name = "Wall Of Stone", buttonId = 52 },
		}
	},
	{
		name     = "Fourth Circle",
		buttonId = 22,
		manaCost = 11,
		spells   = {
			{ name = "Arch Cure",       buttonId = 3  },
			{ name = "Arch Protection", buttonId = 10 },
			{ name = "Curse",           buttonId = 17 },
			{ name = "Fire Field",      buttonId = 24 },
			{ name = "Greater Heal",    buttonId = 31 },
			{ name = "Lightning",       buttonId = 38 },
			{ name = "Mana Drain",      buttonId = 45 },
			{ name = "Recall",          buttonId = 52 },
		}
	},
	{
		name     = "Fifth Circle",
		buttonId = 29,
		manaCost = 14,
		spells   = {
			{ name = "Blade Spirits",    buttonId = 3  },
			{ name = "Dispel Field",     buttonId = 10 },
			{ name = "Incognito",        buttonId = 17 },
			{ name = "Magic Reflection", buttonId = 24 },
			{ name = "Mind Blast",       buttonId = 31 },
			{ name = "Paralyze",         buttonId = 38 },
			{ name = "Poison Field",     buttonId = 45 },
			{ name = "Summon Creature",  buttonId = 52 },
		}
	},
	{
		name     = "Sixth Circle",
		buttonId = 36,
		manaCost = 20,
		spells   = {
			{ name = "Dispel",         buttonId = 3  },
			{ name = "Energy Bolt",    buttonId = 10 },
			{ name = "Explosion",      buttonId = 17 },
			{ name = "Invisibility",   buttonId = 24 },
			{ name = "Mark",           buttonId = 31 },
			{ name = "Mass Curse",     buttonId = 38 },
			{ name = "Paralyze Field", buttonId = 45 },
			{ name = "Reveal",         buttonId = 52 },
		}
	},
	{
		name     = "Seventh Circle",
		buttonId = 43,
		manaCost = 40,
		spells   = {
			{ name = "Chain Lightning", buttonId = 3  },
			{ name = "Energy Field",    buttonId = 10 },
			{ name = "Flamestrike",     buttonId = 17 },
			{ name = "Gate Travel",     buttonId = 24 },
			{ name = "Mana Vampire",    buttonId = 31 },
			{ name = "Mass Dispel",     buttonId = 38 },
			{ name = "Meteor Swarm",    buttonId = 45 },
			{ name = "Polymorph",       buttonId = 52 },
		}
	},
	{
		name     = "Eighth Circle",
		buttonId = 50,
		manaCost = 50,
		spells   = {
			{ name = "Earthquake",            buttonId = 3  },
			{ name = "Energy Vortex",         buttonId = 10 },
			{ name = "Resurrection",          buttonId = 17 },
			{ name = "Summon Air Elemental",  buttonId = 24 },
			{ name = "Summon Daemon",         buttonId = 31 },
			{ name = "Summon Earth Elemental",buttonId = 38 },
			{ name = "Summon Fire Elemental", buttonId = 45 },
			{ name = "Summon Water Elemental",buttonId = 52 },
		}
	}
}

-- =============================================================================
-- PART 2: WINDOW AND CONTROLS
-- =============================================================================

UI.DestroyAllWindows()
window = UI.CreateWindow('inscriptionAssistant', "Proximo's Inscription Assistant v1.0")
window:SetPosition(200, 200)
window:SetSize(350, 500)

local off = 20
window:AddLabel(10, off, 'Crafting Menu'):SetColor(0.2, 0.8, 1, 1)

circle1Checkbox = window:AddCheckbox(10, off + 20, '1st Circle', false)
circle2Checkbox = window:AddCheckbox(10, off + 40, '2nd Circle', false)
circle3Checkbox = window:AddCheckbox(10, off + 60, '3rd Circle', false)
circle4Checkbox = window:AddCheckbox(10, off + 80, '4th Circle', false)
circle5Checkbox = window:AddCheckbox(10, off +100, '5th Circle', false)
circle6Checkbox = window:AddCheckbox(10, off +120, '6th Circle', false)
circle7Checkbox = window:AddCheckbox(10, off +140, '7th Circle', false)
circle8Checkbox = window:AddCheckbox(10, off +160, '8th Circle', false)

selectAllButton = window:AddButton(10, off +180, 'Select All', 150, 30)
selectSpellbookButton = window:AddButton(10, off +230, 'Select Spellbook', 150, 30)
spellbookLabel = window:AddLabel(10, off +280, 'No Spellbook Selected')
spellbookLabel:SetColor(1, 0.5, 0, 1)

startButton = window:AddButton(10, off +330, 'Start', 150, 30)
manaLabel = window:AddLabel(10, off +380, 'Mana:')
manaLabel:SetColor(1, 1, 1, 1)
manaBar = window:AddProgressBar(50, off +380, 110, 15, 0)
manaBar:SetColor(0,0,1,1)
statusTitleLabel = window:AddLabel(10, off +410, 'Status:')
statusTitleLabel:SetColor(1,1,1,1)
statusLabel = window:AddLabel(70, off +410, craftingStatus)
statusLabel:SetColor(1,1,1,1)

-- =============================================================================
-- PART 3: EVENT HANDLERS
-- =============================================================================

selectAllButton:SetOnClick(function()
	circle1Checkbox:SetChecked(true); craftCircle1 = true
	circle2Checkbox:SetChecked(true); craftCircle2 = true
	circle3Checkbox:SetChecked(true); craftCircle3 = true
	circle4Checkbox:SetChecked(true); craftCircle4 = true
	circle5Checkbox:SetChecked(true); craftCircle5 = true
	circle6Checkbox:SetChecked(true); craftCircle6 = true
	circle7Checkbox:SetChecked(true); craftCircle7 = true
	circle8Checkbox:SetChecked(true); craftCircle8 = true
	selectAllCirclesClicked = false
end)

selectSpellbookButton:SetOnClick(function()
	selectSpellBookClicked = true
end)

startButton:SetOnClick(function()
	startCraftingClicked = true
end)

circle1Checkbox:SetOnCheckedChanged(function(c) craftCircle1 = c end)
circle2Checkbox:SetOnCheckedChanged(function(c) craftCircle2 = c end)
circle3Checkbox:SetOnCheckedChanged(function(c) craftCircle3 = c end)
circle4Checkbox:SetOnCheckedChanged(function(c) craftCircle4 = c end)
circle5Checkbox:SetOnCheckedChanged(function(c) craftCircle5 = c end)
circle6Checkbox:SetOnCheckedChanged(function(c) craftCircle6 = c end)
circle7Checkbox:SetOnCheckedChanged(function(c) craftCircle7 = c end)
circle8Checkbox:SetOnCheckedChanged(function(c) craftCircle8 = c end)

-- =============================================================================
-- PART 4: SUPPORT FUNCTIONS
-- =============================================================================

local function updateCraftingStatus(message, colorName)
	local rgba = COLOR_MAP[colorName] or COLOR_MAP.White
	craftingStatus = message
	statusLabel:SetText(message)
	statusLabel:SetColor(table.unpack(rgba))
end

local function updateManaBar()
	local manaPercent = Player.Mana / Player.MaxMana
	manaBar:SetValue(manaPercent)
	manaBar:SetOverlay(Player.Mana .. '/' .. Player.MaxMana)
end

local function updateSpellbookLabel()
	spellbook = Items.FindBySerial(spellbookSerial)
	Pause(50)
	spellbookLabel:SetText(spellbook.Properties)
end

local function Meditate()
	Journal.Clear()
	Skills.Use('Meditation')
	Pause(700)
	if Journal.Contains('concentration') or Journal.Contains('few moments') or Journal.Contains('stop meditation') then
		Pause(1000)
        return Meditate()
	end
	if Journal.Contains('at peace') then 
        Pause(1000)
        return 
    end
	if Journal.Contains('trance') then 
        while Player.Mana < Player.MaxMana do 
            Pause(100)
            updateManaBar() 
        end 
    end
end

local function checkMana(threshold)
	updateManaBar()
	if Player.Mana <= threshold then
		updateCraftingStatus('Waiting for mana', 'Blue')
		Meditate()
	end
end

local function checkPen()
	local pens = Items.FindByFilter({ graphics = 0x0FBF })
	if not pens[1] then
		updateCraftingStatus('No pen found!', 'Red')
		return false
	end
	updateCraftingStatus('Using pen', 'Blue')
	Player.UseObject(pens[1].Serial)
	return true
end

local function checkScroll(name)
	for _, it in ipairs(Items.FindByFilter({ name = name, hues = { 0 } })) do
		if it.RootContainer == Player.Serial then 
            return it 
        end
	end
	return false
end

local function getCraftButtonId(index)
	return 2 + (index - 1) * 7
end

local function craftSpell(circle, spell, index, spellBookId)
	local craftBtn = getCraftButtonId(index)
	local success  = false

	while not success do
		checkMana(circle.manaCost)
		updateSpellbookLabel()

		if not Gumps.IsActive(INSCRIPTION_GUMP) then
			if not checkPen() then 
                goto continue 
            end
			if not Gumps.WaitForGump(INSCRIPTION_GUMP, 3000) then
				updateCraftingStatus('Inscription Gump retry', 'Red')
				goto continue
			end
		end

		Gumps.PressButton(INSCRIPTION_GUMP, circle.buttonId) 
        if not Gumps.WaitForGump(INSCRIPTION_GUMP, 2000) then 
            updateCraftingStatus('Circle retry', 'Orange') 
            Pause(1500) 
            goto continue 
        end 
        Pause(250)

		Gumps.PressButton(INSCRIPTION_GUMP, spell.buttonId) 
        if not Gumps.WaitForGump(INSCRIPTION_GUMP, 2000) then 
            updateCraftingStatus('Spell retry', 'Orange') 
            Pause(1500)
            goto continue 
        end 
        Pause(250)

		updateCraftingStatus('Crafting ' .. spell.name, 'White') 
        Gumps.PressButton(INSCRIPTION_GUMP, craftBtn) Pause(2000)

		local scroll = checkScroll(spell.name)
		if scroll then 
            success = true
            updateCraftingStatus('Success: ' .. spell.name, 'Green')
            Pause(800)
            Player.PickUp(scroll.Serial)
            Player.DropInContainer(spellBookId)
            Pause(50)
            updateSpellbookLabel()
		else updateCraftingStatus('Retrying: ' .. spell.name, 'Red')
            Pause(500) 
        end

		::continue::
	end
end

-- =============================================================================
-- PART 5: MAIN LOOP
-- =============================================================================

while true do
	updateManaBar()
    	requirementsMet = true

	if selectSpellBookClicked then
		spellbookSerial = Targeting.GetNewTarget(10000)
		spellbook = Items.FindBySerial(spellbookSerial)
		Pause(50)
		spellbookLabel:SetText(spellbook.Properties)
		spellbookLabel:SetColor(0, 1, 0, 1)
		selectSpellBookClicked = false
	end

	if startCraftingClicked then
        startCraftingClicked = false

        if not spellbookSerial then
            updateCraftingStatus('Error: Select a spellbook!', 'Red')
            requirementsMet = false 
        end

        if not (craftCircle1 or craftCircle2 or craftCircle3 or craftCircle4
            or craftCircle5 or craftCircle6 or craftCircle7 or craftCircle8) then
            updateCraftingStatus('Error: Select at least one circle!', 'Red')
            requirementsMet = false
        end
		
        if requirementsMet then
		    updateCraftingStatus('Crafting Started', 'Green')

		    local circleFlags = { craftCircle1, craftCircle2, craftCircle3, craftCircle4, craftCircle5, craftCircle6, craftCircle7, craftCircle8 }
		    for i, shouldCraft in ipairs(circleFlags) do
			    if shouldCraft then
				    updateCraftingStatus('Processing ' .. spellCircles[i].name, 'Green')
				    for si, sp in ipairs(spellCircles[i].spells) do craftSpell(spellCircles[i], sp, si, spellbook.Serial) end
			    end
		    end

		    updateCraftingStatus('Crafting Complete', 'Green')
		    updateSpellbookLabel()
        end
	end

	Pause(50)
end
