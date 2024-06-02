local imageCount = 0
function onEvent(name, value1, value2)
    if string.lower(name) == "flashimage" then
        imageCount = imageCount + 1
        makeLuaSprite('image'..imageCount, value1, 0, 0)
        setObjectCamera('image'..imageCount, 'hud')
        doTweenAlpha('imageTween'..imageCount,'image'..imageCount, 0, tonumber(value2))

        addLuaSprite('image'..imageCount,true)
    elseif string.lower(name) == "uno" then
        local name = 'uno'
        if value1 == '1' then
            name = name..'-god'
        end
        triggerEvent('flashimage', name, stepCrochet/250)
        screenCenter('image'..imageCount)
    elseif string.lower(name) == "dos" then
        local name = 'dos'
        if value1 == '1' then
            name = name..'-god'
        end
        triggerEvent('flashimage', name, stepCrochet/250)
        screenCenter('image'..imageCount)
    elseif string.lower(name) == "tres" then
        local name = 'tres'
        if value1 == '1' then
            name = name..'-god'
        end
        triggerEvent('flashimage', name, stepCrochet/250)
        screenCenter('image'..imageCount)
    elseif string.lower(name) == "cuatro" then
        local name = 'cuatro'
        if value1 == '1' then
            name = name..'-god'
        end
        triggerEvent('flashimage', name, stepCrochet/250)
        screenCenter('image'..imageCount)
    elseif string.lower(name) == "gato" then
        triggerEvent('flashimage', 'que opinas de este gato', stepCrochet/250)
        screenCenter('image'..imageCount)
    elseif string.lower(name) == "3" then
        triggerEvent('flashimage', '3', stepCrochet/250)
    elseif string.lower(name) == "2" then
        triggerEvent('flashimage', 'ready', stepCrochet/250)
        setProperty('image'..imageCount..'.y',getProperty('image'..imageCount..'.y')+100)
        --doTweenY('imageTweenY'..imageCount,'image'..imageCount ,getProperty('image'..imageCount)..'.y')+100,stepCrochet/250, 'cubeInOut')
        setObjectCamera('image'..imageCount, 'game')
        screenCenter('image'..imageCount)
    elseif string.lower(name) == "1" then
        triggerEvent('flashimage', 'set', stepCrochet/250)
        setProperty('image'..imageCount..'.y',getProperty('image'..imageCount..'.y')+100)
        --doTweenY('imageTweenY'..imageCount,'image'..imageCount ,getProperty('image'..imageCount)..'.y')+100,stepCrochet/250, 'cubeInOut')
        setObjectCamera('image'..imageCount, 'game')
        screenCenter('image'..imageCount)
    elseif string.lower(name) == "go" then
        triggerEvent('flashimage', 'go', stepCrochet/250)
        setProperty('image'..imageCount..'.y',getProperty('image'..imageCount..'.y')+100)
        --doTweenY('imageTweenY'..imageCount,'image'..imageCount ,getProperty('image'..imageCount)..'.y')+100,stepCrochet/250, 'cubeInOut')
        setObjectCamera('image'..imageCount, 'game')
    end
end