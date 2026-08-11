-- EventController.lua

-- Metin Kutusu Değişkenleri (Daktilo Efekti İçin)
local dialogueActive = false
local dialogueText = ""
local fullDialogueText = ""
local charIndex = 1
local textTimer = 0
local textSpeed = 0.03

-- Kontrol Değişkeni
local isEventsActive = true

-- Kırılma / Parçalanma Kontrolü
local isBroken = false
local leftHalfBorder = ""
local rightHalfBorder = ""
local leftHalfInner = ""
local rightHalfInner = ""

function onCreate()
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

    -- ==================== ALT KISIM KORKUNÇ UYARI METNİ ====================
    makeLuaText('defenseText', '', 1280, 0, 620)
    setTextSize('defenseText', 32)
    setTextFont('defenseText', 'vcr.ttf')
    setTextColor('defenseText', 'FF0000')
    setTextBorder('defenseText', 2, '330000')
    setTextAlignment('defenseText', 'center')
    setObjectCamera('defenseText', 'other')
    setProperty('defenseText.alpha', 0)
    addLuaText('defenseText')

    -- ==================== ORTA ALT KÖŞE (İŞARETLİ ALAN) UYARI METİNLERİ ====================
    -- SaveChart İçin (Sarı)
    makeLuaText('savedText', '', 340, 470, 560)
    setTextSize('savedText', 18)
    setTextFont('savedText', 'vcr.ttf')
    setTextColor('savedText', 'FFFF00')
    setTextBorder('savedText', 2, '333300')
    setTextAlignment('savedText', 'center')
    setObjectCamera('savedText', 'other')
    setProperty('savedText.alpha', 0)
    addLuaText('savedText')

    -- ReplayChart İçin (Kırmızı)
    makeLuaText('loadedText', '', 340, 470, 560)
    setTextSize('loadedText', 18)
    setTextFont('loadedText', 'vcr.ttf')
    setTextColor('loadedText', 'FF0000')
    setTextBorder('loadedText', 2, '330000')
    setTextAlignment('loadedText', 'center')
    setObjectCamera('loadedText', 'other')
    setProperty('loadedText.alpha', 0)
    addLuaText('loadedText')
end

local function triggerDialogue(text, textColorHex)
    if not isEventsActive then return end

    if isBroken then
        removeLuaSprite('leftHalfBorder', true)
        removeLuaSprite('rightHalfBorder', true)
        removeLuaSprite('leftHalfInner', true)
        removeLuaSprite('rightHalfInner', true)
        isBroken = false
    end

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
    
    runTimer('hideDialogueTimer', 4.0)
end

local function triggerShatterAnimation()
    if not isEventsActive then return end

    dialogueActive = false
    cancelTimer('hideDialogueTimer')

    setProperty('boxBorder.alpha', 0)
    setProperty('boxInner.alpha', 0)
    setProperty('boxText.alpha', 0)

    makeLuaSprite('leftHalfBorder', '', 134, 60)
    makeGraphic('leftHalfBorder', 506, 172, '0xFFFFFFFF')
    setObjectCamera('leftHalfBorder', 'other')
    addLuaSprite('leftHalfBorder', true)

    makeLuaSprite('rightHalfBorder', '', 640, 60)
    makeGraphic('rightHalfBorder', 506, 172, '0xFFFFFFFF')
    setObjectCamera('rightHalfBorder', 'other')
    addLuaSprite('rightHalfBorder', true)

    makeLuaSprite('leftHalfInner', '', 138, 64)
    makeGraphic('leftHalfInner', 502, 164, '0xFF000000')
    setObjectCamera('leftHalfInner', 'other')
    addLuaSprite('leftHalfInner', true)

    makeLuaSprite('rightHalfInner', '', 642, 64)
    makeGraphic('rightHalfInner', 502, 164, '0xFF000000')
    setObjectCamera('rightHalfInner', 'other')
    addLuaSprite('rightHalfInner', true)

    isBroken = true

    triggerEvent("Screen Shake", "0.6, 0.025", "")
    playSound('cancelMenu', 1.0)

    doTweenX('leftBorderX', 'leftHalfBorder', 20, 0.6, 'sineIn')
    doTweenY('leftBorderY', 'leftHalfBorder', 750, 0.6, 'quadIn')
    doTweenAngle('leftBorderAngle', 'leftHalfBorder', -45, 0.6, 'sineIn')
    doTweenAlpha('leftBorderAlpha', 'leftHalfBorder', 0, 0.6, 'linear')

    doTweenX('leftInnerX', 'leftHalfInner', 24, 0.6, 'sineIn')
    doTweenY('leftInnerY', 'leftHalfInner', 754, 0.6, 'quadIn')
    doTweenAngle('leftInnerAngle', 'leftHalfInner', -45, 0.6, 'sineIn')
    doTweenAlpha('leftInnerAlpha', 'leftHalfInner', 0, 0.6, 'linear')

    doTweenX('rightBorderX', 'rightHalfBorder', 1100, 0.6, 'sineIn')
    doTweenY('rightBorderY', 'rightHalfBorder', 750, 0.6, 'quadIn')
    doTweenAngle('rightBorderAngle', 'rightHalfBorder', 45, 0.6, 'sineIn')
    doTweenAlpha('rightBorderAlpha', 'rightHalfBorder', 0, 0.6, 'linear')

    doTweenX('rightInnerX', 'rightHalfInner', 1102, 0.6, 'sineIn')
    doTweenY('rightInnerY', 'rightHalfInner', 754, 0.6, 'quadIn')
    doTweenAngle('rightInnerAngle', 'rightHalfInner', 45, 0.6, 'sineIn')
    doTweenAlpha('rightInnerAlpha', 'rightHalfInner', 0, 0.6, 'linear')
end

function onUpdatePost(elapsed)
    if keyboardJustPressed('ALT') then
        isEventsActive = not isEventsActive
        
        if isEventsActive then
            playSound('confirmMenu', 0.4)
        else
            playSound('cancelMenu', 0.4)
            
            dialogueActive = false
            cancelTimer('hideDialogueTimer')
            cancelTimer('shatterDelay')
            cancelTimer('welcomeDialogueDelay')
            cancelTimer('welcomeShatterDelay')
            cancelTimer('hideSavedTimer')
            cancelTimer('hideLoadedTimer')
            
            setProperty('boxBorder.alpha', 0)
            setProperty('boxInner.alpha', 0)
            setProperty('boxText.alpha', 0)
            setProperty('defenseText.alpha', 0)
            setProperty('savedText.alpha', 0)
            setProperty('loadedText.alpha', 0)

            if isBroken then
                removeLuaSprite('leftHalfBorder', true)
                removeLuaSprite('rightHalfBorder', true)
                removeLuaSprite('leftHalfInner', true)
                removeLuaSprite('rightHalfInner', true)
                isBroken = false
            end
        end
    end

    if dialogueActive and isEventsActive then
        textTimer = textTimer + elapsed
        if textTimer >= textSpeed then
            textTimer = 0
            if charIndex <= string.len(fullDialogueText) then
                dialogueText = dialogueText .. string.sub(fullDialogueText, charIndex, charIndex)
                setTextString('boxText', dialogueText)
                charIndex = charIndex + 1
            else
                dialogueActive = false
                
                if fullDialogueText == "* Welcome to my special Hell..." then
                    runTimer('welcomeShatterDelay', 1.5)
                end
            end
        end
    end
end

function onEvent(name, value1, value2)
    if not isEventsActive then return end

    if name == "WelcomeHell" then
        runTimer('welcomeDialogueDelay', 1.5)
        
    elseif name == "BFPlaysSansTheme" then
        if isBroken then
            removeLuaSprite('leftHalfBorder', true)
            removeLuaSprite('rightHalfBorder', true)
            removeLuaSprite('leftHalfInner', true)
            removeLuaSprite('rightHalfInner', true)
            isBroken = false
        end

        triggerDialogue("* BF Sings Sans' Theme", "00FFFF")
        runTimer('shatterDelay', 2.2)

    elseif name == "SaveGChart" then
        setTextString('savedText', "File 1 saved.\n* Determination echoes.")
        setProperty('savedText.alpha', 1)
        playSound('confirmMenu', 0.5)
        doTweenAlpha('hideSaved', 'savedText', 0, 2.0, 'cubeIn')

    elseif name == "ReplayGChart" then
        setTextString('loadedText', "File 1 loaded...\n* Timeline restarts.")
        setProperty('loadedText.alpha', 1)
        playSound('cancelMenu', 0.5)
        doTweenAlpha('hideLoaded', 'loadedText', 0, 2.0, 'cubeIn')

   elseif name == "Spare" then
        if isBroken then
            removeLuaSprite('leftHalfBorder', true)
            removeLuaSprite('rightHalfBorder', true)
            removeLuaSprite('leftHalfInner', true)
            removeLuaSprite('rightHalfInner', true)
            isBroken = false
        end
        triggerDialogue("* Ha... you think mercy will save you from me?", "FF0000")
        playSound('item', 0.8)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'hideDialogueTimer' then
        doTweenAlpha('hideBoxBorder', 'boxBorder', 0, 0.5, 'sineIn')
        doTweenAlpha('hideBoxInner', 'boxInner', 0, 0.5, 'sineIn')
        doTweenAlpha('hideBoxText', 'boxText', 0, 0.5, 'sineIn')
        
    elseif tag == 'shatterDelay' then
        triggerShatterAnimation()

    elseif tag == 'welcomeDialogueDelay' then
        triggerDialogue("* Welcome to my special Hell...", "FF1133")

    elseif tag == 'welcomeShatterDelay' then
        triggerShatterAnimation()
    end
end