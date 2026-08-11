local allowedVersions = { ["0.7.3"] = true, ["1.0.4"] = true }
local engineVersion = tostring(version or "")
local versionOK = allowedVersions[engineVersion] == true

local dialogShown = false
local songStopped = false
local rainbowTimer = 0
local rainbowSpeed = 2.5

local errorLines = {
    "[FATAL] Version mismatch detected!",
    "[INFO]  Required: Psych Engine 0.7.3 or 1.0.4",
    "[INFO]  Detected: Psych Engine " .. (engineVersion ~= "" and engineVersion or "UNKNOWN"),
    "[WARN]  RhythmX module failed to initialize",
    "[ERROR] Incompatible engine build -- aborting launch",
    "[HINT]  Install Psych Engine 0.7.3 or 1.0.4 to continue",
    "",
    ">> Press SHIFT to dismiss this message <<"
}

local function hsvToRgb(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    local r, g, b
    if h < 60 then r, g, b = c, x, 0
    elseif h < 120 then r, g, b = x, c, 0
    elseif h < 180 then r, g, b = 0, c, x
    elseif h < 240 then r, g, b = 0, x, c
    elseif h < 300 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end
    return math.floor((r + m) * 255), math.floor((g + m) * 255), math.floor((b + m) * 255)
end

local function rgbToHex(r, g, b)
    return string.format("%02X%02X%02X", r, g, b)
end

local function setCam(tag, camName)
    runHaxeCode("if (game.getLuaObject('" .. tag .. "') != null) game.getLuaObject('" .. tag .. "').camera = " .. camName .. ";")
end

local function stopSong()
    if songStopped then return end
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

local function forceCloseGame()
    runHaxeCode([[
        try {
            #if sys
            Sys.exit(1);
            #end
            if (FlxG.stage != null && FlxG.stage.application != null) {
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
    while true do end
end

local function showFakeErrorBox()
    if dialogShown then return end
    dialogShown = true

    local sw = screenWidth or 1280
    local sh = screenHeight or 720

    makeLuaSprite("errBackdrop", nil, 0, 0)
    makeGraphic("errBackdrop", sw, sh, "000000")
    setProperty("errBackdrop.alpha", 0.95)
    addLuaSprite("errBackdrop", true)
    setCam("errBackdrop", "camOther")

    local boxW, boxH = 720, 340
    local boxX = (sw - boxW) / 2
    local boxY = (sh - boxH) / 2

    makeLuaSprite("errBox", nil, boxX, boxY)
    makeGraphic("errBox", boxW, boxH, "0A0A0A")
    addLuaSprite("errBox", true)
    setCam("errBox", "camOther")

    makeLuaSprite("errBorder", nil, boxX - 2, boxY - 2)
    makeGraphic("errBorder", boxW + 4, boxH + 4, "FF0000")
    setProperty("errBorder.alpha", 0.5)
    addLuaSprite("errBorder", true)
    setCam("errBorder", "camOther")

    makeLuaText("errTitle", "=== SUPERBOTPLAY FATAL ERROR ===", boxW - 20, boxX + 10, boxY + 10)
    setTextSize("errTitle", 22)
    setTextFont("errTitle", "vcr.ttf")
    setTextColor("errTitle", "FF0000")
    addLuaText("errTitle")
    setCam("errTitle", "camOther")

    local startY = boxY + 50
    local lineHeight = 26

    for i, line in ipairs(errorLines) do
        local tag = "errLine" .. i
        makeLuaText(tag, line, boxW - 40, boxX + 20, startY + (i - 1) * lineHeight)
        setTextSize(tag, 17)
        setTextFont(tag, "vcr.ttf")
        addLuaText(tag)
        setCam(tag, "camOther")
    end
end

-- CRITICAL: onCreate runs BEFORE the song starts loading
function onCreate()
    if versionOK then return end
    -- Stop song BEFORE it even starts
    stopSong()
end

function onCreatePost()
    if versionOK then return end
    -- Double-kill in case onCreate missed it
    stopSong()
    showFakeErrorBox()
end

function onUpdate(elapsed)
    if versionOK then return end

    -- Persistent audio kill every single frame
    if not songStopped then
        stopSong()
    end
    
    -- Keep volumes at 0 even after "stopped" flag
    setProperty("inst.volume", 0)
    setProperty("vocals.volume", 0)
    
    -- Also try to stop music object directly every frame
    runHaxeCode([[
        try {
            if (FlxG.sound.music != null && FlxG.sound.music.playing) {
                FlxG.sound.music.stop();
                FlxG.sound.music.volume = 0;
            }
        } catch(e:Dynamic) {}
    ]])

    if not dialogShown then
        showFakeErrorBox()
    end

    rainbowTimer = rainbowTimer + elapsed * rainbowSpeed * 60

    for i = 1, #errorLines do
        local tag = "errLine" .. i
        local hue = (rainbowTimer * 2 + (i * 35)) % 360
        local r, g, b = hsvToRgb(hue, 1, 1)
        setTextColor(tag, rgbToHex(r, g, b))

        if i == #errorLines then
            local pulse = 1 + math.sin(rainbowTimer * 0.12) * 0.1
            setProperty(tag .. ".scale.x", pulse)
            setProperty(tag .. ".scale.y", pulse)
        end
    end

    local glitch = math.random() > 0.95
    if glitch then
        setTextColor("errTitle", "FFFFFF")
    else
        setTextColor("errTitle", "FF0000")
    end

    if keyboardJustPressed("SHIFT") then
        forceCloseGame()
    end
end

-- Extra safety: also run in onUpdatePost
function onUpdatePost(elapsed)
    if versionOK then return end
    if not songStopped then
        stopSong()
    end
    -- Keep killing audio
    setProperty("inst.volume", 0)
    setProperty("vocals.volume", 0)
end

-- Kill audio on song start too
function onSongStart()
    if versionOK then return end
    stopSong()
end

-- Kill audio on beat hit
function onBeatHit()
    if versionOK then return end
    stopSong()
end