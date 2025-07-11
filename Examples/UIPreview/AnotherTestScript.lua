-- Improved Working Example - Based on your code but cleaner and easier to understand
-- This shows the same functionality as your example but with better organization

-- =============================================================================
-- PART 1: VARIABLES AND SETUP
-- =============================================================================

-- Flag to track when we should do something special
local shouldExecuteAction = false

-- Variables to hold our UI controls (so we can update them later)
local window = nil
local statusLabel = nil
local playerXLabel = nil
local clickButton = nil

-- =============================================================================
-- PART 2: CREATE THE WINDOW AND CONTROLS
-- =============================================================================

-- Create the main window
window = UI.CreateWindow('improvedExample', 'Improved UI Example')

if window then
    Messages.Print("✓ Window created successfully!")
    
    -- Set window position and size
    window:SetPosition(200, 200)
    window:SetSize(400, 300)
    
    -- Add a title
    local titleLabel = window:AddLabel(10, 10, 'Interactive UI Demo')
    titleLabel:SetColor(0.2, 0.8, 1, 1)  -- Light blue
    
    -- Add the main button
    clickButton = window:AddButton(30, 40, 'Click Me!', 100, 30)
    
    -- Add a status label to show what's happening
    statusLabel = window:AddLabel(10, 80, 'Status: Ready to go!')
    
    -- Add a text input box
    textBox = window:AddTextBox(10, 110, 200, 'Type here...')
    
    -- Add a checkbox
    checkbox = window:AddCheckbox(10, 140, 'Enable special feature', false)
    
    -- Add a slider
    slider = window:AddSlider(10, 170, 200, 0, 100, 50)
    
    -- Add labels to show live player position
    window:AddLabel(10, 200, 'Player X coordinate:')
    playerXLabel = window:AddLabel(150, 200, '0')
    
    Messages.Print("✓ All controls added!")
    
else
    Messages.Print("✗ Failed to create window - stopping here")
    return
end

-- =============================================================================
-- PART 3: SET UP EVENT HANDLERS (what happens when controls are used)
-- =============================================================================

-- When the main button is clicked
clickButton:SetOnClick(function()
    Messages.Print('Main button clicked!')
    statusLabel:SetText('Status: Button clicked - will execute action soon!')
    statusLabel:SetColor(1, 1, 0, 1)  -- Yellow color
    
    -- Set the flag so our main loop knows to do something special
    shouldExecuteAction = true
end)

-- When text is typed in the text box
textBox:SetOnTextChanged(function(newText)
    Messages.Print('You typed: ' .. newText)
    statusLabel:SetText('Status: Text changed to "' .. newText .. '"')
    statusLabel:SetColor(0, 1, 1, 1)  -- Cyan color
end)

-- When checkbox is checked or unchecked
checkbox:SetOnCheckedChanged(function(isChecked)
    if isChecked then
        Messages.Print('Special feature enabled!')
        statusLabel:SetText('Status: Special feature is ON')
        statusLabel:SetColor(0, 1, 0, 1)  -- Green color
    else
        Messages.Print('Special feature disabled!')
        statusLabel:SetText('Status: Special feature is OFF')
        statusLabel:SetColor(1, 0, 0, 1)  -- Red color
    end
end)

-- When slider value changes
slider:SetOnValueChanged(function(value)
    local roundedValue = math.floor(value)
    Messages.Print('Slider moved to: ' .. roundedValue)
    statusLabel:SetText('Status: Slider value = ' .. roundedValue)
    statusLabel:SetColor(0.5, 0.5, 1, 1)  -- Light purple
end)

-- =============================================================================
-- PART 4: MAIN LOOP (keeps the window updated and handles special actions)
-- =============================================================================

Messages.Print("✓ Starting main loop - window should be visible now!")
Messages.Print("Try interacting with the controls!")

-- This loop runs forever and keeps everything updated
while true do
    -- Update the player position display
    playerXLabel:SetText(tostring(Player.X))
    
    -- Check if we should execute our special action
    if shouldExecuteAction then
        shouldExecuteAction = false  -- Reset the flag
        
        -- Change status to show we're doing something
        statusLabel:SetText('Status: Executing special action...')
        statusLabel:SetColor(1, 0.5, 0, 1)  -- Orange color
        
        Messages.Print('🔄 Starting special action sequence...')
        
        -- Here's where you can put game actions that need to wait/yield
        -- (like using objects, waiting for gumps, etc.)
        
        -- Example actions (commented out since they use specific object IDs):
        Player.UseObject('1079060793')  -- Use some object
        Gumps.WaitForGump(0, 1000)     -- Wait for a gump to appear
        -- Player.PickUp(1087279029)      -- Pick up an item
        -- Player.DropInBackpack()        -- Drop it in backpack
        
        -- For this demo, we'll just wait a bit and show completion
        Pause(1000)  -- Wait 1 second
        
        statusLabel:SetText('Status: Special action completed!')
        statusLabel:SetColor(0, 1, 0, 1)  -- Green color
        
        Messages.Print('✅ Special action sequence completed!')
    end
    
    -- Wait a short time before the next update (50 milliseconds)
    Pause(50)
end

-- =============================================================================
-- NOTES FOR UNDERSTANDING:
-- =============================================================================
--
-- 1. The window and controls are created first
-- 2. Event handlers are set up to respond to user actions
-- 3. The main loop runs continuously to:
--    - Update live data (like player position)
--    - Check for special actions to execute
--    - Wait briefly to avoid using too much CPU
--
-- 4. The shouldExecuteAction flag is used because:
--    - Event handlers can't use "yielding" functions (like Pause, WaitForGump)
--    - The main loop CAN use yielding functions
--    - So events set a flag, and the main loop checks the flag
--
-- 5. Colors use RGBA values from 0 to 1:
--    - SetColor(1, 0, 0, 1) = Red
--    - SetColor(0, 1, 0, 1) = Green
--    - SetColor(0, 0, 1, 1) = Blue
--    - SetColor(1, 1, 1, 1) = White
--    - SetColor(0, 0, 0, 1) = Black
--
-- =============================================================================