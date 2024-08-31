local currentBarPorcent = 0
local heightBar = 0
local songStarted = false
function onCreatePost()
    makeLuaSprite('FearBarImage','mechanics/resist/healthBar2',screenWidth - 100,30)
    scaleObject('FearBarImage',1.8,1.1)
    setObjectCamera('FearBarImage','hud')
    setProperty("FearBarImage.x", getProperty("FearBarImage.x") + 200)


    makeLuaSprite('FearBarBg','mechanics/resist/healthBarg', getProperty('FearBarImage.x'),getProperty('FearBarImage.y'))
    setObjectCamera('FearBarBg','hud')
    scaleObject('FearBarBg',1.6,1.07)
    addLuaSprite('FearBarImage')
    addLuaSprite('FearBarBg')
    screenCenter("FearBarBg", 'xy') 
    
    makeLuaSprite('FearBarBar','',getProperty('FearBarImage.x') ,getProperty('FearBarImage.y'))
    setObjectCamera('FearBarBar','hud')
    makeGraphic('FearBarBar',getProperty('FearBarBg.width')/1.1,getProperty('FearBarBg.height'),'eda6c4')

    addLuaSprite('FearBarBar',false)
    songStarted = false
end
function onUpdate()
    --[[if keyPressed('space') then
        currentBarPorcent = currentBarPorcent + 0.1
    end]]
    if currentBarPorcent == 0 then
        setGraphicSize('FearBarBar',getProperty('FearBarBg.width')/1.6 * getProperty('FearBarBg.scale.x'),0)
    else
        setGraphicSize('FearBarBar',getProperty('FearBarBg.width')/1.6 * getProperty('FearBarBg.scale.x'),getProperty('FearBarBg.height')/0.99* currentBarPorcent)
    end
    setProperty('FearBarBg.x',getProperty('FearBarImage.x') + 9)
    setProperty('FearBarBar.x',getProperty('FearBarImage.x') + 9)
    setProperty('FearBarBar.y',getProperty('FearBarImage.y') + 655 - getProperty('FearBarBar.height'))
    setProperty('dadGroup.x',getProperty('FearBarBg.height')/1.2* currentBarPorcent)

    if currentBarPorcent > 1 then
        currentBarPorcent  = 1
    end
    if currentBarPorcent <= 0 then
        currentBarPorcent  = 0
        setGraphicSize('FearBarBar',getProperty('FearBarBg.width')/1.8 * getProperty('FearBarBg.scale.x'),0)
        setProperty('FearBarBar.visible',false)
    else
        setProperty('FearBarBar.visible',true)
    end
    if currentBarPorcent == 1 then
        setProperty('health', getProperty('health') - 0.0051*(60/getPropertyFromClass('ClientPrefs', 'framerate')))
    end
    curResist = 100 - ((currentBarPorcent* 1000)/10)
    if getProperty('health') >= 1 then curHorny = 0 else curHorny = ((getProperty('health')-1)*100) end
    setTextString('scoreTxt','Momments of Weakness: '..getProperty('songMisses') ..' | Amount of Resistance Left: '..string.gsub(string.sub(curResist,1,10), "-", "")..'% | Level Of Horny: '..(string.sub((-curHorny),1,2))..'% | Accuracy: '..(string.sub(getProperty('ratingPercent')* 100,0,5)).. '% ['..getProperty('ratingFC')..']')
end
function onSongStart()
    songStarted = true
end
function opponentNoteHit(a,b,c)
    if (difficultyName == 'Nightmare' or difficultyName == 'Unreal') and curStep >= 1024 and curStep <= 1536 then
        if currentBarPorcent < 1 then
            currentBarPorcent = currentBarPorcent + 0.0090
        end
    end
    if (difficultyName == 'Nightmare' or difficultyName == 'Unreal') and curStep <= 2048 and curStep >= 2034 then
        if currentBarPorcent < 1 then
            currentBarPorcent = currentBarPorcent + 1
        end
    end
end
function onBeatHit()
    if (difficultyName == 'Nightmare' or difficultyName == 'Unreal') and curStep >= 1024 and curStep <= 1536 or curStep <= 2048 and curStep >= 2034 then
        if currentBarPorcent < 1 then
            currentBarPorcent = currentBarPorcent + 0.010
        end
    end
    if (difficultyName == 'Nightmare' or difficultyName == 'Unreal') then
        if curBeat == 256 or curBeat == 512 then
            doTweenX("helloBar", "FearBarImage", getProperty('FearBarBg.x') - 200, 0.5, "sineInOut")
        end
        if curBeat == 384 or curBeat == 576 then
            doTweenX("byeBar", "FearBarImage", getProperty('FearBarBg.x') + 200, 0.5, "sineInOut")
            currentBarPorcent = 0
        end
    end
end
function goodNoteHit(a,b,c)
    if (difficultyName == 'Nightmare' or difficultyName == 'Unreal') and curStep >= 1024 and curStep <= 1536 then
        if currentBarPorcent > 0 then
            currentBarPorcent = currentBarPorcent - 0.9
        end
    end
    if (difficultyName == 'Nightmare' or difficultyName == 'Unreal') and curStep <= 2048 and curStep >= 2034 then
        if currentBarPorcent > 0 then
            currentBarPorcent = currentBarPorcent - 1
        end
    end
end
function noteMiss(id,dir,type,sustain)
    if type == '' then
        if currentBarPorcent < 1 then
            currentBarPorcent = currentBarPorcent + 0.053
        end
    end
end