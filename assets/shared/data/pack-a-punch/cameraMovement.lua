local BfOfs = 50
local GfOfs = 50
local DadOfs = 50
local targetX = 0
local targetY = 0
local stageCam = false
local enableSystem = true
local curTarget = 'dad'
local centerCamera = false
--[[If you want to know the credits:
i got a ideia of the script by Washo789, 
the script is made by BF Myt.]]--
function onMoveCamera(focus)
    --if curSection == nil then
        curTarget = focus
    --end
end
function detectStage(stage)
    stageCam = false
    setCamOfs(50)
    if stage == 'VoiidBoxingRingFar' then
        setCamOfs(30)
    elseif stage == 'VoiidWiik3' then
        if songName ~= 'King Hit' then
            stageCam = true
        end
       
        targetX = 1625
        targetY = 820
    elseif stage == 'TKO' then
        stageCam = true
        targetX = 410
        targetY = -110
    end
    if targetX == 0 then
        targetX = getCamX(curTarget)
    end
    if targetY == 0 then
        targetY = getCamY(curTarget)
    end
    setProperty('camFollowPos.x',targetX)
    setProperty('camFollowPos.y',targetY)
end
function onCreatePost()
    detectStage(curStage)
end
function setCamOfs(ofs)
    BfOfs = ofs
    DadOfs = ofs
    GfOfs = ofs
end
function onUpdate()
    if enableSystem == true then
        --[[if curSection >= 1 then
            if gfSection ~= true then
                if mustHitSection == false then
                    curTarget = 'dad'

                else
                    curTarget = 'boyfriend'
                end
            else
                curTarget = 'gf'
            end
        end]]
        local ofs = 0
        local anim = getProperty(curTarget..'.animation.curAnim.name')
        if curTarget == 'boyfriend' then
            ofs = BfOfs
        elseif curTarget == 'dad' then
            ofs = DadOfs
        elseif curTarget == 'gf' then
            ofs = GfOfs
        end
        if not stageCam then
            if not centerCamera then
                targetX,targetY = getCamX(curTarget),getCamY(curTarget)
            else
                local posX1 = getCamX('dad')
                local posX2 = getCamX('boyfriend')
                local posY1 = getCamY('dad')
                local posY2 = getCamY('boyfriend')
                targetX = posX1 + (posX2 - posX1)/2
                targetY = posY1 + (posY2 - posY1)/2
            end
        end
        local ofsX = 0
        local ofsY = 0
        if string.find(anim,'LEFT',0,true) then
            ofsX = -ofs
        elseif string.find(anim,'DOWN',0,true) then
            ofsY = ofs
        elseif string.find(anim,'UP',0,true) then
            ofsY = -ofs
        elseif string.find(anim,'RIGHT',0,true) then
            ofsX = ofs
        end
        setProperty('camFollow.x',targetX+ofsX)
        setProperty('camFollow.y',targetY+ofsY)
    end
end
function getCamX(character)
    local x = 0
    local fliped = 1
    if character == 'boyfriend' then
        x = -150
        fliped = -1
    elseif character == 'dad' then
        x = 150
    end
    x = x + getMidpointX(character) + (getProperty(character..'.cameraPosition[0]') * fliped)

    if character == 'gf' then
        character = 'girlfriend'
    elseif character == 'dad' then
        character = 'opponent'
    end
    x = x + getProperty(character..'CameraOffset[0]')
    return x
end
function getCamY(character)
    local y = -100
    if character == 'boyfriend' then
        character = 'boyfriend'
    elseif character == 'gf' then
        y = 0
    end
    y = y + getMidpointY(character) + getProperty(character..'.cameraPosition[1]')
    if character == 'gf' then
        character = 'girlfriend'
    elseif character == 'dad' then
        character = 'opponent'
    end
    y = y + getProperty(character..'CameraOffset[1]')
    return y
end
function onEvent(name,v1,v2)
    if name == 'change block state' then
        if string.find(v1,'duet',0,true) or v1 == 'doubleshield' then
            centerCamera = true
        else
            centerCamera = false
        end
    elseif name == 'Change Stage' then
        detectStage(v1)
    end
end