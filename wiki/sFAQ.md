## Overview
Scripting in UOSagas Assistant Framework is done in the LUA language. There are many tutorials online as to how to code in LUA but here are the answers to some frequently asked questions. 

## Frequently Asked Questions

### How do I loop?
```lua
-- Basic for loop. This will do something 10 times.
for i = 1, 10 do
   Messages.Print(i)
end

-- Loop Forever
while true do
    Messages.Overhead("I'm Learning LUA and I'M NOT HAPPY ABOUT IT.", Player.Serial)
    Pause(1000) -- 1 second cooldown
end

-- While loop. This will do something while the conditions are met.
-- In this case we're using < 100 to mean less than 100.
while Skills.GetValue("Peacemaking") < 100 do
    Messages.Print("I'm at " .. Skills.GetValue("Peacemaking") .. " Peacemaking.")
    Pause(1000)
end
```

## Using `Pause` in Lua Scripts  

### What is `Pause`?  
The `Pause` function temporarily stops script execution for a specified duration (in milliseconds).  

### Syntax  
```lua
Pause(milliseconds)
```
- `milliseconds`: The duration to pause the script (e.g., `1000` for 1 second).  

### When to Use `Pause`  
- **After Using an Object**: Some actions, like using items, have a server cooldown.  
  ```lua
  Player.UseObject(serial)
  Pause(650) -- Wait for the action to complete  
  ```

- **Timing**: Prevent spamming something on cooldown.  
  ```lua
  while true do  
      Player.UseObjectByType('0x1F66')
      Pause(3600) -- Allow time for item cooldown  
  end  
  ```  

Using `Pause` correctly ensures smooth script execution and prevents unnecessary errors from rapid actions.
If your script is DDoSing your client, you probably need this.

## Using Functions to Check Conditions in Lua  

### What Are Conditional Checks?  
Conditional checks allow scripts to make decisions based on certain conditions, like health, mana, or skill levels.  

### Example: Checking Health and Calling for Help  
In this example, the script will check if the player's health is below 50%. If so, it will display "HELP" as an overhead message.  

```lua
function CheckHealth()
    if Player.Hits < (Player.HitsMax * 0.5) then
        Messages.Overhead("HELP I'M GONNA DIE", Player.Serial)
    end
end
```

### Explanation  
- `Player.Hits`: Current health.  
- `Player.HitsMax`: Maximum health.  
- `Player.Hits < (Player.HitsMax * 0.5)`: Checks if health is below 50%.  
- `Messages.Overhead("HELP I'M GONNA DIE", Player.Serial)`: Displays message overhead.  

This function can be placed in a loop to continuously monitor health:  

```lua
while true do
    CheckHealth()
    Pause(1000) -- Check every second
end
```

Using functions like this helps keep your scripts organized and efficient.


