-- BFPlaysSansTheme.lua

function onEvent(name, value1, value2)
    if name == "BFPlaysSansTheme" then
        debugPrint("PlaysSansTheme event tetiklendi! Value1: " .. tostring(value1) .. " | Value2: " .. tostring(value2))
    end
end