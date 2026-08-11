-- RhythmXAutoPress.lua (Event-Triggered Dialogue Edition)

local isAutoPressEnabled = true

local notifTimer = 0
local notifDuration = 2.5
local notifBaseX = 950
local notifHiddenX = 1350
local notifY = 620
local slideSpeed = 8

-- Metin Kutusu Değişkenleri (Daktilo Efekti İçin)
local dialogueActive = false
local dialogueText = ""
local fullDialogueText = ""
local charIndex = 1
local textTimer = 0
local textSpeed = 0.03

function onCreate()
    precacheSound('DODGE')
    precacheSound('Dodged')
    
    -- ==================== BİLDİRİM METNİ ====================
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

    -- ==================== UNDERTALE DİYALOG KUTUSU (ÜST KISIM) ====================
    makeLuaSprite('boxBorder', '', 134, 60)
    makeGraphic('boxBorder', 1012, 172, '0xFFFFFFFF')
    setObjectCamera('boxBorder', 'other')
    setProperty('boxBorder.alpha', 0)
    addLuaSprite('boxBorder', true)

    makeLuaSprite('boxInner', '', 138, 64)
    makeGraphic('boxInner', 1004, 164, '0xFF000000')
    setObjectCamera('boxInner', 'other')
    setProperty('boxInner.alpha', 0)
    addLuaSprite('boxInner', true)

    makeLuaText('boxText', '', 960, 154, 78)
    setTextSize('boxText', 26)
    setTextFont('boxText', 'vcr.ttf')
    setTextColor('boxText', 'FF1133')
    setObjectCamera('boxText', 'other')
    setProperty('boxText.alpha', 0)
    addLuaText('boxText')
end

local function showNotif(text, color)
    setTextString("autoNotif", text)
    setTextColor("autoNotif", color)
    setProperty("autoNotif.visible", true)
    setProperty("autoNotif.alpha", 1)
    setProperty("autoNotif.x", notifHiddenX)
    notifTimer = notifDuration
end

local function triggerDialogue(text, textColorHex)
    fullDialogueText = text
    dialogueText = ""
    charIndex = 1
    dialogueActive = true
    
    if textColorHex ~= nil then
        setTextColor('boxText', textColorHex)
    end
    
    setProperty('boxBorder.y', 50)
    setProperty('boxInner.y', 54)
    setProperty('boxText.y', 68)
    
    setProperty('boxBorder.alpha', 0)
    setProperty('boxInner.alpha', 0)
    setProperty('boxText.alpha', 0)
    
    doTweenAlpha('showBoxBorder', 'boxBorder', 1, 0.4, 'quadOut')
    doTweenAlpha('showBoxInner', 'boxInner', 1, 0.4, 'quadOut')
    doTweenAlpha('showBoxText', 'boxText', 1, 0.4, 'quadOut')
    
    doTweenY('moveBoxBorder', 'boxBorder', 60, 0.4, 'quadOut')
    doTweenY('moveBoxInner', 'boxInner', 64, 0.4, 'quadOut')
    doTweenY('moveBoxText', 'boxText', 78, 0.4, 'quadOut')
    
    triggerEvent("Screen Shake", "0.2, 0.005", "")
    runTimer('hideDialogueTimer', 4.0)
end

function onUpdatePost(elapsed)
    if dialogueActive then
        textTimer = textTimer + elapsed
        if textTimer >= textSpeed then
            textTimer = 0
            if charIndex <= string.len(fullDialogueText) then
                dialogueText = dialogueText .. string.sub(fullDialogueText, charIndex, charIndex)
                setTextString('boxText', dialogueText)
                charIndex = charIndex + 1
            else
                dialogueActive = false
            end
        end
    end

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
    if name == "DodgeEvent" then
        triggerDialogue("* Incoming attack! Dodge it! or Die =) (Press M Trust Me!)", "FF1133")
        if isAutoPressEnabled then
            local dodgeTime = (value1 ~= '' and tonumber(value1)) or 0.6;
            
            playSound('DODGE', 0.3);
            runTimer('TriggerMKey', dodgeTime - 0.05);
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'hideDialogueTimer' then
        doTweenAlpha('hideBoxBorder', 'boxBorder', 0, 0.5, 'sineIn')
        doTweenAlpha('hideBoxInner', 'boxInner', 0, 0.5, 'sineIn')
        doTweenAlpha('hideBoxText', 'boxText', 0, 0.5, 'sineIn')
    elseif tag == 'TriggerMKey' and isAutoPressEnabled then
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