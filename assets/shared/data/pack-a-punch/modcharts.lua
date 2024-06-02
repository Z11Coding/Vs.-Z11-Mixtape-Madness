function onCreate()
    local directory = 'modcharts/'..songName
    if checkFileExists(directory..'.lua') then
        addLuaScript(directory)
        --callScript(directory,'onCreate',{})
    end
end
