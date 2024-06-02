--╭━━━╮╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╭━╮╭━╮╱╱╱╱╭╮╱╱╭╮╱╱╱╱╱╱╭╮
--┃╭━╮┃╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱┃┃╰╯┃┃╱╱╱╱┃┃╱╱┃┃╱╱╱╱╱╭╯╰╮
--┃┃╱╰╋━┳━━┳━━┳╮╭┳┳━╮╭━━╮┃╭╮╭╮┣━━┳━╯┣━━┫╰━┳━━┳┻╮╭╯
--┃┃╭━┫╭┫╭╮┃╭╮┃╰╯┣┫╭╮┫╭╮┃┃┃┃┃┃┃╭╮┃╭╮┃╭━┫╭╮┃╭╮┃╭┫┃
--┃╰┻━┃┃┃╰╯┃╰╯┣╮╭┫┃┃┃┃╰╯┃┃┃┃┃┃┃╰╯┃╰╯┃╰━┫┃┃┃╭╮┃┃┃╰╮
--╰━━━┻╯╰━━┻━━╯╰╯╰┻╯╰┻━╮┃╰╯╰╯╰┻━━┻━━┻━━┻╯╰┻╯╰┻╯╰━╯
--╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╭━╯┃
--╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╰━━╯ v2.0

-- modchart tool / frame work by: Leo_BPM
-- already working with Lua Sprites In fnf psych engine :D
-- inspiration from TheZoroForce240 <3
-- wtf i turned this in NotItG xddd

--unorganized shit (DONT TOUCH!!)
local Drunk = true;
local RandomSpeed = true;
local SpeedControll

local StrumsCntrl = true;
local Invert = true;
local AngleNotes = true;
local SizeNotes = true;
local Tipsy = true;
local Opacity = true;

function onCreatePost()
    Aux()
    --Note Effects
    makeLuaSprite('drunk', '', 0, 0) -- work X and Y
    makeLuaSprite('SPDdrunk', '', 0.01, 0.01) -- work X and Y
    makeLuaSprite('SpeedMulti', '', 1, 1) -- work Y

    makeLuaSprite('InvertP', '', 1, 1) -- work Y
    makeLuaSprite('InvertO', '', 1, 1) -- work Y
    makeLuaSprite('Flip', '', 1, 1) -- work X
    makeLuaSprite('Swap', '', 1, 1) -- work X
    makeLuaSprite('AngleStrum', '', 0, 0) -- work angle (duuuuhhh)
    makeLuaSprite('bulge', '', 1, 1) -- work Y
    makeLuaSprite('noteSize', '', 100, 100) -- work Y
    makeLuaSprite('inclination', '', 0, 0) -- work Y
    makeLuaSprite('tipsy', '', 0, 0) -- work X and Y
    makeLuaSprite('SPDtipsy', '', 0.1, 0.1) -- work X and Y
    makeLuaSprite('OPfadeStrums', '', 1, 1) -- work alpha
    makeLuaSprite('PLfadeStrums', '', 1, 1) -- work alpha
end

function Aux()
    --Current Strums
    makeLuaSprite('PlStrum', '', 320, 255)
    makeLuaSprite('OpStrum', '', -320, 255)
    
    -----current Notes-----
    makeLuaSprite('OPnote1', '', 0, 0) 
    makeLuaSprite('OPnote2', '', 0, 0) 
    makeLuaSprite('OPnote3', '', 0, 0) 
    makeLuaSprite('OPnote4', '', 0, 0) 

    makeLuaSprite('PLnote1', '', 0, 0) 
    makeLuaSprite('PLnote2', '', 0, 0) 
    makeLuaSprite('PLnote3', '', 0, 0) 
    makeLuaSprite('PLnote4', '', 0, 0) 

    --to make size
    makeLuaSprite('OnotSize1', '', 0, 0)
    makeLuaSprite('OnotSize2', '', 0, 0)
    makeLuaSprite('OnotSize3', '', 0, 0)
    makeLuaSprite('OnotSize4', '', 0, 0)

    makeLuaSprite('PnotSize1', '', 0, 0)
    makeLuaSprite('PnotSize2', '', 0, 0)
    makeLuaSprite('PnotSize3', '', 0, 0)
    makeLuaSprite('PnotSize4', '', 0, 0)


    --shitty
    makeLuaText('text', 'Grooving modchart v2.0 | leo_BPM', 500, -805)
    setTextAlignment('text', 'right')
    setTextSize('text', 15)
    addLuaText('text')
    setObjectCamera('text', 'Other')
    doTweenX('kchuda', 'text', 750, 0.001, 'linear')
    doTweenY('kchudo', 'text', 680, 0.001, 'linear')
    doTweenAlpha('kchude', 'text', 0.2,0.1)
end

-- vvv don't touch this vvv

--<░█████╗░░█████╗░██████╗░███████╗>
--<██╔══██╗██╔══██╗██╔══██╗██╔════╝>
--<██║░░╚═╝██║░░██║██║░░██║█████╗░░>
--<██║░░██╗██║░░██║██║░░██║██╔══╝░░>
--<╚█████╔╝╚█████╔╝██████╔╝███████╗>
--<░╚════╝░░╚════╝░╚═════╝░╚══════╝>


function onUpdatePost(elapsed)

    if Drunk == true then
        for i = 0, getProperty('notes.length')-1 do
            --if not getPropertyFromGroup('notes', i, 'isSustainNote') then
                distance = getPropertyFromGroup('notes', i, 'strumTime') - getSongPosition();
                if getPropertyFromGroup('notes', i, 'mustPress') == false then 
                    setPropertyFromGroup('notes', i, 'x', getPropertyFromGroup('notes', i, 'x') + math.sin(distance / -getProperty('SPDdrunk.x')) * getProperty('drunk.x'));
                else
                    setPropertyFromGroup('notes', i, 'x', getPropertyFromGroup('notes', i, 'x') + math.sin(distance / getProperty('SPDdrunk.x')) * getProperty('drunk.x'));
                end
    
                if getPropertyFromGroup('notes', i, 'mustPress') == false then 
                    setPropertyFromGroup('notes', i, 'y', getPropertyFromGroup('notes', i, 'y') + math.sin(distance / -getProperty('SPDdrunk.y')) * getProperty('drunk.y'));
                else
                    setPropertyFromGroup('notes', i, 'y', getPropertyFromGroup('notes', i, 'y') + math.sin(distance / getProperty('SPDdrunk.y')) * getProperty('drunk.y'));
                end
            --end
        end
    end
end

function onUpdate(elapsed)

    songPos = getSongPosition()

    --new notes shit

    xOpNote1 = getProperty ('OPnote1.x')
    xOpNote2 = getProperty ('OPnote2.x')
    xOpNote3 = getProperty ('OPnote3.x')
    xOpNote4 = getProperty ('OPnote4.x')

    xPlNote1 = getProperty ('PLnote1.x')
    xPlNote2 = getProperty ('PLnote2.x')
    xPlNote3 = getProperty ('PLnote3.x')
    xPlNote4 = getProperty ('PLnote4.x')

    yOpNote1 = getProperty ('OPnote1.y')
    yOpNote2 = getProperty ('OPnote2.y')
    yOpNote3 = getProperty ('OPnote3.y')
    yOpNote4 = getProperty ('OPnote4.y')

    yPlNote1 = getProperty ('PLnote1.y')
    yPlNote2 = getProperty ('PLnote2.y')
    yPlNote3 = getProperty ('PLnote3.y')
    yPlNote4 = getProperty ('PLnote4.y')

    angOpNote1 = getProperty ('OPnote1.angle')
    angOpNote2 = getProperty ('OPnote2.angle')
    angOpNote3 = getProperty ('OPnote3.angle')
    angOpNote4 = getProperty ('OPnote4.angle')

    angPlNote1 = getProperty ('PLnote1.angle')
    angPlNote2 = getProperty ('PLnote2.angle')
    angPlNote3 = getProperty ('PLnote3.angle')
    angPlNote4 = getProperty ('PLnote4.angle')

    SxOpNote1 = getProperty ('OnotSize1.x')
    SxOpNote2 = getProperty ('OnotSize2.x')
    SxOpNote3 = getProperty ('OnotSize3.x')
    SxOpNote4 = getProperty ('OnotSize4.x')

    SxPlNote1 = getProperty ('PnotSize1.x')
    SxPlNote2 = getProperty ('PnotSize2.x')
    SxPlNote3 = getProperty ('PnotSize3.x')
    SxPlNote4 = getProperty ('PnotSize4.x')

    SyOpNote1 = getProperty ('OnotSize1.y')
    SyOpNote2 = getProperty ('OnotSize2.y')
    SyOpNote3 = getProperty ('OnotSize3.y')
    SyOpNote4 = getProperty ('OnotSize4.y')

    SyPlNote1 = getProperty ('PnotSize1.y')
    SyPlNote2 = getProperty ('PnotSize2.y')
    SyPlNote3 = getProperty ('PnotSize3.y')
    SyPlNote4 = getProperty ('PnotSize4.y')

    if Invert == true then
        for i = 0, getProperty('notes.length')-1 do
            if getPropertyFromGroup('notes', i, 'mustPress') then
                setPropertyFromGroup('notes', i, 'multSpeed', getProperty('InvertP.y') * getProperty('SpeedMulti.y'))
            end
        end

        for i = 0, getProperty('notes.length')-1 do
            if not getPropertyFromGroup('notes', i, 'mustPress') then
                setPropertyFromGroup('notes', i, 'multSpeed', getProperty('InvertO.y') * getProperty('SpeedMulti.y'))
            end
        end
    end

    if StrumsCntrl == true then
        -- Y

        Bulge = getProperty('bulge.y')
        mid = Bulge/3

        for i = 0, getProperty('playerStrums.length')-1 do
            setPropertyFromGroup('playerStrums', 0, 'y', yPlNote1 + 315 + getProperty('inclination.y') - mid + getProperty('PlStrum.y') * -getProperty('InvertP.y'))
            setPropertyFromGroup('playerStrums', 1, 'y', yPlNote2 + 315 + getProperty('inclination.y')/3 - Bulge + getProperty('PlStrum.y') * -getProperty('InvertP.y'))
            setPropertyFromGroup('playerStrums', 2, 'y', yPlNote3 + 315 - getProperty('inclination.y')/3 - Bulge + getProperty('PlStrum.y') * -getProperty('InvertP.y'))
            setPropertyFromGroup('playerStrums', 3, 'y', yPlNote4 + 315 - getProperty('inclination.y') - mid + getProperty('PlStrum.y') * -getProperty('InvertP.y'))
        end
    
        for i = 0, getProperty('opponentStrums.length')-1 do
            setPropertyFromGroup('opponentStrums', 0, 'y', yOpNote1 + 315 + getProperty('inclination.y') - mid + getProperty('OpStrum.y') * -getProperty('InvertO.y'))
            setPropertyFromGroup('opponentStrums', 1, 'y', yOpNote2 + 315 + getProperty('inclination.y')/3 - Bulge + getProperty('OpStrum.y') * -getProperty('InvertO.y'))
            setPropertyFromGroup('opponentStrums', 2, 'y', yOpNote3 + 315 - getProperty('inclination.y')/3 - Bulge+ getProperty('OpStrum.y') * -getProperty('InvertO.y'))
            setPropertyFromGroup('opponentStrums', 3, 'y', yOpNote4 + 315 - getProperty('inclination.y') - mid + getProperty('OpStrum.y') * -getProperty('InvertO.y'))
        end

        -- X

        toFlip = 114 * getProperty('Flip.x')
        Ubic0 = 581

        for i = 0, getProperty('playerStrums.length') - 1 do
            setPropertyFromGroup('playerStrums', 0, 'x', xPlNote1 + Ubic0 - toFlip - toFlip/2 + getProperty('PlStrum.x') * getProperty('Swap.x'))
            setPropertyFromGroup('playerStrums', 1, 'x', xPlNote2 + Ubic0 - toFlip/2 + getProperty('PlStrum.x') * getProperty('Swap.x'))
            setPropertyFromGroup('playerStrums', 2, 'x', xPlNote3 + Ubic0 + toFlip/2  + getProperty('PlStrum.x') * getProperty('Swap.x'))
            setPropertyFromGroup('playerStrums', 3, 'x', xPlNote4 + Ubic0 + toFlip + toFlip/2  + getProperty('PlStrum.x') * getProperty('Swap.x'))
        end
        
        for i = 0, getProperty('opponentStrums.length') - 1 do
            setPropertyFromGroup('opponentStrums', 0, 'x', xOpNote1 + Ubic0 - toFlip - toFlip/2 + getProperty('OpStrum.x') * getProperty('Swap.x'))
            setPropertyFromGroup('opponentStrums', 1, 'x', xOpNote4 + Ubic0 - toFlip/2 + getProperty('OpStrum.x') * getProperty('Swap.x'))
            setPropertyFromGroup('opponentStrums', 2, 'x', xOpNote3 + Ubic0 + toFlip/2  + getProperty('OpStrum.x') * getProperty('Swap.x'))
            setPropertyFromGroup('opponentStrums', 3, 'x', xOpNote2 + Ubic0 + toFlip + toFlip/2  + getProperty('OpStrum.x') * getProperty('Swap.x'))
        end
    end

    if AngleNotes == true then

        for i = 0, getProperty('playerStrums.length')-1 do
            setPropertyFromGroup('playerStrums', 0, 'angle', angPlNote1 + getProperty('AngleStrum.angle') - getProperty('camHUD.angle') - mid)
            setPropertyFromGroup('playerStrums', 1, 'angle', angPlNote2 + getProperty('AngleStrum.angle') - getProperty('camHUD.angle') - Bulge)
            setPropertyFromGroup('playerStrums', 2, 'angle', angPlNote3 + getProperty('AngleStrum.angle') - getProperty('camHUD.angle') + Bulge)
            setPropertyFromGroup('playerStrums', 3, 'angle', angPlNote4 + getProperty('AngleStrum.angle') - getProperty('camHUD.angle') + mid)
        end
    
        -- Establecer el ángulo de las strums del oponente
        for i = 0, getProperty('opponentStrums.length')-1 do
            setPropertyFromGroup('opponentStrums', 0, 'angle', angOpNote1 + getProperty('AngleStrum.angle') - getProperty('camHUD.angle') - mid)
            setPropertyFromGroup('opponentStrums', 1, 'angle', angOpNote1 + getProperty('AngleStrum.angle') - getProperty('camHUD.angle') - Bulge)
            setPropertyFromGroup('opponentStrums', 2, 'angle', angOpNote1 + getProperty('AngleStrum.angle') - getProperty('camHUD.angle') + Bulge)
            setPropertyFromGroup('opponentStrums', 3, 'angle', angOpNote1 + getProperty('AngleStrum.angle') - getProperty('camHUD.angle') + mid)
        end
    end 

    if SizeNotes == true then

        divFactor = 145
        strumScaleX = getProperty('noteSize.x')/divFactor
        strumScaleY = getProperty('noteSize.y')/divFactor

        for i = 0, getProperty('playerStrums.length')-1 do
            setPropertyFromGroup('playerStrums', 0, 'scale.x', getProperty('PnotSize1.x') + strumScaleX)
            setPropertyFromGroup('playerStrums', 1, 'scale.x', getProperty('PnotSize2.x') + strumScaleX)
            setPropertyFromGroup('playerStrums', 2, 'scale.x', getProperty('PnotSize3.x') + strumScaleX)
            setPropertyFromGroup('playerStrums', 3, 'scale.x', getProperty('PnotSize4.x') + strumScaleX)
    
            setPropertyFromGroup('playerStrums', 0, 'scale.y', getProperty('PnotSize1.y') + strumScaleY)
            setPropertyFromGroup('playerStrums', 1, 'scale.y', getProperty('PnotSize2.y') + strumScaleY)
            setPropertyFromGroup('playerStrums', 2, 'scale.y', getProperty('PnotSize3.y') + strumScaleY)
            setPropertyFromGroup('playerStrums', 3, 'scale.y', getProperty('PnotSize4.y') + strumScaleY)
        end
    
        for i = 0, getProperty('opponentStrums.length')-1 do
            setPropertyFromGroup('opponentStrums', 0, 'scale.x', getProperty('OnotSize1.x') + strumScaleX)
            setPropertyFromGroup('opponentStrums', 1, 'scale.x', getProperty('OnotSize2.x') + strumScaleX)
            setPropertyFromGroup('opponentStrums', 2, 'scale.x', getProperty('OnotSize3.x') + strumScaleX)
            setPropertyFromGroup('opponentStrums', 3, 'scale.x', getProperty('OnotSize4.x') + strumScaleX)
            
            setPropertyFromGroup('opponentStrums', 0, 'scale.y', getProperty('OnotSize1.y') + strumScaleY)
            setPropertyFromGroup('opponentStrums', 1, 'scale.y', getProperty('OnotSize2.y') + strumScaleY)
            setPropertyFromGroup('opponentStrums', 2, 'scale.y', getProperty('OnotSize3.y') + strumScaleY)
            setPropertyFromGroup('opponentStrums', 3, 'scale.y', getProperty('OnotSize4.y') + strumScaleY)
        end

        for i = 0, getProperty('notes.length')-1 do
            setPropertyFromGroup('notes', i, 'scale.x', strumScaleX)
            if not getPropertyFromGroup('notes', i, 'isSustainNote') then
                setPropertyFromGroup('notes', i, 'scale.y', strumScaleY)
            end
        end
    end

    if Tipsy == true then
        tipsyXspeed = getProperty('SPDtipsy.x')
        tipsyYspeed = getProperty('SPDtipsy.y')
        tipsyXint = getProperty('tipsy.x')
        tipsyYint = getProperty('tipsy.y')

        local currentBeatTipX = (songPos/5000)*(curBpm/tipsyXspeed)
        local currentBeatTipY = (songPos/5000)*(curBpm/tipsyYspeed)

        --X
        doTweenX('Xnotep1', 'PLnote1', tipsyXint * math.sin((currentBeatTipX + 4 * 0.25) * math.pi), 0.1, 'linear')
        doTweenX('Xnotep2', 'PLnote2', tipsyXint * math.sin((currentBeatTipX + 5 * 0.25) * math.pi), 0.1, 'linear')
        doTweenX('Xnotep3', 'PLnote3', tipsyXint * math.sin((currentBeatTipX + 6 * 0.25) * math.pi), 0.1, 'linear')
        doTweenX('Xnotep4', 'PLnote4', tipsyXint * math.sin((currentBeatTipX + 7 * 0.25) * math.pi), 0.1, 'linear')

        doTweenY('Ynotep1', 'PLnote1', tipsyYint * math.cos((currentBeatTipY + 4 * 0.25) * math.pi), 0.1, 'linear')
        doTweenY('Ynotep2', 'PLnote2', tipsyYint * math.cos((currentBeatTipY + 5 * 0.25) * math.pi), 0.1, 'linear')
        doTweenY('Ynotep3', 'PLnote3', tipsyYint * math.cos((currentBeatTipY + 6 * 0.25) * math.pi), 0.1, 'linear')
        doTweenY('Ynotep4', 'PLnote4', tipsyYint * math.cos((currentBeatTipY + 7 * 0.25) * math.pi), 0.1, 'linear')

        -- Y
        doTweenX('noteo1', 'OPnote1', tipsyXint * math.sin((currentBeatTipX + 2 * 0.25) * math.pi), 0.1, 'linear')
        doTweenX('noteo2', 'OPnote2', tipsyXint * math.sin((currentBeatTipX + 1 * 0.25) * math.pi), 0.1, 'linear')
        doTweenX('noteo3', 'OPnote3', tipsyXint * math.sin((currentBeatTipX + 2 * 0.25) * math.pi), 0.1, 'linear')
        doTweenX('noteo4', 'OPnote4', tipsyXint * math.sin((currentBeatTipX + 3 * 0.25) * math.pi), 0.1, 'linear')

        doTweenY('Ynoteo1', 'OPnote1', tipsyYint * math.cos((currentBeatTipY + 0 * 0.25) * math.pi), 0.1, 'linear')
        doTweenY('Ynoteo2', 'OPnote2', tipsyYint * math.cos((currentBeatTipY + 1 * 0.25) * math.pi), 0.1, 'linear')
        doTweenY('Ynoteo3', 'OPnote3', tipsyYint * math.cos((currentBeatTipY + 2 * 0.25) * math.pi), 0.1, 'linear')
        doTweenY('Ynoteo4', 'OPnote4', tipsyYint * math.cos((currentBeatTipY + 3 * 0.25) * math.pi), 0.1, 'linear')
    end

    if Opacity == true then
        OpFade = getProperty('OPfadeStrums.alpha')
        PlFade = getProperty('PLfadeStrums.alpha')

        for i = 0, getProperty('notes.length')-1 do
            setPropertyFromGroup('playerStrums', i, 'alpha', PlFade)
            
            setPropertyFromGroup('opponentStrums', i, 'alpha', OpFade)
        end
    end
end