local allowedVersions = {
    ["0.7.3"] = true,
    ["1.0.4"] = true
}

local engineVersion = tostring(version or "")
local versionOK = allowedVersions[engineVersion] == true

local dialogShown = false
local songStopped = false

-- SABİT RENKLİ TÜRKÇE HATA MESAJLARI
local errorLines = {
    {
        text = "[RHYTHMX/KRİTİK] Versiyonlar kapışıyor, senin PC kaybetti!",
        color = "8B0000"
    },
    {
        text = "[RHYTHMX/BİLGİ] Bize Psych Engine 0.7.3 veya 1.0.4 lazım.",
        color = "00FF00"
    },
    {
        text = "[RHYTHMX/BİLGİ] Senin kullandığın: Psych Engine "
            .. (engineVersion ~= "" and engineVersion or "BELİRSİZ"),
        color = "00FF00"
    },
    {
        text = "[RHYTHMX/UYARI] RHYTHMX modülü error verdi, motor su kaynatıyor.",
        color = "FFFF00"
    },
    {
        text = "[RHYTHMX/HATA] Uyumsuz motor! Uçuş iptal, herkes evine dağılsın.",
        color = "8B0000"
    },
    {
        text = "[RHYTHMX/İPUCU] 0.7.3 veya 1.0.4 yükle gel, çay koyduk bekliyoruz.",
        color = "FF8C00"
    },
    {
        text = "",
        color = "FFFFFF"
    },
    {
        text = ">> SHIFT'e bas da bu rezaleti kapatalım <<",
        color = "FF0000"
    }
}

-- Kamera ataması
local function setCam(tag, camName)
    runHaxeCode(
        "if (game.getLuaObject('" .. tag ..
        "') != null) game.getLuaObject('" .. tag ..
        "').camera = " .. camName .. ";"
    )
end

-- Şarkıyı ve sesleri durdur
local function stopSong()
    if songStopped then
        return
    end

    songStopped = true

    runHaxeCode([[
        try {
            if (FlxG.sound.music != null) {
                FlxG.sound.music.stop();
                FlxG.sound.music.volume = 0;
            }

            if (FlxG.sound.list != null) {
                for (snd in FlxG.sound.list) {
                    if (snd != null) {
                        snd.stop();
                        snd.volume = 0;
                    }
                }
            }
        } catch(e:Dynamic) {}
    ]])

    setProperty("inst.volume", 0)
    setProperty("vocals.volume", 0)
end

-- Oyunu kapat
local function forceCloseGame()
    runHaxeCode([[
        try {
            #if sys
            Sys.exit(1);
            #end

            if (FlxG.stage != null &&
                FlxG.stage.application != null) {
                try {
                    FlxG.stage.application.window.close();
                } catch(e:Dynamic) {}
            }

            try {
                var forceCrash:Dynamic = null;
                forceCrash.crashNow();
            } catch(e:Dynamic) {}
        } catch(e:Dynamic) {}
    ]])
end

-- Sahte hata penceresini oluştur
local function showFakeErrorBox()
    if dialogShown then
        return
    end

    dialogShown = true

    local sw = screenWidth or 1280
    local sh = screenHeight or 720

    -- Arka plan
    makeLuaSprite("errBackdrop", nil, 0, 0)
    makeGraphic("errBackdrop", sw, sh, "000000")
    setProperty("errBackdrop.alpha", 0.95)
    addLuaSprite("errBackdrop", true)
    setCam("errBackdrop", "camOther")

    -- Pencere boyutları
    local boxW = 750
    local boxH = 340

    local boxX = (sw - boxW) / 2
    local boxY = (sh - boxH) / 2

    -- Kırmızı kenarlık
    makeLuaSprite(
        "errBorder",
        nil,
        boxX - 2,
        boxY - 2
    )

    makeGraphic(
        "errBorder",
        boxW + 4,
        boxH + 4,
        "FF0000"
    )

    setProperty("errBorder.alpha", 0.75)
    addLuaSprite("errBorder", true)
    setCam("errBorder", "camOther")

    -- Ana pencere
    makeLuaSprite(
        "errBox",
        nil,
        boxX,
        boxY
    )

    makeGraphic(
        "errBox",
        boxW,
        boxH,
        "0A0A0A"
    )

    addLuaSprite("errBox", true)
    setCam("errBox", "camOther")

    -- Başlık
    makeLuaText(
        "errTitle",
        "=== RHYTHMX: SİSTEM ÇÖKTÜ ABİ ===",
        boxW - 20,
        boxX + 10,
        boxY + 10
    )

    setTextSize("errTitle", 22)
    setTextFont("errTitle", "vcr.ttf")
    setTextColor("errTitle", "FF0000")
    addLuaText("errTitle")
    setCam("errTitle", "camOther")

    -- Mesajlar
    local startY = boxY + 50
    local lineHeight = 26

    for i, line in ipairs(errorLines) do
        local tag = "errLine" .. i

        makeLuaText(
            tag,
            line.text,
            boxW - 40,
            boxX + 20,
            startY + (i - 1) * lineHeight
        )

        setTextSize(tag, 17)
        setTextFont(tag, "vcr.ttf")
        setTextColor(tag, line.color)

        addLuaText(tag)
        setCam(tag, "camOther")
    end
end

function onCreate()
    if versionOK then
        return
    end

    stopSong()
end

function onCreatePost()
    if versionOK then
        return
    end

    stopSong()
    showFakeErrorBox()
end

function onUpdate(elapsed)
    if versionOK then
        return
    end

    if not songStopped then
        stopSong()
    end

    setProperty("inst.volume", 0)
    setProperty("vocals.volume", 0)

    -- Müziğin tekrar başlamasını engelle
    runHaxeCode([[
        try {
            if (FlxG.sound.music != null &&
                FlxG.sound.music.playing) {
                FlxG.sound.music.stop();
                FlxG.sound.music.volume = 0;
            }
        } catch(e:Dynamic) {}
    ]])

    if not dialogShown then
        showFakeErrorBox()
    end

    -- Başlık sabit kırmızı
    setTextColor("errTitle", "FF0000")

    -- Kapatma mesajına hafif nabız efekti
    local pulse = 1 + math.sin(
        getSongPosition() * 0.001
    ) * 0.05

    setProperty("errLine8.scale.x", pulse)
    setProperty("errLine8.scale.y", pulse)

    -- SHIFT ile kapatma
    if keyboardJustPressed("SHIFT") then
        forceCloseGame()
    end
end

function onUpdatePost(elapsed)
    if versionOK then
        return
    end

    if not songStopped then
        stopSong()
    end

    setProperty("inst.volume", 0)
    setProperty("vocals.volume", 0)
end

function onSongStart()
    if versionOK then
        return
    end

    stopSong()
end

function onBeatHit()
    if versionOK then
        return
    end

    stopSong()
end
