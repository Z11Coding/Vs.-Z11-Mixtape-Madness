messageAlt = {
    [0] = {'but it refused'},
    [1] = {'not yet!'},
    [2] = {'don\'t give up!'},
    [3] = {'keep going, Pico!'},
    [4] = {'It\'s not your fault'},
    [5] = {'The pause menu is gone, too...'},
    [6] = {'death means nothing here...'},
    [7] = {'you don\'t deserve this...'},
    [8] = {'nothing\'s left...'},
    [9] = {'nobody\'s left...'},
    [10] = {'...'},
}
function onPause()
    randMessageAlt = math.random(0, 10)
    setTextString('ready', messageAlt[randMessageAlt])
    setProperty('ready.visible', true)
    setProperty('ready.alpha', 1)
    doTweenAlpha("imready", "ready", 0, 1, "sineInOut")
    --return Function_Stop
end

function onUpdate(elapsed)
    screenCenter('ready')
    setProperty('ready.y',getProperty('ready.y')-200)
    if getProperty('ready.alpha') == 0 then
        setProperty('ready.visible', false)
        setProperty('ready.alpha', 1)
    end
end

function onCreatePost()
    makeLuaText('ready', 'ready?', 0, 10, 355)
    setObjectCamera('ready', 'camOther')
	setTextSize('ready', 50)
	addLuaText('ready', true)
    setProperty('ready.visible', false)
end