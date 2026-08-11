-- CustomRatings.lua
-- Orijinal ratingleri devre dışı bırakıp şarkıya özel (Normal, Chara veya Frisk) ratingleri gösterir

local ratingIndex = 0

-- Orijinal şarkılar için renkli ratingler
local NORMAL_RATINGS = {
    { text = "SICK!",    color = "00FFFF" },
    { text = "RADICAL!", color = "FF00FF" },
    { text = "GROOVY!",  color = "00FF66" },
    { text = "CHILL!",   color = "3399FF" }
}

-- Chara'nın şarkıları için karanlık/kırmızı ratingler
local CHARA_RATINGS = {
    { text = "ERASED",   color = "FF2222" },
    { text = "SINISTER", color = "990000" },
    { text = "BLOODLUST",color = "660000" },
    { text = "NULL",     color = "111111" }
}

-- TENACITY (Frisk) için huzurlu ve altın ratingler
local MERCY_RATINGS = {
    { text = "GOLDEN",   color = "FFD700" },
    { text = "SPARE",    color = "FFFFFF" },
    { text = "BRAVERY",  color = "FF4500" },
    { text = "JUSTICE",  color = "FFFF00" }
}

function onCreatePost()
    runHaxeCode([[
        if (game != null) {
            game.popUpScore = function(note:Dynamic):Void { };
        }
    ]])
end

local function spawnCustomRating()
    local isRhythmXActive = runHaxeCode("game.variables.get('isRhythmXActive');")
    if not isRhythmXActive then return end

    ratingIndex = ratingIndex + 1
    local tag = "customRating_" .. ratingIndex
    
    local songName = string.lower(getProperty("songName") or "")
    
    -- Hangi rating setini kullanacağımızı belirle
    local chosenList = NORMAL_RATINGS
    
    if string.find(songName, "tenacity") then
        chosenList = MERCY_RATINGS -- Tenacity'de Frisk'in merhametini kullan
    elseif string.find(songName, "petals") or 
           string.find(songName, "fallen") or 
           string.find(songName, "megalo") or 
           string.find(songName, "strike") then
        chosenList = CHARA_RATINGS
    end
    
    local chosen = chosenList[math.random(1, #chosenList)]
    
    local posX = 340
    local posY = 280
    local textSize = 48
    
    -- FAILED ise özel border (Chara için)
    makeLuaText(tag, chosen.text, 600, posX, posY)
    setTextAlignment(tag, "center")
    setTextSize(tag, textSize)
    setTextColor(tag, chosen.color)
    
    -- Border Ayarları
    if chosen.text == "FAILED" then
        setTextBorder(tag, 3, "FF0000")
    else
        setTextBorder(tag, 3, "000000")
    end
    
    setTextFont(tag, "vcr.ttf")
    setObjectCamera(tag, "hud")
    addLuaText(tag)
    
    -- Animasyon
    local tweenTime = 0.4
    if chosenList == CHARA_RATINGS then
        tweenTime = 0.35 
    elseif chosenList == MERCY_RATINGS then
        tweenTime = 0.5 -- Merhamet ratingleri biraz daha yavaş ve süzülerek gitsin
    end
    
    doTweenY(tag .. "Y", tag, getProperty(tag .. ".y") - 60, tweenTime, "sineOut")
    doTweenAlpha(tag .. "Alpha", tag, 0, tweenTime, "sineOut")
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if not isSustainNote then
        spawnCustomRating()
    end
end