-- RhythmXAutoPress.lua
local isAutoPressEnabled = true

local notifTimer = 0
local notifDuration = 2.5
local notifBaseX = 950
local notifHiddenX = 1350
local notifY = 620
local slideSpeed = 8

function onCreate()
    precacheSound('DODGE')
    precacheSound('Dodged')
    
    makeLuaText("autoNotif", "", notifHiddenX, notifY, 400)
    setTextAlignment("autoNotif", "left")
    setTextSize("autoNotif", 22)
    setTextColor("autoNotif", "FFFFFF")
    setTextBorder("autoNotif", 2, "000000")
    setTextFont("autoNotif", "vcr.ttf")
    setProperty("autoNotif.antialiasing", true)
    setProperty("autoNotif.visible", false)
    setProperty("autoNotif.alpha", 0)
    setObjectCamera("autoNotif", "other")
    addLuaText("autoNotif")
end

local function showNotif(text, color)
    setTextString("autoNotif", text)
    setTextColor("autoNotif", color)
    setProperty("autoNotif.visible", true)
    setProperty("autoNotif.alpha", 1)
    setProperty("autoNotif.x", notifHiddenX)
    notifTimer = notifDuration
end

function onUpdatePost(elapsed)
    -- TAB Tuşu ile Auto-Press Açma / Kapama
    if keyboardJustPressed('TAB') then
        isAutoPressEnabled = not isAutoPressEnabled
        
        if isAutoPressEnabled then
            playSound('confirmMenu', 0.4)
            showNotif("RHYTHMX AUTO PRESS IS ON", "00FF00")
        else
            playSound('cancelMenu', 0.4)
            showNotif("RHYTHMX AUTO PRESS IS OFF", "FF3333")
        end
    end

    -- Bildirim kaydırma animasyonu
    if notifTimer > 0 then
        notifTimer = notifTimer - elapsed
        local curX = getProperty("autoNotif.x")
        if curX > notifBaseX then
            local newX = curX - (curX - notifBaseX) * math.min(slideSpeed * elapsed, 1)
            setProperty("autoNotif.x", newX)
        end
        if notifTimer <= 0.5 then
            local fadeAlpha = math.max(notifTimer / 0.5, 0)
            setProperty("autoNotif.alpha", fadeAlpha)
            setProperty("autoNotif.x", notifBaseX + (1 - fadeAlpha) * 100)
        end
        if notifTimer <= 0 then
            setProperty("autoNotif.visible", false)
        end
    end
end

function onEvent(name, value1, value2)
    if name == "DodgeEvent" and isAutoPressEnabled then
        local dodgeTime = (value1 ~= '' and tonumber(value1)) or 0.6;
        
        playSound('DODGE', 0.3);
        runTimer('TriggerMKey', dodgeTime - 0.05);
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'TriggerMKey' and isAutoPressEnabled then
        playSound('Dodged', 0.5);
        characterPlayAnim('boyfriend', 'dodge', true);
        setProperty('boyfriend.specialAnim', true);
        
        if getProperty('spacebar.exists') then
            removeLuaSprite('spacebar', true);
        end
        
        if variables and variables.canDodge ~= nil then
            variables.canDodge = false;
        end
        
        cancelTimer('Died');
        cancelTimer('DodgeTimer');
    end
end