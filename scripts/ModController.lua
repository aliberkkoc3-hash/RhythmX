-- ModController.lua

function onCreate()
    -- Checking the folder existence or file path of the VSCHARA mod
    local modFolderName = "VSCHARA"
    
    if checkModExist(modFolderName) then
        debugPrint("[RHYTHMX/MODCONTROLLER] VSCHARA MOD EXISTS.")
    else
        debugPrint("[RHYTHMX/MODCONTROLLER] VSCHARA MOD NOT FOUND.")
    end
end

function checkModExist(folderName)
    -- Checking file or folder existence via pack.json or main directory
    local file = io.open("mods/" .. folderName .. "/pack.json", "r")
    if file ~= nil then
        io.close(file)
        return true
    end
    
    local dirCheck = io.open("mods/" .. folderName, "r")
    if dirCheck ~= nil then
        io.close(dirCheck)
        return true
    end

    return false
end