local isRhythmXActive = false

local songNotifTimer = 0
local songNotifDuration = 3.0
local songNotifY = 260

local notifTimer = 0

local notifDuration = 2.5
local notifBaseX = 950
local notifHiddenX = 1350
local notifY = 620
local slideSpeed = 8

local engineVersion = tostring(version or "")
local isPsych1 = string.sub(engineVersion, 1, 2) == "1."

local detectedSongName = "(UNKNOWN SONG)"
local detectedSongAuthor = "Unknown Artist"

local rainbowTimer = 0
local rainbowSpeed = 2.5

local songNotifShown = false
local videoCheckTimer = 0.15
local videoCheckDone = false
local videoWasPlaying = false

local function isVideoPlaying()
    local active = runHaxeCode([[
        var found = false;
        if (game.modchartSprites != null) {
            for (key in game.modchartSprites.keys()) {
                if (StringTools.endsWith(key, '_video')) {
                    found = true;
                    break;
                }
            }
        }
        found;
    ]])
    return active == true
end

local function showSongNotif()
    if songNotifShown then return end
    songNotifShown = true
    setProperty("songNotifTitle.visible", true)
    setProperty("songNotifAuthor.visible", true)
    setProperty("blurOverlay.visible", true)
    songNotifTimer = songNotifDuration
    setProperty("songNotifTitle.alpha", 1)
    setProperty("songNotifAuthor.alpha", 1)
    setProperty("blurOverlay.alpha", 0.6)
end

function onCreatePost()
    setProperty("cpuControlled", false)
    runHaxeCode([[
        if (game.variables == null) game.variables = new Map();
        game.variables.set('isRhythmXActive', ]] .. tostring(isRhythmXActive) .. [[);
    ]])

    detectedSongName = tostring(loadedSongName or songName or "(UNKNOWN SONG)")

    local chartAuthor = runHaxeCode([[
        var author = "Unknown Artist";
        if (PlayState.SONG != null) {
            if (PlayState.SONG.songAuthor != null) author = PlayState.SONG.songAuthor;
            else if (PlayState.SONG.artist != null) author = PlayState.SONG.artist;
            else if (PlayState.SONG.credits != null) author = PlayState.SONG.credits;
            else if (PlayState.SONG.charter != null) author = "Charted by " + PlayState.SONG.charter;
        }
        author;
    ]]) or "Unknown Artist"
    detectedSongAuthor = tostring(chartAuthor)

    makeLuaSprite("blurOverlay", nil, 0, 0)
    makeGraphic("blurOverlay", screenWidth, screenHeight, "000000")
    setProperty("blurOverlay.alpha", 0)
    setObjectCamera("blurOverlay", "other")
    addLuaSprite("blurOverlay", true)

    makeLuaText("songNotifTitle", detectedSongName, 1280, 0, songNotifY)
    setTextAlignment("songNotifTitle", "center")
    setTextSize("songNotifTitle", 52)
    setTextColor("songNotifTitle", "FFFFFF")
    setTextBorder("songNotifTitle", 3, "000000")
    setTextFont("songNotifTitle", "vcr.ttf")
    setProperty("songNotifTitle.antialiasing", true)
    setProperty("songNotifTitle.visible", false)
    setProperty("songNotifTitle.alpha", 0)
    addLuaText("songNotifTitle")

    makeLuaText("songNotifAuthor", "By " .. detectedSongAuthor, 1280, 0, songNotifY + 58)
    setTextAlignment("songNotifAuthor", "center")
    setTextSize("songNotifAuthor", 38)
    setTextColor("songNotifAuthor", "66C0F4")
    setTextBorder("songNotifAuthor", 3, "000000")
    setTextFont("songNotifAuthor", "vcr.ttf")
    setProperty("songNotifAuthor.antialiasing", true)
    setProperty("songNotifAuthor.visible", false)
    setProperty("songNotifAuthor.alpha", 0)
    addLuaText("songNotifAuthor")

    makeLuaText("botNotif", "", notifHiddenX, notifY, 300)
    setTextAlignment("botNotif", "left")
    setTextSize("botNotif", 24)
    setTextColor("botNotif", "FFFFFF")
    setTextBorder("botNotif", 2, "000000")
    setTextFont("botNotif", "vcr.ttf")
    setProperty("botNotif.antialiasing", true)
    setProperty("botNotif.visible", false)
    setProperty("botNotif.alpha", 0)
    addLuaText("botNotif")
end

local function hsvToRgb(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    local r, g, b

    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end

    return math.floor((r + m) * 255), math.floor((g + m) * 255), math.floor((b + m) * 255)
end

local function rgbToHex(r, g, b)
    return string.format("%02X%02X%02X", r, g, b)
end

local function showNotif(text, color)
    setTextString("botNotif", text)
    setTextColor("botNotif", color)
    setProperty("botNotif.visible", true)
    setProperty("botNotif.alpha", 1)
    setProperty("botNotif.x", notifHiddenX)
    notifTimer = notifDuration
end

local function toggleRhythmX()
    isRhythmXActive = not isRhythmXActive
    runHaxeCode([[
        if (game.variables == null) game.variables = new Map();
        game.variables.set('isRhythmXActive', ]] .. tostring(isRhythmXActive) .. [[);
    ]])
    playSound("confirmMenu")
    if isRhythmXActive then
        showNotif("RHYTHMX IS NOW ON", "00FF00")
    else
        showNotif("RHYTHMX IS NOW OFF", "FF3333")
    end
end

function onUpdatePost(elapsed)
    if not videoCheckDone then
        videoCheckTimer = videoCheckTimer - elapsed
        local playing = isVideoPlaying()

        if playing then
            videoWasPlaying = true
        end

        if videoCheckTimer <= 0 then
            videoCheckDone = true
            if not videoWasPlaying then
                showSongNotif()
            end
        end
    else
        if videoWasPlaying and not songNotifShown then
            if not isVideoPlaying() then
                showSongNotif()
            end
        end
    end

    local shiftPressed = runHaxeCode("FlxG.keys.justPressed.SHIFT")
    if shiftPressed then
        toggleRhythmX()
    end

    if songNotifTimer > 0 then
        songNotifTimer = songNotifTimer - elapsed
        rainbowTimer = rainbowTimer + elapsed * rainbowSpeed * 60

        local hue1 = (rainbowTimer * 2) % 360
        local hue2 = (rainbowTimer * 2 + 120) % 360

        local r1, g1, b1 = hsvToRgb(hue1, 1, 1)
        local r2, g2, b2 = hsvToRgb(hue2, 1, 1)

        setTextColor("songNotifTitle", rgbToHex(r1, g1, b1))
        setTextColor("songNotifAuthor", rgbToHex(r2, g2, b2))

        local pulse = 1 + math.sin(rainbowTimer * 0.1) * 0.05
        setProperty("songNotifTitle.scale.x", pulse)
        setProperty("songNotifTitle.scale.y", pulse)
        setProperty("songNotifAuthor.scale.x", pulse)
        setProperty("songNotifAuthor.scale.y", pulse)

        if songNotifTimer <= 0.5 then
            local fadeAlpha = math.max(songNotifTimer / 0.5, 0)
            setProperty("songNotifTitle.alpha", fadeAlpha)
            setProperty("songNotifAuthor.alpha", fadeAlpha)
            setProperty("blurOverlay.alpha", fadeAlpha * 0.6)
        end

        if songNotifTimer <= 0 then
            setProperty("songNotifTitle.visible", false)
            setProperty("songNotifAuthor.visible", false)
            setProperty("blurOverlay.visible", false)
        end
    end

    if notifTimer > 0 then
        notifTimer = notifTimer - elapsed
        local curX = getProperty("botNotif.x")
        if curX > notifBaseX then
            local newX = curX - (curX - notifBaseX) * math.min(slideSpeed * elapsed, 1)
            setProperty("botNotif.x", newX)
        end
        if notifTimer <= 0.5 then
            local fadeAlpha = math.max(notifTimer / 0.5, 0)
            setProperty("botNotif.alpha", fadeAlpha)
            setProperty("botNotif.x", notifBaseX + (1 - fadeAlpha) * 100)
        end
        if notifTimer <= 0 then
            setProperty("botNotif.visible", false)
        end
    end
end

local function hitNote(index, lane, isSustainNote)
    if isPsych1 then
        runHaxeCode([[
            var idx = ]] .. index .. [[;
            if (game.notes != null && idx >= 0 && idx < game.notes.length) {
                var n = game.notes.members[idx];
                if (n != null && n.mustPress && !n.wasGoodHit && !n.ignoreNote && !n.blockHit) {
                    n.tooLate = false;
                    n.hitCausesMiss = false;
                    n.strumTime = Conductor.songPosition;
                    game.goodNoteHit(n);
                    if (game.health < 0.023 * 2 + 1) game.health += 0.02;
                }
            }
        ]])
    else
        runHaxeCode([[
            var idx = ]] .. index .. [[;
            if (game.notes != null && idx >= 0 && idx < game.notes.length) {
                var n = game.notes.members[idx];
                if (n != null && n.mustPress && !n.wasGoodHit) {
                    n.tooLate = false;
                    n.hitCausesMiss = false;
                    n.strumTime = Conductor.songPosition;
                    game.goodNoteHit(n);
                    if (game.health < 2.02) game.health += 0.02;
                }
            }
        ]])
    end
    local resetTime = isSustainNote and 0.30 or 0.15
    setPropertyFromGroup("playerStrums", lane, "resetAnim", resetTime)
end

function onUpdate(elapsed)
    if getProperty("cpuControlled") then
        setProperty("cpuControlled", false)
    end
    if not isRhythmXActive then
        return
    end

    local songPos = getSongPosition()
    local noteCount = getProperty("notes.length")
    if noteCount == nil then return end

    for i = noteCount - 1, 0, -1 do
        local mustPress = getPropertyFromGroup("notes", i, "mustPress")
        local wasHit = getPropertyFromGroup("notes", i, "wasGoodHit")
        if mustPress and not wasHit then
            local ignoreNote = getPropertyFromGroup("notes", i, "ignoreNote")
            if not ignoreNote then
                local isSustainNote = getPropertyFromGroup("notes", i, "isSustainNote")
                local strumTime = getPropertyFromGroup("notes", i, "strumTime")
                local tooLate = getPropertyFromGroup("notes", i, "tooLate")
                local shouldHit = songPos >= strumTime or tooLate
                if shouldHit then
                    local lane = math.abs(getPropertyFromGroup("notes", i, "noteData")) % 4
                    hitNote(i, lane, isSustainNote)
                end
            end
        end
    end
end

function onDestroy()
    setProperty("cpuControlled", false)
end