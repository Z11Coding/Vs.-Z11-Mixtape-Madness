local daDrain = 0
local fadetime = 0.01
function onCreatePost()
   precacheImage('BEAT_assets')
    makeLuaText("warn", "REMEMBER THIS PART!", 800, getProperty("botplayTxt.x") - 140, getProperty("botplayTxt.y") + 140)
    setTextSize('warn', 45)
    setObjectCamera("warn", "hud")
    setTextColor('warn', 'be201c')
    addLuaText('warn')
    setProperty("warn.visible", false)

    makeLuaText("pain", "You Won't Be Needing These!", 800, getProperty("botplayTxt.x") + 160, getProperty("botplayTxt.y") - 400)
    setTextSize('pain', 25)
    setObjectCamera("pain", "hud")
    addLuaText('pain')
    setProperty("pain.alpha", 0)

    makeAnimatedLuaSprite("notestoremember", "BEAT_assets", 0, 0)
    screenCenter("notestoremember", 'xy')
    addAnimationByPrefix("notestoremember", "left", "purple0", 24, true)
    addAnimationByPrefix("notestoremember", "down", "blue0", 24, true)
    addAnimationByPrefix("notestoremember", "up", "green0", 24, true)
    addAnimationByPrefix("notestoremember", "right", "red0", 24, true)
    addLuaSprite("notestoremember", false)
    setObjectCamera("notestoremember", "hud")
    setProperty("notestoremember.alpha", 0)

end

function onBeatHit()
    for i = 0, getProperty('notes.length') -1 do
        if getPropertyFromGroup('notes', i, 'noteType') == 'ArrowMech' then
            setProperty("warn.visible", true)
            if not mustHitSection then
                showArrow = true
            end
            if difficultyName == 'Unreasonable' then
                for a = 0, 3 do
                    setPropertyFromGroup('strumLineNotes', a, 'alpha', 0)
                end
            end
        else
            setProperty("warn.visible", false)
            if difficultyName == 'Unreasonable' then
                for a = 0, 3 do
                    setPropertyFromGroup('strumLineNotes', a, 'alpha', 1)
                end
            end
            showArrow = false
        end
    end
    if curBeat == 254 and (difficultyName == 'Semi-Impossible' or difficultyName == 'Impossible') then
        noteTweenY("suffering", 4, 70, 2, "elasticInOut")
    end
end

function onTimerCompleted(tag)
    if tag == 'kys' then
        doTweenY("paina", "pain", getProperty("botplayTxt.y") - 400, 2, "sineOut")
    end
end


function onUpdatePost()
    for i = 0, getProperty('notes.length') -1 do
        if getPropertyFromGroup('notes', i, 'noteType') == 'ArrowMech' then
            if getPropertyFromGroup('notes', i, 'mustPress') then
                setPropertyFromGroup('notes', i, 'alpha', 0)
				setPropertyFromGroup('notes', i, 'multAlpha', 0)
            else if not getPropertyFromGroup('notes', i, 'mustPress') then
                setPropertyFromGroup('notes', i, 'alpha', 0)
				setPropertyFromGroup('notes', i, 'multAlpha', 0)
            end
            end
        end
    end
    if difficultyName == 'Impossible' then
        fadetime = 0.08
    end
	if difficultyName == 'hell' or 'Hell' and not 'normal' then
	daDrain = 0.01999
	end
    if getProperty("notestoremember.alpha") > 0 then
        setProperty("notestoremember.alpha", getProperty("notestoremember.alpha")-fadetime)
    end
end
local direcList = {'left', 'down', 'up', 'right'}
function opponentNoteHit(id, direc, type, sus)
    if getProperty('health') > 0.1 then
        setProperty('health', getProperty('health') - daDrain)
    end
        if type == 'ArrowMech' and not sus then
            playAnim('notestoremember', direcList[direc+1], true)
            if showArrow then
                setProperty("notestoremember.alpha", 1)
            end
        end
end