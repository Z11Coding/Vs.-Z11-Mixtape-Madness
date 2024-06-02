function onCreate()
    makeLuaSprite('healthBarVoiid','healthBar_bg',0,0)
    setObjectCamera('healthBarVoiid','hud')
    addLuaSprite('healthBarVoiid',false)

 
    setProperty('healthBar.scale.x',1.03)
    setProperty('healthBar.scale.y',1.4)


    makeLuaText('timeTxtVoiid','',400,0,0)
    setObjectCamera('timeTxtVoiid','hud')
    setTextBorder('timeTxtVoiid',1,'000000')
    setTextSize('timeTxtVoiid',20)
    addLuaText('timeTxtVoiid',false)

    makeLuaSprite('timeBarBGVoiid','timeBarBG',getProperty('timeBar.x'),getProperty('timeBar.y'))
    setObjectCamera('timeBarBGVoiid','hud')
    addLuaSprite('timeBarBGVoiid',false)
end
function onCreatePost()
    if hideHud then
        setProperty('healthBarVoiid.visible',false)
    end
    if timeBarType == 'Disabled' then
        setProperty('timeTxtVoiid.visible',false)
        setProperty('timeBarBGVoiid.visible',false)
    end
    setObjectOrder('healthBar',getObjectOrder('healthBar')-10)
    setObjectOrder('iconP1',getObjectOrder('iconP1')-10)
    setObjectOrder('iconP2',getObjectOrder('iconP2')-10)
    setObjectOrder('scoreTxt',getObjectOrder('scoreTxt')-10)
    setObjectOrder('healthBarVoiid',getObjectOrder('healthBar'))
    setObjectOrder('timeTxtVoiid',getObjectOrder('timeTxt'))
    setObjectOrder('timeBarBGVoiid',getObjectOrder('timeBar'))
    setTextSize('scoreTxt',16)

    scaleObject('healthBar',1.015,1.25)
    setProperty('healthBar.offset.x',0)
    setProperty('healthBar.offset.y',0)
    scaleObject('timeBar',1.2,1)
    setProperty('timeBar.offset.x',0)
    setProperty('timeTxt.visible',false)
    setProperty('timeBar.visible',false)
    if not downscroll then
        setProperty('timeBar.y',5)
        setProperty('timeBarBG.y',5)
    else
        setProperty('timeBar.y',screenHeight-getProperty('timeBar.height'))
        setProperty('timeBarBG.y',screenHeight-getProperty('timeBarBG.height'))
    end
    scaleObject('timeBarBG',1.2,1)
    setProperty('timeBarBG.offset.x',0)
    setObjectOrder('healthBarBG',getObjectOrder('healthBarBG')-10)
    setProperty('healthBarBG.visible',false)
end
function onUpdate(el)
    local songCurPos = math.max(0,getSongPosition())
    local songPos = songLength-songCurPos
    setProperty('timeBarBGVoiid.x',getProperty('timeBar.x') - 39)
    setProperty('timeBarBGVoiid.y',getProperty('timeBar.y'))

    setProperty('healthBarVoiid.x',getProperty('healthBar.x') - 18)
    setProperty('healthBarVoiid.y',getProperty('healthBar.y') - 21)
    setProperty('healthBarVoiid.angle',getProperty('healthBar.angle'))
    setProperty('timeTxtVoiid.x',getProperty('timeTxt.x'))
    setProperty('timeTxtVoiid.y',getProperty('timeTxt.y'))

    local time = math.floor(songPos/60000)..':'..math.floor((songPos/10000) % 6)..math.floor((songPos/1000) % 10)
    --setTextString('timeTxtVoiid',songName..' - '..string.upper(getProperty('storyDifficultyText'))..'('..time..')')
    setTextString('timeTxtVoiid',songName..' - VOIID('..time..')')
end
function onUpdatePost()
    loadGraphic('timeBarBGVoiid','timeBarBG',getProperty('timeBar.width')*(math.max(0,getSongPosition())/songLength),getProperty('timeBar.height'))
end
function onUpdateScore()
    local ratFC = getProperty('ratingFC')
    local ratPercent = getProperty('ratingPercent')
    if ratFC ~= '' and ratFC ~= 'Clear' then
        local rat = getProperty('ratingName')
        if ratFC == 'SFC' then
            ratFC = 'MFC'
        elseif ratFC == 'GFC' then
            ratFC = 'SDG'
        end
        if ratPercent == 1 then
            rat = 'SSSS'
        elseif ratPercent >= 0.95 and ratPercent < 1 then
            rat = 'SSS'
        elseif ratPercent >= 0.9 and ratPercent < 0.95 then
            rat = 'SS'
        elseif ratPercent >= 0.85 and ratPercent < 0.9 then
            rat = 'A'
        elseif ratPercent >= 0.8 and ratPercent < 0.85 then
            rat = 'B+'
        end
        rat = ' - '..rat
        ratFC = ' | '..ratFC..rat
    else
        ratFC = ''
    end
    setTextString('scoreTxt','Score: '..getProperty('songScore')..' | Combo Breaks: '..getProperty('songMisses')..' | Accurancy: '..(math.floor(ratPercent*10000)/100)..'%'..ratFC)
end