-- TAKE ME TO THE ACTION
-- script by Kaite#1102
-- This script lets you skip right to gameplay! (Sends you right before the first note)
-- useful when a song has a long wait before the action and you're trying to do something

-- CONFIG:
local checkForBF = false    -- Should the script check if the first note is yours           > (Default: false)
local beatsBefore = 2       -- How many beats before the first note will the time skip to   > (Default: 2)
local keybind = 'SPACE'      -- What keybind will trigger the skip, leave blank for none     > (Default: 'back')
local keyboard = ''         -- What keyboard key will trigger the skip, blank for none      > (Default: '')
-- DONT TOUCH ANYTHING BELOW THIS HHH
-- oops I did my bad :(

local skipTime = 0
local canSkip = false
local crochet1 = 0
function onCreatePost()
    crochet1 = crochet
    skipTime = getPropertyFromGroup('unspawnNotes', 0, 'strumTime') - (crochet1*2)
    for i = 0, getProperty('unspawnNotes.length') do
        skipTime = getPropertyFromGroup('unspawnNotes', i, 'strumTime') - (crochet1*2)
        break
    end
    if keybind ~= '' and keyboard ~= '' then
        keyToPressText = keybind..' or '..keyboard
    else if keybind == '' and keyboard ~= '' then
        keyToPressText = keyboard
    else if keybind ~= '' and keyboard == '' then
        keyToPressText = keybind
    end
    end
    end
    makeLuaText('skipText', 'Press '..keyToPressText..' to skip intro.', 650, 0, 400)
    setObjectCamera('skipText', 'hud')
    setTextFont('skipText', 'FridayNightFunkin')
    if songName ~= 'Resistance-kai' then
    addLuaText('skipText')
    end
    setProperty('skipText.alpha', 0)
    setTextSize('skipText', 50)
    screenCenter('skipText', 'X')
    -- debugPrint(skipTime)
end

function onUpdatePost(e)
    if canSkip and getSongPosition() < skipTime then
        if keyboardJustPressed("SPACE") then
            canSkip = false
            -- debugPrint('hi ', getSongPosition(), ' ', skipTime)
            playSound('confirmMenu')
            cameraFlash('other', '0x55FFFFFF', crochet1*0.001, true)
            doTweenAlpha('skipTextAlpha2', 'skipText', 0, 1, 'sineInOut')
            setTextString('skipText', 'Good Luck!')
	        runHaxeCode([[game.setSongTime(]]..(skipTime)..[[)]])
        end
    if canSkip and getSongPosition() > skipTime then
        canSkip = false    
        doTweenAlpha('skipTextAlpha2', 'skipText', 0, 1, 'sineInOut')
        setTextString('skipText', 'Good Luck!')
    end
    end
end

function opponentNoteHit()
    if canSkip then
        canSkip = false    
        doTweenAlpha('skipTextAlpha2', 'skipText', 0, 1, 'sineInOut')
        setTextString('skipText', 'Good Luck!')
    end
end

function goodNoteHit()
    if canSkip then
        canSkip = false    
        doTweenAlpha('skipTextAlpha2', 'skipText', 0, 1, 'sineInOut')
        setTextString('skipText', 'Good Luck!')
    end
end

function onSongStart()
    canSkip = true
    doTweenAlpha('skipTextAlpha', 'skipText', 1, 1, 'sineInOut')
end