-- WelcomeHell.lua

function onEvent(name, value1, value2)
    if name == "WelcomeHell" then
        debugPrint("WelcomeHell event tetiklendi! Value1: " .. tostring(value1) .. " | Value2: " .. tostring(value2))
    end
end