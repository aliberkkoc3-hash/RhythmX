-- RhythmXAnimation.lua (Megalo Strike Back Theme Edition)

local toggleDir = 1
local isAnimationsActive = false

local notifTimer = 0
local notifDuration = 2.5
local notifBaseX = 950
local notifHiddenX = 1350
local notifY = 660
local slideSpeed = 8

-- Metin Kutusu Değişkenleri (Daktilo Efekti İçin)
local dialogueActive = false
local dialogueText = ""
local fullDialogueText = ""
local charIndex = 1
local textTimer = 0
local textSpeed = 0.03

function onCreate()
    -- ==================== BİLDİRİM METNİ ====================
    makeLuaText("animNotif", "", notifHiddenX, notifY, 400)
    setTextAlignment("animNotif", "left")
    setTextSize("animNotif", 22)
    setTextColor("animNotif", "FFFFFF")
    setTextBorder("animNotif", 2, "000000")
    setTextFont("animNotif", "vcr.ttf")
    setProperty("animNotif.antialiasing", true)
    setProperty("animNotif.visible", false)
    setProperty("animNotif.alpha", 0)
    setObjectCamera("animNotif", "other")
    addLuaText("animNotif")

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

    -- ==================== FALLEN İÇİN METİN & ANİMASYON ====================
    makeLuaText('creepySmile', '=)', 600)
    setTextSize('creepySmile', 72)
    setTextColor('creepySmile', 'FF0000')
    setTextBorder('creepySmile', 4, '330000')
    setTextFont('creepySmile', 'vcr.ttf')
    setObjectCamera('creepySmile', 'hud')
    setProperty('creepySmile.alpha', 0)
    addLuaText('creepySmile')
end

local function showNotif(text, color)
    setTextString("animNotif", text)
    setTextColor("animNotif", color)
    setProperty("animNotif.visible", true)
    setProperty("animNotif.alpha", 1)
    setProperty("animNotif.x", notifHiddenX)
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

function onSongStart()
    local songName = string.lower(getProperty("songName") or "")
    
    if string.find(songName, "fallen") then
        triggerDialogue("* Fightin' a demon... fills you with determination. =)", "FF1133")
    elseif string.find(songName, "tenacity") then
        triggerDialogue("* The wind is howling... yet your soul resonates with peace, while at the same time, you are afraid.", "FFAA00")
    elseif string.find(songName, "megalo") or string.find(songName, "strike") then
        triggerDialogue("* Human... CVS (Chara's Vengeance Strike) is about to begin.", "FF5500")
    else
        triggerDialogue("* Let the rhythm guide your soul through the underground.", "CCCCCC")
    end
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

    if keyboardJustPressed('CONTROL') then
        isAnimationsActive = not isAnimationsActive
        
        runHaxeCode([[
            if (game.variables == null) game.variables = new Map();
            game.variables.set('isRhythmXActive', ]] .. tostring(isAnimationsActive) .. [[);
        ]])
        
        if isAnimationsActive then
            playSound('confirmMenu', 0.4)
            showNotif("RHYTHMX ANIMATIONS IS: ON", "00FF00")
        else
            playSound('cancelMenu', 0.4)
            showNotif("RHYTHMX ANIMATIONS IS: OFF", "FF3333")
        end
    end

    if notifTimer > 0 then
        notifTimer = notifTimer - elapsed
        local curX = getProperty("animNotif.x")
        if curX > notifBaseX then
            local newX = curX - (curX - notifBaseX) * math.min(slideSpeed * elapsed, 1)
            setProperty("animNotif.x", newX)
        end
        if notifTimer <= 0.5 then
            local fadeAlpha = math.max(notifTimer / 0.5, 0)
            setProperty("animNotif.alpha", fadeAlpha)
            setProperty("animNotif.x", notifBaseX + (1 - fadeAlpha) * 100)
        end
        if notifTimer <= 0 then
            setProperty("animNotif.visible", false)
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'hideDialogueTimer' then
        doTweenAlpha('hideBoxBorder', 'boxBorder', 0, 0.5, 'sineIn')
        doTweenAlpha('hideBoxInner', 'boxInner', 0, 0.5, 'sineIn')
        doTweenAlpha('hideBoxText', 'boxText', 0, 0.5, 'sineIn')
    elseif string.find(tag, 'arrowShow_') then
         local arrowIdx = tonumber(string.sub(tag, 11))
         setPropertyFromGroup('playerStrums', arrowIdx, 'alpha', 1)
    end
end

function onBeatHit()
    if not isAnimationsActive then return end

    local songName = string.lower(getProperty("songName") or "")

    if string.find(songName, "fallen") then
        if math.random(1, 100) <= 30 then
            local randomX = math.random(100, 1000)
            local randomY = math.random(100, 500)
            
            setProperty('creepySmile.x', randomX)
            setProperty('creepySmile.y', randomY)
            setProperty('creepySmile.alpha', 1.0)
            
            doTweenAlpha('hideSmile', 'creepySmile', 0, 0.35, 'quadOut')
        end

        if curBeat % 32 == 0 then
            cameraFlash("game", "0xFFFF0000", 0.2, true)
            triggerEvent("Screen Shake", "0.1, 0.008", "")
        end

    elseif string.find(songName, "tenacity") then
        if curBeat % 2 == 0 then
            doTweenZoom("camHUDZoom", "camHUD", 1.02, 0.1, "sineOut")
            for i = 0, 3 do
                doTweenColor('arrowGold_' .. i, 'playerStrums.members['..i..']', 'FFD700', 0.15, 'sineInOut')
            end
        else
            for i = 0, 3 do
                doTweenColor('arrowGoldReset_' .. i, 'playerStrums.members['..i..']', 'FFFFFF', 0.2, 'sineIn')
            end
        end

        if curBeat % 8 == 0 then
            toggleDir = toggleDir * -1
            for i = 0, 3 do
                local currentAngle = getPropertyFromGroup('playerStrums', i, 'angle')
                doTweenAngle('tenacityWave_' .. i, 'playerStrums.members['..i..']', currentAngle + (45 * toggleDir), 0.4, "sineInOut")
            end
        end

    elseif string.find(songName, "megalo") or string.find(songName, "strike") then
        if curBeat % 1 == 0 then
            triggerEvent("Screen Shake", "0.06, 0.005", "")
            local flipChance = math.random(1, 4)
            if flipChance == 1 then
                doTweenAngle("camGameFlip", "camGame", 360, 0.15, "elasticOut")
            elseif flipChance == 2 then
                doTweenAngle("camHUDFlip", "camHUD", -360, 0.15, "elasticOut")
            end
        end
        
        if curBeat % 2 == 0 then
            toggleDir = toggleDir * -1
            for i = 0, 3 do
                local currentAngle = getPropertyFromGroup('playerStrums', i, 'angle')
                doTweenAngle('megaloWildSpin_' .. i, 'playerStrums.members['..i..']', currentAngle + (180 * toggleDir), 0.1, "expoOut")
                local strikeColors = {'FF4400', 'FFD700', 'FF0000', 'FFAA00'}
                doTweenColor('megaloColor_' .. i, 'playerStrums.members['..i..']', strikeColors[math.random(1, #strikeColors)], 0.08, 'linear')
            end
        end

        if curBeat % 4 == 0 then
            for i = 0, 3 do
                setPropertyFromGroup('playerStrums', i, 'alpha', 0.2)
                runTimer('arrowShow_'..i, 0.15)
            end
        end

    elseif string.find(songName, "petals") then
        if curBeat % 2 == 0 then
            doTweenZoom("camHUDZoom", "camHUD", 1.025, 0.15, "sineInOut")
            triggerEvent("Add Camera Zoom", "0.005", "0.005")
            
            for i = 0, 3 do
                doTweenColor('petalsBlue_' .. i, 'playerStrums.members['..i..']', '00E1FF', 0.15, 'sineInOut')
            end
        else
            for i = 0, 3 do
                doTweenColor('petalsReset_' .. i, 'playerStrums.members['..i..']', 'FFFFFF', 0.2, 'sineIn')
            end
        end

        if curBeat % 4 == 0 then
            toggleDir = toggleDir * -1
            for i = 0, 3 do
                local basePosY = getPropertyFromGroup('playerStrums', i, 'y')
                doTweenY('petalsFloatY_' .. i, 'playerStrums.members['..i..']', basePosY + (8 * toggleDir), 0.25, "sineInOut")
                doTweenAngle('petalsFloatAngle_' .. i, 'playerStrums.members['..i..']', 10 * toggleDir, 0.25, "sineInOut")
            end
        end

    else
        if curBeat % 2 == 0 then
            triggerEvent("Add Camera Zoom", "0.005", "0.005")
            triggerEvent("Screen Shake", "0.02, 0.002", "")
            
            for i = 0, 3 do
                local customColors = {'00FFCC', 'FF00AA', '33FF00', 'FFEE00', '0088FF', 'FF3300'}
                doTweenColor('randColor_' .. i, 'playerStrums.members['..i..']', customColors[math.random(1, #customColors)], 0.1, 'linear')
            end
        else
            for i = 0, 3 do
                doTweenColor('randColorReset_' .. i, 'playerStrums.members['..i..']', 'FFFFFF', 0.15, 'sineIn')
            end
        end

        toggleDir = toggleDir * -1
        for i = 0, 3 do
            local basePosY = getPropertyFromGroup('playerStrums', i, 'y')
            local offsetMultiplier = (i % 2 == 0) and 1 or -1
            doTweenY('wavePos_' .. i, 'playerStrums.members['..i..']', basePosY + (12 * toggleDir * offsetMultiplier), 0.18, 'sineInOut')
            doTweenAngle('waveAngle_' .. i, 'playerStrums.members['..i..']', 25 * toggleDir * offsetMultiplier, 0.18, 'backOut')
        end

        if curBeat % 4 == 0 then
            doTweenZoom("defaultHUDZoom", "camHUD", 1.04, 0.12, "sineInOut")
            
            local camTiltDir = (math.random(1, 2) == 1) and 1 or -1
            doTweenAngle("defaultGameTilt", "camGame", 6 * camTiltDir, 0.15, "sineOut")
            doTweenAngle("defaultHUDTilt", "camHUD", -5 * camTiltDir, 0.15, "sineOut")
        else
            doTweenZoom("defaultHUDReset", "camHUD", 1.0, 0.15, "sineIn")
            doTweenAngle("defaultGameTiltReset", "camGame", 0, 0.15, "sineIn")
            doTweenAngle("defaultHUDTiltReset", "camHUD", 0, 0.15, "sineIn")
        end

        if curBeat % 16 == 0 then
            local flashColors = {"0xFF003366", "0xFF660066", "0xFF006633", "0xFF663300", "0xFF330066"}
            cameraFlash("game", flashColors[math.random(1, #flashColors)], 0.3, true)
        end
    end

    if string.find(songName, "fallen") then
        if curBeat % 2 == 0 then
            triggerEvent("Screen Shake", "0.03, 0.003", "")
            doTweenZoom("camGameZoom", "camGame", 1.03, 0.04, "quadIn")
            
            for i = 0, 3 do
                doTweenColor('arrowBlood_' .. i, 'playerStrums.members['..i..']', 'FF0000', 0.05, 'quadOut')
            end
        else
            for i = 0, 3 do
                doTweenColor('arrowNormal_' .. i, 'playerStrums.members['..i..']', 'FFFFFF', 0.1, 'quadIn')
            end
        end

        if curBeat % 4 == 0 then
            toggleDir = toggleDir * -1
            for i = 0, 3 do
                local currentAngle = getPropertyFromGroup('playerStrums', i, 'angle')
                doTweenAngle('fallenSpin_' .. i, 'playerStrums.members['..i..']', currentAngle + (270 * toggleDir), 0.25, "expoIn")
            end
        end
    end
end

function onTweenCompleted(tag)
    if tag == "camHUDZoom" then
        doTweenZoom("camHUDReset", "camHUD", 1.0, 0.1, "sineIn")
    elseif tag == "camGameZoom" then
        doTweenZoom("camGameReset", "camGame", 1.0, 0.1, "sineIn")
    elseif tag == "camGameFlip" then
        doTweenAngle("camGameReset", "camGame", 0, 0.5, "backOut")
    elseif tag == "camHUDFlip" then
        doTweenAngle("camHUDReset", "camHUD", 0, 0.5, "backOut")
    end
end