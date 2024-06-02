local voiidPunchs = {}
local voiidSprites = {}
local punchDodge = 0
local punshing = 0
local curPunch = 1
local whiteMatts = {}
local punchEvents = {}
local flipMatt = false
function onCreate()
    for punchs = 1,3 do--precache punchs
        createPunch(punchs)
        cancelTween('VoiidPunch'..punchs..'Alpha')
        setProperty('VoiidPunch'..punchs..'.alpha',0.01)
    end
    createWhiteMatt()
    setProperty('MattWhiteattack0.alpha',0.001)
    for events = 0,getProperty('eventNotes.length')-1 do
        if getPropertyFromGroup('eventNotes',events,'event') == 'punch' then
            table.insert(punchEvents,{
                'punch',
                getPropertyFromGroup('eventNotes',events,'strumTime'),
                getPropertyFromGroup('eventNotes',events,'value1'),
                getPropertyFromGroup('eventNotes',events,'value2')
            })
        end
    end
    callScript('scripts/LoadEvents','loadEvent',{'ca burst'})
end
function createWhiteMatt(type)
    local anim = 'attack'
    if type == nil then
        type = 'attack'
    end
    local x = 0
    if not flipMatt then
		x = getProperty('boyfriend.x') - 1000 + (math.random(-150,50))
	else
		x = getProperty('boyfriend.x') - 150 + (math.random(-150,50))
	end
    local name = 'MattWhite'..type..(#whiteMatts)
	table.insert(whiteMatts,name)

	makeAnimatedLuaSprite(name,'characters/WhiteMattStand_Attack',x,getProperty('boyfriend.y') - 150 + math.random(-10,10))
	scaleObject(name,1.5,1.5)
	setProperty(name..'.flipX',flipMatt)
	addAnimationByPrefix(name,'anim',anim,24,false)
	objectPlayAnimation(name,'anim',true)
	setObjectOrder(name,getObjectOrder('boyfriendGroup') + 2)
	addLuaSprite(name,false)
end
function onSongStart()--precache punch's
    for punchs = 1,3 do
        if getProperty('VoiidPunch'..punchs..'.alpha') == 0.01 then
            removePunch(punchs)
        end
    end
end
function onUpdate(el)
    local pressedSpace = false
    if not botPlay then
        pressedSpace = keyboardJustPressed('SPACE')
    end
    if punshing > 0 then
        if botPlay then
            pressedSpace = true
        end
        if punchDodge > stepCrochet *0.007 then
            punshing = -1
        end
        if punshing < 0.6 then
            punshing = punshing + (stepCrochet*0.16)*el
        else
            setHealth(0.1)
            punshing = 0
        end
    end
    if punchDodge > 0 then
        punchDodge = punchDodge - el
    end

    --debugPrint(punchDodge..','..(stepCrochet*(0.016/curPunch)))
    if not botPlay and keyboardJustPressed('SPACE') and punchDodge <= stepCrochet*(0.006/2)*(math.max(1,curPunch-1)) then
        pressedSpace = true
    end
    if pressedSpace then
        punchDodge = stepCrochet*0.009
        callScript('scripts/global_functions','playerDodge',{})
    end
    if #punchEvents > 0 then
        for events = 1,#punchEvents do
            local punchEvent = punchEvents[events]
            local strumTime = punchEvent[2] - getSongPosition()
            if strumTime > stepCrochet*32 then
                break
            end
            local event = punchEvent[1]
            if event == 'punch' then
                if strumTime > stepCrochet*20 then
                    punchEvents[events][1] = 'voiidPunchSet'
                end
            elseif event == 'voiidPunchSet' then
                local speed = tonumber(punchEvent[4])
                if speed == nil then
                    speed = 2
                end
                if strumTime < stepCrochet*(speed * 6) then
                    local punch = tonumber(punchEvent[3])

                    if punch == nil then
                        punch = 1
                    end
 
                    if punch == '' then
                        punch = 1
                    end
                    createPunch(punch,speed)
                    punchEvents[events][1] = 'punchMatt'
                end
            elseif event == 'punchMatt' then
                if strumTime <= 350 then
                    createWhiteMatt()
                    table.remove(punchEvents,events)
                end
            end
        end
    end
    if #voiidSprites > 0 then
        for punchs = 1,#voiidSprites do
            local name = voiidSprites[punchs]
            local id = string.sub(name,11)
            if pressedSpace and getProperty(name..'.animation.curAnim.curFrame') >= 5 then
                objectPlayAnimation(name,'punch',true)
            end
            if luaTextExists('VoiidPunchText'..id) then
                setProperty('VoiidPunchText'..id..'.alpha',getProperty(name..'.alpha'))
            end
        end
    end
    if #whiteMatts > 0 then
        for ma = 1,#whiteMatts do
            local name = whiteMatts[ma]
            if name ~= nil then
                if getProperty(name..'.animation.curAnim.finished') == true then
                    if not string.find(name,'sword') then
                        removeLuaSprite(name,true)
                    else
                        doTweenAlpha(name..'mattNoteAlpha',name,0,stepCrochet*0.001*4,'cubeIn')
                    end
                    table.remove(whiteMatts,ma)
                end
            end
        end
    end

end
function onTweenCompleted(tag)
    if string.match(tag,'punchLeave') == 'punchVoiidBye' then
        removePunch(string.sub(tag,9))
    end
end
function createPunch(id,speed)
    local name = 'VoiidPunch'..id
    cancelTween(name..'Bye')
    cancelTimer('punchLeave'..id)
    if not luaSpriteExists(name) then
        if speed == nil then
            speed = 2
        end
        table.insert(voiidSprites,name)
        makeAnimatedLuaSprite(name,'mechanics/punch'..id,screenWidth/2 - 250,screenHeight/2 - 150)
        setObjectCamera(name,'hud')
        addAnimationByPrefix(name,'punch','punch'..id,24,false)
        setProperty(name..'.animation.curAnim.curFrame',9)
        addLuaSprite(name,true)
        setProperty(name..'.alpha',0.001)
        setObjectOrder(name,getObjectOrder('healthBar') + 1)
    end

    doTweenAlpha(name..'Alpha',name,1,stepCrochet*0.0016*speed,'linear')
    local text = 'VoiidPunchText'..id
    if not luaTextExists(text) then
        makeLuaText(text,id,50,getProperty(name..'.x') + 220,getProperty(name..'.y') + 100)
        setObjectCamera(text,'hud')
        setTextSize(text,60)
        setTextBorder(text,0,'000000')
        addLuaText(text,false)
        setObjectOrder(text,getObjectOrder(name) + 1)
    end
    setTextString(text,id)
    setProperty(text..'.visible',true)
end
function removePunch(id)
    if #voiidSprites > 0 then
        for punchs = 1,#voiidSprites do
            if voiidSprites[punchs] == 'VoiidPunch'..id then
                removeLuaSprite(voiidSprites[punchs],true)
                removeLuaText('VoiidPunchText'..punchs,true)
                table.remove(voiidSprites,punchs)
                break
            end
        end
    end
end
function activePunch(id)
    local text = 'VoiidPunchText'..id
    if luaTextExists(text) then
        if tonumber(getTextString(text)) > 1 then
            setTextString(text,tonumber(getTextString(text))-1)
        else
            setProperty(text..'.visible',false)
        end
    end
    punshing = 0.01
    triggerEvent('ca burst', '0.007', '0.01')
end
function onEvent(name,v1,v2)
    if name == 'punch' then
        local punch = tonumber(v1)
        if punch == nil then
            punch = 1
        end
        local speed = tonumber(v2)
        if speed == nil then
            speed = 2
        end
        curPunch = punch
        runTimer('punchLeave'..punch,(stepCrochet*0.0078)*math.min(punch,2))
        activePunch(punch)
        if punch > 1 then
            for punchs = 1,punch-1 do
                local time = stepCrochet*0.0016 + (stepCrochet*0.0064)/punchs
                runTimer('punchDodge'..punch..#voiidPunchs..punchs,time)
                if punchs > 1 then
                    runTimer('createmattattack'..punchs,time - stepCrochet*0.008)
                end
            end
        end
        table.insert(voiidPunchs,punch)
    end
end
function onTimerCompleted(tag)
    if string.match(tag,'punchDodge') then
        activePunch(string.sub(tag,11,string.len(tag) - string.len(#voiidPunchs) - 1))
    elseif string.match(tag,'punchLeave') then
        local id = string.sub(tag,11)
        doTweenAlpha('VoiidPunch'..id..'Bye','VoiidPunch'..id,0,stepCrochet*0.008,'expoOut')
    elseif string.match(tag,'creatematt') then
        local type = string.sub(tag,11,string.len(tag) - 1)
        if type ~= 'attack' and type ~= 'sword' then
            type = 'attack'
        end
        createWhiteMatt(type)
    end
end