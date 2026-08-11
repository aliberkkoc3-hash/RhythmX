function onEvent(name, value1, value2)
    if name == "FlashBang" then
        -- value1: Flash'in beyaz ekranın kalacağı süre (Saniye cinsinden, örn: 0.5)
        -- value2: Beyaz ekranın kararıp kaybolma süresi (Fade out süresi, örn: 1.5)
        
        local flashDuration = tonumber(value1)
        if flashDuration == nil or flashDuration <= 0 then flashDuration = 0.5 end

        local fadeDuration = tonumber(value2)
        if fadeDuration == nil or fadeDuration <= 0 then fadeDuration = 1.5 end

        -- Eğer ekran önünde flash nesnesi yoksa oluşturuyoruz
        if not luaSpriteExists("flashBangWhite") then
            makeLuaSprite("flashBangWhite", "", 0, 0)
            makeGraphic("flashBangWhite", screenWidth, screenHeight, "FFFFFF")
            setObjectCamera("flashBangWhite", "other")
            addLuaSprite("flashBangWhite", true)
        end

        -- Ekranı anında patlatıp beyaz yapıyoruz ve ayarlanan süre boyunca fade atıyoruz
        setProperty("flashBangWhite.alpha", 1)
        doTweenAlpha("flashBangFade", "flashBangWhite", 0, flashDuration + fadeDuration, "linear")
    end
end