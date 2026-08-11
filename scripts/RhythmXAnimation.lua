-- RhythmXAnimation.lua
-- Fallen: Kanlı Katliam | Tenacity: Frisk'in Merhameti | Megalo: Deli Oklar | Petals: Mavi Akıllı/Sevimli Aura

local toggleDir = 1
local isAnimationsActive = false

local notifTimer = 0
local notifDuration = 2.5
local notifBaseX = 950
local notifHiddenX = 1350
local notifY = 660 -- AutoPress ile üst üste binmemesi için Y konumu biraz aşağıda
local slideSpeed = 8

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

    -- ==================== FALLEN İÇİN GÖRSELLER ====================
    makeLuaSprite('jumpscareChara', 'chara_scary', 0, 0)
    setLuaSpriteScrollFactor('jumpscareChara', 0, 0)
    screenCenter('jumpscareChara')
    setProperty('jumpscareChara.alpha', 0)
    addLuaSprite('jumpscareChara', true)

    makeLuaSprite('scaryMessage', 'chara_scary_message', 0, 0)
    setGraphicSize('scaryMessage', 600, 300)
    updateHitbox('scaryMessage')
    setProperty('scaryMessage.x', 80)  
    setProperty('scaryMessage.y', 180) 
    setProperty('scaryMessage.alpha', 0)
    setObjectCamera('scaryMessage', 'hud') 
    addLuaSprite('scaryMessage', true)

    makeLuaText('creepySmile', '=)', 600)
    setTextSize('creepySmile', 72)
    setTextColor('creepySmile', 'FF0000')
    setTextBorder('creepySmile', 4, '330000')
    setTextFont('creepySmile', 'vcr.ttf')
    setObjectCamera('creepySmile', 'hud')
    setProperty('creepySmile.alpha', 0)
    addLuaText('creepySmile')

    -- ==================== TENACITY İÇİN GÖRSEL ====================
    makeLuaSprite('friskMessage', 'friskMessage', 0, 0)
    setGraphicSize('friskMessage', 600, 300)
    updateHitbox('friskMessage')
    setProperty('friskMessage.x', 320)  
    setProperty('friskMessage.y', 230) 
    setProperty('friskMessage.alpha', 0)
    setObjectCamera('friskMessage', 'hud') 
    addLuaSprite('friskMessage', true)
end

local function showNotif(text, color)
    setTextString("animNotif", text)
    setTextColor("animNotif", color)
    setProperty("animNotif.visible", true)
    setProperty("animNotif.alpha", 1)
    setProperty("animNotif.x", notifHiddenX)
    notifTimer = notifDuration
end

function onSongStart()
    local songName = string.lower(getProperty("songName") or "")
    if string.find(songName, "fallen") then
        doTweenAlpha('showMessage', 'scaryMessage', 1, 0.5, 'expoOut')
        runTimer('hideMessageTimer', 2.5)
    elseif string.find(songName, "tenacity") then
        doTweenAlpha('showFriskMsg', 'friskMessage', 1, 0.8, 'sineOut')
        runTimer('hideFriskMessageTimer', 3.0)
    end
end

function onUpdatePost(elapsed)
    -- CTRL Tuşu ile animasyonları aç/kapat
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

    -- Bildirim kaydırma animasyonu
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
    if tag == 'hideMessageTimer' then
        doTweenAlpha('hideMessage', 'scaryMessage', 0, 1.0, 'sineIn')
    elseif tag == 'hideFriskMessageTimer' then
        doTweenAlpha('hideFriskMsg', 'friskMessage', 0, 1.5, 'sineIn')
    elseif string.find(tag, 'arrowShow_') then
         local arrowIdx = tonumber(string.sub(tag, 11))
         setPropertyFromGroup('playerStrums', arrowIdx, 'alpha', 1)
    end
end

function onBeatHit()
    if not isAnimationsActive then return end

    local songName = string.lower(getProperty("songName") or "")

    -- ==================== FALLEN ====================
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
            setProperty('jumpscareChara.alpha', 1.0)
            cameraFlash("game", "0xFFFF0000", 0.2, true)
            triggerEvent("Screen Shake", "0.1, 0.008", "")
            doTweenAlpha('hideJumpscare', 'jumpscareChara', 0, 0.5, 'expoIn')
        end

    -- ==================== TENACITY ====================
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

    -- ==================== MEGALO STRIKE BACK ====================
    elseif string.find(songName, "megalo") or string.find(songName, "strike") then
        if curBeat % 1 == 0 then
            triggerEvent("Screen Shake", "0.05, 0.004", "")
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
                local wildColors = {'FF0000', 'FF00FF', '00FFFF', 'FFFF00'}
                doTweenColor('megaloColor_' .. i, 'playerStrums.members['..i..']', wildColors[math.random(1, #wildColors)], 0.08, 'linear')
            end
        end

        if curBeat % 4 == 0 then
            for i = 0, 3 do
                setPropertyFromGroup('playerStrums', i, 'alpha', 0.2)
                runTimer('arrowShow_'..i, 0.15)
            end
        end

    -- ==================== PETALS ====================
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

    -- ==================== DİĞER ŞARKILAR ====================
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

    -- ==================== FALLEN İÇİN EK EFEKTLER ====================
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
    elseif tag == "hideMessage" then
        setProperty('scaryMessage.alpha', 0)
    elseif tag == "hideFriskMsg" then
        setProperty('friskMessage.alpha', 0)
    end
end