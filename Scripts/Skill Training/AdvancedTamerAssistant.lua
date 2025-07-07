-- ===============================================
-- Advanced Tamer Assistant - Ultimate Edition
-- ===============================================
-- Version: 2.0
-- Author: 3HMonkey
-- Dependencies: None
-- Big thanks to the unknown author for the idea
-- ===============================================
-- QUICK SETUP GUIDE:
-- 1. Scroll down to the Config section (line ~40)
-- 2. Enable/disable kill modes (killAfterRelease, killTamedFirst)
-- 3. Set killMethod = "mage" or "melee" (how to kill?)
-- 4. If mage: Set mageSpell (EnergyBolt, Lightning, etc.)
-- 5. If melee: Set meleeWeaponType (sword, mace, bow, etc.)
-- 6. Configure ranges, timing, and behavior settings
-- 7. Add custom ignore names if needed
-- 8. Save and run the script!
--
-- FEATURES:
-- * Auto-tame nearby creatures with smart targeting
-- * Kill already tamed pets in area before taming (optional)
-- * Rename pets with custom suffix/name system
-- * Auto-release tamed pets after successful taming
-- * Kill released pets (mage spells or melee attacks)
-- * Smart ignore system for problematic targets
-- * Overhead messages and real-time status updates
-- * Comprehensive debug logging and error handling
-- * Highly configurable timing, ranges, and behavior
-- * Configuration validation with helpful error messages
--
-- ===============================================
local TamerAssistant = {}

-- ===============================================
-- === SETUP & CONFIGURATION BLOCK ===
-- ===============================================
-- Customize these settings to fit your playstyle!

local Config = {
    -- ========== CORE BEHAVIOR ==========
    renameAfterTame = true,           -- Rename pets after taming?
    renameSuffix = "KillMe",            -- What suffix/name to use
    autoRelease = true,               -- Auto-release pets after taming?
    repeatAfterTame = true,           -- Keep running after successful tame?
    ignoreAfterSuccessfulTame = true, -- Ignore mobs after successful tame?
    
    -- ========== KILL SETTINGS ==========
    -- Primary Kill Options
    killAfterRelease = true,          -- Kill pets immediately after releasing them?
    killTamedFirst = true,            -- Kill already tamed pets in area before starting to tame?
    killMethod = "mage",              -- How to kill: "mage", "melee", or "none"
    
    -- Mage Kill Settings (if killMethod = "mage")
    mageSpell = "EnergyBolt",         -- Spell to cast: "EnergyBolt", "Lightning", "Flamestrike", "Explosion", etc.
    mageReagentCheck = true,          -- Verify you have reagents before attempting to cast?
    mageAutoMeditate = false,         -- Auto-meditate if low on mana? (experimental)
    
    -- Melee Kill Settings (if killMethod = "melee") 
    meleeWeaponType = "any",          -- Weapon preference: "any", "sword", "mace", "bow", "xbow"
    autoEquipWeapon = true,           -- Automatically equip weapon if none wielded?
    meleeAutoHeal = false,            -- Auto-heal if low on health? (experimental)
    
    -- Kill Timing & Behavior
    killTimeout = 8000,               -- Max time to spend killing one target (milliseconds)
    killRetries = 3,                  -- Max attack/spell attempts per target before giving up
    waitAfterKill = 1000,             -- Pause after successful kill before continuing (milliseconds)
    killTamedRange = 3,               -- Range to look for already tamed pets to kill (tiles)
    killTamedMaxTargets = 5,          -- Max number of tamed pets to kill per cycle
    
    -- ========== TIMING CONTROL ==========
    -- Main Loop Timing
    scanDelay = 400,                  -- Delay when no mobs found (milliseconds)
    pollingDelay = 200,               -- Delay between journal checks during taming (milliseconds)
    betweenAttemptsDelay = 600,       -- Delay after successful tame before next cycle (milliseconds)
    smallStepDelay = 100,             -- General small pause for various operations (milliseconds)
    
    -- ========== DISPLAY OPTIONS ==========
    -- Visual Feedback Settings  
    showOverheadMessages = true,      -- Display floating messages above mobs?
    showStatusMessages = true,        -- Show periodic status updates in chat?
    statusMessageInterval = 5,        -- How often to show status updates (seconds)
    showKillMessages = true,          -- Display messages during kill attempts?
    showTamedKillMessages = true,     -- Show messages when killing already tamed pets?
    
    -- ========== MESSAGE COOLDOWNS ==========
    -- Prevents spam by limiting how often messages appear
    killMeCooldown = 3,               -- "Kill me" overhead message cooldown (seconds)
    cantTameCooldown = 5,             -- "Can't tame" overhead message cooldown (seconds)
    tameSkipCooldown = 10,            -- "Already tamed" overhead message cooldown (seconds)
    tooManyFollowersCooldown = 5,     -- "Too many followers" message cooldown (seconds)
    
    -- ========== RELEASE SETTINGS ==========
    -- Gump handling for pet release confirmation
    releaseGumpId = 3432224886,       -- Expected gump ID for release confirmation dialog
    releaseButtonId = 2,              -- Button ID to click for confirming release
    
    -- ========== RANGE & IGNORE SETTINGS ==========
    -- Distance and Targeting Control
    scanRange = 10,                   -- Range to scan for mobs and show overhead messages (tiles)
    tameRange = 2,                    -- Range to look for tameable mobs (tiles)
    killRange = 1,                    -- Range to attack released pets (tiles)
    
    -- Ignore System Configuration
    ignoreDuration = 15,              -- How long to temporarily ignore failed mobs (seconds)
    ignoreNoChancePermanently = true, -- Permanently ignore mobs that can't be tamed?
    
    -- ========== CUSTOM IGNORE LIST ==========
    -- Add mob names here that you NEVER want to tame
    customIgnoreNames = {
        "IgnoreMe1",
        "IgnoreMe2", 
        "IgnoreMe3",
        -- "Add more names here",
    },
    
    -- ========== ADVANCED SETTINGS ==========
    debugMode = false,                -- Show debug messages?
    maxTameAttempts = 5,              -- Max tame attempts per mob before giving up
    smartTargeting = true,            -- Prefer closer/easier targets?
}

-- === State Management ===
local State = {
    ignoreList = {},
    cooldowns = {},
    tamedCount = 0,
    lastStatusPrint = 0,
    isRunning = false,
    killCount = 0,
    errors = {},
    startTime = 0
}

-- === Configuration Validation ===
local function validateConfig()
    local errors = {}
    
    -- Validate kill method
    if Config.killAfterRelease then
        local validMethods = {"mage", "melee", "none"}
        local validMethod = false
        for _, method in ipairs(validMethods) do
            if Config.killMethod == method then
                validMethod = true
                break
            end
        end
        if not validMethod then
            table.insert(errors, "Invalid killMethod: " .. Config.killMethod .. ". Must be 'mage', 'melee', or 'none'")
        end
        
        -- Validate mage spell
        if Config.killMethod == "mage" then
            local validSpells = {"EnergyBolt", "Lightning", "Flamestrike", "Explosion", "MagicArrow", "Fireball", "Harm"}
            local validSpell = false
            for _, spell in ipairs(validSpells) do
                if Config.mageSpell == spell then
                    validSpell = true
                    break
                end
            end
            if not validSpell then
                table.insert(errors, "Unknown mageSpell: " .. Config.mageSpell)
            end
        end
        
        -- Validate weapon type
        if Config.killMethod == "melee" then
            local validWeapons = {"any", "sword", "mace", "bow", "xbow"}
            local validWeapon = false
            for _, weapon in ipairs(validWeapons) do
                if Config.meleeWeaponType == weapon then
                    validWeapon = true
                    break
                end
            end
            if not validWeapon then
                table.insert(errors, "Invalid meleeWeaponType: " .. Config.meleeWeaponType)
            end
        end
    end
    
    -- Validate ranges
    if Config.tameRange > Config.scanRange then
        table.insert(errors, "tameRange cannot be greater than scanRange")
    end
    
    if Config.killRange > Config.tameRange then
        table.insert(errors, "killRange should not be greater than tameRange")
    end
    
    return errors
end

-- === Debug and Styling Functions ===
local function debugPrint(message, category)
    if not Config.debugMode then return end
    
    local timestamp = string.format("%.2f", getCurrentTime() % 100)
    local prefix = "[DEBUG " .. timestamp .. "]"
    
    if category then
        prefix = prefix .. " [" .. string.upper(category) .. "]"
    end
    
    printStatus(prefix .. " " .. message, 90)
end

local function printBanner(text, color, symbol)
    color = color or 68
    symbol = symbol or "="
    local bannerLine = string.rep(symbol, 50)
    Messages.Print(bannerLine, color)
    Messages.Print("  " .. text, color)
    Messages.Print(bannerLine, color)
end

local function printSection(title, color)
    color = color or 89
    Messages.Print("--- " .. title .. " ---", color)
end

local function printSuccess(message)
    Messages.Print("[OK] " .. message, 68)
end

local function printWarning(message)
    Messages.Print("[WARN] " .. message, 38)
end

local function printError(message)
    Messages.Print("[ERROR] " .. message, 33)
end

local function printInfo(message, color)
    Messages.Print("[INFO] " .. message, color or 89)
end

local function printStatus(message, color)
    Messages.Print(message, color or 89)
end

-- === Utility Functions ===
local function getCurrentTime()
    return os.clock()
end

local function isOnCooldown(key, duration)
    local lastTime = State.cooldowns[key] or 0
    return (getCurrentTime() - lastTime) < duration
end

local function setCooldown(key)
    State.cooldowns[key] = getCurrentTime()
end

local function shouldIgnoreMob(mob)
    local now = getCurrentTime()
    local ignoreData = State.ignoreList[mob.Serial]
    
    -- Check permanent ignore
    if ignoreData == true then
        return true
    end
    
    -- Check temporary ignore
    if ignoreData and now < ignoreData then
        return true
    end
    
    -- Check custom ignore names
    if mob.Name then
        local mobNameLower = mob.Name:lower()
        for _, ignoreName in ipairs(Config.customIgnoreNames) do
            if mobNameLower == ignoreName:lower() then
                return true
            end
        end
    end
    
    -- Check if already tamed (has suffix)
    if mob.Name and mob.Name:find(Config.renameSuffix) then
        return true
    end
    
    return false
end

local function addToIgnoreList(serial, permanent)
    if permanent then
        State.ignoreList[serial] = true
    else
        State.ignoreList[serial] = getCurrentTime() + Config.ignoreDuration
    end
end

-- === Display Functions ===
local function printHeader()
    printBanner("Advanced Tamer Assistant v2.0 - Ultimate Edition", 68)
    
    printSection("Configuration Status", 89)
    printInfo("Rename Suffix: " .. Config.renameSuffix)
    printInfo("Auto Release: " .. (Config.autoRelease and "[ON]" or "[OFF]"))
    printInfo("Kill After Release: " .. (Config.killAfterRelease and "[ON]" or "[OFF]"))
    printInfo("Kill Tamed First: " .. (Config.killTamedFirst and "[ON]" or "[OFF]"))
    printInfo("Kill Method: " .. (Config.killMethod ~= "none" and Config.killMethod or "disabled"))
    
    if Config.killMethod == "mage" then
        printInfo("Spell: " .. Config.mageSpell)
        printInfo("Reagent Check: " .. (Config.mageReagentCheck and "[ON]" or "[OFF]"))
    elseif Config.killMethod == "melee" then
        printInfo("Weapon Type: " .. Config.meleeWeaponType)
        printInfo("Auto Equip: " .. (Config.autoEquipWeapon and "[ON]" or "[OFF]"))
    end
    
    printInfo("Ranges: Scan=" .. Config.scanRange .. ", Tame=" .. Config.tameRange .. ", Kill=" .. Config.killRange .. ", TamedKill=" .. Config.killTamedRange)
    printInfo("Debug Mode: " .. (Config.debugMode and "[ON]" or "[OFF]"))
    
    printSuccess("Initialized and ready to tame!")
    
    if #Config.customIgnoreNames > 0 then
        printSection("Custom Ignore List", 38)
        for _, name in ipairs(Config.customIgnoreNames) do
            printWarning("Ignoring: " .. name)
        end
    end
    
    Messages.Print("", 89) -- Empty line for spacing
end

local function showOverheadMessage(message, color, serial)
    if not Config.showOverheadMessages then return end
    Messages.Overhead(message, color, serial)
end

local function printStatus(message, color)
    Messages.Print(message, color or 89)
end

local function showStatusIfNeeded()
    local now = getCurrentTime()
    if Config.showStatusMessages and 
       (now - State.lastStatusPrint) >= Config.statusMessageInterval then
        local uptime = math.floor(now - (State.startTime or now))
        printInfo("Scanning... [Uptime: " .. uptime .. "s | Tamed: " .. State.tamedCount .. " | Killed: " .. State.killCount .. "]")
        State.lastStatusPrint = now
    end
end

-- === Mob Finding and Filtering ===
local function findNearbyMobs(range)
    local mobs = Mobiles.FindByFilter({
        rangemax = range,
        dead = false,
        human = false
    }) or {}
    
    return type(mobs) == "table" and mobs or {}
end

local function getUntamedMobs()
    local allMobs = findNearbyMobs(Config.tameRange)
    local untamed = {}
    
    debugPrint("Found " .. #allMobs .. " total mobs in range " .. Config.tameRange, "SCAN")
    
    for _, mob in ipairs(allMobs) do
        if mob.Name and mob.Name ~= "" then
            if shouldIgnoreMob(mob) then
                debugPrint("Ignoring mob: " .. mob.Name .. " (Serial: " .. mob.Serial .. ")", "FILTER")
            else
                debugPrint("Adding tameable mob: " .. mob.Name .. " (Distance: " .. mob.Distance .. ")", "FILTER")
                table.insert(untamed, mob)
            end
        else
            debugPrint("Skipping unnamed mob (Serial: " .. mob.Serial .. ")", "FILTER")
        end
    end
    
    -- Sort by distance (closest first)
    table.sort(untamed, function(a, b) 
        return a.Distance < b.Distance 
    end)
    
    debugPrint("Final untamed count: " .. #untamed, "SCAN")
    return untamed
end

-- === Overhead Message Management ===
local function processOverheadMessages()
    if not Config.showOverheadMessages then return end
    
    local nearbyMobs = findNearbyMobs(Config.scanRange)
    local now = getCurrentTime()
    
    for _, mob in ipairs(nearbyMobs) do
        local serial = mob.Serial
        
        -- Show "Already Tamed" for renamed pets
        if mob.Name and mob.Name:find(Config.renameSuffix) then
            if not isOnCooldown("tamed_" .. serial, Config.tameSkipCooldown) then
                showOverheadMessage("Already Tamed... Skipping", 38, serial)
                setCooldown("tamed_" .. serial)
            end
        end
        
        -- Show "Can't tame" for permanently ignored mobs
        if State.ignoreList[serial] == true then
            if not isOnCooldown("cant_tame_" .. serial, Config.cantTameCooldown) then
                showOverheadMessage("Can't tame!", 53, serial)
                setCooldown("cant_tame_" .. serial)
            end
        end
    end
end

-- === Pet Management ===
local function renamePet(mob)
    if not Config.renameAfterTame or not mob.Name then 
        debugPrint("Skipping rename - not configured or no name", "RENAME")
        return mob.Name
    end
    
    local originalName = mob.Name
    local newName
    
    debugPrint("Renaming pet: " .. originalName, "RENAME")
    
    if originalName:lower():match("^a%s") then
        newName = Config.renameSuffix
        debugPrint("Detected 'a/an' prefix, using suffix only: " .. newName, "RENAME")
    else
        originalName = originalName:gsub("%s+", "")
        newName = originalName .. Config.renameSuffix
        debugPrint("Appending suffix: " .. originalName .. " -> " .. newName, "RENAME")
    end
    
    Mobiles.Rename(mob.Serial, newName)
    printSuccess("Renamed: " .. originalName .. " -> " .. newName)
    debugPrint("Rename command sent to server", "RENAME")
    return newName
end

-- === Kill Functions ===
local function hasReagentsForSpell(spellName)
    if not Config.mageReagentCheck then return true end
    
    -- Basic reagent check - you may need to customize this based on your server
    local reagentMap = {
        ["EnergyBolt"] = {"Black Pearl", "Nightshade"},
        ["Lightning"] = {"Mandrake Root", "Sulfurous Ash"},
        ["Flamestrike"] = {"Spiders Silk", "Sulfurous Ash"},
        ["Explosion"] = {"Blood Moss", "Mandrake Root"},
        ["MagicArrow"] = {"Sulfurous Ash"},
        ["Fireball"] = {"Black Pearl"},
        ["Harm"] = {"Nightshade", "Spiders Silk"}
    }
    
    local requiredReagents = reagentMap[spellName]
    if not requiredReagents then return true end -- Unknown spell, assume we have reagents
    
    -- This is a simplified check - you may need to implement proper reagent counting
    return true -- For now, assume we always have reagents
end

local function findBestWeapon()
    if not Config.autoEquipWeapon then return nil end
    
    -- Find weapon in backpack based on preference
    local weaponTypes = {
        sword = {0x13B9, 0x13BA, 0x13BB, 0x13BE, 0x13BF, 0x13C6, 0x13C7},
        mace = {0x13B4, 0x13B0, 0x13AF, 0x13B1, 0x143D, 0x143E},
        bow = {0x13B1, 0x13B2},
        xbow = {0x0F4F, 0x13FC}
    }
    
    local searchTypes = {}
    if Config.meleeWeaponType == "any" then
        for _, types in pairs(weaponTypes) do
            for _, typeId in ipairs(types) do
                table.insert(searchTypes, typeId)
            end
        end
    elseif weaponTypes[Config.meleeWeaponType] then
        searchTypes = weaponTypes[Config.meleeWeaponType]
    end
    
    -- Simple weapon finding - you may need to customize this
    -- This is a placeholder that would need proper implementation
    return nil
end

local function castSpellOnTarget(spellName, targetSerial)
    debugPrint("Checking reagents for spell: " .. spellName, "KILL")
    
    if not hasReagentsForSpell(spellName) then
        printWarning("No reagents for " .. spellName)
        debugPrint("Reagent check failed", "KILL")
        return false
    end
    
    debugPrint("Casting " .. spellName .. " on target " .. targetSerial, "KILL")
    
    -- Cast the spell
    Spells.Cast(spellName)
    debugPrint("Spell cast command sent", "KILL")
    
    if Targeting.WaitForTarget(3000) then
        Targeting.Target(targetSerial)
        debugPrint("Target acquired for spell", "KILL")
        if Config.showKillMessages then
            printInfo("[MAGIC] Casting " .. spellName .. "...")
        end
        return true
    else
        printError("Failed to acquire target for " .. spellName)
        debugPrint("Targeting timeout after 3 seconds", "KILL")
        return false
    end
end

local function meleeAttackTarget(targetSerial)
    debugPrint("Starting melee attack on target " .. targetSerial, "KILL")
    
    local weapon = findBestWeapon()
    if weapon and Config.autoEquipWeapon then
        debugPrint("Found weapon, attempting to equip", "KILL")
        -- Equip weapon logic would go here
    else
        debugPrint("No weapon found or auto-equip disabled", "KILL")
    end
    
    debugPrint("Executing attack command", "KILL")
    
    -- Perform attack - try available API methods
    local attackSuccess = false
    
    -- Try Player.Attack first
    if Player and Player.Attack then
        Player.Attack(targetSerial)
        attackSuccess = true
        debugPrint("Used Player.Attack method", "KILL")
    -- Try Targeting.Attack
    elseif Targeting and Targeting.Attack then
        Targeting.Attack(targetSerial)
        attackSuccess = true
        debugPrint("Used Targeting.Attack method", "KILL")
    else
        -- Fallback: try to target the serial (some engines may auto-attack on target)
        if Targeting and Targeting.Target then
            Targeting.Target(targetSerial)
            debugPrint("Fallback: targeted serial (may auto-attack)", "KILL")
            attackSuccess = true
        else
            debugPrint("No attack or targeting method available", "KILL")
            attackSuccess = false
        end
    end
    
    if Config.showKillMessages then
        printInfo("[MELEE] Attacking...")
    end
    
    debugPrint("Melee attack command sent", "KILL")
    return attackSuccess
end

local function isTargetDead(targetSerial)
    local target = Mobiles.FindBySerial(targetSerial)
    return not target or target.Dead or target.Hits <= 0
end

local function killReleasedPet(targetSerial, petName)
    if not Config.killAfterRelease or Config.killMethod == "none" then
        debugPrint("Kill after release disabled or method is 'none'", "KILL")
        return
    end
    
    debugPrint("Starting kill process for pet: " .. petName .. " (Serial: " .. targetSerial .. ")", "KILL")
    printSection("Kill Phase - " .. Config.killMethod:upper(), 38)
    
    if Config.showKillMessages then
        printInfo("Target: " .. petName .. " | Method: " .. Config.killMethod)
    end
    
    local startTime = getCurrentTime()
    local attempts = 0
    local lastAttackTime = 0
    
    while attempts < Config.killRetries and 
          (getCurrentTime() - startTime) * 1000 < Config.killTimeout do
        
        local elapsed = math.floor((getCurrentTime() - startTime) * 1000)
        debugPrint("Kill attempt " .. (attempts + 1) .. "/" .. Config.killRetries .. " (Elapsed: " .. elapsed .. "ms)", "KILL")
        
        -- Check if target is dead
        if isTargetDead(targetSerial) then
            State.killCount = State.killCount + 1
            printSuccess("Pet eliminated! (Kill #" .. State.killCount .. ")")
            debugPrint("Target confirmed dead, kill successful", "KILL")
            Pause(Config.waitAfterKill)
            return
        end
        
        -- Check if we're in range
        local target = Mobiles.FindBySerial(targetSerial)
        if not target then
            debugPrint("Target not found, assuming dead or despawned", "KILL")
            printWarning("Target vanished - assuming dead")
            return
        end
        
        if target.Distance > Config.killRange then
            printWarning("Pet moved out of range (" .. target.Distance .. " > " .. Config.killRange .. "), aborting kill")
            debugPrint("Target distance: " .. target.Distance .. ", max range: " .. Config.killRange, "KILL")
            return
        end
        
        debugPrint("Target in range (" .. target.Distance .. " tiles), proceeding with attack", "KILL")
        
        -- Throttle attacks/spells
        local now = getCurrentTime()
        if now - lastAttackTime < 1.5 then -- 1.5 second cooldown between attempts
            debugPrint("Attack cooldown active, waiting...", "KILL")
            Pause(100)
            goto continue
        end
        
        lastAttackTime = now
        attempts = attempts + 1
        
        local success = false
        if Config.killMethod == "mage" then
            debugPrint("Attempting mage kill with " .. Config.mageSpell, "KILL")
            success = castSpellOnTarget(Config.mageSpell, targetSerial)
        elseif Config.killMethod == "melee" then
            debugPrint("Attempting melee kill", "KILL")
            success = meleeAttackTarget(targetSerial)
        end
        
        if success then
            debugPrint("Attack successful, waiting for damage resolution", "KILL")
            Pause(1500) -- Wait for damage to be dealt
        else
            debugPrint("Attack failed, short pause before retry", "KILL")
            Pause(500)
        end
        
        ::continue::
    end
    
    -- If we get here, we failed to kill in time
    printError("Kill timeout - gave up after " .. attempts .. " attempts")
    debugPrint("Kill failed: " .. attempts .. " attempts over " .. math.floor((getCurrentTime() - startTime) * 1000) .. "ms", "KILL")
end

local function findTamedPetsInRange()
    if not Config.killTamedFirst then 
        debugPrint("Kill tamed first disabled", "TAMED_KILL")
        return {}
    end
    
    local nearbyMobs = findNearbyMobs(Config.killTamedRange)
    local tamedPets = {}
    
    debugPrint("Scanning " .. #nearbyMobs .. " mobs in range " .. Config.killTamedRange .. " for tamed pets", "TAMED_KILL")
    
    for _, mob in ipairs(nearbyMobs) do
        if mob.Name and mob.Name ~= "" then
            -- Check if mob has the tamed suffix or looks like a renamed pet
            local hasSuffix = mob.Name:find(Config.renameSuffix)
            local isPlayerNamed = not mob.Name:match("^[Aa]n? ") -- Not starting with "a " or "an "
            
            if hasSuffix or (isPlayerNamed and not shouldIgnoreMob(mob)) then
                debugPrint("Found potential tamed pet: " .. mob.Name .. " (Distance: " .. mob.Distance .. ")", "TAMED_KILL")
                table.insert(tamedPets, mob)
                
                if #tamedPets >= Config.killTamedMaxTargets then
                    debugPrint("Reached max tamed targets limit: " .. Config.killTamedMaxTargets, "TAMED_KILL")
                    break
                end
            end
        end
    end
    
    -- Sort by distance (closest first)
    table.sort(tamedPets, function(a, b) return a.Distance < b.Distance end)
    
    debugPrint("Found " .. #tamedPets .. " tamed pets to kill", "TAMED_KILL")
    return tamedPets
end

local function killTamedPet(target)
    if not Config.killTamedFirst or Config.killMethod == "none" then
        return false
    end
    
    debugPrint("Starting kill process for tamed pet: " .. target.Name .. " (Serial: " .. target.Serial .. ")", "TAMED_KILL")
    
    if Config.showTamedKillMessages then
        printSection("Killing Tamed Pet: " .. target.Name, 38)
        printInfo("Target: " .. target.Name .. " | Distance: " .. target.Distance)
    end
    
    local startTime = getCurrentTime()
    local attempts = 0
    local lastAttackTime = 0
    
    while attempts < Config.killRetries and 
          (getCurrentTime() - startTime) * 1000 < Config.killTimeout do
        
        local elapsed = math.floor((getCurrentTime() - startTime) * 1000)
        debugPrint("Tamed kill attempt " .. (attempts + 1) .. "/" .. Config.killRetries .. " (Elapsed: " .. elapsed .. "ms)", "TAMED_KILL")
        
        -- Check if target is dead
        if isTargetDead(target.Serial) then
            State.killCount = State.killCount + 1
            if Config.showTamedKillMessages then
                printSuccess("Tamed pet eliminated! (Kill #" .. State.killCount .. ")")
            end
            debugPrint("Tamed pet confirmed dead, kill successful", "TAMED_KILL")
            Pause(Config.waitAfterKill)
            return true
        end
        
        -- Check if target is still in range
        local currentTarget = Mobiles.FindBySerial(target.Serial)
        if not currentTarget then
            debugPrint("Tamed target not found, assuming dead or despawned", "TAMED_KILL")
            if Config.showTamedKillMessages then
                printWarning("Target vanished - assuming dead")
            end
            return true
        end
        
        if currentTarget.Distance > Config.killTamedRange then
            if Config.showTamedKillMessages then
                printWarning("Tamed pet moved out of range (" .. currentTarget.Distance .. " > " .. Config.killTamedRange .. "), aborting")
            end
            debugPrint("Tamed target distance: " .. currentTarget.Distance .. ", max range: " .. Config.killTamedRange, "TAMED_KILL")
            return false
        end
        
        debugPrint("Tamed target in range (" .. currentTarget.Distance .. " tiles), proceeding with attack", "TAMED_KILL")
        
        -- Throttle attacks/spells  
        local now = getCurrentTime()
        if now - lastAttackTime < 1.5 then -- 1.5 second cooldown between attempts
            debugPrint("Attack cooldown active, waiting...", "TAMED_KILL")
            Pause(100)
            goto continue
        end
        
        lastAttackTime = now
        attempts = attempts + 1
        
        local success = false
        if Config.killMethod == "mage" then
            debugPrint("Attempting mage kill on tamed pet with " .. Config.mageSpell, "TAMED_KILL")
            success = castSpellOnTarget(Config.mageSpell, target.Serial)
        elseif Config.killMethod == "melee" then
            debugPrint("Attempting melee kill on tamed pet", "TAMED_KILL")
            success = meleeAttackTarget(target.Serial)
        end
        
        if success then
            debugPrint("Attack successful, waiting for damage resolution", "TAMED_KILL")
            Pause(1500) -- Wait for damage to be dealt
        else
            debugPrint("Attack failed, short pause before retry", "TAMED_KILL")
            Pause(500)
        end
        
        ::continue::
    end
    
    -- If we get here, we failed to kill in time
    if Config.showTamedKillMessages then
        printError("Tamed kill timeout - gave up after " .. attempts .. " attempts")
    end
    debugPrint("Tamed kill failed: " .. attempts .. " attempts over " .. math.floor((getCurrentTime() - startTime) * 1000) .. "ms", "TAMED_KILL")
    return false
end

local function killAllTamedPetsInRange()
    if not Config.killTamedFirst or Config.killMethod == "none" then
        debugPrint("Kill tamed first disabled or kill method is none", "TAMED_KILL")
        return 0
    end
    
    local tamedPets = findTamedPetsInRange()
    if #tamedPets == 0 then
        debugPrint("No tamed pets found in range", "TAMED_KILL")
        return 0
    end
    
    if Config.showTamedKillMessages then
        printSection("Clearing Tamed Pets", 38)
        printInfo("Found " .. #tamedPets .. " tamed pets to eliminate")
    end
    
    local killedCount = 0
    for _, pet in ipairs(tamedPets) do
        if killTamedPet(pet) then
            killedCount = killedCount + 1
            debugPrint("Successfully killed tamed pet " .. killedCount .. "/" .. #tamedPets, "TAMED_KILL")
        else
            debugPrint("Failed to kill tamed pet: " .. pet.Name, "TAMED_KILL")
        end
        
        -- Small pause between kills
        Pause(200)
    end
    
    if Config.showTamedKillMessages and killedCount > 0 then
        printSuccess("Eliminated " .. killedCount .. "/" .. #tamedPets .. " tamed pets")
    end
    
    debugPrint("Tamed pet killing phase complete: " .. killedCount .. "/" .. #tamedPets .. " killed", "TAMED_KILL")
    return killedCount
end

local function releasePet(petName, targetSerial)
    if not Config.autoRelease then 
        debugPrint("Auto-release disabled, keeping pet", "RELEASE")
        return true 
    end
    
    debugPrint("Starting release process for: " .. petName, "RELEASE")
    printInfo("Releasing tamed creature: " .. petName, 20)
    
    Player.Say(petName .. " release")
    debugPrint("Sent release command: '" .. petName .. " release'", "RELEASE")
    Pause(500)
    
    if Gumps.WaitForGump(Config.releaseGumpId, 1000) then
        debugPrint("Release gump appeared, pressing button " .. Config.releaseButtonId, "RELEASE")
        Gumps.PressButton(Config.releaseGumpId, Config.releaseButtonId)
        printSuccess("Pet released successfully")
        
        -- Kill the pet after release if enabled
        if Config.killAfterRelease and Config.killMethod ~= "none" then
            debugPrint("Kill after release enabled, starting kill process", "RELEASE")
            Pause(500) -- Small delay to ensure release is processed
            killReleasedPet(targetSerial, petName)
        else
            debugPrint("Kill after release disabled or method is 'none'", "RELEASE")
        end
        return true
    else
        printError("Release gump not found - pet may not have been released")
        debugPrint("Expected gump ID: " .. Config.releaseGumpId, "RELEASE")
        return false
    end
end

-- === Journal Processing ===
local function processJournalMessages(target)
    local now = getCurrentTime()
    
    -- Too many followers
    if Journal.Contains("You have too many followers to tame that creature.") then
        if not isOnCooldown("too_many_followers", Config.tooManyFollowersCooldown) then
            showOverheadMessage("Too many followers!", 38, Player.Serial)
            printStatus("Too many followers — taming not possible.", 38)
            setCooldown("too_many_followers")
        end
        return "too_many_followers"
    end
    
    -- No chance to tame
    if Journal.Contains("You have no chance of taming this creature.") or 
       Journal.Contains("That animal looks tame already") then
        if not isOnCooldown("cant_tame_" .. target.Serial, Config.cantTameCooldown) then
            showOverheadMessage("Can't tame!", 53, target.Serial)
            setCooldown("cant_tame_" .. target.Serial)
        end
        printStatus("No chance to tame — ignoring mob.", 38)
        addToIgnoreList(target.Serial, Config.ignoreNoChancePermanently)
        return "no_chance"
    end
    
    -- Successful tame
    if Journal.Contains("It seems to accept you as master") or 
       Journal.Contains("You tame the creature.") or 
       Journal.Contains("That wasn't even challenging") then
        return "success"
    end
    
    -- Failed tame
    if Journal.Contains("You fail to tame the creature.") then
        printStatus("Taming failed. Trying again...", 20)
        return "failed"
    end
    
    -- Beast angered
    if Journal.Contains("You seem to anger the beast") then
        printStatus("The beast was angered.", 20)
        return "angered"
    end
    
    -- Too far away
    if Journal.Contains("That is too far away.") then
        printStatus("Target too far. Skipping...", 38)
        return "too_far"
    end
    
    -- Too many owners
    if Journal.Contains("This animal has had too many owners") then
        if not isOnCooldown("kill_me_" .. target.Serial, Config.killMeCooldown) then
            showOverheadMessage("Kill me", 33, target.Serial)
            setCooldown("kill_me_" .. target.Serial)
        end
        printStatus("Too many owners — marked for death.", 38)
        addToIgnoreList(target.Serial, true)
        return "too_many_owners"
    end
    
    return "continue"
end

-- === Taming Logic ===
local function attemptTame(target)
    debugPrint("Starting tame attempt on: " .. target.Name .. " (Serial: " .. target.Serial .. ", Distance: " .. target.Distance .. ")", "TAME")
    printSection("Taming: " .. target.Name, 68)
    
    Journal.Clear()
    debugPrint("Journal cleared, using Animal Taming skill", "TAME")
    Skills.Use("Animal Taming")
    
    if not Targeting.WaitForTarget(2000) then
        printError("Targeting cursor failed - skipping creature")
        debugPrint("WaitForTarget returned false after 2000ms", "TAME")
        return false
    end
    
    debugPrint("Targeting cursor acquired, targeting mob", "TAME")
    Targeting.Target(target.Serial)
    printInfo("Taming " .. target.Name .. "...")
    
    local timeout = 15000
    local elapsed = 0
    local startTime = getCurrentTime()
    
    while elapsed < timeout do
        local result = processJournalMessages(target)
        debugPrint("Journal result: " .. result .. " (Elapsed: " .. elapsed .. "ms)", "TAME")
        
        if result == "success" then
            State.tamedCount = State.tamedCount + 1
            printSuccess("Taming successful! (Total: " .. State.tamedCount .. ")")
            debugPrint("Tame successful, starting post-tame process", "TAME")
            
            local petName = renamePet(target) or target.Name or "Unknown"
            releasePet(petName, target.Serial)
            
            if Config.ignoreAfterSuccessfulTame then
                debugPrint("Adding tamed mob to ignore list", "TAME")
                addToIgnoreList(target.Serial, true)
            end
            
            return true
            
        elseif result == "failed" then
            printWarning("Taming failed - will retry")
            debugPrint("Tame failed, but will continue trying", "TAME")
            
        elseif result == "angered" then
            printWarning("Beast angered - continuing")
            debugPrint("Beast angered, continuing tame attempts", "TAME")
            
        elseif result ~= "continue" then
            -- All other results mean we should stop trying this mob
            debugPrint("Journal result indicates we should stop: " .. result, "TAME")
            return false
        end
        
        Pause(Config.pollingDelay)
        elapsed = elapsed + Config.pollingDelay
    end
    
    printError("Taming timeout (" .. (timeout/1000) .. "s)")
    debugPrint("Taming attempt timed out after " .. timeout .. "ms", "TAME")
    return false
end

-- === Main Loop ===
function TamerAssistant.run()
    -- Validate configuration
    local configErrors = validateConfig()
    if #configErrors > 0 then
        printBanner("CONFIGURATION ERRORS", 33, "!")
        for _, error in ipairs(configErrors) do
            printError(error)
        end
        printError("Please fix these errors and restart the script")
        return
    end
    
    printHeader()
    State.isRunning = true
    State.startTime = getCurrentTime()
    State.lastStatusPrint = getCurrentTime()
    Journal.Clear()
    
    debugPrint("Main loop started", "MAIN")
    
    while State.isRunning do
        debugPrint("Main loop iteration", "MAIN")
        
        -- Kill already tamed pets in range first (if enabled)
        if Config.killTamedFirst then
            local killedCount = killAllTamedPetsInRange()
            if killedCount > 0 then
                debugPrint("Killed " .. killedCount .. " tamed pets, pausing before continuing", "MAIN")
                Pause(Config.waitAfterKill * 2) -- Extra pause after clearing tamed pets
            end
        end
        
        -- Process overhead messages for nearby mobs
        processOverheadMessages()
        
        -- Find untamed mobs in range
        local untamedMobs = getUntamedMobs()
        
        if #untamedMobs == 0 then
            debugPrint("No untamed mobs found, showing status and waiting", "MAIN")
            showStatusIfNeeded()
            Pause(Config.scanDelay)
        else
            local target = untamedMobs[1]
            debugPrint("Selected target: " .. target.Name .. " at distance " .. target.Distance, "MAIN")
            
            local success = attemptTame(target)
            
            if success then
                debugPrint("Tame successful, checking repeat settings", "MAIN")
                if not Config.repeatAfterTame then
                    printBanner("Script Complete", 68)
                    printSuccess("Ending script after successful tame")
                    break
                end
                debugPrint("Pausing " .. Config.betweenAttemptsDelay .. "ms before next attempt", "MAIN")
                Pause(Config.betweenAttemptsDelay)
            else
                debugPrint("Tame failed, short pause before retry", "MAIN")
                Pause(Config.smallStepDelay)
            end
        end
    end
    
    printBanner("Script Terminated", 38)
    printInfo("Final Stats - Tamed: " .. State.tamedCount .. " | Killed: " .. State.killCount)
    debugPrint("Script ended normally", "MAIN")
end

function TamerAssistant.stop()
    State.isRunning = false
    local uptime = State.startTime > 0 and math.floor(getCurrentTime() - State.startTime) or 0
    printBanner("Tamer Assistant Stopped", 38)
    printInfo("Session Stats:")
    printInfo("  * Runtime: " .. uptime .. " seconds")
    printInfo("  * Creatures Tamed: " .. State.tamedCount)
    printInfo("  * Pets Killed: " .. State.killCount)
    debugPrint("Script stopped by user request", "MAIN")
end

function TamerAssistant.getStats()
    local uptime = State.startTime > 0 and math.floor(getCurrentTime() - State.startTime) or 0
    return {
        tamedCount = State.tamedCount,
        killCount = State.killCount,
        uptime = uptime,
        isRunning = State.isRunning,
        ignoredCount = 0 -- Could implement counter if needed
    }
end

-- Display current stats
function TamerAssistant.showStats()
    local stats = TamerAssistant.getStats()
    printSection("Current Statistics", 89)
    printInfo("Runtime: " .. stats.uptime .. " seconds")
    printInfo("Tamed: " .. stats.tamedCount)
    printInfo("Killed: " .. stats.killCount)
    printInfo("Status: " .. (stats.isRunning and "Running" or "Stopped"))
end

-- === Start the script ===
TamerAssistant.run()