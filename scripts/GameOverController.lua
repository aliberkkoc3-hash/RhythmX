-- GameOverController.lua
-- Şarkılara özel sinematik, efekt dolu ve akıl almaz Game Over ekranları

local isGameOverTriggered = false

function onGameOver()
    if isGameOverTriggered then return Function_Continue; end
    isGameOverTriggered = true

    local songName = string.lower(getProperty("songName") or "")

    -- ==================== FALLEN İÇİN ÖZEL KANLI & KÂBUS GAME OVER ====================
    if string.find(songName, "fallen") then
        -- Ekranı kana boya, şiddetli sarsıntı ve kırmızı flash patlat
        cameraFlash('hud', '0xFF990000', 0.3, true)
        triggerEvent("Screen Shake", "0.5, 0.03", "")
        
        -- Boyfriend'i karart ve HUD'u gizle
        doTweenAlpha('bfDarken', 'boyfriend', 0.2, 0.8, 'quartOut')
        doTweenAlpha('hudHide', 'camHUD', 0, 0.5, 'sineIn')
        
        -- Ekranın ortasına korkunç bir Chara gülümsemesi veya yazı efekti için özel sprite patlatabiliriz
        makeLuaSprite('fallenDeathOverlay', '', 0, 0)
        makeGraphic('fallenDeathOverlay', 1280, 720, '99000000')
        setObjectCamera('fallenDeathOverlay', 'hud')
        addLuaSprite('fallenDeathOverlay', true)
        setProperty('fallenDeathOverlay.alpha', 0)
        doTweenAlpha('overlayFade', 'fallenDeathOverlay', 0.8, 0.5, 'linear')

        -- Ölüm müziği veya ses efektini buraya entegre edebilirsin (Psych Engine otomatik .ogg dosyalarını arar)
        -- Örn: loadSong('fallen-gameover', 0);

    -- ==================== TENACITY İÇİN ÖZEL ALTIN / MERHAMET (FRISK) GAME OVER ====================
    elseif string.find(songName, "tenacity") then
        -- Parlak altın rengi patlama ve yavaş sinematik kararma
        cameraFlash('hud', '0xFFFFD700', 0.6, true)
        triggerEvent("Screen Shake", "0.3, 0.01", "")
        
        doTweenZoom('deathZoom', 'camGame', 1.3, 1.5, 'sineInOut')
        doTweenAlpha('hudHideTenacity', 'camHUD', 0, 1.0, 'sineOut')

        makeLuaSprite('tenacityGlow', '', 0, 0)
        makeGraphic('tenacityGlow', 1280, 720, 'FFD700')
        setObjectCamera('tenacityGlow', 'hud')
        addLuaSprite('tenacityGlow', true)
        setProperty('tenacityGlow.alpha', 0)
        doTweenAlpha('glowFade', 'tenacityGlow', 0.4, 0.4, 'sineIn')

    -- ==================== MEGALO STRIKE BACK İÇİN KAOTİK DELİ GAME OVER ====================
    elseif string.find(songName, "megalo") or string.find(songName, "strike") then
        -- Çılgın flaşlar, ekran dönmesi ve yüksek sarsıntı
        cameraFlash('game', '0xFF00FFFF', 0.15, true)
        cameraFlash('hud', '0xFFFF00FF', 0.15, true)
        triggerEvent("Screen Shake", "0.8, 0.04", "")
        
        doTweenAngle('deathSpinGame', 'camGame', 360, 0.8, 'expoIn')
        doTweenAngle('deathSpinHUD', 'camHUD', -360, 0.8, 'expoIn')
        doTweenAlpha('hudHideMegalo', 'camHUD', 0, 0.3, 'linear')

    -- ==================== PETALS İÇİN MAVİ RUH / ÖLÜM EFEKTİ ====================
    elseif string.find(songName, "petals") then
        -- Derin mavi tonlarında hüzünlü ve yumuşak süzülme efekti
        cameraFlash('hud', '0xFF003366', 0.5, true)
        
        doTweenZoom('petalsZoom', 'camGame', 1.15, 2.0, 'sineOut')
        doTweenAlpha('hudHidePetals', 'camHUD', 0, 1.2, 'sineInOut')
        
        for i = 0, 3 do
            doTweenAlpha('bfArrowHide_' .. i, 'playerStrums.members['..i..']', 0, 0.5, 'linear')
        end
    end

    -- FNF'in orijinal Game Over mekaniğinin (müzik ve yeniden başlama ekranı) düzgün çalışması için devam ediyoruz
    return Function_Continue;
end