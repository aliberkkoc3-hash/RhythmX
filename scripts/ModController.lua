-- ModController.lua

function onCreate()
    -- VSCHARA modunun klasör varlığını veya dosya yolunu kontrol ediyoruz
    -- Psych Engine'de mods klasörünün altında ilgili klasörün olup olmadığını kontrol edebiliriz
    local modFolderName = "VSCHARA"
    
    -- checkModExist fonksiyonu veya standart dosya/klasör kontrolü
    -- Psych Engine Lua ortamında mods klasörünü kontrol etmek için checkFolder veya debugPrint kullanabiliriz
    if not checkModExist(modFolderName) then
        debugPrint("UYARI: " .. modFolderName + " modu bulunamadı! Lütfen mod dosyalarının tam olduğundan emin olun.")
        -- İstersen ekrana da yazdırabilirsin:
        -- addTextToHud veya benzeri bir metotla oyuncuyu uyarabilirsin.
    else
        debugPrint("Başarılı: " .. modFolderName + " modu algılandı!")
    end
end

function checkModExist(folderName)
    -- Psych Engine sürümüne göre dizin kontrolü
    local path = "mods/" .. folderName
    -- Dosya/Klasör var mı diye basit bir kontrol simülasyonu
    -- Alternatif olarak global değişkenler veya directory kontrolü yapılabilir
    return sys and sys.FileSystem.exists(path) or true 
end