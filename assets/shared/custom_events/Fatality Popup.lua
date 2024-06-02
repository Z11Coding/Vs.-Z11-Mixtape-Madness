local FB = {'error_popups'}
local FPS = {24, 12, 12}

local Boxhit = {'hitBox'}
local Bxpos = {363, 364, 1025}
local Bypos = {460, 360, 608}

local xpos = 0
local ypos = 0
local ransize = 0

local i = 1
local Boxy = 0
local ugh = 11

function onCreate()
    setPropertyFromClass('flixel.FlxG', 'mouse.visible', false);
    makeLuaSprite('mouse', 'bg/fatal/fatal_mouse_cursor', getMouseX('other'), getMouseY('other'));   
    setProperty('mouse.antialiasing', false);
    scaleLuaSprite('mouse', 1.5, 1.5)
    addLuaSprite('mouse', true);
    setObjectCamera('mouse', 'other')	
    for i = 1,10 do
        makeAnimatedLuaSprite('error_popups'..i, 'bg/fatal/error_popups', getRandomInt(0, 700), getRandomInt(0, 300))
        addAnimationByPrefix('error_popups'..i, 'idle', 'idle', 24, false);
        addAnimationByPrefix('error_popups'..i, 'end', 'end', 36, false);
        scaleObject('error_popups'..i, ransize1, ransize1)
        setProperty('error_popups'..i..'.antialiasing', false);
        addLuaSprite('error_popups'..i, false)
        setObjectCamera('error_popups'..i, 'other')
        objectPlayAnimation('error_popups', 'idle') 
        makeLuaSprite('hitBox'..i, 'hitBox', getProperty('error_popups'..i..'.x') + xpos, getProperty('error_popups'..i..'.y') + ypos)
        setObjectCamera('hitBox'..i, 'other')
        scaleObject('hitBox'..i, SOX, SOY)
        addLuaSprite('hitBox'..i, true)
        setProperty('hitBox'..i..'.alpha', 0.0)
    end
end


function onEvent(name, value1, value2)
    if value1 == '' then
        value1 = 1
    end
    if value2 == '' then
        value2 = 1
    end
    if value2 == 'a' then
        value2 = 1
    end
    if value2 == 'b' then
        value2 = 2
    end
    if value2 == 'c' then
        value2 = 3
    end
    if name == 'Fatality Popup' then 
        if value2 == 1 then   
            for j = 1,value1 do
                if i == 11 then
                    i = 1
                end
                ransize = getRandomInt(1, 5)
                if ransize == 1 then
                    ransize1 = 1.6
                end
                if ransize == 2 then
                    ransize1 = 1.7
                end
                if ransize == 3 then
                    ransize1 = 1.8
                end 
                if ransize == 4 then
                    ransize1 = 1.9
                end 
                if ransize == 5 then
                    ransize1 = 2
                end
                makeAnimatedLuaSprite('error_popups'..i, 'bg/fatal/error_popups', getRandomInt(0, 700), getRandomInt(0, 300))
                addAnimationByPrefix('error_popups'..i, 'idle', 'idle', 24, false);
                addAnimationByPrefix('error_popups'..i, 'end', 'end', 36, false);
                scaleObject('error_popups'..i, ransize1, ransize1)
                setProperty('error_popups'..i..'.antialiasing', false);
                addLuaSprite('error_popups'..i, false)
                setObjectCamera('error_popups'..i, 'other')
                objectPlayAnimation('error_popups', 'idle') 
                if ransize == 1 then
                    xpos = 193
                    ypos = 192
                    SOX = 0.55
                    SOY = 0.3
                end
                if ransize == 2 then
                    xpos = 205
                    ypos = 204
                    SOX = 0.6
                    SOY = 0.31
                end
                if ransize == 3 then
                    xpos = 217
                    ypos = 216
                    SOX = 0.63
                    SOY = 0.32
                end 
                if ransize == 4 then
                    xpos = 230
                    ypos = 228
                    SOX = 0.66
                    SOY = 0.34
                end 
                if ransize == 5 then
                    xpos = 242
                    ypos = 240
                    SOX = 0.69
                    SOY = 0.36
                end
                makeLuaSprite('hitBox'..i, 'hitBox', getProperty('error_popups'..i..'.x') + xpos, getProperty('error_popups'..i..'.y') + ypos)
                setObjectCamera('hitBox'..i, 'other')
                scaleObject('hitBox'..i, SOX, SOY)
                addLuaSprite('hitBox'..i, true)
                setProperty('hitBox'..i..'.alpha', 0.0)
                i = i + 1
            end
        elseif value2 == 2 then
            for j = 1,value1 do
                if ugh == 101 then 
                    ugh = 11
                end
                ransize1 = 2.5
                makeAnimatedLuaSprite('error_popups'..ugh, 'bg/fatal/error_popups', getRandomInt(0, 600), getRandomInt(0, 300))
                addAnimationByPrefix('error_popups'..ugh, 'idle', 'idle', 24, false);
                addAnimationByPrefix('error_popups'..ugh, 'end', 'end', 36, false);
                scaleObject('error_popups'..ugh, ransize1, ransize1)
                setProperty('error_popups'..ugh..'.antialiasing', false);
                addLuaSprite('error_popups'..ugh, false)
                setObjectCamera('error_popups'..ugh, 'other')
                makeLuaSprite('hitBox'..ugh, 'hitBox', getProperty('error_popups'..ugh..'.x') + 302, getProperty('error_popups'..ugh..'.y') + 300)
                setObjectCamera('hitBox'..ugh, 'other')
                scaleObject('hitBox'..ugh, 0.86, 0.45)
                addLuaSprite('hitBox'..ugh, true)
                setProperty('hitBox'..ugh..'.alpha', 0.0)
                ugh = ugh + 1
            end
        elseif value2 == 3 then
            for j = 1,value1 do
                if ugh == 101 then 
                    ugh = 11
                end
                ransize1 = 4.7
                makeAnimatedLuaSprite('error_popups'..ugh, 'bg/fatal/error_popups', -40, -65)
                addAnimationByPrefix('error_popups'..ugh, 'idle', 'idle', 24, false);
                addAnimationByPrefix('error_popups'..ugh, 'end', 'end', 36, false);
                scaleObject('error_popups'..ugh, ransize1, ransize1)
                setProperty('error_popups'..ugh..'.antialiasing', false);
                addLuaSprite('error_popups'..ugh, false)
                setObjectCamera('error_popups'..ugh, 'other')
                makeLuaSprite('hitBox'..ugh, 'hitBox', getProperty('error_popups'..ugh..'.x') + 568, getProperty('error_popups'..ugh..'.y') + 564)
                setObjectCamera('hitBox'..ugh, 'other')
                scaleObject('hitBox'..ugh, 1.6, 0.85)
                addLuaSprite('hitBox'..ugh, true)
                setProperty('hitBox'..ugh..'.alpha', 0.0)
                ugh = ugh + 1
            end
        end
    end
end

function onUpdate(elapsed)
    setProperty('mouse.x', getMouseX('other'))
    setProperty('mouse.y', getMouseY('other'))
    if mouseReleased() then
        for i = 1, 100 do 
            if getMouseX('other') > getProperty('hitBox'..i..'.x') and getMouseY('other') > getProperty('hitBox'..i..'.y') and getMouseX('other') < getProperty('hitBox'..i..'.x') + getProperty('hitBox'..i..'.width') and getMouseY('other') < getProperty('hitBox'..i..'.y') + getProperty('hitBox'..i..'.height') and mouseReleased() then
                objectPlayAnimation('error_popups'..i, 'end') 
                runTimer('endd'..i, .1)
            end
        end
    end
    
end

function onTimerCompleted(tag, loops, loopsLeft)
    for i = 1, 100 do     
        if tag == 'endd'..i then
            setProperty('error_popups'..i..'.visible', false);
        end
    end
end