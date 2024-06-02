function onCreate()
    local movey = getProperty('camGame.height')*0.5
    local movex = getProperty('camGame.width')*0.5
    setProperty('camGame.height', getProperty('camGame.height')*2)
    setProperty('camGame.width', getProperty('camGame.width')*2)
    setProperty('camGame.x', -movex)
    setProperty('camGame.y', -movey)
end

--ferzy was here